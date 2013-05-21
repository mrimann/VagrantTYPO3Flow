# ---------------------------------------------------
# Basic system stuff
# ---------------------------------------------------

package {'apparmor':
	ensure => absent,
}
package { 'unzip':
	ensure => present,
}

exec { 'apt-get update':
	command => '/usr/bin/apt-get update',
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
