DROP FUNCTION IF EXISTS move_cheat_score;
CREATE FUNCTION move_cheat_score (
       playerx double, playerz double,
       quadrant int(11), sector int(11),
       event int(11))
RETURNS double
       alias aws_sagemaker_invoke_endpoint
       endpoint name 'move-cheat'
;
