module Puppet::Parser::Functions
  newfunction(
    :chronos_zk_url,
    type: :rvalue,
    arity: -3,
    doc: 'Combine a list of Zookeeper server with ports and path'
  ) do |args|
    servers = args[0]
    path = args[1]
    port = args[2] || '2181'

    raise Puppet::ParseError, 'chronos_zk_url() You should provide arguments: server list and path!' unless servers && path
    servers = [servers] unless servers.is_a? Array
    break nil unless servers.any?
    list = servers.map do |server|
      next server if server.include? ':'
      "#{server}:#{port}"
    end.join ','

    "zk://#{list}/#{path}"
  end
end
