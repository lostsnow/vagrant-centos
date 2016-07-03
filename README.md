Build CentOS 7 Vagrant Box
==========================

Build CentOS 7 Vagrant Box with Packer.

Requirements
------------

* Install [VirtualBox][1]
* Install [Vagrant][2]
* Install [Packer][3]
* Download the [CentOS 7 NetInstall ISO][4] and copy/link it into the repo directory

Build
-----

```shell
cd vagrant-centos
packer build base/centos7.json
```

Publish
-------

```
# create box version and provider
make.sh create -v 0.1.0
# upload box file
make.sh upload -v 0.1.0 -f build/centos-7-x86_64-virtualbox-base.box
# release box
make.sh release -v 0.1.0
```

Test
----

```shell
# get box
vagrant init lostsnow/centos7
# or
vagrant box add build/centos-7-x86_64-virtualbox-base.box

vagrant up
vagrant ssh
```

[1]: https://www.virtualbox.org/wiki/Downloads
[2]: http://www.vagrantup.com/downloads
[3]: http://www.packer.io/downloads.html
[4]: http://isoredirect.centos.org/centos/7/isos/x86_64/