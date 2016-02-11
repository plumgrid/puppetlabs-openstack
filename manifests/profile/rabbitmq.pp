# The profile to install rabbitmq and set the firewall
class openstack::profile::rabbitmq {
  $management_address = $::openstack::config::controller_address_management

  include erlang

  rabbitmq_user { ['neutron', 'nova', 'cinder', 'glance']:
    admin    => true,
    password => $::openstack::config::rabbitmq_password,
    provider => 'rabbitmqctl',
    require  => Class['::rabbitmq'],
  }
  rabbitmq_user_permissions {  ['neutron@/', 'nova@/', 'cinder@/', 'glance@/']:
    configure_permission => '.*',
    write_permission     => '.*',
    read_permission      => '.*',
    provider             => 'rabbitmqctl',
  }->Anchor<| title == 'nova-start' |>

  class { '::rabbitmq':
    service_ensure    => 'running',
    port              => 5672,
    delete_guest_user => true,
    default_user      => $::openstack::config::rabbitmq_user,
    default_pass      => $::openstack::config::rabbitmq_password,
  }
  rabbitmq_vhost { '/':
    provider => 'rabbitmqctl',
    require  => Class['::rabbitmq'],
  }

  #https://bugzilla.redhat.com/show_bug.cgi?id=505266
  if $::osfamily == 'RedHat' {
    if !defined(Package['fprintd-pam']) {
      package { 'fprintd-pam':
        ensure => present,
        before => Class['::rabbitmq'],
      }
    }
  }
}
