# ###########  ansible with linux server configuration yml file #########
To configure a Linux server, Ansible uses Playbooks (YAML files) to define tasks. Unlike Windows, Linux servers are typically managed via SSH and do not require an agent.

 Playbook: Linux Server Configuration
This playbook handles common setup tasks: updating packages, creating a sudo user, and setting up a basic web server.

Plz Refer Linux_server_config.yml file 


Essential Linux Modules
Module                               	Purpose
ansible.builtin.apt / yum	          Manage packages on Debian/Ubuntu or RHEL/CentOS systems.
ansible.builtin.user	              Creates, removes, and manages user accounts and permissions.
ansible.builtin.copy	              Transfers local files to the remote server.
ansible.builtin.lineinfile            Ensures a particular line is in a file (useful for configuration files like SSH).
ansible.builtin.service               Starts, stops, or restarts system services.


Security Hardening Tips
SSH Hardening: Use lineinfile to set PermitRootLogin no and PasswordAuthentication no to require SSH keys.
Automatic Updates: Configure the unattended-upgrades package on Ubuntu to ensure security patches are applied automatically.
SELinux: For Red Hat systems, use the ansible.posix.selinux module to ensure it is in enforcing mode


# ############### how to encrypt sensitive data like passwords using Ansible Vault ###############

To encrypt sensitive data like passwords, you can use Ansible Vault, which allows you to secure either entire files or specific individual variables. 

Method 1: Encrypting Specific Variables (Recommended)
This approach keeps your playbook readable while only hiding sensitive strings.

1. Generate the encrypted string:
Run the following command to encrypt a single password:

Bash Command :

ansible-vault encrypt_string 'db_secret_password' --name 'db_password'

You will be prompted to enter a vault password.

2. Paste into your Playbook:
The command outputs an encrypted block that you can paste directly into your YAML file:

vars:
  db_password: !vault |
      $ANSIBLE_VAULT;1.1;AES256
      6563313830313336303433373465373438323535356439326432653237643333...
```



Method 2: Encrypting Entire Files
Use this for files that consist entirely of secrets, such as a dedicated secrets.yml file. 

ansible-vault create secrets.yml

This opens your default editor (usually vi). Any data saved here will be encrypted upon closing.
ansible-vault encrypt my_vars.yml
```

Edit an encrypted file:
ansible-vault edit secrets.yml
```

How to Run Playbooks with Encrypted Data
When executing your playbook, you must provide the vault password so Ansible can decrypt the data in memory during runtime. 

Interactive prompt:
ansible-playbook site.yml --ask-vault-pass
Using a password file (best for automation):
Store your vault password in a protected local file and reference it:
ansible-playbook site.yml --vault-password-file ~/.vault_pass.txt

Summary of Commands
Action 	Command
Encrypt a string	ansible-vault encrypt_string 'value' --name 'var_name'
Encrypt a file	ansible-vault encrypt <filename>
Edit a secret file	ansible-vault edit <filename>
Change password	ansible-vault rekey <filename>
Security Best Practice: Never commit your vault password file to version control (e.g., Git). Use chmod 600 on your password file to restrict access to only your user account.

# ########## how to use multiple vault passwords for different environments like staging and production #########


To manage multiple environments like staging and production with distinct passwords, use Vault IDs. This feature allows you to label encrypted content so Ansible knows which password to use for which file. 
LinkedIn
LinkedIn
 +2
1. Encrypt Files with Vault IDs 
Assign a unique label (e.g., staging or prod) when encrypting your files. This label is stored in the file header as a "hint". 

For Staging:
ansible-vault encrypt --vault-id staging@prompt vars/staging_secrets.yml
For Production:
ansible-vault encrypt --vault-id prod@prompt vars/prod_secrets.yml

2. Run Playbooks with Multiple IDs 
When running a playbook, provide the source for each required password. You can mix interactive prompts and password files.

ansible-playbook site.yml \
  --vault-id staging@~/.vault_pass_staging \
  --vault-id prod@prompt

3. Automate via Configuration 
To avoid long CLI commands, define your Vault IDs in the ansible.cfg file under the [defaults] section.

[defaults]
# Maps labels to local password files
vault_identity_list = staging@~/.ansible/staging_pass, prod@~/.ansible/prod_pass

# Optional: strictly match IDs to prevent trying every password on every file
vault_id_match = True

Comparison: Single vs. Multiple Passwords
Feature 	Single Password	Multiple Vault IDs
Best For	Small teams/projects	Multi-environment (Dev/Staging/Prod)
Security	One leak exposes everything	Compromised staging password won't affect prod
Usage	--ask-vault-pass	--vault-id label@source
Security Tip: If you are using Ansible AWX or Tower, you can create separate "Vault" credentials for each environment and assign multiple credentials to a single job template.
