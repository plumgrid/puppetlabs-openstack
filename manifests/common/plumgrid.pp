# Common class used by Plumgrid Neutron Plugin.

class openstack::common::plumgrid {

  $controller_management_address = $::openstack::config::controller_address_management

  # forward all ipv4 traffic
  # this is required for the vms to pass through the gateways public interface
  sysctl::value { 'net.ipv4.ip_forward': value => '1' }

  # ifc_ctl_pp needs to be invoked by root as part of the vif.py when a VM is powered on
  file { '/etc/sudoers.d/ifc_ctl_sudoers':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0440',
    content => 'nova ALL=(root) NOPASSWD: /opt/pg/bin/ifc_ctl_pp *\n',
  }

  openstack::resources::firewall { 'Nova API': port => '8774', }
  openstack::resources::firewall { 'Nova Metadata': port => '8775', }

  class { '::nova::api':
    admin_password                       => $::openstack::config::nova_password,
    auth_host                            => $controller_management_address,
    neutron_metadata_proxy_shared_secret => $::openstack::config::neutron_shared_secret,
    enabled                              => true,
  }
}
