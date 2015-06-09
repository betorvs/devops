

$partition = 'opt'
$vg = 'oi01'

exec { 'umount':
  command => "/bin/umount /${particion}",
  onlyif => ["/bin/mount |/bin/grep -q opt","/sbin/lvdisplay /dev/mapper/${vg}-${particion} |grep -q '5..... GiB'" ]
}
exec { 'lvremove':
  command => "/sbin/lvremove /dev/mapper/${vg}-${particion}",
  unless => "/sbin/lvdisplay |grep -q ${particion}",
  require => Exec["umount"],
}
exec { 'lvcreate':
  command => "/sbin/lvcreate -n ${particion} --size 4093MB ${vg}",
  unless => "/sbin/lvdisplay /dev/mapper/${vg}-${particion}|grep -q '4.00 GiB'",
  require => Exec["lvremove"],
}
exec { 'mkfs':
  command => "/sbin/mkfs.ext4 /dev/mapper/${vg}-${particion}",
  unless => "/sbin/lvdisplay |grep -q ${particion}",
  require => Exec["lvcreate"],
}
exec { 'mount':
  command => "/bin/mount /${particion}",
  unless => "/bin/grep -q ${particion} /etc/fstab"
  require => Exec["mkfs"],
}
