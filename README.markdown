# puppetlabs-chronos
A Puppet module for managing Chronos.

[![Build Status](https://travis-ci.org/puppetlabs/puppetlabs-chronos.svg)](https://travis-ci.org/puppetlabs/puppetlabs-chronos)

#### Table of Contents

1. [Overview](#overview)
2. [Setup - The basics of getting started with chronos](#setup)
    * [What chronos affects](#what-puppetlabs-chronos-affects)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Overview

This Puppet module installs the Chronos package, manages the configuration and
service, and creates jobs using Chronos' HTTP API.

## Setup

If you're using r10k or librarian-puppet, add the following to your Puppetfile:

```ruby
mod 'puppetlabs-chronos', :git => 'git://github.com/puppetlabs/puppetlabs-chronos.git', :ref => 'v0.1.0'
```

### What puppetlabs-chronos affects

- Manage Chronos configuration files `master`, `http_port`, and `zk_hosts`
in `/etc/chronos/conf`
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
  master              => 'zk://10.1.1.1:2181,10.1.1.2:2181,10.1.1.1.3:2181/mesos',
  zk_hosts            => '10.1.1.1:2181,10.1.1.2:2181,10.1.1.3:2181',
  conf_dir            => '/etc/chronos/conf',
  http_port           => '4400',
  manage_package_deps => true,
  package_name        => 'chronos',
  service_name        => 'chronos',
}
```

If you wish to override the system default provider for service management, you
may also specify the optional `force_provider` parameter in the class
declaration. For example, the following declaration specifies that `upstart` is
to be used as the service provider:

```puppet
class { 'chronos':
  master              => 'zk://10.1.1.1:2181,10.1.1.2:2181,10.1.1.1.3:2181/mesos',
  zk_hosts            => '10.1.1.1:2181,10.1.1.2:2181,10.1.1.3:2181',
  conf_dir            => '/etc/chronos/conf',
  http_port           => '4400',
  manage_package_deps => true,
  package_name        => 'chronos',
  service_name        => 'chronos',
  force_provider      => 'upstart',
}
```

## Limitations

  - This module will not add the Mesosphere repo to the system's package
  manager. It is recommended that the user manage the repo in a profile, using
  the puppetlabs/apt or stahnma/epel modules.
  - The `chronos_job` type requires that two Ruby Gems are present on the
  system: httparty and json. The `chronos` class will install these gems, but
  the "ruby" and "ruby-dev" packages need to be managed separately.
  - The `master` and `zk_hosts` params must be left blank if Chronos is
  being installed on a machine that uses Mesos packages provided by Mesosphere.
  For more information, see https://github.com/mesos/chronos/issues/481

## Development

Please see the [contributing guidelines](CONTRIBUTING.md).
