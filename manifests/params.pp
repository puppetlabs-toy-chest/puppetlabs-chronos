# == Class chronos::params
#
# This class is meant to be called from chronos.
# It sets variables according to platform.
#
class chronos::params {
  $package_manage        = true
  $package_ensure        = 'present'
  $package_provider      = undef

  $package_deps_list     = ['httparty', 'json']
  $package_deps_manage   = true
  $package_deps_ensure   = 'present'

  $package_deps_provider = $::puppetversion ? {
    /Puppet Enterprise/ => 'pe_gem',
    default             => 'gem',
  }

  $service_manage        = true
  $service_enable        = true
  $service_provider      = undef

  $zk_servers            = ['localhost']
  $zk_chronos_servers    = undef
  $zk_default_port       = '2181'
  $zk_mesos_path         = 'mesos'

  $libprocess_ip         = '127.0.0.1'

  $mesos_principal       = undef
  $mesos_secret          = undef

  $secret_file_path      = '/etc/chronos/auth_secret'

  $config_base_path      = '/etc/chronos'
  $config_dir_path       = '/etc/chronos/conf'
  $config_file_mode      = '0640'

  $startup_manage        = false
  $startup_system        = undef
  $launcher_manage       = false
  $launcher_path         = '/usr/bin/chronos'
  $jar_file_path         = undef
  $run_user              = undef
  $run_group             = undef

  $options               = { }

  case $::osfamily {
    'Debian': {
      $package_name     = 'chronos'
      $service_name     = 'chronos'
      $config_file_path = '/etc/default/chronos'
    }
    'RedHat', 'Amazon': {
      $package_name     = 'chronos'
      $service_name     = 'chronos'
      $config_file_path = '/etc/sysconfig/chronos'
    }
    default: {
      warning("${::osfamily} is not supported! But you can manually configure all parameters or use the default values.")
      $package_name     = 'chronos'
      $service_name     = 'chronos'
      $config_file_path = '/etc/chronos/config.sh'
    }
  }

  $java_opts = '-Xmx512m'
  $java_home = undef

}
