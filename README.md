# BSF local CDN server

Is a cache server that synchronize remote content locally to make it available
 to devices such as Ideascube server.

## Installation

1. Download the [latest version](https://www.armbian.com/olimex-lime-2/) of
   Armbian (Debian version), currently Buster.
2. Burn an SD card and insert it on an OLIMEX Lime 2
3. Attach a big hard drive (~ 2Tb) with a `ext4` partition
4. Grab a very good 5V / 2A power supply
5. Power the board

## Configuration

You can find help on
[Armbian website](https://docs.armbian.com/User-Guide_Getting-Started/) as well.

SSH access:

* login : `root`
* password : `1234`

Launch configuration either with:

```shell
ansible-playbook -l olimex -u root main.yml --extra-vars "country=france project_name=bib"
```

OR

```shell
curl -sfL https://github.com/bibliosansfrontieres/cdn-ideascube/raw/master/go.sh | bash -s -- --country france --project_name bib
```

Finally autorize synchronization on master syncthing server.
