## Mysql Master-Slave replication with Puppet
To run the demo in vagrant, run

	./deps.sh   # clone the mysql puppet module
	vagrant up  # provision the two nodes with vagrant

to configure your `mysqlmaster` and `mysqlslave` nodes, then follow the steps below
to get replication running between them.
	

- [Puppet for `mysqlmaster`](https://github.com/benschw/mysql-replication-vagrant/blob/master/puppet/local-modules/mysqlprofile/manifests/mysqlmaster.pp)
- [Puppet for `mysqlslave`](https://github.com/benschw/mysql-replication-vagrant/blob/master/puppet/local-modules/mysqlprofile/manifests/mysqlslave.pp)


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

<!-- clear -->


	vagrant ssh mysqlslave
	
	$ mysql -u root -pchangeme demo < /vagrant/demo.sql
	$ mysql -u root -pchangeme
	mysql> CHANGE MASTER TO MASTER_HOST='172.10.10.10', \
	  MASTER_USER='slave_user', MASTER_PASSWORD='changeme', \
	  MASTER_LOG_FILE='mysql-bin.000002', MASTER_LOG_POS=1467;
	Query OK, 0 rows affected (0.00 sec)
	mysql> START SLAVE;
	Query OK, 0 rows affected (0.00 sec)

	mysql> SHOW SLAVE STATUS\G


### Verify Replication

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


