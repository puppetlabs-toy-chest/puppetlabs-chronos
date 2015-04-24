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
  $manage_package_deps = false,
) inherits ::chronos::params {

  # validate parameters here

  if $manage_package_deps {
    $gem_provider = $::puppetversion ? {
      /Puppet Enterprise/ => 'pe-gem',
      default             => 'gem',
    }

    package { 'httparty':
      ensure   => present,
      provider => $gem_provider,
    }

    package { 'json':
      ensure   => present,
      provider => $gem_provider,
    }
  }
}
