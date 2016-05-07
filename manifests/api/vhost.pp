# == Class: aptly::api::vhost
#
# Configure an Apache vhost for serving the Aptly api. Adds Apache Basic Auth for
# protection of the API.
#
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
class aptly::api::vhost (
	$api_port          = '8080',
	$port              = '8081',
  $servername        = 'aptly',
  $serveraliases     = [],
  $htpasswd_contents = '',
) {
  validate_string($docroot)
  validate_string($servername)
  validate_array($serveraliases)

  include ::apache

  file { '/etc/aptly.htpasswd':
    ensure  => file,
    content => $htpasswd_contents,
  }
  ->
  apache::vhost { "aptly-api":
    servername    => $servername,
    serveraliases => $serveraliases,
    priority      => '06',
    port          => $port,
    docroot       => '/var/www', #have to specify, irrelevant for a proxy
    proxy_pass    => [ { 'path' => '/', 'url' => "http://127.0.0.1:${api_port}/" } ],
    directories   => [
      {
        'path'           => '/',
        'provider'       => 'location',
        'auth_user_file' => '/etc/aptly.htpasswd',
        'auth_type'      => 'basic',
        'auth_require'   => 'valid-user',
        'auth_name'      => 'Auth Required for Aptly API',
      }
    ],
  }
}
