DROP FUNCTION IF EXISTS auth_cheat_score;
CREATE FUNCTION auth_cheat_score (
       uagent int(11),day int,month int,hour int,minute int,src_ip_encoded int(11))
RETURNS double
       alias aws_sagemaker_invoke_endpoint
       endpoint name 'auth-cheat'
;
