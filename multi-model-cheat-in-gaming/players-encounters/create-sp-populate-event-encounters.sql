DELIMITER $$

DROP PROCEDURE IF EXISTS populate_event_encountes;
CREATE PROCEDURE populate_event_encountes()
BEGIN
  DECLARE finished INTEGER DEFAULT 0;
  DECLARE c_eventName varchar(64);
  DECLARE encoded_event INTEGER DEFAULT 0;

  DECLARE enc_cursor 
          CURSOR FOR	
                 select distinct eventName from (SELECT eventName FROM encounters limit 10) t;

  DECLARE CONTINUE HANDLER
  FOR NOT FOUND SET finished=1;

  insert into debug_log (log) values('going to open enconters cursor');
  OPEN enc_cursor;

  getEncounter: LOOP
       FETCH enc_cursor INTO c_eventName;
       IF finished =1 THEN
         LEAVE getEncounter;
       END IF;
       select encoded_event+1 into encoded_event;
       insert into debug_log (log) values(concat(encoded_event,',',c_eventName));
  END LOOP getEncounter;
  CLOSE enc_cursor;
END $$

DELIMITER ;
