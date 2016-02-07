require 'spec_helper'

RSpec.describe PortMap::Hosts do
  describe '.update' do
    let(:contents) { 'line' }
    let(:expected_contents) { [contents, "127.0.0.1 #{servers.join(' ')} #{described_class::PORT_MAP_TRACK_COMMENT}"].join("\n") }
    let(:port_maps) { servers.map { |server| { 'server_name' => server } } }

    before do
      allow(described_class).to receive(:contents) { contents }
      allow(JSON).to receive(:parse) { port_maps }
    end

    context 'with no port_maps' do
      let(:servers) { [] }
      let(:expected_contents) { contents }

      it 'does not change the contents' do
        expect(described_class).to receive(:save).with(expected_contents)
        described_class.update
      end
    end

    context 'with one port_map' do
      let(:servers) { ['server_a'] }

      it 'adds server and port map track comment' do
        expect(described_class).to receive(:save).with(expected_contents)
        described_class.update
      end
    end

    context 'with multiple port_maps' do
      let(:servers) { ['server_a', 'server_b'] }

      it 'adds servers and port map track comment' do
        expect(described_class).to receive(:save).with(expected_contents)
        described_class.update
      end
    end
  end

  describe '#save' do
    let(:temp_dir) { Dir.mktmpdir }
    let(:temp_file) { File.new(temp_dir + File::Separator + 'hosts', 'w+') }
    let(:content) { 'example_content' }

    before { stub_const('PortMap::Hosts::HOSTS_FILENAME', temp_file.path) }
    after { FileUtils.rm_rf(temp_dir) }

    it 'saves output(default conf) to filename' do
      described_class.save(content)
      expect(temp_file.read).to eq(content)
    end
  end

  describe '.contents' do
    before { allow(File).to receive(:readlines).with(PortMap::Hosts::HOSTS_FILENAME) { content } }

    context 'content has no port map track comment' do
      let(:content) { ['normal line', 'line with no comment'] }

      it 'returns all lines of content' do
        expect(described_class.contents).to eq(content.join)
      end
    end

    context 'content has port map track comment' do
      let(:content) { ['normal line', "line with port map track comment #{described_class::PORT_MAP_TRACK_COMMENT}"] }

      it 'returns all lines of content' do
        expect(described_class.contents).to eq(content.first)
      end
    end
  end
end
