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
#
# @param [String] server_package_source The chocolatey source that contains
#   the `chocolatey.server` package. Defaults to
#   'https://chocolatey.org/api/v2/'.
#
# @param [String] server_install_location The location to that the chocolatey
#   server will be installed.  This is can be used if you are controlling
#   the location that chocolatey packages are being installed via some other
#   means. e.g. environment variable ChocolateyBinRoot.  Defaults to
#   'C:\tools\chocolatey.server'
class chocolatey_server (
  $chocolatey_server_app_pool_name = $::chocolatey_server::params::chocolatey_server_app_pool_name,
  $disable_default_website = $::chocolatey_server::params::disable_default_website,
  $packages_folder = $::chocolatey_server::params::packages_folder,
  $packages_folder_permissions = $::chocolatey_server::params::packages_folder_permissions,
  $port = $::chocolatey_server::params::service_port,
  $server_package_source = $::chocolatey_server::params::server_package_source,
  $server_install_location = $::chocolatey_server::params::server_install_location,
) inherits ::chocolatey_server::params {
  require chocolatey

  $_chocolatey_server_location      = $server_install_location
  $_chocolatey_server_app_pool_name = $chocolatey_server_app_pool_name
  $_chocolatey_server_app_port      = $port
  $_server_package_url              = $server_package_source
  $_is_windows_2008 = $::kernelmajversion ? {
    '6.1'   => true,
    default => false
  }
  $_install_management_tools = $_is_windows_2008 ? {
    true    => false,
    default => true
  }
  $_web_asp_net = $_is_windows_2008 ? {
    true    => 'Web-Asp-Net',
    default => 'Web-Asp-Net45'
  }

  # disable default web site
  if $disable_default_website {
    iis::manage_site {'Default Web Site':
      ensure   => stopped,
      app_pool => 'DefaultAppPool',
    }
  }

  # package install
  package {'chocolatey.server':
    ensure   => installed,
    provider => chocolatey,
    source   => $_server_package_url,
  }

  # add windows features
  iis_feature { 'Web-WebServer':
    ensure                   => present,
    include_management_tools => $_install_management_tools,
  }
  -> iis_feature { $_web_asp_net:
    ensure => present,
  }
  -> iis_feature { 'Web-AppInit':
    ensure => present,
  }

  # remove default web site
  -> iis_site {'Default Web Site':
    ensure          => absent,
    applicationpool => 'DefaultAppPool',
    require         => Iis_feature['Web-WebServer'],
  }

  # application in iis
  -> iis_application_pool { $_chocolatey_server_app_pool_name:
    ensure                    => 'present',
    state                     => 'started',
    enable32_bit_app_on_win64 => true,
    managed_runtime_version   => 'v4.0',
    start_mode                => 'AlwaysRunning',
    idle_timeout              => '00:00:00',
    restart_time_limit        => '00:00:00',
  }
  -> iis_site {'chocolateyserver':
    ensure          => 'started',
    physicalpath    => $_chocolatey_server_location,
    applicationpool => $_chocolatey_server_app_pool_name,
    preloadenabled  => true,
    bindings        =>  [
      {
        'bindinginformation' => '*:80:',
        'protocol'           => 'http'
      }
    ],
    require         => Package['chocolatey.server'],
  }

  # lock down web directory
  -> acl { $_chocolatey_server_location:
    purge                      => true,
    inherit_parent_permissions => false,
    permissions                => [
      { identity => 'Administrators',
      rights     => ['full'] },
      { identity => 'IIS_IUSRS',
      rights     => ['read'] },
      { identity => 'IUSR',
      rights     => ['read'] },
      { identity => "IIS APPPOOL\\${_chocolatey_server_app_pool_name}",
      rights     => ['read'] }
    ],
    require                    => Package['chocolatey.server'],
  }
  -> acl { "${_chocolatey_server_location}/App_Data":
    permissions => [
      { identity => "IIS APPPOOL\\${_chocolatey_server_app_pool_name}", rights => ['modify'] },
      { identity => 'IIS_IUSRS', rights => ['modify'] }
    ],
    require     => Package['chocolatey.server'],
  }

  # only set permissions if an alternate package folder is undefined
  unless $packages_folder {
    # ensure app_data folder is created
    file { "${_chocolatey_server_location}/App_Data":
      ensure => directory,
    }

    # ensure packages folder is created
    file { "${_chocolatey_server_location}/App_Data/Packages":
      ensure  => directory,
      require => File["${_chocolatey_server_location}/App_Data"],
    }

    acl { "${_chocolatey_server_location}/App_Data":
      permissions => $packages_folder_permissions,
      require     => [Iis::Manage_app_pool["${_chocolatey_server_app_pool_name}"],
                      File["${_chocolatey_server_location}/App_Data"]],
    }
    # technically you may only need IIS_IUSRS but I have not tested this yet.
  }

  # if a different folder for packages is specified, create a symlink
  if $packages_folder {
    # ensure app_data folder is created
    file { "${_chocolatey_server_location}/App_Data":
      ensure => directory,
    }

    # ensure packages folder is created
    file { "${packages_folder}":
      ensure => directory,
    }

    # create a symlink to the new packages folder, replacing the existing
    # app_data folder
    file { "${_chocolatey_server_location}/App_Data/Packages":
      ensure  => link,
      force   => true,
      target  => $packages_folder,
      require => File["${packages_folder}"],
    }

    # set permissions on the new packages folder
    acl { "${packages_folder}":
      permissions => $packages_folder_permissions,
      require     => File["${packages_folder}"],
    }
  }

}
