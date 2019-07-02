require 'spec_helper'

describe TagCategory do
  describe 'validation' do
    it 'should pass with valid attributes' do
      expect(FactoryBot.create(:tag_category)).to be_valid
    end
  end

  describe '#callname' do
    it 'sould be set from label before validation, unless provided' do
      category = FactoryBot.build(:tag_category, :label => 'Rating', :callname => nil)
      category.valid?
      expect(category.callname).to eq('rating')
    end

    it 'sould not be set from label unless a label is available' do
      category = FactoryBot.build(:tag_category, :label => nil, :callname => nil)
      category.valid?
      expect(category.callname).to be_nil
    end
  end

  describe '#context' do
    before do
      @first = FactoryBot.create(:tag_category, :context => ['realm:100', 'model:movie'])
      @second = FactoryBot.create(:tag_category, :context => ['realm:100', 'model:photo'])
      @third = FactoryBot.create(:tag_category)
    end

    it 'should use a filter to find one record' do
      expect(TagCategory.context({:model => 'movie'}).map(&:id)).to eq([@first.id])
    end

    it 'should use a filter to find several records' do
      expect(TagCategory.context({:realm => 100}).map(&:id)).to eq([@first.id, @second.id])
    end

    it 'should use a more complex filter to find one record' do
      filter = {:realm => 100, :model => 'photo'}
      expect(TagCategory.context(filter).map(&:id)).to eq([@second.id])
    end

    it 'should find nothing' do
      expect(TagCategory.context({:foo => 'bar'}).count).to eq(0)
    end

    it 'should find all records' do
      expect(TagCategory.context({}).count).to eq(3)
    end
  end

  describe '#tags' do
    it 'should be an empty array by default' do
      expect(TagCategory.new.tags).to eq([])
    end

    it 'should be made unique before validation' do
      category = FactoryBot.build(:tag_category, :tags => %w[tag1 tag2 tag1])
      category.valid?
      expect(category.tags).to eq(%w[tag1 tag2])
    end
  end

  describe '#context' do
    it 'should be an empty array by default' do
      expect(TagCategory.new.context).to eq([])
    end
  end

  describe '.sort!' do
    before do
      @first = FactoryBot.create(:tag_category, :context => ['realm:100', 'model:movie'])
      @second = FactoryBot.create(:tag_category, :context => ['realm:100', 'model:movie'])
      @third = FactoryBot.create(:tag_category, :context => ['realm:101', 'model:movie'])
      @fourth = FactoryBot.create(:tag_category, :context => ['realm:101', 'model:movie'])
    end

    it 'should put items in order' do
      order = [@third.uuid, @second.uuid, @first.uuid, @fourth.uuid]
      TagCategory.sort!(order)
      expect(TagCategory.sorted.map {|t| t.uuid}).to eq(order)
    end

    it 'should remove items not in list' do
      order = [@third.uuid, @first.uuid, @fourth.uuid]
      TagCategory.sort!(order)
      expect(TagCategory.sorted.map {|t| t.uuid}).to eq(order)
    end

    it 'should accept order with prefix' do
      order = [@third.uuid, @second.uuid, @first.uuid, @fourth.uuid]
      TagCategory.sort!(order.map {|o| "prefix-#{o}"})
      expect(TagCategory.sorted.map {|t| t.uuid}).to eq(order)
    end

    context 'in context' do
      let(:context) do
        {:realm => 100, :model => 'movie'}
      end

      it 'should put items in order' do
        order = [@second.uuid, @first.uuid]
        TagCategory.in_context(context).sort!(order)
        expect(TagCategory.in_context(context).sorted.map {|t| t.uuid}).to eq(order)
      end

      it 'should remove items not in list' do
        order = [@second.uuid]
        TagCategory.in_context(context).sort!(order)
        expect(TagCategory.in_context(context).sorted.map {|t| t.uuid}).to eq(order)
      end

      it 'should not touch items not in context' do
        order = [@third.uuid, @second.uuid]
        TagCategory.in_context(context).sort!(order)
        expect(TagCategory.in_context(context).sorted.map {|t| t.uuid}).to eq([@second.uuid])
        expect(TagCategory.in_context(:realm => 101, :model => 'movie').count).to eq(2)
      end
    end
  end
end
