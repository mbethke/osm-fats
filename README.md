# Fully Automated Tile Server

This Ansible playbook installs an OSM tile server from the ground up, from
setting up a virtual machine to installing the software, style sheets and data.

## Preparations

You'll need `mkpasswd` installed locally to hash the root password. Also,
`pwgen` is required locally for generating a random database password unless
you're setting your own. 

Other than that, your new VM must have an IP address and associated hostname,
either via DNS or at least in your workstation's `hosts` file, so ansible can
reach it once it's up.

## Configuration

All configuration except for the root account's password happens in the
`playbook-osm.yaml` file. Here are the things you *have* to adjust (everything
but `hosts` is found in the `vars` section):

* `hosts`: the host name of your prospective tile server. This is supposed to
  take an array but only a single hostname makes sense here.
* `hyper`: the hypervisor that is supposed to run this VM.
* `hostname` and `domainname`: just like `hosts`
* `name`, `ip`, `netmask`, `gateway`, `nameserver` and `mac` under `nics`.
  `name` is the name of the bridge on the hypervisor to connect the VM's `eth0`
  interface to; everything else should be obvious. If you have a different kind
  of network configuration, read the `vminstaller` role on how to set that up.

You probably *should* tweak the following:

* `virtualcpus` and `ramsize` to match what your hypervisor can spare
* `timezone`, obviously
* Set `disks` to match the hardware of your hypervisor. Here, `/dev/md127` is my
  SSD, and the only virsh pool is called `virtimages`.
* Adjust `partitions` accordingly. You'll have to read up on the weird format
  expected by Debian's preseed.
* `osm_psql_password`: although the playbook can generate its own password, setting
  your own means less possibilities to screw things up if you have to re-run the
  setup later.
* `download_planet`: st to `yes` to download the lastest planet file from BBBike
  (I find this to be ususally much faster than Geofabrik's server; change
  `planet_url` if you disagree) as part of the setup process.
* `download_regions`: this will be ignored if `download_planet` is set, otherwise
  add your desired regions here. This is just a partial URL on the Geofabrik
  download server.
* `psql_tuning`: this is highly dependent on your hardware so changing it is
  usually required. All arguments are just passed to the ansible module
  `postgresql_set`, so you can set whatever parameter you want here. Note that
  it is usually recommended to disable autovacuum when importing the planet, but
  my disk is too small so I leave it on and only run it once every 30 min.
* `renderd_tuning`: as above, match your CPUs and expected workload.
  
You *might* want to change those:

* `sshpubkey`: I just get this from the account running the setup
* `gis_dbname` and `osm_username`, if you don't like the defaults for some
  reason
* `styles`: delete at most one from the list, or tweak the version when a new
  one is released. Adding a new one will need a new task in `roles/osm`, too.
* `use_postgresql_11`: will use the PostgreSQL dev's repository to get the newer
  version. This definitely doesn't work with the `carto-de` style due to a
  missing extension but *might* work with plain `carto`. I tried to use it
  before but as I really need carto-de, I haven't tested much.

## Running

After configuring the playbook variables, set `$ROOTPW` to the password for the
VM's root account and call `run.sh`:

```
ROOTPW="correct horse battery staple" ./run.sh"
```

When ansible is done, you are left with a running and configured VM but no live
database. This last step can take many hours and is thus left to a shell script
that gives you the usual progress indicators of `osm2pgsql` etc. instead of only
one block of output once it's done as you'd get from ansible. If you are
downloading smaller regions, this should work:

```
ssh ansible@myosmhost 'sudo -iuosm '~osm/import.sh /var/tmp/osm/*.pbf; sudo service renderd restart'
```

When importing the entire planet, it is advisable to run `sudo -iuosm
'~osm/import.sh /var/tmp/osm/*.pbf` under *tmux* (or *screen* if you prefer it
oldschool) so as not to break it if your connection should drop. 

## Misc

Note that occasionally the installation may abort with an error similar to the
following appearing on the VM's console:

    in-target: Some packages could not be installed. This may mean that you have
    in-target: requested an impossible situation or if you are using the unstable
    in-target: distribution that some required packages have not yet been created
    in-target: or been moved out of Incoming.
    in-target: The following information may help to resolve the situation:
    in-target:
    in-target: The following packages have unmet dependencies:
    in-target:  linux-generic : Depends: linux-image-generic (= 4.15.0.68.70) but it is not going to be installed

    in-target: Setting up linux-headers-generic (4.15.0.68.70) ...^M
    base-installer: error: exiting on error base-installer/kernel/failed-install
    main-menu[3869]: WARNING **: Configuring 'bootstrap-base' failed with error code 1
    main-menu[3869]: WARNING **: Menu item 'bootstrap-base' failed.

This is not a problem of the installer but of inconsistent information on the
Ubuntu mirrors. Simply wait for the mirror to fully synchronize and retry.

## TODO

* Add jobs for timely updates
* Support more map styles
* Vector tiles
