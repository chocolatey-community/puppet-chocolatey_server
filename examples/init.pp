# setting up a chocolatey server with a new apikey on port 8080 with an
# alternate packages folder without disabling the default web site
class { 'chocolatey_server':
  apikey                  => 'changeme',
  disable_default_website => false,
  packages_folder         => 'C:\Chocolatey',
  port                    => '8080',
}

# installs chocolatey server with default parameters
include chocolatey_server
