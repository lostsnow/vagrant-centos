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

Test
----

```shell
vagrant up
vagrant ssh
```

[1]: https://www.virtualbox.org/wiki/Downloads
[2]: http://www.vagrantup.com/downloads
[3]: http://www.packer.io/downloads.html
[4]: http://isoredirect.centos.org/centos/7/isos/x86_64/