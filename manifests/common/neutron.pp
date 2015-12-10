# Common class for neutron installation
# Private, and should not be used on its own
# Sets up configuration common to all neutron nodes.
# Flags install individual services as needed
# This follows the suggest deployment from the neutron Administrator Guide.
class openstack::common::neutron {
  $is_controller = $::openstack::profile::base::is_controller

  $controller_management_address = $::openstack::config::controller_address_management

  $data_network = $::openstack::config::network_data
  $data_address = ip_for_network($data_network)

  # neutron auth depends upon a keystone configuration
  include ::openstack::common::keystone

  $user                = $::openstack::config::mysql_user_neutron
  $pass                = $::openstack::config::mysql_pass_neutron
  $database_connection = "mysql://${user}:${pass}@${controller_management_address}/neutron"


  class { '::neutron':
    rabbit_host           => $controller_management_address,
    core_plugin           => $::openstack::config::neutron_core_plugin,
    allow_overlapping_ips => true,
    rabbit_user           => 'neutron',
    rabbit_password       => $::openstack::config::rabbitmq_password,
    rabbit_hosts          => $::openstack::config::rabbitmq_hosts,
    debug                 => $::openstack::config::debug,
    verbose               => $::openstack::config::verbose,
    service_plugins       => $::openstack::config::neutron_service_plugins,
  }

  class { '::neutron::keystone::auth':
    password     => $::openstack::config::neutron_password,
    public_url   => "http://$::openstack::config::controller_address_api:9696",
    admin_url    => "http://$controller_management_address:9696",
    internal_url => "http://$controller_management_address:9696",
    region       => $::openstack::config::region,
  }

  class { '::neutron::server':
    auth_uri            => "http://$controller_management_address:5000",
    identity_uri        => "http://$controller_management_address:35357",
    auth_password       => $::openstack::config::neutron_password,
    database_connection => $database_connection,
    enabled             => $is_controller,
    sync_db             => $is_controller,
  }

  if $::osfamily == 'redhat' {
    package { 'iproute':
        ensure => latest,
        before => Class['::neutron']
    }
  }
}
