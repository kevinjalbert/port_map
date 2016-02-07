require 'spec_helper'

RSpec.describe PortMap::Utilities do
  describe '.shell_cmd_wrapper' do
    let(:cmd) { 'rails server' }
    let(:example_path) { 'example_path' }

    before { allow(ENV).to receive(:fetch).with('PATH') { example_path } }

    context 'zsh shell' do
      before { allow(ENV).to receive(:fetch).with('SHELL') { described_class::ZSH_SHELL } }

      it 'returns zsh cmd' do
        zsh_cmd = described_class.shell_cmd_wrapper(cmd)
        expected_zsh_cmd = described_class::ZSH_CMD_STRING % { path: example_path, cmd: cmd }
        expect(zsh_cmd).to eq(expected_zsh_cmd)
      end
    end

    context 'bash shell' do
      before { allow(ENV).to receive(:fetch).with('SHELL') { described_class::BASH_SHELL } }

      it 'returns bash cmd' do
        bash_cmd = described_class.shell_cmd_wrapper(cmd)
        expected_bash_cmd = described_class::BASH_CMD_STRING % { path: example_path, cmd: cmd }
        expect(bash_cmd).to eq(expected_bash_cmd)
      end
    end
  end

  describe '.apply_open_port_option' do
    let(:cmd) { "example_cmd -t 30 --num 60 #{port_flag} #{port_number}" }

    let(:port_flag) { '--port' }
    let(:port_number) { 3000 }

    let(:expected_cmd) { "example_cmd -t 30 --num 60 #{expected_port_flag} #{expected_port_number}" }
    let(:expected_port_number) { 10000 }

    before { allow(described_class).to receive(:next_empty_port) { expected_port_number } }

    context 'with --port in cmd' do
      let(:expected_port_flag) { '--port' }

      it { expect(described_class.apply_open_port_option(expected_port_number, cmd)).to eq(expected_cmd) }
    end

    context 'with -p in cmd' do
      let(:port_flag) { '-p' }
      let(:expected_port_flag) { '-p' }

      it { expect(described_class.apply_open_port_option(expected_port_number, cmd)).to eq(expected_cmd) }
    end

    context 'with no port option in cmd' do
      let(:port_flag) { nil }
      let(:port_number) { nil }
      let(:expected_port_flag) { '--port' }

      it { expect(described_class.apply_open_port_option(expected_port_number, cmd)).to eq(expected_cmd) }
    end
  end

  describe '.next_empty_port' do
    let(:port_mappings) { [] }

    before { allow(PortMap::Mappings).to receive(:all) { port_mappings } }

    context 'no port mappings exist' do
      it 'returns STARTING_PORT_NUMBER' do
        expect(described_class.next_empty_port).to eq(described_class::STARTING_PORT_NUMBER)
      end
    end

    context 'one port mapping exist' do
      context 'with one location' do
        let(:previous_highest_port_number) { 30000 }
        let(:port_mappings) do
          [
            {
              name: 'admin',
              nginx_conf: '/usr/local/etc/nginx/servers/admin.port_map.conf',
              server_name: 'admin.dev',
              locations: [
                {
                  name: '/',
                  proxy_pass: "http://127.0.0.1:#{previous_highest_port_number}"
                }
              ]
            }
          ]
        end

        it 'returns STARTING_PORT_NUMBER' do
          expect(described_class.next_empty_port).to eq(previous_highest_port_number + described_class::PORT_NUMBER_INCREMENT)
        end
      end

      context 'with multiple locations' do
        let(:previous_highest_port_number) { 30000 }
        let(:port_mappings) do
          [
            {
              name: 'admin',
              nginx_conf: '/usr/local/etc/nginx/servers/admin.port_map.conf',
              server_name: 'admin.dev',
              locations: [
                {
                  name: '/',
                  proxy_pass: "http://127.0.0.1:#{previous_highest_port_number}"
                },
                {
                  name: '/test',
                  proxy_pass: 'http://test.dev'
                }
              ]
            }
          ]
        end

        it 'returns STARTING_PORT_NUMBER' do
          expect(described_class.next_empty_port).to eq(previous_highest_port_number + described_class::PORT_NUMBER_INCREMENT)
        end
      end
    end

    context 'multiple port mappings exist' do
      let(:previous_highest_port_number) { 30000 }
      let(:port_mappings) do
        [
          {
            name: 'admin',
            nginx_conf: '/usr/local/etc/nginx/servers/admin.port_map.conf',
            server_name: 'admin.dev',
            locations: [
              {
                name: '/',
                proxy_pass: 'http://127.0.0.1:20720'
              }
            ]
          },
          {
            name: 'api',
            nginx_conf: '/usr/local/etc/nginx/servers/api.port_map.conf',
            server_name: 'api.dev',
            locations: [
              {
                name: '/',
                proxy_pass: "http://127.0.0.1:#{previous_highest_port_number}"
              }
            ]
          }
        ]
      end

      it 'returns STARTING_PORT_NUMBER' do
        expect(described_class.next_empty_port).to eq(previous_highest_port_number + described_class::PORT_NUMBER_INCREMENT)
      end
    end
  end
end
