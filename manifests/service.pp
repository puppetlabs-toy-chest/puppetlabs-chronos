# == Class: chronos::service
#
# Manages the Chronos service and configuration.
#
class chronos::service (
  $service_manage   = $chronos::params::service_manage,
  $service_enable   = $chronos::params::service_enable,
  $service_name     = $chronos::params::service_name,
  $service_provider = $chronos::params::service_provider,
) inherits ::chronos::params {
  validate_bool($service_manage)
  validate_bool($service_enable)
  validate_string($service_name)

  if $service_provider {
    validate_string($service_provider)
  }

  if $service_manage {

    if $service_enable {
      $ensure_service = 'running'
    } else {
      $ensure_service = 'stopped'
    }

    service { 'chronos' :
      ensure     => $ensure_service,
      name       => $service_name,
      hasstatus  => true,
      hasrestart => true,
      enable     => $service_enable,
      provider   => $service_provider,
    }

  }

}
