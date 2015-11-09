# == Class: flashplayer
#
# Full description of class flashplayer here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'flashplayer':
#    server => 'example.domain.com',
#    cert => 'base64 string',
#  }
#
# === Authors
#
# Zhu Sheng Li <zshengli@cn.ibm.com>
#
# === Copyright
#
# Copyright 2015 Zhu Sheng Li, unless otherwise noted.
#
class flashplayer (
  $server,
  $cert_base64_string,
) {

  if ( $::architecture == 'x64' ) {
    $flash_path = 'C:\Windows\SysWOW64\Macromed\Flash'
  } else {
    $flash_path = 'C:\Windows\System32\Macromed\Flash'
  }

  if $::flash[installed] {

    # or using a http link to download cert.
    file { 'cert':
      ensure => present,
      path => 'C:\Windows\Temp\sau.cer',
      content => template('flashplayer/cert.erb'),
    }

    exec { 'import_cert':
      command =>
        'certutil -enterprise -f -addstore Root C:\Windows\Temp\sau.cer',
      subscribe => File['cert'],
      refreshonly => true,
    }

    file { 'sau_config':
      ensure => present,
      path => "${flash_path}\\mms.cfg",
      content => template('flashplayer/mms.cfg')
    }

    # If user has disabled autoupdate from Flash Control Panel,
    # the service and scheduled task should not exist.
    # So ensure they are present with puppet.
    exec {'auservice':
      command => "sc create AdobeFlashPlayerUpdateSvr \
      binPath= ${flash_path}\\FlashPlayerUpdateService.exe \
      displayName= \"Adobe Flash Player Update Service\"",
      unless => 'sc query AdobeFlashPlayerUpdateSvr',
    }

    scheduled_task { 'flash':
      ensure    => present,
      enabled   => true,
      command   => "${flash_path}\\FlashPlayerUpdateService.exe",
      trigger   => {
          schedule   => weekly,
          start_time => '23:00',
          day_of_week => 'fri'
      }
    }

  }

}
