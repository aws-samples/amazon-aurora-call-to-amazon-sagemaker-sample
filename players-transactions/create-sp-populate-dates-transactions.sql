DELIMITER $$

DROP PROCEDURE IF EXISTS populate_dummy_dates_transactions;
CREATE PROCEDURE populate_dummy_dates_transactions()
BEGIN
  DECLARE finished INTEGER DEFAULT 0;
  DECLARE unix_timestamp_base datetime DEFAULT "2020-03-30 14:53:27";
  DECLARE unix_timestamp_random datetime DEFAULT "";
  DECLARE curr_ts datetime DEFAULT "";
  DECLARE curr_id varchar(64) DEFAULT ""; 
  DECLARE curr_n varchar(16) DEFAULT "";

  DECLARE enc_cursor 
          CURSOR FOR	
                 SELECT distinct playerGuId,name FROM transactions where substring_index(timestamp,'-',1)='0000';

  DECLARE CONTINUE HANDLER
  FOR NOT FOUND SET finished=1;

  insert into debug_log_transactions (log) values('going to open enconters cursor');
  OPEN enc_cursor;

  getTransactions: LOOP
       FETCH enc_cursor INTO curr_id,curr_n;
       IF finished =1 THEN
         LEAVE getTransactions;
       END IF;
       select FROM_UNIXTIME(UNIX_TIMESTAMP(unix_timestamp_base) + FLOOR(0 + (RAND() * 6307200))) into unix_timestamp_random;
       insert into debug_log_transactions (log) values(concat(unix_timestamp_random,curr_id,curr_n));
       update transactions set timestamp=unix_timestamp_random where playerGuId=curr_id and name=curr_n;
  END LOOP getTransactions;
  CLOSE enc_cursor;
END $$

DELIMITER ;
