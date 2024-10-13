/************************************************************
 * Code formatted by SoftTree SQL Assistant © v11.3.277
 * Time: 13/10/2024 17:12:57
 ************************************************************/

--phr generator
--kutip empat mencetak single quote
 
DECLARE @p_TransactionNo      VARCHAR(25) = 'PHR/20241007-0642',
        @p_RegistrationNo     VARCHAR(25) = 'REG/OP/220614-0539',
        @p_QuestionFormID     VARCHAR(25) = 'KMOS'  
   
 
SET NOCOUNT on
CREATE TABLE ##bagsatu
(
	RowIndex         INT,
	nomor            INT,
	nourut           VARCHAR(20),
	QuestionID       VARCHAR(20),
	QuestionText     VARCHAR(MAX),
	SRAnswerType     VARCHAR(20),
)
  --temp table harus diatas karena cte tidak mengizinkan temp table dibawahnya
;
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
         WHERE  qf.QuestionFormID = 'KMOS'
     )
  
  

  
INSERT INTO ##bagsatu
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
            FROM   ##bagsatu AS b
        )     
       
DECLARE @teks0     NVARCHAR(MAX) = (
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

DECLARE @teks1     VARCHAR(MAX) = (
            SELECT STRING_AGG(
                       CASE 
                            WHEN b.SRAnswerType != 'CTX' THEN CHAR(13) + CHAR(10) + b.nourut + '.QuestionAnswerText' +
                                 ' AS ' + '''' +
                                 b.QuestionText +
                                 
                                 CASE 
                                      WHEN @tot = b.nomor THEN ''''
                                      ELSE ''','
                                 END
                            WHEN b.SRAnswerType = 'CTX' THEN ' SUBSTRING(' + b.nourut + '.QuestionAnswerText, 1, 1)' +
                                 ' AS ' + '''' + b.QuestionText + CASE 
                                                                       WHEN @tot = b.nomor THEN ''''
                                                                       ELSE ''','
                                                                  END + CHAR(13) + CHAR(10) 
                                 
                                 
                                 
                                 
                                 
                                 --CASE
                                 --     WHEN SUBSTRING(phrl4.QuestionAnswerText, 1, 2) = '1|' THEN LTRIM(REPLACE(phrl4.QuestionAnswerText, '1|', ''))
                                 --     WHEN SUBSTRING(phrl4.QuestionAnswerText, 1, 2) = '0|' THEN LTRIM(REPLACE(phrl4.QuestionAnswerText, '0|', ''))
                                 --END                         AS 'ans_AIRWAY_Obstruksi Total / Parsial',
                       END,
                       CHAR(13) + CHAR(10)
                   )          AS teks
            FROM   ##bagsatu  AS b
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
                   )          AS teks
            FROM   ##bagsatu  AS b
        )


DECLARE @where VARCHAR(MAX) = (
            'WHERE  phr.TransactionNo = @p_TransactionNo' + CHAR(13) + CHAR(10) +
            'AND phr.QuestionFormID = @p_QuestionFormID' + CHAR(13) + CHAR(10) +
            'AND phr.RegistrationNo = @p_RegistrationNo'
        )
        
 
        
   

SELECT TRIM(@teks0) + TRIM(@teks1) + TRIM(@teks2) + CHAR(13) + CHAR(10) + TRIM(@teks3) + CHAR(13) + CHAR(10) + TRIM(@where)
            
            
            
            
            
DROP TABLE ##bagsatu
     
       
     
       

	