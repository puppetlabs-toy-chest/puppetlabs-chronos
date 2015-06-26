# == Class: chronos::install
#
class chronos::install {
  package { $chronos::package_name:
    ensure => installed,
  }
}
