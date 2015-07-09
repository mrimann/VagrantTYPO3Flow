class supervisor {
	package { 'supervisor':
		ensure => present,
	}

	service { 'supervisor':
		ensure => running,
	}
}


define supervisor::task(
	$user,
	$command,
	$autorestart = 'true',
	$numprocs = 1
) {

	file { "/etc/supervisor/conf.d/${name}.conf":
		ensure => file,
		mode => '0700',
		owner => "root",
		content => template('supervisor/supervisorTask.conf.erb'),
		notify => Service['supervisor'],
	}
}