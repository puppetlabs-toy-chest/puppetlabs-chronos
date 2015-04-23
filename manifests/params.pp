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
      $provider = $::puppetversion ? {
        /.*Enterprise.*/ => 'pe-gem',
        default => 'gem',
      }
    }
    'RedHat', 'Amazon': {
      $package_name = 'chronos'
      $service_name = 'chronos'
      $provider = $::puppetversion ? {
        /.*Enterprise.*/ => 'pe-gem',
        default => 'gem',
      }
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
