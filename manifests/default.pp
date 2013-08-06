# ---------------------------------------------------
# Basic system stuff
# ---------------------------------------------------

package {'apparmor':
	ensure => absent,
}
package { 'unzip':
	ensure => present,
}

package { 'curl':
	ensure => present,
}

package { 'nano':
	ensure => present,
}

package { 'git':
	ensure => present,
}

package { 'tig':
	ensure => present,
}

exec { "Import repo signing key to apt keys":
	path   => "/usr/bin:/usr/sbin:/bin",
	command     => "apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E5267A6C",
	unless      => "apt-key list | grep E5267A6C",
}

file { '/etc/apt/sources.list.d/php-5.4-repos.list':
	ensure => present,
	source => "/vagrant/manifests/files/php-5.4-repos.list",
	notify => Service['php5-fpm'],
}

exec { 'apt-get update':
	command => '/usr/bin/apt-get update',
	require => [
		File['/etc/apt/sources.list.d/php-5.4-repos.list'],
		Exec["Import repo signing key to apt keys"],
	],
}


# ---------------------------------------------------
# Install MySQL
# ---------------------------------------------------

package { "mysql-server":
	ensure => present,
	require => Exec['apt-get update'],
}

service { 'mysql':
	ensure => running,
	hasstatus => true,
	hasrestart => true,
	enable => true,
	require => Package["mysql-server"],
}

exec { 'mysql-root-password':
	command => '/usr/bin/mysqladmin -u root password vagrant',
	onlyif => '/usr/bin/mysql -u root mysql -e "show databases;"',
	require => Package['mysql-server'],
}



# ---------------------------------------------------
# Install PHP 5.4.x with FPM
# ---------------------------------------------------

package { 'php5-fpm':
	ensure => installed,
	require => Exec['apt-get update'],
}

package { 'libapache2-mod-php5':
	ensure => installed,
	require => Exec['apt-get update'],
	notify => Service['apache2'],
}

package { 'php5-mysql':
	ensure => installed,
	require => Exec['apt-get update'],
	notify => Service['php5-fpm'],
}
package { 'php5-mcrypt':
	ensure => installed,
	require => Exec['apt-get update'],
	notify => Service['php5-fpm'],
}
package { 'php5-curl':
	ensure => installed,
	require => Exec['apt-get update'],
	notify => Service['php5-fpm'],
}
package { 'php5-gd':
	ensure => installed,
	require => Exec['apt-get update'],
	notify => Service['php5-fpm'],
}
package { 'php5-cli':
	ensure => installed,
	require => Exec['apt-get update'],
}
package { 'php-apc':
	ensure => installed,
	require => Exec['apt-get update'],
	notify => Service['php5-fpm'],
}

service { 'php5-fpm':
	ensure => running,
	require => Package['php5-fpm'],
	hasrestart => true,
	hasstatus => true,
}

file { '/etc/php5/conf.d/99-vagrant.ini':
	ensure => present,
	source => "/vagrant/manifests/files/90-vagrant.ini",
	require => [
		Package['libapache2-mod-php5'],
	],
	notify => [
		Service['apache2'],
	],
}


# ---------------------------------------------------
# Install Nginx
# ---------------------------------------------------

package { "nginx":
	ensure => present,
	require => Exec['apt-get update'],
}

file { '/etc/nginx/nginx.conf':
	ensure => present,
	source => "/vagrant/manifests/files/nginx.conf",
	require => [
		Package['nginx'],
	],
	notify => Service['nginx'],
}

service { 'nginx':
	ensure => running,
	hasstatus => true,
	hasrestart => true,
	enable => true,
	require => Package['nginx'],
}



# ---------------------------------------------------
# Install Apache
# ---------------------------------------------------

package { "apache2":
	ensure => present,
	require => Exec['apt-get update'],
}

service { 'apache2':
	ensure => running,
	hasstatus => true,
	hasrestart => true,
	enable => true,
	require => Package['apache2'],
}

file { "/var/www":
	ensure => directory,
	recurse => false,
}

# Enable the "vhost_alias" module for apache
exec { "/usr/sbin/a2enmod vhost_alias":
	unless => "/bin/readlink -e /etc/apache2/mods-enabled/vhost_alias.load",
	notify => Exec["force-reload-apache2"],
	require => Package['apache2'],
}

# Enable the "rewrite" module for apache
exec { "/usr/sbin/a2enmod rewrite":
	unless => "/bin/readlink -e /etc/apache2/mods-enabled/rewrite.load",
	notify => Exec["force-reload-apache2"],
	require => Package['apache2'],
}

exec { "force-reload-apache2":
	command => "/etc/init.d/apache2 force-reload",
	refreshonly => true,
}

file { '/etc/apache2/ports.conf':
	ensure => present,
	source => "/vagrant/manifests/files/ports.conf",
	require => [
		Package['apache2']
	],
	notify => Service['apache2'],
}

file { '/etc/apache2/sites-enabled/mass_vhost.conf':
	ensure => present,
	source => "/vagrant/manifests/files/mass_vhost.conf",
	require => [
		Package['apache2'],
		Exec['/usr/sbin/a2enmod vhost_alias'],
		File['/etc/apache2/ports.conf']
	],
	notify => Service['apache2'],
}



# ---------------------------------------------------
# Install PhpMyAdmin
# ---------------------------------------------------

package { 'phpmyadmin':
	ensure => present,
	require => Package['apache2'],
}

file { '/etc/apache2/sites-enabled/phpmyadmin.conf':
	source => "/vagrant/manifests/files/phpmyadmin.conf",
	require => Package['phpmyadmin'],
	notify => Service['apache2'],
}