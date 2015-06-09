

$partition = 'opt'
$vg = 'oi01'

exec { 'umount':
  command => "/bin/umount /${partition}",
  onlyif => ["/bin/mount |/bin/grep -q opt","/sbin/lvdisplay /dev/mapper/${vg}-${partition} |grep -q '8..... GiB'" ]
}
exec { 'lvremove':
  command => "/sbin/lvremove --force /dev/mapper/${vg}-${partition}",
  unless => "/sbin/lvdisplay /dev/mapper/${vg}-${partition}|grep -q '4.00 GiB'",
  require => Exec["umount"],
}
exec { 'lvcreate':
  command => "/sbin/lvcreate -n ${partition} --size 4093MB ${vg}",
  unless => "/sbin/lvdisplay /dev/mapper/${vg}-${partition}|grep -q '4.00 GiB'",
  require => Exec["lvremove"],
}
exec { 'mkfs':
  command => "/sbin/mkfs.ext4 /dev/mapper/${vg}-${partition}",
#  onlyif => "/bin/mount /${partition}", 
  require => Exec["lvcreate"],
}
exec { 'mount':
  command => "/bin/mount /${partition}",
  onlyif => ["/bin/grep -q ${partition} /etc/fstab", "/bin/mount /${partition}"],
  require => Exec["mkfs"],
}
