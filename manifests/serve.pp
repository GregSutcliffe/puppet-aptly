# == Class: aptly::serve
#
# Configure an Apache vhost for serving the Aptly repos.
# Requires puppetlabs-apache.
#
# === Parameters
#
# [*docroot*]
#   Directory of the webserver, should be the "public" dir in the
#   aptly root.
#
# [*servername*]
#   Name of the vhost.
#
# [*docroot*]
#   Aliases for the vhost.
#
class aptly::serve (
  $docroot = '/var/lib/aptly/public',
  $servername = 'aptly',
  $serveraliases = [],
) {
  validate_string($docroot)
  validate_string($servername)
  validate_array($serveraliases)

  include ::apache

  # Workaround so apache::vhost doesn't attempt to create a directory
  file { $docroot: }

  apache::vhost { 'aptly':
    add_default_charset     => 'UTF-8',
    docroot                 => $docroot,
    options                 => ['Indexes','FollowSymLinks'],
    port                    => 80,
    priority                => '05',
    servername              => $servername,
    serveraliases           => $serveraliases,
  }
}
