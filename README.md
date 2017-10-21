# puppet-squid module

Installs and configures Squid caching proxy server on RHEL, CentOS.

## Installation
Clone into puppet's modules directories.
```
git clone https://github.com/efoft/puppet-squid.git squid
```

## Example of usage

By default it installs as tranparent proxy with 443 SSL-port and allows connection from local network determined by facter.
For this just include the class:
```
include ::squid
```

To customize setting define as parameterized class:
```
class { '::squid':
  transparent => true,
  myip        => '192.168.1.1',
  myacl       => ['192.168.1.0/24', '172.16.16.0/24'],
}
```
