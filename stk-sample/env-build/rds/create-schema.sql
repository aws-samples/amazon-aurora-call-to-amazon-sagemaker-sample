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
  class DOUBLE,
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


create or replace view v_actions_m_value_velocity as
select id,m_action,m_kart_id,c_v,p_v,(c_v-p_v) vel,c_v_l,p_v_l,(c_v_l-p_v_l) vel_l,c_v_r,p_v_r,(c_v_r-p_v_r) vel_r,party_size,session,class
from
(
select curr.id,curr.m_action,curr.m_kart_id,curr.m_value c_v,prev.m_value p_v,curr.m_value_l c_v_l,prev.m_value_l p_v_l,curr.m_value_r c_v_r,prev.m_value_r p_v_r,curr.party_size,curr.session,curr.class
from actions prev, actions curr
where prev.id=curr.id-1 and prev.class=curr.class and curr.m_kart_id=prev.m_kart_id and curr.m_action=prev.m_action and curr.party_size=prev.party_size and curr.session=prev.session and party_size=2
order by curr.m_kart_id,curr.id
) v

select 'v_actions_m_value_velocity' as '';

create or replace view v_actions_m_value_accel as
select id,m_action,m_kart_id,c_v,p_v,c_vel,p_vel,(c_vel-p_vel) accel,c_v_l,p_v_l,c_vel_l,p_vel_l,(c_vel_l-p_vel_l) accel_l,c_v_r,p_v_r,c_vel_r,p_vel_r,(c_vel_r-p_vel_r) accel_r,party_size,session,class
from
(
select curr.id,curr.m_action,curr.m_kart_id,curr.c_v,curr.p_v,curr.vel c_vel,prev.vel p_vel,curr.c_v_l,curr.p_v_l,curr.vel_l c_vel_l,prev.vel_l p_vel_l,curr.c_v_r,curr.p_v_r,curr.vel_r c_vel_r,prev.vel_r p_vel_r,curr.party_size,curr.session,curr.class
  from v_actions_m_value_velocity prev,v_actions_m_value_velocity curr
  where prev.id=curr.id-1 and prev.class=curr.class and curr.m_kart_id=prev.m_kart_id and curr.m_action=prev.m_action and curr.party_size=prev.party_size and curr.session=prev.session and curr.party_size=2
  order by curr.m_kart_id,curr.id
) v

select 'v_actions_m_value_accel' as '';