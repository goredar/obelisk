require "obelisk/version"

require "active_directory"
require "yaml"
require "logger"

module Obelisk
  DEFAULT_CONFIG_PATH = "./.obelisk.conf"
  DEFAULT_CONFIG = {
    :ad_settings => {
      ldap_host:                "localhost",
      base_dn:                  "OU=STAFF,DC=CORP,DC=LOCAL",
      bind_name:                "user",
      bind_pass:                "pass",
    },
    :mapping => {
      facsimileTelephoneNumber: :secret,
      ipPhone:                  :extension,
      sAMAccountName:           :peer,
      pager:                    :callgroup,
      # Used for AdressBook generation
      homePhone:                :none,
      mobile:                   :none,
      displayName:              :none,
      company:                  :none,
      department:               :none,
      title:                    :none,
    },
    :asterisk_settings => {
      channel_driver:           :sip,
      template:                 "simple",
    },
  }
  CONFIG = {}

  LOG = Logger.new STDERR
  LOG.level = Logger::WARN

  def self.gen_def_conf(file_name = DEFAULT_CONFIG_PATH)
    File.open file_name, 'w' do |f|
      f.write YAML.dump DEFAULT_CONFIG
    end
  end
  
  def self.load_conf(file_name = DEFAULT_CONFIG_PATH)
    return unless CONFIG.empty?
    begin
      CONFIG = YAML.load IO.read file_name
    rescue
      LOG.error "Unable to load config file. Using default values."
      CONFIG = DEFAULT_CONFIG
    end
  end

  def self.get_ad_users
    #Bind
    settings = {
      :host => conf[:ldap_host],
      :base => conf[:base_dn],
      :port => 389,
      :auth => {
                :method => :simple,
                :username => conf[:bind_name],
                :password => conf[:password]
               }
    }
end
