require "test/unit"
require "obelisk"

class ObeliskTestCase < Test::Unit::TestCase
  def test_config
    test_conf_file = Obelisk::DEFAULT_CONFIG_PATH
    File.delete test_conf_file
    Obelisk.gen_def_conf
    assert File.exist?(test_conf_file)
    assert_equal YAML.dump(Obelisk::DEFAULT_CONFIG), IO.read(test_conf_file)
  end
end