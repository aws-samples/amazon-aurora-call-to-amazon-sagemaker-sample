CREATE EXTENSION "uuid-ossp";

DROP TABLE servers CASCADE;

CREATE TABLE servers (
 id uuid DEFAULT uuid_generate_v4() NOT NULL,
 created_at timestamp with time zone NOT NULL,
 location char(16) NOT NULL,
 endpoint char(24) NOT NULL,
 is_ready smallint DEFAULT 0,
 num_active_session smallint DEFAULT 0,
 server_mode smallint NOT NULL,
 session_start timestamp with time zone NULL,
 session_end timestamp with time zone NULL,
 PRIMARY KEY (id,created_at)
) PARTITION BY RANGE (created_at);

CREATE SCHEMA partman;
CREATE EXTENSION pg_partman WITH SCHEMA partman;

DELETE FROM partman.part_config;

SELECT partman.create_parent( p_parent_table => 'public.servers',
 p_control => 'created_at',
 p_type => 'native',
 p_start_partition => '2022-05-01',
 p_interval=> 'monthly',
 p_premake => 6);

