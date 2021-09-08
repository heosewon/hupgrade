CREATE OR REPLACE PACKAGE IFC_SEND_MAIL_PKG IS

  ----------------------- CUSTOMIZABLE SECTION -----------------------

  -- CUSTOMIZE THE SMTP HOST, PORT AND YOUR DOMAIN NAME BELOW.
  --2010.05.04 그룹웨어 OPEN시 변경됨.  SMTP_HOST   VARCHAR2(256) := '191.1.8.48'; --'MAIL.MANDO.COM';
  SMTP_HOST   VARCHAR2(256) := '192.168.5.188';
  SMTP_PORT   PLS_INTEGER := 25;
  SMTP_DOMAIN VARCHAR2(256) := 'MAIL.INTERFLEX.CO.KR';
  --REFERENCE BY FND_CONC REQUEST STATUS CODES

  -- CUSTOMIZE THE SIGNATURE THAT WILL APPEAR IN THE EMAIL'S MIME HEADER.
  -- USEFUL FOR VERSIONING.
  MAILER_ID CONSTANT VARCHAR2(256) := 'INTERFLEX MAIL SYSTEM';

  G_RECIPIENTS VARCHAR2(32767);

  --------------------- END CUSTOMIZABLE SECTION ---------------------

  -- A UNIQUE STRING THAT DEMARCATES BOUNDARIES OF PARTS IN A MULTI-PART EMAIL
  -- THE STRING SHOULD NOT APPEAR INSIDE THE BODY OF ANY PART OF THE EMAIL.
  -- CUSTOMIZE THIS IF NEEDED OR GENERATE THIS RANDOMLY DYNAMICALLY.
  BOUNDARY CONSTANT VARCHAR2(256) := '-----7D81B75CCC90D2974F7A1CBD';

  FIRST_BOUNDARY CONSTANT VARCHAR2(256) := '--' || BOUNDARY || UTL_TCP.CRLF;
  LAST_BOUNDARY  CONSTANT VARCHAR2(256) := '--' || BOUNDARY || '--' ||
                                           UTL_TCP.CRLF;

  -- A MIME TYPE THAT DENOTES MULTI-PART EMAIL (MIME) MESSAGES.
  MULTIPART_MIME_TYPE   CONSTANT VARCHAR2(256) := 'MULTIPART/MIXED; BOUNDARY="' ||
                                                  BOUNDARY || '"';
  MAX_BASE64_LINE_WIDTH CONSTANT PLS_INTEGER := 76 / 4 * 3;

  -- A SIMPLE EMAIL API FOR SENDING EMAIL IN PLAIN TEXT IN A SINGLE CALL.
  -- THE FORMAT OF AN EMAIL ADDRESS IS ONE OF THESE:
  --   SOMEONE@SOME-DOMAIN
  --   "SOMEONE AT SOME DOMAIN" <SOMEONE@SOME-DOMAIN>
  --   SOMEONE AT SOME DOMAIN <SOMEONE@SOME-DOMAIN>
  -- THE RECIPIENTS IS A LIST OF EMAIL ADDRESSES  SEPARATED BY
  -- EITHER A "," OR A ";"
  PROCEDURE MAIL(SENDER     IN VARCHAR2
                ,RECIPIENTS IN VARCHAR2
                ,CC         IN VARCHAR2
                ,SUBJECT    IN VARCHAR2
                ,MESSAGE    IN VARCHAR2);

  -- EXTENDED EMAIL API TO SEND EMAIL IN HTML OR PLAIN TEXT WITH NO SIZE LIMIT.
  -- FIRST, BEGIN THE EMAIL BY BEGIN_MAIL(). THEN, CALL WRITE_TEXT() REPEATEDLY
  -- TO SEND EMAIL IN ASCII PIECE-BY-PIECE. OR, CALL WRITE_MB_TEXT() TO SEND
  -- EMAIL IN NON-ASCII OR MULTI-BYTE CHARACTER SET. END THE EMAIL WITH
  -- END_MAIL().
  FUNCTION BEGIN_MAIL(SENDER     IN VARCHAR2
                     ,RECIPIENTS IN VARCHAR2
                     ,CC         IN VARCHAR2
                     ,SUBJECT    IN VARCHAR2
                     ,MIME_TYPE  IN VARCHAR2 DEFAULT 'TEXT/PLAIN'
                     ,PRIORITY   IN PLS_INTEGER DEFAULT NULL)
    RETURN UTL_SMTP.CONNECTION;
  PROCEDURE WRITE_MIME_HEADER(CONN  IN OUT NOCOPY UTL_SMTP.CONNECTION
                             ,NAME  IN VARCHAR2
                             ,VALUE IN VARCHAR2);
  PROCEDURE ATTACH_BASE64(CONN   IN OUT NOCOPY UTL_SMTP.CONNECTION
                         ,INLINE IN BOOLEAN DEFAULT TRUE
                         ,FILEID IN NUMBER
                         ,LAST   IN BOOLEAN DEFAULT FALSE);
  -- WRITE EMAIL BODY IN ASCII
  PROCEDURE WRITE_TEXT(CONN    IN OUT NOCOPY UTL_SMTP.CONNECTION
                      ,MESSAGE IN VARCHAR2);

  -- WRITE EMAIL BODY IN NON-ASCII (INCLUDING MULTI-BYTE). THE EMAIL BODY
  -- WILL BE SENT IN THE DATABASE CHARACTER SET.
  PROCEDURE WRITE_MB_TEXT(CONN    IN OUT NOCOPY UTL_SMTP.CONNECTION
                         ,MESSAGE IN VARCHAR2);

  -- WRITE EMAIL BODY IN BINARY
  PROCEDURE WRITE_RAW(CONN    IN OUT NOCOPY UTL_SMTP.CONNECTION
                     ,MESSAGE IN RAW);

  -- APIS TO SEND EMAIL WITH ATTACHMENTS. ATTACHMENTS ARE SENT BY SENDING
  -- EMAILS IN "MULTIPART/MIXED" MIME FORMAT. SPECIFY THAT MIME FORMAT WHEN
  -- BEGINNING AN EMAIL WITH BEGIN_MAIL().

  -- SEND A SINGLE TEXT ATTACHMENT.
  PROCEDURE ATTACH_TEXT(CONN      IN OUT NOCOPY UTL_SMTP.CONNECTION
                       ,DATA      IN VARCHAR2
                       ,MIME_TYPE IN VARCHAR2 DEFAULT 'TEXT/PLAIN'
                       ,INLINE    IN BOOLEAN DEFAULT TRUE
                       ,FILENAME  IN VARCHAR2 DEFAULT NULL
                       ,LAST      IN BOOLEAN DEFAULT FALSE);

  -- SEND A BINARY ATTACHMENT. THE ATTACHMENT WILL BE ENCODED IN BASE-64
  -- ENCODING FORMAT.
  PROCEDURE ATTACH_BASE64(CONN      IN OUT NOCOPY UTL_SMTP.CONNECTION
                         ,DATA      IN LONG RAW
                         ,MIME_TYPE IN VARCHAR2 DEFAULT 'APPLICATION/OCTET'
                         ,INLINE    IN BOOLEAN DEFAULT TRUE
                         ,FILENAME  IN VARCHAR2 DEFAULT NULL
                         ,LAST      IN BOOLEAN DEFAULT FALSE);

  -- SEND AN ATTACHMENT WITH NO SIZE LIMIT. FIRST, BEGIN THE ATTACHMENT
  -- WITH BEGIN_ATTACHMENT(). THEN, CALL WRITE_TEXT REPEATEDLY TO SEND
  -- THE ATTACHMENT PIECE-BY-PIECE. IF THE ATTACHMENT IS TEXT-BASED BUT
  -- IN NON-ASCII OR MULTI-BYTE CHARACTER SET, USE WRITE_MB_TEXT() INSTEAD.
  -- TO SEND BINARY ATTACHMENT, THE BINARY CONTENT SHOULD FIRST BE
  -- ENCODED IN BASE-64 ENCODING FORMAT USING THE DEMO PACKAGE FOR 8I,
  -- OR THE NATIVE ONE IN 9I. END THE ATTACHMENT WITH END_ATTACHMENT.
  PROCEDURE BEGIN_ATTACHMENT(CONN         IN OUT NOCOPY UTL_SMTP.CONNECTION
                            ,MIME_TYPE    IN VARCHAR2 DEFAULT 'TEXT/PLAIN'
                            ,INLINE       IN BOOLEAN DEFAULT TRUE
                            ,FILENAME     IN VARCHAR2 DEFAULT NULL
                            ,TRANSFER_ENC IN VARCHAR2 DEFAULT NULL);

  -- END THE ATTACHMENT.
  PROCEDURE END_ATTACHMENT(CONN IN OUT NOCOPY UTL_SMTP.CONNECTION
                          ,LAST IN BOOLEAN DEFAULT FALSE);

  -- END THE EMAIL.
  PROCEDURE END_MAIL(CONN IN OUT NOCOPY UTL_SMTP.CONNECTION);

  -- EXTENDED EMAIL API TO SEND MULTIPLE EMAILS IN A SESSION FOR BETTER
  -- PERFORMANCE. FIRST, BEGIN AN EMAIL SESSION WITH BEGIN_SESSION.
  -- THEN, BEGIN EACH EMAIL WITH A SESSION BY CALLING BEGIN_MAIL_IN_SESSION
  -- INSTEAD OF BEGIN_MAIL. END THE EMAIL WITH END_MAIL_IN_SESSION INSTEAD
  -- OF END_MAIL. END THE EMAIL SESSION BY END_SESSION.
  FUNCTION BEGIN_SESSION RETURN UTL_SMTP.CONNECTION;

  -- BEGIN AN EMAIL IN A SESSION.
  PROCEDURE BEGIN_MAIL_IN_SESSION(CONN       IN OUT NOCOPY UTL_SMTP.CONNECTION
                                 ,SENDER     IN VARCHAR2
                                 ,RECIPIENTS IN VARCHAR2
                                 ,CC         IN VARCHAR2
                                 ,SUBJECT    IN VARCHAR2
                                 ,MIME_TYPE  IN VARCHAR2 DEFAULT 'TEXT/PLAIN'
                                 ,PRIORITY   IN PLS_INTEGER DEFAULT NULL);

  -- END AN EMAIL IN A SESSION.
  PROCEDURE END_MAIL_IN_SESSION(CONN IN OUT NOCOPY UTL_SMTP.CONNECTION);

  -- END AN EMAIL SESSION.
  PROCEDURE END_SESSION(CONN IN OUT NOCOPY UTL_SMTP.CONNECTION);

  -- SEND EMAIL ATTACHMENT FILE.
  -- SEND EMAIL ATTACHMENT FILE OVER 32K ON TABLE
  PROCEDURE MAIL_ATTACHMENT(P_SENDER       IN VARCHAR2
                           ,P_RECIPIENTS   IN VARCHAR2
                           ,P_CC           IN VARCHAR2 DEFAULT NULL
                           ,P_SUBJECT      IN VARCHAR2
                           ,P_MESSAGE      IN CLOB --VARCHAR2
                           ,P_FILE_ID      IN VARCHAR2 DEFAULT NULL
                           ,P_CONTENT_TYPE IN VARCHAR2 DEFAULT NULL);

  -- SEND EMAIL ATTACHMENT FILE.
  -- SEND EMAIL ATTACHMENT FILE OVER 32K ON FILE SYSTEM.
  PROCEDURE MAIL_ATTACHMENT(P_SENDER       IN VARCHAR2
                           ,P_RECIPIENTS   IN VARCHAR2
                           ,P_CC           IN VARCHAR2 DEFAULT NULL
                           ,P_SUBJECT      IN VARCHAR2
                           ,P_MESSAGE      IN CLOB
                           ,P_MIME_TYPE    IN VARCHAR2
                           ,P_DIR          IN VARCHAR2
                           ,P_FILE_NAME    IN VARCHAR2
                           ,P_CONTENT_TYPE IN VARCHAR2);

  -- SEND EMAIL ATTACHMENT FILE.
  -- SEND EMAIL ATTACHMENT FILE OVER 32K ON TABLE
  PROCEDURE SEND_MAIL(P_SENDER        IN VARCHAR2
                     ,P_RECIPIENTS    IN VARCHAR2
                     ,P_CC            IN VARCHAR2 DEFAULT NULL
                     ,P_SUBJECT       IN VARCHAR2
                     ,P_MESSAGE       IN CLOB DEFAULT NULL
                     ,P_FILE_ID       IN VARCHAR2 DEFAULT NULL
                     ,P_MIME_TYPE     IN VARCHAR2 DEFAULT NULL
                     ,P_DIR           IN VARCHAR2 DEFAULT NULL
                     ,P_FILE_NAME     IN VARCHAR2 DEFAULT NULL
                     ,P_CONTENT_TYPE  IN VARCHAR2 DEFAULT 'TEXT/PLAIN'
                     ,O_STATUS_CODE   OUT VARCHAR2
                     ,O_ERROR_MESSAGE OUT VARCHAR2);
END;
/
CREATE OR REPLACE PACKAGE BODY IFC_SEND_MAIL_PKG
/**********************************************************************************/
/*                                                                                */
/* PROJECT       : MANDO G-ERP PROJECT                                            */
/* MODULE        : XXEGO                                                          */
/* PROGRAM NAME  : XXENG_EPI_MAILING_PKG                                          */
/* DESCRIPTION   : EPI INFO MAILING PACKAGE                                       */
/* REFERENCED BY :                                                                */
/* PROGRAM HISTORY                                                                */
/**********************************************************************************/
/* DATE        IN CHARGE         DESCRIPTION                                      */
/**********************************************************************************/
/* 2009-09-01  OH DOO SUNG       INITIAL RELEASE                                  */
/* 2009-10-14  OH DOO SUNG       ADD MULTI-FILE ATTACH LOGIC                      */
/* 2009-10-29  OH DOO SUNG       EXPANSION MESSAGE SIZE FROM LONG TO CLOB         */
/* 2011-01-19  GSIPJT            CONVERT UTF8                                     */
/*                                                                                */
/**********************************************************************************/
 IS

  -- RETURN THE NEXT EMAIL ADDRESS IN THE LIST OF EMAIL ADDRESSES, SEPARATED
  -- BY EITHER A "," OR A ";".  THE FORMAT OF MAILBOX MAY BE IN ONE OF THESE:
  --   SOMEONE@SOME-DOMAIN
  --   "SOMEONE AT SOME DOMAIN" <SOMEONE@SOME-DOMAIN>
  --   SOMEONE AT SOME DOMAIN <SOMEONE@SOME-DOMAIN>
  FUNCTION GET_ADDRESS(ADDR_LIST IN OUT VARCHAR2) RETURN VARCHAR2 IS
  
    ADDR VARCHAR2(256);
    I    PLS_INTEGER;
  
    FUNCTION LOOKUP_UNQUOTED_CHAR(STR  IN VARCHAR2
                                 ,CHRS IN VARCHAR2) RETURN PLS_INTEGER AS
      C            VARCHAR2(5);
      I            PLS_INTEGER;
      LEN          PLS_INTEGER;
      INSIDE_QUOTE BOOLEAN;
    BEGIN
      INSIDE_QUOTE := FALSE;
      I            := 1;
      LEN          := LENGTH(STR);
      WHILE (I <= LEN)
      LOOP
      
        C := SUBSTR(STR, I, 1);
      
        IF (INSIDE_QUOTE) THEN
          IF (C = '"') THEN
            INSIDE_QUOTE := FALSE;
          ELSIF (C = '\') THEN
            I := I + 1; -- SKIP THE QUOTE CHARACTER
          END IF;
          GOTO NEXT_CHAR;
        END IF;
      
        IF (C = '"') THEN
          INSIDE_QUOTE := TRUE;
          GOTO NEXT_CHAR;
        END IF;
      
        IF (INSTR(CHRS, C) >= 1) THEN
          RETURN I;
        END IF;
      
        <<NEXT_CHAR>>
        I := I + 1;
      
      END LOOP;
    
      RETURN 0;
    
    END;
  
  BEGIN
  
    ADDR_LIST := LTRIM(ADDR_LIST);
    I         := LOOKUP_UNQUOTED_CHAR(ADDR_LIST, ',;');
    IF (I >= 1) THEN
      ADDR      := SUBSTR(ADDR_LIST, 1, I - 1);
      ADDR_LIST := SUBSTR(ADDR_LIST, I + 1);
    ELSE
      ADDR      := ADDR_LIST;
      ADDR_LIST := '';
    END IF;
  
    I := LOOKUP_UNQUOTED_CHAR(ADDR, '<');
    IF (I >= 1) THEN
      ADDR := SUBSTR(ADDR, I + 1);
      I    := INSTR(ADDR, '>');
      IF (I >= 1) THEN
        ADDR := SUBSTR(ADDR, 1, I - 1);
      END IF;
    END IF;
  
    RETURN ADDR;
  END;

  -- WRITE A MIME HEADER
  PROCEDURE WRITE_MIME_HEADER(CONN  IN OUT NOCOPY UTL_SMTP.CONNECTION
                             ,NAME  IN VARCHAR2
                             ,VALUE IN VARCHAR2) IS
  BEGIN
    UTL_SMTP.WRITE_DATA(CONN, NAME || ': ' || VALUE || UTL_TCP.CRLF);
  END;

  -- MARK A MESSAGE-PART BOUNDARY.  SET <LAST> TO TRUE FOR THE LAST BOUNDARY.
  PROCEDURE WRITE_BOUNDARY(CONN IN OUT NOCOPY UTL_SMTP.CONNECTION
                          ,LAST IN BOOLEAN DEFAULT FALSE) AS
  BEGIN
    IF (LAST) THEN
      UTL_SMTP.WRITE_DATA(CONN, LAST_BOUNDARY);
    ELSE
      UTL_SMTP.WRITE_DATA(CONN, FIRST_BOUNDARY);
    END IF;
  END;

  ------------------------------------------------------------------------
  PROCEDURE MAIL(SENDER     IN VARCHAR2
                ,RECIPIENTS IN VARCHAR2
                ,CC         IN VARCHAR2
                ,SUBJECT    IN VARCHAR2
                ,MESSAGE    IN VARCHAR2) IS
    CONN UTL_SMTP.CONNECTION;
  BEGIN
    CONN := BEGIN_MAIL(SENDER, RECIPIENTS, CC, SUBJECT);
    WRITE_TEXT(CONN, MESSAGE);
    --WRITE_TEXT(CONN, UTL_RAW.CAST_TO_RAW(CONVERT(MESSAGE, 'KO16MSWIN949')));
    END_MAIL(CONN);
  END;

  ------------------------------------------------------------------------
  FUNCTION BEGIN_MAIL(SENDER     IN VARCHAR2
                     ,RECIPIENTS IN VARCHAR2
                     ,CC         IN VARCHAR2
                     ,SUBJECT    IN VARCHAR2
                     ,MIME_TYPE  IN VARCHAR2 DEFAULT 'TEXT/PLAIN'
                     ,PRIORITY   IN PLS_INTEGER DEFAULT NULL)
    RETURN UTL_SMTP.CONNECTION IS
    CONN UTL_SMTP.CONNECTION;
  BEGIN
    CONN := BEGIN_SESSION;
    BEGIN_MAIL_IN_SESSION(CONN,
                          SENDER,
                          RECIPIENTS,
                          CC,
                          SUBJECT,
                          MIME_TYPE,
                          PRIORITY);
    RETURN CONN;
  END;

  ------------------------------------------------------------------------
  PROCEDURE WRITE_TEXT(CONN    IN OUT NOCOPY UTL_SMTP.CONNECTION
                      ,MESSAGE IN VARCHAR2) IS
  BEGIN
    UTL_SMTP.WRITE_DATA(CONN, MESSAGE);
  END;

  ------------------------------------------------------------------------
  PROCEDURE WRITE_MB_TEXT(CONN    IN OUT NOCOPY UTL_SMTP.CONNECTION
                         ,MESSAGE IN VARCHAR2) IS
  BEGIN
    UTL_SMTP.WRITE_RAW_DATA(CONN, UTL_RAW.CAST_TO_RAW(MESSAGE));
  END;

  ------------------------------------------------------------------------
  PROCEDURE WRITE_RAW(CONN    IN OUT NOCOPY UTL_SMTP.CONNECTION
                     ,MESSAGE IN RAW) IS
  BEGIN
    UTL_SMTP.WRITE_RAW_DATA(CONN, MESSAGE);
  END;

  ------------------------------------------------------------------------
  PROCEDURE ATTACH_TEXT(CONN      IN OUT NOCOPY UTL_SMTP.CONNECTION
                       ,DATA      IN VARCHAR2
                       ,MIME_TYPE IN VARCHAR2 DEFAULT 'TEXT/PLAIN'
                       ,INLINE    IN BOOLEAN DEFAULT TRUE
                       ,FILENAME  IN VARCHAR2 DEFAULT NULL
                       ,LAST      IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    BEGIN_ATTACHMENT(CONN, MIME_TYPE, INLINE, FILENAME);
    WRITE_TEXT(CONN, DATA);
    END_ATTACHMENT(CONN, LAST);
  END;

  ------------------------------------------------------------------------
  -- 32K가 넘지 않는 파일 첨부 가능하도록..(거의 사용될 일이 없는 경우).
  PROCEDURE ATTACH_BASE64(CONN      IN OUT NOCOPY UTL_SMTP.CONNECTION
                         ,DATA      IN LONG RAW
                         ,MIME_TYPE IN VARCHAR2 DEFAULT 'APPLICATION/OCTET'
                         ,INLINE    IN BOOLEAN DEFAULT TRUE
                         ,FILENAME  IN VARCHAR2 DEFAULT NULL
                         ,LAST      IN BOOLEAN DEFAULT FALSE) IS
    I   PLS_INTEGER;
    LEN PLS_INTEGER;
  BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG, '-----------1');
    BEGIN_ATTACHMENT(CONN, MIME_TYPE, INLINE, FILENAME, 'BASE64');
  
    -- SPLIT THE BASE64-ENCODED ATTACHMENT INTO MULTIPLE LINES
    I   := 1;
    LEN := UTL_RAW.LENGTH(DATA);
    WHILE (I < LEN)
    LOOP
      IF (I + MAX_BASE64_LINE_WIDTH < LEN) THEN
        UTL_SMTP.WRITE_RAW_DATA(CONN,
                                UTL_ENCODE.BASE64_ENCODE(UTL_RAW.SUBSTR(DATA,
                                                                        I,
                                                                        MAX_BASE64_LINE_WIDTH)));
      ELSE
        UTL_SMTP.WRITE_RAW_DATA(CONN,
                                UTL_ENCODE.BASE64_ENCODE(UTL_RAW.SUBSTR(DATA,
                                                                        I)));
      END IF;
      UTL_SMTP.WRITE_DATA(CONN, UTL_TCP.CRLF);
      I := I + MAX_BASE64_LINE_WIDTH;
    END LOOP;
    END_ATTACHMENT(CONN, LAST);
  
  END;

  -- 32K가 넘는 파일 첨부 가능하도록..
  -- FILE SYSTEM에 저장되어있는 파일..
  -- DIRECTORY OBJECT가 생성되어있어야 함..
  PROCEDURE ATTACH_BASE64(CONN      IN OUT NOCOPY UTL_SMTP.CONNECTION
                         ,MIME_TYPE IN VARCHAR2 DEFAULT 'APPLICATION/OCTET'
                         ,INLINE    IN BOOLEAN DEFAULT TRUE
                         ,DIR       IN VARCHAR2
                         ,FILENAME  IN VARCHAR2 DEFAULT NULL
                         ,LAST      IN BOOLEAN DEFAULT FALSE) IS
    I PLS_INTEGER;
    --LEN              PLS_INTEGER;
    FIL      BFILE;
    FILE_LEN PLS_INTEGER;
    AMT      BINARY_INTEGER := 672 * 3; /* ENSURES PROPER FORMAT;  2016 */
    --POS              PLS_INTEGER := 1; /* POINTER FOR EACH PIECE */
    FILEPOS PLS_INTEGER := 1; /* POINTER FOR THE FILE */
    MODULO  PLS_INTEGER;
    PIECES  PLS_INTEGER;
    CHUNKS  PLS_INTEGER;
    BUF     RAW(32000);
    DATA    RAW(32000);
  
  BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG, '-----------2');
    BEGIN_ATTACHMENT(CONN, MIME_TYPE, INLINE, FILENAME, 'BASE64');
  
    FIL      := BFILENAME(DIR, FILENAME);
    FILE_LEN := DBMS_LOB.GETLENGTH(FIL);
    MODULO   := MOD(FILE_LEN, AMT);
    PIECES   := TRUNC(FILE_LEN / AMT);
  
    IF (MODULO <> 0) THEN
      PIECES := PIECES + 1;
    END IF;
  
    DBMS_LOB.FILEOPEN(FIL, DBMS_LOB.FILE_READONLY);
    DBMS_LOB.READ(FIL, AMT, FILEPOS, BUF);
    DATA := NULL;
  
    FOR I IN 1 .. PIECES
    LOOP
      FILEPOS  := I * AMT + 1;
      FILE_LEN := FILE_LEN - AMT;
      DATA     := UTL_RAW.CONCAT(DATA, BUF);
      CHUNKS   := TRUNC(UTL_RAW.LENGTH(DATA) / MAX_BASE64_LINE_WIDTH);
      IF (I <> PIECES) THEN
        CHUNKS := CHUNKS - 1;
      END IF;
      WRITE_RAW(CONN, UTL_ENCODE.BASE64_ENCODE(DATA));
      DATA := NULL;
      IF (FILE_LEN < AMT AND FILE_LEN > 0) THEN
        AMT := FILE_LEN;
      END IF;
      DBMS_LOB.READ(FIL, AMT, FILEPOS, BUF);
    END LOOP;
    DBMS_LOB.FILECLOSE(FIL);
  
    END_ATTACHMENT(CONN, LAST);
  END;

  -- 32K가 넘는 파일 첨부 가능하도록..
  -- TABLE로 저장되어있는 경우 첨부 될수 있도록..
  -- EXT. TABLE을 사용할것인지 STD. TABLE을 사용할 것인지 정의가 필요..
  PROCEDURE ATTACH_BASE64(CONN   IN OUT NOCOPY UTL_SMTP.CONNECTION
                         ,INLINE IN BOOLEAN DEFAULT TRUE
                         ,FILEID IN NUMBER
                         ,LAST   IN BOOLEAN DEFAULT FALSE) IS
    I        PLS_INTEGER;
    FILE_LEN PLS_INTEGER;
  
    BUF            RAW(32000);
    DATA           RAW(32000);
    V_CONTENT_TYPE FND_LOBS.FILE_CONTENT_TYPE%TYPE;
    V_BLOB         BLOB;
    V_FILE_NAME    FND_LOBS.FILE_NAME%TYPE;
    AMT            BINARY_INTEGER := 2016;
    FILEPOS        PLS_INTEGER := 1; /* POINTER FOR THE FILE */
    PIECES         PLS_INTEGER;
    MODULO         PLS_INTEGER;
    CHUNKS         PLS_INTEGER;
  BEGIN
    --GET FILE INFO
    BEGIN
      SELECT FL.FILE_CONTENT_TYPE
            ,FL.FILE_DATA
            ,FL.FILE_NAME
      INTO   V_CONTENT_TYPE
            ,V_BLOB
            ,V_FILE_NAME
      FROM   FND_LOBS FL
      WHERE  (FL.FILE_ID = FILEID);
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, SQLERRM);
    END;
    BEGIN_ATTACHMENT(CONN, V_CONTENT_TYPE, INLINE, V_FILE_NAME, 'BASE64');
  
    -- SPLIT THE BASE64-ENCODED ATTACHMENT INTO MULTIPLE LINES
    I        := 1;
    FILE_LEN := DBMS_LOB.GETLENGTH(V_BLOB);
    MODULO   := MOD(FILE_LEN, AMT);
    PIECES   := TRUNC(FILE_LEN / AMT);
  
    IF (MODULO <> 0) THEN
      PIECES := PIECES + 1;
    END IF;
  
    DBMS_LOB.READ(V_BLOB, AMT, FILEPOS, BUF);
    DATA := NULL;
    FOR I IN 1 .. PIECES
    LOOP
      FILEPOS  := I * AMT + 1;
      FILE_LEN := FILE_LEN - AMT;
      DATA     := UTL_RAW.CONCAT(DATA, BUF);
      CHUNKS   := TRUNC(UTL_RAW.LENGTH(DATA) / MAX_BASE64_LINE_WIDTH);
      IF (I <> PIECES) THEN
        CHUNKS := CHUNKS - 1;
      END IF;
      WRITE_RAW(CONN, UTL_ENCODE.BASE64_ENCODE(DATA));
      DATA := NULL;
      IF (FILE_LEN < AMT AND FILE_LEN > 0) THEN
        AMT := FILE_LEN;
      END IF;
      DBMS_LOB.READ(V_BLOB, AMT, FILEPOS, BUF);
    END LOOP;
  
    END_ATTACHMENT(CONN, LAST);
  EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);
  END;
  ------------------------------------------------------------------------
  PROCEDURE BEGIN_ATTACHMENT(CONN         IN OUT NOCOPY UTL_SMTP.CONNECTION
                            ,MIME_TYPE    IN VARCHAR2 DEFAULT 'TEXT/PLAIN'
                            ,INLINE       IN BOOLEAN DEFAULT TRUE
                            ,FILENAME     IN VARCHAR2 DEFAULT NULL
                            ,TRANSFER_ENC IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    WRITE_BOUNDARY(CONN);
    WRITE_MIME_HEADER(CONN, 'CONTENT-TYPE', MIME_TYPE);
    IF (FILENAME IS NOT NULL) THEN
      IF (INLINE) THEN
        --WRITE_MIME_HEADER(CONN, 'CONTENT-DISPOSITION', 'INLINE; FILENAME="'||FILENAME||'"');
        --한글일 경우..
        UTL_SMTP.WRITE_DATA(CONN, 'CONTENT-DISPOSITION:INLINE; FILENAME="');
        /* UTL_SMTP.WRITE_RAW_DATA(CONN
        ,UTL_RAW.CAST_TO_RAW(CONVERT(FILENAME
                                    ,'KO16MSWIN949'))); */
      
        UTL_SMTP.WRITE_RAW_DATA(CONN,
                                UTL_RAW.CAST_TO_RAW(CONVERT(FILENAME,
                                                            'UTF8')));
        UTL_SMTP.WRITE_DATA(CONN, '"' || UTL_TCP.CRLF);
      ELSE
        --WRITE_MIME_HEADER(CONN, 'CONTENT-DISPOSITION', 'ATTACHMENT; FILENAME="'||FILENAME||'"');
        --한글일 경우..
        UTL_SMTP.WRITE_DATA(CONN,
                            'CONTENT-DISPOSITION:ATTACHMENT; FILENAME="');
        /* UTL_SMTP.WRITE_RAW_DATA(CONN
        ,UTL_RAW.CAST_TO_RAW(CONVERT(FILENAME
                                    ,'KO16MSWIN949')));*/
        UTL_SMTP.WRITE_RAW_DATA(CONN,
                                UTL_RAW.CAST_TO_RAW(CONVERT(FILENAME,
                                                            'UTF8')));
        UTL_SMTP.WRITE_DATA(CONN, '"' || UTL_TCP.CRLF);
      END IF;
    END IF;
  
    IF (TRANSFER_ENC IS NOT NULL) THEN
      WRITE_MIME_HEADER(CONN, 'CONTENT-TRANSFER-ENCODING', TRANSFER_ENC);
    END IF;
  
    UTL_SMTP.WRITE_DATA(CONN, UTL_TCP.CRLF);
  END;

  ------------------------------------------------------------------------
  PROCEDURE END_ATTACHMENT(CONN IN OUT NOCOPY UTL_SMTP.CONNECTION
                          ,LAST IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    UTL_SMTP.WRITE_DATA(CONN, UTL_TCP.CRLF);
    IF (LAST) THEN
      WRITE_BOUNDARY(CONN, LAST);
    END IF;
  END;

  ------------------------------------------------------------------------
  PROCEDURE END_MAIL(CONN IN OUT NOCOPY UTL_SMTP.CONNECTION) IS
  BEGIN
    END_MAIL_IN_SESSION(CONN);
    END_SESSION(CONN);
  END;

  ------------------------------------------------------------------------
  FUNCTION BEGIN_SESSION RETURN UTL_SMTP.CONNECTION IS
    CONN UTL_SMTP.CONNECTION;
  BEGIN
    -- OPEN SMTP CONNECTION
    CONN := UTL_SMTP.OPEN_CONNECTION(SMTP_HOST, SMTP_PORT);
    UTL_SMTP.HELO(CONN, SMTP_DOMAIN);
    RETURN CONN;
  END;

  ------------------------------------------------------------------------
  PROCEDURE BEGIN_MAIL_IN_SESSION(CONN       IN OUT NOCOPY UTL_SMTP.CONNECTION
                                 ,SENDER     IN VARCHAR2
                                 ,RECIPIENTS IN VARCHAR2
                                 ,CC         IN VARCHAR2
                                 ,SUBJECT    IN VARCHAR2
                                 ,MIME_TYPE  IN VARCHAR2 DEFAULT 'TEXT/PLAIN'
                                 ,PRIORITY   IN PLS_INTEGER DEFAULT NULL) IS
    MY_RECIPIENTS VARCHAR2(32767) := RECIPIENTS;
    MY_SENDER     VARCHAR2(32767) := SENDER;
  BEGIN
    -- SPECIFY SENDER'S ADDRESS (OUR SERVER ALLOWS BOGUS ADDRESS
    -- AS LONG AS IT IS A FULL EMAIL ADDRESS (XXX@YYY.COM).
    UTL_SMTP.MAIL(CONN, GET_ADDRESS(MY_SENDER));
  
    -- SPECIFY RECIPIENT(S) OF THE EMAIL.
    WHILE (MY_RECIPIENTS IS NOT NULL)
    LOOP
      UTL_SMTP.RCPT(CONN, GET_ADDRESS(MY_RECIPIENTS));
    END LOOP;
  
    -- START BODY OF EMAIL
    UTL_SMTP.OPEN_DATA(CONN);
  
    -- SET "FROM" MIME HEADER
    WRITE_MIME_HEADER(CONN, 'FROM', SENDER);
  
    -- SET "TO" MIME HEADER
    --WRITE_MIME_HEADER(CONN, 'TO', RECIPIENTS);
    WRITE_MIME_HEADER(CONN, 'TO', G_RECIPIENTS);
  
    -- SET "CC" MIME HEADER
    WRITE_MIME_HEADER(CONN, 'CC', CC);
  
    -- SET "SUBJECT" MIME HEADER
    --WRITE_MIME_HEADER(CONN, 'SUBJECT', SUBJECT);
    UTL_SMTP.WRITE_DATA(CONN, 'SUBJECT: ');
    /*UTL_SMTP.WRITE_RAW_DATA(CONN
    ,UTL_RAW.CAST_TO_RAW(CONVERT(SUBJECT
                                ,'KO16MSWIN949')));*/
    UTL_SMTP.WRITE_RAW_DATA(CONN,
                            UTL_RAW.CAST_TO_RAW(CONVERT(SUBJECT, 'UTF8')));
    UTL_SMTP.WRITE_DATA(CONN, UTL_TCP.CRLF);
  
    -- SET "CONTENT-TYPE" MIME HEADER
    WRITE_MIME_HEADER(CONN, 'CONTENT-TYPE', MIME_TYPE);
  
    -- SET "X-MAILER" MIME HEADER
    WRITE_MIME_HEADER(CONN, 'X-MAILER', MAILER_ID);
  
    -- SET PRIORITY:
    --   HIGH      NORMAL       LOW
    --   1     2     3     4     5
    IF (PRIORITY IS NOT NULL) THEN
      WRITE_MIME_HEADER(CONN, 'X-PRIORITY', PRIORITY);
    END IF;
  
    -- SEND AN EMPTY LINE TO DENOTES END OF MIME HEADERS AND
    -- BEGINNING OF MESSAGE BODY.
    UTL_SMTP.WRITE_DATA(CONN, UTL_TCP.CRLF);
  
    IF (MIME_TYPE LIKE 'MULTIPART/MIXED%') THEN
      WRITE_TEXT(CONN,
                 'THIS IS A MULTI-PART MESSAGE IN MIME FORMAT.' ||
                 UTL_TCP.CRLF);
    END IF;
  
  END;

  ------------------------------------------------------------------------
  PROCEDURE END_MAIL_IN_SESSION(CONN IN OUT NOCOPY UTL_SMTP.CONNECTION) IS
  BEGIN
    UTL_SMTP.CLOSE_DATA(CONN);
  END;

  ------------------------------------------------------------------------
  PROCEDURE END_SESSION(CONN IN OUT NOCOPY UTL_SMTP.CONNECTION) IS
  BEGIN
    UTL_SMTP.QUIT(CONN);
  END;

  --파일이름 한글처리..
  PROCEDURE MAIL_ATTACHMENT(P_SENDER       IN VARCHAR2
                           ,P_RECIPIENTS   IN VARCHAR2
                           ,P_CC           IN VARCHAR2 DEFAULT NULL
                           ,P_SUBJECT      IN VARCHAR2
                           ,P_MESSAGE      IN CLOB
                           ,P_FILE_ID      IN VARCHAR2 DEFAULT NULL
                           ,P_CONTENT_TYPE IN VARCHAR2 DEFAULT NULL) IS
    CONN           UTL_SMTP.CONNECTION;
    V_CONTENT_TYPE FND_LOBS.FILE_CONTENT_TYPE%TYPE;
    V_FILE_NAME    FND_LOBS.FILE_NAME%TYPE;
    V_LONG_RAW     LONG RAW;
    V_BLOB         CLOB;
    V_MESSAGE      CLOB;
    V_NEXT_FILE_ID NUMBER;
  
    V_FILE_LENGTH NUMBER;
    V_MOD         NUMBER;
    V_PIECES      NUMBER;
    V_AMT         NUMBER := 550;
    V_FILEPOS     PLS_INTEGER := 1;
    V_BUF         VARCHAR2(4000);
    V_DATA        VARCHAR2(4000);
    V_CHUNKS      PLS_INTEGER;
  
    SRC_FILE BFILE;
    DST_FILE BLOB;
    LGH_FILE BINARY_INTEGER;
  
    CURSOR C_ATTACHES_LIST IS
      --SELECT LTRIM(REGEXP_SUBSTR(XX.STR, '[^' || XX.DIV || ']+', 1, LEVEL), XX.DIV) AS FILE_ID
      SELECT LTRIM(XX.STR, XX.DIV) AS FILE_ID
      FROM   (SELECT RTRIM(',' || P_FILE_ID, ',') STR
                    ,',' DIV
              FROM   DUAL) XX
      CONNECT BY LEVEL <= (LENGTH(XX.STR) - LENGTH(REPLACE(XX.STR, XX.DIV))) /
                 LENGTH(XX.DIV);
  BEGIN
    --변환이 필요함..
    V_MESSAGE := CONVERT(P_MESSAGE, 'UTF8');
  
    --CONNECTION OPEN
    CONN := BEGIN_MAIL(SENDER     => P_SENDER,
                       RECIPIENTS => P_RECIPIENTS,
                       CC         => P_CC,
                       SUBJECT    => P_SUBJECT,
                       MIME_TYPE  => MULTIPART_MIME_TYPE);
  
    --BODY
    ----------------------------------------
    -- SEND THE MAIN MESSAGE TEXT
    ----------------------------------------
    UTL_SMTP.WRITE_DATA(CONN, FIRST_BOUNDARY);
    WRITE_MIME_HEADER(CONN, 'CONTENT-TYPE', P_CONTENT_TYPE);
    UTL_SMTP.WRITE_DATA(CONN, UTL_TCP.CRLF);
  
    V_FILE_LENGTH := DBMS_LOB.GETLENGTH(V_MESSAGE);
  
    V_MOD    := MOD(V_FILE_LENGTH, V_AMT);
    V_PIECES := TRUNC(V_FILE_LENGTH / V_AMT);
  
    IF (V_MOD <> 0) THEN
      V_PIECES := V_PIECES + 1;
    END IF;
  
    IF V_FILE_LENGTH < V_AMT THEN
      V_AMT := V_FILE_LENGTH - 1;
    END IF;
  
    --CLOB을 잘라서..
    DBMS_LOB.READ(V_MESSAGE, V_AMT, V_FILEPOS, V_BUF);
  
    V_DATA := NULL;
    FOR I IN 1 .. V_PIECES
    LOOP
      V_FILEPOS     := I * V_AMT + 1;
      V_FILE_LENGTH := V_FILE_LENGTH - V_AMT;
      V_DATA        := V_DATA || V_BUF;
      V_CHUNKS      := TRUNC(LENGTH(V_DATA) / 10);
      IF (I <> V_PIECES) THEN
        V_CHUNKS := V_CHUNKS - 1;
      END IF;
      /*UTL_SMTP.WRITE_RAW_DATA(CONN
      ,UTL_RAW.CAST_TO_RAW(CONVERT(V_DATA
                                  ,'KO16MSWIN949')));*/
      UTL_SMTP.WRITE_RAW_DATA(CONN,
                              UTL_RAW.CAST_TO_RAW(CONVERT(V_DATA, 'UTF8')));
      V_DATA := NULL;
      IF (V_FILE_LENGTH < V_AMT AND V_FILE_LENGTH > 0) THEN
        V_AMT := V_FILE_LENGTH;
      END IF;
      DBMS_LOB.READ(V_MESSAGE, V_AMT, V_FILEPOS, V_BUF);
    END LOOP;
  
    UTL_SMTP.WRITE_DATA(CONN, UTL_TCP.CRLF);
  
    ----------------------------------------
    -- ATTACH
    ----------------------------------------
    IF P_FILE_ID IS NOT NULL THEN
      IF INSTR(P_FILE_ID, ',') > 0 THEN
        FOR REC_ATTACHES_LIST IN C_ATTACHES_LIST
        LOOP
          ATTACH_BASE64(CONN   => CONN,
                        INLINE => FALSE,
                        FILEID => TO_NUMBER(REC_ATTACHES_LIST.FILE_ID));
        END LOOP;
      ELSE
        ATTACH_BASE64(CONN => CONN, INLINE => FALSE, FILEID => P_FILE_ID);
      END IF;
    END IF;
  
    -- CLOSE CONNECTION
    END_MAIL(CONN);
  
    DBMS_OUTPUT.PUT_LINE('SUCCESSFULLY DONE');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'SUCCESSFULLY DONE');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001, 'ERROR OCCURRED :' || SQLERRM);
      END_MAIL(CONN);
  END;

  PROCEDURE MAIL_ATTACHMENT(P_SENDER       IN VARCHAR2
                           ,P_RECIPIENTS   IN VARCHAR2
                           ,P_CC           IN VARCHAR2 DEFAULT NULL
                           ,P_SUBJECT      IN VARCHAR2
                           ,P_MESSAGE      IN CLOB
                           ,P_MIME_TYPE    IN VARCHAR2
                           ,P_DIR          IN VARCHAR2
                           ,P_FILE_NAME    IN VARCHAR2
                           ,P_CONTENT_TYPE IN VARCHAR2) IS
    CONN           UTL_SMTP.CONNECTION;
    V_CONTENT_TYPE FND_LOBS.FILE_CONTENT_TYPE%TYPE;
    V_FILE_NAME    FND_LOBS.FILE_NAME%TYPE;
    V_LONG_RAW     LONG RAW;
    V_BLOB         BLOB;
    V_MESSAGE      VARCHAR2(32767); -- := CONVERT('한글', 'KO16MSWIN949');
    --V_MESSAGE      CLOB;
    V_NEXT_FILE_ID NUMBER;
  
    SRC_FILE BFILE;
    DST_FILE BLOB;
    LGH_FILE BINARY_INTEGER;
  
  BEGIN
    --V_SUBJECT := CONVERT(P_SUBJECT, 'UTF8');
    V_MESSAGE := CONVERT(P_MESSAGE, 'UTF8');
  
    --CONNECTION OPEN
    CONN := BEGIN_MAIL(SENDER     => P_SENDER,
                       RECIPIENTS => P_RECIPIENTS,
                       CC         => P_CC,
                       SUBJECT    => P_SUBJECT,
                       MIME_TYPE  => MULTIPART_MIME_TYPE);
  
    --BODY
    ----------------------------------------
    -- SEND THE MAIN MESSAGE TEXT
    ----------------------------------------
    UTL_SMTP.WRITE_DATA(CONN, FIRST_BOUNDARY);
    --WRITE_MIME_HEADER(CONN, 'CONTENT-TYPE', 'TEXT/HTML');
    WRITE_MIME_HEADER(CONN, 'CONTENT-TYPE', P_CONTENT_TYPE);
    UTL_SMTP.WRITE_DATA(CONN, UTL_TCP.CRLF);
    /*        UTL_SMTP.WRITE_RAW_DATA(CONN
    ,UTL_RAW.CAST_TO_RAW(CONVERT(V_MESSAGE
                                ,'KO16MSWIN949')));*/
    UTL_SMTP.WRITE_RAW_DATA(CONN,
                            UTL_RAW.CAST_TO_RAW(CONVERT(V_MESSAGE, 'UTF8')));
    UTL_SMTP.WRITE_DATA(CONN, UTL_TCP.CRLF);
  
    ----------------------------------------
    -- ATTACH
    ----------------------------------------
    IF P_FILE_NAME IS NOT NULL THEN
      ATTACH_BASE64(CONN      => CONN,
                    MIME_TYPE => P_MIME_TYPE,
                    INLINE    => TRUE,
                    DIR       => P_DIR,
                    FILENAME  => P_FILE_NAME);
    END IF;
  
    -- CLOSE CONNECTION
    END_MAIL(CONN);
    DBMS_OUTPUT.PUT_LINE('SUCCESSFULLY DONE');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'SUCCESSFULLY DONE');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001,
                              'MAIL_ATTACHMENT PROCEDURE ERROR OCCURRED :' ||
                              SQLERRM);
      END_MAIL(CONN);
  END;

  PROCEDURE SEND_MAIL(P_SENDER        IN VARCHAR2
                     ,P_RECIPIENTS    IN VARCHAR2
                     ,P_CC            IN VARCHAR2 DEFAULT NULL
                     ,P_SUBJECT       IN VARCHAR2
                     ,P_MESSAGE       IN CLOB DEFAULT NULL
                     ,P_FILE_ID       IN VARCHAR2 DEFAULT NULL
                     ,P_MIME_TYPE     IN VARCHAR2 DEFAULT NULL
                     ,P_DIR           IN VARCHAR2 DEFAULT NULL
                     ,P_FILE_NAME     IN VARCHAR2 DEFAULT NULL
                     ,P_CONTENT_TYPE  IN VARCHAR2 DEFAULT 'TEXT/PLAIN'
                     ,O_STATUS_CODE   OUT VARCHAR2
                     ,O_ERROR_MESSAGE OUT VARCHAR2) IS
    CURSOR C_CC_LIST IS
      --SELECT LTRIM(REGEXP_SUBSTR(XX.STR, '[^' || XX.DIV || ']+', 1, LEVEL), XX.DIV) AS RECIPIENTS
      SELECT LTRIM(XX.STR, XX.DIV) AS RECIPIENTS
      FROM   (SELECT RTRIM(',' || P_RECIPIENTS || ',' || P_CC, ',') STR
                    ,',' DIV
              FROM   DUAL) XX
      CONNECT BY LEVEL <= (LENGTH(XX.STR) - LENGTH(REPLACE(XX.STR, XX.DIV))) /
                 LENGTH(XX.DIV);
  BEGIN
    G_RECIPIENTS := P_RECIPIENTS;
    IF P_FILE_ID IS NULL AND P_FILE_NAME IS NULL THEN
      FOR REC_CC_LIST IN C_CC_LIST
      LOOP
        MAIL_ATTACHMENT(P_SENDER       => P_SENDER,
                        P_RECIPIENTS   => REC_CC_LIST.RECIPIENTS,
                        P_CC           => P_CC,
                        P_SUBJECT      => P_SUBJECT,
                        P_MESSAGE      => P_MESSAGE,
                        P_CONTENT_TYPE => P_CONTENT_TYPE);
      END LOOP;
    END IF;
  
    IF P_FILE_ID IS NOT NULL THEN
      FOR REC_CC_LIST IN C_CC_LIST
      LOOP
        MAIL_ATTACHMENT(P_SENDER       => P_SENDER,
                        P_RECIPIENTS   => REC_CC_LIST.RECIPIENTS,
                        P_CC           => P_CC,
                        P_SUBJECT      => P_SUBJECT,
                        P_MESSAGE      => P_MESSAGE,
                        P_FILE_ID      => P_FILE_ID,
                        P_CONTENT_TYPE => P_CONTENT_TYPE);
      END LOOP;
    END IF;
  
    IF P_FILE_NAME IS NOT NULL THEN
      FOR REC_CC_LIST IN C_CC_LIST
      LOOP
        MAIL_ATTACHMENT(P_SENDER       => P_SENDER,
                        P_RECIPIENTS   => REC_CC_LIST.RECIPIENTS,
                        P_CC           => P_CC,
                        P_SUBJECT      => P_SUBJECT,
                        P_MESSAGE      => P_MESSAGE,
                        P_MIME_TYPE    => P_MIME_TYPE,
                        P_DIR          => P_DIR,
                        P_FILE_NAME    => P_FILE_NAME,
                        P_CONTENT_TYPE => P_CONTENT_TYPE);
      END LOOP;
    END IF;
    O_STATUS_CODE := 'S';
  EXCEPTION
    WHEN OTHERS THEN
      O_STATUS_CODE   := 'E';
      O_ERROR_MESSAGE := SQLERRM;
  END;

END;
/
