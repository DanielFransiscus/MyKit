/************************************************************
 * Code formatted by SoftTree SQL Assistant � v11.3.277
 * Time: 26/11/2024 10:02:01
 ************************************************************/

DECLARE @p_TransactionNo VARCHAR(25) = 'PHR/20250106-1416',
        @p_RegistrationNo VARCHAR(25) = 'REG/IP/241231-0034',
        @p_QuestionFormID VARCHAR(25) = 'MKUL',
        @p_FromDate VARCHAR(25) = '',
        @p_ToDate VARCHAR(25) = ''
 
DECLARE @NewLineChar AS CHAR(2) = CHAR(13) + CHAR(10)

SET NOCOUNT ON
CREATE TABLE ##temp_table
(
	RowIndex         INT,
	nomor            INT,
	nourut           VARCHAR(20),
	QuestionID       VARCHAR(20),
	QuestionText     VARCHAR(MAX),
	SRAnswerType     VARCHAR(20),
);

WITH cte as (
         SELECT distinct
                qig.RowIndex,
                q.SRAnswerType,
                q.QuestionID,
                q.QuestionText
         FROM   QuestionForm             AS qf WITH (NOLOCK)
                LEFT JOIN QuestionGroupInForm AS qgif WITH (NOLOCK)
                     ON  qf.QuestionFormID = qgif.QuestionFormID
                LEFT JOIN QuestionGroup  AS qg WITH (NOLOCK)
                     ON  qg.QuestionGroupID = qgif.QuestionGroupID
                LEFT JOIN QuestionInGroup AS qig WITH (NOLOCK)
                     ON  qgif.QuestionGroupID = qig.QuestionGroupID
                LEFT  JOIN Question      AS q WITH (NOLOCK)
                     ON  qig.QuestionID = q.QuestionID
         WHERE  qf.QuestionFormID = @p_QuestionFormID
                AND q.SRAnswerType != 'LBL'
     )
  
INSERT INTO ##temp_table
  (
    RowIndex,
    nomor,
    nourut,
    QuestionID,
    QuestionText,
    SRAnswerType
  )
SELECT c.RowIndex,
       ROW_NUMBER() OVER(ORDER BY c.RowIndex) AS nomor,
       CONCAT('phrl', ROW_NUMBER() OVER(ORDER BY c.RowIndex)) AS nourut,
       c.QuestionID,
       c.QuestionText,
       c.SRAnswerType
FROM   cte AS c
ORDER BY
       c.RowIndex
       
DECLARE @tot VARCHAR(10) = (
            SELECT COUNT(*)
            FROM   ##temp_table AS b
        )    
              
DECLARE @bagian1 NVARCHAR(MAX) = TRIM(
            'DECLARE @p_TransactionNo	VARCHAR(25)' + '=' + '''' + @p_TransactionNo + '''' + ',' + @NewLineChar 
            +
            '@p_RegistrationNo	VARCHAR(25)' + '=' + '''' + @p_RegistrationNo + '''' + ',' + @NewLineChar +
            
            '@p_QuestionFormID	VARCHAR(25)' + '=' + '''' + @p_QuestionFormID + '''' + @NewLineChar +
            'SELECT' + @NewLineChar +
            'phr.TransactionNo,' + @NewLineChar +
            's.ServiceUnitName,  ' + @NewLineChar +
            'qf.RmNO,  ' + @NewLineChar +
            'p.MedicalNo,  ' + @NewLineChar
        )

DECLARE @bagian1_1     NVARCHAR(MAX) = TRIM(
            'DECLARE @p_FromDate ' + 'DATETIME' + '=' + '''' + @p_FromDate + '''' + ',' +
            
            '@p_ToDate	DATETIME' + '=' + '''' + @p_ToDate + '''' +
            
            'SELECT' + @NewLineChar +
            'phr.TransactionNo,' + @NewLineChar
        )
 
DECLARE @bagian2       VARCHAR(MAX) = TRIM(
            (
                SELECT STRING_AGG(
                           CASE 
                                WHEN b.SRAnswerType = 'SIG' THEN @NewLineChar + b.nourut + '.BodyImage' +
                                     ' AS ' + '''' + 
                                     LEFT(REPLACE(b.QuestionText, ',', ''), 45)+ '_' +b.QuestionID  +
                                     
                                     CASE 
                                          WHEN @tot = b.nomor THEN ''''
                                          ELSE ''','
                                     END
                                WHEN b.SRAnswerType IN ('CTX', 'CTM') THEN ' SUBSTRING(' + b.nourut +
                                     '.QuestionAnswerText, 1, 1)' +
                                     ' AS ' + '''' + LEFT(REPLACE(b.QuestionText, ',', ''), 45)+ '_' +b.QuestionID  + CASE 
                                                                                                                            WHEN 
                                                                                                                                 @tot 
                                                                                                                                 =
                                                                                                                                 b.nomor THEN 
                                                                                                                                 ''''
                                                                                                                            ELSE 
                                                                                                                                 ''','
                                                                                                                       END 
                                     +
                                     @NewLineChar +
                                     'CASE ' +
                                     'WHEN SUBSTRING(' + b.nourut +
                                     '.QuestionAnswerText, 1, 2) = ''1|'' THEN LTRIM(REPLACE(' + b.nourut +
                                     '.QuestionAnswerText, ''1|'', '''')) ' +
                                     'WHEN SUBSTRING(' + b.nourut +
                                     '.QuestionAnswerText, 1, 2) = ''0|'' THEN LTRIM(REPLACE(' + b.nourut +
                                     '.QuestionAnswerText, ''0|'', '''')) ' +
                                     'END ' +
                                     'AS ''' + 'keterangan_'  + LEFT(REPLACE(b.QuestionText, ',', ''), 45) + '_' +b.QuestionID +
                                     + CASE 
                                            WHEN @tot 
                                                 =
                                                 b.nomor THEN ''''
                                            ELSE ''','
                                       END 
                                     + @NewLineChar
                                ELSE @NewLineChar + b.nourut + '.QuestionAnswerText' +
                                     ' AS ' + ''''  +
                                     LEFT(REPLACE(b.QuestionText, ',', ''), 45)+ '_'  +b.QuestionID +
                                     
                                     CASE 
                                          WHEN @tot = b.nomor THEN ''''
                                          ELSE ''','
                                     END
                           END,
                           @NewLineChar
                       )             AS teks
                FROM   ##temp_table  AS b
            )
        );
        
          
        
DECLARE @bagian3     VARCHAR(MAX) = TRIM(
            @NewLineChar + 'FROM   PatientHealthRecord         AS phr with (NOLOCK) ' +
            @NewLineChar + 'LEFT JOIN ServiceUnit       AS s WITH (NOLOCK)' +
            @NewLineChar + '	ON  phr.ServiceUnitID = s.ServiceUnitID ' +
            @NewLineChar + 'LEFT JOIN QuestionForm      AS qf WITH (NOLOCK)' +
            @NewLineChar + '	ON  phr.QuestionFormID = qf.QuestionFormID' +
            @NewLineChar + 'LEFT JOIN Registration      AS r WITH(NOLOCK)' +
            @NewLineChar + '	ON  phr.RegistrationNo = r.RegistrationNo  ' +
            @NewLineChar + 'LEFT JOIN Patient           AS p WITH(NOLOCK)' +
            @NewLineChar + '	ON  r.PatientID = p.PatientID  '
        )
        
        
DECLARE @bagian4     VARCHAR(MAX) = TRIM(
            (
                SELECT STRING_AGG(
                           CAST(
                               'LEFT JOIN PatientHealthRecordLine AS ' + b.nourut + ' WITH (NOLOCK)' + @NewLineChar 
                               +
                               '	ON ' + b.nourut + '.TransactionNo = ' +
                               
                               'phr.TransactionNo' + @NewLineChar + '	' + ' AND ' +
                               b.nourut + '.QuestionID = ' + '''' + b.QuestionID + ''''
                               
                               as VARCHAR(MAX)
                           ),
                           @NewLineChar
                       )             AS teks
                FROM   ##temp_table  AS b
            )
        )


DECLARE @where1 VARCHAR(MAX) = TRIM(
            'WHERE  phr.TransactionNo = @p_TransactionNo' + @NewLineChar +
            'AND phr.QuestionFormID = @p_QuestionFormID' + @NewLineChar +
            'AND phr.RegistrationNo = @p_RegistrationNo'
        )

DECLARE @where2 VARCHAR(MAX) = TRIM(
            'WHERE phr.QuestionFormID = ' + '''' + @p_QuestionFormID + '''' + @NewLineChar +
            ' AND phr.RecordDate > = @p_FromDate
       AND phr.RecordDate <= @p_ToDate'
        )
        
 
        
IF @p_TransactionNo != ''
   AND @p_RegistrationNo != ''
   AND @p_QuestionFormID != ''
   AND @p_FromDate = ''
   AND @p_ToDate = ''
BEGIN
    SELECT @bagian1 + @bagian2 + @bagian3 + @NewLineChar + @bagian4 + @NewLineChar +
           @where1 AS result
END

IF @p_TransactionNo = ''
   AND @p_RegistrationNo = ''
   AND @p_QuestionFormID != ''
   AND @p_FromDate != ''
   AND @p_ToDate != ''
BEGIN
    SELECT @bagian1_1 + @bagian2 + @bagian3 + @NewLineChar + @bagian4 + @NewLineChar 
           + @where2 AS result
END

                        
DROP TABLE ##temp_table






