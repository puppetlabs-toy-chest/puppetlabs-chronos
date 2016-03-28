# == Class: chronos
#
# Manage Chronos installation, configuration, and jobs.
#
class chronos (
  $package_name          = $chronos::params::package_name,
  $package_manage        = $chronos::params::package_manage,
  $package_ensure        = $chronos::params::package_ensure,
  $package_provider      = $chronos::params::package_provider,

  $package_deps_list     = $chronos::params::package_deps_list,
  $package_deps_manage   = $chronos::params::package_deps_manage,
  $package_deps_ensure   = $chronos::params::package_deps_ensure,
  $package_deps_provider = $chronos::params::package_deps_provider,

  $service_name          = $chronos::params::service_name,
  $service_manage        = $chronos::params::service_manage,
  $service_enable        = $chronos::params::service_enable,
  $service_provider      = $chronos::params::service_provider,

  $zk_servers            = $chronos::params::zk_servers,
  $zk_chronos_servers    = $chronos::params::zk_chronos_servers,
  $zk_default_port       = $chronos::params::zk_default_port,
  $zk_mesos_path         = $chronos::params::zk_mesos_path,

  $libprocess_ip         = $chronos::params::libprocess_ip,

  $java_opts             = $chronos::params::java_opts,
  $java_home             = $chronos::params::java_home,

  $mesos_principal       = $chronos::params::mesos_principal,
  $mesos_secret          = $chronos::params::mesos_secret,

  $secret_file_path      = $chronos::params::secret_file_path,

  $config_base_path      = $chronos::params::config_base_path,
  $config_dir_path       = $chronos::params::config_dir_path,
  $config_file_path      = $chronos::params::config_file_path,
  $config_file_mode      = $chronos::params::config_file_mode,

  $startup_manage        = $chronos::params::startup_manage,
  $startup_system        = $chronos::params::startup_system,
  $launcher_manage       = $chronos::params::launcher_manage,
  $launcher_path         = $chronos::params::launcher_path,
  $jar_file_path         = $chronos::params::jar_file_path,
  $run_user              = $chronos::params::run_user,
  $run_group             = $chronos::params::run_group,

  $options               = $chronos::params::options,
) inherits ::chronos::params {

  class { '::chronos::install':
    package_name          => $package_name,
    package_manage        => $package_manage,
    package_ensure        => $package_ensure,
    package_provider      => $package_provider,
  }

  class { '::chronos::config':
    zk_servers            => $zk_servers,
    zk_chronos_servers    => $zk_chronos_servers,
    zk_default_port       => $zk_default_port,
    zk_mesos_path         => $zk_mesos_path,

    libprocess_ip         => $libprocess_ip,

    mesos_principal       => $mesos_principal,
    mesos_secret          => $mesos_secret,

    secret_file_path      => $secret_file_path,

    config_base_path      => $config_base_path,
    config_dir_path       => $config_dir_path,
    config_file_path      => $config_file_path,
    config_file_mode      => $config_file_mode,

    java_opts             => $java_opts,
    java_home             => $java_home,

    options               => $options,
  }

  class { '::chronos::deps':
    package_deps_list     => $package_deps_list,
    package_deps_manage   => $package_deps_manage,
    package_deps_ensure   => $package_deps_ensure,
    package_deps_provider => $package_deps_provider,
  }

  class { '::chronos::startup' :
    launcher_manage => $launcher_manage,
    launcher_path   => $launcher_path,
    startup_manage  => $startup_manage,
    startup_system  => $startup_system,
    jar_file_path   => $jar_file_path,
    service_name    => $service_name,
    run_user        => $run_user,
    run_group       => $run_group,
  }

  class { '::chronos::service':
    service_name          => $service_name,
    service_manage        => $service_manage,
    service_enable        => $service_enable,
    service_provider      => $service_provider,
  }

  contain 'chronos::install'
  contain 'chronos::config'
  contain 'chronos::deps'
  contain 'chronos::startup'
  contain 'chronos::service'

  Class['chronos::install'] ->
  Class['chronos::deps'] ->
  Class['chronos::config'] ->
  Class['chronos::startup'] ->
  Class['chronos::service']

}
