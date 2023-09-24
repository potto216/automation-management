#  Automation Management
The purpose of this repository is to maintain the setup for the systems that are runnning the code bases

## Setup Ansible on 5.15.90.1-microsoft-standard-WSL2 (Ubuntu)
Install ansible using the following steps.
```
sudo apt update
sudo apt upgrade
sudo apt install python3 python3-pip git libffi-dev libssl-dev -y
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
# add the below line such as
comm_dev ansible_host=192.168.141.128
```

Test with 
```
ansible all -i "localhost," -m shell -a 'echo Ansible is fun'
```

For sudo access on the remote host store the password in an ansible-vault. To do that in the  automation_management repo root create the vault directory.
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
echo "password" >> vault/vault_password.txt
# check with
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
cd playbooks
ansible-playbook install_wps_automation.yaml --vault-password-file ../vault/vault_password.txt
```

## Launching with Visual Studio Code running from Windows
First find the WSL distribution you are looking for. In this case it is the Ubuntu distribution
```
C:\Users\user>wsl --list --verbose
  NAME            STATE           VERSION
* Ubuntu          Running         2
  Ubuntu-22.04    Running         2
```

Find the repo on the distribution
```
C:\Users\user>dir \\wsl$\Ubuntu\home\user\automation_management
 Volume in drive \\wsl$\Ubuntu has no label.

 Directory of \\wsl$\Ubuntu\home\user\automation_management

07/02/2023  09:53 AM    <DIR>          vault
07/02/2023  07:37 AM               513 .gitignore
08/13/2023  03:12 PM             2,998 README.md
...
```
Launch Visual Studio Code
```
code \\wsl$\Ubuntu\home\user\automation_management
```

## Example: Setting up the GNURadio SDR notebook

```
ansible-playbook install_gnuradio_notebook.yaml --vault-password-file ../vault/vault_password.txt
```

Test on the device with
```
cd ~/sdr/gnuradio_notebook
source .gnuradio_notebook/bin/activate 
export PYTHONPATH=$HOME/sdr/gnuradio_notebook/.gnuradio_notebook/lib/python3.10/site-packages:/usr/lib/python3/dist-packages:/usr/lib/python3/site-packages
jupyter lab --LabApp.token='' 
```

