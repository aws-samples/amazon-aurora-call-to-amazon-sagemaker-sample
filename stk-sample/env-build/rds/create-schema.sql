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

create or replace view v_actions_ticks_velocity as
select id,m_kart_id,c_t,p_t,(c_t-p_t) vel
from
(
select curr.id,curr.m_kart_id,curr.m_ticks c_t,prev.m_ticks p_t
from actions prev, actions curr
where prev.id=curr.id-1  
order by curr.m_kart_id,curr.id
) v

select 'v_actions_ticks_velocity' as '';

create or replace view v_actions_ticks_accel as
select id,m_kart_id,c_t,p_t,c_v,p_v,(c_v-p_v) accel
from
(
select curr.id,curr.m_kart_id,curr.c_t,curr.p_t,curr.vel c_v,prev.vel p_v 
  from v_actions_ticks_velocity prev,v_actions_ticks_velocity curr
  where prev.id=curr.id-1
  order by curr.m_kart_id,curr.id
) v

select 'v_actions_ticks_accel' as '';
