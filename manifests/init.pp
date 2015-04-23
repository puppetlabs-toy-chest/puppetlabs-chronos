# == Class: chronos
#
# Full description of class chronos here.
#
# === Parameters
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#
class chronos (
  $package_name = $::chronos::params::package_name,
  $service_name = $::chronos::params::service_name,
  $provider     = $::chronos::params::provider,
  $manage_package_deps = false,
) inherits ::chronos::params {

  # validate parameters here

  if $manage_package_deps {
    package { 'httparty':
      ensure   => present,
      provider => $provider,
    }
    package { 'json':
      ensure   => present,
      provider => $provider,
    }
  }
}
