Puppet::Type.newtype(:chronos_job) do

    @doc = "Manage creation/deletion of Chronos jobs."

    ensurable

    newparam(:name, :namevar => true) do
        desc "The name of the Chronos job."
    end

    newparam(:host) do
        desc "The host/port to the chronos host. Defaults to localhost."

    newparam(:command) do
        desc "The command to execute in the job."
        validate do |val|
            if val.is_a? String
                raise ArgumentError, "epsilon parameter must be a String, got value of type #{val.class}"
            end
        end
    end

    newparam(:schedule) do
        desc "The scheduling for the job, in ISO8601 format."
        validate do |val|
            if val.is_a? String
                raise ArgumentError, "schedule parameter must be a String, got value of type #{val.class}"
            end
        end
    end

    newparam(:schedule_timezone) do
        desc "The time zone name to use when scheduling the job."
        validate do |val|
            if val.is_a? String
                raise ArgumentError, "schedule_timezone parameter must be a String, got value of type #{val.class}"
            end
        end
    end

    newparam(:epsilon) do
        desc "The interval to run the job on, in ISO8601 duration format."
        validate do |val|
            if val.is_a? String
                raise ArgumentError, "epsilon parameter must be a String, got value of type #{val.class}"
            end
        end
    end

    newparam(:owner) do
        desc "The email address of the person or persons interested in the job status."
        validate do |val|
            if val.is_a? String
                raise ArgumentError, "owner parameter must be a String, got value of type #{val.class}"
            end
        end
    end

    newparam(:async, :boolean => true, :parent => Puppet::Parameter::Boolean)
        desc "Whether or not the job runs in the background."
    end

    newparam(:parents) do
        desc "Optionally create parent Chronos jobs."
        validate do |val|
          if val.is_a? Array
            raise ArgumentError, "parents parameter must be an Array, got value of type #{val.class}"
          end
        end
    end

    autorequire(:chronos_job) do
      parent_jobs = self[:parents]
    end
end

