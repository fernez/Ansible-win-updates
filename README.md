# Ansible win-update

## Ansible node setup


Description of configuration of master Ansible server for managing Windows servers.
 
Checking actual image of Ubuntu using AWS CLI:

```
aws ec2 describe-images --owners 099720109477 --filters
 "Name=VirtualizationType,Values=hvm" --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*" --query "sort_by(Images, &CreationDate)[-1].[ImageId]" --region eu-west-1 --output "table"
```
 
Creation of ec2 security Gross using AWS CLI:

``` 
aws ec2 create-security-group --group-name ansible --description "Grocerkey security-group for Ansible server"
aws ec2 create-security-group --group-name windows-update--description "Security group for managed Windows Server"
aws ec2 create-security-group --group-name remote-access --description "Security group for admin remote access to servers"
``` 
 
Running EC2 instance for Ansible:
 
``` 
aws ec2 run-instances --image-id ami-46dee13f --count 1 --instance-type t2.micro --key-name GKKeyPairAnsibleEU --security-groups "remote-access" "ansible"
```

Installation of mandatory software for Ansible server:
Software needed for running Ansible including Python, Git, etc.
Run the shell script:


[/Nodes/Ansible/ansible_ubuntu_setup.sh](/Nodes/Ansible/ansible_ubuntu_setup.sh)


Create new group called „winservers“ defined with variables used for technical account and SSL Windows Remote Management (WinRM) port specification
(Copy group_vars directory into your Ansible directory /etc/ansible/):


[/Nodes/Ansible/group_vars/winservers](/Nodes/Ansible/group_vars/winservers)

 
Edit hosts file located in /etc/ansible/hosts, ADD windows servers group like it is in hosts file:


[/Nodes/Ansible/hosts](/Nodes/Ansible/hosts)

 
Heathcheck of Windows servers (all hosts should return SUCCESS):
```
ansible winservers -m win_ping
```


## Windows node setup


Description of configuration of managed Windows servers.
 
Running Windows (not fully updated) AMI instance:

```
aws ec2 run-instances --image-id ami-1ae05663 --count 1 --instance-type t2.medium --key-name GKKeyPairSQLServerEU --security-groups "remote-access" "windows-update"
```
 
Configuration script:
Windows server Powershell configuration script enabling Ansible using ports 5985, 5986, enabling some usefull tools like telnet client for debugging and creation of technical admin user for Ansible purposes.


[/Nodes/Windows/ansible_setup.ps1](/Nodes/Windows/ansible_setup.ps1)


*note: Edit password of technical user before running script

Manually disable Windows Updates:

Windows + R, type Services.msc to open Services
Windows Update > Properties > Startup type change to "Manual"



## How to perform Windows update

Windows update is performed by Ansible Playbook which can be found on location below. There are two kinds of behavior which depends on check mode (if its on or off).
[/Playbooks/windows-update.yml](/Playbooks/windows-update.yml)

### Playbook dry run

In dry-run (using --check option) the playbook contains only one task:

1. List updates available.

```
ansible-playbook /etc/ansible/windows-update.yml --check
```

### Running playbook

Playbook contains 3 tasks performing the actual windows update:
1. Checking for updates. 
2. Install updates (Only if some updates are found)
3. Reboot with waiting (if required) - When updates are installed
	* Waiting time can be changed in playbook according to server performance

```
sudo ansible-playbook /etc/ansible/windows-update.yml
```


