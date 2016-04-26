# == Class: chronos::config
#
# Create the Chronos configuration
#
class chronos::config (
  $zk_servers            = $chronos::params::zk_servers,
  $zk_chronos_servers    = $chronos::params::zk_chronos_servers,
  $zk_default_port       = $chronos::params::zk_default_port,
  $zk_mesos_path         = $chronos::params::zk_mesos_path,

  $libprocess_ip         = $chronos::params::libprocess_ip,

  $mesos_principal       = $chronos::params::mesos_principal,
  $mesos_secret          = $chronos::params::mesos_secret,

  $secret_file_path      = $chronos::params::secret_file_path,

  $config_base_path      = $chronos::params::config_base_path,
  $config_dir_path       = $chronos::params::config_dir_path,
  $config_file_path      = $chronos::params::config_file_path,
  $config_file_mode      = $chronos::params::config_file_mode,

  $java_opts             = $chronos::params::java_opts,
  $java_home             = $chronos::params::java_home,

  $options               = $chronos::params::options,
) inherits ::chronos::params {
  validate_array($zk_servers)

  if $zk_chronos_servers {
    validate_array($zk_chronos_servers)
  }

  validate_integer($zk_default_port)
  validate_string($zk_mesos_path)
  validate_ip_address($libprocess_ip)
  validate_absolute_path($config_base_path)
  validate_absolute_path($config_dir_path)
  validate_absolute_path($config_file_path)
  validate_string($config_file_mode)
  validate_hash($options)

  if $mesos_principal or $mesos_secret {
    validate_string($mesos_principal)
    validate_string($mesos_secret)
  }

  validate_absolute_path($secret_file_path)

  validate_string($java_opts)

  if $java_home {
    validate_absolute_path($java_home)
  }

  $chronos_master = chronos_zk_url($zk_servers, $zk_mesos_path, $zk_default_port)
  $real_zk_chronos_servers = pick($zk_chronos_servers, $zk_servers)
  $chronos_zk_hosts = chronos_zk_servers($real_zk_chronos_servers, $zk_default_port)

  File {
    ensure => 'present',
    owner  => 'root',
    group  => 'root',
    mode   => $config_file_mode,
  }

  file { 'chronos_config_base' :
    ensure => 'directory',
    path   => $config_base_path,
  }

  file { 'chronos_config_dir':
    ensure  => 'directory',
    path    => $config_dir_path,
    purge   => true,
    recurse => true,
  }

  file { 'chronos_config_file' :
    path    => $config_file_path,
    content => template('chronos/config.sh.erb'),
  }

  file { 'chronos_secret_file' :
    path    => $secret_file_path,
    content => $mesos_secret,
  }

  $hiera_options = hiera_hash('chronos::options', { })
  $options_structute = chronos_options($hiera_options, $options)
  $options_defaults = { }
  create_resources('chronos::option', $options_structute, $options_defaults)

  Package <| title == 'chronos' |> ->
  File['chronos_config_base']

  File['chronos_config_dir'] ~>
  Service <| title == 'chronos' |>

  File['chronos_config_file'] ~>
  Service <| title == 'chronos' |>

  File['chronos_secret_file'] ~>
  Service <| title == 'chronos' |>

}
