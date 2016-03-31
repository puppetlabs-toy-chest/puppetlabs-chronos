class chronos::startup::upstart (
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

  file { 'chronos_upstart_file' :
    path    => "/etc/init/${service_name}.conf",
    content => template('chronos/startup/upstart.conf.erb'),
  }

  file { 'chronos_init.d_wrapper' :
    ensure => 'symlink',
    path   => "/etc/init.d/${service_name}",
    target => '/lib/init/upstart-job',
  }

  File['chronos_upstart_file'] ~>
  Service <| title == 'chronos' |>

  File['chronos_init.d_wrapper'] ~>
  Service <| title == 'chronos' |>

}
