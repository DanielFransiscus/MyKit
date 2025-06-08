/************************************************************
 * Code formatted by SoftTree SQL Assistant © v11.3.277
 * Time: 08/06/2025 21.03.29
 ************************************************************/

DECLARE @p_TransactionNo      VARCHAR(25) = 'PHR/20240418-0480',
        @p_RegistrationNo     VARCHAR(25) = 'REG/OP/240102-0221',
        @p_QuestionFormID     VARCHAR(25) = 'KMOS',
        @nama_sp              VARCHAR(30) = 'spxml_KartuMonitoringSedasiTest',
        @p_FromDate           VARCHAR(25) = '',
        @p_ToDate             VARCHAR(25) = '',
        @NewLineChar          AS CHAR(2) = CHAR(13) + CHAR(10),
        @menu                 CHAR(1) = 1,
        --1 generate sp tanpa tabel
        --2 generate PIVOT col 
        
        @alias                VARCHAR(5) = 'q8',
        @total_cell           INT = 924;
	

SET NOCOUNT ON;

DECLARE @phr TABLE
        (
            RowIndex INT,
            nomor INT,
            nourut VARCHAR(15),
            QuestionID VARCHAR(10),
            QuestionText VARCHAR(MAX),
            SRAnswerType VARCHAR(15)
        );

WITH cte AS (
         SELECT DISTINCT
                qig.RowIndex,
                q.QuestionAnswerSelectionID,
                q.SRAnswerType,
                q.QuestionID,
                q.QuestionText
         FROM   QuestionForm              AS qf WITH (NOLOCK)
                JOIN QuestionGroupInForm  AS qgif WITH (NOLOCK)
                     ON  qf.QuestionFormID = qgif.QuestionFormID
                JOIN QuestionGroup        AS qg WITH (NOLOCK)
                     ON  qg.QuestionGroupID = qgif.QuestionGroupID
                JOIN QuestionInGroup      AS qig WITH (NOLOCK)
                     ON  qig.QuestionGroupID = qgif.QuestionGroupID
                JOIN Question             AS q WITH (NOLOCK)
                     ON  q.QuestionID = qig.QuestionID
         WHERE  qf.QuestionFormID = @p_QuestionFormID
                AND q.SRAnswerType NOT IN ('LBL', 'TBL')
     )

  
INSERT INTO @phr
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
       trim(c.QuestionText),
       c.SRAnswerType
FROM   cte AS c
ORDER BY
       c.RowIndex;
DECLARE @tot VARCHAR(10) = (
            SELECT COUNT(*)
            FROM   @phr AS b
        );
        
DECLARE @create_sp AS VARCHAR(MAX) = 'CREATE PROCEDURE [dbo].' + @nama_sp +
        '

(
    @p_TransactionNo      VARCHAR(25),
    @p_RegistrationNo     VARCHAR(25),
    @p_QuestionFormID     VARCHAR(25)
)
AS
'        
              
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
                                     LEFT(REPLACE(b.QuestionText, ',', ''), 45) + '_' + b.QuestionID +
                                     
                                     CASE 
                                          WHEN @tot = b.nomor THEN ''''
                                          ELSE ''','
                                     END
                                WHEN b.SRAnswerType IN ('CTX', 'CTM') THEN ' SUBSTRING(' + b.nourut +
                                     '.QuestionAnswerText, 1, 1)' +
                                     ' AS ' + '''' + LEFT(REPLACE(b.QuestionText, ',', ''), 45) + '_' + b.QuestionID + CASE 
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
                                     'AS ''' + 'keterangan_' + LEFT(REPLACE(b.QuestionText, ',', ''), 45) + '_' +
                                     b.QuestionID +
                                     + CASE 
                                            WHEN @tot 
                                                 =
                                                 b.nomor THEN ''''
                                            ELSE ''','
                                       END 
                                     + @NewLineChar
                                ELSE @NewLineChar + b.nourut + '.QuestionAnswerText' +
                                     ' AS ' + '''' +
                                     LEFT(REPLACE(b.QuestionText, ',', ''), 45) + '_' + b.QuestionID +
                                     
                                     CASE 
                                          WHEN @tot = b.nomor THEN ''''
                                          ELSE ''','
                                     END
                           END,
                           @NewLineChar
                       )     AS teks
                FROM   @phr  AS b
            )
        );
                      
DECLARE @bagian3     VARCHAR(MAX) = TRIM(
            @NewLineChar + 'FROM   PatientHealthRecord         AS phr with (NOLOCK) ' +
            @NewLineChar + 'JOIN ServiceUnit       AS s WITH (NOLOCK)' +
            @NewLineChar + '	ON  phr.ServiceUnitID = s.ServiceUnitID ' +
            @NewLineChar + 'JOIN QuestionForm      AS qf WITH (NOLOCK)' +
            @NewLineChar + '	ON  phr.QuestionFormID = qf.QuestionFormID' +
            @NewLineChar + 'JOIN Registration      AS r WITH(NOLOCK)' +
            @NewLineChar + '	ON  phr.RegistrationNo = r.RegistrationNo  ' +
            @NewLineChar + 'JOIN Patient           AS p WITH(NOLOCK)' +
            @NewLineChar + '	ON  p.PatientID =r.PatientID '
        )
        

DECLARE @bagian4     VARCHAR(MAX) = TRIM(
            (
                SELECT STRING_AGG(
                           CAST(
                               'LEFT JOIN PatientHealthRecordLine AS ' + b.nourut + ' WITH (NOLOCK)' +
                               @NewLineChar 
                               +
                               '	ON ' + 'phr.TransactionNo = ' +
                               
                               + b.nourut + '.TransactionNo' + @NewLineChar + '	' + 'AND ' +
                               b.nourut + '.QuestionID = ' + '''' + b.QuestionID + ''''
                               
                               AS VARCHAR(MAX)
                           ),
                           @NewLineChar
                       )     AS teks
                FROM   @phr  AS b
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
        
IF @menu = 1
BEGIN
    IF @p_TransactionNo != ''
       AND @p_RegistrationNo != ''
       AND @p_QuestionFormID != ''
       AND @p_FromDate = ''
       AND @p_ToDate = ''
    BEGIN
        SELECT @create_sp + @bagian1 + @bagian2 + @bagian3 + @NewLineChar + @bagian4 + @NewLineChar +
               @where1 AS result
    END
    
    IF @p_TransactionNo = ''
       AND @p_RegistrationNo = ''
       AND @p_QuestionFormID != ''
       AND @p_FromDate != ''
       AND @p_ToDate != ''
    BEGIN
        SELECT @create_sp + @bagian1_1 + @bagian2 + @bagian3 + @NewLineChar + @bagian4 + @NewLineChar 
               + @where2 AS result
    END
END

IF @menu = 2
BEGIN
    DECLARE @counter INT = 1;
    DECLARE @hasil INT = 0;
    
    DECLARE @tabel TABLE (col VARCHAR(MAX));
    
    WHILE @counter <= @total_cell
    BEGIN
        INSERT INTO @tabel
          (
            col
          )
        VALUES
          (
            CONCAT('[', 'ttv', @counter, ']')
          );
        
        SET @counter = @counter + 1;
    END;
    --CONCAT(@alias ,'.', 'ttv', @counter,' AS ' , CONCAT( @counter,'_', 'ttv',@alias))
    
    --atas
    SELECT STRING_AGG(CONCAT(@alias, '.', col), ',')
    FROM   @tabel
    
    --bawah
    SELECT STRING_AGG(col, ',')
    FROM   @tabel
END--template pivot
   
   --LEFT JOIN (
   --        SELECT 'TTV' + CAST(
   --                   ROW_NUMBER() OVER(PARTITION BY a.TransactionNo ORDER BY a.TransactionNo) AS VARCHAR(200)
   --               ) AS col,
   --               sp.splitdata,
   --               a.QuestionAnswerText,
   --               a.QuestionAnswerNum,
   --               a.TransactionNo
   --        FROM   PatientHealthRecordLine AS a
   --               CROSS APPLY dbo.fnSplitString(a.QuestionAnswerText, '|') AS sp
   --        WHERE  a.QuestionID = 'KMOS15'
   --               AND a.QuestionFormID = @p_QuestionFormID
   --               AND a.TransactionNo = @p_TransactionNo
   --               AND a.RegistrationNo = @p_RegistrationNo
   --    )                             AS tbl
   --    PIVOT(
   --        MAX(splitdata) FOR col IN ([ttv1], [ttv2], [ttv3], [ttv4], [ttv5], [ttv6], [ttv7], [ttv8], [ttv9],
   --                                  [ttv10], [ttv11], [ttv12], [ttv13], [ttv14], [ttv15], [ttv16], [ttv17],
   --                                  [ttv18], [ttv19], [ttv20], [ttv21], [ttv22], [ttv23], [ttv24])
   --    ) AS q8
   --    ON  q8.TransactionNo = phr.TransactionNo