require 'puppet/property/boolean'
Puppet::Type.newtype(:chronos_job) do
  @doc = 'Manage creation/deletion of Chronos jobs.'

  ensurable

  newparam(:name, namevar: true) do
    desc 'The name of the Chronos job.'
  end

  newparam(:host) do
    desc 'The host/port to the chronos host. Defaults to localhost.'
    defaultto 'http://localhost:4400'
  end

  newproperty(:command) do
    desc 'The command to execute in the job.'

    validate do |val|
      unless val.is_a? String
        raise ArgumentError, "command parameter must be a String, got value of type #{val.class}"
      end
    end
  end

  newproperty(:arguments, array_matching: :all) do
    desc 'Arguments that will be passed to the command'

    validate do |val|
      unless val.is_a? String
        raise ArgumentError, "arguments parameter must be a collection or Strings, got value of type #{val.class}"
      end
    end
  end

  newproperty(:uris, array_matching: :all) do
    desc 'A list of URIs that Mesos downloads when the Chronos job starts'

    validate do |val|
      unless val.is_a? String
        raise ArgumentError, "uris parameter must be a collection or Strings, got value of type #{val.class}"
      end
    end
  end

  newproperty(:container) do
    desc 'The subfields that contain data needed to run the job in a container'

    validate do |val|
      unless val.is_a? Hash
        raise ArgumentError, "container parameter must be a Hash, got value of type #{val.class}"
      end
    end
  end

  newproperty(:environment_variables) do
    desc 'Environments variables set for job'

    validate do |val|
      if val.is_a?(Hash) && val.key?('name') && val.key?('value')
        raise ArgumentError, 'detected environment_variables parameter with keys "name" and "value". The chronos_job type does not support the Chronos API way of setting environment variables, sending an array of hashes. The chronos_job type expects a hash of { NAME => VALUE }'
      end
    end
  end

  newproperty(:job_schedule) do
    desc 'The scheduling for the job, in ISO8601 format.'

    validate do |val|
      unless val.is_a? String
        raise ArgumentError, "job_schedule parameter must be a String, got value of type #{val.class}"
      end
    end
  end

  newproperty(:schedule_timezone) do
    desc 'The time zone name to use when scheduling the job.'

    defaultto 'UTC'

    validate do |val|
      unless val.is_a? String
        raise ArgumentError, "schedule_timezone parameter must be a String, got value of type #{val.class}"
      end
    end
  end

  newproperty(:epsilon) do
    desc 'The interval to run the job on, in ISO8601 duration format.'

    validate do |val|
      unless val.is_a? String
        raise ArgumentError, "epsilon parameter must be a String, got value of type #{val.class}"
      end
    end
  end

  newproperty(:owner, array_matching: :all) do
    desc 'The email address of the person or persons interested in the job status.'

    # Create an array by splitting the value on commas because this is how the Chronos
    # documentation says to set multiple owners.
    def should=(val)
      super
      if val.is_a? String
        val.split(',').each do |item|
          unless item.is_a? String
            raise ArgumentError, "owner parameter must be a String or Array of Strings, got value of type #{item.class}"
          end
        end
        @should = @should.first.split(',')
      else
        @should
      end
    end

    validate do |val|
      unless val.is_a? String
        raise ArgumentError, "owner parameter must be a String or Array of Strings, got value of type #{val.class}"
      end
    end
  end

  newproperty(:async, boolean: true, parent: Puppet::Property::Boolean) do
    desc 'Whether or not the job runs in the background.'
  end

  newproperty(:parents, array_matching: :all) do
    desc 'Optionally associate with parent Chronos job(s).'

    validate do |val|
      unless val.is_a? String
        raise ArgumentError, "parents parameter must be a String or Array of Strings, got value of type #{val.class}"
      end
    end
  end

  newproperty(:retries) do
    desc 'Number of times to retry job execution after a failure.'

    validate do |val|
      unless val.is_a? Fixnum
        raise ArgumentError, "retries parameter must be a Fixnum, got value of type #{val.class}"
      end
    end
  end

  newproperty(:cpus) do
    desc 'Amount of cpu shares to allocate to a job.'

    defaultto 0.1

    validate do |val|
      unless val.is_a?(Float) || val.is_a?(Fixnum)
        raise ArgumentError, "cpus parameter must be a Float or Fixnum, got value of type #{val.class}"
      end
    end
  end

  newproperty(:disk) do
    desc 'Amount of disk to allocate to a job.'

    defaultto 256

    validate do |val|
      unless val.is_a?(Float) || val.is_a?(Fixnum)
        raise ArgumentError, "disk parameter must be a Float or Fixnum, got value of type #{val.class}"
      end
    end
  end

  newproperty(:mem) do
    desc 'Amount of disk to allocate to a job.'

    defaultto 64

    validate do |val|
      unless val.is_a?(Float) || val.is_a?(Fixnum)
        raise ArgumentError, "mem parameter must be a FLoat or Fixnum, got value of type #{val.class}"
      end
    end
  end

  validate do
    if self[:command].nil? && provider.command.nil?
      raise ArgumentError, 'The following parameter is required: command'
    end

    if self[:schedule] && self[:parents]
      raise ArgumentError, 'schedule and parents parameters are mutually exclusive, they define the Chronos job type, scheduled or dependent'
    end
  end

  autorequire(:chronos_job) do
    self[:parents]
  end
end
