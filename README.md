### Usage

	./deps.sh
	vagrant up
	

### Puppet profile for Mysql Master node

	  class { 'mysql::server':
		restart          => true,
		root_password    => 'changeme',
		override_options => {
		  'mysqld' => {
			'bind_address'                   => '0.0.0.0',
			'server-id'                      => '1',
			'binlog-format'                  => 'mixed',
			'log-bin'                        => 'mysql-bin',
			'datadir'                        => '/var/lib/mysql',
			'innodb_flush_log_at_trx_commit' => '1',
			'sync_binlog'                    => '1',
			'binlog-do-db'                   => ['demo'],
		  },
		}
	  }

	  mysql_user { 'slave_user@%':
		ensure        => 'present',
		password_hash => mysql_password('changeme'),
	  }

	  mysql_grant { 'slave_user@%/*.*':
		ensure     => 'present',
		privileges => ['REPLICATION SLAVE'],
		table      => '*.*',
		user       => 'slave_user@%',
	  }

	  mysql::db { 'demo':
		ensure   => 'present',
		user     => 'demo',
		password => 'changeme',
		host     => '%',
		grant    => ['all'],
	  }

### Puppet profile for Mysql Master node


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


#### On Mysql Master
Make sure database is locked down, take note of the bin log `File` and `Position`, and take an export.

	vagrant ssh mysqlmaster

	$ mysql -u root -pchangeme
	mysql> SLAVE STOP;
	Query OK, 0 rows affected (0.00 sec)
	mysql> FLUSH TABLES WITH READ LOCK;
	Query OK, 0 rows affected (0.00 sec)

	mysql> SHOW MASTER STATUS;
	+------------------+----------+--------------+------------------+
	| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
	+------------------+----------+--------------+------------------+
	| mysql-bin.000002 |     1467 | demo         |                  |
	+------------------+----------+--------------+------------------+
	1 row in set (0.00 sec)

	mysql> EXIT;

	$ mysqldump -u root -pchangeme --opt demo > /vagrant/demo.sql
	$ mysql -u root -pchangeme
	
	mysql> UNLOCK TABLES;
	
#### On Mysql Slave
Import the export just taken from the master, configure the slave with:

- The mysql master host ip (`172.10.10.10`)
- The user created in puppet (`slave_user`)
- And the bin log position info (`mysql-bin.000002` / `1467`)

	vagrant ssh mysqlslave
	
	$ mysql -u root -pchangeme demo < /vagrant/demo.sql
	$ mysql -u root -pchangeme
	mysql> CHANGE MASTER TO MASTER_HOST='172.10.10.10',MASTER_USER='slave_user', MASTER_PASSWORD='changeme', MASTER_LOG_FILE='mysql-bin.000002', MASTER_LOG_POS=1467;
	Query OK, 0 rows affected (0.00 sec)
	mysql> START SLAVE;
	Query OK, 0 rows affected (0.00 sec)

	mysql> SHOW SLAVE STATUS\G


###
That's it! continue on to create a new table on the master node, insert a record, and see it show up on the slave.

#### On Mysql Master
	
	vagrant ssh mysqlmaster
	
	$ mysql -u root -pchangeme
	
	mysql USE demo;
	mysql> CREATE TABLE IF NOT EXISTS demo ( msg VARCHAR(255) ) ENGINE=InnoDB;
	mysql> INSERT INTO demo (`msg`) VALUES ('hello world');
	
	
#### On Mysql Slave

	vagrant ssh mysqlslave
	
	$ mysql -u root -pchangeme
	mysql> USE demo;
	mysql> SELECT * FROM demo;
	+-------------+
	| msg         |
	+-------------+
	| hello world |
	+-------------+
	1 row in set (0.00 sec)

