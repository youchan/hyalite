require 'spec_helper'

describe Hyalite::DOMProperty do
  describe '#is_custom_attribute' do
    it "is true for 'data-xxx'" do
      result = Hyalite::DOMProperty.is_custom_attribute('data-xxxx')

      expect(result).to eq(true)
    end

    it "is false for 'xxx'" do
      result = Hyalite::DOMProperty.is_custom_attribute('xxxx')

      expect(result).to eq(false)
    end
  end
end
