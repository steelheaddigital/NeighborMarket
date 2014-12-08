require 'test_helper'

class SiteContentTest < ActiveSupport::TestCase

  test "should not validate if require_terms_of_service is true and terms_of_service is blank" do
    site_content = SiteContent.new(:terms_of_service => "", :require_terms_of_service => true)
    assert !site_content.valid?, site_content.errors.inspect
  end

  test "new_content returns new site_contents" do
    settings = { :site_description => "Desc", :inventory_guidelines => "Test Guidelines", :terms_of_service => "Test TOS", :require_terms_of_service => true }
    result = SiteContent.new_content(settings)
    
    assert_not_nil(result)
  end

end