# == Class: flashplayer
#
# Full description of class flashplayer here.
#
# === Parameters
#
# Document parameters here.
#
# [*server*]
# [*cert_base64_string*]
# [*installer_source*]
#
# === Examples
#
#  class { 'flashplayer':
#    server => 'example.domain.com',
#    cert_base64_string => 'base64 string',
#    installer_source => '\\10.1.1.111\flash'
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
  $installer_source,
) {

  if ( $::architecture == 'x64' ) {
    $flash_path = 'C:\Windows\SysWOW64\Macromed\Flash'
  } else {
    $flash_path = 'C:\Windows\System32\Macromed\Flash'
  }

  if $::flash[installed] {

    if $::flash[activex] == "" {
      $version = split($::flash[npapi], '[.]')
    } else {
      $version = split($::flash[activex], '[.]')
    }


    # Old flash player(like v10) can't automatically update, so have to install
    # a newer version first.
    # The installer will silently uninstall any old versions.
    if $version[0] < '19' {
      package { 'flashplayer':
        name   => 'Adobe Flash Player 19 ActiveX',
        ensure => installed,
        source => "${installer_source}\\install_flash_player_19_active_x.exe",
        install_options => [ '-install' ],
      }
    }

    # Todo: or using a http link to download cert.
    file { 'cert':
      ensure => present,
      path => 'C:\Windows\Temp\sau.cer',
      content => template('flashplayer/cert.erb'),
    }

    exec { 'import_cert':
      path => 'C:\Windows\System32',
      command =>
        'certutil.exe -enterprise -f -addstore Root C:\Windows\Temp\sau.cer',
      subscribe => File['cert'],
      refreshonly => true,
    }

    file { 'sau_config':
      ensure => present,
      path => "${flash_path}\\mms.cfg",
      content => template('flashplayer/mms.erb')
    }

    # If user has disabled autoupdate from Flash Control Panel,
    # the service and scheduled task should not exist.
    # So ensure they are present with puppet.
    # The service name has to be *AdobeFlashPlayerUpdateSvc*.
    exec {'auservice':
      path => 'C:\Windows\System32',
      command => "sc.exe create AdobeFlashPlayerUpdateSvc \
      binPath= ${flash_path}\\FlashPlayerUpdateService.exe \
      displayName= \"Adobe Flash Player Update Service\"",
      unless => 'sc query AdobeFlashPlayerUpdateSvc',
    }

    # 1. If a successful update check has been performed in last 24 hours, 
    # (which means that the client connected to the update server and check the
    # version number...), current update attempt will be skipped.
    # 2. The update service only updates one kind of flash plugins a time.
    # (either NPAPI or ActiveX).
    scheduled_task { 'Adobe Flash Player Updater':
      name => 'Adobe Flash Player Updater',
      ensure    => present,
      enabled   => true,
      command   => "${flash_path}\\FlashPlayerUpdateService.exe",
      trigger   => {
          schedule   => daily,
          start_time => '01:00',
          minutes_interval=> 60,
          minutes_duration=> 300,
      }
    }

  }

}
