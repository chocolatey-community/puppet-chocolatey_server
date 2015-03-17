# == Class: chocolatey_server
#
# Full description of class chocolatey_server here.
#
# === Parameters
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#
class chocolatey_server (
  $port = $::chocolatey_server::params::service_port,
) inherits ::chocolatey_server::params {

  $chocolatey_server_location = 'C:\tools\chocolatey.server'
  $chocolatey_server_app_pool_name = 'chocolatey.server'
  $chocolatey_server_app_port = $port

  # package install
  package {'chocolatey.server':
    ensure => installed,
    provider => chocolatey,
  } ->

  # add windows features
  windowsfeature { 'Web-WebServer':
  installmanagementtools => true,
  } ->
  windowsfeature { 'Web-Asp-Net45':
  } ->

  # remove default web site
  iis::manage_site {'Default Web Site':
    ensure        => absent,
    site_path     => 'any',
    app_pool      => 'DefaultAppPool'
  } ->

  # application in iis
  iis::manage_app_pool { "${chocolatey_server_app_pool_name}":
    enable_32_bit           => true,
    managed_runtime_version => 'v4.0',
  } ->
  iis::manage_site {'chocolatey.server':
    site_path     => $chocolatey_server_location,
    port          => "${chocolatey_server_app_port}",
    ip_address    => '*',
    app_pool      => "${chocolatey_server_app_pool_name}",
  } ->

  # lock down web directory
  acl { "${chocolatey_server_location}":
    purge                       => true,
    inherit_parent_permissions  => false,
    permissions => [
     { identity => 'Administrators', rights => ['full'] },
     { identity => 'IIS_IUSRS', rights => ['read'] },
     { identity => 'IUSR', rights => ['read'] },
     { identity => "IIS APPPOOL\\${chocolatey_server_app_pool_name}", rights => ['read'] }
   ],
  } ->
  acl { "${chocolatey_server_location}/App_Data":
    permissions => [
     { identity => "IIS APPPOOL\\${chocolatey_server_app_pool_name}", rights => ['modify'] },
     { identity => 'IIS_IUSRS', rights => ['modify'] }
   ],
  }
  # technically you may only need IIS_IUSRS but I have not tested this yet.
}
