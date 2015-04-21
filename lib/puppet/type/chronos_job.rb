require 'puppet/property/boolean'
Puppet::Type.newtype(:chronos_job) do

  @doc = "Manage creation/deletion of Chronos jobs."

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the Chronos job."
  end

  newparam(:host) do
    desc "The host/port to the chronos host. Defaults to localhost."
    defaultto 'http://localhost:4400'
  end

  newproperty(:command) do
    desc "The command to execute in the job."
    validate do |val|
      unless val.is_a? String
        raise ArgumentError, "epsilon parameter must be a String, got value of type #{val.class}"
      end
    end
  end

  newproperty(:arguments) do
    desc "The command to execute in the job."
    munge do |value|
      value.to_a
    end
  end

  newproperty(:uris) do
    desc "The command to execute in the job."
    munge do |value|
      value.to_a
    end
  end

  newproperty(:container) do
    desc "The command to execute in the job."
    munge do |val|
      val.to_hash
    end
  end


  newproperty(:environment_variables) do
    desc "Optionally create parent Chronos jobs."
    munge do |val|
      val.to_a
    end
 end

  newproperty(:job_schedule) do
    desc "The scheduling for the job, in ISO8601 format."
    validate do |val|
      unless val.is_a? String
        raise ArgumentError, "schedule parameter must be a String, got value of type #{val.class}"
      end
    end
  end

  newparam(:schedule_timezone) do
    desc "The time zone name to use when scheduling the job."
    defaultto 'UTC'
    validate do |val|
      if not val.is_a? String
        raise ArgumentError, "schedule_timezone parameter must be a String, got value of type #{val.class}"
      end
    end
  end

  newproperty(:epsilon) do
    desc "The interval to run the job on, in ISO8601 duration format."
    validate do |val|
      unless val.is_a? String
        raise ArgumentError, "epsilon parameter must be a String, got value of type #{val.class}"
      end
    end
  end

  newproperty(:owner) do
    desc "The email address of the person or persons interested in the job status."
    # Should we validate against http://www.ex-parrot.com/~pdw/Mail-RFC822-Address.html...?
    validate do |val|
      unless val.is_a? String
        raise ArgumentError, "owner parameter must be a String, got value of type #{val.class}"
      end
    end
  end

  newproperty(:async, :boolean => true, :parent => Puppet::Property::Boolean) do
    desc "Whether or not the job runs in the background."
  end

  newproperty(:parents) do
    desc "Optionally associate with parent Chronos job(s)."
    munge do |value|
      value.to_a
    end
  end

  newproperty(:retries) do
    desc "Number of times to retry job execution after a failure."
    validate do |val|
      unless val.is_a? Fixnum
        raise ArgumentError, "owner parameter must be a String, got value of type #{val.class}"
      end
    end
  end

  newproperty(:cpus) do
    desc "Amount of cpu shares to allocate to a job."
    defaultto 0.1
    validate do |val|
      unless val.is_a? Float
        raise ArgumentError, "cpus parameter must be a Float, got value of type #{val.class}"
      end
    end
  end

  newproperty(:disk) do
    desc "Amount of disk to allocate to a job."
    defaultto 256
    validate do |val|
      unless val.is_a? Fixnum
        raise ArgumentError, "cpus parameter must be a Fixnum, got value of type #{val.class}"
      end
    end
  end

  newproperty(:mem) do
    desc "Amount of disk to allocate to a job."
    defaultto 64
    validate do |val|
      unless val.is_a? Fixnum
        raise ArgumentError, "cpus parameter must be a Fixnum, got value of type #{val.class}"
      end
    end
  end

  autorequire(:chronos_job) do
    parent_jobs = self[:parents]
  end
end
