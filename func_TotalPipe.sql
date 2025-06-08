/************************************************************
 * Code formatted by SoftTree SQL Assistant © v11.3.277
 * Time: 08/06/2025 17.06.33
 ************************************************************/

ALTER FUNCTION func_TotalPipe
(
	@teks      VARCHAR(MAX),
	@answerwidth INT
)

RETURNs INT
AS

BEGIN
	DECLARE @counter INT = 1;
	DECLARE @hasil INT;
	
	
	DECLARE @tabel TABLE(chars CHAR(2));
	
	
	WHILE @counter <= LEN(@teks)
	BEGIN
	    INSERT INTO @tabel
	      (
	        chars
	      )
	    VALUES
	      (
	        SUBSTRING(
	            SUBSTRING(@teks, 1, @counter),
	            LEN(SUBSTRING(@teks, 1, @counter)),
	            LEN(SUBSTRING(@teks, 1, @counter))
	        )
	      )
	    
	    SET @counter = @counter + 1;
	END
	
	
	SELECT @hasil=COUNT(*) * @answerwidth
	FROM   @tabel AS t
	WHERE  t.chars ='|'
	
	RETURN @hasil
END
