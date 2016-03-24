# == Class chronos::params
#
# This class is meant to be called from chronos.
# It sets variables according to platform.
#
class chronos::params {
  $hostname            = false
  $master              = false
  $zk_hosts            = false
  $conf_dir            = '/etc/chronos/conf'
  $http_port           = '4400'
  $manage_package_deps = true
  $force_provider      = undef

  case $::osfamily {
    'Debian': {
      $package_name = 'chronos'
      $service_name = 'chronos'
    }
    'RedHat', 'Amazon': {
      $package_name = 'chronos'
      $service_name = 'chronos'
    }
    default: {
      fail("${::osfamily} not supported")
    }
  }
}
