#!/bin/sh

set -x

###
### UbuntuPreseed Post Install Script
### -----------------------------------
### Author : Toshaan Bharvani <toshaan@vantosh.com>
### (c) copyright VanTosh 2013
### BSD License
###

### OpenSSH Settings
/bin/sed 's/#\?PasswordAuthentication.*/PasswordAuthentication no/' -i /etc/ssh/sshd_config
/bin/sed 's/PrintLastLog\ yes/PrintLastLog\ no' -i /etc/ssh/sshd_config

# Add extra SSD for databases if available
SSD=/dev/vdb
if [ -b $SSD ]; then
    blkval() { blkid $SSD -o value | head -n$1 | tail -n1; }
    mkfs.ext4 -Osparse_super,filetype,dir_index -LPostgres $SSD 
    mkdir /data /var/lib/postgresql
    mount $SSD /data
    mkdir /data/__home /data/__var__lib__postgresql
    mv /home/ansible /data/__home
    mount --bind /data/__home /home
    printf "%23s %23s %7s %15s %d %d\n" "UUID=$(blkval 2)" /data "$(blkval 3)" "rw,errors=remount-ro" 0 0 >>/etc/fstab
    printf "%23s %23s %7s %15s %d %d\n" /data/__var__lib__postgresql /var/lib/postgresql none bind 0 0 >>/etc/fstab
    printf "%23s %23s %7s %15s %d %d\n" /data/__home /home none bind 0 0 >>/etc/fstab
fi

### Ansible User
/bin/mkdir /home/ansible/.ssh/
/bin/chmod 700 /home/ansible/.ssh/ ; \
/bin/echo "{{ sshpubkey }}" > /home/ansible/.ssh/authorized_keys ; \
/bin/chmod 600 /home/ansible/.ssh/authorized_keys ; \
/bin/chown -R 999999.999999 /home/ansible/.ssh/

### Sudo Settings
/bin/cat << 'EOF' > /etc/sudoers.d/ansible
Defaults:ansible !requiretty
ansible     ALL=(ALL)       NOPASSWD: ALL
EOF
/bin/chmod 440 /etc/sudoers.d/ansible

### Delete unnecessary users
for u in games list irc proxy backup gnats news; do
    /usr/sbin/userdel $u
done

exit
