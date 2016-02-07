require 'spec_helper'

RSpec.describe PortMap::Mappings do
  describe '.parse_conf' do
    let(:port) { '3000' }
    let(:name) { 'admin' }
    let(:domain) { 'dev' }

    let(:nginx_conf) { PortMap::NginxConf.new(port, name, domain).tap(&:save) }
    let(:temp_dir) { Dir.mktmpdir }

    before { allow(PortMap::Nginx).to receive(:servers_directory) { temp_dir } }
    after { FileUtils.rm_rf(temp_dir) }

    it 'parses correctly' do
      data = described_class.parse_conf(nginx_conf.filename)
      expect(data[:name]).to eq(name)
      expect(data[:nginx_conf]).to eq(nginx_conf.filename)
      expect(data[:server_name]).to eq(nginx_conf.server_name)
      expect(data[:locations].first[:name]).to eq('/')
      expect(data[:locations].first[:proxy_pass]).to eq("http://127.0.0.1:#{port}")
    end
  end

  describe '.all' do
    let(:temp_dir) { Dir.mktmpdir }

    before do
      allow(PortMap::Nginx).to receive(:servers_directory) { temp_dir }
      File.open(temp_dir + File::Separator + 'admin.port_map.conf', 'w')
      File.open(temp_dir + File::Separator + 'api.port_map.conf', 'w')
    end

    after { FileUtils.rm_rf(temp_dir) }

    it 'calls parse_conf for each port_map.conf' do
      expect(described_class).to receive(:parse_conf).twice
      described_class.all
    end
  end
end
