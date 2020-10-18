SHOW WARNINGS;
DROP FUNCTION IF EXISTS bot_detect_score;
CREATE FUNCTION bot_detect_score (
  ticks_1 int(11),action_1 int(11),value_1 int(11),value_l_1 int(11),value_r_1 int(11),ticks_2 int(11),action_2 int(11),value_2 int(11),value_l_2 int(11),value_r_2 int(11),ticks_3 int(11),action_3 int(11),value_3 int(11),value_l_3 int(11),value_r_3 int(11),ticks_4 int(11),action_4 int(11),value_4 int(11),value_l_4 int(11),value_r_4 int(11),ticks_5 int(11),action_5 int(11),value_5 int(11),value_l_5 int(11),value_r_5 int(11),ticks_6 int(11),action_6 int(11),value_6 int(11),value_l_6 int(11),value_r_6 int(11),ticks_7 int(11),action_7 int(11),value_7 int(11),value_l_7 int(11),value_r_7 int(11),ticks_8 int(11),action_8 int(11),value_8 int(11),value_l_8 int(11),value_r_8 int(11),
ticks_9 int(11),action_9 int(11),value_9 int(11),value_l_9 int(11),value_r_9 int(11),ticks_10 int(11),action_10 int(11),value_10 int(11),value_l_10 int(11),value_r_10 int(11),ticks_11 int(11),action_11 int(11),value_11 int(11),value_l_11 int(11),value_r_11 int(11),ticks_12 int(11),action_12 int(11),value_12 int(11),value_l_12 int(11),value_r_12 int(11),
ticks_13 int(11),action_13 int(11),value_13 int(11),value_l_13 int(11),value_r_13 int(11),ticks_14 int(11),action_14 int(11),value_14 int(11),value_l_14 int(11),value_r_14 int(11),ticks_15 int(11),action_15 int(11),value_15 int(11),value_l_15 int(11),value_r_15 int(11),ticks_16 int(11),action_16 int(11),value_16 int(11),value_l_16 int(11),value_r_16 int(11),
ticks_17 int(11),action_17 int(11),value_17 int(11),value_l_17 int(11),value_r_17 int(11),ticks_18 int(11),action_18 int(11),value_18 int(11),value_l_18 int(11),value_r_18 int(11),ticks_19 int(11),action_19 int(11),value_19 int(11),value_l_19 int(11),value_r_19 int(11),ticks_20 int(11),action_20 int(11),value_20 int(11),value_l_20 int(11),value_r_20 int(11),
ticks_21 int(11),action_21 int(11),value_21 int(11),value_l_21 int(11),value_r_21 int(11),ticks_22 int(11),action_22 int(11),value_22 int(11),value_l_22 int(11),value_r_22 int(11),ticks_23 int(11),action_23 int(11),value_23 int(11),value_l_23 int(11),value_r_23 int(11),ticks_24 int(11),action_24 int(11),value_24 int(11),value_l_24 int(11),value_r_24 int(11),
ticks_25 int(11),action_25 int(11),value_25 int(11),value_l_25 int(11),value_r_25 int(11))
RETURNS double
       alias aws_sagemaker_invoke_endpoint
       endpoint name 'stk-bot-detector'
;
DROP FUNCTION IF EXISTS bot_detect_ticks_score;
CREATE FUNCTION bot_detect_ticks_score (
  ticks_1 int(11),ticks_2 int(11),ticks_3 int(11),ticks_4 int(11),ticks_5 int(11),ticks_6 int(11),ticks_7 int(11),ticks_8 int(11),ticks_9 int(11),ticks_10 int(11))
RETURNS varchar(256)
       alias aws_sagemaker_invoke_endpoint
       endpoint name 'stk-bot-detect-ticks'
;
