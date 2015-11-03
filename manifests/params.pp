# chocolatey_server::params
#
# This class is meant to be called from chocolatey_server.
# It sets variables according to platform.
class chocolatey_server::params {
  case $::osfamily {
    'windows': {
      $service_port          = '80'
      $server_package_source = 'https://chocolatey.org/api/v2/'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
