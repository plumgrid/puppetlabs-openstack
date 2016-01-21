class openstack::profile::openstack_selinux {

  if($::osfamily == 'Redhat') {
    package { 'openstack-selinux':
      ensure   => present,
    }
  }
}
