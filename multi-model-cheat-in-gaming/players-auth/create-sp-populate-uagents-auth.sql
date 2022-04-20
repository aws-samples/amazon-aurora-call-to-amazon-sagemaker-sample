DELIMITER $$

DROP PROCEDURE IF EXISTS populate_uagents_auth;
CREATE PROCEDURE populate_uagents_auth()
BEGIN
  DECLARE finished INTEGER DEFAULT 0;
  DECLARE rand_ua varchar(16) DEFAULT "";
  DECLARE curr_ts datetime DEFAULT "";
  DECLARE curr_id varchar(64) DEFAULT ""; 
  DECLARE curr_u varchar(16) DEFAULT "";

  DECLARE auth_cursor 
          CURSOR FOR	
                 SELECT distinct playerGuId,uagent FROM auth where uagent='TraverseSector';

  DECLARE CONTINUE HANDLER
  FOR NOT FOUND SET finished=1;

  insert into debug_log_auth (log) values('going to open enconters cursor');
  OPEN auth_cursor;

  getAuth: LOOP
       FETCH auth_cursor INTO curr_id,curr_u;
       IF finished =1 THEN
         LEAVE getAuth;
       END IF;
       select FLOOR(RAND()*10+1) into rand_ua;
       insert into debug_log_auth (log) values(concat(curr_id,',',curr_u,',',rand_ua));
       update auth set uagent=rand_ua where playerGuId=curr_id; 
  END LOOP getAuth;
  CLOSE auth_cursor;
END $$

DELIMITER ;
