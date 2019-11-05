#!/bin/sh
if [ -z "$ROOTPW" ]; then
    echo >&2 "ROOTPW" is unset
    exit 1
fi
OSMHOST="$(sed -n 's/^- hosts: \(.*\)/\1/p' < playbook-osm.yaml)"
ansible-playbook -i$OSMHOST, playbook-osm.yaml --extra-vars "rootpwd=$(mkpasswd -m sha-512 "$ROOTPW")"
