#!/bin/bash

# change to normal user for tce-load to work
su tc

# for sfdisk
tce-load -w -i util-linux.tcz

# for virtualbox
tce-load -w -i linux-headers-3.0.21-tinycore.tcz

# tce-load -w -i ruby.tcz

# rvm dependencies
#tce-load -w -i gcc.tcz
#tce-load -w -i curl.tcz
#tce-load -w -i git.tcz
#tce-load -w -i patch.tcz
#tce-load -w -i readline.tcz
#tce-load -w -i zlib.tcz
#tce-load -w -i libyaml.tcz
#tce-load -w -i iconv.tcz
#tce-load -w -i libxml1.tcz
#tce-load -w -i libxslt.tcz


exit  # back to root user

echo "enough for now!"

date > /etc/vagrant_box_build_time

#Based on http://www.tcl.org/doc/en/gentoo-x86-quickinstall.xml


#Partition the disk
#This assumes a predefined layout - customize to your own liking

#/boot -> /dev/sda1
#swap -> /dev/sda2
#root -> /dev/sda3
 
sfdisk --force /dev/sda <<EOF
# partition table of /dev/sda
unit: sectors

/dev/sda1 : start=     2048, size=   409600, Id=83
/dev/sda2 : start=   411648, size=  2097152, Id=82
/dev/sda3 : start=  2508800, size= 18257920, Id=83
/dev/sda4 : start=        0, size=        0, Id= 0
EOF

sleep 2

#Format the /boot
mke2fs /dev/sda1

#Main partition /
mke2fs -j /dev/sda3

#Format the swap and use it
mkswap /dev/sda2
swapon /dev/sda2

#Mount the new disk
mkdir /mnt/tcl
mount /dev/sda3 /mnt/tcl
mkdir /mnt/tcl/boot
mount /dev/sda1 /mnt/tcl/boot
cd /mnt/tcl

#Note: we retry as sometimes mirrors fail to have the files

#Download a stage3 archive
while true; do
	wget ftp://distfiles.tcl.org/gentoo/releases/x86/current-stage3/stage3-i686-*.tar.bz2 && > gotstage3
        if [ -f "gotstage3" ]
        then
		break
	else
		echo "trying in 2seconds"
		sleep 2
        fi
done
tar xjpf stage3*

#Download Portage snapshot
cd /mnt/tcl/usr
while true; do
	wget http://distfiles.tcl.org/snapshots/portage-latest.tar.bz2 && > gotportage
        if [ -f "gotportage" ]
        then
		break
	else
		echo "trying in 2seconds"
		sleep 2
	fi
done

tar xjf portage-lat*

#Chroot
cd /
mount -t proc proc /mnt/tcl/proc
mount --rbind /dev /mnt/tcl/dev
cp -L /etc/resolv.conf /mnt/tcl/etc/
echo "env-update && source /etc/profile" | chroot /mnt/tcl /bin/bash -

# Get the kernel sources
# echo "emerge tcl-sources" | chroot /mnt/gentoo /bin/bash -

# We will use genkernel to automate the kernel compilation
# http://www.tcl.org/doc/en/genkernel.xml
# echo "emerge grub" | chroot /mnt/tcl /bin/bash -
# echo "emerge genkernel" | chroot /mnt/tcl /bin/bash -
# echo "genkernel --bootloader=grub --real_root=/dev/sda3 --no-splash --install all" | chroot /mnt/tcl /bin/bash -

cat <<EOF | chroot /mnt/tcl /bin/bash -
cat <<FSTAB > /etc/fstab
/dev/sda1   /boot     ext2    noauto,noatime     1 2
/dev/sda3   /         ext3    noatime            0 1
/dev/sda2   none      swap    sw                 0 0
FSTAB
EOF


#We need some things to do here
#Network
cat <<EOF | chroot /mnt/tcl /bin/bash -
cd /etc/conf.d
echo 'config_eth0=( "dhcp" )' >> net
#echo 'dhcpd_eth0=( "-t 10" )' >> net
#echo 'dhcp_eth0=( "release nodns nontp nois" )' >> net
rc-update add net.eth0 default
#Module?
rc-update add sshd default
EOF

#Root password

# Cron & Syslog
# echo "emerge syslog-ng vixie-cron" | chroot /mnt/tcl sh -
# echo "rc-update add syslog-ng default" | chroot /mnt/tcl sh -
# echo "rc-update add vixie-cron default" | chroot /mnt/tcl sh -

#Get an editor going
# echo "emerge vim" | chroot /mnt/tcl sh -

#Allow external ssh
echo "echo 'sshd:ALL' > /etc/hosts.allow" | chroot /mnt/tcl sh -
echo "echo 'ALL:ALL' > /etc/hosts.deny" | chroot /mnt/tcl sh -

#create vagrant user  / password vagrant
chroot /mnt/tcl useradd -m -r vagrant -p '$1$MPmczGP9$1SeNO4bw5YgiEJuo/ZkWq1'

#Configure Sudo
# chroot /mnt/tcl emerge sudo
echo "echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers" | chroot /mnt/tcl sh -

#Installing vagrant keys
# chroot /mnt/tcl emerge wget 

echo "creating vagrant ssh keys"
chroot /mnt/tcl mkdir /home/vagrant/.ssh
chroot /mnt/tcl chmod 700 /home/vagrant/.ssh
chroot /mnt/tcl cd /home/vagrant/.ssh
chroot /mnt/tcl wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O /home/vagrant/.ssh/authorized_keys
chroot /mnt/tcl chmod 600 /home/vagrant/.ssh/authorized_keys
chroot /mnt/tcl chown -R vagrant /home/vagrant/.ssh

#This could be done in postinstall
#reboot

#get some ruby running
# chroot /mnt/tcl emerge git curl gcc automake  m4
# chroot /mnt/tcl emerge libiconv readline zlib openssl curl git libyaml sqlite libxslt
# echo "bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)"| chroot /mnt/tcl /bin/bash -
# echo "/usr/local/rvm/bin/rvm install ruby-1.8.7 "| chroot /mnt/tcl sh -
# echo "/usr/local/rvm/bin/rvm use ruby-1.8.7 --default "| chroot /mnt/tcl sh -

#Installing chef & Puppet
# echo ". /usr/local/rvm/scripts/rvm ; gem install chef --no-ri --no-rdoc"| chroot /mnt/tcl sh -
# echo ". /usr/local/rvm/scripts/rvm ; gem install puppet --no-ri --no-rdoc"| chroot /mnt/tcl sh -


# echo "adding rvm to global bash rc"
# echo "echo '. /usr/local/rvm/scripts/rvm' >> /etc/bash/bash.rc" | chroot /mnt/tcl sh -

/bin/cp -f /root/.vbox_version /mnt/tcl/home/vagrant/.vbox_version
VBOX_VERSION=$(cat /root/.vbox_version)

#Kernel headers
# chroot /mnt/tcl emerge linux-headers

#Installing the virtualbox guest additions
cat <<EOF | chroot /mnt/tcl /bin/bash -
cd /tmp
mkdir /mnt/vbox
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt/vbox
sh /mnt/vbox/VBoxLinuxAdditions.run
#umount /mnt/vbox
#rm VBoxGuestAdditions_$VBOX_VERSION.iso
EOF

echo "sed -i 's:^DAEMONS\(.*\))$:DAEMONS\1 rc.vboxadd):' /etc/rc.conf" | chroot /mnt/tcl sh -

exit
cd /
umount /mnt/tcl/{proc,sys,dev}
umount /mnt/tcl

reboot
