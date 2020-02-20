export DEBIAN_FRONTEND=noninteractive

#Commands for router-1 software
sudo apt-get update
sudo apt-get install -y tcpdump --assume-yes
sudo apt install -y curl --assume-yes

#Startup commands go here

#Configuration of interface towards router-2
sudo ip add add 193.0.0.1/30 dev enp0s9
sudo ip link set enp0s9 up

#Allowed router-1 to route packets
sudo sysctl net.ipv4.ip_forward=1

#Configuration of sub interfaces for vlans
sudo ip link set enp0s8 up
sudo ip link add link enp0s8 name enp0s8.10 type vlan id 10
sudo ip add add 190.0.0.24/24 dev enp0s8.10
sudo ip link set enp0s8.10 up
sudo ip link add link enp0s8 name enp0s8.8 type vlan id 8
sudo ip add add 190.0.2.21/23 dev enp0s8.8
sudo ip link set enp0s8.8 up

#Configuration for static route for subnet of host-c
sudo ip route add 191.0.0.0/25 via 193.0.0.2 dev enp0s9

