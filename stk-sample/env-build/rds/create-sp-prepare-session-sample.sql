DELIMITER $$

DROP PROCEDURE IF EXISTS prepare_session_sample;
CREATE PROCEDURE prepare_session_sample()
BEGIN
  DECLARE sample text;
  DECLARE finished INTEGER DEFAULT 0;
  DECLARE _count INT DEFAULT 1;
  DECLARE i INTEGER DEFAULT 0;

  DECLARE _cursor 
          CURSOR FOR	
		select group_concat(concat(m_ticks,',',m_action,',',m_value,',',m_value_l,',',m_value_r)) as sample 
		from (
			select concat(id,"-",m_kart_id) id, m_ticks,m_action,m_value,m_value_l,m_value_r 
			from (
				select id,m_kart_id,m_ticks,m_action,m_value,m_value_l,m_value_r 
				from (
					select id,m_kart_id,m_ticks,m_action,m_value,m_value_l,m_value_r 
					from actions order by id desc limit 70) t1 order by m_kart_id limit 25) t2) t3;
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

       WHILE _count < 126 DO 
         insert into vertical_session values(_count,split_string(sample,',',_count),'session');
         SET _count = _count + 1;
       END WHILE;
       insert into session_sample (session,ticks_1,actions_1,value_1,value_l_1,value_r_1,ticks_2,actions_2,value_2,value_l_2,value_r_2,ticks_3,actions_3,value_3,value_l_3,value_r_3,ticks_4,actions_4,value_4,value_l_4,value_r_4,ticks_5,actions_5,value_5,value_l_5,value_r_5,ticks_6,actions_6,value_6,value_l_6,value_r_6,ticks_7,actions_7,value_7,value_l_7,value_r_7,ticks_8,actions_8,value_8,value_l_8,value_r_8,ticks_9,actions_9,value_9,value_l_9,value_r_9,ticks_10,actions_10,value_10,value_l_10,value_r_10,ticks_11,actions_11,value_11,value_l_11,value_r_11,ticks_12,actions_12,value_12,value_l_12,value_r_12,ticks_13,actions_13,value_13,value_l_13,value_r_13,ticks_14,actions_14,value_14,value_l_14,value_r_14,ticks_15,actions_15,value_15,value_l_15,value_r_15,ticks_16,actions_16,value_16,value_l_16,value_r_16,ticks_17,actions_17,value_17,value_l_17,value_r_17,ticks_18,actions_18,value_18,value_l_18,value_r_18,ticks_19,actions_19,value_19,value_l_19,value_r_19,ticks_20,actions_20,value_20,value_l_20,value_r_20,ticks_21,actions_21,value_21,value_l_21,value_r_21,ticks_22,actions_22,value_22,value_l_22,value_r_22,ticks_23,actions_23,value_23,value_l_23,value_r_23,ticks_24,actions_24,value_24,value_l_24,value_r_24,ticks_25,actions_25,value_25,value_l_25,value_r_25)
       select session,
	max(case when ind=1 then value end) as  ticks_1,
	max(case when ind=2 then value end) as  actions_1,
	max(case when ind=3 then value end) as  value_1,
	max(case when ind=4 then value end) as  value_l_1,
	max(case when ind=5 then value end) as  value_r_1,
	max(case when ind=6 then value end) as  ticks_2,
	max(case when ind=7 then value end) as  actions_2,
	max(case when ind=8 then value end) as  value_2,
	max(case when ind=9 then value end) as  value_l_2,
	max(case when ind=10 then value end) as value_r_2,
	max(case when ind=11 then value end) as ticks_3,
	max(case when ind=12 then value end) as actions_3,
	max(case when ind=13 then value end) as value_3,
	max(case when ind=14 then value end) as value_l_3,
	max(case when ind=15 then value end) as value_r_3,
	max(case when ind=16 then value end) as ticks_4,
	max(case when ind=17 then value end) as actions_4,
	max(case when ind=18 then value end) as value_4,
	max(case when ind=19 then value end) as value_l_4,
	max(case when ind=20 then value end) as value_r_4,
	max(case when ind=21 then value end) as ticks_5,
	max(case when ind=22 then value end) as actions_5,
	max(case when ind=23 then value end) as value_5,
	max(case when ind=24 then value end) as value_l_5,
	max(case when ind=25 then value end) as value_r_5,
	max(case when ind=26 then value end) as ticks_6,
	max(case when ind=27 then value end) as actions_6,
	max(case when ind=28 then value end) as value_6,
	max(case when ind=29 then value end) as value_l_6,
	max(case when ind=30 then value end) as value_r_6,
	max(case when ind=31 then value end) as ticks_7,
	max(case when ind=32 then value end) as actions_7,
	max(case when ind=33 then value end) as value_7,
	max(case when ind=34 then value end) as value_l_7,
	max(case when ind=35 then value end) as value_r_7,
	max(case when ind=36 then value end) as ticks_8,
	max(case when ind=37 then value end) as actions_8,
	max(case when ind=38 then value end) as value_8,
	max(case when ind=39 then value end) as value_l_8,
	max(case when ind=40 then value end) as value_r_8,
	max(case when ind=41 then value end) as ticks_9,
	max(case when ind=42 then value end) as actions_9,
	max(case when ind=43 then value end) as value_9,
	max(case when ind=44 then value end) as value_l_9,
	max(case when ind=45 then value end) as value_r_9,
	max(case when ind=46 then value end) as ticks_10,
	max(case when ind=47 then value end) as actions_10,
	max(case when ind=48 then value end) as value_10,
	max(case when ind=49 then value end) as value_l_10,
	max(case when ind=50 then value end) as value_r_10,
	max(case when ind=51 then value end) as ticks_11,
	max(case when ind=52 then value end) as actions_11,
	max(case when ind=53 then value end) as value_11,
	max(case when ind=54 then value end) as value_l_11,
	max(case when ind=55 then value end) as value_r_11,
	max(case when ind=56 then value end) as ticks_12,
	max(case when ind=57 then value end) as actions_12,
	max(case when ind=58 then value end) as value_12,
	max(case when ind=59 then value end) as value_l_12,
	max(case when ind=60 then value end) as value_r_12,
	max(case when ind=61 then value end) as ticks_13,
	max(case when ind=62 then value end) as actions_13,
	max(case when ind=63 then value end) as value_13,
	max(case when ind=64 then value end) as value_l_13,
	max(case when ind=65 then value end) as value_r_13,
	max(case when ind=66 then value end) as ticks_14,
	max(case when ind=67 then value end) as actions_14,
	max(case when ind=68 then value end) as value_14,
	max(case when ind=69 then value end) as value_l_14,
	max(case when ind=70 then value end) as value_r_14,
	max(case when ind=71 then value end) as ticks_15,
	max(case when ind=72 then value end) as actions_15,
	max(case when ind=73 then value end) as value_15,
	max(case when ind=74 then value end) as value_l_15,
	max(case when ind=75 then value end) as value_r_15,
	max(case when ind=76 then value end) as ticks_16,
	max(case when ind=77 then value end) as actions_16,
	max(case when ind=78 then value end) as value_16,
	max(case when ind=79 then value end) as value_l_16,
	max(case when ind=80 then value end) as value_r_16,
	max(case when ind=81 then value end) as ticks_17,
	max(case when ind=82 then value end) as actions_17,
	max(case when ind=83 then value end) as value_17,
	max(case when ind=84 then value end) as value_l_17,
	max(case when ind=85 then value end) as value_r_17,
	max(case when ind=86 then value end) as ticks_18,
	max(case when ind=87 then value end) as actions_18,
	max(case when ind=88 then value end) as value_18,
	max(case when ind=89 then value end) as value_l_18,
	max(case when ind=90 then value end) as value_r_18,
	max(case when ind=91 then value end) as ticks_19,
	max(case when ind=92 then value end) as actions_19,
	max(case when ind=93 then value end) as value_19,
	max(case when ind=94 then value end) as value_l_19,
	max(case when ind=95 then value end) as value_r_19,
	max(case when ind=96 then value end) as ticks_20,
	max(case when ind=97 then value end) as actions_20,
	max(case when ind=98 then value end) as value_20,
	max(case when ind=99 then value end) as value_l_20,
	max(case when ind=100 then value end) as value_r_20,
	max(case when ind=101 then value end) as ticks_21,
	max(case when ind=102 then value end) as actions_21,
	max(case when ind=103 then value end) as value_21,
	max(case when ind=104 then value end) as value_l_21,
	max(case when ind=105 then value end) as value_r_21,
	max(case when ind=106 then value end) as ticks_22,
	max(case when ind=107 then value end) as actions_22,
	max(case when ind=108 then value end) as value_22,
	max(case when ind=109 then value end) as value_l_22,
	max(case when ind=1010 then value end) as value_r_22,
	max(case when ind=111 then value end) as ticks_23,
	max(case when ind=112 then value end) as actions_23,
	max(case when ind=113 then value end) as value_23,
	max(case when ind=114 then value end) as value_l_23,
	max(case when ind=115 then value end) as value_r_23,
	max(case when ind=116 then value end) as ticks_24,
	max(case when ind=117 then value end) as actions_24,
	max(case when ind=118 then value end) as value_24,
	max(case when ind=119 then value end) as value_l_24,
	max(case when ind=120 then value end) as value_r_24,
	max(case when ind=121 then value end) as ticks_25,
	max(case when ind=122 then value end) as actions_25,
	max(case when ind=123 then value end) as value_25,
	max(case when ind=124 then value end) as value_l_25,
	max(case when ind=125 then value end) as value_r_25
       from vertical_session group by session; 
       insert into debug_log (log) values(CONCAT('sample=',sample,' count=',_count));
  END LOOP getSample;
  CLOSE _cursor;
END $$

DELIMITER ;
