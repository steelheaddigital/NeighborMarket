require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  
  test "item_quantity_label should be pluralized if unit is not each and is quantity is greater than 1" do
    item = InventoryItem.new(:price_unit => "pound")
    assert_equal "pounds", item_quantity_label(item, 2)
  end
  
  test "item_quantity_label should be singular if unit is not each and quantity is equal to 1" do
    item = InventoryItem.new(:price_unit => "pound")
    assert_equal "pound", item_quantity_label(item, 1)
  end
  
  test "item_quantity_label should return nothing if unit is each" do
    item = InventoryItem.new(:price_unit => "each")
    assert_equal nil, item_quantity_label(item, 2)
  end
  
  test "price_unit_label should return per if unit is not each" do
    item = InventoryItem.new(:price_unit => "pound")
    assert_equal "per pound", price_unit_label(item)
  end
  
  test "price_unit_label should not return per if unit is each" do
    item = InventoryItem.new(:price_unit => "each")
    assert_equal "each", price_unit_label(item)
  end
  
end