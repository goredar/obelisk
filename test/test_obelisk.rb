require "test/unit"
require "obelisk"

class ObeliskTestCase < Test::Unit::TestCase
  def test_save_conf
    test_conf_file = "/tmp/.obelisk.conf"
    File.delete(test_conf_file) if File.exist?(test_conf_file)
    Obelisk.save_def_conf test_conf_file
    assert File.exist?(test_conf_file)
    assert_equal YAML.dump(Obelisk::DEFAULT_CONFIG), IO.read(test_conf_file)
    File.delete(test_conf_file)
  end
end