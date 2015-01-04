require 'test_helper'

class SiteContentTest < ActiveSupport::TestCase

  test "should not validate if require_terms_of_service is true and terms_of_service is blank" do
    site_content = SiteContent.instance
    site_content.update(:terms_of_service => "", :require_terms_of_service => true)
    assert !site_content.valid?, site_content.errors.inspect
  end

end