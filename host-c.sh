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

#Startup commands go here

#Configuration of host interface
sudo ip addr add 191.0.0.10/25 dev enp0s8
sudo ip link set enp0s8 up


#Setup default gateway
sudo ip route add default via 191.0.0.11
