#!/bin/bash
# Disks management for new part
# Retrieve information about the virtual machine storage
lsblk -o NAME,SIZE,MOUNTPOINT
lsblk -P | grep 'TYPE="disk"' # -P is parse for GREP can filter - "global regular expression print."

#Use parted to partition the disk. If necessary, change sdc to your disk name.
sudo parted /dev/sdc --script mklabel gpt mkpart xfspart xfs 0% 100%;

#Use partprobe to inform the operating system of partition table changes. If necessary, change sdc to your disk name.
sudo partprobe /dev/sdc

#Use mkfs to build the Linux file system. If necessary, change sdc to your disk name.
sudo mkfs.xfs /dev/sdc1

#mkdir
sudo mkdir /datadrive

#mount data disk to dir
sudo mount /dev/sdc1 /datadrive

#download azcopy
wget https://aka.ms/downloadazcopy-v10-linux
sudo tar xzf downloadazcopy-v10-linux
sudo mkdir /opt/azcopy
sudo cp ./azcopy_linux_amd64_*/azcopy /opt/azcopy/
