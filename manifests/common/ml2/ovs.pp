# Private class
# Set up the OVS agent
class openstack::common::ml2::ovs {
  $type_drivers        = $::openstack::config::neutron_type_drivers # ['gre']
  $tenant_network_type = $::openstack::config::neutron_tenant_network_type # ['gre']
  $mechanism_drivers   = $::openstack::config::neutron_mechanism_drivers # ['openvswitch']
  $tunnel_id_ranges    = $::openstack::config::neutron_tunnel_id_ranges # ['1:1000']
  $data_network        = $::openstack::config::network_data
  $data_address        = ip_for_network($data_network)
  $enable_tunneling    = $::openstack::config::neutron_tunneling # true
  $tunnel_types        = $::openstack::config::neutron_tunnel_types #['gre']

  firewall { '002 gre':
    proto  => 'gre',
    action => 'accept',
  }

  class  { '::neutron::plugins::ml2':
    type_drivers         => $type_drivers,
    tenant_network_types => $tenant_network_type,
    mechanism_drivers    => $mechanism_drivers,
    tunnel_id_ranges     => $tunnel_id_ranges
  }

  class { '::neutron::agents::ml2::ovs':
    enable_tunneling => $enable_tunneling,
    local_ip         => $data_address,
    enabled          => true,
    tunnel_types     => $tunnel_types,
  }
}
