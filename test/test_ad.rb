require "test/unit"
require "obelisk"

class ADTestCase < Test::Unit::TestCase
  def test_get_users
    users = Obelisk.get_ad_users
    assert users.count > 0
    users = Obelisk.get_ad_users "non-exists"
    assert_equal 0, users.count
  end
end