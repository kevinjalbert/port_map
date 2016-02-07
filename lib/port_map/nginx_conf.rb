module PortMap
  class NginxConf
    DOMAIN = 'dev'.freeze
    PORT_PLACEHOLDER = '$PORT'.freeze
    PORT_MAP_CONF_FILENAME = '.port_map.conf'.freeze

    attr_reader :name,
                :port,
                :domain,
                :output

    def self.from_file(port, file)
      file_content = file.read

      raise "File #{file} does not contain special $PORT placeholder" unless file_content.include?(PORT_PLACEHOLDER)
      file_content = file_content.sub(PORT_PLACEHOLDER, port)

      name, domain = file_content.match(/server_name\s+(.+)\.(.+?);/).captures
      new(port, name, domain, file_content)
    end

    def initialize(port, name, domain = DOMAIN, existing_conf_content = '')
      @name = name
      @port = port
      @domain = domain

      if existing_conf_content.empty?
        @output = default_conf_content
      else
        @output = existing_conf_content
      end
    end

    def default_conf_content
      %(
        server {
          listen       80;
          server_name  #{@name}.#{DOMAIN};

          location / {
              proxy_pass http://127.0.0.1:#{@port};
          }
        }
      )
    end

    def server_name
      "#{@name}.#{@domain}"
    end

    def filename
      Nginx.servers_directory + File::Separator + @name + '.port_map.conf'
    end

    def save
      File.open(filename, 'w+') { |f| f.write(@output) }
    end
  end
end
