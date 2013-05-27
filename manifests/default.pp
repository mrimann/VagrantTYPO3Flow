# ---------------------------------------------------
# Basic system stuff
# ---------------------------------------------------

package {'apparmor':
	ensure => absent,
}
package { 'unzip':
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