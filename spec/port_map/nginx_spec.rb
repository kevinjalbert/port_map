require 'spec_helper'

RSpec.describe PortMap::Nginx do
  describe '.conf_directory' do
    context 'env var NGINX_DIR is not set' do
      context 'nginx is not installed' do
        let(:cmd_output) { 'zsh: command not found: nginx' }

        before { allow(Open3).to receive(:popen3).with('nginx -t') { [nil, double(read: ''), double(read: cmd_output)] } }

        it 'raises exception' do
          expect { described_class.conf_directory }.to raise_error(StandardError)
        end
      end

      context 'nginx is installed' do
        let(:nginx_dir) { '/usr/local/etc/nginx' }
        let(:cmd_output) do
          [
            "nginx: the configuration file #{nginx_dir}/nginx.conf syntax is ok",
            "nginx: configuration file #{nginx_dir}/nginx.conf test is successful"
          ].join("\n")
        end

        before { allow(Open3).to receive(:popen3).with('nginx -t') { [nil, double(read: ''), double(read: cmd_output)] } }

        it 'returns nginx_dir' do
          expect(described_class.conf_directory).to eq(nginx_dir)
        end
      end
    end

    context 'env var NGINX_DIR is set' do
      let(:nginx_dir) { '/temp' }
      before do
        allow(ENV).to receive(:key?).with('NGINX_DIR') { true }
        allow(ENV).to receive(:fetch).with('NGINX_DIR') { nginx_dir }
      end

      it 'returns nginx_dir' do
        expect(described_class.conf_directory).to eq(nginx_dir)
      end
    end
  end

  describe '.servers_directory!' do
    before { allow(described_class).to receive(:conf_directory) { '/temp/' } }

    it 'returns servers directory' do
      expect(described_class.servers_directory).to eq(described_class.conf_directory + File::Separator + 'servers')
    end
  end
end
