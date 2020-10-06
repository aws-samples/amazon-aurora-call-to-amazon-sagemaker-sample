DROP FUNCTION IF EXISTS bot_detect_score;
CREATE FUNCTION bot_detect_score (
       col text)
RETURNS double
       alias aws_sagemaker_invoke_endpoint
       endpoint name 'stk-bot-detector'
;
