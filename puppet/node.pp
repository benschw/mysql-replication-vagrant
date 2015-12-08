Exec { path => "/usr/bin:/usr/sbin:/bin:/sbin" }

# fix dnsmasq, which looks for /bin/test
file { '/bin/test':
  ensure => 'link',
  target => '/usr/bin/test',
}

stage { 'preinstall':
  before => Stage['main']
}
 
class apt_get_update {
  exec { 'apt-get -y update': }
}

class { 'apt_get_update':
  stage => preinstall
}

notice("Loading role")
hiera_include('role')

node default {
}

