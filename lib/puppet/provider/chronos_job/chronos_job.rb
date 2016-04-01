Puppet::Type.type(:chronos_job).provide(:default) do
  desc 'Implements creating Chronos jobs through its REST api.'

  # There's a possibility of this provider being loaded before Puppet has had
  # a chance to manage the 'httparty' and 'json' gems. Therefore, we confine
  # this provider to only work *if* both httparty and json can be required.
  confine feature: :httparty

  def initialize(*args)
    super
    require 'httparty'
    require 'json'
  end

  mk_resource_methods

  @default_target = 'http://localhost:4400'

  class << self
    attr_accessor :default_target
  end

  def self.targets(resources = nil)
    targets = []

    if resources
      resources.each do |_name, resource|
        value = resource[:host]
        targets << value if value
      end
    else
      targets << default_target
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
          name: job['name'],
          command: job['command'],
          arguments: job['arguments'],
          uris: job['uris'],
          container: job['container'],
          environment_variables: job['environmentVariables'],
          job_schedule: job['schedule'],
          schedule_timezone: job['scheduleTimeZone'],
          epsilon: job['epsilon'],
          owner: job['owner'].split(','),
          async: job['async'],
          parents: job['parents'],
          retries: job['retries'],
          cpus: job['cpus'],
          disk: job['disk'],
          mem: job['mem'],
        }

        unless job[:environment_variables].empty?
          merged = {}
          job[:environment_variables].each { |x| merged.merge!(x['name'] => x['value']) }
          job[:environment_variables] = merged
        end

        job.delete_if do |_k, v|
          if v.is_a?(Array) || v.is_a?(Hash)
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
      res = resources[prov.name.to_s]
      next unless res
      res.provider = prov
    end
  end

  def flush
    create if ! @property_hash.empty? && @property_hash[:ensure] != :absent
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
      'retries'              => resource[:retries],
      'schedule'             => resource[:job_schedule],
      'scheduleTimeZone'     => resource[:schedule_timezone],
      'parents'              => resource[:parents]
    }

    unless resource[:environment_variables].nil?
      listed = []
      resource[:environment_variables].each_pair { |k, v| listed << { 'name' => k, 'value' => v } }
      job['environmentVariables'] = listed
    end

    job.delete_if do |_k, v|
      if v.is_a?(Array) || v.is_a?(Hash)
        v.empty?
      else
        v.nil?
      end
    end

    headers = {
      'Content-Type' => 'application/json'
    }

    job_type_endpoint = resource[:parents].nil? ? 'scheduler/iso8601' : 'scheduler/dependency'

    begin
      HTTParty.post("#{resource[:host]}/#{job_type_endpoint}", body: job.to_json, headers: headers)
    rescue HTTParty::Error
      raise Puppet::Error, "Error while connecting to Chronos host #{resource[:host]}"
    rescue HTTParty::ResponseError => e
      raise Puppet::Error, "Failed to create Chronos job with HTTP error : #{e}"
    end

    @property_hash.clear
  end

  def exists?
    !(@property_hash[:ensure] == :absent || @property_hash.empty?)
  end

  def destroy
    begin
      HTTParty.delete("#{resource[:host]}/scheduler/job/#{@property_hash[:name]}")
    rescue HTTParty::Error
      raise Puppet::Error, "Error while connecting to Chronos host #{resource[:host]}"
    rescue HTTParty::ResponseError => e
      raise Puppet::Error, "Failed to delete Chronos job with HTTP error : #{e}"
    end
    @property_hash[:ensure] = :absent
  end
end
