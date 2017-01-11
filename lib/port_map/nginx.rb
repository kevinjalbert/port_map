module PortMap
  module Nginx
    def self.conf_directory
      return ENV.fetch('NGINX_DIR') if ENV.key?('NGINX_DIR')

      _, stdout, stderr = Open3.popen3('nginx -t')
      location_match = [stdout.read, stderr.read].join.match(/nginx: the configuration file (.+?) syntax/)

      if location_match && !location_match.captures.empty?
        Pathname.new(location_match.captures.first).dirname.to_s
      else
        raise '`nginx -t` command did not reveal nginx conf. You can set NGINX_DIR environment variable to indicate nginx conf directory'
      end
    end

    def self.servers_directory
      directory = conf_directory + File::Separator + 'servers'
      Dir.mkdir(directory) unless Dir.exist?(directory)
      directory
    end

    def self.reload
      `sudo nginx -s reload`
    end
  end
end
