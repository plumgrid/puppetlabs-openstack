define openstack::resources::user (
  $password,
  $tenant,
  $email,
  $admin   = false,
  $enabled = true,
) {

  keystone_role { '_member_':
    ensure => present,
  }

  keystone_user { $name:
    ensure   => present,
    enabled  => $enabled,
    password => $password,
    email    => $email,
  }

  if $admin == true {
    keystone_user_role { "${name}@${tenant}":
      ensure => present,
      roles  => ['_member_', 'admin'],
    }
  } else {
    keystone_user_role { "${name}@${tenant}":
      ensure => present,
      roles  => ['_member_'],
    }
  }
}
