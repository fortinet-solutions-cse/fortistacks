# Automate Secured SDWAN demo

The goal is to deliver a automated deployment of:

 - 2 network simulating
    * bad WAN 
    * guaranteed network like MPLS.
 - 1 simulated branches with Fortigate SDWAN firewalls.
 - a media server

## Scenario
 
 Entreprise A want to organize a live broadcasted townhall. The IT must rapidely deploy a media server and ensure proper bandwidth and latency to ensure smooth upload and broadcasts.
 Presented that way SDWAN rules must be changed on the time of the broadcast for video delivery and resumed to business critical apps at the end of it.
 
 
## Deploy the scenario
### pre requisite

* You must have a Cloudify manager installed and configured. The easiest is to run : cloudify/manager-on-openstackvm on a configured openstack.
* You must have a fortimanager with API access enabled, accessible from Cloudify manager.
* Ensure you have fortigate images uploaded 
* Ubuntu 16.04 images (see input-citycloud.yaml as example)
 
### Follow me instructions
Add your fortigate license to cloudify :
```shell
cfy secret create fgt_license -f ../../fortigate/FGT.lic 
```
Add Fortimanager password to cloudify :
```shell
 cfy secret create fmg_password -s XXXX 
```

Then run the following 

 ```bash
cfy blueprint upload -b acme acme-enterprise.yaml
cfy deployment create --skip-plugins-validation acme -b acme -i inputs-citycloud.yaml
cfy -v executions start -d acme install
``` 
This is the content of ``` ./deploy.sh```
Be patient it installed several VMs to create a WAN simulation and ubuntu desktop for client simulation.
 
Once this is done you will have a simulated branch with a client Ubuntu desktop.

Pay attention to the SDWAN setup on FMG or Fortigate, you can manually add floating-ips if necessary for you or access directly.

## VLC access from MAC

On a x11 started session:

```
    gsettings set  org.gnome.Vino enabled true
      #   for broken clients like rdp/Macos
     gsettings set  org.gnome.Vino  require-encryption false
     gsettings set  org.gnome.Vino vnc-password Zm9ydGluZXQ=
     gsettings set org.gnome.Vino use-upnp true
     gsettings set org.gnome.Vino notify-on-connect false
     gsettings set org.gnome.Vino prompt-enabled false
     gsettings set org.gnome.Vino authentication-methods  "['vnc']"
```

 ## Streaming server
 
 Install Antmedia using:
 ````shell script
 cfy install -b antmedia antmedia.yaml -i inputs-citycloud.yaml 
````
As usual adapt the input file.

## Streaming source

 Using OBS and do those settings
 https://github.com/ant-media/Ant-Media-Server/wiki/Reduce-Latency-in-RTMP-to-HLS-Streaming
 
 To watch the stream:
 http://<SERVER_NAME>/LiveApp/streams/<STREAM_ID>.m3u8 HLS
 
 See this https://github.com/ant-media/Ant-Media-Server/wiki/Play-Live-and-VoD-Streams for details
 
 In community edition, MP4 URL will be available in this URL http://<SERVER_NAME>:5080/LiveApp/streams/<STREAM_ID>.mp4

Embeded player is available here:
http://<SERVER_NAME>:5080/LiveApp/play.html?name=<STREAM_ID> 

OBS/antmedia allow to broadcast on a non predefine stream and name it.

In OBS setting streams server :
  rtmp://<SERVER_NAME>/LiveApp/   stream: townhall

Will broadcast even if not predefined.

Frotinet SDWAN videos on youtube (broadcast sources):
 https://www.youtube.com/watch?v=CgkbewuLEys  https://www.youtube.com/watch?v=jaNZiFFg-38  https://www.youtube.com/watch?v=SYyCJS-hE5I

# to see the bandwidth usage on Ubuntu:

```shell script
speedometer -r ens4 -t ens4 -s
```