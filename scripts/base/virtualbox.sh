#!/bin/bash

set -e
set -x

sudo yum -y install bzip2 kernel-devel make perl dkms

# dkms_autoinstaller that is enabled by default
if systemctl list-unit-files | grep -q dkms.service; then
	sudo systemctl start dkms
	sudo systemctl enable dkms
fi

sudo mount -o loop,ro ~/VBoxGuestAdditions.iso /mnt/
sudo /mnt/VBoxLinuxAdditions.run --nox11 || true
sudo umount /mnt/
rm -f ~/VBoxGuestAdditions.iso
