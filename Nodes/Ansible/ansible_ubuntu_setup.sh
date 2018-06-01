#Installation of mandatory sw
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get install python3.6
sudo apt-get install software-properties-common
sudo apt-get install python-pip git libffi-dev libssl-dev -y
#Python install winrm and ansible
pip install "pywinrm>=0.2.2"
pip install ansible
#Resolve windows hostnames
sudo apt-get install winbind