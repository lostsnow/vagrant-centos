Build CentOS 7 Vagrant Box
==========================

Build CentOS 7 Vagrant Box with Packer.

Requirements
------------

* Install [VirtualBox][1]
* Install [Vagrant][2]
* Install [Packer][3]
* Download the [CentOS 7 NetInstall ISO][4] and copy/link it into the repo directory, or auto download from ISO mirror

Build
-----

```shell
cd vagrant-centos
packer build centos7.json
```

### Configuration

 User Variable       | Default Value | Description
---------------------|---------------|----------------------------------------------------------------------------------------
 `disk_size`         | 40000         | [Documentation][5]
 `headless`          | false         | [Documentation][6]
 `memory`            | 512           | Memory size in MB
 `mirror`            |	             | A URL of the ISO mirror, default use local ISO, eg: `http://mirrors.kernel.org/centos/7.2.1511/isos/x86_64/`
 `ssh_timeout`       | 1800s         | SSH connect timeout

```shell
packer build -var headless=true -var disk_size=100000 base/centos7.json
```

Publish
-------

```shell
# create box version and provider
make.sh create -v 0.2.0
# upload box file
make.sh upload -v 0.2.0 -f build/centos-7-x86_64-virtualbox.box
# release box
make.sh release -v 0.2.0
```

Test
----

```shell
# get box
vagrant init lostsnow/centos7
# or
vagrant box add lostsnow/centos7 build/centos-7-x86_64-virtualbox.box

vagrant up
vagrant ssh
```

[1]: https://www.virtualbox.org/wiki/Downloads
[2]: http://www.vagrantup.com/downloads
[3]: http://www.packer.io/downloads.html
[4]: http://isoredirect.centos.org/centos/7/isos/x86_64/
[5]: https://packer.io/docs/builders/virtualbox-iso.html#disk_size
[6]: https://packer.io/docs/builders/virtualbox-iso.html#headless
