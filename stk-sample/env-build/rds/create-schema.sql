CREATE DATABASE IF NOT EXISTS stk;
use stk;

create table if not exists actions (
  id MEDIUMINT NOT NULL AUTO_INCREMENT,
  m_ticks DOUBLE,
  m_kart_id DOUBLE,
  m_action DOUBLE,
  m_value DOUBLE,
  m_value_l DOUBLE,
  m_value_r DOUBLE,
  primary key (id)
);
select 'actions' as '';

create table debug_log_auth (id MEDIUMINT NOT NULL AUTO_INCREMENT, log varchar(64) not null, primary key (id));

select 'debug_log_auth' as '';
