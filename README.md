# DNCS-LAB

This repository contains the Vagrant files required to run the virtual lab environment used in the DNCS course.
```


        +-----------------------------------------------------+
        |                                                     |
        |                                                     |eth0
        +--+--+                +------------+             +------------+
        |     |                |            |             |            |
        |     |            eth0|            |eth2     eth2|            |
        |     +----------------+  router-1  +-------------+  router-2  |
        |     |                |            |             |            |
        |     |                |            |             |            |
        |  M  |                +------------+             +------------+
        |  A  |                      |eth1                       |eth1
        |  N  |                      |                           |
        |  A  |                      |                           |
        |  G  |                      |                     +-----+----+
        |  E  |                      |eth1                 |          |
        |  M  |            +-------------------+           |          |
        |  E  |        eth0|                   |           |  host-c  |
        |  N  +------------+      SWITCH       |           |          |
        |  T  |            |                   |           |          |
        |     |            +-------------------+           +----------+
        |  V  |               |eth2         |eth3                |eth0
        |  A  |               |             |                    |
        |  G  |               |             |                    |
        |  R  |               |eth1         |eth1                |
        |  A  |        +----------+     +----------+             |
        |  N  |        |          |     |          |             |
        |  T  |    eth0|          |     |          |             |
        |     +--------+  host-a  |     |  host-b  |             |
        |     |        |          |     |          |             |
        |     |        |          |     |          |             |
        ++-+--+        +----------+     +----------+             |
        | |                              |eth0                   |
        | |                              |                       |
        | +------------------------------+                       |
        |                                                        |
        |                                                        |
        +--------------------------------------------------------+



```

# Requirements
 - Python 3
 - 10GB disk storage
 - 2GB free RAM
 - Virtualbox
 - Vagrant (https://www.vagrantup.com)
 - Internet

# How-to
 - Install Virtualbox and Vagrant
 - Clone this repository
`git clone https://github.com/dustnic/dncs-lab`
 - You should be able to launch the lab from within the cloned repo folder.
```
cd dncs-lab
[~/dncs-lab] vagrant up
```
Once you launch the vagrant script, it may take a while for the entire topology to become available.
 - Verify the status of the 4 VMs
 ```
 [dncs-lab]$ vagrant status                                                                                                                                                                
Current machine states:

router                    running (virtualbox)
switch                    running (virtualbox)
host-a                    running (virtualbox)
host-b                    running (virtualbox)
```
- Once all the VMs are running verify you can log into all of them:
`vagrant ssh router`
`vagrant ssh switch`
`vagrant ssh host-a`
`vagrant ssh host-b`
`vagrant ssh host-c`

# Assignment
This section describes the assignment, its requirements and the tasks the student has to complete.
The assignment consists in a simple piece of design work that students have to carry out to satisfy the requirements described below.
The assignment deliverable consists of a Github repository containing:
- the code necessary for the infrastructure to be replicated and instantiated
- an updated README.md file where design decisions and experimental results are illustrated
- an updated answers.yml file containing the details of 

## Design Requirements
- Hosts 1-a and 1-b are in two subnets (*Hosts-A* and *Hosts-B*) that must be able to scale up to respectively 145 and 401 usable addresses
- Host 2-c is in a subnet (*Hub*) that needs to accommodate up to 79 usable addresses
- Host 2-c must run a docker image (dustnic82/nginx-test) which implements a web-server that must be reachable from Host-1-a and Host-1-b
- No dynamic routing can be used
- Routes must be as generic as possible
- The lab setup must be portable and executed just by launching the `vagrant up` command

## Tasks
- Fork the Github repository: https://github.com/dustnic/dncs-lab
- Clone the repository
- Run the initiator script (dncs-init). The script generates a custom `answers.yml` file and updates the Readme.md file with specific details automatically generated by the script itself.
  This can be done just once in case the work is being carried out by a group of (<=2) engineers, using the name of the 'squad lead'. 
- Implement the design by integrating the necessary commands into the VM startup scripts (create more if necessary)
- Modify the Vagrantfile (if necessary)
- Document the design by expanding this readme file
- Fill the `answers.yml` file where required (make sure that is committed and pushed to your repository)
- Commit the changes and push to your own repository
- Notify the examiner that work is complete specifying the Github repository, First Name, Last Name and Matriculation number. This needs to happen at least 7 days prior an exam registration date.

# Notes and References
- https://rogerdudler.github.io/git-guide/
- http://therandomsecurityguy.com/openvswitch-cheat-sheet/
- https://www.cyberciti.biz/faq/howto-linux-configuring-default-route-with-ipcommand/
- https://www.vagrantup.com/intro/getting-started/


# Design
## Table of Contents
1. [Technical Configuration](#Technical Configuration)
        - [Subnets](#Subnets)
        - [VLAN](#VLAN)
        - [Interfaces Mapping](#Interfaces Mapping)
        - [Network Map](#Network Map)
2. [Implementation](#Implementation)
3. [Assignement Execution and Results](#Assignement Execution and Results)
4. [Examples of Bad Configuration](#Examples of Bad Configuration)


### Technical Configuration

My implementation of this assignment is composed by four subnets:
        -S1 hosts Host-a, the net address is 190.0.0.0/24, so the netmask is 255.255.255.0 because it has to contain 145 hosts, so 8 bits are needed (2^8=256).
        For this subnet two IP addresses are assigned: 190.0.0.25 for Host-a and 190.0.0.24 for Router-1, which is the default gateway for S1.
        S1 has also a VLAN implmented, as required from the assignment, whose tag is 10.
        -S2 hosts Host-b, the net address is 190.0.2.0/23, so the netmask is 255.255.254.0 bacause it has to contain 401 hosts, so 9 bits are needed (2^9=512).
        As S1, also S2 has two IP addresses assigned, 190.0.2.22 for Host-b and 190.0.2.21 for Router-1, which is the default gateway for S2, the same as S1.
        That is why I needed to implement a system of VLANs, since Host-a and Host-b have to stay on different nets. The tag for Host-b VLAN is 8.
        -S3 hosts Host-c, the net address is 191.0.0.0/25, so the netmask is 255.255.255.127 since the number of hosts to contain is 79, 7 bits are needed (2^7=128).
        Two are the IP addresses assigned, 191.0.0.10 fo Host-c and 191.0.0.11 for Router-1, the gateway of the net. Since on Router-2 just one net is attached, there is no need to implement VLANs here.
        -S4 is the last subnets and it has been created just to link Router-1 and Router-2. Two bits are necessary, because there are only two "users" in the net (the routers), so just two IP address for them, then one for the net and one for the broadcast service. So the net address is 193.0.0.0/30 and the netmask is 255.255.255.252. Router-1 has the address 193.0.0.1 and Router-2 has 193.0.0.2.

I modified the Vagrant file, every virtual machine now has its own script based on what kind of device is running. So it recalls 6 bash files with the commands for every router, switch or host present in the network. In every script there are commands for pure Linux software part to update their machines and also the creation of interfaces and their power on. Exept for the Switch one, the interfaces have also an IP address to get them reachable through the network.
Here I paste an example of it from Host-b script:
        sudo ip addr add 190.0.2.22/23 dev enp0s8
        sudo ip link set enp0s8 up

In particular, the hosts' scripts contain just those commands and one more (execpt for the host-c one, but I will talk about it later): the command that sets the default gateway. That is done to force hosts to send packets directly to the router of their competence (or through the switch), instead of going through the management interface, that uses the system IP address. An example is in Host-a script:
        sudo ip route add default via 190.0.0.24 

For what concerns Host-c, the only difference is that this one has to contain a Docker container that runs a ngnix web server on it, as told by the assignment. To manage this, more commands are necessary to install the proper tools and software and then the one to run the service:
        sudo docker run --name Liz -p 80:80 -d dustnic82/nginx-test

Talking about routers, two more commands are necessary: the first one is put to make the device as a real router allowing to route packets:
        sudo sysctl net.ipv4.ip_forward=1
The second is done to put a static route between the two routers, so that they know where to forward incoming packets:
        sudo ip route add 191.0.0.0/25 via 193.0.0.2 dev enp0s9 (for Router-1 to reach S3)
        sudo ip route add 190.0.0.0/22 via 193.0.0.1 dev enp0s9 (for Router-2 to reach S1 and S2)

Note that the command in Router-2 script is just one because I put a bigger net's destination which includes S1 and S2 since 190.0.0.0/22 goes from 190.0.0.0 to 190.0.2.255.

In the end the Switch. It is a level 2 device, so it does not need IP address. However it needs first of all to be set as a switch:
        sudo ovs-vsctl add-br switch
And then the two interfaces towards Host-a and Host-b must be developed as VLAN interfaces and the one towards Router-1 has to be put as a trunk one, so that it can allow the passage of packets incoming and outcoming:
        ovs-vsctl set port enp0s9 tag=10
        ovs-vsctl set port enp0s10 tag=8
        ovs-vsctl set port enp0s8 trunks=8,10


Here I report experimental reports.

PINGS:
Host-a -> Host-b
        vagrant@host-a:~$ ping 190.0.2.22
        PING 190.0.2.22 (190.0.2.22) 56(84) bytes of data.
        64 bytes from 190.0.2.22: icmp_seq=1 ttl=63 time=2.22 ms

Host-a -> Router-1 (internal interface S1)
        vagrant@host-a:~$ ping 190.0.0.24
        PING 190.0.0.24 (190.0.0.24) 56(84) bytes of data.
        64 bytes from 190.0.0.24: icmp_seq=1 ttl=64 time=0.720 ms

Host-a -> Router-1 (internal interface S2)
        vagrant@host-a:~$ ping 190.0.2.21
        PING 190.0.2.21 (190.0.2.21) 56(84) bytes of data.
        64 bytes from 190.0.2.21: icmp_seq=1 ttl=64 time=0.926 ms

Host-a -> Router-1 (external interface)
        vagrant@host-a:~$ ping 193.0.0.1
        PING 193.0.0.1 (193.0.0.1) 56(84) bytes of data.
        64 bytes from 193.0.0.1: icmp_seq=1 ttl=64 time=0.954 ms

Host-a -> Router-2 (external interface)
        vagrant@host-a:~$ ping 193.0.0.2
        PING 193.0.0.2 (193.0.0.2) 56(84) bytes of data.
        64 bytes from 193.0.0.2: icmp_seq=1 ttl=63 time=1.38 ms

Host-a -> Router-2 (internal interface)
        vagrant@host-a:~$ ping 191.0.0.11
        PING 191.0.0.11 (191.0.0.11) 56(84) bytes of data.
        64 bytes from 191.0.0.11: icmp_seq=1 ttl=63 time=1.10 ms

Host-a -> Host-c 
        vagrant@host-a:~$ ping 191.0.0.10
        PING 191.0.0.10 (191.0.0.10) 56(84) bytes of data.
        64 bytes from 191.0.0.10: icmp_seq=1 ttl=62 time=1.85 ms

Host-b -> Host-a
        vagrant@host-b:~$ ping 190.0.0.25
        PING 190.0.0.25 (190.0.0.25) 56(84) bytes of data.
        64 bytes from 190.0.0.25: icmp_seq=1 ttl=63 time=1.63 ms

Host-c -> Router-2 (internal interface)
        vagrant@host-c:~$ ping 191.0.0.11
        PING 191.0.0.11 (191.0.0.11) 56(84) bytes of data.
        64 bytes from 191.0.0.11: icmp_seq=1 ttl=64 time=0.387 ms

Host-c -> Router-2 (external interface)
        vagrant@host-c:~$ ping 193.0.0.2
        PING 193.0.0.2 (193.0.0.2) 56(84) bytes of data.
        64 bytes from 193.0.0.2: icmp_seq=1 ttl=64 time=0.373 ms

Host-c -> Router-1 (external interface)
        vagrant@host-c:~$ ping 193.0.0.1
        PING 193.0.0.1 (193.0.0.1) 56(84) bytes of data.
        64 bytes from 193.0.0.1: icmp_seq=1 ttl=63 time=0.723 ms

Host-c -> Router-1 (internal interface S1)
        vagrant@host-c:~$ ping 190.0.0.24
        PING 190.0.0.24 (190.0.0.24) 56(84) bytes of data.
        64 bytes from 190.0.0.24: icmp_seq=1 ttl=63 time=0.724 ms

Host-c -> Router-1 (internal interface S2)
        vagrant@host-c:~$ ping 190.0.2.21
        PING 190.0.2.21 (190.0.2.21) 56(84) bytes of data.
        64 bytes from 190.0.2.21: icmp_seq=1 ttl=63 time=0.805 ms

Host-c -> Host-a
        vagrant@host-c:~$ ping 190.0.0.25
        PING 190.0.0.25 (190.0.0.25) 56(84) bytes of data.
        64 bytes from 190.0.0.25: icmp_seq=1 ttl=62 time=1.53 ms

Host-c -> Host-b
        vagrant@host-c:~$ ping 190.0.2.22
        PING 190.0.2.22 (190.0.2.22) 56(84) bytes of data.
        64 bytes from 190.0.2.22: icmp_seq=1 ttl=62 time=1.43 ms

Router-1 -> Router-2 (external interface)
        vagrant@router-1:~$ ping 193.0.0.2
        PING 193.0.0.2 (193.0.0.2) 56(84) bytes of data.
        64 bytes from 193.0.0.2: icmp_seq=1 ttl=64 time=0.240 ms

Router-1 -> Router-2 (internal interface)
        vagrant@router-1:~$ ping 191.0.0.11
        PING 191.0.0.11 (191.0.0.11) 56(84) bytes of data.
        64 bytes from 191.0.0.11: icmp_seq=1 ttl=64 time=0.419 ms

Router-2 -> Router-1 (external interface)
        vagrant@router-2:~$ ping 193.0.0.1
        PING 193.0.0.1 (193.0.0.1) 56(84) bytes of data.
        64 bytes from 193.0.0.1: icmp_seq=1 ttl=64 time=0.348 ms

Router-2 -> Router-1 (internal interface S1)
        vagrant@router-2:~$ ping 190.0.0.24
        PING 190.0.0.24 (190.0.0.24) 56(84) bytes of data.
        64 bytes from 190.0.0.24: icmp_seq=1 ttl=64 time=0.445 ms

Router-2 -> Router-1 (internal interface S2)
        vagrant@router-2:~$ ping 190.0.2.21
        PING 190.0.2.21 (190.0.2.21) 56(84) bytes of data.
        64 bytes from 190.0.2.21: icmp_seq=1 ttl=64 time=0.251 ms

I do not put all others pings because the route used are the same shown above

DOCKER:
Host-a -> Host-c
        vagrant@host-a:~$ curl 191.0.0.10:80
        <!DOCTYPE html>
        <html>
        <head>
        <title>Welcome to nginx!</title>
        <style>
        body {
                width: 35em;
                margin: 0 auto;
                font-family: Tahoma, Verdana, Arial, sans-serif;
        }
        </style>
        </head>
        <body>
        <h1>Welcome to nginx!</h1>
        <p>If you see this page, the nginx web server is successfully installed and
        working. Further configuration is required.</p>

        <p>For online documentation and support please refer to
        <a href="http://nginx.org/">nginx.org</a>.<br/>
        Commercial support is available at
        <a href="http://nginx.com/">nginx.com</a>.</p>

        <p><em>Thank you for using nginx.</em></p>
        </body>
        </html>

Host-b -> Host-c
        vagrant@host-b:~$ curl 191.0.0.10:80
        <!DOCTYPE html>
        <html>
        <head>
        <title>Welcome to nginx!</title>
        <style>
        body {
                width: 35em;
                margin: 0 auto;
                font-family: Tahoma, Verdana, Arial, sans-serif;
        }
        </style>
        </head>
        <body>
        <h1>Welcome to nginx!</h1>
        <p>If you see this page, the nginx web server is successfully installed and
        working. Further configuration is required.</p>

        <p>For online documentation and support please refer to
        <a href="http://nginx.org/">nginx.org</a>.<br/>
        Commercial support is available at
        <a href="http://nginx.com/">nginx.com</a>.</p>

        <p><em>Thank you for using nginx.</em></p>
        </body>
        </html>


