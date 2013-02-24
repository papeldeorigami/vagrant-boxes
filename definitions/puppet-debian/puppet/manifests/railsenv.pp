# based on this post:
# http://phaseshiftllc.com/articles/2012/03/19/setting-up-vagrant-with-rvm-and-mysql-for-rails-development.html
stage { 'req-install': before => Stage['rvm-install'] }

class requirements {
  group { "puppet": ensure => "present", }
  exec { "apt-update":
    command => "/usr/bin/apt-get -y update"
  }

  package {
    ["libmagick++-dev", "postgresql", "libpqxx3-dev" ,"sqlite3", "libsqlite3-dev", "sphinxsearch"]:
      ensure => installed, require => Exec['apt-update']
  }
}

class installrvm {
  include rvm
  rvm::system_user { vagrant: ; }

  rvm_system_ruby {
    'ruby-1.9.3-p374': ensure => 'present';
  }
}

class doinstall {
  class { requirements:, stage => "req-install" }
  include installrvm
}

include doinstall

