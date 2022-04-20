drop table if exists trs_cheat_mv;
create table trs_cheat_mv as select t.timestamp,t.playerGuid from (select playerGuid,timestamp,trans_cheat_score(month,day,hour,minute,name_encoded,uagent) cls from transactions t) as t where cls>0;

drop table if exists auth_cheat_mv;
create table auth_cheat_mv as select t.timestamp,t.playerGuid from (select timestamp,playerGuid,auth_cheat_score(uagent,day,month,hour,minute,src_ip_encoded) cls from auth) as t where cls>0;

drop table if exists move_cheat_mv;
create table move_cheat_mv as select t.timestamp,t.playerGuid from (select timestamp,playerGuid,move_cheat_score(playerX,playerZ,quadrant,sector,event) cls from dist_player_moves) as t where cls>2;
