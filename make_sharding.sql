create procedure make_shard(table_name varchar(255), sharding_year int)
begin
	set @db_name = concat(table_name, '_', sharding_year);
	set @full_table_name = concat(@db_name, '.', table_name);
	
	set @check_db_exists = 
		concat
		(
			'select
				schema_name
			from information_schema.schemata
			where schema_name = ''', @db_name, ''' into @db'
		);
	
	prepare check_db_exists_stmt from @check_db_exists;
	execute check_db_exists_stmt;
	deallocate prepare check_db_exists_stmt;
	
	if (@db is not null) then
		set @build_db = concat('create database if not exists ', @db_name);
		prepare build_db_stmt from @build_db;
		execute build_db_stmt;
		deallocate prepare build_db_stmt;
	end if;
	
	set @build_table = concat('create table if not exists ', @full_table_name, ' like ', table_name);
	prepare build_table_stmt from @build_table;
	execute build_table_stmt;
	deallocate prepare build_table_stmt;

	set @build_primary_key = concat('alter table ', @full_table_name, ' drop primary key, add primary key (id, created)');
	prepare build_primary_key_stmt from @build_primary_key;
	execute build_primary_key_stmt;
	deallocate prepare build_primary_key_stmt;

	set @build_head_partition =
		concat
		(
			'alter table ', @full_table_name,
			' partition by range(to_days(created))',
			'('
		);
	
	create temporary table if not exists partitions (p text);
	truncate partitions;
	set @start_range = concat(sharding_year, '-01-01');
	set @end_range = date_add(@start_range, interval 12 month);

	while (@start_range < @end_range) do
		set @i_date = date_add(@start_range, interval 1 month);
		set @i_partition = concat('partition p', date_format(@start_range, '%Y%m'), ' values less than (to_days(''', @i_date,'''))');
		insert into partitions (p) values (@i_partition);
		set @start_range = @i_date;	
	end while;

	set @full_build_table = concat(@build_head_partition, (select group_concat('\n', p) from partitions),');');
	
	prepare build_table_stmt from @full_build_table;
	execute build_table_stmt;
	deallocate prepare build_table_stmt;
end;
