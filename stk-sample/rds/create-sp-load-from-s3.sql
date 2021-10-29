DELIMITER $$

DROP PROCEDURE IF EXISTS load_actions_from_s3;
CREATE PROCEDURE load_actions_from_s3(
	IN s3uri VARCHAR(255))
BEGIN

  FOR NOT FOUND SET finished=1;
  LOAD DATA FROM S3 's3://stk-events/2020/09/18/01/stk-5-2020-09-18-01-54-05-bc01ff9b-7121-4470-8d6f-bace1d397c12'
    INTO TABLE actions
    FIELDS TERMINATED BY ' '
    LINES TERMINATED BY '\n'
    (m_ticks,m_kart_id,m_action,m_value,m_value_l,m_value_r);

END $$

DELIMITER ;
