# == Class chronos::service
#
# This class is meant to be called from chronos.
# It ensure the service is running.
#
class chronos::service {

  service { $::chronos::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
