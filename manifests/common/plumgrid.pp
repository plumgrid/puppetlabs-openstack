# Common class used by Plumgrid Neutron Plugin.

class openstack::common::plumgrid {

  $controller_management_address = $::openstack::config::controller_address_management

  # forward all ipv4 traffic
  # this is required for the vms to pass through the gateways public interface
  sysctl::value { 'net.ipv4.ip_forward': value => '1' }

  file { '/etc/nova/rootwrap.d/plumgrid.filters':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => "puppet:///modules/openstack/plumgrid.filters",
  }
}
