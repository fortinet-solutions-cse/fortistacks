#!/bin/bash
# from  https://osm-download.etsi.org/ftp/osm-3.0-three/install_osm.sh modified
#   Copyright 2016 Telefónica Investigación y Desarrollo S.A.U.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

function usage(){
    echo -e "usage: $0 [OPTIONS]"
    echo -e "Install OSM from binaries or source code (by default, from binaries)"
    echo -e "  OPTIONS"
    echo -e "     --uninstall:    uninstall OSM: remove the containers and delete NAT rules"
    echo -e "     --source:       install OSM from source code using the latest stable tag"
    echo -e "     -r <repo>:      use specified repository name for osm packages"
    echo -e "     -R <release>:   use specified release for osm binaries (deb packages, lxd images, ...)"
    echo -e "     -u <repo base>: use specified repository url for osm packages"
    echo -e "     -k <repo key>:  use specified repository public key url"
    echo -e "     -b <refspec>:   install OSM from source code using a specific branch (master, v2.0, ...) or tag"
    echo -e "                     -b master          (main dev branch)"
    echo -e "                     -b v2.0            (v2.0 branch)"
    echo -e "                     -b tags/v1.1.0     (a specific tag)"
    echo -e "                     ..."
    echo -e "     --lxdimages:    download lxd images from OSM repository instead of creating them from scratch"
    echo -e "     -l <lxd_repo>:  use specified repository url for lxd images"
    echo -e "     --develop:      (deprecated, use '-b master') install OSM from source code using the master branch"
#    echo -e "     --reconfigure:  reconfigure the modules (DO NOT change NAT rules)"
    echo -e "     --nat:          install only NAT rules"
    echo -e "     --noconfigure:  DO NOT install osmclient, DO NOT install NAT rules, DO NOT configure modules"
#    echo -e "     --update:       update to the latest stable release or to the latest commit if using a specific branch"
    echo -e "     --showopts:     print chosen options and exit (only for debugging)"
    echo -e "     -y:             do not prompt for confirmation, assumes yes"
    echo -e "     -h / --help:    print this help"
}

#Uninstall OSM: remove containers
function uninstall(){
    echo -e "\nUninstalling OSM"
    if [ $RC_CLONE ] || [ -n "$TEST_INSTALLER" ]; then
        $OSM_DEVOPS/jenkins/host/clean_container RO
        $OSM_DEVOPS/jenkins/host/clean_container VCA
        $OSM_DEVOPS/jenkins/host/clean_container SO
        #$OSM_DEVOPS/jenkins/host/clean_container UI
    else
        lxc stop RO && lxc delete RO
        lxc stop VCA && lxc delete VCA
        lxc stop SO-ub && lxc delete SO-ub
    fi
}



function FATAL(){
    echo "FATAL error: Cannot install OSM due to \"$1\""
    exit 1
}

#Update RO, SO and UI:
function update(){
    echo -e "\nUpdating components"

    echo -e "     Updating RO"
    CONTAINER="RO"
    MDG="RO"
    INSTALL_FOLDER="/opt/openmano"
    echo -e "     Fetching the repo"
    lxc exec $CONTAINER -- git -C $INSTALL_FOLDER fetch --all
    BRANCH=""
    BRANCH=`lxc exec $CONTAINER -- git -C $INSTALL_FOLDER status -sb | head -n1 | sed -n 's/^## \(.*\).*/\1/p'|awk '{print $1}' |sed 's/\(.*\)\.\.\..*/\1/'`
    [ -z "$BRANCH" ] && FATAL "Could not find the current branch in use in the '$MDG'"
    CURRENT=`lxc exec $CONTAINER -- git -C $INSTALL_FOLDER status |head -n1`
    CURRENT_COMMIT_ID=`lxc exec $CONTAINER -- git -C $INSTALL_FOLDER rev-parse HEAD`
    echo "         FROM: $CURRENT ($CURRENT_COMMIT_ID)"
    # COMMIT_ID either was  previously set with -b option, or is an empty string
    CHECKOUT_ID=$COMMIT_ID
    [ -z "$CHECKOUT_ID" ] && [ "$BRANCH" == "HEAD" ] && CHECKOUT_ID="tags/$LATEST_STABLE_DEVOPS"
    [ -z "$CHECKOUT_ID" ] && [ "$BRANCH" != "HEAD" ] && CHECKOUT_ID="$BRANCH"
    if [[ $CHECKOUT_ID == "tags/"* ]]; then
        REMOTE_COMMIT_ID=`lxc exec $CONTAINER -- git -C $INSTALL_FOLDER rev-list -n 1 $CHECKOUT_ID`
    else
        REMOTE_COMMIT_ID=`lxc exec $CONTAINER -- git -C $INSTALL_FOLDER rev-parse origin/$CHECKOUT_ID`
    fi
    echo "         TO: $CHECKOUT_ID ($REMOTE_COMMIT_ID)"
    if [ "$CURRENT_COMMIT_ID" == "$REMOTE_COMMIT_ID" ]; then
        echo "         Nothing to be done."
    else
        echo "         Update required."
        lxc exec $CONTAINER -- service osm-ro stop
        lxc exec $CONTAINER -- git -C /opt/openmano stash
        lxc exec $CONTAINER -- git -C /opt/openmano pull --rebase
        lxc exec $CONTAINER -- git -C /opt/openmano checkout $CHECKOUT_ID
        lxc exec $CONTAINER -- git -C /opt/openmano stash pop
        lxc exec $CONTAINER -- /opt/openmano/database_utils/migrate_mano_db.sh
        lxc exec $CONTAINER -- service osm-ro start
    fi
    echo

    echo -e "     Updating SO and UI"
    CONTAINER="SO-ub"
    MDG="SO"
    INSTALL_FOLDER=""   # To be filled in
    echo -e "     Fetching the repo"
    lxc exec $CONTAINER -- git -C $INSTALL_FOLDER fetch --all
    BRANCH=""
    BRANCH=`lxc exec $CONTAINER -- git -C $INSTALL_FOLDER status -sb | head -n1 | sed -n 's/^## \(.*\).*/\1/p'|awk '{print $1}' |sed 's/\(.*\)\.\.\..*/\1/'`
    [ -z "$BRANCH" ] && FATAL "Could not find the current branch in use in the '$MDG'"
    CURRENT=`lxc exec $CONTAINER -- git -C $INSTALL_FOLDER status |head -n1`
    CURRENT_COMMIT_ID=`lxc exec $CONTAINER -- git -C $INSTALL_FOLDER rev-parse HEAD`
    echo "         FROM: $CURRENT ($CURRENT_COMMIT_ID)"
    # COMMIT_ID either was  previously set with -b option, or is an empty string
    CHECKOUT_ID=$COMMIT_ID
    [ -z "$CHECKOUT_ID" ] && [ "$BRANCH" == "HEAD" ] && CHECKOUT_ID="tags/$LATEST_STABLE_DEVOPS"
    [ -z "$CHECKOUT_ID" ] && [ "$BRANCH" != "HEAD" ] && CHECKOUT_ID="$BRANCH"
    if [[ $CHECKOUT_ID == "tags/"* ]]; then
        REMOTE_COMMIT_ID=`lxc exec $CONTAINER -- git -C $INSTALL_FOLDER rev-list -n 1 $CHECKOUT_ID`
    else
        REMOTE_COMMIT_ID=`lxc exec $CONTAINER -- git -C $INSTALL_FOLDER rev-parse origin/$CHECKOUT_ID`
    fi
    echo "         TO: $CHECKOUT_ID ($REMOTE_COMMIT_ID)"
    if [ "$CURRENT_COMMIT_ID" == "$REMOTE_COMMIT_ID" ]; then
        echo "         Nothing to be done."
    else
        echo "         Update required."
        # Instructions to be added
        # lxc exec SO-ub -- ...
    fi
    echo
}

function so_is_up() {
    if [ -n "$1" ]; then
        SO_IP=$1
    else
        SO_IP=`lxc list SO-ub -c 4|grep eth0 |awk '{print $2}'`
    fi
    time=0
    step=5
    timelength=300
    while [ $time -le $timelength ]
    do
        if [[ `curl -k -X GET   https://$SO_IP:8008/api/operational/vcs/info \
                -H 'accept: application/vnd.yang.data+json' \
                -H 'authorization: Basic YWRtaW46YWRtaW4=' \
                -H 'cache-control: no-cache' 2> /dev/null | jq  '.[].components.component_info[] | select(.component_name=="RW.Restconf")' 2>/dev/null | grep "RUNNING" | wc -l` -eq 1 ]]
        then
            echo "RW.Restconf running....SO is up"
            return 0
        fi

        sleep $step
        echo -n "."
        time=$((time+step))
    done

    FATAL "OSM Failed to startup. SO failed to startup"
}

function vca_is_up() {
    if [[ `lxc exec VCA -- juju status | grep "osm" | wc -l` -eq 1 ]]; then
            echo "VCA is up and running"
            return 0
    fi

    FATAL "OSM Failed to startup. VCA failed to startup"
}

function ro_is_up() {
    if [ -n "$1" ]; then
        RO_IP=$1
    else
        RO_IP=`lxc list RO -c 4|grep eth0 |awk '{print $2}'`
    fi
    time=0
    step=2
    timelength=20
    while [ $time -le $timelength ]; do
        if [[ `curl http://$RO_IP:9090/openmano/ | grep "works" | wc -l` -eq 1 ]]; then
            echo "RO is up and running"
            return 0
        fi
        sleep $step
        echo -n "."
        time=$((time+step))
    done

    FATAL "OSM Failed to startup. RO failed to startup"
}


function configure_RO(){
    . $OSM_DEVOPS/installers/export_ips
    echo -e "       Configuring RO"
    lxc exec RO -- sed -i -e "s/^\#\?log_socket_host:.*/log_socket_host: $SO_CONTAINER_IP/g" /etc/osm/openmanod.cfg
    lxc exec RO -- service osm-ro restart

    ro_is_up

    lxc exec RO -- openmano tenant-delete -f osm >/dev/null
    lxc exec RO -- sed -i '/export OPENMANO_TENANT=osm/d' .bashrc 
    lxc exec RO -- sed -i '$ i export OPENMANO_TENANT=osm' .bashrc
    #lxc exec RO -- sh -c 'echo "export OPENMANO_TENANT=osm" >> .bashrc'
}

function configure_VCA(){
    echo -e "       Configuring VCA"
    JUJU_PASSWD=`date +%s | sha256sum | base64 | head -c 32`
    echo -e "$JUJU_PASSWD\n$JUJU_PASSWD" | lxc exec VCA -- juju change-user-password
}

function configure_SOUI(){
    . $OSM_DEVOPS/installers/export_ips
    #workaround to switch the host IP to container IP on fortistacks containers are accessible directly:
    DEFAULT_IP=$SO_CONTAINER_IP
    JUJU_CONTROLLER_IP=`lxc exec VCA -- lxc list -c 4 |grep eth0 |awk '{print $2}'`
    RO_TENANT_ID=`lxc exec RO -- openmano tenant-create osm |awk '{print $1}'`

    echo -e "       Configuring SO"
    sudo route add -host $JUJU_CONTROLLER_IP gw $VCA_CONTAINER_IP
    sudo sed -i "$ i route add -host $JUJU_CONTROLLER_IP gw $VCA_CONTAINER_IP" /etc/rc.local
    # make journaling persistent
    lxc exec SO-ub -- mkdir -p /var/log/journal
    lxc exec SO-ub -- systemd-tmpfiles --create --prefix /var/log/journal
    lxc exec SO-ub -- systemctl restart systemd-journald

    echo RIFT_EXTERNAL_ADDRESS=$DEFAULT_IP | lxc exec SO-ub -- tee -a /usr/rift/etc/default/launchpad

    lxc exec SO-ub -- systemctl restart launchpad

    so_is_up $SO_CONTAINER_IP

    #delete existing config agent (could be there on reconfigure)
    curl -k --request DELETE \
      --url https://$SO_CONTAINER_IP:8008/api/config/config-agent/account/osmjuju \
      --header 'accept: application/vnd.yang.data+json' \
      --header 'authorization: Basic YWRtaW46YWRtaW4=' \
      --header 'cache-control: no-cache' \
      --header 'content-type: application/vnd.yang.data+json' &> /dev/null

    result=$(curl -k --request POST \
      --url https://$SO_CONTAINER_IP:8008/api/config/config-agent \
      --header 'accept: application/vnd.yang.data+json' \
      --header 'authorization: Basic YWRtaW46YWRtaW4=' \
      --header 'cache-control: no-cache' \
      --header 'content-type: application/vnd.yang.data+json' \
      --data '{"account": [ { "name": "osmjuju", "account-type": "juju", "juju": { "ip-address": "'$JUJU_CONTROLLER_IP'", "port": "17070", "user": "admin", "secret": "'$JUJU_PASSWD'" }  }  ]}')
    [[ $result =~ .*success.* ]] || FATAL "Failed config-agent configuration: $result"

    #R1/R2 config line
    #result=$(curl -k --request PUT \
    #  --url https://$SO_CONTAINER_IP:8008/api/config/resource-orchestrator \
    #  --header 'accept: application/vnd.yang.data+json' \
    #  --header 'authorization: Basic YWRtaW46YWRtaW4=' \
    #  --header 'cache-control: no-cache' \
    #  --header 'content-type: application/vnd.yang.data+json' \
    #  --data '{ "openmano": { "host": "'$RO_CONTAINER_IP'", "port": "9090", "tenant-id": "'$RO_TENANT_ID'" }, "name": "osmopenmano", "account-type": "openmano" }')

    result=$(curl -k --request PUT \
      --url https://$SO_CONTAINER_IP:8008/api/config/project/default/ro-account/account \
      --header 'accept: application/vnd.yang.data+json' \
      --header 'authorization: Basic YWRtaW46YWRtaW4=' \
      --header 'cache-control: no-cache'   \
      --header 'content-type: application/vnd.yang.data+json' \
      --data '{"rw-ro-account:account": [ { "openmano": { "host": "'$RO_CONTAINER_IP'", "port": "9090", "tenant-id": "'$RO_TENANT_ID'"}, "name": "osmopenmano", "ro-account-type": "openmano" }]}')
    [[ $result =~ .*success.* ]] || FATAL "Failed resource-orchestrator configuration: $result"

    result=$(curl -k --request PATCH \
      --url https://$SO_CONTAINER_IP:8008/v2/api/config/openidc-provider-config/rw-ui-client/redirect-uri \
      --header 'accept: application/vnd.yang.data+json' \
      --header 'authorization: Basic YWRtaW46YWRtaW4=' \
      --header 'cache-control: no-cache'   \
      --header 'content-type: application/vnd.yang.data+json' \
      --data '{"redirect-uri": "https://'$DEFAULT_IP':8443/callback" }')
    [[ $result =~ .*success.* ]] || FATAL "Failed redirect-uri configuration: $result"

    result=$(curl -k --request PATCH \
      --url https://$SO_CONTAINER_IP:8008/v2/api/config/openidc-provider-config/rw-ui-client/post-logout-redirect-uri \
      --header 'accept: application/vnd.yang.data+json' \
      --header 'authorization: Basic YWRtaW46YWRtaW4=' \
      --header 'cache-control: no-cache'   \
      --header 'content-type: application/vnd.yang.data+json' \
      --data '{"post-logout-redirect-uri": "https://'$DEFAULT_IP':8443/?api_server=https://'$DEFAULT_IP'" }')
    [[ $result =~ .*success.* ]] || FATAL "Failed post-logout-redirect-uri configuration: $result"

}

#Configure RO, VCA, and SO with the initial configuration:
#  RO -> tenant:osm, logs to be sent to SO
#  VCA -> juju-password
#  SO -> route to Juju Controller, add RO account, add VCA account
function configure(){
    #Configure components
    echo -e "\nConfiguring components"
    configure_RO
    configure_VCA
    configure_SOUI
}

function install_lxd() {
    sudo apt-get update
    sudo apt-get install -y lxd
    newgrp lxd
    lxd init --auto
    lxd waitready
    lxc network create lxdbr0 ipv4.address=auto ipv4.nat=true ipv6.address=none ipv6.nat=false
    DEFAULT_INTERFACE=$(route -n | awk '$1~/^0.0.0.0/ {print $8}')
    DEFAULT_MTU=$( ip addr show $DEFAULT_INTERFACE | perl -ne 'if (/mtu\s(\d+)/) {print $1;}')
    lxc profile device set default eth0 mtu $DEFAULT_MTU
    #sudo systemctl stop lxd-bridge
    #sudo systemctl --system daemon-reload
    #sudo systemctl enable lxd-bridge
    #sudo systemctl start lxd-bridge
}

function ask_user(){
    # ask to the user and parse a response among 'y', 'yes', 'n' or 'no'. Case insensitive
    # Params: $1 text to ask;   $2 Action by default, can be 'y' for yes, 'n' for no, other or empty for not allowed
    # Return: true(0) if user type 'yes'; false (1) if user type 'no'
    read -e -p "$1" USER_CONFIRMATION
    while true ; do
        [ -z "$USER_CONFIRMATION" ] && [ "$2" == 'y' ] && return 0
        [ -z "$USER_CONFIRMATION" ] && [ "$2" == 'n' ] && return 1
        [ "${USER_CONFIRMATION,,}" == "yes" ] || [ "${USER_CONFIRMATION,,}" == "y" ] && return 0
        [ "${USER_CONFIRMATION,,}" == "no" ]  || [ "${USER_CONFIRMATION,,}" == "n" ] && return 1
        read -e -p "Please type 'yes' or 'no': " USER_CONFIRMATION
    done
}

function launch_container_from_lxd(){
    export OSM_MDG=$1
    OSM_load_config
    export OSM_BASE_IMAGE=$2
    if ! container_exists $OSM_BUILD_CONTAINER; then
        CONTAINER_OPTS=""
        [[ "$OSM_BUILD_CONTAINER_PRIVILEGED" == yes ]] && CONTAINER_OPTS="$CONTAINER_OPTS -c security.privileged=true"
        [[ "$OSM_BUILD_CONTAINER_ALLOW_NESTED" == yes ]] && CONTAINER_OPTS="$CONTAINER_OPTS -c security.nesting=true"
        create_container $OSM_BASE_IMAGE $OSM_BUILD_CONTAINER $CONTAINER_OPTS
        wait_container_up $OSM_BUILD_CONTAINER
    fi
}

function install_osmclient(){
    CLIENT_RELEASE=${RELEASE#"-R "}
    CLIENT_REPOSITORY_KEY="OSM%20ETSI%20Release%20Key.gpg"
    CLIENT_REPOSITORY="stable"
    [ -z "$REPOSITORY_BASE" ] && REPOSITORY_BASE="-u https://osm-download.etsi.org/repository/osm/debian"
    CLIENT_REPOSITORY_BASE=${REPOSITORY_BASE#"-u "}
    key_location=$CLIENT_REPOSITORY_BASE/$CLIENT_RELEASE/$CLIENT_REPOSITORY_KEY
    curl $key_location | sudo apt-key add -
    sudo add-apt-repository -y "deb [arch=amd64] $CLIENT_REPOSITORY_BASE/$CLIENT_RELEASE $CLIENT_REPOSITORY osmclient"
    sudo apt-get update
    sudo apt-get install -y python-osmclient
    export OSM_HOSTNAME=`lxc list | awk '($2=="SO-ub"){print $6}'`
    export OSM_RO_HOSTNAME=`lxc list | awk '($2=="RO"){print $6}'`
    echo -e "\nOSM client installed"
    echo -e "You might be interested in adding the following OSM client env variables to your .bashrc file:"
    echo "     export OSM_HOSTNAME=${OSM_HOSTNAME}"
    echo "     export OSM_RO_HOSTNAME=${OSM_RO_HOSTNAME}"
}

function install_from_lxdimages(){
    LXD_RELEASE=${RELEASE#"-R "}
    LXD_IMAGE_DIR="$(mktemp -d -q --tmpdir "osmimages.XXXXXX")"
    trap 'rm -rf "$LXD_IMAGE_DIR"' EXIT
    wget -O $LXD_IMAGE_DIR/osm-ro.tar.gz $LXD_REPOSITORY_BASE/$LXD_RELEASE/osm-ro.tar.gz
    lxc image import $LXD_IMAGE_DIR/osm-ro.tar.gz --alias osm-ro
    rm -f $LXD_IMAGE_DIR/osm-ro.tar.gz
    wget -O $LXD_IMAGE_DIR/osm-vca.tar.gz $LXD_REPOSITORY_BASE/$LXD_RELEASE/osm-vca.tar.gz
    lxc image import $LXD_IMAGE_DIR/osm-vca.tar.gz --alias osm-vca
    rm -f $LXD_IMAGE_DIR/osm-vca.tar.gz
    wget -O $LXD_IMAGE_DIR/osm-soui.tar.gz $LXD_REPOSITORY_BASE/$LXD_RELEASE/osm-soui.tar.gz
    lxc image import $LXD_IMAGE_DIR/osm-soui.tar.gz --alias osm-soui
    rm -f $LXD_IMAGE_DIR/osm-soui.tar.gz
    launch_container_from_lxd RO osm-ro
    ro_is_up && track RO
    launch_container_from_lxd VCA osm-vca
    vca_is_up && track VCA
    launch_container_from_lxd SO osm-soui
    #so_is_up && track SOUI
    track SOUI
}

function dump_vars(){
    echo "DEVELOP=$DEVELOP"
    echo "INSTALL_FROM_SOURCE=$INSTALL_FROM_SOURCE"
    echo "UNINSTALL=$UNINSTALL"
    echo "NAT=$NAT"
    echo "UPDATE=$UPDATE"
    echo "RECONFIGURE=$RECONFIGURE"
    echo "TEST_INSTALLER=$TEST_INSTALLER"
    echo "INSTALL_LXD=$INSTALL_LXD"
    echo "INSTALL_FROM_LXDIMAGES=$INSTALL_FROM_LXDIMAGES"
    echo "LXD_REPOSITORY_BASE=$LXD_REPOSITORY_BASE"
    echo "RELEASE=$RELEASE"
    echo "REPOSITORY=$REPOSITORY"
    echo "REPOSITORY_BASE=$REPOSITORY_BASE"
    echo "REPOSITORY_KEY=$REPOSITORY_KEY"
    echo "NOCONFIGURE=$NOCONFIGURE"
    echo "SHOWOPTS=$SHOWOPTS"
    echo "Install from specific refspec (-b): $COMMIT_ID"
}

function track(){
    ctime=`date +%s`
    duration=$((ctime - SESSION_ID))
    url="http://www.woopra.com/track/ce?project=osm.etsi.org&cookie=${SESSION_ID}"
    #url="${url}&ce_campaign_name=${CAMPAIGN_NAME}"
    event_name="bin"
    [ -n "$INSTALL_FROM_SOURCE" ] && event_name="src"
    [ -n "$INSTALL_FROM_LXDIMAGES" ] && event_name="lxd"
    event_name="${event_name}_$1"
    url="${url}&event=${event_name}&ce_duration=${duration}"
    wget -q -O /dev/null $url
}

UNINSTALL=""
DEVELOP=""
NAT=""
UPDATE=""
RECONFIGURE=""
TEST_INSTALLER=""
INSTALL_LXD=""
SHOWOPTS=""
COMMIT_ID=""
ASSUME_YES=""
INSTALL_FROM_SOURCE=""
RELEASE="-R ReleaseTHREE"
INSTALL_FROM_LXDIMAGES=""
LXD_REPOSITORY_BASE="https://osm-download.etsi.org/repository/osm/lxd"
NOCONFIGURE=""

SESSION_ID=`date +%s`

while getopts ":hy-:b:r:k:u:R:l:" o; do
    case "${o}" in
        h)
            usage && exit 0
            ;;
        b)
            COMMIT_ID=${OPTARG}
            ;;
        r)
            REPOSITORY="-r ${OPTARG}"
            ;;
        R)
            RELEASE="-R ${OPTARG}"
            ;;
        k)
            REPOSITORY_KEY="-k ${OPTARG}"
            ;;
        u)
            REPOSITORY_BASE="-u ${OPTARG}"
            ;;
        l)
            LXD_REPOSITORY_BASE="${OPTARG}"
            ;;
        -)
            [ "${OPTARG}" == "help" ] && usage && exit 0
            [ "${OPTARG}" == "source" ] && INSTALL_FROM_SOURCE="y" && continue
            [ "${OPTARG}" == "develop" ] && DEVELOP="y" && continue
            [ "${OPTARG}" == "uninstall" ] && UNINSTALL="y" && continue
            [ "${OPTARG}" == "nat" ] && NAT="y" && continue
            [ "${OPTARG}" == "update" ] && UPDATE="y" && continue
            [ "${OPTARG}" == "reconfigure" ] && RECONFIGURE="y" && continue
            [ "${OPTARG}" == "test" ] && TEST_INSTALLER="y" && continue
            [ "${OPTARG}" == "lxdinstall" ] && INSTALL_LXD="y" && continue
            [ "${OPTARG}" == "lxdimages" ] && INSTALL_FROM_LXDIMAGES="y" && continue
            [ "${OPTARG}" == "noconfigure" ] && NOCONFIGURE="y" && continue
            [ "${OPTARG}" == "showopts" ] && SHOWOPTS="y" && continue
            echo -e "Invalid option: '--$OPTARG'\n" >&2
            usage && exit 1
            ;;
        \?)
            echo -e "Invalid option: '-$OPTARG'\n" >&2
            usage && exit 1
            ;;
        y)
            ASSUME_YES="y"
            ;;
        *)
            usage && exit 1
            ;;
    esac
done

if [ -n "$SHOWOPTS" ]; then
    dump_vars
    exit 0
fi

# if develop, we force master
[ -z "$COMMIT_ID" ] && [ -n "$DEVELOP" ] && COMMIT_ID="master"

# forcing source from master removed. Now only install from source when explicit
# [ -n "$COMMIT_ID" ] && [ "$COMMIT_ID" == "master" ] && INSTALL_FROM_SOURCE="y"

if [ -n "$TEST_INSTALLER" ]; then
    echo -e "\nUsing local devops repo for OSM installation"
    TEMPDIR="$(dirname $(realpath $(dirname $0)))"
else
    echo -e "\nCreating temporary dir for OSM installation"
    TEMPDIR="$(mktemp -d -q --tmpdir "installosm.XXXXXX")"
    trap 'rm -rf "$TEMPDIR"' EXIT
fi

need_packages="git jq"
for package in $need_packages; do
    echo -e "Checking required packages: $package"
    dpkg -l $package &>/dev/null \
        || ! echo -e "     $package not installed.\nInstalling $package requires root privileges" \
        || sudo apt-get install -y $package \
        || FATAL "failed to install $package"
done

if [ -z "$TEST_INSTALLER" ]; then
    echo -e "\nCloning devops repo temporarily"
    git clone https://osm.etsi.org/gerrit/osm/devops.git $TEMPDIR
    RC_CLONE=$?
fi

echo -e "\nGuessing the current stable release"
LATEST_STABLE_DEVOPS=`git -C $TEMPDIR tag -l v[0-9].* | sort -V | tail -n1`
[ -z "$COMMIT_ID" ] && [ -z "$LATEST_STABLE_DEVOPS" ] && echo "Could not find the current latest stable release" && exit 0
echo "Latest tag in devops repo: $LATEST_STABLE_DEVOPS"
[ -z "$COMMIT_ID" ] && [ -n "$LATEST_STABLE_DEVOPS" ] && COMMIT_ID="tags/$LATEST_STABLE_DEVOPS"
[ -z "$TEST_INSTALLER" ] && git -C $TEMPDIR checkout tags/$LATEST_STABLE_DEVOPS

OSM_DEVOPS=$TEMPDIR
OSM_JENKINS="$TEMPDIR/jenkins"
. $OSM_JENKINS/common/all_funcs

[ -n "$UNINSTALL" ] && uninstall && echo -e "\nDONE" && exit 0
#[ -n "$NAT" ] && nat && echo -e "\nDONE" && exit 0
[ -n "$UPDATE" ] && update && echo -e "\nDONE" && exit 0
[ -n "$RECONFIGURE" ] && configure && echo -e "\nDONE" && exit 0

#Installation starts here
echo -e "\nInstalling OSM from refspec: $COMMIT_ID"
if [ -n "$INSTALL_FROM_SOURCE" ] && [ -z "$ASSUME_YES" ]; then 
    ! ask_user "The installation will take about 75-90 minutes. Continue (Y/n)? " y && echo "Cancelled!" && exit 1
fi

echo -e "\nChecking required packages: wget, curl, tar"
dpkg -l wget curl tar &>/dev/null || ! echo -e "    One or several packages are not installed.\nInstalling required packages\n     Root privileges are required" || sudo apt-get install -y wget curl tar

echo -e "Checking required packages: lxd"
lxd --version &>/dev/null || FATAL "lxd not present, exiting."
[ -n "$INSTALL_LXD" ] && echo -e "\nInstalling and configuring lxd" && install_lxd

wget -q -O- https://osm-download.etsi.org/ftp/osm-3.0-three/README.txt &> /dev/null
track start

# use local devops for containers
export OSM_USE_LOCAL_DEVOPS=true
if [ -n "$INSTALL_FROM_SOURCE" ]; then #install from source
    echo -e "\nCreating the containers and building from source ..."
    $OSM_DEVOPS/jenkins/host/start_build RO --notest checkout $COMMIT_ID || FATAL "RO container build failed (refspec: '$COMMIT_ID')"
    ro_is_up && track RO
    $OSM_DEVOPS/jenkins/host/start_build VCA || FATAL "VCA container build failed"
    vca_is_up && track VCA
    $OSM_DEVOPS/jenkins/host/start_build SO checkout $COMMIT_ID || FATAL "SO container build failed (refspec: '$COMMIT_ID')"
    $OSM_DEVOPS/jenkins/host/start_build UI checkout $COMMIT_ID || FATAL "UI container build failed (refspec: '$COMMIT_ID')"
    #so_is_up && track SOUI
    track SOUI
elif [ -n "$INSTALL_FROM_LXDIMAGES" ]; then #install from LXD images stored in OSM repo
    echo -e "\nInstalling from lxd images ..."
    install_from_lxdimages
else #install from binaries
    echo -e "\nCreating the containers and installing from binaries ..."
    $OSM_DEVOPS/jenkins/host/install RO $REPOSITORY $RELEASE $REPOSITORY_KEY $REPOSITORY_BASE || FATAL "RO install failed"
    ro_is_up && track RO
    $OSM_DEVOPS/jenkins/host/start_build VCA || FATAL "VCA install failed"
    vca_is_up && track VCA
    $OSM_DEVOPS/jenkins/host/install SO $REPOSITORY $RELEASE $REPOSITORY_KEY $REPOSITORY_BASE || FATAL "SO install failed"
    $OSM_DEVOPS/jenkins/host/install UI $REPOSITORY $RELEASE $REPOSITORY_KEY $REPOSITORY_BASE || FATAL "UI install failed"
    #so_is_up && track SOUI
    track SOUI
fi

#don't Install iptables-persistent and configure NAT rules
#[ -z "$NOCONFIGURE" ] && nat

#Configure components
[ -z "$NOCONFIGURE" ] && configure

#Install osmclient
[ -z "$NOCONFIGURE" ] && install_osmclient

wget -q -O- https://osm-download.etsi.org/ftp/osm-3.0-three/README2.txt &> /dev/null
track end
echo -e "\nDONE"

