require 'spec_helper'

RSpec.describe PortMap::NginxConf do
  describe '.from_file' do
    let(:port_placeholder) { '$PORT' }
    let(:port) { '3000' }
    let(:name) { 'admin' }
    let(:domain) { 'dev' }

    let(:temp_dir) { Dir.mktmpdir }
    let(:temp_file) do
      File.new(temp_dir + File::Separator + 'temp.conf', 'w+').tap do |file|
        file.write(content)
        file.rewind
      end
    end
    let(:content) do
      %(
        server {
          listen       80;
          server_name  #{name}.#{domain};

          location / {
              proxy_pass http://127.0.0.1:#{port_placeholder};
          }
        }
      )
    end

    after { FileUtils.rm_rf(temp_dir) }

    context 'file has no $PORT placeholder' do
      let(:port_placeholder) { '$NOT_PORT' }
      it { expect { described_class.from_file(port, temp_file) }.to raise_error(StandardError) }
    end

    context 'file has $PORT placeholder' do
      let(:port_placeholder) { '$PORT' }
      it { expect { described_class.from_file(port, temp_file) }.not_to raise_error }
    end

    it 'creates conf from file' do
      conf = described_class.from_file(port, temp_file)
      expect(conf.port).to eq(port)
      expect(conf.name).to eq(name)
      expect(conf.domain).to eq(domain)
      expect(conf.output).to eq(content.gsub(port_placeholder, port))
    end
  end

  describe '#initialize' do
    let(:port) { 3000 }
    let(:name) { 'admin' }
    let(:domain) { 'dev' }

    context 'without existing_conf_content' do
      it 'sets output to default_conf_content' do
        conf = described_class.new(port, name)
        expect(conf.output).to eq(conf.default_conf_content)
      end
    end

    context 'with existing_conf_content' do
      let(:existing_conf_content) { 'example conf config' }

      it 'sets output to existing_conf_content' do
        conf = described_class.new(port, name, domain, existing_conf_content)
        expect(conf.output).to eq(existing_conf_content)
      end
    end
  end

  describe '#default_conf_content' do
    let(:name) { 'admin' }
    let(:port) { '3000' }
    let(:domain) { 'dev' }
    let(:default_config) do
      %(
        server {
          listen       80;
          server_name  #{name}.#{domain};

          location / {
              proxy_pass http://127.0.0.1:#{port};
          }
        }
      )
    end

    it 'should return a default conf' do
      conf = described_class.new(port, name, domain)
      expect(conf.output).to eq(default_config)
    end
  end

  describe '#server_name' do
    let(:name) { 'admin' }
    let(:port) { '3000' }
    let(:domain) { 'dev' }

    it 'returns server_name' do
      conf = described_class.new(port, name, domain)
      expect(conf.server_name).to eq("#{name}.#{domain}")
    end
  end

  describe '#filename' do
    let(:name) { 'admin' }
    let(:port) { '3000' }
    let(:temp_dir) { '/temp' }

    before { allow(PortMap::Nginx).to receive(:servers_directory) { temp_dir } }

    it 'returns filename' do
      conf = described_class.new(port, name)
      expect(conf.filename).to eq(temp_dir + File::Separator + name + '.port_map.conf')
    end
  end

  describe '#save' do
    let(:name) { 'admin' }
    let(:port) { '3000' }
    let(:temp_dir) { Dir.mktmpdir }

    before { allow(PortMap::Nginx).to receive(:servers_directory) { temp_dir } }
    after { FileUtils.rm_rf(temp_dir) }

    it 'saves output(default conf) to filename' do
      conf = described_class.new(port, name)
      conf.save
      expect(File.exist?(conf.filename)).to be true
      expect(File.new(conf.filename).read).to eq(conf.default_conf_content)
    end
  end
end
