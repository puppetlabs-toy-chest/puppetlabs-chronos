# == Class chronos::params
#
# This class is meant to be called from chronos.
# It sets variables according to platform.
#
class chronos::params {
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
