/************************************************************
 * Code formatted by SoftTree SQL Assistant © v11.3.277
 * Time: 24/11/2024 19:10:29
 ************************************************************/

DECLARE @p_TransactionNo      VARCHAR(25) = 'PHR/20241112-0060',
        @p_RegistrationNo     VARCHAR(25) = 'REG/EM/241112-0011',
        @p_QuestionFormID     VARCHAR(25) = 'KMOS',
        @p_FromDate           VARCHAR(25) = '',
        @p_ToDate             VARCHAR(25) = ''
   
 
SET NOCOUNT on
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
                left  JOIN Question      AS q WITH (NOLOCK)
                     ON  qig.QuestionID = q.QuestionID
                LEFT JOIN QuestionAnswerSelection AS qas WITH (NOLOCK)
                     ON  q.QuestionAnswerSelectionID = qas.QuestionAnswerSelectionID
                LEFT JOIN QuestionAnswerSelectionLine AS qasl WITH (NOLOCK)
                     ON  qas.QuestionAnswerSelectionID = qasl.QuestionAnswerSelectionID
                LEFT JOIN AppProgram     AS ap WITH (NOLOCK)
                     ON  qf.ReportProgramID = ap.ProgramID
         WHERE  qf.QuestionFormID = @p_QuestionFormID
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
        
        

         
       
DECLARE @bagian1 NVARCHAR(MAX) = (
            'DECLARE @p_TransactionNo	VARCHAR(25)' + '=' + '''' + @p_TransactionNo + '''' + ',' + CHAR(13) + CHAR(10) 
            +
            '@p_RegistrationNo	VARCHAR(25)' + '=' + '''' + @p_RegistrationNo + '''' + ',' + CHAR(13) + CHAR(10) +
            
            '@p_QuestionFormID	VARCHAR(25)' + '=' + '''' + @p_QuestionFormID + '''' + CHAR(13) + CHAR(10) +
            
            
            
            'SELECT' + CHAR(13) + CHAR(10) +
            'phr.TransactionNo,' + CHAR(13) + CHAR(10) +
            's.ServiceUnitName,  ' + CHAR(13) + CHAR(10) +
            'qf.RmNO,  ' + CHAR(13) + CHAR(10) +
            'p.MedicalNo,  ' + CHAR(13) + CHAR(10)
        )

DECLARE @bagian1_1     NVARCHAR(MAX) = (
            'DECLARE @p_FromDate ' + 'DATETIME' + '=' + '''' + @p_FromDate + '''' + ',' +
            
            '@p_ToDate	DATETIME' + '=' + '''' + @p_ToDate + '''' +
            
            'SELECT' + CHAR(13) + CHAR(10) +
            'phr.TransactionNo,' + CHAR(13) + CHAR(10)
        )
       
        



DECLARE @teks1         VARCHAR(MAX) = (
            SELECT STRING_AGG(
                       CASE 
                            WHEN b.SRAnswerType = 'SIG' THEN CHAR(13) + CHAR(10) + b.nourut + '.BodyImage' +
                                 ' AS ' + '''' +
                                 LEFT(REPLACE(b.QuestionText, ',', ''), 45) +
                                 
                                 CASE 
                                      WHEN @tot = b.nomor THEN ''''
                                      ELSE ''','
                                 END
                            WHEN b.SRAnswerType = 'CTX' THEN ' SUBSTRING(' + b.nourut + '.QuestionAnswerText, 1, 1)' +
                                 ' AS ' + '''' + LEFT(REPLACE(b.QuestionText, ',', ''), 45) + CASE 
                                                                                                   WHEN @tot = b.nomor THEN 
                                                                                                        ''''
                                                                                                   ELSE ''','
                                                                                              END + CHAR(13) + CHAR(10) + 
                        'CASE ' +
'WHEN SUBSTRING(' + b.nourut + '.QuestionAnswerText, 1, 2) = ''1|'' THEN LTRIM(REPLACE(' + b.nourut + '.QuestionAnswerText, ''1|'', '''')) ' +
'WHEN SUBSTRING(' + b.nourut + '.QuestionAnswerText, 1, 2) = ''0|'' THEN LTRIM(REPLACE(' + b.nourut + '.QuestionAnswerText, ''0|'', '''')) ' +
'END ' +
'AS ''' + 'keterangan_' + LEFT(REPLACE(b.QuestionText, ',', ''), 45) + CASE 
                                                     WHEN @tot = b.nomor THEN ''''
                                                     ELSE ''','
                                                 END + CHAR(13) + CHAR(10)

                                                                                              
                         
                                                                                              
                                                                                              
                                                                                              
                                                                                              
                                                                                              
                            ELSE CHAR(13) + CHAR(10) + b.nourut + '.QuestionAnswerText' +
                                 ' AS ' + '''' +
                                 LEFT(REPLACE(b.QuestionText, ',', ''), 45) +
                                 
                                 CASE 
                                      WHEN @tot = b.nomor THEN ''''
                                      ELSE ''','
                                 END
                       END,
                       CHAR(13) + CHAR(10)
                   )             AS teks
            FROM   ##temp_table  AS b
        );
        
          
        
DECLARE @teks2     VARCHAR(MAX) = (
            CHAR(13) + CHAR(10) + 'FROM   PatientHealthRecord         AS phr with (NOLOCK) ' +
            CHAR(13) + CHAR(10) + 'LEFT JOIN ServiceUnit       AS s WITH (NOLOCK)' +
            CHAR(13) + CHAR(10) + '	ON  phr.ServiceUnitID = s.ServiceUnitID ' +
            CHAR(13) + CHAR(10) + 'LEFT JOIN QuestionForm      AS qf WITH (NOLOCK)' +
            CHAR(13) + CHAR(10) + '	ON  phr.QuestionFormID = qf.QuestionFormID' +
            CHAR(13) + CHAR(10) + 'LEFT JOIN Registration      AS r WITH(NOLOCK)' +
            CHAR(13) + CHAR(10) + '	ON  phr.RegistrationNo = r.RegistrationNo  ' +
            CHAR(13) + CHAR(10) + 'LEFT JOIN Patient           AS p WITH(NOLOCK)' +
            CHAR(13) + CHAR(10) + '	ON  r.PatientID = p.PatientID  '
        )
        
        
DECLARE @teks3     VARCHAR(MAX) = (
            SELECT STRING_AGG(
                       CAST(
                           'LEFT JOIN PatientHealthRecordLine AS ' + b.nourut + ' WITH (NOLOCK)' + CHAR(13) + CHAR(10) +
                           '	ON ' + b.nourut + '.TransactionNo = ' +
                           
                           'phr.TransactionNo' + CHAR(13) + CHAR(10) + '	' + ' AND ' +
                           b.nourut + '.QuestionID = ' + '''' + b.QuestionID + ''''
                           
                           as VARCHAR(MAX)
                       ),
                       CHAR(13) + CHAR(10)
                   )             AS teks
            FROM   ##temp_table  AS b
        )


DECLARE @where1 VARCHAR(MAX) = (
            'WHERE  phr.TransactionNo = @p_TransactionNo' + CHAR(13) + CHAR(10) +
            'AND phr.QuestionFormID = @p_QuestionFormID' + CHAR(13) + CHAR(10) +
            'AND phr.RegistrationNo = @p_RegistrationNo'
        )

DECLARE @where2 VARCHAR(MAX) = (
            'WHERE phr.QuestionFormID = ' + '''' + @p_QuestionFormID + '''' + CHAR(13) + CHAR(10) +
            ' AND phr.RecordDate > = @p_FromDate
       AND phr.RecordDate <= @p_ToDate'
        )
        
 
        
IF @p_TransactionNo != ''
   AND @p_RegistrationNo != ''
   AND @p_QuestionFormID != ''
   AND @p_FromDate = ''
   AND @p_ToDate = ''
BEGIN
    SELECT TRIM(@bagian1) + TRIM(@teks1) + TRIM(@teks2) + CHAR(13) + CHAR(10) + TRIM(@teks3) + CHAR(13) + CHAR(10) +
           TRIM(@where1)
END

IF @p_TransactionNo = ''
   AND @p_RegistrationNo = ''
   AND @p_QuestionFormID != ''
   AND @p_FromDate != ''
   AND @p_ToDate != ''
BEGIN
    SELECT TRIM(@bagian1_1) + TRIM(@teks1) + TRIM(@teks2) + CHAR(13) + CHAR(10) + TRIM(@teks3) + CHAR(13) + CHAR(10) 
           + TRIM(@where2)
END



            
            
            
            
            
DROP TABLE ##temp_table
     
       
     
       

	