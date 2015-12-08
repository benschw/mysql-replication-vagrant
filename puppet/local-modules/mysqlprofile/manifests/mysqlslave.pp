class mysqlprofile::mysqlslave {
  notice("Loading mysqlmaster")

  class { 'mysql::server':
    restart          => true,
    root_password    => 'changeme',
    override_options => {
      'mysqld' => {
        'bind_address' => '0.0.0.0',
        'server-id'         => '2',
        'binlog-format'     => 'mixed',
        'log-bin'           => 'mysql-bin',
        'relay-log'         => 'mysql-relay-bin',
        'log-slave-updates' => '1',
        'read-only'         => '1',
        'replicate-do-db'   => ['demo'],
      },
    }
  }

  mysql::db { 'demo':
    ensure   => 'present',
    user     => 'demo',
    password => 'changeme',
    host     => '%',
    grant    => ['all'],
  }
}

