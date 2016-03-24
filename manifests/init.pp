# == Class: chronos
#
# Manage Chronos installation, configuration, and jobs.
#
# === Parameters
#
# [*master*]
#   URL to the Mesos master, e.g. 'zk://localhost:2181/mesos' (optional).
#   Leave this blank to use the Chronos default of looking for this value at
#   '/etc/mesos/zk'.
#
# [*zk_hosts*]
#   Comma-separated list of ZooKeeper hosts for Chronos to use (optional).
#   Leave this blank to use the Chronos default of looking for this value at
#   '/etc/mesos/zk'.
#
# [*conf_dir*]
#   The path where the Chronos config is located.
#   Defaults to '/etc/chronos/conf'
#
# [*http_port*]
#   HTTP port for Chronos to listen on. Defaults to 4400.
#
# [*hostname*]
#   The advertised hostname (optional). Leave this blank for Chronos to
#   auto-populate the hostname.
#
# [*manage_package_deps*]
#   Whether to install the dependencies for this module, such as the 'json'
#   and 'httparty' Ruby gems. Defaults to true.
#
# [*package_name*]
#   The name of the package to install, e.g. 'chronos'
#   The default is set in params.pp based on the operating system and release.
#
# [*service_name*]
#   The name of the service to manage, e.g. 'chronos'
#   The default is set in params.pp based on the operating system and release.
#
# [*force_provider*]
#   Service provider to use to create/start the Chronos service.
#   If not specified, the system default service provider is used.
#
class chronos (
  $master              = $chronos::params::master,
  $zk_hosts            = $chronos::params::zk_hosts,
  $conf_dir            = $chronos::params::conf_dir,
  $http_port           = $chronos::params::http_port,
  $hostname            = $chronos::params::hostname,
  $manage_package_deps = $chronos::params::manage_package_deps,
  $package_name        = $chronos::params::package_name,
  $service_name        = $chronos::params::service_name,
  $force_provider      = $chronos::params::force_provider,
) inherits chronos::params {

  if $manage_package_deps {
    $gem_provider = $::puppetversion ? {
      /Puppet Enterprise/ => 'pe_gem',
      default             => 'gem',
    }

    package { 'httparty':
      ensure   => present,
      provider => $gem_provider,
    }

    package { 'json':
      ensure   => present,
      provider => $gem_provider,
    }
  }

  class { 'chronos::install': } ~>
  class { 'chronos::service': }
  contain 'chronos::install'
  contain 'chronos::service'
}
