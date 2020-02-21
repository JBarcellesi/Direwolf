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
1. [Technical Configuration](#Technical-Configuration)    
    * [Subnets](#Subnets)
    * [VLAN](#VLAN)
    * [Network Map](#Network-Map)
2. [Implementation](#Implementation)
    * [Vagrantfile](#Vagrantfile)
    * [router-1](#router-1)
    * [router-2](#router-2)
    * [switch](#switch)
    * [host-a](#host-a)
    * [host-b](#host-b)
    * [host-c](#host-c)
        
3. [Assignement Execution](#Assignement-Execution)
    * [Traditional host](#Traditional-host)
    * [Switch with VLAN](Switch-with-VLAN)
    * [Router with VLAN](Router-with-VLAN)
    * [Docker Container](Docker-Container)
4. [Results](#Results)


### Technical Configuration
#### Subnets
To implement the assignement, four subents are needed, one for each host linked to its router of reference and one to link routers together:

**1**) S1 is the subnet for host-a between it and router-1. This subnet has to contain at least 145 hosts, so it needs 8 bits for hosts IP addresses (2<sup>8</sup>=256). This means that 24 bits remain for network IP address, so the netmask of the subnet is 255.255.255.0 and the IP network address chosen is 190.0.0.0/24.

**2**) S2 is the subnet that contains host-b and it is associated to router-1. The requirement says that the subnet of host-b has to contain at least 401 hosts, hence 9 bits are needed for hosts IP addresses (2<sup>9</sup>=512). For this reason, the netmask of the subnet is composed by 23 bits and it is 255.255.254.0 with a subnet IP address that is 190.0.2.0/23.

**3**) S3 is the subnet where host-c stays, provided by router-2. It has to contain just 79 hosts as the assignement requires, so it needs 7 bits for hosts IP addresses (2<sup>7</sup>=128) generating a netmask that is 255.255.255.128 since 25 bits remain for subnet IP adress that is 191.0.0.0/25.

**4**) S4 is the last subnet in the project but is the most important, because it links ruoter-1 and router-2 and, without it, is not possible to send packets from host-a or host-b to host-c and viceversa. Since the subnet has just to provide a connection between routers, 2 bits are enough for hosts IP addresses (2 hosts that are routers, one address for broadcast service and one for the network). The netmask is 255.255.255.252 and the subnet IP adress is 193.0.0.0/30.

| Subnet | Address      | Netmask         | Required size (hosts) | Maximum size (hosts) |
| ------ | ------------ | --------------- | --------------------- | -------------------- |
| S1     | 190.0.0.0/24 | 255.255.255.0   |  145                  |  256                 |
| S2     | 190.0.2.0/23 | 255.255.254.0   |  401                  |  512                 |
| S3     | 191.0.0.0/25 | 255.255.255.128 |  79                   |  128                 |
| S4     | 193.0.0.0/30 | 255.255.255.252 |   2                   |   2                  |

#### VLAN
As required in the assignement, the traffic from and to host-a has to be indipendent of traffic from and to host-b. To allow this operation, VLANs are needed, one for S1 and one for S2. For S1-VLAN the identification tag is 10 and for S2-VLAN is 8. To implement the VLANs, it is necessary "to split" the interface from router-1 towards the switch that provides virtual networks, adding the indentification VLAN tag at the router interface.

| Subnet | VLAN ID | Router Interface |
| ------ | ------- | ---------------- |
|   S1   |    10   |    enp0s8.10     |
|   S2   |    8    |    enp0s8.8      |

#### Network Map
```


        +------------------------------------------------------------------+
        |                                                                  |
        |                                                                  |enp0s3
        +--+--+                +------------+                       +------------+
        |     |                |            |                       |            |
        |     |          enp0s3|            |enp0s9           enp0s9|            |
        |     +----------------+  router-1  +-----------------------+  router-2  |
        |     |                |            |193.0.0.1     193.0.0.2|            |
        |     |                |            |                       |            |
        |  M  |                +------------+                       +------------+
        |  A  |             enp0s8.10||enp0s8.8                      enp0s8|191.0.0.11
        |  N  |            190.0.0.24||190.0.2.21                          |
        |  A  |                      ||                              enp0s8|191.0.0.10
        |  G  |                      ||                              +-----+----+
        |  E  |                      ||enp0s8                        |          |
        |  M  |            +-------------------+                     |          |
        |  E  |      enp0s3|                   |                     |  host-c  |
        |  N  +------------+      SWITCH       |                     |          |
        |  T  |            |                   |                     |          |
        |     |            +-------------------+                     +----------+
        |  V  |         enp0s9|             |enp0s10                       |enp0s3
        |  A  |               |             |                              |
        |  G  |               |             |                              |
        |  R  |     190.0.0.25|enp0s8 enp0s8|190.0.2.22                    |
        |  A  |        +----------+     +----------+                       |
        |  N  |        |          |     |          |                       |
        |  T  |  enp0s3|          |     |          |                       |
        |     +--------+  host-a  |     |  host-b  |                       |
        |     |        |          |     |          |                       |
        |     |        |          |     |          |                       |
        ++-+--+        +----------+     +----------+                       |
        | |                              |enp0s3                           |
        | |                              |                                 |
        | +------------------------------+                                 |
        |                                                                  |
        |                                                                  |
        +------------------------------------------------------------------+



```

| Subnet | VLAN   | Device   | Interface | IP address    |
|------- | ------ | -------- | --------- | ------------- |
| S1     | 10     | host-a   | enp0s8    | 190.0.0.25/24 |
| S1     | 10     | router-1 | enp0s8.10 | 190.0.0.24/24 |
| S2     | 8      | host-b   | enp0s8    | 190.0.2.22/23 |
| S2     | 8      | router-2 | enp0s8.8  | 190.0.2.21/23 |
| S3     | -      | host-c   | enp0s8    | 191.0.0.10/25 |
| S3     | -      | router-2 | enp0s8    | 191.0.0.11/25 |
| S4     | -      | router-1 | enp0s9    | 193.0.0.1/30  |
| S4     | -      | router-2 | enp0s9    | 193.0.0.2/30  |
| -      | 10 - 8 | switch   | enp0s8    | -             |
| -      | 10     | switch   | enp0s9    | -             |
| -      | 8      | switch   | enp0s10   | -             | 

_Note_: IP addresses, VLANs tags and subnets addresses are not chosen with a kind of logic, they are just important numbers for the author


### Implementation
In order to make the project work, an ad-hoc script has to be written for each device in the network, since they have to be configured in the proper way and one by one because some features cannot be the same between different devices, as IP addresses, default gateways and VLAN tags. For this reason, the Vagrantfile has to be modified to guarantee that every device's script is executed.

It is necessary for every device to turn on interfaces in order to allow traffic to pass, to give IP addresses for every interface (execpt for the switch that works at level 2 in the ISO/OSI stack, so it does not have an IP address since it is only for level 3 of ISO/OSI stack devices). In addiction, those VMs that act as routers need a command to allow them to route packet becoming worthy of being named "router". Then every host needs a command to ensure them a default gateway and every gateway needs a command that builds a static route (since dynamic routing is not allowed in the project) to reach those subnets that are linked to the other gateway present in the network. To reduce the number of commands required, only one instruction has been written in router-2 merging together network IP addresses of S1 and S2.

Special commands are required for host-c because it has to run a nginx web server. This is one of the two differences between host-c and the others hosts. The other is that host-a and host-b are connected to the same router (router-1), but they interface with a switch that keeps them on two different VLANs. Hence, router-1 has to have the interface towards the swtich splitted, one part with the tag of host-a VLAN and IP compatible with the host-a subnet,and one part with same things but related to host-b. In script of router-1 and switch, commands to do these operations have a comment to highlight them. 

#### Vagrantfile
Throrugh the Vagrantfile, the network is build instantiating devices as virtual machines. Here is an example of how this file creates VM setting a name (router-2), the interfaces on that device, the script from which the device takes its features when the network is up (router-2.sh) and the RAM allocated for the machine (256MB).

```
config.vm.define "router-2" do |router2|
    router2.vm.box = "ubuntu/bionic64"
    router2.vm.hostname = "router-2"
    router2.vm.network "private_network", virtualbox__intnet: "broadcast_router-south-2", auto_config: false
    router2.vm.network "private_network", virtualbox__intnet: "broadcast_router-inter", auto_config: false
    router2.vm.provision "shell", path: "router-2.sh"
    router2.vm.provider "virtualbox" do |vb|
      vb.memory = 256
    end
  end  
```

This operation in the Vagrantfile is done for every device in the network and configurations are very similar (just the number of intefaces changes and of course names and source scripts), exept for host-c, which has to run a Docker image in order to provide a web-server on it, so the allocated RAM is doubled (512MB).

```
config.vm.define "host-c" do |hostc|
    hostc.vm.box = "ubuntu/bionic64"
    hostc.vm.hostname = "host-c"
    hostc.vm.network "private_network", virtualbox__intnet: "broadcast_router-south-2", auto_config: false
    hostc.vm.provision "shell", path: "host-c.sh"
    hostc.vm.provider "virtualbox" do |vb|
      vb.memory = 512
    end
  end
```
The original Vagrantfile has been modified and now it recalls scripts for every device in the network and not the "common.sh" script that was recalling when the project was blind.
If there is the need to do some modifies once that the network is up, it is possible to connect at every device in the network by a SSH connection in this way:
```
vagrant ssh #name-of-the-device

e.g. vagrant ssh host-a
```

#### Router-1
```
export DEBIAN_FRONTEND=noninteractive

#Commands for router-1 software
sudo apt-get update
sudo apt-get install -y tcpdump --assume-yes
sudo apt install -y curl --assume-yes

#Configuration of interface towards router-2
sudo ip add add 193.0.0.1/30 dev enp0s9                         #added IP address to the interface
sudo ip link set enp0s9 up                                      #turned on the interface

#Allowed router-1 to route packets
sudo sysctl net.ipv4.ip_forward=1

#Configuration of sub interfaces for vlans
sudo ip link set enp0s8 up
sudo ip link add link enp0s8 name enp0s8.10 type vlan id 10     #created new interface with VLAN tag=10
sudo ip add add 190.0.0.24/24 dev enp0s8.10                     #added IP address to VLAN interface with tag=10
sudo ip link set enp0s8.10 up                                   #turned on VLAN interface with tag=10
sudo ip link add link enp0s8 name enp0s8.8 type vlan id 8       #created new interface with VLAN tag=8
sudo ip add add 190.0.2.21/23 dev enp0s8.8                      #added IP address to VLAN interface with tag=8
sudo ip link set enp0s8.8 up                                    #turned on VLAN interface with tag=8

#Configuration for static route for subnet of host-c
sudo ip route add 191.0.0.0/25 via 193.0.0.2 dev enp0s9
```

#### Router-2
```
export DEBIAN_FRONTEND=noninteractive

#Commands for router-2 software
sudo apt-get update
sudo apt-get install -y tcpdump --assume-yes
sudo apt install -y curl --assume-yes

#Configuration of interface towards router-1
sudo ip addr add 193.0.0.2/30 dev enp0s9
sudo ip link set enp0s9 up

#Configuration of interface towards host-c
sudo ip addr add 191.0.0.11/25 dev enp0s8
sudo ip link set enp0s8 up

#Allowed ruoter-2 to route packets
sudo sysctl net.ipv4.ip_forward=1

#Configuration static route for subnet of host-a and host-b
sudo ip route add 190.0.0.0/22 via 193.0.0.1 dev enp0s9         #just one instruction referring to a bigger address that can contain S1 and S2
```
#### Switch
```export DEBIAN_FRONTEND=noninteractive

#Commands for switch's software
apt-get update
apt-get install -y tcpdump
apt-get install -y openvswitch-common openvswitch-switch apt-transport-https ca-certificates curl software-properties-common

#Configuration of switch ports
sudo ovs-vsctl add-br switch                    #made the device as a bridge called "switch"                  
sudo ovs-vsctl add-port switch enp0s8
sudo ovs-vsctl add-port switch enp0s9 tag=10
sudo ovs-vsctl add-port switch enp0s10 tag=8
sudo ip link set enp0s8 up
sudo ip link set enp0s9 up
sudo ip link set enp0s10 up
ovs-vsctl set port enp0s8 trunks=8,10
```
#### Host-a
```
export DEBIAN_FRONTEND=noninteractive

#Commands for host-a software
sudo apt-get update
sudo apt-get install -y tcpdump --assume-yes
sudo apt install -y curl --assume-yes

#Confugation of host interface
sudo ip addr add 190.0.0.25/24 dev enp0s8
sudo ip link set enp0s8 up

#Setup default gateway
sudo ip route add default via 190.0.0.24        #default gateway set on IP address of router-1 for S1
```
#### Host-b
```
export DEBIAN_FRONTEND=noninteractive

#Commands for host-c software
sudo apt-get update
sudo apt-get install -y tcpdump --assume-yes
sudo apt install -y curl --assume-yes

#Configuration of host interface
sudo ip addr add 190.0.2.22/23 dev enp0s8
sudo ip link set enp0s8 up

#Setup default gateway
sudo ip route add default via 190.0.2.21        #default gateway set on IP address of router-1 for S2
```
#### Host-c
```
export DEBIAN_FRONTEND=noninteractive

#Commands for host-c software
sudo apt-get update
sudo apt-get install -y tcpdump --assume-yes

#Commands for running a Docker container on host-c
sudo apt install -y curl --assume-yes
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common --assume-yes
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
sudo apt-key fingerprint 0EBFCD88 | grep docker@docker.com || exit 1
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce --assume-yes
sudo docker run --name Liz -p 80:80 -d dustnic82/nginx-test

#Configuration of host interface
sudo ip addr add 191.0.0.10/25 dev enp0s8
sudo ip link set enp0s8 up

#Setup default gateway
sudo ip route add default via 191.0.0.11
```

Of course, host-c needs more instructions than other hosts. This is due to the installation of the Docker image that requires some code lines. Is possible to see those in the script above, where first seven rows are for installation of certificates and access to repository where Docker image is stored, and the last one is the one that makes that particular ngninx server run.

### Assignement Execution
#### Traditional host
Is not particularly tricky to configure a host in this network. It just needs three actions: a valid IP address associated with the interface towards its competence router, to swtich on that interface and, in the end, a command that set the default gateway. Before doing these operations, it is possible to see that the interface's table is withuot an IP address on the interest interface and that it is off with the command:
```
vagrant@host-a:~$ ip addr show
```
And the result shows all interfaces on host-a. In this network, host-a has three interfaces: one with the Vagrant management (enp0s3), one is for the system address (lo) and one for the connection to the router-1 through the switch(enp0s8).
```
vagrant@host-a:~$ ip addr show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 02:82:7a:7b:51:94 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic enp0s3
       valid_lft 85726sec preferred_lft 85726sec
    inet6 fe80::82:7aff:fe7b:5194/64 scope link
       valid_lft forever preferred_lft forever
3: enp0s8: <BROADCAST,MULTICAST> mtu 1500 qdisc fq_codel state DOWN group default qlen 1000
    link/ether 08:00:27:dc:84:8a brd ff:ff:ff:ff:ff:ff
```
Once IP address is given and interface is turned on through these commands
```
vagrant@host-a:~$ sudo ip addr add 190.0.0.25/24 dev enp0s8
vagrant@host-a:~$ sudo ip link set enp0s8 up
```
the interface's table is updated:
```
vagrant@host-a:~$ ip add show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 02:82:7a:7b:51:94 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic enp0s3
       valid_lft 85264sec preferred_lft 85264sec
    inet6 fe80::82:7aff:fe7b:5194/64 scope link
       valid_lft forever preferred_lft forever
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:dc:84:8a brd ff:ff:ff:ff:ff:ff
    inet 190.0.0.25/24 scope global enp0s8
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fedc:848a/64 scope link
       valid_lft forever preferred_lft forever
```

Now the only thing remained to do is to add the default gateway. The command is
```
vagrant@host-a:~$ sudo ip route add default via 190.0.0.24
```
and before it, the situation shows a default gateway through the management interface (enp0s3)
```
vagrant@host-a:~$ ip route
default via 10.0.2.2 dev enp0s3 proto dhcp src 10.0.2.15 metric 100
```
but after the commnad, the default interface for the traffic has changed into enp0s8
```
vagrant@host-a:~$ ip route
default via 190.0.0.24 dev enp0s8
```

<b> NOTE: </b> the operation of assigning IP addresses and switching on interfaces has to be done for every device and on every interface of interest (exept for switch that does not have an IP address)

#### Switch with VLAN
The most important thing to do with the switch, in order to comply assignement's requests, is to set properly VLANs. Before do that, it is essential to make the device as a switch. This is done with the command
```
vagrant@switch:~$ sudo ovs-vsctl add-br switch
```
but does not inserts ports, in fact is possible to check it typing
```
vagrant@switch:~$ sudo ovs-vsctl list-ports switch
vagrant@switch:~$
```
as it is possible to see, there is no output. This means that actually there are not ports yet.
To add them, it is necessary a command that adds the port on a specify interface and, in the same time, sets the tag for the VLAN. Below it is reported just the example related to the port towards host-a and its power on.
```
vagrant@switch:~$ sudo ovs-vsctl add-port switch enp0s9 tag=10
vagrant@switch:~$ sudo ip link set enp0s9 up
```
Repeating this action for the interface towards host-b, and powering on the interface towards router-1 completes the configuration of the switch. Now, with the command used before, it is possible to see first of all the presence of ports in the switch:
```
vagrant@switch:~$ sudo ovs-vsctl list-ports switch
enp0s10
enp0s8
enp0s9
```
but mostly, using another command, it is pobbile to see the presence of VLANs in the switch, and so in the network:
```
vagrant@switch:~$ sudo ovs-appctl fdb/show switch
 port  VLAN  MAC                Age
    2    10  08:00:27:2c:7b:82  234
    3     8  08:00:27:30:fc:87  229
```
Another control to do is by the command
```
vagrant@switch:~$ sudo ovs-vsctl show
```
that shows ports, tags and interfaces in switch:
```
f3fe5cd6-2aec-437d-86a7-d684ac8d03ed
    Bridge switch
        Port "enp0s10"
            tag: 8
            Interface "enp0s10"
        Port switch
            Interface switch
                type: internal
        Port "enp0s8"
            trunks: [8, 10]
            Interface "enp0s8"
        Port "enp0s9"
            tag: 10
            Interface "enp0s9"
    ovs_version: "2.9.5"
```

#### Router with VLAN
Besides the configuration of interfaces and IP addresses already explained, routers need an important instruction that allows to reach those subnets not directly linked to them. In this case, S1 and S2 for router-2 and S3 for router-1. Analyzing router-1 case, with the command
```
vagrant@router-1:~$ ip route
```
is possible to see that there are no links with S3, which is linked only at router-2 and it has a network address of 191.0.0.0/25

```
vagrant@router-1:~$ ip route
default via 10.0.2.2 dev enp0s3 proto dhcp src 10.0.2.15 metric 100
10.0.2.0/24 dev enp0s3 proto kernel scope link src 10.0.2.15
10.0.2.2 dev enp0s3 proto dhcp scope link src 10.0.2.15 metric 100
190.0.0.0/24 dev enp0s8.10 proto kernel scope link src 190.0.0.24
190.0.2.0/23 dev enp0s8.8 proto kernel scope link src 190.0.2.21
193.0.0.0/30 dev enp0s9 proto kernel scope link src 193.0.0.1
```
But using the command that establishes a static route to reach S3, that is
```
vagrant@router-1:~$ sudo ip route add 191.0.0.0/25 via 193.0.0.2 dev enp0s9
```
the track for S3 appears in the routing table:
```
vagrant@router-1:~$ ip route
default via 10.0.2.2 dev enp0s3 proto dhcp src 10.0.2.15 metric 100
10.0.2.0/24 dev enp0s3 proto kernel scope link src 10.0.2.15
10.0.2.2 dev enp0s3 proto dhcp scope link src 10.0.2.15 metric 100
190.0.0.0/24 dev enp0s8.10 proto kernel scope link src 190.0.0.24
190.0.2.0/23 dev enp0s8.8 proto kernel scope link src 190.0.2.21
191.0.0.0/25 via 193.0.0.2 dev enp0s9
193.0.0.0/30 dev enp0s9 proto kernel scope link src 193.0.0.1
```
In the project, an unique instruction has been used to set the static route for S1 and S2 on router-2 merging together the subnets: this is called route aggregation.
```
sudo ip route add 190.0.0.0/22 via 193.0.0.1 dev enp0s9
```
This is possible because the network 190.0.0.0/22 has 10 bits for host addressing that means a range of addresses that goes from 190.0.0.0 to 190.0.3.255 that includes S1 (190.0.0.0/24) and S2 (190.0.2.0/23).

Other imporant things to set up on router-1 are interfaces towards host-a and host-b, so towards switch. Since the switch provides two different VLANs but router-1 has just one interface for switch, there is the need of a solution. The solution is to split the interface by VLANs' tags: this tags must be added at the interface's name. Once this is done, the interface with the tag "10" will hadle just the traffic coming from VLAN "10", and the same will do the interface with tag "8" with the traffic from the correspective interface.
Commands above descripted are:
```
sudo ip link add link enp0s8 name enp0s8.10 type vlan id 10
sudo ip add add 190.0.0.24/24 dev enp0s8.10
sudo ip link set enp0s8.10 up
sudo ip link add link enp0s8 name enp0s8.8 type vlan id 8
sudo ip add add 190.0.2.21/23 dev enp0s8.8
sudo ip link set enp0s8.8 up
```
and the effect on router-1 IP address table is:
```
vagrant@router-1:~$ ip add show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 02:82:7a:7b:51:94 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic enp0s3
       valid_lft 80259sec preferred_lft 80259sec
    inet6 fe80::82:7aff:fe7b:5194/64 scope link
       valid_lft forever preferred_lft forever
4: enp0s9: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:53:79:80 brd ff:ff:ff:ff:ff:ff
    inet 193.0.0.1/30 scope global enp0s9
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe53:7980/64 scope link
       valid_lft forever preferred_lft forever
5: enp0s8.10@enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 08:00:27:f6:d3:05 brd ff:ff:ff:ff:ff:ff
    inet 190.0.0.24/24 scope global enp0s8.10
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fef6:d305/64 scope link
       valid_lft forever preferred_lft forever
6: enp0s8.8@enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 08:00:27:f6:d3:05 brd ff:ff:ff:ff:ff:ff
    inet 190.0.2.21/23 scope global enp0s8.8
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fef6:d305/64 scope link
       valid_lft forever preferred_lft forever
```
#### Docker Container
Once the script for host-c is launched, it is possible to check if the docker container has been set up correctly:
```
vagrant@host-c:~$ sudo docker ps
CONTAINER ID        IMAGE                  COMMAND                  CREATED
STATUS              PORTS                         NAMES
44635fe7a158        dustnic82/nginx-test   "nginx -g 'daemon of…"   5 minutes ago
Up 5 minutes        0.0.0.0:80->80/tcp, 443/tcp   Liz
```
### Results
Now that every feature of the network has been checked and everything is fine, it is time to check if devices can communicate each other and if the docker container does its job.
For the first opration, a ping is enough. In the network, every possible ping from and to every interface works, but for facilitate reading, only two are reported, one from host-a to host-c and one from router-2 to host-b:
```
vagrant@host-a:~$ ping 191.0.0.10
PING 191.0.0.10 (191.0.0.10) 56(84) bytes of data.
64 bytes from 191.0.0.10: icmp_seq=1 ttl=62 time=1.83 ms
64 bytes from 191.0.0.10: icmp_seq=2 ttl=62 time=1.63 ms
64 bytes from 191.0.0.10: icmp_seq=3 ttl=62 time=1.81 ms
64 bytes from 191.0.0.10: icmp_seq=4 ttl=62 time=1.53 ms
64 bytes from 191.0.0.10: icmp_seq=5 ttl=62 time=1.45 ms
64 bytes from 191.0.0.10: icmp_seq=6 ttl=62 time=1.57 ms
64 bytes from 191.0.0.10: icmp_seq=7 ttl=62 time=1.47 ms
64 bytes from 191.0.0.10: icmp_seq=8 ttl=62 time=1.64 ms
--- 191.0.0.10 ping statistics ---
8 packets transmitted, 8 received, 0% packet loss, time 7018ms
rtt min/avg/max/mdev = 1.454/1.621/1.837/0.144 ms
```
```
vagrant@router-2:~$ ping 190.0.2.22
PING 190.0.2.22 (190.0.2.22) 56(84) bytes of data.
64 bytes from 190.0.2.22: icmp_seq=1 ttl=63 time=1.37 ms
64 bytes from 190.0.2.22: icmp_seq=2 ttl=63 time=1.05 ms
64 bytes from 190.0.2.22: icmp_seq=3 ttl=63 time=1.24 ms
64 bytes from 190.0.2.22: icmp_seq=4 ttl=63 time=1.27 ms
64 bytes from 190.0.2.22: icmp_seq=5 ttl=63 time=1.09 ms
64 bytes from 190.0.2.22: icmp_seq=6 ttl=63 time=1.15 ms
64 bytes from 190.0.2.22: icmp_seq=7 ttl=63 time=1.13 ms
64 bytes from 190.0.2.22: icmp_seq=8 ttl=63 time=1.08 ms
--- 190.0.2.22 ping statistics ---
8 packets transmitted, 8 received, 0% packet loss, time 7013ms
rtt min/avg/max/mdev = 1.056/1.177/1.374/0.111 ms
```

In the end, to test if the Docker container works properly is necessary this command that asks the server to download an internet page (tried from host-b):
```
vagrant@host-b:~$ curl 191.0.0.10
```
that provides this output:
```
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
```
which is a sign that everything works.

