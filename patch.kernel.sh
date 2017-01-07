mv /usr/src/linux-`uname -r` /tmp/.
rm /usr/src/linux
ln -s /tmp/linux-`uname -r` /usr/src/linux


 mkdir /tmp/aufs
 cd /tmp/aufs
 git clone git://github.com/sfjro/aufs4-standalone aufs4-standalone.git
 cd aufs4-standalone.git
 # uncomment line below to get aufs for stable kernel
 git checkout origin/aufs4.4
 # uncomment line below to get aufs for latest -rc kernel
 #git checkout origin/aufs3.x-rcN
 mkdir ../a ../b
 cp -r {Documentation,fs,include} ../b
 rm ../b/include/uapi/linux/Kbuild 2>/dev/null || rm ../b/include/linux/Kbuild
 cd ..
 diff -rupN a/ b/ > /usr/src/linux/aufs.patch
 
 # extra patches:
 cat aufs4-standalone.git/*.patch >> /usr/src/linux/aufs.patch
 
 # cleanup:
 
 cd /usr/src/linux/
 patch -p1 < aufs.patch
 
 
 
 cd /usr/src/linux
 cp /tmp/quantsoft/patch.kernel.config .config
 make menuconfig
 make -j 8 modules bzImage
 
 removepkg /var/log/packages/kernel-huge*
 removepkg /var/log/packages/kernel-generic*
 removepkg /var/log/packages/kernel-modules*
 
 make modules_install
 make headers_install
 
 cp arch/x86_64/boot/bzImage /boot/vmlinuz
 cp .config /boot/config
 cp System.map /boot/.
 cp /tmp/quantsoft/lilo.conf /etc/.
 lilo -c
 
 cd /tmp/aufs/aufs4-standalone.git
 make install
 make install_headers
 
 cd /tmp/aufs
 git clone git://git.code.sf.net/p/aufs/aufs-util aufs-util.git
 cd aufs-util.git
 git checkout origin/aufs4.0
 make
 make install
 
 cd /tmp/aufs
 git clone git://git.code.sf.net/p/squashfs/code squashfs-code
 cd squashfs-code/squashfs-tools
 sed -i -r 's/#XZ_SUPPORT = 1/XZ_SUPPORT = 1/' Makefile
 make
 cp mksquashfs /usr/bin/.
 cp unsquashfs /usr/bin/.
