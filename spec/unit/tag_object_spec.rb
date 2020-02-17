require 'spec_helper'

describe TagObject do
  let(:tag_object) {FactoryBot.build(:tag_object) }

  describe 'validation' do
    it 'should pass with valid attributes' do
      expect(tag_object).to be_valid
    end

    it 'should fail without a value' do
      tag_object.value = nil
      expect(tag_object).to be_invalid
    end
  end
end
