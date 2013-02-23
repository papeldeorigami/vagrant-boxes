# based on this post: http://vagrantup.com/docs/getting-started/index.html
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

# if $rvm_installed == "true" {
    rvm_system_ruby {
      'ruby-1.9.3-p374':
        ensure => 'present';
    }
#}
}

class doinstall {
  class { requirements:, stage => "req-install" }
  include installrvm
}

include doinstall

