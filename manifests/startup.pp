# == Class: chronos::startup
#
# Manages the startup files for the Chronos service
class chronos::startup (
  $startup_manage  = $chronos::params::startup_manage,
  $launcher_manage = $chronos::params::launcher_manage,
  $launcher_path   = $chronos::params::launcher_path,
  $jar_file_path   = $chronos::params::jar_file_path,
  $service_name    = $chronos::params::service_name,
  $startup_system  = $chronos::params::startup_system,
  $run_user        = $chronos::params::run_user,
  $run_group       = $chronos::params::run_group,
) inherits ::chronos::params {
  validate_string($service_name)
  validate_absolute_path($launcher_path)
  validate_bool($startup_manage)
  validate_bool($launcher_manage)

  if $jar_file_path {
    validate_absolute_path($jar_file_path)
  }

  File {
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  if $startup_manage {

    if $startup_system == 'upstart' {

      class { 'chronos::startup::upstart' :
        launcher_path => $launcher_path,
        jar_file_path => $jar_file_path,
        service_name  => $service_name,
        run_user      => $run_user,
        run_group     => $run_group,
      }

      contain 'chronos::startup::upstart'

    } elsif $startup_system == 'systemd' {

      class { 'chronos::startup::systemd' :
        launcher_path => $launcher_path,
        jar_file_path => $jar_file_path,
        service_name  => $service_name,
        run_user      => $run_user,
        run_group     => $run_group,
      }

      contain 'chronos::startup::systemd'

    }

  }

  if $launcher_manage {

    file { 'chronos_launcher_file' :
      path    => $launcher_path,
      content => template('chronos/launcher.sh.erb'),
      mode    => '0755',
    }

    File['chronos_launcher_file'] ~>
    Service <| title == 'chronos' |>

  }

}
