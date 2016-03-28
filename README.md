# puppetlabs-chronos
A Puppet module for managing Chronos.

[![Build Status](https://travis-ci.org/puppetlabs/puppetlabs-chronos.svg)](https://travis-ci.org/puppetlabs/puppetlabs-chronos)

#### Table of Contents

1. [Overview](#overview)
2. [Setup - The basics of getting started with chronos](#setup)
    * [What chronos affects](#what-puppetlabs-chronos-affects)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Parameters](#parameters)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This Puppet module installs the Chronos package, manages the configuration and
service, and creates jobs using Chronos' HTTP API.

## Setup

If you're using r10k or librarian-puppet, add the following to your Puppetfile:

```ruby
mod 'puppetlabs-chronos', :git => 'git://github.com/puppetlabs/puppetlabs-chronos.git', :ref => 'v0.1.0'
```

### What puppetlabs-chronos affects

- Manage Chronos configuration files `/etc/default/chronos` and
  files in the `/etc/chronos/conf` directory with options.
- Optionally setup the Chronos startup files for systemd or upstart
- Install the Chronos package and ensure the service is running
- Create jobs using the Chronos HTTP API

## Usage

This module adds a new type and provider, `chronos_job`, that will
automatically be copied to nodes using pluginsync.

To install Chronos on a node, simply include the Chronos class:

```puppet
include chronos
```

The module does allow for some customizations, but please read the "limitations"
section below before using them.

```puppet
class { 'chronos':
  zk_servers          => ['10.1.1.1', '10.1.1.2', '10.1.1.1.3'],
  package_deps_manage => true,
  package_name        => 'chronos',
  service_name        => 'chronos',
  options             => {
    'http_port' => '8080',
  }
}
```

## Parameters

### package_name

The name of the Chronos package to install.
Default: chronos

### package_manage

(Boolean) Should the module try to install the package?
Default: true

### package_ensure

Package version or the required state. Can be set to the package
version or to one of present, installed, absent, latest, purged.
Default: present

### package_provider

Override the provider used to install the package.
Default: undef

### package_deps_list

The list of dependency packages used by the chronos_job resource.
Default: 'httparty', 'json'

### package_deps_manage

(Boolean) Should the module try to install dependencies?
Default: true

### package_deps_ensure

The required state of the dependencies. Can be set to the package
version or to one of present, installed, absent, latest, purged.
Default: present

### package_deps_provider

Override the provider used to install the dependency packages.
Default: gem or pe_gem

### service_name

The name of the Chronos service.
Default: chronos

### service_manage

(Boolean) Should the module try to manage the service?
Default: true

### service_enable

(Boolean) Should the module start and enable the service, if true,
or stop and disable it, if false?
Default: true

### service_provider

Override the service provider.
Default: undef

### zk_servers

The list of Zookeeper servers used by the Mesos services. This list
will be converted to the Zookeeper URL. If the empty list is used
the option will be disabled.
Default ['localhost']

### zk_chronos_servers

The list of Zookeeper servers used by Chronos to store its state.
Will be equal to *zk_servers* unless defined.
Default: undef

### zk_default_port

The default port for every Zookeeper server. Can be overrided by providing
the host like this: "host:port".
Default: 2181

### zk_mesos_path

The default zk_node used by mesos.
Default: mesos

### libprocess_ip

Set to the IP address Chronos service should use to talk to the Mesos master.
If left as 127.0.0.1 Chronos will not be able to communicate with remote
Mesos master and '0.0.0.0' cannot be used.
Default: 127.0.0.1

### java_opts

Additional Java option to run the Chronos service with.
Default: '-Xmx512m'

### java_home

Set this option to the root of your custom Java distribution if
you want to use one.
Default: undef

### mesos_principal

Mesos principal name that Chronos should use to authenticate.
Default: undef

### mesos_secret

Mesos principal password that Chronos should use to authenticate.
Default: undef

### secret_file_path

Path to the files used to store the Mesos principal secret.
Default: /etc/chronos/auth_secret

### config_base_path

Path to the base of Chronos configuration.
Default: /etc/chronos

### config_dir_path

Path to the configuration directory used for Chronos options.
Default: /etc/chronos/conf

### config_file_path

Path to the main Chronos configuration file. If will be used by the launcher
to get environment variables from.
Default: /etc/sysconfig/chronos (Debian) or /etc/default/chronos (RedHat)

### config_file_mode

File mode of all configuration files.
Default: 0640

### startup_manage

(Boolean) Should the module try to install startup files?
Ypu should also set *startup_system* if you enable this.
Default: false

### startup_system

Which startup system should be used. Supported: upstart, systemd
Default: undef

### launcher_manage

(Boolean) Should the module try to install the launcher file?
Default: false

### launcher_path

Path to the launcher file.
Default: /usr/bin/chronos

### jar_file_path

Path to the actual JAR file. Will be used in the startup files.
It's expected that jar file is embedded into the launcher file unless defined.
Default: undef

### run_user

Run the service by this system user in the startup files.
User will NOT be created.
Default: undef

### run_user

Run the service by this system group in the startup files.
Group will NOT be created.
Default: undef

### options

The Hash of custom Chronos configuration options and their values.
You can find the complete list of theese options
[here](https://mesos.github.io/chronos/docs/configuration.html)
Default: {}

## Limitations

- This module will not add the Mesosphere repo to the system's package
manager. It is recommended that the user manage the repo in a profile, using
the puppetlabs/apt or stahnma/epel modules.
- The `chronos_job` type requires that two Ruby Gems are present on the
system: httparty and json. The `chronos` class will install these gems, but
the "ruby" and "ruby-dev" packages need to be managed separately.
- The `zk_servers` params should be set to an empty array if Chronos is
being installed on a machine that uses Mesos packages provided by Mesosphere
and launcher_manage is disabled.
For more information, see https://github.com/mesos/chronos/issues/481

## Development

Please see the [contributing guidelines](CONTRIBUTING.md).
