require 'rails_helper'

RSpec.describe Book, type: :model do
  describe 'validations' do
    subject { create(:book) }

    it { should validate_presence_of(:title) }

    it { should validate_presence_of(:publisher) }

    it { should validate_presence_of(:published_at) }

    it { should validate_presence_of(:pages_count) }

    it { should validate_numericality_of(:pages_count).only_integer.is_greater_than_or_equal_to(1) }

    it { should validate_numericality_of(:weight).is_greater_than_or_equal_to(0.0).allow_nil }

    it { should validate_length_of(:isbn_10).is_equal_to(10) }

    it { should validate_length_of(:isbn_13).is_equal_to(13) }

    it { should validate_uniqueness_of(:isbn_10).case_insensitive.allow_nil }

    it { should validate_uniqueness_of(:isbn_13).case_insensitive.allow_nil }
  end

  describe 'associations' do
    it { should { belong_to(:publisher) } }

    it { should { have_and_belong_to_many(:authors) } }

    it { should { have_and_belong_to_many(:genres) } }

    it { should { have_many(:stocks) } }

    it { should { have_many(:shops).through(:stocks) } }

    it { should { have_many(:sales) } }
  end

  describe '.search' do
    let(:book) { create(:book, title: 'wat book') }

    it 'returns book with a matching title' do
      expect(described_class.search(book.title)).to eq([book])
    end

    it 'returns book with a partially matching title' do
      expect(described_class.search(book.title[0..2])).to eq([book])
    end

    it 'returns book with a matching title regardless of the casing' do
      expect(described_class.search(book.title.upcase)).to eq([book])
    end
  end
end
