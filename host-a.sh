export DEBIAN_FRONTEND=noninteractive

#Commands for host-a software
sudo apt-get update
sudo apt-get install -y tcpdump --assume-yes
sudo apt install -y curl --assume-yes

#Startup commands go here

#Confugation of host interface
sudo ip addr add 190.0.0.25/24 dev enp0s8
sudo ip link set enp0s8 up

#Setup default gateway
sudo ip route add default via 190.0.0.24