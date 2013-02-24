require 'net/http'

Veewee::Definition.declare( {
  :cpu_count => '1', :memory_size=> '256',
  :disk_size => '10140', :disk_format => 'VDI',:hostiocache => 'off',
  :os_type_id => 'Linux',
  :iso_file => "Core-4.7.4.iso",
  :iso_src => "http://tinycorelinux.net/4.x/x86/release/Core-4.7.4.iso",
  :iso_md5 => "2c99a6cd27f781f6862f98e1841b829c",
  :iso_download_timeout => "1000",
  :boot_wait => "3",:boot_cmd_sequence => [
        '<Enter>',
        '<Wait>'*5,
        'tce-load -w -i openssh.tcz<Enter>',
        '<Wait>'*40,
        'tce-load -w -i bash.tcz<Enter>',
        '<Wait>'*20,
        'sudo su<Enter>',
        '<Enter><Enter>',
        'chpasswd<Enter>',
        '<Wait>',
        'root:vagrant<Enter>',
        '<Wait><Enter>',
        'cd /usr/local/etc/ssh<Enter>',
        'cp ssh_config.example ssh_config<Enter>',
        'cp sshd_config.example sshd_config<Enter>',
        '/usr/local/etc/init.d/openssh start<Enter>',
        'cd ~<Enter>'
    ],
  :kickstart_port => "7122", :kickstart_timeout => "10000",:kickstart_file => "",
  :ssh_login_timeout => "10000",:ssh_user => "root", :ssh_password => "vagrant",:ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "cat '%f'|su -",
  :shutdown_cmd => "shutdown -p now",
  :postinstall_files => [ "postinstall.sh"],:postinstall_timeout => "10000"
   }
)
