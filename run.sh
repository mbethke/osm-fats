#!/bin/sh
if [ -z "$ROOTPW" ]; then
    echo >&2 "ROOTPW" is unset
    exit 1
fi
PLAYBOOK="${1:-playbook-osm.yaml}"
OSMHOST="$(sed -n 's/^- hosts: \(.*\)/\1/p' < "$PLAYBOOK")"
ansible-playbook -i$OSMHOST, "$PLAYBOOK" --extra-vars "rootpwd=$(mkpasswd -m sha-512 "$ROOTPW")"
