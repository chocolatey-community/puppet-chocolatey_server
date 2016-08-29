# chocolatey_server - Host your own Chocolatey package repository
#
# @author Rob Reynolds and puppet-chocolatey_server contributors
#
# @example Default - install the server
#   include chocolatey_server
#
# @example Use a different port
#   class {'chocolatey_server':
#     port => '8080',
#   }
#
# @example Use an internal source for installing the `chocolatey.server` package
#   class {'chocolatey_server':
#     server_package_source => 'http://someinternal/nuget/odatafeed',
#   }
#
# @example Use a local file source for the `chocolatey.server` package
#   class {'chocolatey_server':
#     server_package_source => 'c:/folder/containing/packages',
#   }
#
# @param [String] port The port for the server website. Defaults to '80'.
# @param [String] server_package_source The chocolatey source that contains
#   the `chocolatey.server` package. Defaults to
#   'https://chocolatey.org/api/v2/'.
# @param [String] server_install_location The location to that the chocolatey
#   server will be installed.  This is can be used if you are controlling
#   the location that chocolatey packages are being installed via some other
#   means. e.g. environment variable ChocolateyBinRoot.  Defaults to
#   'C:\tools\chocolatey.server'
class chocolatey_server (
  $service_port          = '80',
  $server_package_source = 'https://chocolatey.org/api/v2/',
  $server_install_location = 'C:\tools\chocolatey.server',
  $chocolatey_server_app_pool_name = 'chocolatey.server',
  $chocolatey_server_app_port      = $port,
) {
  require chocolatey

  # package install
  package {'chocolatey.server':
    ensure   => installed,
    provider => chocolatey,
    source   => $server_package_source,
  } ->

  # add windows features
  windowsfeature { 'Web-WebServer':
  installmanagementtools => true,
  } ->
    windowsfeature { 'Web-Asp-Net45':
  } ->

  # remove default web site
  iis_site {'Default Web Site':
    ensure   => stopped,
    app_pool => 'DefaultAppPool'
  } ->

  # application in iis
  iis::manage_app_pool { "${chocolatey_server_app_pool_name}":
    enable_32_bit           => true,
    managed_runtime_version => 'v4.0',
  } ->
  iis_site {'chocolatey.server':
    ensure   => 'started',
    path     => $server_install_location,
    port     => $service_port,
    app_pool => $chocolatey_server_app_pool_name,
  } ->

  # lock down web directory
    acl { "${server_install_location}":
    purge                       => true,
    inherit_parent_permissions  => false,
    permissions => [
      { identity => 'Administrators', rights => ['full'] },
      { identity => 'IIS_IUSRS', rights => ['read'] },
      { identity => 'IUSR', rights => ['read'] },
      { identity => "IIS APPPOOL\\${chocolatey_server_app_pool_name}", rights => ['read'] }
    ],
  } ->

  acl { "${server_install_location}/App_Data":
    permissions => [
      { identity => "IIS APPPOOL\\${chocolatey_server_app_pool_name}", rights => ['modify'] },
      { identity => 'IIS_IUSRS', rights => ['modify'] }
    ],
  }
  # technically you may only need IIS_IUSRS but I have not tested this yet.
}
