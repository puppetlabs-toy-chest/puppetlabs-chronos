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
) inherits ::chronos::params {

  # validate parameters here

  class { '::chronos::install': } ->
  class { '::chronos::config': } ~>
  class { '::chronos::service': } ->
  Class['::chronos']
}
