# The plumgrid zone profile
class openstack::profile::plumgrid (
  $plumgrid_ip = '',
  $virtual_ip = '',
  $plumgrid_port = '',
  $rest_port = '',
  $fabric_net = '',
  $fabric_mode = '',
  $lvm_keypath = '',
) inherits ::openstack::role {

  $node_addresses_management = ip_for_network($::openstack::config::network_management)
  $node_address_management   = join(unique(delete($node_addresses_management, $virtual_ip)), '')
  $director_ips              = split($plumgrid_ip, ',')
  $is_director               = ($node_address_management in $director_ips)
  notify {"is_director = ${is_director}":}
  $mgmt_dev                  = device_for_network($::openstack::config::network_management)
  notify {"mgmt_dev = ${mgmt_dev}":}
  $fabric_dev                = device_for_network($fabric_net)
  notify {"fabric_dev = ${fabric_dev}":}

  class { ::plumgrid:
    plumgrid_ip   => $plumgrid_ip,
    plumgrid_port => $plumgrid_port,
    rest_port     => $rest_port,
    mgmt_dev      => $mgmt_dev,
    fabric_dev    => $fabric_dev,
    fabric_mode   => $fabric_mode,
    lvm_keypath   => $lvm_keypath,
    source_net    => $::openstack::config::network_management,
    dest_net      => $::openstack::config::network_management,
  }
  if ($is_director) {
    class { ::sal:
      plumgrid_ip => $plumgrid_ip,
      virtual_ip  => $virtual_ip,
      rest_port   => $rest_port,
      mgmt_dev    => $mgmt_dev,
      source_net  => $::openstack::config::network_management,
    }
  }
}
