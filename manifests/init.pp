# === Class squid ===
#
# Installs and configures squid.
#
# === Parameters ===
# [*transparent*]
#   If the proxy server should run in transparent mode. That means packets going to the web
#   will be intercepted by firewall and redirected to the proxy port. Firewall configuration
#   must be additionally performed.
#   Default: false
#
# [*servername*]
#   Visible proxy server name.
#   Default: fqdn fact
#
# [*myip*]
#   IP address on with proxy will accept clients requests.
#   Default: ip address fact
#
# [*ssl_ports*]
#   If specified, it will replace default list in config file.
#   Default: 443
#
# [*myacl*]
#   Array of IP or IP/prefix - who allowed to go
#   through proxy. If undef whole LAN is allowed.
#   Default: undef
#
class squid(
  Enum['present','absent'] $ensure     = 'present',
  Boolean $transparent                 = false,
  String $servername                   = $facts['networking']['fqdn'],
  Stdlib::Ip::Address $myip            = $facts['networking']['ip'],
  Array[Numeric] $ssl_ports            = [443],
  Optional[Array] $myacl               = undef,
) inherits squid::params {

  $network = $facts['networking']['network']
  $prefix  = $facts['networking']['netmask'] ? {
    '255.255.255.0' => '24',
    '255.255.0.0'   => '16',
    '255.0.0.0'     => '8',
    default         => $facts['networking']['netmask']
  }
  $mynetwork = "${network}/${prefix}"

  package { $squid::params::package_name:
    ensure => $ensure ? { 'absent' => 'purged', 'present' => 'installed' },
  }

  file { $squid::params::cfgfile:
    ensure     => $ensure,
    content    => template('squid/squid.conf.erb'),
    require    => Package[$squid::params::package_name],
    notify     => Service[$squid::params::service_name],
  }

  service { $squid::params::service_name:
    ensure     => $ensure ? { 'present' => running, 'absent' => undef },
    enable     => $ensure ? { 'present' => true, 'absent'    => undef },
    hasstatus  => true,
    hasrestart => true,
  }
}
