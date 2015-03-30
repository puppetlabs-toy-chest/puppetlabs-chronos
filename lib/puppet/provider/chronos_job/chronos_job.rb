require 'httparty'
require 'json'
Puppet::Type.type(:chronos_job).provide(:default) do

  desc "Implements creating Chronos jobs through its REST api."

  def create
    job = {
    "name" => resource[:name],
    "async" =>  resource[:async],
    "command" => resource[:command],
    "epsilon" => resource[:epsilon],
    "owner" => resource[:owner],
    "retries" => resource[:retries],
    "cpus" => resource[:cpus],
    "disk" => resource[:disk],
    "mem" => resource[:mem],
    }

    headers = {
      "Content-Type" => "application/json"
    }
    if resource[:parents] == nil
      job_type_endpoint = "scheduler/iso8601"
      job[:schedule] = resource[:job_schedule]
      if resource[:schedule_timezone]
        job[:scheduleTimeZone] = resource[:schedule_timezone]
      end
    else
      job_type_endpoint = "scheduler/dependency"
      job[:parents] = resource[:parents]
    end

    begin
      response = HTTParty.post("#{resource[:host]}/#{job_type_endpoint}", :body => job.to_json, :headers => headers)
    rescue HTTParty::Error
      raise Puppet::Error, "Error while connecting to Chronos host #{resource[:host]}"
    rescue HTTParty::ResponseError => e
      raise Puppet::Error, "Failed to create Chronos job with HTTP error : #{e}"
    end
  end

  def exists?
    begin
      response = HTTParty.get("#{resource[:host]}/scheduler/jobs")
      body = JSON.parse(response.body)
      body.each do |job|
        if resource[:name] == job['name']
          return true
        end
      end
      return false
    rescue HTTParty::Error
      raise Puppet::Error, "Error while connecting to Chronos host #{resource[:host]}"
    end
  end

  def destroy
    begin
      response = HTTParty.delete("#{resource[:host]}/scheduler/job/#{resource[:name]}")
    rescue HTTParty::Error
      raise Puppet::Error, "Error while connecting to Chronos host #{resource[:host]}"
    rescue HTTParty::ResponseError => e
      raise Puppet::Error, "Failed to delete Chronos job with HTTP error : #{e}"
    end
  end
end
