# == Class: chronos::install
#
# Install the Chronos package.
#
class chronos::install (
  $package_name          = $chronos::params::package_name,
  $package_manage        = $chronos::params::package_manage,
  $package_ensure        = $chronos::params::package_ensure,
  $package_provider      = $chronos::params::package_provider,
) inherits chronos::params {
  validate_string($package_name)
  validate_bool($package_manage)
  validate_string($package_ensure)

  if $package_provider {
    validate_string($package_provider)
  }

  if $package_manage {
    package { 'chronos' :
      ensure   => $package_ensure,
      name     => $package_name,
      provider => $package_provider,
    }

    Package['chronos'] ~>
    Service <| title == 'chronos' |>
  }
}
