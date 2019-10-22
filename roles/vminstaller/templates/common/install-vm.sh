#!/bin/bash

###
### vm-installer
### (c) Copuryght 2016, VanTosh
### Author: Toshaan Bharvani <toshaan@vantosh.com>
### License : BSD
###


if [ ! -f /etc/libvirt/qemu/{{ inventory_hostname }}.xml ]; then

virt-install \
{% if virtualmachinetype is defined %}
    --machine={{ virtualmachinetype }} \
{% endif %}
    --name={{ inventory_hostname_short }} \
{% if virtualcputype is defined %}
    --cpu={{ virtualcputype }} \
{% endif %}
{% if ( virtualsockets is defined and virtualcores is defined and virtualthreads is defined ) %}
    {% set vcpus = virtualsockets * virtualcores * virtualthreads %}
    --vcpus={{ vcpus }},sockets={{ virtualsockets }},cores={{ virtualcores }},threads={{ virtualthreads }} \
{% else %}
    --vcpus={{ virtualcpus }} \
{% endif %}
{% if virtualcpuset is defined %}
    --cpuset={{ cpuset }} \
{% endif %}
{% if minram is defined and ramsize < minram %}
    --ram={{ minram }} \
{% else %}
    --ram={{ ramsize }} \
{% endif %}
    --hvm \
    --accelerate \
    --os-variant=auto \
{% set bootorder = 1 %}
{% if disks is defined %}
{% if machinearch is defined %}
{% if ( machinearch == 'ppc64' or machinearch == 'ppc64le' or machinearch == 'ppc64el' or machinearch == 'powerpc' ) %}
{#% set disks = disks|reverse %#}
{% endif %}
{% endif %}
{% if isofile is defined %}
--disk path={{ virtualfilespath }}/{{ isofile }},device=cdrom,boot_order={{ bootorder }}  \
{% set bootorder = bootorder + 1 %}
{% endif %}
{% for disk in disks %}
    {% if disk.size[-1:] == 'T' %}
        {% set disk_size = (disk.size[:-1]|float) * 1024 %}
    {% elif disk.size[-1:] == 'G' %}
        {% set disk_size = (disk.size[:-1]|float) %}
    {% elif disk.size[-1:] == 'M' %}
        {% set disk_size = (disk.size[:-1]|float) / 1024 %}
    {% elif disk.size[-1:] == 'K' %}
        {% set disk_size = (disk.size[:-1]|float) / 1024 / 1024 %}
    {% else %}
        {% set disk_size = (disk.size[:-1]|float) %}
    {% endif %}
    {% if disk.bootorder is defined %}
    {% set disk_bootorder = disk.bootorder %}
    {% else %}
    {% set disk_bootorder = bootorder %}
    {% endif %}
{% if disk.bus is defined %}
{% set diskbus = disk.bus %}
{% else %}
{% set diskbus = 'virtio' %}
{% endif %}
{% if installisos is defined %}
--disk path={{ disk.path }},device=disk,size={{ disk_size }},cache=none,format=qcow2,io=native,bus={{ diskbus }}  \
{% else %}
{% if disk.device is defined %}
--disk path={{ disk.device }},device=disk,cache=none,io=native,bus={{ diskbus }},boot_order={{ disk_bootorder }} \
{% elif disk.pool is defined %}
--disk pool={{ disk.pool }},device=disk,size={{ disk_size }},format=qcow2,cache=none,io=native,bus={{ diskbus }},boot_order={{ disk_bootorder }},sparse=false \
{% else %}
--disk path={{ disk.path }},device=disk,size={{ disk_size }},format=qcow2,cache=none,io=native,bus={{ diskbus }},boot_order={{ disk_bootorder }},sparse=false \
{% endif %}
{% endif %}
    {% set bootorder = bootorder + 1 %}
{% endfor %}
{% endif %}
{% if installisos is defined %}
{% for installiso in installisos %}
--disk path={{ installiso }},device=cdrom \
{% endfor %}
{% if autounattend is defined %}
    --disk path={{ virtualfilespath }}{{ inventory_hostname }}-autounattend-disk.vusb,device=floppy \
{% endif %}
    --boot cdrom,menu=off,useserial=on \
    --force \
{% endif %}
{% if disk is not defined and installisos is not defined %}
    --disk none \
{% endif %}
{% if machinearch is defined %}
{% if ( machinearch == 'ppc64' or machinearch == 'ppc64le' or machinearch == 'ppc64el' or machinearch == 'powerpc' ) %}
{#{% set nics = nics|reverse %}#}
{% endif %}
{% endif %}
{% for nic in nics %}
{% if nic.type is defined %}
{% if nic.type == "bridge" or nic.type == "network" %}
    --network {{ nic.type }}={{ nic.name }},model={{ nic.model }}{% if nic.mac is defined -%},mac={{ nic.mac }}{% endif %} \
{% endif %}
{% endif %}
{% endfor %}
{% if location is defined %}
    --location={{ location }} \
    --initrd-inject={{ virtualfilespath }}vminstall_post_preseed_{{ inventory_hostname }}.sh \
{#    --boot hd,menu=off \ #}
{% if injectfile is defined %}
    --initrd-inject={{ virtualfilespath }}{{ injectfile }} \
{% elif autoyastfile %}
    --initrd-inject={{ virtualfilespath }}{{ autoyastfile }} \
{% else %}
    --initrd-inject={{ virtualfilespath }}{{ inventory_hostname }}.cfg \
{% endif %}
{% endif %}
{% if graphics is defined %}--extra-args "{{ gextrargs }}{% else -%}--extra-args "{{ textrargs }}{% endif -%}{% if kickstartdevice is defined %} ksdevice={{ kickstartdevice }}{% endif %}" \
    --memballoon virtio \
{% if graphics is defined %}
{% if tlsport is defined %}
    --graphics {{ graphics.type }},port={{ graphics.port }},tlsport={{ graphics.tlsport }}{% if graphics.password is defined -%},password={{ graphics.password }}{% endif  %} --channel spicevmc \
{% else %}
    --graphics {{ graphics.type }},port={{ graphics.port }}{% if graphics.password is defined -%},password={{ graphics.password }}{% endif  %} --channel spicevmc \
{% endif %}
{% else %}
    --nographics \
{% endif %}
    --noautoconsole

else

echo "The VM is already defined"

fi
