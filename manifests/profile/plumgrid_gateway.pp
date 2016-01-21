# The plumgrid zone profile
class openstack::profile::plumgrid_gateway (
  $plumgrid_ip = '',
  $virtual_ip = '',
  $plumgrid_port = '',
  $rest_port = '',
  $fabric_net = '',
  $fabric_mode = '',
  $gateway_devs = [],
  $lvm_keypath = '',
) inherits ::openstack::role {

  class { '::openstack::profile::firewall': }

  notify {"is_gateway = true":}
  notify {"gateway_devs = ${gateway_devs}":}
  $mgmt_dev                  = device_for_network($::openstack::config::network_management)
  notify {"mgmt_dev = ${mgmt_dev}":}
  $fabric_dev                = device_for_network($fabric_net)
  notify {"fabric_dev = ${fabric_dev}":}

  class { '::plumgrid':
    plumgrid_ip   => $plumgrid_ip,
    plumgrid_port => $plumgrid_port,
    rest_port     => $rest_port,
    mgmt_dev      => $mgmt_dev,
    fabric_dev    => $fabric_dev,
    fabric_mode   => $fabric_mode,
    gateway_devs  => $gateway_devs,
    lvm_keypath   => $lvm_keypath,
    source_net    => $::openstack::config::network_management,
    dest_net      => $::openstack::config::network_management,
  }
}
