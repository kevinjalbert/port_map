module PortMap
  module Mappings
    def self.parse_conf(filename)
      contents = File.new(filename).read
      server_name = contents.match(/server_name\s+(.+?);/)
      location_mappings = contents.scan(/location\s+(.+?)\s+{\s+proxy_pass\s+(.+?);\s+}/m)

      data = {}
      data[:name] = File.basename(filename, '.port_map.conf')
      data[:nginx_conf] = PortMap::Nginx.servers_directory + File::Separator + data[:name] + '.port_map.conf'
      data[:server_name] = server_name.captures.first
      data[:locations] = location_mappings.map do |location_mapping|
        { name: location_mapping.first, proxy_pass: location_mapping.last }
      end

      data
    end

    def self.all
      Dir.glob(PortMap::Nginx.servers_directory + File::Separator + '/*.port_map.conf').map do |filename|
        parse_conf(filename)
      end
    end
  end
end
