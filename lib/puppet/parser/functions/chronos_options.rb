module Puppet::Parser::Functions
  newfunction(
    :chronos_options,
    type: :rvalue,
    arity: -2,
    doc: 'Convert a hash of Chronos options to a structure for create_resources function'
  ) do |args|
    structure = {}
    args.each do |options|
      raise Puppet::ParseError, "chronos_options() Options should be provided as a Hash! Got: #{options.inspect}" unless options.is_a? Hash
      options.each do |key, value|
        next unless key && !value.nil?
        structure[key] = {}
        structure[key]['value'] = value
      end
    end
    structure
  end
end
