CREATE FUNCTION `hostId`(`host` VARBINARY(255)) RETURNS BIGINT UNSIGNED
    READS SQL DATA
BEGIN
DECLARE result BIGINT UNSIGNED;
SELECT id INTO result FROM host WHERE v=host;
IF result IS NULL THEN
  RETURN NULL;
END IF;
RETURN result;
END ;;