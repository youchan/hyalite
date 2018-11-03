require "test_helper"

module Hyalite
  class DOMPropertyTest < Opal::Test::Unit::TestCase
    # DOMProperty#is_custom_attribute
    test "'data-xxx' is true" do
      result = Hyalite::DOMProperty.is_custom_attribute('data-xxxx')

      assert(result)
    end

    test "'xxx' is false" do
      result = Hyalite::DOMProperty.is_custom_attribute('xxxx')

      assert_equal(false, result)
    end
  end
end
