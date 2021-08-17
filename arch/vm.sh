#!/bin/bash

NAME=arch
DISKNAME=disk.vdi
ISO=/Users/richardveitch/Downloads/archlinux-2021.07.01-x86_64.iso

if vboxmanage list vms | grep $NAME
then
    vboxmanage controlvm $NAME poweroff
    while vboxmanage list runningvms | grep $NAME
    do
        echo "Waiting for vm to stop"
        sleep 1
    done

    sleep 2
    vboxmanage unregistervm $NAME --delete || true
fi

if [ -f $DISKNAME ]
then
    OLD_DISK_UUID=$(vboxmanage showmediuminfo disk.vdi | grep ^UUID: | awk '{print $2}')
    vboxmanage closemedium disk $OLD_DISK_UUID --delete
fi

vboxmanage createvm --name $NAME --register
vboxmanage modifyvm $NAME --memory 8192
vboxmanage modifyvm $NAME --vram 256
vboxmanage modifyvm $NAME --graphicscontroller vmsvga
vboxmanage modifyvm $NAME --nic1 nat

vboxmanage createmedium disk --filename $DISKNAME --size 8192 --format VDI --variant fixed
vboxmanage storagectl $NAME --name sata --add sata --bootable on 
vboxmanage storageattach $NAME --storagectl sata --port 0 --type hdd --medium $DISKNAME
vboxmanage storagectl $NAME --name ide --add ide
vboxmanage storageattach $NAME --storagectl ide --port 0 --device 0 --type dvddrive --medium $ISO

vboxmanage setextradata $NAME GUI/ScaleFactor 2



vboxmanage startvm $NAME
