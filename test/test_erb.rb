require "test/unit"
require "obelisk"
require "securerandom"

class ErbTestCase < Test::Unit::TestCase
  def test_make_erb_conf
    begin
      dir = "/tmp/#{SecureRandom.hex}"
      assert Obelisk.make_erb_conf :conf_dir => dir
      assert Dir.exists? dir
      assert_equal Dir[File.expand_path "*.erb", $conf[:erb_file_dir]].count, Dir[File.expand_path "*", dir].count
      assert ! Obelisk.make_erb_conf(:conf_dir => dir)
      assert Obelisk.make_erb_conf :conf_dir => dir, :force => true
      assert ! Obelisk.make_erb_conf(:conf_dir => dir)
      puts %x(cat #{dir}/*)
    ensure
      File.delete *Dir[File.expand_path "*", dir]
      Dir.rmdir dir
    end
  end
end