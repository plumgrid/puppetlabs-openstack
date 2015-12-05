# The profile to set up the neutron server
class openstack::profile::neutron::server {

  openstack::resources::database { 'neutron': }
  openstack::resources::firewall { 'Neutron API': port => '9696', }

  include ::openstack::common::neutron

  $controller_management_address = $::openstack::config::controller_address_management

  if ($::openstack::config::neutron_core_plugin == 'ml2') {

  } elsif ($::openstack::config::neutron_core_plugin == 'plumgrid') {
    $user = $::openstack::config::mysql_user_neutron
    $pass = $::openstack::config::mysql_pass_neutron
    $db_connection = "mysql://${user}:${pass}@${controller_management_address}/neutron"

    if !defined(Package['python-pip']) {
      package { 'python-pip': ensure => present, }
    }

    neutron_config {
      'DEFAULT/service_plugins': ensure => absent,
    }
    ->
    class { '::neutron::plugins::plumgrid':
      director_server              => $::openstack::config::plumgrid_director_vip,
      username                     => $::openstack::config::plumgrid_username,
      password                     => $::openstack::config::plumgrid_password,
      admin_password               => $::openstack::config::keystone_admin_password,
      controller_priv_host         => $controller_management_address,
      connection                   => $db_connection,
      nova_metadata_ip             => $::openstack::config::plumgrid_nova_metadata_ip,
      nova_metadata_port           => $::openstack::config::plumgrid_nova_metadata_port,
      metadata_proxy_shared_secret => $::openstack::config::neutron_shared_secret,
    }
    ->
    package { 'networking-plumgrid':
      ensure   => present,
      provider => 'pip',
      notify   => Service["$::neutron::params::server_service"],
      require  => Package['python-pip'],
    }
  }

  anchor { 'neutron_common_first': } ->
  class { '::neutron::server::notifications':
    nova_url    => "http://${controller_management_address}:8774/v2",
    auth_url    => "http://${controller_management_address}:35357",
    password    => $::openstack::config::nova_password,
    region_name => $::openstack::config::region,
  } ->
  anchor { 'neutron_common_last': }

  Class['::neutron::db::mysql'] -> Exec['neutron-db-sync']
}
