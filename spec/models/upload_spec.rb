require 'rails_helper'

describe Upload do
  describe 'associations' do
    it { should belong_to(:model) }
  end

  describe 'validations' do
    it { should validate_presence_of(:size) }
    it { should validate_presence_of(:path) }
    it { should validate_presence_of(:model) }
    it { should validate_presence_of(:uploader) }
  end

  describe 'callbacks' do
    context 'for a file at or below the checksum threshold' do
      it 'calculates checksum immediately before save' do
        upload = described_class.new(
          path: __FILE__,
          size: described_class::CHECKSUM_THRESHOLD,
          model: build_stubbed(:user),
          uploader: double('ExampleUploader')
        )

        expect { upload.save }
          .to change { upload.checksum }.from(nil)
          .to(a_string_matching(/\A\h{64}\z/))
      end
    end

  end

  describe '#absolute_path' do
    it 'returns the path directly when already absolute' do
      path = '/path/to/namespace/project/secret/file.jpg'
      upload = described_class.new(path: path)

      expect(upload).not_to receive(:uploader_class)

      expect(upload.absolute_path).to eq path
    end

    it "delegates to the uploader's absolute_path method" do
      uploader = spy('FakeUploader')
      upload = described_class.new(path: 'secret/file.jpg')
      expect(upload).to receive(:uploader_class).and_return(uploader)

      upload.absolute_path

      expect(uploader).to have_received(:absolute_path).with(upload)
    end
  end

  describe '#calculate_checksum!' do
    let(:upload) do
      described_class
        .new(path: __FILE__, size: described_class::CHECKSUM_THRESHOLD - 1.megabyte)
    end

    it 'sets `checksum` to SHA256 sum of the file' do
      expected = Digest::SHA256.file(__FILE__).hexdigest

      expect { upload.calculate_checksum! }
        .to change { upload.checksum }.from(nil).to(expected)
    end

    it 'sets `checksum` to nil for a non-existent file' do
      expect(upload).to receive(:exist?).and_return(false)

      checksum = Digest::SHA256.file(__FILE__).hexdigest
      upload.checksum = checksum

      expect { upload.calculate_checksum! }
        .to change { upload.checksum }.from(checksum).to(nil)
    end
  end

  describe '#exist?' do
    it 'returns true when the file exists' do
      upload = described_class.new(path: __FILE__)

      expect(upload).to exist
    end

    it 'returns false when the file does not exist' do
      upload = described_class.new(path: "#{__FILE__}-nope")

      expect(upload).not_to exist
    end
  end
end
