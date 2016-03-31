# == Define: chronos::options
#
# Manage a single command line option
# by creating a file in the config directory.
#
define chronos::option (
  $ensure = 'present',
  $owner  = 'root',
  $group  = 'root',
  $mode   = undef,
  $path   = undef,
  $value  = undef,
) {
  include '::chronos::params'

  $config_dir_path = $::chronos::params::config_dir_path
  $config_file_mode = $::chronos::params::config_file_mode

  $file_path = pick($path, "${config_dir_path}/${name}")
  $file_mode = pick($mode, $config_file_mode)
  $file_title = "chronos-option-${name}"

  file { $file_title :
    ensure  => $ensure,
    path    => $file_path,
    owner   => $owner,
    group   => $group,
    mode    => $file_mode,
    content => "${value}\n",
  }

  File <| title == 'chronos_config_dir' |> ->
  File[$file_title] ~>
  Service <| title == 'chronos' |>
}
