module PortMap
  module Utilities
    BASH_SHELL = '/bin/bash'.freeze
    ZSH_SHELL = '/bin/zsh'.freeze

    BASH_CMD_STRING = "bash -c 'source ~/.bashrc > /dev/null; PATH=%{path}; shopt -s expand_aliases; %{cmd}"
    ZSH_CMD_STRING = "zsh -c 'source ~/.zshrc > /dev/null; PATH=%{path}; setopt aliases; eval %{cmd}'"

    STARTING_PORT_NUMBER = 20000

    def self.shell_cmd_wrapper(cmd)
      case ENV.fetch('SHELL')
      when ZSH_SHELL
        ZSH_CMD_STRING % { path: ENV.fetch('PATH'), cmd: cmd }
      when BASH_SHELL
        BASH_CMD_STRING % { path: ENV.fetch('PATH'), cmd: cmd }
      else
        cmd
      end
    end

    def self.apply_open_port_option(port, cmd)
      port_option_flag = '--port'

      if cmd.sub!(/-p\s+(\d+)/, '')
        port_option_flag = '-p'
      elsif cmd.sub!(/--port\s+(\d+)/, '')
        port_option_flag = '--port'
      end

      [cmd.strip, port_option_flag, port].join(' ')
    end

    def self.next_empty_port
      highest_port = PortMap::Mappings.all.map do |port_map|
        port_map[:locations].detect { |location| location[:name] == '/' }[:proxy_pass].split(':').last.to_i
      end.sort.reverse.first || STARTING_PORT_NUMBER - 1

      highest_port += 1
      highest_port += 1 while port_taken?(highest_port)

      highest_port
    end

    def self.port_taken?(port)
      system("lsof -i:#{port}", out: '/dev/null')
    end
  end
end
