class openstack::profile::openstack_security {

  if($::osfamily == 'Redhat') {
    package { 'openstack-selinux':
      ensure   => present,
    }
  } elsif $::operatingsystem == 'Ubuntu' {

    include ::nova::params

    if($::openstack::profile::base::is_controller) {
      package { 'libvirt':
        ensure => present,
        name   => $::nova::params::libvirt_package_name,
      }
      service { 'libvirt' :
        ensure   => running,
        enable   => true,
        name     => $::nova::params::libvirt_service_name,
        provider => $::nova::params::special_service_provider,
        require  => Package['libvirt'],
      }
    }

    package { 'apparmor-utils':
      ensure   => present,
    }
    package { 'cgroup-bin':
      ensure   => present,
    }

    exec { 'disable apparmor for libvirtd':
      command => '/usr/sbin/aa-disable /usr/sbin/libvirtd',
      creates => '/etc/apparmor.d/disable/usr.sbin.libvirtd',
      require => [ Package['apparmor-utils'], Package['libvirt'] ],
      notify  => Service['libvirt'],
    }
  }
}
