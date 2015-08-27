# ---------------------------------------------------
# Basic system stuff
# ---------------------------------------------------

package {'apparmor':
	ensure => absent,
}
package { 'unzip':
	ensure => present,
	require => Exec['apt-get update'],
}

package { 'curl':
	ensure => present,
	require => Exec['apt-get update'],
}

package { 'nano':
	ensure => present,
	require => Exec['apt-get update'],
}

package { 'git':
	ensure => present,
	require => Exec['apt-get update'],
}

package { 'tig':
	ensure => present,
	require => Exec['apt-get update'],
}

exec { "Import repo signing key to apt keys for nginx":
	path   => "/usr/bin:/usr/sbin:/bin",
	command     => "apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 7BD9BF62",
	unless      => "apt-key list | grep 7BD9BF62",
}

file { '/etc/apt/sources.list.d/nginx-repos.list':
	ensure => present,
	source => "/vagrant/manifests/files/apt/nginx-repos.list",
	notify => Service['nginx'],
}

exec { 'apt-get update':
	command => '/usr/bin/apt-get update',
	onlyif => "/bin/bash -c 'exit $(( $(( $(date +%s) - $(stat -c %Y /var/lib/apt/lists/$( ls /var/lib/apt/lists/ -tr1 | tail -1 )) )) <= 604800 ))'",
	require => [
		File['/etc/apt/sources.list.d/nginx-repos.list'],
		Exec["Import repo signing key to apt keys for nginx"],
	],
}


# ---------------------------------------------------
# Install dnsmasq
# ---------------------------------------------------

package { "dnsmasq":
	ensure => present,
	require => Exec['apt-get update'],
}

service { 'dnsmasq':
	ensure => running,
	hasstatus => true,
	hasrestart => true,
	enable => true,
	require => Package["dnsmasq"],
}

file { '/etc/dnsmasq.conf':
	ensure => present,
	source => "/vagrant/manifests/files/dnsmasq/dnsmasq.conf",
	require => Package["dnsmasq"],
	notify => Service['dnsmasq'],
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

file { '/etc/mysql/my.cnf':
	ensure => present,
	source => "/vagrant/manifests/files/mysql/my.cnf",
	owner => "root",
	group => "root",
	require => Package["mysql-server"],
	notify => Service["mysql"]
}

exec { 'mysql-root-password':
	command => '/usr/bin/mysqladmin -u root password "vagrant"',
	onlyif => '/usr/bin/mysqladmin -u root status',
	require => File['/etc/mysql/my.cnf'],
	notify => Service['mysql'],
}



# ------------------------------------------------------
# Install PHP 5.5.x with FPM (from regular trusty repos)
# ------------------------------------------------------

package { 'php5-fpm':
	ensure => installed,
	require => Exec['apt-get update'],
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
package { 'php5-imagick':
	ensure => installed,
	require => Exec['apt-get update'],
	notify => Service['php5-fpm'],
}
package { 'php5-cli':
	ensure => installed,
	require => Exec['apt-get update'],
}
package { 'php5-sqlite':
	ensure => installed,
	require => Exec['apt-get update'],
	notify => Service['php5-fpm'],
}
package { 'php5-ldap':
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

file { '/etc/php5/fpm/pool.d/www.conf':
	ensure => present,
	source => "/vagrant/manifests/files/php/www.conf",
	require => [
		Package['php5-fpm']
	],
	notify => [
		Service['php5-fpm'],
	],
}

file { '/etc/php5/fpm/conf.d/90-vagrant.ini':
	ensure => present,
	source => "/vagrant/manifests/files/php/90-vagrant.ini",
	require => [
		Package['php5-fpm'],
	],
	notify => [
		Service['php5-fpm'],
	],
}

file { '/etc/php5/cli/conf.d/90-vagrant.ini':
	ensure => present,
	source => "/vagrant/manifests/files/php/90-vagrant.ini",
	require => [
		Package['php5-cli'],
	],
}


# ---------------------------------------------------
# Install Composer
# ---------------------------------------------------

exec { 'install-composer':
	command => 'curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer',
	path => "/usr/local/bin/:/usr/bin/:/bin/",
	timeout => 0,
	creates => "/usr/local/bin/composer",
	require => [
		Package['curl'],
		Package['php5-cli'],
	],
}

exec { 'selfupdate-composer':
	command => 'sudo composer self-update',
	path => "/usr/local/bin/:/usr/bin/",
	require => [
		Exec['install-composer'],
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
	source => "/vagrant/manifests/files/nginx/nginx.conf",
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

file { "/var/www":
	ensure => directory,
	recurse => false,
}



# ---------------------------------------------------
# Install PhpMyAdmin
# ---------------------------------------------------

package { 'phpmyadmin':
	ensure => present,
	require => [
		Exec['apt-get update'],
	],
}



# ---------------------------------------------------
# Install Node Package Manager and some packages we
# use e.g. for web-development
# ---------------------------------------------------

package { 'npm':
	ensure => 'present',
	require => Exec['apt-get update'],
}

# install Ubuntu/Debian specific wrapper package to bring things to the right path (again)
# see https://github.com/joyent/node/issues/3911#issuecomment-18951288
package { 'nodejs-legacy':
	ensure => 'present',
	require => Package['npm']
}

exec { '/usr/bin/npm install -g bower':
	require => Package['npm'],
	creates => "/usr/local/bin/bower",
}



# ---------------------------------------------------
# Install ruby stuff needed e.g. for mailcatcher
# ---------------------------------------------------
package { ["ruby1.9.1-dev", "libsqlite3-dev", "build-essential"]:
	ensure  => latest,
	require => Exec["apt-get update"],
}



# --------------------------------------------------------------------
# Install and configure the mailcatcher Mock-SMTP-Server
#
# Heavily inspired by https://github.com/actionjack/puppet-mailcatcher
# --------------------------------------------------------------------
package { 'mailcatcher':
	ensure => 'latest',
	provider => 'gem',
	notify => Service['nginx'],
	require => [
		Package['ruby1.9.1-dev'],
		Package['build-essential'],
		Package['libsqlite3-dev'],
	],
}

user { 'mailcatcher':
	ensure	=> 'present',
	comment	=> 'Mailcatcher Service User',
	home	=> '/var/spool/mailcatcher',
	shell	=> '/bin/true',
}

file {'/var/log/mailcatcher':
	ensure	=> 'directory',
	owner	=> 'mailcatcher',
	group	=> 'mailcatcher',
	mode	=> '0755',
	require	=> User['mailcatcher']
}

file { '/etc/init/mailcatcher.conf':
	ensure	=> 'file',
	source	=> "/vagrant/manifests/files/mailcatcher/mailcatcher.conf",
	mode	=> '0755',
	notify	=> Service['mailcatcher']
}

service {'mailcatcher':
	ensure		=> 'running',
	provider	=> 'upstart',
	hasstatus	=> true,
	hasrestart	=> true,
	require		=> [
		User['mailcatcher'],
		Package['mailcatcher'],
		File['/etc/init/mailcatcher.conf'],
		File['/var/log/mailcatcher'],
	],
}


# ---------------------------------------------------
# Install OpenLDAP Server
# ---------------------------------------------------

package { 'slapd':
	ensure => present,
}

package { 'ldap-utils':
	ensure => present,
	require => Package['slapd'],
}


# ---------------------------------------------------
# Install Beanstalk Daemon
# ---------------------------------------------------

package { 'beanstalkd':
	ensure => present,
}



# ---------------------------------------------------
# Install Supervisor Daemon
# ---------------------------------------------------

include supervisor

# Uncomment the following lines to enable a dummy task (or change it to your command)
#supervisor::task{ 'dummy':
#	user => 'root',
#	command => 'sleep 3',
#	autorestart => 'true',
#	numprocs => 2
#}



# ---------------------------------------------------
# Install Redis Server
# ---------------------------------------------------

package { 'redis-server':
	ensure => present,
}

package { 'redis-tools':
	ensure => present,
}

package { 'php5-redis':
	ensure => present,
	notify => Service['php5-fpm'],
}