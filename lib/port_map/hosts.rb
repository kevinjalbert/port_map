module PortMap
  module Hosts
    PORT_MAP_TRACK_COMMENT = '#port_map'.freeze
    HOSTS_FILENAME = '/etc/hosts'.freeze

    def self.update
      new_contents = contents
      port_maps = JSON.parse(`list_port_maps`)

      unless port_maps.empty?
        new_contents += "\n127.0.0.1 #{port_maps.map { |port_map| port_map['server_name'] }.join(' ')} #{PORT_MAP_TRACK_COMMENT}"
      end

      save(new_contents)
    end

    def self.save(new_contents)
      File.open(HOSTS_FILENAME, 'w+') { |f| f.write(new_contents) }
    end

    def self.contents
      File.readlines(HOSTS_FILENAME).reject do |line|
        line.strip.match(/#{PORT_MAP_TRACK_COMMENT}$/)
      end.join
    end
  end
end
