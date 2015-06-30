# == Class: chronos::service
#
# Manages the Chronos service and configuration.
#
class chronos::service {
  include chronos::params

  $conf_dir     = $chronos::params::conf_dir
  $http_port    = $chronos::http_port
  $hostname     = $chronos::hostname
  $master       = $chronos::master
  $package_name = $chronos::package_name
  $service_name = $chronos::service_name
  $zk_hosts     = $chronos::zk_hosts

  File {
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0660',
  }

  service { $service_name:
    ensure => running,
    enable => true,
  }

  file { $conf_dir:
    ensure  => directory,
    mode    => '0770',
    purge   => true,
    recurse => true,
  }

  file { "${conf_dir}/http_port":
    content => $http_port,
    notify  => Service[$service_name],
  }

  if $chronos::hostname {
    file { "${conf_dir}/hostname":
      content => $hostname,
      notify  => Service[$service_name],
    }
  }

  if $chronos::master {
    file { "${conf_dir}/master":
      content => $master,
      notify  => Service[$service_name],
    }
  }

  if $chronos::zk_hosts {
    file { "${conf_dir}/zk_hosts":
      content => $zk_hosts,
      notify  => Service[$service_name],
    }
  }
}
