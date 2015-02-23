class openstack::common::plumgrid {
  $pg_package_ensure        = 'latest'
  $pg_connection            = $::openstack::resources::connectors::neutron
  $pg_director_server       = $::openstack::config::pg_director_server
  $pg_director_server_port  = '443'
  $pg_username              = $::openstack::config::pg_username
  $pg_password              = $::openstack::config::pg_password
  $pg_servertimeout         = '70'
  $pg_enable_metadata_agent = $::openstack::config::pg_enable_metadata_agent
  $admin_password           = $::openstack::config::keystone_admin_password
  $metadata_proxy_secret    = $::openstack::config::neutron_shared_secret
  $controller_priv_host     = $::openstack::config::controller_address_management

  ### PLUMgrid Controller Node Configuration
  if $::openstack::config::pg_controller { 
    class { '::neutron::plugins::plumgrid':
     package_ensure          => $pg_package_ensure,
     pg_connection           => $pg_connection,
     pg_director_server      => $pg_director_server,
     pg_director_server_port => $pg_director_server_port,
     pg_username             => $pg_username,
     pg_password             => $pg_password,
     pg_servertimeout        => $pg_servertimeout,
     pg_enable_metadata_agent=> $pg_enable_metadata_agent,
     admin_password          => $admin_password,
     controller_priv_host    => $controller_priv_host,
    }

    nova_config { 'DEFAULT/scheduler_driver': value => 'nova.scheduler.filter_scheduler.FilterScheduler' }
    nova_config { 'DEFAULT/libvirt_vif_type': value => 'ethernet'}
    nova_config { 'DEFAULT/libvirt_cpu_mode': value => 'none'}

    if $pg_enable_metadata_agent {
      class { '::neutron::agents::metadata' :
        auth_password => $admin_password,
        shared_secret => $metadata_proxy_secret,
        auth_tenant   => 'admin',
        auth_user     => 'admin',
        auth_region   => 'openstack',
      }
    }
  }

  ### PLUMgrid Compute Node Configuration
  if $::openstack::config::pg_compute { 
    include nova::params

    nova_config { 'DEFAULT/scheduler_driver': value => 'nova.scheduler.filter_scheduler.FilterScheduler' }
    nova_config { 'DEFAULT/libvirt_vif_type': value => 'ethernet'}
    nova_config { 'DEFAULT/libvirt_cpu_mode': value => 'none'}

    # forward all ipv4 traffic
    # this is required for the vms to pass through the gateways
    # public interface
    Exec {
      path => $::path
    }

    sysctl::value { 'net.ipv4.ip_forward':
      value => '1'
    }

    # network.filters should only be included in the nova-network node package
    # Reference: https://wiki.openstack.org/wiki/Packager/Rootwrap
    nova::generic_service { 'network.filters':
      package_name   => $::nova::params::network_package_name,
      service_name   => $::nova::params::network_service_name,
    }

    class { 'libvirt':
      qemu_config => {
              cgroup_device_acl => { value => ["/dev/null","/dev/full","/dev/zero",
              "/dev/random","/dev/urandom","/dev/ptmx",
              "/dev/kvm","/dev/kqemu",
              "/dev/rtc","/dev/hpet","/dev/net/tun"] },
               clear_emulator_capabilities => { value => 0 },
               user => { value => "root" },
        },
      libvirtd_config => {
         max_clients => { value => 20 },
       },
    }

    file { "/etc/sudoers.d/ifc_ctl_sudoers":
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => 0440,
      content => "nova ALL=(root) NOPASSWD: /opt/pg/bin/ifc_ctl_pp *\n",
      require => [ Package[$::nova::params::compute_package_name], ],
    }
  }
}
