# Profile to install the horizon web service
class openstack::profile::horizon {
  $vhost_params = { add_listen => false }

  class { '::horizon':
    allowed_hosts      => concat([ '127.0.0.1', $::openstack::config::controller_address_api, $::fqdn ], $::openstack::config::horizon_allowed_hosts),
    server_aliases     => concat([ '127.0.0.1', $::openstack::config::controller_address_api, $::fqdn ], $::openstack::config::horizon_server_aliases),
    secret_key         => $::openstack::config::horizon_secret_key,
    vhost_extra_params => $vhost_params,
    cache_server_ip    => $::openstack::config::controller_address_management,
    compress_offline   => false,
  }

  openstack::resources::firewall { 'Apache (Horizon)': port => '80' }
  openstack::resources::firewall { 'Apache SSL (Horizon)': port => '443' }

  if $::selinux and str2bool($::selinux) != false {
    selboolean{'httpd_can_network_connect':
      value      => on,
      persistent => true,
    }
  }

}
