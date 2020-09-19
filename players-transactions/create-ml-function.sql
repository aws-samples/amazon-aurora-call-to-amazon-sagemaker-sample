DROP FUNCTION IF EXISTS trans_cheat_score;
CREATE FUNCTION trans_cheat_score (
       month int,day int,hour int, minute int,name_encoded int(11),
       uagent int(11))
RETURNS double
       alias aws_sagemaker_invoke_endpoint
       endpoint name 'trans-cheat'
;
