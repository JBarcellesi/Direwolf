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
        
3. [Assignement Execution and Results](#Assignement-Execution-and-Results)
4. [Examples of Bad Configuration](#Examples-of-Bad-Configuration)


### Technical Configuration
#### Subnets
To implement the assignement, four subents are needed, one for each host linked to its router of reference and one to link routers together:

**1**) S1 is the subnet for host-a between it and router-1. This subnet has to contain at least 145 hosts, so it needs 8 bits for hosts IP addresses (2<sup>8</sup>=256). This means that 24 bits remain for network IP address, so the netmask of the subnet is 255.255.255.0 and the IP network address chosen is 190.0.0.0/24.

**2**) S2 is the subnet that contains host-b and it is associated to router-1. The requirement says that the subnet of host-b has to contain at least 401 hosts, hence 9 bits are needed for hosts IP addresses (2<sup>9</sup>=512). For this reason, the netmask of the subnet is composed by 23 bits and it is 255.255.254.0 with a subnet IP address that is 190.0.2.0/23.

**3**) S3 is the subnet where host-c stays, provided by router-2. It has to contain just 79 hosts as the assignement requires, so it needs 7 bits for hosts IP addresses (2<sup>7</sup>=128) generating a netmask that is 255.255.255.128 since 25 bits remain for subnet IP adress that is 191.0.0.0/25.

**4**) S4 is the last subnet in the project but is the most important, because it links ruoter-1 and router-2 and, without it, is not possible to send packets from host-a or host-b to host-c and viceversa. Since the subnet has just to provide a connection between routers, 2 bits are enough for hosts IP addresses (2 hosts that are routers, one address for broadcast service and one for the network). The netmask is 255.255.255.252 and the subnet IP adress is 193.0.0.0/30.

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

It is necessary for every device to turn on interfaces to allow traffic to pass, to give IP addresses for every interface (execpt for the switch that works at level 2 in the ISO/OSI stack, so it does not have an IP address since it is only for level 3 of ISO/OSI stack devices). In addiction, those VMs that act as routers need a command to allow them to route packet becoming worthy of being named "router". Then every host needs a command to ensure them a default gateway and every gateway needs a command that builds a static route (since dynamic routing is not allowed in the project) to reach those subnets that are linked to the other gateway present in the network.  

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

This operation in teh Vagrantfile is done for every device in the network and configurations are very similar (just the number of intefaces changes and of course names and source scripts), exept for host-c, which has to run a Docker image in order to provide a web-server on it, so the allocated RAM is doubled (512MB)

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

#Allow ruoter-2 to route packets
sudo sysctl net.ipv4.ip_forward=1

#Configuration static route for subnet of host-a and host-b
sudo ip route add 190.0.0.0/22 via 193.0.0.1 dev enp0s9
```
#### Switch
```export DEBIAN_FRONTEND=noninteractive

#Commands for switch's software
apt-get update
apt-get install -y tcpdump
apt-get install -y openvswitch-common openvswitch-switch apt-transport-https ca-certificates curl software-properties-common

#Configuration of switch ports
sudo ovs-vsctl add-br switch
sudo ovs-vsctl add-port switch enp0s8
sudo ovs-vsctl add-port switch enp0s9
sudo ovs-vsctl add-port switch enp0s10
sudo ip link set enp0s8 up
sudo ip link set enp0s9 up
sudo ip link set enp0s10 up

#Configuration of VLANs
sudo su
ovs-vsctl set port enp0s9 tag=10
ovs-vsctl set port enp0s10 tag=8
ovs-vsctl set port enp0s8 trunks=8,10
exit
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
sudo ip route add default via 190.0.0.24
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
sudo ip route add default via 190.0.2.21
```
#### Host-c
```
export DEBIAN_FRONTEND=noninteractive

#Commands for host-c software
sudo apt-get update
sudo apt-get install -y tcpdump --assume-yes

#Command for running a Docker container on host-c
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

### Assignement Execution and Results
### Examples of Bad Configuration

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


