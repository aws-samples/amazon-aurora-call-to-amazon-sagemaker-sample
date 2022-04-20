DELIMITER $$

DROP PROCEDURE IF EXISTS populate_ip_auth;
CREATE PROCEDURE populate_ip_auth()
BEGIN
  DECLARE finished INTEGER DEFAULT 0;
  DECLARE curr_t datetime DEFAULT "";
  DECLARE curr_id varchar(64) DEFAULT ""; 
  DECLARE curr_u int;
  DECLARE curr_ip varchar(64) DEFAULT "";
  DECLARE rand_octat varchar(64) DEFAULT "";
  DECLARE new_ip varchar(64) DEFAULT "";

  DECLARE auth_cursor 
          CURSOR FOR	
                 SELECT playerGuid,uagent,timestamp from auth where uagent=11 and month(timestamp)<=5;

  DECLARE CONTINUE HANDLER
  FOR NOT FOUND SET finished=1;

  insert into debug_log_auth (log) values('going to open enconters cursor');
  OPEN auth_cursor;

  getAuth: LOOP
       FETCH auth_cursor INTO curr_id,curr_u,curr_t;
       IF finished =1 THEN
         LEAVE getAuth;
       END IF;
       select FLOOR(RAND()*254+1) into rand_octat;
       select concat(substring_index('249.191.89','.',3),".",rand_octat) into new_ip;
       insert into debug_log_auth (log) values(new_ip);
       update auth set src_ip=new_ip where playerGuId=curr_id and uagent=curr_u and timestamp=curr_t; 
       /* 249.191.89, 159.214.253 */
  END LOOP getAuth;
  CLOSE auth_cursor;
END $$

DELIMITER ;
