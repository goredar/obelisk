require "test/unit"
require "obelisk"
require "securerandom"

class ErbTestCase < Test::Unit::TestCase
  def test_make_erb_conf
    dir = "/tmp/#{SecureRandom.hex}"
    $conf[:asterisk_conf_dir] = dir
    Obelisk.make_erb_conf
    assert Dir.exists? dir
    assert_equal Dir[File.expand_path "*.erb", $conf[:erb_file_dir]].count, Dir[File.expand_path "*", dir].count
    puts %x(cat #{dir}/*)
    File.delete *Dir[File.expand_path "*", dir]
    Dir.rmdir dir
  end
end