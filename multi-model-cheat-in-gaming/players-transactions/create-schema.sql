CREATE DATABASE IF NOT EXISTS playerdb;
use playerdb;

create table if not exists players (
  playerGuId VARCHAR(64) PRIMARY KEY
);
select 'players' as '';

create table if not exists encounters (
  timestamp DATETIME not null,
  playerGuId VARCHAR(64),
  playerX DOUBLE,
  playerZ DOUBLE,
  quadrant VARCHAR(16),
  sector VARCHAR(16),
  playerAchiever DOUBLE,
  playerBuilder DOUBLE,
  playerExplorer DOUBLE,
  playerSlayer DOUBLE,
  playerSocializer DOUBLE,
  playerHappinessCumulative DOUBLE,
  playerHappinessModifier DOUBLE,
  eventName VARCHAR(16),
  eventAchiever DOUBLE,
  eventBuilder DOUBLE,
  eventExplorer DOUBLE,
  eventSlayer DOUBLE,
  eventSocializer DOUBLE,
  timecode DOUBLE,
  foreign key (playerGuId) references players(playerGuId) on delete cascade
);
select 'encounters' as '';

create table if not exists transactions (
  timestamp DATETIME not null,
  playerGuId VARCHAR(64),
  name VARCHAR(16),
  foreign key (playerGuId) references players(playerGuId) on delete cascade
); 
select 'transactions' as '';

create table user_devices (id MEDIUMINT NOT NULL AUTO_INCREMENT, uagent varchar(16) not null, primary key (id));
create table debug_log_auth (id MEDIUMINT NOT NULL AUTO_INCREMENT, log varchar(64) not null, primary key (id));
