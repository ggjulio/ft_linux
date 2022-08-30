
# when live cd reboot, here
sudo su -

export LFS=/mnt/lfs

mkdir -p $LFS
mount -v -t ext4 /dev/sdb3 $LFS
mount -v -t ext4 /dev/sdb2 $LFS/boot

/sbin/swapon -v /dev/sdb1 # ensure swap partition is enabled

groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs

passwd lfs # password: ft_linux_42

#BEGIN Only before part 7 ! 
		chown -v lfs $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools}
		case $(uname -m) in
			x86_64) chown -v lfs $LFS/lib64 ;;
		esac

		chown -v lfs $LFS/sources

		su - lfs

		cat > ~/.bash_profile <<-"EOF"
			exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
		EOF

		cat > ~/.bashrc <<-"EOF"
			set +h
			umask 022
			LFS=/mnt/lfs
			LC_ALL=POSIX
			LFS_TGT=$(uname -m)-lfs-linux-gnu
			PATH=/usr/bin
			if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
			PATH=$LFS/tools/bin:$PATH
			CONFIG_SITE=$LFS/usr/share/config.site
			export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
		EOF

		source ~/.bash_profile

		export MAKEFLAGS='-j4' # to parallelize compilation when the host have multiple cpus
#END

#BEGIN ONLY AFTER PART 7

		# remounting and populating /dev
		mount -v --bind /dev $LFS/dev

		# remounting virtual kernel file systems
		mount -v --bind /dev/pts $LFS/dev/pts
		mount -vt proc proc $LFS/proc
		mount -vt sysfs sysfs $LFS/sys
		mount -vt tmpfs tmpfs $LFS/run

		if [ -h $LFS/dev/shm ]; then
			mkdir -pv $LFS/$(readlink $LFS/dev/shm)
		fi

		chroot "$LFS" /usr/bin/env -i   \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin     \
    /bin/bash --login
		
		export MAKEFLAGS='-j4' # to parallelize compilation when the host have multiple cpus
#END
