# Mini Proof of Concept

Prerequisite: run ```./configure-openstack``` script prior to deploy mini-poc with different methods.
##Definition
Mini-poc consist of deploying:

* 2 Ubuntu VMs with iperf, Apache, etc.. to be able to generate traffic.
* 2 networks left and right.
* 1 fortigate or fortios 

All have floating ips on the predefined mgmt network for easy access.

##Illustration


        ===========================================================
            |                     |    Management/floating ips   |
            |                     |                              |
       .----v-----.               |                              |
       | trafleft |               |                              |
       |  Ubuntu  |               |                              |
       '----------'               |                              |
             |                    |                              |
             v                    |                              |
        .-,(  ),-.          .-----v-----.        .-,(  ),-.      |
     .-(          )-.       | Fortigate |     .-(          )-.   |
    (      left      )----->|     vm    |--->(      right      ) |
     '-(          ).-'      '-----------'     '-(          ).-'  |
         '-.( ).-'                                '-.( ).-'      |
                                                      <-------.  |
                                                              |  v
                                                        .-----------.
                                                        | trafright |
                                                        |   Ubuntu  |
                                                        '-----------'


The goal is to offer an easy access to all parts and being able to experiment with Fortinet products on Openstack.
There is little explanations are all the code is available. We may put explanations in comments though.

This same result is then achieved with different tools: script, heat template, cloudify blueprint, osm VNFd.

You must understand Fortigate deployment after this, please go to [Fortigate](Fortigate.md)