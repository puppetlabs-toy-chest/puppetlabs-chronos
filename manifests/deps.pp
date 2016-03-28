# == Class: chronos::deps
#
# Install the dependencies needed for the "chronos_job" resource.
#
class chronos::deps (
  $package_deps_list     = $chronos::params::package_deps_list,
  $package_deps_manage   = $chronos::params::package_deps_manage,
  $package_deps_ensure   = $chronos::params::package_deps_ensure,
  $package_deps_provider = $chronos::params::package_deps_provider,
) inherits ::chronos::params {
  validate_array($package_deps_list)
  validate_bool($package_deps_manage)
  validate_string($package_deps_ensure)

  if $package_deps_provider {
    validate_string($package_deps_provider)
  }

  if $package_deps_manage {
    package { $package_deps_list :
      ensure   => $package_deps_ensure,
      provider => $package_deps_provider,
    }

    Package[$package_deps_list] ~>
    Chronos_job <||>
  }
}
