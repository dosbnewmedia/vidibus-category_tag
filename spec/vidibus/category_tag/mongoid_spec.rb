require 'spec_helper'

class Movie
  include Mongoid::Document
  include Vidibus::CategoryTag::Mongoid
end

class Western < Movie
  tags_separator ';'
end

describe Vidibus::CategoryTag::Mongoid do
  let(:subject) { Movie.new }
  let(:uuid) { 'a068ff70a523012d26d158b035f038ab' }
  let(:uuid2) { '7d4ef7d0974a012d10ad58b035f038ab' }
  let(:category) do
    obj = FactoryBot.create(:tag_category, :uuid => uuid)
    allow(subject).to receive(:tag_category).with(uuid) { obj }
    obj
  end

  let(:category2) do
    obj = FactoryBot.create(:tag_category, :uuid => uuid2)
    allow(subject).to receive(:tag_category).with(uuid2) { obj }
    obj
  end

  describe 'saving' do
    before do
      category
    end

    it 'should set tags on tag category' do
      subject.update_attributes(:tags => {uuid => 'rugby'})
      expect(subject.tags[uuid]).to eq("rugby")
    end

    it 'should persist tag category' do
      allow(category).to receive(:save)
      subject.update_attributes(:tags => {uuid => 'rugby'})
    end

    it 'should not persist tag category if tags did not have been changed' do
      subject.update_attributes(:tags => {uuid => 'rugby'})
      expect(category).to_not receive(:save)
      subject.update_attributes(:tags => {uuid => 'rugby'})
    end

    it 'should not store tags of a different category' do
      category2
      expect(category).to_not receive(:save)
      subject.update_attributes(:tags => {uuid2 => 'football'})
    end

    it 'should only persist a tag category if tags did change' do
      category2
      subject.update_attributes(:tags_hash => {uuid => ['rugby'], uuid2 => ['1']})
      expect(category).to_not receive(:save)
      subject.update_attributes(:tags_hash => {uuid => ['rugby'], uuid2 => ['2']})
    end
  end

  describe '#tags=' do
    it 'should save a hash as tags with category' do
      subject.tags = {'1' => 'rugby'}
      expect(subject.tags_hash).to eq({'1' => ['rugby']})
    end

    it 'should save tags as array' do
      subject.tags = {'1' => 'us, br'}
      expect(subject.tags_hash).to eq({'1' => ['us', 'br']})
    end

    it 'should save tags separated by semicolon' do
      subject = Western.new
      subject.tags = {'1' => 'us; br'}
      expect(subject.tags_hash).to eq({'1' => ['us', 'br']})
    end

    it 'should not save empty tags' do
      subject.tags = {'1' => ''}
      expect(subject.tags_hash).to eq({})
    end

    it 'should accept tags as array' do
      subject.tags = {'1' => %w[us br]}
      expect(subject.tags_hash).to eq({'1' => ['us', 'br']})
    end

    it 'should add multiple keys as category' do
      subject.tags = {'1' => 'rugby', '2' => 'us, br'}
      expect(subject.tags_hash).to eq({'1' => ['rugby'], '2' => ['us', 'br']})
    end

    it 'should not add an array as tag' do
      tags = ['1', 'rugby']
      expect { subject.tags = tags }.
        to raise_error(Vidibus::CategoryTag::Error)
    end

    it 'should not add a string as tag' do
      expect { subject.tags = '1' }.
        to raise_error(Vidibus::CategoryTag::Error)
    end

    it 'should remove a trailing separator' do
      subject.tags = {'1' => 'rugby,'}
      expect(subject.tags_hash).to eq({'1' => ['rugby']})
    end

    it 'should override tags' do
      subject.tags = {'1' => 'rugby'}
      subject.tags = {'2' => 'us'}
      expect(subject.tags_hash).to eq({'2' => ['us']})
    end
  end

  describe '#tags' do
    it 'should be empty by default' do
      expect(subject.tags).to eq({})
    end

    it 'should be a string' do
      subject.tags_hash = {'1' => ['us', 'br']}
      expect(subject.tags).to eq({'1' => 'us,br'})
    end

    it 'should be separated by semicolon when defined' do
      subject = Western.new
      subject.tags_hash = {'1' => ['us', 'br']}
      expect(subject.tags).to eq({'1' => 'us;br'})
    end
  end

  describe '#tags[]' do
    it 'should add tags to an existing hash' do
      skip 'Second iteration'
    end
  end

  describe '.clean_tags_array' do
    it 'should return an array' do
      input = ['some', 'thing']
      expect(Movie.clean_tags_array(input)).to eq(input)
    end

    it 'should return a stripped array' do
      expect(Movie.clean_tags_array(['some ', ' thing'])).
        to eq(['some', 'thing'])
    end

    it 'should return an array without blanks' do
      expect(Movie.clean_tags_array(['some', ' ', 'thing'])).
        to eq(['some', 'thing'])
    end

    it 'should return an array from string input separated by comma' do
      expect(Movie.clean_tags_array('some,thing')).
        to eq(['some', 'thing'])
    end

    it 'should return an array from string input separated by semicolon' do
      expect(Western.clean_tags_array('some;thing')).
        to eq(['some', 'thing'])
    end

    it 'should strip string input' do
      expect(Movie.clean_tags_array(' some, thing ')).
        to eq(['some', 'thing'])
    end
  end
end
