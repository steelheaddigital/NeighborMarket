require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def test_should_not_save_without_some_stuff
    user = User.new
    assert !user.save
  end
end
