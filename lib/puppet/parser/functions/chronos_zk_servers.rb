module Puppet::Parser::Functions
  newfunction(
    :chronos_zk_servers,
    type: :rvalue,
    arity: -2,
    doc: 'Combine a list of Zookeeper servers with ports into an array'
  ) do |args|
    servers = args[0]
    port = args[1] || '2181'

    raise Puppet::ParseError, 'chronos_zk_servers() You should provide arguments: server list!' unless servers
    servers = [servers] unless servers.is_a? Array
    break nil unless servers.any?
    servers.map do |server|
      next server if server.include? ':'
      "#{server}:#{port}"
    end.join ','
  end
end
