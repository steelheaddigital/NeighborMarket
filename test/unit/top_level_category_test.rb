require 'test_helper'

class TopLevelCategoryTest < ActiveSupport::TestCase
 test "category does not validate without name" do
    category = TopLevelCategory.new
    
    assert !category.valid?
  end
end
