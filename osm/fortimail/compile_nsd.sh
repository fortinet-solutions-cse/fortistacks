#!/bin/bash

if ! [ -d "devops" ]; then
  echo "Devops dir not present, cloning...."
  git clone https://osm.etsi.org/gerrit/osm/devops
fi

./devops/descriptor-packages/tools/generate_descriptor_pkg.sh -t nsd -N fortimail_nsd
