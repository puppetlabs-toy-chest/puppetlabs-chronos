class chronos::startup::systemd (
  $launcher_path = $chronos::params::launcher_path,
  $jar_file_path = $chronos::params::jar_file_path,
  $service_name  = $chronos::params::service_name,
  $run_user      = $chronos::params::run_user,
  $run_group     = $chronos::params::run_group,
) inherits ::chronos::params {

  File {
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { 'chronos_systemd_unit' :
    path    => "/lib/systemd/system/${service_name}.service",
    content => template('chronos/startup/systemd.unit.erb'),
  }

  File['chronos_systemd_unit'] ~>
  Service <| title == 'chronos' |>

}
