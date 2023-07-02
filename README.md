#  Automation Management
The purpose of this repository is to maintain the setup for the systems that are runnning the code bases

## Setup Ansible on  5.15.90.1-microsoft-standard-WSL2 (Ubuntu)
Install ansible using the following steps.
```
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install python3 python3-pip git libffi-dev libssl-dev -y
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt remove ansible
sudo apt install ansible-core
```
Test ansible with `ansible --version`. It should return
```
   ansible [core 2.14.6]
```

Now for passwordless SSH access, setup your local SSH keys and then copy them to the remote host where you replace **user** and **localhost** with the username for the remote host and address of the remote host.
```
ssh-keygen -t rsa
ssh-copy-id user@localhost
ssh user@localhost
```

Also add the remote host IP address and DNS name (if available) to the `/etc/ansible/hosts` file. In the below example **comm_dev** is the name of the VM I added to the Window's `%SystemRoot%\System32\drivers\etc\hosts` file. This allows me to have VMs on different machines doing the same thing and all can be referenced from Windows with **comm_dev**.
```
sudo vi /etc/ansible/hosts
# add the below line
comm_dev ansible_host=192.168.141.128
```

Test with 
```
ansible all -i "localhost," -m shell -a 'echo Ansible is fun'
```

For sudo access on the remote host store the password in an ansible-vault. To do that 
```
mkdir vault
ansible-vault create vault/secrets.yaml
```

Then add where user and password are the actual username and password. Protip don't make your password 'password' :). Also don't commit this file even if it is encrypted.
```
ansible_user: user
ansible_become_pass: password
```

If you need to view the information run
``` 
 ansible-vault view vault/secrets.yaml 
```

Or to change it
``` 
 ansible-vault edit vault/secrets.yaml 
```

Finally if you do not want to specify the vault password when running playbooks create a text file in the vault directory containing just the vault password: 
```
cat vault/vault_password.txt 
password
```
Now you can run either
```
ansible-playbook playbook.yaml --ask-vault-pass
# or
ansible-playbook playbook.yaml --vault-password-file ../vault/vault_password.txt
```

## Running playbooks
To run the WPS automation playbook, execute the following:
```
ansible-playbook install_wps_automation.yaml --vault-password-file ../vault/vault_password.txt
```

