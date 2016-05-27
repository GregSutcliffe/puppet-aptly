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
  $htpasswd_contents = '',
) {
  validate_string($docroot)
  validate_string($servername)
  validate_string($htpasswd_contents)
  validate_array($serveraliases)

  include ::apache

  # Workaround so apache::vhost doesn't attempt to create a directory
  file { $docroot: }

  if $htpasswd_contents == '' {
    apache::vhost { 'aptly':
      add_default_charset => 'UTF-8',
      options             => ['Indexes','FollowSymLinks'],
      docroot             => $docroot,
      port                => 80,
      priority            => '05',
      servername          => $servername,
      serveraliases       => $serveraliases,
    }
  } else {
    file { '/etc/apt.htpasswd':
      ensure  => file,
      content => $htpasswd_contents,
    }
    ->
    apache::vhost { 'aptly':
      add_default_charset     => 'UTF-8',
      docroot                 => $docroot,
      port                    => 80,
      priority                => '05',
      servername              => $servername,
      serveraliases           => $serveraliases,
      directories   => [
        {
          'path'               => "$docroot",
          'provider'           => 'location',
          'auth_user_file'     => '/etc/apt.htpasswd',
          'auth_type'          => 'basic',
          'auth_require'       => 'valid-user',
          'auth_name'          => 'Auth Required for Apt Repo',
          'allow_override'     => ['None'],
          'options'            => ['Indexes','FollowSymLinks'],
        }
      ],
    }
  }
}
