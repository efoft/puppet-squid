# @summary  Installs and configures squid.
#
# @param transparent
#   If the proxy server should run in transparent mode. That means packets going to the web
#   will be intercepted by firewall and redirected to the proxy port. Firewall configuration
#   must be additionally performed.
#
# @param servername    Visible proxy server name.
# @param myip          IP address on with proxy will accept clients requests.
# @param ssl_ports     If specified, it will replace default list in config file.
# @param myacl         Array of IP or IP/prefix - who allowed to go through proxy. If undef whole LAN is allowed.
#
class squid(
  Enum['present','absent'] $ensure      = 'present',
  Boolean                  $transparent = false,
  String                   $servername  = $facts['networking']['fqdn'],
  Stdlib::Ip::Address      $listen_ip   = $facts['networking']['ip'],
  Array[Numeric]           $ssl_ports   = [443],
  Optional[Array]          $myacl       = undef,
) inherits squid::params {

  # In EL7 localhost and manager acls are pre-defined
  $define_manager_localhost = fact('os.release.major') ?
  {
    '7' => false,
    '6' => true,
  }

  package { $package_name:
    ensure => $ensure ? { 'absent' => 'purged', 'present' => 'installed' },
  }

  file { $cfgfile:
    ensure     => $ensure,
    content    => template('squid/squid.conf.erb'),
    require    => Package[$package_name],
    notify     => Service[$service_name],
  }

  service { $service_name:
    ensure     => $ensure ? { 'present' => running, 'absent' => undef },
    enable     => $ensure ? { 'present' => true, 'absent'    => undef },
    hasstatus  => true,
    hasrestart => true,
  }
}
