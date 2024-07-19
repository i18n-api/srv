CREATE PROCEDURE `splitMail`(IN mail VARBINARY(255),OUT username VARBINARY(255),OUT host VARBINARY(255))
BEGIN
  DECLARE p INT;
  SET p=LOCATE('@',mail);
  SET username=SUBSTRING(mail,1,p - 1);
  SET host=SUBSTRING(mail,p + 1);
END ;;