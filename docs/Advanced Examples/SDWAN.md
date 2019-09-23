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
 
  Then 
 ```bash
 $ cd cloudify-ftnt-sdwan
 $ cfy install -b dcplus dc-plus-wans.yaml -i inputs-citycloud.yaml
 $  openstack router set dc-router --route destination=10.20.20.0/24,gateway=10.40.40.254
 $ cfy install -b antmedia antmedia.yaml -i inputs-citycloud.yaml 
``` 

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

 ## Streaming
 
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

# show the bandwidth usage on Ubuntu:

speedometer -r ens4 -t ens4 -s