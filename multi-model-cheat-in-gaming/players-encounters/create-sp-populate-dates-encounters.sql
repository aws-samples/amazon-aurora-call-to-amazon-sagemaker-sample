DELIMITER $$

DROP PROCEDURE IF EXISTS populate_dummy_dates_encounters;
CREATE PROCEDURE populate_dummy_dates_encounters()
BEGIN
  DECLARE finished INTEGER DEFAULT 0;
  DECLARE unix_timestamp_base datetime DEFAULT "2020-03-30 14:53:27";
  DECLARE unix_timestamp_random datetime DEFAULT "";
  DECLARE curr_id varchar(64) DEFAULT ""; 

  DECLARE enc_cursor 
          CURSOR FOR	
                 SELECT distinct playerGuId FROM encounters where substring_index(timestamp,'-',1)='0000';

  DECLARE CONTINUE HANDLER
  FOR NOT FOUND SET finished=1;

  insert into debug_log (log) values('going to open enconters cursor');
  OPEN enc_cursor;

  getEncounter: LOOP
       FETCH enc_cursor INTO curr_id;
       IF finished =1 THEN
         LEAVE getEncounter;
       END IF;
       select FROM_UNIXTIME(UNIX_TIMESTAMP(unix_timestamp_base) + FLOOR(0 + (RAND() * 6307200))) into unix_timestamp_random;
       insert into debug_log (log) values(concat(unix_timestamp_random,',',curr_id));
       update encounters set timestamp=unix_timestamp_random where playerGuId=curr_id;
  END LOOP getEncounter;
  CLOSE enc_cursor;
END $$

DELIMITER ;
