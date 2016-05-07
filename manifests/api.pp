# == Class: aptly::api
#
# Install and configure Aptly's API Service
#
# === Parameters
#
# [*ensure*]
#   Ensure to pass on to service type
#   Default: running
#
# [*type*]
#   Type of service to deploy - upstart or systemd
#   Default: upstart
#
# [*user*]
#   User to run the service as.
#   Default: root
#
# [*group*]
#   Group to run the service as.
#   Default: root
#
# [*listen*]
#   What IP/port to listen on for API requests.
#   Default: ':8080'
#
# [*log*]
#   Enable or disable Upstart logging (logging is always enabled for systemd).
#   Default: none
#
# [*enable_cli_and_http*]
#   Enable concurrent use of command line (CLI) and HTTP APIs with
#   the same Aptly root.
#
class aptly::api (
  $ensure              = running,
  $type                = 'upstart',
  $user                = 'root',
  $group               = 'root',
  $listen              = ':8080',
  $log                 = 'none',
  $config_file         = '/etc/aptly.conf',
  $enable_cli_and_http = false,
) {

  validate_string($user, $group, $config_file)

  validate_re($ensure, ['^stopped|running$'], 'Valid values for $ensure: stopped, running')
  validate_re($type, ['^upstart|systemd$'], 'Valid values for $type: upstart, systemd')
  validate_re($listen, ['^[0-9.]*:[0-9]+$'], 'Valid values for $listen: :port, <ip>:<port>')
  validate_re($log, ['^none|log$'], 'Valid values for $log: none, log')

  validate_bool($enable_cli_and_http)

  if $type == 'systemd' {
    file { 'aptly-service':
      path    => '/etc/systemd/system/aptly-api.service',
      content => template('aptly/etc/aptly.systemd.erb'),
    }

    # Make sure systemctl is reloaded on file changes
    exec { '/bin/systemctl daemon-reload':
      refreshonly => true,
      subscribe   => File['aptly-service'],
      before      => Service['aptly-api'],
    }

    service{'aptly-api':
      provider => 'systemd',
      ensure   => $ensure,
      enable   => true,
    }
  } else {
    file { 'aptly-service':
      path    => '/etc/init/aptly-api.conf',
      content => template('aptly/etc/aptly.init.erb'),
    }

    service{'aptly-api':
      ensure => $ensure,
      enable => true,
    }
  }

  File['aptly-service'] ~> Service['aptly-api']

}
