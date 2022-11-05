CREATE EXTENSION "uuid-ossp";

--DROP TABLE servers CASCADE;

CREATE TABLE servers (
 id uuid DEFAULT uuid_generate_v4() NOT NULL,
 created_at timestamp with time zone NOT NULL,
 updated_at timestamp with time zone,
 location char(16) NOT NULL,
 endpoint char(24) NOT NULL,
 is_ready smallint DEFAULT 0,
 track char(24) NOT NULL,
 tracktheme char(24) NOT NULL,
 mode char(24) NOT NULL,
 max_players smallint NOT NULL,
 difficulty smallint NOT NULL,
 num_active_session smallint DEFAULT 0,
 PRIMARY KEY (id,created_at)
) PARTITION BY RANGE (created_at);

create index on servers (endpoint);

CREATE TABLE sessions (
 id uuid DEFAULT uuid_generate_v4() NOT NULL,
 client_id char(64) NOT NULL,
 created_at timestamp with time zone NOT NULL,
 updated_at timestamp with time zone,
 location char(16) NOT NULL,
 endpoint char(24) NOT NULL,
 track char(24) NOT NULL,
 tracktheme char(24) NOT NULL,
 app char(24) NOT NULL,
 mode char(24) NOT NULL,
 max_players smallint NOT NULL,
 difficulty smallint NOT NULL,
 session_length interval,
 player_skill char(24),
 is_active smallint,
 PRIMARY KEY (id,created_at)
) PARTITION BY RANGE (created_at);

CREATE TABLE server_sessions (
 id uuid DEFAULT uuid_generate_v4() NOT NULL,
 created_at timestamp with time zone NOT NULL,
 updated_at timestamp with time zone,
 endpoint char(24) NOT NULL,
 s_location char(16) NOT NULL,
 s_track char(24) NOT NULL,
 s_tracktheme char(24) NOT NULL,
 s_mode char(24) NOT NULL,
 s_difficulty smallint NOT NULL,
 p_difficulty smallint,
 p_location char(16),
 p_track char(24),
 p_tracktheme char(24),
 p_mode char(24),
 p_skill char(24),
 session_length interval,
 PRIMARY KEY (id,created_at)
) PARTITION BY RANGE (created_at);
 
CREATE SCHEMA partman;
CREATE EXTENSION pg_partman WITH SCHEMA partman;

--DELETE FROM partman.part_config;

SELECT partman.create_parent( p_parent_table => 'public.servers',
 p_control => 'created_at',
 p_type => 'native',
 p_interval => 'daily',
 p_start_partition =>'2022-05-01',
 p_premake => 6);

SELECT partman.create_parent( p_parent_table =>'public.sessions',
 p_control =>'created_at',
 p_type =>'native',
 p_interval =>'daily',
 p_start_partition =>'2022-05-01',
 p_premake =>6);

SELECT partman.create_parent( p_parent_table => 'public.server_sessions',
 p_control => 'created_at',
 p_type => 'native',
 p_interval => 'daily',
 p_start_partition => '2022-05-01',
 p_premake => 30);

CREATE EXTENSION pg_cron;

UPDATE partman.part_config 
SET infinite_time_partitions = true,
    retention = '3 years', 
    retention_keep_table=true 
WHERE parent_table = 'public.servers';
SELECT cron.schedule('@hourly', $$CALL partman.run_maintenance_proc()$$);

UPDATE partman.part_config 
SET infinite_time_partitions = true,
    retention = '3 years', 
    retention_keep_table=true 
WHERE parent_table = 'public.server_sessions';
SELECT cron.schedule('@hourly', $$CALL partman.run_maintenance_proc()$$);

UPDATE partman.part_config 
SET infinite_time_partitions = true,
    retention = '3 years', 
    retention_keep_table=true 
WHERE parent_table = 'public.sessions';
SELECT cron.schedule('@hourly', $$CALL partman.run_maintenance_proc()$$);



CREATE TABLE trackmap (
 id uuid DEFAULT uuid_generate_v4() NOT NULL,
 theme char(24) NOT NULL,track char(24) NOT NULL);

insert into trackmap(theme,track) values('penguinplayground','sandtrack');
insert into trackmap(theme,track) values('penguinplayground','scotland');
insert into trackmap(theme,track) values('penguinplayground','abyss');
insert into trackmap(theme,track) values('penguinplayground','volcano_island');
insert into trackmap(theme,track) values('penguinplayground','hacienda');
insert into trackmap(theme,track) values('offthebeatentrack','cornfield_crossing');
insert into trackmap(theme,track) values('offthebeatentrack','snowtuxpeak');
insert into trackmap(theme,track) values('offthebeatentrack','ravenbridge_mansion');
insert into trackmap(theme,track) values('offthebeatentrack','zengarden');
insert into trackmap(theme,track) values('offthebeatentrack','zengarden');
insert into trackmap(theme,track) values('offthebeatentrack','cocoa_temple');
insert into trackmap(theme,track) values('tothemoonandback','olivermath');
insert into trackmap(theme,track) values('tothemoonandback','gran_paradiso_island');
insert into trackmap(theme,track) values('tothemoonandback','lighthouse');
insert into trackmap(theme,track) values('tothemoonandback','candela_city');
insert into trackmap(theme,track) values('tothemoonandback','snowmountain');
insert into trackmap(theme,track) values('tothemoonandback','snowmountain');
insert into trackmap(theme,track) values('atworldsend','minigolf');
insert into trackmap(theme,track) values('atworldsend','black_forest');
insert into trackmap(theme,track) values('atworldsend','mines');
insert into trackmap(theme,track) values('atworldsend','stk_enterprise');
insert into trackmap(theme,track) values('atworldsend','xr591');
