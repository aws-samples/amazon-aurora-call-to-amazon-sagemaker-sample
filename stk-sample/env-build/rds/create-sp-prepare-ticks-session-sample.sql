DELIMITER $$

DROP PROCEDURE IF EXISTS prepare_ticks_session_sample;
CREATE PROCEDURE prepare_ticks_session_sample()
BEGIN
  DECLARE sample text;
  DECLARE finished INTEGER DEFAULT 0;
  DECLARE _count INT DEFAULT 1;
  DECLARE i INTEGER DEFAULT 0;

  DECLARE _cursor 
          CURSOR FOR
--TODO - wrong session aggregation -	
            select group_concat(concat(m_ticks)) as sample from (select concat(id,"-",m_kart_id) id, m_ticks from (select * from (select * from (select m_kart_id,m_ticks from actions where class is null order by id desc limit 50) t1 order by m_kart_id limit 10) t2 order by m_ticks) t3) t4;
--                                        where id < (select FLOOR(0 + (RAND() * 1000)))
--                                        and id > (select FLOOR(0 + (RAND() * 10000)))

  DECLARE CONTINUE HANDLER
  FOR NOT FOUND SET finished=1;

  insert into debug_log (log) values('executed sample');
  OPEN _cursor;

  getSample: LOOP
       FETCH _cursor INTO sample;
       IF finished =1 THEN
         LEAVE getSample;
       END IF;
       truncate table vertical_session; 

       WHILE _count < 11 DO 
         insert into vertical_session values(_count,split_string(sample,',',_count),'session');
         SET _count = _count + 1;
       END WHILE;
       insert into ticks_session_sample (session,ticks_1,ticks_2,ticks_3,ticks_4,ticks_5,ticks_6,ticks_7,ticks_8,ticks_9,ticks_10)
       select session,
	max(case when ind=1 then value end) as  ticks_1,
	max(case when ind=2 then value end) as  ticks_2,
	max(case when ind=3 then value end) as ticks_3,
	max(case when ind=4 then value end) as ticks_4,
	max(case when ind=5 then value end) as ticks_5,
	max(case when ind=6 then value end) as ticks_6,
	max(case when ind=7 then value end) as ticks_7,
	max(case when ind=8 then value end) as ticks_8,
	max(case when ind=9 then value end) as ticks_9,
	max(case when ind=10 then value end) as ticks_10
       from vertical_session group by session; 
       insert into debug_log (log) values(CONCAT('sample=',sample,' count=',_count));
  END LOOP getSample;
  CLOSE _cursor;
END $$

DELIMITER ;
