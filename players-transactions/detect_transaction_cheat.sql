select auth_cheat_mv.timestamp auth_time, trs_cheat_mv.timestamp trans_time, trs_cheat_mv.playerguid player
from trs_cheat_mv, auth_cheat_mv
where trs_cheat_mv.playerGuid=auth_cheat_mv.playerGuid and auth_cheat_mv.timestamp<trs_cheat_mv.timestamp;
