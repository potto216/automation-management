## Ansible notes
Most of these notes are edited ChatGPT responses.

### To deploy an Ansible playbook to a group of hosts while gracefully skipping any hosts that are offline or unreachable

To deploy an Ansible playbook to a group of hosts, like comm_dev_group, while gracefully skipping any hosts that are offline or unreachable, you can use a combination of Ansible inventory, configuration settings, and command-line options.

Here are the steps to set up and run your playbook under these conditions:

Define Your Host Group in the Ansible Inventory:

In your Ansible inventory file (typically /etc/ansible/hosts or a custom inventory file), define the comm_dev_group group and list the hosts in it.
```
[comm_dev_group]
host1.example.com
host2.example.com
```
Configure Ansible to Skip Unreachable Hosts:

You can configure Ansible to continue running on other hosts when it encounters an unreachable host. This can be done by setting any_errors_fatal: false in your playbook. Also, you can set the strategy to free, which allows each host to run the playbook as fast as it can without waiting for others.

```
---
- name: Deploy to comm_dev_group
  hosts: comm_dev_group
  any_errors_fatal: false
  strategy: free
  tasks:
    ...
```

### Use Ansible Command Line with Custom Timeout

When running your playbook, you can specify a custom timeout value using the -T or --timeout option to reduce the time Ansible waits for a response from each host. This can help to quickly skip offline hosts.

This command sets a connection timeout of 10 seconds for each host.
```
ansible-playbook your_playbook.yml -i your_inventory_file -T 10
```

Optional: Ansible Configuration File Tweaks:

For more persistent settings, you can modify your ansible.cfg file to include settings like a custom timeout. This way, you won't have to specify these settings in the command line every time.

```
[defaults]
timeout = 10
```
Running the Playbook:

Finally, run your playbook with the following command:

```
ansible-playbook -i your_inventory_file playbook.yml
```
Replace your_inventory_file with the path to your inventory file and playbook.yml with your playbook file.

By setting any_errors_fatal: false and using a reasonable timeout, Ansible will attempt to run the playbook on all hosts in comm_dev_group but will skip any that are unreachable within the timeout period. This approach ensures that your playbook is deployed to all online computers in the group with a single command.


The behavior you're observing in the Ansible task is due to the order in which Ansible processes different directives, specifically become and 
environment. In your task:

```
- name: Install Pyenv
  shell: |
    curl https://pyenv.run | bash
  args:
    creates: "$HOME/.pyenv"
  environment:
    HOME: "{{ ansible_env.HOME }}"
  become: yes
  become_user: user
  when: install_python
```
The key parts to focus on are become, become_user, and environment. Here's what's happening:

Environment Variable (environment): You are setting the HOME environment variable to {{ ansible_env.HOME }}. The ansible_env variable is gathered at the start of the playbook execution and reflects the environment of the user under whom Ansible is running, typically the user that initiates the Ansible run. If this playbook is executed as root, then ansible_env.HOME will point to /root, the home directory of the root user.

User Switching (become and become_user): The become and become_user directives are used to escalate privileges and switch the effective user to user. However, this switch happens after the environment variables are set.

As a result, even though you switch to the user account for executing the task, the HOME environment variable still points to /root (or the home directory of the user who started the playbook) because ansible_env.HOME was resolved before the user switch.

To ensure the HOME environment variable is correctly set to the user's home directory, you should avoid using ansible_env.HOME and instead set it explicitly, like so:
```
- name: Install Pyenv
  shell: |
    curl https://pyenv.run | bash
  args:
    creates: "/home/user/.pyenv"
  environment:
    HOME: "/home/user"
  become: yes
  become_user: user
  when: install_python
In this modified task, the HOME environment variable is explicitly set to /home/user, which is the expected home directory of the user account. This ensures that the task operates in the correct user's environment.
```

### Using the environment setup by the user .bashrc 

How do you make sure the task below uses the environment setup by the user .bashrc ?
    - name: Install Python 11 using Pyenv
      shell: pyenv install 11.7.0
      environment:
        PATH: "$HOME/.pyenv/bin:$PATH"
      become: yes
      become_user: user
      when: install_python

**Answer**
To ensure that the Ansible task uses the environment setup by the user's .bashrc, especially when becoming another user (e.g., switching to the user account), you need to make sure that the shell session is a login session, so it reads the .bashrc or .bash_profile of the user.

However, the shell module in Ansible does not start a login shell by default. Thus, environment variables set in the user's .bashrc are not automatically sourced. To work around this, you can explicitly source the .bashrc file in your task. Here's how you can modify your task:

```
- name: Install Python 11 using Pyenv
  shell: |
    source /home/user/.bashrc
    pyenv install 11.7.0
  environment:
    PATH: "/home/user/.pyenv/bin:{{ ansible_env.PATH }}"
  become: yes
  become_user: user
  when: install_python
```

In this task:

The source /home/user/.bashrc command is used to explicitly source the .bashrc file of the user. This ensures that all the environment variables and settings defined in .bashrc are available to the subsequent commands in the task.
The PATH environment variable is set to include pyenv's bin directory. It's important to note that {{ ansible_env.PATH }} is used instead of $PATH to ensure that the original PATH from the Ansible environment is preserved and appended.
become: yes and become_user: user are used to switch to the user account for executing the command.
Keep in mind that sourcing .bashrc may have unintended consequences depending on what's in there. It's typically designed for interactive shell sessions, so ensure that it doesn't contain interactive-specific elements when sourcing it in a script or automation tool like Ansible.

### Common errors with the Ansible task

**source: not found:** This error occurs because the shell module in Ansible uses /bin/sh by default, which does not recognize the source command. source is a Bash-specific command. To resolve this, you can either use . /home/user/.bashrc (which is POSIX-compliant and equivalent to source in Bash) or explicitly specify that Bash should be used for the shell commands.

**pyenv: not found:** This error is likely because the PATH environment variable is not correctly set to include the pyenv binary, or pyenv is not installed in the expected location. This might also be related to the fact that the .bashrc file (which presumably initializes pyenv) is not being sourced correctly due to the first issue.

To address both issues, modify your task as follows:

```
- name: Install Python 11 using Pyenv
  shell: |
    . /home/user/.bashrc
    pyenv install 11.7.0
  args:
    executable: /bin/bash
  environment:      
    HOME: "/home/user"      
    PATH: "/home/user/.pyenv/bin:{{ ansible_env.PATH }}"
  become: yes
  become_user: user
  when: install_python
```
Changes made:

Replaced source with ., which is the POSIX-compliant way to source a file.
Added args: executable: /bin/bash to explicitly use Bash as the shell for executing the script. This is important because .bashrc is typically configured for Bash.
Adjusted the PATH environment variable to prepend the pyenv binary location.
With these changes, the task should correctly source the .bashrc file and find the pyenv command. Ensure that pyenv is correctly installed and configured for the user, and the .bashrc contains the necessary initialization for pyenv.


### Override the host or group of hosts specified in the Ansible playbook

You can override the host or group of hosts specified in the Ansible playbook from the command line when running the playbook. This is done using the -i (inventory) and -l (limit) options.

Here's how you can do it:

Using the -i Option:
The -i option allows you to specify a different inventory file or a list of hosts at the command line. This can be useful if you have multiple environments (like staging, production, etc.) with different inventories.

```
ansible-playbook playbook.yml -i another_inventory_file
```

You can also specify a single host or a comma-separated list of hosts directly:

```
ansible-playbook playbook.yml -i 'host1.example.com,host2.example.com,'
```
The trailing comma is important when specifying a list directly as it tells Ansible that it's a list of hosts and not a file name.

Using the -l Option:
The -l option limits the playbook's execution to the hosts or groups specified. This is useful when your playbook targets a broad group (like all), but you want to run it on a specific host or subgroup.

```
ansible-playbook playbook.yml -l specific_host
```
Or for a subgroup within an inventory:

```
ansible-playbook playbook.yml -l subgroup_name
```
Combining -i and -l:
You can use both -i and -l together to specify an inventory file and then limit the execution to certain hosts within that inventory.

```
ansible-playbook playbook.yml -i custom_inventory_file -l specific_host
```
This flexibility allows you to create generic playbooks that can be targeted at different environments or sets of hosts simply by changing command-line arguments, without the need to alter the playbook itself.

