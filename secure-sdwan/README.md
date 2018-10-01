# Automate Secured SDWAN demo

The goal is to deliver a automated deployment of:
 - a media server
 - 2 network simulating
    * bad WAN 
    * guaranteed network like MPLS.
 - 2 simulated branches with Fortigate SDWAN firewalls.
 
 ## Scenario
 
 Entreprise A want to organize a live broadcasted townhall. The IT must rapidely deploy a media server and ensure proper bandwidth and latency to ensure smooth upload and broadcasts.
 Presented that way SDWAN rules must be changed on the time of the broadcast for video delivery and resumed to business critical apps at the end of it.
 
 
 ##Quick start
 
 You must have a Cloudify manager installed and configured.
 
 The easiest is to run : cloudify/manager-on-openstackvm on a configured openstack (mgmt netwrok with floating ips)

 Then upload fortigate images and be sure to point to Ubuntu 16.04 images (input-citycloud.yaml as example)
 
  Then 
  ```bash
 $ cd cloudify-ftnt-sdwan
 $ cfy install -b dcplus dc-plus-wans.yaml -i inputs-citycloud.yaml
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

 ## Steaming
 
 Using OBS and do those settings
 https://github.com/ant-media/Ant-Media-Server/wiki/Reduce-Latency-in-RTMP-to-HLS-Streaming
 
 To watch the stream:
 http://<SERVER_NAME>/LiveApp/streams/<STREAM_ID>.m3u8 HLS
 
 See this https://github.com/ant-media/Ant-Media-Server/wiki/Play-Live-and-VoD-Streams for details
 
 In community edition, MP4 URL will be available in this URL http://<SERVER_NAME>:5080/LiveApp/streams/<STREAM_ID>.mp4

Embeded player is available here:
http://<SERVER_NAME>:5080/LiveApp/play.html?name=<STREAM_ID> 

For demos might want to broadcast a file with vlc:
 cvlc  -vvv FILE016.MP4 --sout '#transcode{vcodec=h264,scale=Auto,width=1280,height=720,acodec=mp3,ab=128,channels=2,samplerate=44100}:std{access=rtmp,mux=ffmpeg{mux=flv},dst=rtmp://a.rtmp.youtube.com/live2/stream-name}'
src: https://stackoverflow.com/questions/40428837/broadcasting-to-youtube-live-via-rtmp-using-vlc-from-terminal
 
 As the VOD usually buffer the file hence the network lag are not visibles
 Broadasting and viewing from same pc overflow the bandwidth
 
 SDWAN videos on youtube : 
 https://www.youtube.com/watch?v=CgkbewuLEys  https://www.youtube.com/watch?v=jaNZiFFg-38  https://www.youtube.com/watch?v=SYyCJS-hE5I