# == Class chronos::install
#
# This class is called from chronos for install.
#
class chronos::install {

  package { $::chronos::package_name:
    ensure => present,
  }
}
