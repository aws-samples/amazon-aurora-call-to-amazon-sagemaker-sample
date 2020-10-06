DROP FUNCTION IF EXISTS bot_detect_score;
CREATE FUNCTION bot_detect_score (
       kart_id_1 int,ticks_1 int,action_1 int,value_1 int,value_l_1 int,value_r_1 int,kart_id_2 int,ticks_2 int,action_2 int,value_2 int,value_l_2 int,value_r_2 int,kart_id_3 int,ticks_3 int,action_3 int,value_3 int,value_l_3 int,value_r_3 int,kart_id_4 int,ticks_4 int,action_4 int,value_4 int,value_l_4 int,value_r_4 int,kart_id_5 int,ticks_5 int,action_5 int,value_5 int,value_l_5 int,value_r_5 int)
RETURNS double
       alias aws_sagemaker_invoke_endpoint
       endpoint name 'stk-bot-detector'
;
