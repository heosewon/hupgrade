USE [IFC_SPC]
GO
/****** Object:  StoredProcedure [dbo].[JOB_SCHEDULE_DAILY_REPORT]    Script Date: 2021-09-08 오전 8:56:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- EXEC [JOB_SCHEDULE_DAILY_REPORT]
ALTER PROCEDURE	[dbo].[JOB_SCHEDULE_DAILY_REPORT]
AS

-- EXEC [DBO].[JOB_SCHEDULE_DAILY_REPORT]
/***** 일일 실적 보고를 메일로 전송하기 위한 SP *****/
BEGIN

	SET NOCOUNT ON
	
	-- 날짜체크;
	DECLARE @DAY_CHECK	INT = -1;
	-- 요일 체크(일요일이면 1)
	DECLARE @DAY_DATE	INT = -1;
	
	
	-- 메일내용;
	DECLARE @MAIL_BODY NVARCHAR(MAX) = ''
	DECLARE @MAIL_SUBJECT NVARCHAR(MAX) = ''
	DECLARE @PROFILE_NAME VARCHAR(20) = 'DAILY_REPORT'
	
	-- 메일수신자 리스트
	DECLARE @RECIPIENTS_LIST				NVARCHAR(MAX)	=	''
	DECLARE @COPY_RECIPIENTS_LIST			NVARCHAR(MAX)	=	''
	DECLARE @BLIND_COPY_RECIPIENTS_LIST		NVARCHAR(MAX)	=	''
	
	DECLARE @STARTINDEX INT	=	1
	DECLARE @ENDINDEX INT	=	1
	DECLARE @CNTINDEX INT	=	1
	
	
	-- 메일 발송 내용
	SELECT	@MAIL_BODY= MESSAGE, 
			@MAIL_SUBJECT = SUBJECT
	FROM	OPENQUERY(IFC, 'SELECT	T.MESSAGE AS MESSAGE, 
									T.SUBJECT AS SUBJECT 
							FROM	IFC_WEB_MAIL_TEMP T')	
	
	-- MAIL 보낼 대상 편집
	DECLARE @TEMP_TABLE TABLE(
			TID					INT IDENTITY(1,1) NOT NULL,
			TEMP_CODE			NVARCHAR(30),
			TEMP_NAME			NVARCHAR(200),
			TEMAIL				NVARCHAR(50))
				
	DECLARE @TEMAIL		NVARCHAR(100)	=	''
	DECLARE @TEMP_CODE	NVARCHAR(100)	=	''
	
	----------------------------------------------------------------------------------------------------------------------
	-- 수신자 명단
	
	DELETE FROM @TEMP_TABLE
	SET @STARTINDEX = 1
	SET @ENDINDEX = 1
	SET	@CNTINDEX = 1
	
	/*INSERT INTO @TEMP_TABLE
	SELECT	EMP_CODE 
	,		EMP_NAME
	,		EMAIL
	FROM	OPENQUERY(IFC, 'SELECT NULL			AS EMP_CODE
							,      T.USER_NAME  AS EMP_NAME
							,      T.MAIL_ADDR  AS EMAIL
							FROM   IFC_WEB_ERP_MAIL_LIST T
							WHERE  T.MAIL_TYPE = ''A''
							ORDER BY T.USER_NAME')	*/
						
	INSERT INTO @TEMP_TABLE
	--VALUES ('','일일실적보고 수신자','changgyun.yoo@interflex.co.kr')
    --VALUES ('','일일실적보고 수신자','jungwook.kim@interflex.co.kr')
	--VALUES ('','일일실적보고 수신자','sewon.heo@interflex.co.kr')
	VALUES ('','일일실적보고 수신자','ifc_daily_address@interflex.co.kr')

	
	/*최대값 받아오기*/
	SELECT	@ENDINDEX = ISNULL(MAX(TID), 0) FROM @TEMP_TABLE
	
	/*MAIL 주소 하나로 MERGE*/
	WHILE @CNTINDEX <= @ENDINDEX
		BEGIN			
				
			SET @TEMAIL	= ''
			SET @TEMP_CODE	= ''
	
			SELECT	@RECIPIENTS_LIST	= @RECIPIENTS_LIST + TEMP_NAME + '<' + LOWER(TEMAIL) + '>' + ';',
					@TEMAIL = LOWER(TEMAIL),
					@TEMP_CODE	= TEMP_CODE
			FROM	@TEMP_TABLE
			WHERE	TID	=	@CNTINDEX			
			
			INSERT INTO ALARM_HISTORY(ALARM_ID,EMP_CODE,ALARM_TYPE,ALARM_DAY,ALARM_DATE,ALARM_CONTENTS,INS_DATE,INS_EMP)
			VALUES('51','A','EMAIL',GETDATE(),GETDATE(),'TITLE : ' + @MAIL_SUBJECT + ' BODY : ' + @MAIL_BODY,GETDATE(),'ADMIN')
				
			SET @CNTINDEX = @CNTINDEX +1
		END
		
	
	------------------------------------------------------------------------------------------------------------------------
	
	------------------------------------------------------------------------------------------------------------------------
	-- 참조 수신자 명단
	
	--DELETE FROM @TEMP_TABLE
	--SET @STARTINDEX = 1
	--SET @ENDINDEX = 1
	--SET	@CNTINDEX = 1
	
	--INSERT INTO @TEMP_TABLE
	--SELECT	EMP_CODE 
	--,		EMP_NAME
	--,		EMAIL
	--FROM	OPENQUERY(IFC, 'SELECT NULL			AS EMP_CODE
	--						,      T.USER_NAME  AS EMP_NAME
	--						,      T.MAIL_ADDR  AS EMAIL
	--						FROM   IFC_WEB_ERP_MAIL_LIST T
	--						WHERE  T.MAIL_TYPE = ''B''
	--						ORDER BY T.USER_NAME')	
	
	--/*최대값 받아오기*/
	--SELECT	@ENDINDEX = ISNULL(MAX(TID), 0) FROM @TEMP_TABLE
	
	--/*MAIL 주소 하나로 MERGE*/
	--WHILE @CNTINDEX <= @ENDINDEX
	--	BEGIN			
				
	--		SET @TEMAIL	= ''
	--		SET @TEMP_CODE	= ''
	
	--		SELECT	@COPY_RECIPIENTS_LIST	= @COPY_RECIPIENTS_LIST + TEMP_NAME + '<' + LOWER(TEMAIL) + '>' + ';',
	--				@TEMAIL = LOWER(TEMAIL),
	--				@TEMP_CODE	= TEMP_CODE
	--		FROM	@TEMP_TABLE
	--		WHERE	TID	=	@CNTINDEX
			
	--		INSERT INTO ALARM_HISTORY(ALARM_ID,EMP_CODE,ALARM_TYPE,ALARM_DAY,ALARM_DATE,ALARM_CONTENTS,INS_DATE,INS_EMP)
	--		VALUES('52','B','EMAIL',GETDATE(),GETDATE(),'TITLE : ' + @MAIL_SUBJECT + ' BODY : ' + @MAIL_BODY,GETDATE(),'ADMIN')
	
	--		SET @CNTINDEX = @CNTINDEX +1
	--	END
	----------------------------------------------------------------------------------------------------------------------
	
	------------------------------------------------------------------------------------------------------------------------
	-- 숨은 참조 수신자 명단	
	
	DELETE FROM @TEMP_TABLE
	SET @STARTINDEX = 1
	SET @ENDINDEX = 1
	SET	@CNTINDEX = 1
	
	--INSERT INTO @TEMP_TABLE
	--SELECT	EMP_CODE 
	--,		EMP_NAME
	--,		EMAIL
	--FROM	OPENQUERY(IFC, 'SELECT NULL			AS EMP_CODE
	--						,      T.USER_NAME  AS EMP_NAME
	--						,      T.MAIL_ADDR  AS EMAIL
	--						FROM   IFC_WEB_ERP_MAIL_LIST T
	--						WHERE  T.MAIL_TYPE = ''C''
	--						ORDER BY T.USER_NAME')	
	
	
	--INSERT INTO @TEMP_TABLE
	--VALUES ('','일일실적보고 수신자(송신확인용)','changgyun.yoo@interflex.co.kr')
	--VALUES ('','일일실적보고 수신자(송신확인용)','ifc_daily_address_hidden@interflex.co.kr')
    --VALUES ('','일일실적보고 수신자','jungwook.kim@interflex.co.kr')
	--VALUES ('','일일실적보고 수신자','sewon.heo@interflex.co.kr')
	
	
	
	/*최대값 받아오기*/
	SELECT	@ENDINDEX = ISNULL(MAX(TID), 0) FROM @TEMP_TABLE
	
	/*MAIL 주소 하나로 MERGE*/
	WHILE @CNTINDEX <= @ENDINDEX
		BEGIN			
				
			SET @TEMAIL	= ''
			SET @TEMP_CODE	= ''
	
			SELECT	@BLIND_COPY_RECIPIENTS_LIST	= @BLIND_COPY_RECIPIENTS_LIST + TEMP_NAME + '<' + LOWER(TEMAIL) + '>' + ';',
					@TEMAIL = LOWER(TEMAIL),
					@TEMP_CODE	= TEMP_CODE
			FROM	@TEMP_TABLE
			WHERE	TID	=	@CNTINDEX
						
			INSERT INTO ALARM_HISTORY(ALARM_ID,EMP_CODE,ALARM_TYPE,ALARM_DAY,ALARM_DATE,ALARM_CONTENTS,INS_DATE,INS_EMP)
			VALUES('53','C','EMAIL',GETDATE(),GETDATE(),'TITLE : ' + @MAIL_SUBJECT + ' BODY : ' + @MAIL_BODY,GETDATE(),'ADMIN')
	
			SET @CNTINDEX = @CNTINDEX +1
		END
	----------------------------------------------------------------------------------------------------------------------
	
	SELECT		@DAY_CHECK	=	DAY(GETDATE())         --현재 29일
	SELECT		@DAY_DATE   =   DATEPART(DW,GETDATE()) --현재 금요일
	

	-- 08시 45분에 발송되는 메일은 
	-- SELECT	DATEPART(HH,GETDATE()-0.3)
	 IF			DATEPART(HH,GETDATE())	<>	9
		BEGIN
			SET	@RECIPIENTS_LIST	=	''
			SET	@COPY_RECIPIENTS_LIST	=	''
		END
    
	
	--IF @DAY_CHECK	<>	1 OR ( (@DAY_CHECK = 1) and (@DAY_DATE = 1) ) -- 1일 제외 전송(예외:당월 1일이 일요일 시 메일 전송)
	BEGIN	
		---- 메일 발송
		--SELECT @PROFILE_NAME 
		--,			@RECIPIENTS_LIST
		--,			@COPY_RECIPIENTS_LIST
		--,			@BLIND_COPY_RECIPIENTS_LIST
		--,			@MAIL_SUBJECT
		--,			@MAIL_BODY
		----,			@BODY_FORMAT
		
		--SELECT @PROFILE_NAME, @RECIPIENTS_LIST, @COPY_RECIPIENTS_LIST, @BLIND_COPY_RECIPIENTS_LIST
		
		EXEC MSDB.DBO.SP_SEND_DBMAIL
			@PROFILE_NAME     = @PROFILE_NAME,					
			@RECIPIENTS       = @RECIPIENTS_LIST,			         --수신인
			@COPY_RECIPIENTS  = @COPY_RECIPIENTS_LIST,               --참조인
			@BLIND_COPY_RECIPIENTS = @BLIND_COPY_RECIPIENTS_LIST,    --숨은참조
			@SUBJECT = @MAIL_SUBJECT,
			@BODY	= @MAIL_BODY,			
			@BODY_FORMAT = 'HTML'				
	END
END


