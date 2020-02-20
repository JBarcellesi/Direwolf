export DEBIAN_FRONTEND=noninteractive

#Commands for router-2 software
sudo apt-get update
sudo apt-get install -y tcpdump --assume-yes
sudo apt install -y curl --assume-yes

#Startup commands go here

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





