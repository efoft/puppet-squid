#
class squid::params {
  
  case $facts['os']['family'] {
    'RedHat': {
      $package_name = 'squid'
      $service_name = 'squid'
      $cfgfile      = '/etc/squid/squid.conf'
    }
    default: {
      fail('Sorry! Your OS is not supported')
    }
  }
}
