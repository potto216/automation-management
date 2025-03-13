#  Automation Management
The purpose of this repository is to maintain the setup for the systems that are runnning the code bases. Warning! most of the playbooks assume Ubuntu Linux and that the user account is called "user". Please file an issue if there is a need to modify this. PRs are welcome.

## Setup the Automation Management repo with Ansible on 5.15.90.1-microsoft-standard-WSL2 (Ubuntu)
Install git
```
sudo apt install git
```

Clone the repository (Assuming HTTPS) and my preference is that the directory name uses underscores instead of dashes to reduce the chance of conflicts
```
git clone https://github.com/potto216/automation-management.git automation_management
```

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

Also add the remote host IP address and DNS name (if available) to the `/etc/ansible/hosts` file and the `/etc/hosts` file. In the below example **comm_dev** is the name of the VM I added to the Window's `%SystemRoot%\System32\drivers\etc\hosts` file. This allows me to have VMs on different machines doing the same thing and all can be referenced from Windows with **comm_dev**. If using WSL then `/etc/hosts` is normally automatically updated by the Windows host file.
```
sudo vi /etc/ansible/hosts
# add the below lines for the group and hosts, such as 
[comm_dev_group]
comm-dev-01    ansible_host=192.168.141.128
esp-rs-dev-01  ansible_host=192.168.202.133
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
ansible-playbook ./playbooks/install_wps_automation.yaml --vault-password-file ./vault/vault_password.txt
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

## Playbook Examples
If installing to Ubuntu make sure the ssh server has been installed and the ssh key from the ansible server has been copied over with commands such as:
```
sudo apt install openssh-server
ssh-copy-id user@replace-with-device-name
```

### Setting up the GNURadio SDR notebook playbook 
This assumes GNURadio is already setup. It will run on all hosts defined in the inventory file that match the playbook’s target group (as declared in the playbook’s hosts: directive). 
```
ansible-playbook ./playbooks/install_gnuradio_notebook.yaml --vault-password-file ./vault/vault_password.txt
```

Test that the notebook server works on the device with
```
cd ~/sdr/gnuradio_notebook
source .gnuradio_notebook/bin/activate 
export PYTHONPATH=$HOME/sdr/gnuradio_notebook/.gnuradio_notebook/lib/python3.10/site-packages:/usr/lib/python3/dist-packages:/usr/lib/python3/site-packages
jupyter lab --LabApp.token='' 
```
### To install the general communication development environment playbook on device esp-rs-dev-01
```
ansible-playbook  -vv ./playbooks/setup_general_comm_dev.yaml --vault-password-file ./vault/vault_password.txt -l esp-rs-dev-01 --extra-vars "install_python=true install_vim=true install_rust=true"
```

### To setup a Matter.js on the device matter_js_test
```
# First install the general communication development environment playbook to setup python and vim 
ansible-playbook  -vv ./playbooks/setup_general_comm_dev.yaml --vault-password-file ./vault/vault_password.txt -l matter_js_test --extra-vars "install_python=true python_version=3.12.9"

# Now setup matter.js and its dependencies 
ansible-playbook  -vv ./playbooks/install_matter.yaml --vault-password-file ./vault/vault_password.txt -l matter_js_test --extra-vars "install_nodejs=true install_matterjs=true"
```

## Ansible notes
See [ansible notes](./docs/ansible_notes.md)