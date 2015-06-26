Puppet::Type.type(:chronos_job).provide(:default) do

  # I've had issues with lazy loading of providers in the past where requirements
  # for the provider to function are best defined inside the provider as opposed
  # to the standard Ruby practice.  Allows for you to be able to install httparty
  # on the same run as the provider is synced.
  require 'httparty'
  require 'json'

  desc "Implements creating Chronos jobs through its REST api."

  mk_resource_methods

  @default_target = 'http://localhost:4400'

  class << self
    attr_accessor :default_target
  end

  def self.targets(resources = nil)
    targets = []

    if resources
      resources.each do |name, resource|
        if value = resource[:host]
          targets << value
        end
      end
    else
      targets << self.default_target
    end

    targets.uniq.compact
  end

  def self.instances(resources = nil)

    instances = []

    ltargets = targets(resources)

    ltargets.each do |target|
      jobs = HTTParty.get("#{target}/scheduler/jobs")

      jobs.each do |job|
        job = {
          :name                  => job['name'],
          :command               => job['command'],
          :arguments             => job['arguments'],
          :uris                  => job['uris'],
          :container             => job['container'],
          :environment_variables => job['environmentVariables'],
          :job_schedule          => job['schedule'],
          :schedule_timezone     => job['scheduleTimeZone'],
          :epsilon               => job['epsilon'],
          :owner                 => job['owner'].split(','),
          :async                 => job['async'],
          :parents               => job['parents'],
          :retries               => job['retries'],
          :cpus                  => job['cpus'],
          :disk                  => job['disk'],
          :mem                   => job['mem'],
        }

        unless job[:environment_variables].empty?
          merged = {};job[:environment_variables].each { |x| merged.merge!({ x['name'] => x['value'] }) }
          job[:environment_variables] = merged
        end

        job.delete_if do |k,v|
          if (v.is_a?(Array) || v.is_a?(Hash))
            v.empty?
          else
            v.nil?
          end
        end

        instances << new(job)
      end
    end
    instances
  end

  def self.prefetch(resources)
    instances(resources).each do |prov|
      if res = resources[prov.name.to_s]
        res.provider = prov
      end
    end
  end

  def flush
    if ! @property_hash.empty? && @property_hash[:ensure] != :absent
      create
    end
    @property_hash = resource.to_hash
  end

  def create
    job = {
      'name'                 => resource[:name],
      'command'              => resource[:command],
      'owner'                => resource[:owner].join(','),
      'cpus'                 => resource[:cpus],
      'disk'                 => resource[:disk],
      'mem'                  => resource[:mem],
      'arguments'            => resource[:arguments],
      'uris'                 => resource[:uris],
      'container'            => resource[:container],
      'environmentVariables' => resource[:environment_variables],
      'epsilon'              => resource[:epsilon],
      'async'                => resource[:async],
      'parents'              => resource[:parents],
      'retries'              => resource[:retries],
      'schedule'             => resource[:job_schedule],
      'scheduleTimeZone'     => resource[:schedule_timezone],
      'parents'              => resource[:parents]
    }

    unless resource[:environment_variables].nil?
      listed = [];resource[:environment_variables].each_pair { |k,v| listed << { 'name' => k, 'value' => v }}
      job['environmentVariables'] = listed
    end

    job.delete_if do |k,v|
      if (v.is_a?(Array) || v.is_a?(Hash))
        v.empty?
      else
        v.nil?
      end
    end

    headers = {
      "Content-Type" => "application/json"
    }

    job_type_endpoint = resource[:parents].nil? ? 'scheduler/iso8601' : 'scheduler/dependency'

    begin
      response = HTTParty.post("#{resource[:host]}/#{job_type_endpoint}", :body => job.to_json, :headers => headers)
    rescue HTTParty::Error
      raise Puppet::Error, "Error while connecting to Chronos host #{resource[:host]}"
    rescue HTTParty::ResponseError => e
      raise Puppet::Error, "Failed to create Chronos job with HTTP error : #{e}"
    end

    @property_hash.clear
  end

  def exists?
    !(@property_hash[:ensure] == :absent or @property_hash.empty?)
  end

  def destroy
    begin
      response = HTTParty.delete("#{resource[:host]}/scheduler/job/#{@property_hash[:name]}")
    rescue HTTParty::Error
      raise Puppet::Error, "Error while connecting to Chronos host #{resource[:host]}"
    rescue HTTParty::ResponseError => e
      raise Puppet::Error, "Failed to delete Chronos job with HTTP error : #{e}"
    end
    @property_hash[:ensure] = :absent
  end
end
