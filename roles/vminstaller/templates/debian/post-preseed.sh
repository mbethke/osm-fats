#!/bin/sh

###
### Debian Preseed Post Install Script
### -----------------------------------
### Author : Toshaan Bharvani <toshaan@vantosh.com>
### (c) copyright VanTosh 2013
### BSD License
###

TARGET='/target'

### Go into the machine environment
chroot $TARGET

### OpenSSH Settings
/bin/sed 's/\Port\ 22/Port\ {{ ansible_port }}/' -i /etc/ssh/sshd_config
/bin/sed 's/\LoginGraceTime\ 120/LoginGraceTime\ 60/' -i /etc/ssh/sshd_config
/bin/sed 's/\PermitRootLogin\ yes/PermitRootLogin\ no/' -i /etc/ssh/sshd_config
/bin/sed 's/UsePAM\ yes/UsePAM\ yes\nAllowUsers\ ansible/' -i /etc/ssh/sshd_config
/bin/mkdir /home/ansible/.ssh/
/bin/chmod 700 /home/ansible/.ssh/ ; \
/bin/echo "{{ sshpubkey }}" > /home/ansible/.ssh/authorized_keys ; \
/bin/chmod 600 /home/ansible/.ssh/authorized_keys ; \
/bin/chown -R 999999.999999 /home/ansible/.ssh/
{# #/usr/bin/ssh-keygen -q -b {{ sshdkeylength }} -t rsa -f /etc/ssh/ssh_host_rsa_key -C '' -N '' #}

### Sudo Settings
/bin/echo "ansible     ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/ansible
chmod 440 /etc/sudoers.d/ansible

### Delete unnecessary users
/usr/sbin/userdel games
/usr/sbin/userdel list
/usr/sbin/userdel irc
/usr/sbin/userdel proxy
/usr/sbin/userdel backup
/usr/sbin/userdel gnats
/usr/sbin/userdel news

exit
