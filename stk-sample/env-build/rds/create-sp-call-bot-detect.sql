DELIMITER $$

DROP PROCEDURE IF EXISTS is_bot_detector;
CREATE PROCEDURE is_bot_detector()
BEGIN
  DECLARE class double;
  select bot_detect_score(ticks_1,actions_1,value_1,value_l_1,value_r_1,ticks_2,actions_2,value_2,value_l_2,value_r_2,ticks_3,actions_3,value_3,value_l_3,value_r_3,ticks_4,actions_4,value_4,value_l_4,value_r_4,ticks_5,actions_5,value_5,value_l_5,value_r_5,ticks_6,actions_6,value_6,value_l_6,value_r_6,ticks_7,actions_7,value_7,value_l_7,value_r_7,ticks_8,actions_8,value_8,value_l_8,value_r_8,ticks_9,actions_9,value_9,value_l_9,value_r_9,ticks_10,actions_10,value_10,value_l_10,value_r_10,ticks_11,actions_11,value_11,value_l_11,value_r_11,ticks_12,actions_12,value_12,value_l_12,value_r_12,ticks_13,actions_13,value_13,value_l_13,value_r_13,ticks_14,actions_14,value_14,value_l_14,value_r_14,ticks_15,actions_15,value_15,value_l_15,value_r_15,ticks_16,actions_16,value_16,value_l_16,value_r_16,ticks_17,actions_17,value_17,value_l_17,value_r_17,ticks_18,actions_18,value_18,value_l_18,value_r_18,ticks_19,actions_19,value_19,value_l_19,value_r_19,ticks_20,actions_20,value_20,value_l_20,value_r_20,ticks_21,actions_21,value_21,value_l_21,value_r_21,ticks_22,actions_22,value_22,value_l_22,value_r_22,ticks_23,actions_23,value_23,value_l_23,value_r_23,ticks_24,actions_24,value_24,value_l_24,value_r_24,ticks_25,actions_25,value_25,value_l_25,value_r_25) score from session_sample into class;
 insert into debug_log(log) values (CONCAT('call_bot_detector-class=',class));
 SELECT class;
END $$

DROP PROCEDURE IF EXISTS is_bot_ticks_detector;
CREATE PROCEDURE is_bot_ticks_detector()
BEGIN
  DECLARE class double;
  select bot_detect_ticks_score(ticks_1,ticks_2,ticks_3,ticks_4,ticks_5,ticks_6,ticks_7,ticks_8,ticks_9,ticks_10) score from ticks_session_sample into class;
 insert into debug_log(log) values (CONCAT('call_bot_ticks_detector-class=',class));
 SELECT class;
END $$
DELIMITER ;
