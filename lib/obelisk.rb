require "obelisk/version"

require "active_directory"
require "yaml"
require "erb"
require "logger"
require "fileutils"

module Obelisk
  DEFAULT_CONFIG_PATH = "#{Dir.home}/.obelisk.conf"
  DEFAULT_CONFIG = {
    :ad_settings => {
      ldap_host:                "localhost",
      base_dn:                  "ou=STAFF,dc=CORP,dc=LOCAL",
      bind_name:                "user",
      bind_pass:                "pass",
    },
    :mapping => {
      samaccountname:           :peer,
      info:                     :secret,
      facsimiletelephonenumber: :context,
      ipphone:                  :extension,
      pager:                    :callgroup,
      # Used for AdressBook generation
      displayname:              :name,
      mobile:                   :mobile,
      homephone:                :home,
      company:                  :company,
      department:               :department,
      title:                    :title,
    },
    :defaults => {
      facsimiletelephonenumber: "from-internal"
    },
    :asterisk_conf_dir =>       "/tmp/asterisk",
    :erb_file_dir =>            File.expand_path(File.dirname(__FILE__) + "/../erb")
  }

  $conf = {}

  def self.make_erb_conf
    FileUtils.mkdir_p $conf[:asterisk_conf_dir]
    b = binding
    users = get_ad_users
    Dir[File.expand_path "*.erb", $conf[:erb_file_dir]].each do |erb|
      conf_file = File.expand_path File.basename(erb, ".erb"), $conf[:asterisk_conf_dir]
      File.open(conf_file, "w") { |file| file.write ERB.new(IO.read(erb), nil, "-").result(b) }
    end
  end

  def self.get_ad_users(ou = nil)
    load_conf
    settings = {
      :host => $conf[:ad_settings][:ldap_host],
      :base => (ou ? "ou=#{ou},#{$conf[:ad_settings][:base_dn]}" : $conf[:ad_settings][:base_dn]),
      :port => 389,
      :auth => {
        :method => :simple,
        :username => $conf[:ad_settings][:bind_name],
        :password => $conf[:ad_settings][:bind_pass],
      }
    }
    ActiveDirectory::Base.setup(settings)
    ActiveDirectory::User.find(:all).select{ |u| u.valid_attribute? :info }.map do |u|
      k = $conf[:mapping].values
      v = $conf[:mapping].keys.map { |attr| u.valid_attribute?(attr) ? u.send(attr) : $conf[:defaults][attr] }
      Hash[k.zip v]
    end
  end

  def self.save_def_conf(file_name = DEFAULT_CONFIG_PATH)
    conf = DEFAULT_CONFIG
    if File.exists? file_name
      merge_proc = proc { |k, o, n| o.is_a?(Hash) && n.is_a?(Hash) ? o.merge(n, &merge_proc) : n }
      conf.merge! YAML.load(IO.read(file_name)), &merge_proc
    end
    File.open(file_name, 'w') { |f| f.write YAML.dump conf }
  end

  def self.load_conf(file_name = DEFAULT_CONFIG_PATH)
    return unless $conf.empty?
    begin
      $conf = YAML.load IO.read file_name
    rescue
      $conf = DEFAULT_CONFIG
    end
  end
end