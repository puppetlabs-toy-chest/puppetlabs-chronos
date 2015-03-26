require 'httparty'
Puppet::Type.type(:chronos_job).provide(:default) do

  desc "Implements creating Chronos jobs through its REST api."

  def create
    @job = {
    'name': resource[:name],
    'async' : resource[:async],
    'command': resource[:command],
    'epsilon': resource[:epsilon],
    'owner': resource[:owner],
    }
    if resource[:parents] == nil
      @job_type_endpoint = "scheduler/iso8601"
      job[:schedule] = resource[:schedule]
      if resource[:schedule_timezone]
        job[:scheduleTimeZone] = resource[:schedule_timezone]
      end
    else
      @job_type_endpoint = "scheduler/dependency"
      job[:parents] = resource[:parents]
    end

    begin
      response = HTTParty.post("#{resource[:host]}/#{job_type}", job)
    rescue HTTParty::Error
      raise Puppet::Error, "Error while connecting to Chronos host #{resource[:host]}"
    rescue HTTParty::ResponseError => e
      raise Puppet::Error, "Failed to create Chronos job with HTTP error : #{e}"
    end
  end

  def destroy
    begin
      response = HTTParty.delete("#{resource[:host]}/job/#{resource[:name]}")
    rescue HTTParty::Error
      raise Puppet::Error, "Error while connecting to Chronos host #{resource[:host]}"
    rescue HTTParty::ResponseError => e
      raise Puppet::Error, "Failed to delete Chronos job with HTTP error : #{e}"
    end
  end
end
