class openstack::role::compute inherits ::openstack::role {
  class { '::openstack::profile::firewall': }
  class { '::openstack::profile::openstack_security': } ->
  class { '::openstack::profile::neutron::agent': } ->
  class { '::openstack::profile::nova::compute': }
}
