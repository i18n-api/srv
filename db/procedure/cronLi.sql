CREATE PROCEDURE `cronLi`()
    MODIFIES SQL DATA
BEGIN
 DECLARE now INT UNSIGNED;
 SET now=ROUND(UNIX_TIMESTAMP(NOW())/60)+1;
 UPDATE cron SET next=now+timeout WHERE next+1<=now;
 SELECT id,dir,sh,timeout FROM cron WHERE next=now+timeout;
END ;;