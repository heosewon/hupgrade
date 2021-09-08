CREATE OR REPLACE PROCEDURE ifc_send_mail_RT(
                           Errbuf     OUT VARCHAR2,
                           Retcode    OUT VARCHAR2)
IS

--> 컨커런트 명 : Dally Performence Status Send Mail (ERP)
--> 메일보내는 프로시져 : JOB_SCHEDULE_DAILY_REPORT (SPC)

  --  v_to_name        VARCHAR2(100);
  --  v_to_email       VARCHAR2(100);
  --  v_org_code       VARCHAR2(10);
    v_subject        VARCHAR2(250);
    v_message        LONG;
    v_ORDER_PL_AMT   VARCHAR2(100);
    v_START_PL_AMT   VARCHAR2(100); -- 투입 계획 금액(소계)
    v_WIP_PL_AMT     VARCHAR2(100); -- 생산 계획 금액(소계)
    v_DEL_PL_AMT     VARCHAR2(100);
    v_ORDER_PL_AMT1  NUMBER;
    v_START_PL_AMT1  NUMBER;
    v_WIP_PL_AMT1    NUMBER;
    v_DEL_PL_AMT1    NUMBER;
    v_ORDER_AMT      VARCHAR2(100);
    v_START_AMT      VARCHAR2(100);
    v_ORDER_AMT1     NUMBER;
    v_START_AMT1     NUMBER;
    v_IWIP_AMT       VARCHAR2(100);
    v_CWIP_AMT       VARCHAR2(100);
    v_WIP_AMT        VARCHAR2(100);
    v_DEL_AMT        VARCHAR2(100);
    v_WIP_AMT1       NUMBER;
    v_DEL_AMT1       NUMBER;
    v_ORDER_MM       VARCHAR2(100);
    v_START_MM       VARCHAR2(100);
    v_IWIP_MM        VARCHAR2(100);
    v_CWIP_MM        VARCHAR2(100);
    v_WIP_MM         VARCHAR2(100);
    v_DEL_MM         VARCHAR2(100);
    v_ORDER_LM_AMT   VARCHAR2(100);
    v_START_LM_AMT   VARCHAR2(100);
    v_WIP_LM_AMT     VARCHAR2(100);
    v_CWIP_LM_AMT    VARCHAR2(100);   -- 생산 전월 실적 금액 (CCT)
    v_DEL_LM_AMT     VARCHAR2(100);
    v_DAY            NUMBER;
    v_ORDER_PER      VARCHAR2(100);
    v_START_PER      VARCHAR2(100);
    v_WIP_PER        VARCHAR2(100);
    v_DEL_PER        VARCHAR2(100);
    v_TITLE          VARCHAR2(300);
    v_DY             VARCHAR2(300);
    v_DORDER_AMT     VARCHAR2(100);
    v_DSTART_AMT     VARCHAR2(100);
    v_DIWIP_AMT      VARCHAR2(100);
    v_DCWIP_AMT      VARCHAR2(100);
    v_DWIP_AMT       VARCHAR2(100);
    v_DDEL_AMT       VARCHAR2(100);
    v_month          VARCHAR2(30);
    v_month1         VARCHAR2(30);
    v_url            VARCHAR2(400); 
    v_etc            VARCHAR2(500);
   -- v_message1       VARCHAR2(4000); 
   --v_message2       VARCHAR2(4000);   
   
    -- 2020.06.03 J.W Kim 경영관리팀 김흥섭S 요청 - 수주계획금액, 출고계획금액에 제품/상품 구분 추가
    v_ORDER_PL_FG_AMT VARCHAR2(100);    -- 수주 계획 금액 (제품)
    v_ORDER_PL_P_AMT  VARCHAR2(100);    -- 수주 계획 금액 (상품)
    v_DEL_PL_FG_AMT   VARCHAR2(100);    -- 출고 계획 금액 (제품)
    v_DEL_PL_P_AMT    VARCHAR2(100);    -- 출고 계획 금액 (상품)
    v_DORDER_FG_AMT   VARCHAR2(100);    -- 수주 일일 실적 금액 (제품)
    v_DORDER_P_AMT    VARCHAR2(100);    -- 수주 일일 실적 금액 (상품)
    v_DDEL_FG_AMT     VARCHAR2(100);    -- 출고 일일 실적 금액 (제품)
    v_DDEL_P_AMT      VARCHAR2(100);    -- 출고 일일 실적 금액 (상품)
    v_ORDER_FG_AMT    VARCHAR2(100);    -- 수주 누적 실적 금액 (제품)
    v_ORDER_P_AMT     VARCHAR2(100);    -- 수주 누적 실적 금액 (상품)
    v_DELIVERY_FG_AMT VARCHAR2(100);    -- 출고 누적 실적 금액 (제품)
    v_DELIVERY_P_AMT  VARCHAR2(100);    -- 출고 누적 실적 금액 (상품)
    v_ORDER_FG_MM     VARCHAR2(100);    -- 수주 누적 면적 (제품)
    v_ORDER_P_MM      VARCHAR2(100);    -- 수주 누적 면적 (상품)
    v_DELIVERY_FG_MM  VARCHAR2(100);    -- 출고 누적 면적 (제품)
    v_DELIVERY_P_MM   VARCHAR2(100);    -- 출고 누적 면적 (상품)
    v_ORDER_LM_FG_AMT VARCHAR2(100);    -- 수주 전월 실적 (제품)
    v_ORDER_LM_P_AMT  VARCHAR2(100);    -- 수주 전월 실적 (상품)
    v_DEL_LM_FG_AMT   VARCHAR2(100);    -- 출고 전월 실적 (제품)
    v_DEL_LM_P_AMT    VARCHAR2(100);    -- 츨거 전월 실적 (상품)
    
    -- 2020.07.06 J.W.Kim 경영관리팀 김흥섭S 요청-일일경영실적현황 (각 항목별 샘플 실적 추가)
    v_DORDER_SPL_AMT   VARCHAR2(100);   -- 수주 일일 실적 금액 (샘플)
    v_DSTART_SPL_AMT   VARCHAR2(100);   -- 투입 일일 실적 금액 (샘플)
    v_DWIP_SPL_AMT     VARCHAR2(100);   -- 생산 일일 실적 금액 (샘플)
    v_DDEL_SPL_AMT     VARCHAR2(100);   -- 출고 일일 실적 금액 (샘플)
    v_ORDER_SPL_AMT    VARCHAR2(100);   -- 수주 누적 실적 금액 (샘플)
    v_START_SPL_AMT    VARCHAR2(100);   -- 투입 누적 실적 금액 (샘플)
    v_WIP_SPL_AMT      VARCHAR2(100);   -- 생산 누적 실적 금액 (샘플)
    v_DELIVERY_SPL_AMT VARCHAR2(100);   -- 출고 누적 실적 금액 (샘플)
    v_ORDER_SPL_MM     VARCHAR2(100);   -- 수주 누적 면적 (샘플)
    v_START_SPL_MM     VARCHAR2(100);   -- 투입 누적 면적 (샘플)
    v_WIP_SPL_MM       VARCHAR2(100);   -- 생산 누적 면적 (샘플)   
    v_DELIVERY_SPL_MM  VARCHAR2(100);   -- 출고 누적 면적 (샘플)
    v_ORDER_LM_SPL_AMT VARCHAR2(100);   -- 수주 전월 실적 금액 (샘플)
    v_START_LM_SPL_AMT VARCHAR2(100);   -- 투입 전월 실적 금액 (샘플)
    v_WIP_LM_SPL_AMT   VARCHAR2(100);   -- 생산 전월 실적 금액 (샘플)
    v_DEL_LM_SPL_AMT   VARCHAR2(100);   -- 출고 전월 실적 금액 (샘플)
    
    v_DORDER_TOTAL_AMT   VARCHAR2(100); -- 수주 일일 실적 총계
    v_DSTART_TOTAL_AMT   VARCHAR2(100); -- 투입 일일 실적 총계
    
    v_DWIP_TOTAL_AMT     VARCHAR2(100); -- 생산 일일 실적 소계
    v_CDWIP_TOTAL_AMT    VARCHAR2(100); -- 생산 일일 실적 총계
    
    v_DDEL_TOTAL_AMT     VARCHAR2(100); -- 출고 일일 실적 총계
    v_ORDER_TOTAL_AMT    VARCHAR2(100); -- 수주 누적 실적 총계
    v_START_TOTAL_AMT    VARCHAR2(100); -- 투입 누적 실적 총계
    v_WIP_TOTAL_AMT      VARCHAR2(100); -- 생산 누적 실적 소계
    v_CWIP_TOTAL_AMT     VARCHAR2(100); -- 생산 누적 실적 총계
    v_DELIVERY_TOTAL_AMT VARCHAR2(100); -- 출고 누적 실적 총계
    v_ORDER_TOTAL_MM     VARCHAR2(100); -- 수주 누적 면적 총계
    v_START_TOTAL_MM     VARCHAR2(100); -- 투입 누적 면적 총계
    v_WIP_TOTAL_MM       VARCHAR2(100); -- 생산 누적 면적 소계
    v_CWIP_TOTAL_MM      VARCHAR2(100); -- 생산 누적 면적 총계
    v_DELIVERY_TOTAL_MM  VARCHAR2(100); -- 출고 누적 면적 총계
    v_ORDER_LM_TOTAL_AMT VARCHAR2(100); -- 수주 전월 실적 금액 총계
    v_START_LM_TOTAL_AMT VARCHAR2(100); -- 투입 전월 실적 금액 총계  
    v_WIP_LM_TOTAL_AMT   VARCHAR2(100); -- 생산 전월 실적 금액 소계
    v_CWIP_LM_TOTAL_AMT  VARCHAR2(100); -- 생산 전월 실적 금액 총계
    v_DEL_LM_TOTAL_AMT   VARCHAR2(100); -- 출고 전월 실적 금액 총계

   -- 2020.07.14 J.W.Kim 경영관리팀 김흥섭S 요청-일일경영실적현황 (투입/생산 목표 샘플 추가)
    v_START_PL_FG_AMT    VARCHAR2(100); -- 투입 계획 금액(양산)
    v_WIP_PL_FG_AMT      VARCHAR2(100); -- 생산 계획 금액(양산)
    v_START_PL_SMP_AMT   VARCHAR2(100); -- 투입 계획 금액(샘플)
    v_WIP_PL_SMP_AMT     VARCHAR2(100); -- 생산 계획 금액(샘플)   
    
   -- 2020.09.16 J.W.Kim 경영관리팀 김흥섭S 요청-일일경영실적현황 (생산 목표 CCT 추가)
    v_WIP_PL_CCT_AMT     VARCHAR2(100); -- 생산 계획 금액(CCT)
    v_CWIP_PL_TOTAL_AMT  VARCHAR2(100); -- 생산 계획 총계    
    v_CWIP_PL_TOTAL_AMT1 NUMBER;
    
    V_Run_Count Number;
     
BEGIN

    SELECT count(*)
      INTO V_Run_Count
      FROM fnd_concurrent_programs    pb
         , fnd_executables            fe
         , fnd_concurrent_requests    r
     WHERE pb.application_id          = r.program_application_id
       AND pb.concurrent_program_id   = r.concurrent_program_id
       AND pb.executable_id           = fe.executable_id
       AND pb.application_id          = fe.application_id
       AND r.phase_code               = 'R' --Running
       AND pb.concurrent_program_name = 'IFCEISC0061'
       AND r.request_id              != FND_GLOBAL.Conc_Request_ID;
    
    --중복 실행 방지
    IF (V_Run_Count > 0) THEN
        fnd_file.put_line (fnd_file.log, '배치 프로그램이 이미 실행중입니다.');
        dbms_output.put_line('배치 프로그램이 이미 실행중입니다.');
        Return;
    END IF;

  BEGIN
    SELECT REPLACE(TO_CHAR(ROUND(PM.Order_Pl_Fg_Amt) + ROUND(PM.Order_Pl_p_Amt),'999,990'),' ','')
    ,      REPLACE(TO_CHAR(ROUND(PM.Start_Pl_Fg_Amt) + ROUND(PM.Start_Pl_Smp_Amt),'999,990'),' ','')
--    ,      REPLACE(TO_CHAR(ROUND(PM.START_PL_AMT), '999,990'),' ','')
    ,      REPLACE(TO_CHAR(ROUND(PM.Wip_Pl_Fg_Amt) + ROUND(PM.Wip_Pl_Smp_Amt),'999,990'),' ','')
--    ,      REPLACE(TO_CHAR(ROUND(PM.WIP_PL_AMT), '999,990'),' ','')
    ,      REPLACE(TO_CHAR(ROUND(PM.Wip_Pl_Fg_Amt) + ROUND(PM.Wip_Pl_Smp_Amt) + ROUND(PM.Wip_Pl_Cct_Amt),'999,990'),' ','')                   --생산 계획 총계
    ,      REPLACE(TO_CHAR(ROUND(PM.Del_Pl_Fg_Amt) + ROUND(PM.Del_Pl_p_Amt),'999,990'),' ','')
    ,      ROUND(PM.ORDER_PL_AMT)
    ,      ROUND(PM.START_PL_AMT)
    ,      ROUND(PM.WIP_PL_AMT)
    ,      ROUND(PM.CWIP_PL_TOTAL_AMT)
    ,      ROUND(PM.DEL_PL_AMT)
    ,      ROUND(TO_NUMBER(TO_CHAR(SYSDATE -1 - 8.5/24,'DD'))/ TO_NUMBER(TO_CHAR(last_day(sysdate -1 - 8.5/24),'DD')) * 100) as CNT1
 
    -- 2020.06.03 경영관리팀 김흥섭S 요청 - 수주계획금액, 출고계획금액에 제품/상품 구분 추가
    ,      REPLACE(TO_CHAR(ROUND(PM.Order_Pl_Fg_Amt), '999,990'),' ','') --수주 제품 계획 금액
    ,      REPLACE(TO_CHAR(ROUND(PM.Order_Pl_p_Amt), '999,990'),' ','')  --수주 상품 계획 금액
    ,      REPLACE(TO_CHAR(ROUND(PM.Del_Pl_Fg_Amt), '999,990'),' ','')   --출고 제품 계획 금액
    ,      REPLACE(TO_CHAR(ROUND(PM.Del_Pl_p_Amt), '999,990'),' ','')    --출고 상품 계획 금액
    
    -- 2020.07.16 경영관리팀 김흥섭S 요청 - 투입계획금액, 생산계획금액에 양산/샘플 구분 추가
    ,      REPLACE(TO_CHAR(ROUND(PM.Start_Pl_Fg_Amt), '999,990'),' ','') --투입 양산 계획 금액
    ,      REPLACE(TO_CHAR(ROUND(PM.Start_Pl_Smp_Amt), '999,990'),' ','')--투입 샘플 계획 금액
    ,      REPLACE(TO_CHAR(ROUND(PM.Wip_Pl_Fg_Amt), '999,990'),' ','')   --생산 양산 계획 금액
    ,      REPLACE(TO_CHAR(ROUND(PM.Wip_Pl_Smp_Amt), '999,990'),' ','')  --생산 샘플 계획 금액
   
    -- 2020.09.16 J.W.Kim 경영관리팀 김흥섭S 요청-일일경영실적현황 (생산 목표 CCT 추가)
    ,      REPLACE(TO_CHAR(ROUND(PM.Wip_Pl_Cct_Amt), '999,990'),' ','')  --생산 CCT 계획 금액 
   
    INTO   v_ORDER_PL_AMT
    ,      v_START_PL_AMT
    ,      v_WIP_PL_AMT
    ,      v_CWIP_PL_TOTAL_AMT  -- 생산 계획 실적 금액 총계
    ,      v_DEL_PL_AMT
    ,      v_ORDER_PL_AMT1
    ,      v_START_PL_AMT1
    ,      v_WIP_PL_AMT1
    ,      v_CWIP_PL_TOTAL_AMT1
    ,      v_DEL_PL_AMT1
    ,      v_DAY
    ,      v_ORDER_PL_FG_AMT
    ,      v_ORDER_PL_P_AMT
    ,      v_DEL_PL_FG_AMT
    ,      v_DEL_PL_P_AMT
    ,      v_START_PL_FG_AMT   -- 투입 계획 금액(양산)
    ,      v_START_PL_SMP_AMT  -- 투입 계획 금액(샘플)
    ,      v_WIP_PL_FG_AMT     -- 생산 계획 금액(양산)
    ,      v_WIP_PL_SMP_AMT    -- 생산 계획 금액(샘플)
    ,      v_WIP_PL_CCT_AMT    -- 생산 계획 금액(CCT)    
    FROM   IFC_WEB_ERP_PLAN_MONTHS PM
    WHERE  1=1
      and PM.PERIOD_NAME = TO_CHAR(sysdate-1,'YYYY-MM');
--      and PM.PERIOD_NAME = '2020-04';
  END;

  BEGIN
     SELECT  REPLACE(TO_CHAR(ROUND(GRP.ORDER_FG_AMT) + ROUND(GRP.ORDER_P_AMT),'999,990'),' ','')
     ,       REPLACE(TO_CHAR(ROUND(GRP.START_AMT + GRP.IPRO_START_AMT), '999,990'),' ','')
     ,       REPLACE(TO_CHAR(ROUND(GRP.ENTER_AMT + GRP.IPRO_ENTER_AMT), '999,990'),' ','')
     ,       REPLACE(TO_CHAR(ROUND(GRP.CCT_ENTER_AMT), '999,990'),' ','')
     ,       REPLACE(TO_CHAR(ROUND(GRP.ENTER_AMT) + ROUND(GRP.CCT_ENTER_AMT),'999,990'),' ','')  
     ,       REPLACE(TO_CHAR(ROUND(GRP.DELIVERY_FG_AMT) + ROUND(GRP.DELIVERY_P_AMT),'999,990'),' ','')
     -- 2020.06.03 경영관리팀 김흥섭S 요청 - 일일 실적( 수주/제품 )에 제품/상품 구분 추가
     ,       REPLACE(TO_CHAR(ROUND(GRP.ORDER_FG_AMT), '999,990'),' ','')                                                                            --수주 제품 일일 실적
     ,       REPLACE(TO_CHAR(ROUND(GRP.ORDER_P_AMT), '999,990'),' ','')                                                                             --수주 상품 일일 실적
     ,       REPLACE(TO_CHAR(ROUND(GRP.DELIVERY_FG_AMT), '999,990'),' ','')                                                                         --출고 제품 일일 실적
     ,       REPLACE(TO_CHAR(ROUND(GRP.DELIVERY_P_AMT), '999,990'),' ','')                                                                          --출고 상품 일일 실적
     -- 2020.07.06 J.W.Kim 경영관리팀 김흥섭S 요청-일일경영실적현황 (각 항목별 샘플 실적 추가)
     ,       REPLACE(TO_CHAR(ROUND(GRP.ORDER_SAMPLE_AMT), '999,990'),' ','')                                                                        --수주 일일 실적 (샘플)
     ,       REPLACE(TO_CHAR(ROUND(GRP.START_SAMPLE_AMT), '999,990'),' ','')                                                                        --투입 일일 실적 (샘플)
     ,       REPLACE(TO_CHAR(ROUND(GRP.ENTER_SAMPLE_AMT), '999,990'),' ','')                                                                        --생산 일일 실적 (샘플)
     ,       REPLACE(TO_CHAR(ROUND(GRP.DELIVERY_SAMPLE_AMT), '999,990'),' ','')                                                                     --출고 일일 실적 (샘플)
     ,       REPLACE(TO_CHAR(ROUND(GRP.ORDER_FG_AMT) + ROUND(GRP.ORDER_P_AMT) + ROUND(GRP.ORDER_SAMPLE_AMT),'999,990'),' ','')                      --수주 일일 총계
     ,       REPLACE(TO_CHAR(ROUND(GRP.START_AMT) + ROUND(GRP.START_SAMPLE_AMT),'999,990'),' ','')                                                  --투입 일일 총계
     ,       REPLACE(TO_CHAR(ROUND(GRP.ENTER_AMT) + ROUND(GRP.ENTER_SAMPLE_AMT),'999,990'),' ','')                                                  --생산 일일 소계
     ,       REPLACE(TO_CHAR(ROUND(GRP.ENTER_AMT) + ROUND(GRP.ENTER_SAMPLE_AMT) + ROUND(GRP.CCT_ENTER_AMT),'999,990'),' ','')                       --생산 일일 총계
     ,       REPLACE(TO_CHAR(ROUND(GRP.DELIVERY_FG_AMT) + ROUND(GRP.DELIVERY_P_AMT) + ROUND(GRP.DELIVERY_SAMPLE_AMT),'999,990'),' ','')             --출하 일일 총계
     INTO    v_DORDER_AMT
     ,       v_DSTART_AMT
     ,       v_DIWIP_AMT
     ,       v_DCWIP_AMT
     ,       v_DWIP_AMT
     ,       v_DDEL_AMT
     ,       v_DORDER_FG_AMT
     ,       v_DORDER_P_AMT
     ,       v_DDEL_FG_AMT
     ,       v_DDEL_P_AMT
     ,       v_DORDER_SPL_AMT   -- 수주 일일 실적 금액 (샘플)
     ,       v_DSTART_SPL_AMT   -- 투입 일일 실적 금액 (샘플)
     ,       v_DWIP_SPL_AMT     -- 생산 일일 실적 금액 (샘플)
     ,       v_DDEL_SPL_AMT     -- 출고 일일 실적 금액 (샘플)
     ,       v_DORDER_TOTAL_AMT -- 수주 일일 실적 총계
     ,       v_DSTART_TOTAL_AMT -- 투입 일일 실적 총계
     ,       v_DWIP_TOTAL_AMT   -- 생산 일일 실적 소계
     ,       v_CDWIP_TOTAL_AMT  -- 생산 일일 실적 총계
     ,       v_DDEL_TOTAL_AMT   -- 출고 일일 실적 총계
     FROM IFC_GW_RESULT_PT_DAILY_V GRP
     WHERE GRP.TRANSACTION_DATE = TO_CHAR(sysdate -1 - 8.5/24,'YYYY-MM-DD');
  END;

  BEGIN
     SELECT  REPLACE(TO_CHAR(ROUND(GRP.ORDER_FG_AMT) + ROUND(GRP.ORDER_P_AMT),'999,990'),' ','')
     ,       REPLACE(TO_CHAR(ROUND(GRP.START_AMT + GRP.IPRO_START_AMT,1), '999,990'),' ','')
     ,       ROUND(GRP.ORDER_AMT)
     ,       ROUND(GRP.START_AMT + GRP.IPRO_START_AMT) + ROUND(GRP.START_SAMPLE_AMT)                                             --2020.08.31 투입누적실적 샘플실적추가
     ,       REPLACE(TO_CHAR(ROUND(GRP.ENTER_AMT + GRP.IPRO_ENTER_AMT), '999,990'),' ','')
     ,       REPLACE(TO_CHAR(ROUND(GRP.CCT_ENTER_AMT), '999,990'),' ','')
     ,       REPLACE(TO_CHAR(ROUND(GRP.ENTER_AMT) + ROUND(GRP.CCT_ENTER_AMT),'999,990'),' ','')
     ,       REPLACE(TO_CHAR(ROUND(GRP.DELIVERY_FG_AMT) + ROUND(GRP.DELIVERY_P_AMT),'999,990'),' ','')
     ,       ROUND(GRP.ENTER_AMT + GRP.IPRO_ENTER_AMT) + ROUND(NVL(GRP.CCT_ENTER_AMT,0)) + ROUND(GRP.ENTER_SAMPLE_AMT)           --2020.08.31 생산누적실적 샘플실적추가
     ,       ROUND(GRP.DELIVERY_AMT)
     ,       REPLACE(TO_CHAR(ROUND(GRP.ORDER_FG_MM) + ROUND(GRP.ORDER_P_MM),'999,990'),' ','')
     ,       REPLACE(TO_CHAR(ROUND(GRP.START_MM + GRP.IPRO_START_MM), '999,990'),' ','')
     ,       REPLACE(TO_CHAR(ROUND(GRP.ENTER_MM + GRP.IPRO_ENTER_MM), '999,990'),' ','')
     ,       REPLACE(TO_CHAR(ROUND(CCT_ENTER_MM), '999,990'),' ','')
     ,       REPLACE(TO_CHAR(ROUND(GRP.ENTER_MM)+ ROUND(GRP.CCT_ENTER_MM),'999,990'),' ','') 
     ,       REPLACE(TO_CHAR(ROUND(GRP.DELIVERY_FG_MM) + ROUND(GRP.DELIVERY_P_MM),'999,990'),' ','')
     -- 2020.06.03 경영관리팀 김흥섭S 요청 - 수주누적실적, 출고누적실적에 제품/상품 구분 추가
     ,       REPLACE(TO_CHAR(ROUND(GRP.ORDER_FG_AMT), '999,990'),' ','')                                                                        --수주 제품 누적 실적
     ,       REPLACE(TO_CHAR(ROUND(GRP.ORDER_P_AMT), '999,990'),' ','')                                                                         --수주 상품 누적 실적
     ,       REPLACE(TO_CHAR(ROUND(GRP.DELIVERY_FG_AMT), '999,990'),' ','')                                                                     --출고 제품 누적 실적
     ,       REPLACE(TO_CHAR(ROUND(GRP.DELIVERY_P_AMT), '999,990'),' ','')                                                                      --출고 상품 누적 실적
     ,       REPLACE(TO_CHAR(ROUND(GRP.ORDER_FG_MM), '999,990'),' ','')                                                                         --수주 제품 누적 면적
     ,       REPLACE(TO_CHAR(ROUND(GRP.ORDER_P_MM), '999,990'),' ','')                                                                          --수주 상품 누적 면적
     ,       REPLACE(TO_CHAR(ROUND(GRP.DELIVERY_FG_MM), '999,990'),' ','')                                                                      --출고 제품 누적 면적
     ,       REPLACE(TO_CHAR(ROUND(GRP.DELIVERY_P_MM), '999,990'),' ','')                                                                       --출고 상품 누적 면적
     -- 2020.07.06 J.W.Kim 경영관리팀 김흥섭S 요청-일일경영실적현황 (각 항목별 샘플 실적 추가)
     ,       REPLACE(TO_CHAR(ROUND(GRP.ORDER_SAMPLE_AMT), '999,990'),' ','')                                                                    --수주 샘플 누적 실적
     ,       REPLACE(TO_CHAR(ROUND(GRP.START_SAMPLE_AMT), '999,990'),' ','')                                                                    --투입 샘플 누적 실적
     ,       REPLACE(TO_CHAR(ROUND(GRP.ENTER_SAMPLE_AMT), '999,990'),' ','')                                                                    --생산 샘플 누적 실적
     ,       REPLACE(TO_CHAR(ROUND(GRP.DELIVERY_SAMPLE_AMT), '999,990'),' ','')                                                                 --출고 샘플 누적 실적
     ,       REPLACE(TO_CHAR(ROUND(GRP.ORDER_SAMPLE_MM), '999,990'),' ','')                                                                     --수주 샘플 누적 면적
     ,       REPLACE(TO_CHAR(ROUND(GRP.START_SAMPLE_MM), '999,990'),' ','')                                                                     --투입 샘플 누적 면적
     ,       REPLACE(TO_CHAR(ROUND(GRP.ENTER_SAMPLE_MM), '999,990'),' ','')                                                                     --생산 샘플 누적 면적
     ,       REPLACE(TO_CHAR(ROUND(GRP.DELIVERY_SAMPLE_MM), '999,990'),' ','')                                                                  --출고 샘플 누적 면적
     ,       REPLACE(TO_CHAR(ROUND(GRP.ORDER_FG_AMT) + ROUND(GRP.ORDER_P_AMT) + ROUND(GRP.ORDER_SAMPLE_AMT),'999,990'),' ','')                  --수주 누적 실적 총계
     ,       REPLACE(TO_CHAR(ROUND(GRP.START_AMT) + ROUND(GRP.START_SAMPLE_AMT),'999,990'),' ','')                                              --투입 누적 실적 총계
     ,       REPLACE(TO_CHAR(ROUND(GRP.ENTER_AMT) + ROUND(GRP.ENTER_SAMPLE_AMT),'999,990'),' ','')                                              --생산 누적 실적 소계
     ,       REPLACE(TO_CHAR(ROUND(GRP.ENTER_AMT) + ROUND(GRP.ENTER_SAMPLE_AMT) + ROUND(GRP.CCT_ENTER_AMT),'999,990'),' ','')                   --생산 누적 실적 총계
     ,       REPLACE(TO_CHAR(ROUND(GRP.DELIVERY_FG_AMT) + ROUND(GRP.DELIVERY_P_AMT) + ROUND(GRP.DELIVERY_SAMPLE_AMT),'999,990'),' ','')         --출하 누적 실적 총계
     ,       REPLACE(TO_CHAR(ROUND(GRP.ORDER_FG_MM) + ROUND(GRP.ORDER_P_MM) + ROUND(GRP.ORDER_SAMPLE_MM),'999,990'),' ','')                     --수주 누적 면적 총계
     ,       REPLACE(TO_CHAR(ROUND(GRP.START_MM) + ROUND(GRP.START_SAMPLE_MM),'999,990'),' ','')                                                --투입 누적 면적 총계
     ,       REPLACE(TO_CHAR(ROUND(GRP.ENTER_MM) + ROUND(GRP.ENTER_SAMPLE_MM),'999,990'),' ','')                                                --생산 누적 면적 소계
     ,       REPLACE(TO_CHAR(ROUND(GRP.ENTER_MM) + ROUND(GRP.ENTER_SAMPLE_MM) + ROUND(GRP.CCT_ENTER_MM),'999,990'),' ','')                      --생산 누적 면적 총계
     ,       REPLACE(TO_CHAR(ROUND(GRP.DELIVERY_FG_MM) + ROUND(GRP.DELIVERY_P_MM) + ROUND(GRP.DELIVERY_SAMPLE_MM),'999,990'),' ','')            --출하 누적 면적 총계
     
    INTO    v_ORDER_AMT
     ,       v_START_AMT
     ,       v_ORDER_AMT1
     ,       v_START_AMT1
     ,       v_IWIP_AMT
     ,       v_CWIP_AMT
     ,       v_WIP_AMT
     ,       v_DEL_AMT     
     ,       v_WIP_AMT1
     ,       v_DEL_AMT1
     ,       v_ORDER_MM
     ,       v_START_MM
     ,       v_IWIP_MM
     ,       v_CWIP_MM
     ,       v_WIP_MM
     ,       v_DEL_MM
     ,       v_ORDER_FG_AMT
     ,       v_ORDER_P_AMT
     ,       v_DELIVERY_FG_AMT
     ,       v_DELIVERY_P_AMT
     ,       v_ORDER_FG_MM
     ,       v_ORDER_P_MM
     ,       v_DELIVERY_FG_MM
     ,       v_DELIVERY_P_MM 
     ,       v_ORDER_SPL_AMT      -- 수주 누적 실적 금액 (샘플)
     ,       v_START_SPL_AMT      -- 투입 누적 실적 금액 (샘플)
     ,       v_WIP_SPL_AMT        -- 생산 누적 실적 금액 (샘플)
     ,       v_DELIVERY_SPL_AMT   -- 출고 누적 실적 금액 (샘플)
     ,       v_ORDER_SPL_MM       -- 수주 누적 면적 (샘플)
     ,       v_START_SPL_MM       -- 투입 누적 면적 (샘플)
     ,       v_WIP_SPL_MM         -- 생산 누적 면적 (샘플)   
     ,       v_DELIVERY_SPL_MM    -- 출고 누적 면적 (샘플)
     ,       v_ORDER_TOTAL_AMT    -- 수주 누적 실적 총계
     ,       v_START_TOTAL_AMT    -- 투입 누적 실적 총계
     ,       v_WIP_TOTAL_AMT      -- 생산 누적 실적 소계
     ,       v_CWIP_TOTAL_AMT     -- 생산 누적 실적 총계
     ,       v_DELIVERY_TOTAL_AMT -- 출고 누적 실적 총계
     ,       v_ORDER_TOTAL_MM     -- 수주 누적 면적 총계
     ,       v_START_TOTAL_MM     -- 투입 누적 면적 총계
     ,       v_WIP_TOTAL_MM       -- 생산 누적 면적 소계   
     ,       v_CWIP_TOTAL_MM      -- 생산 누적 면적 총계   
     ,       v_DELIVERY_TOTAL_MM  -- 출고 누적 면적 총계
     
     FROM IFC_GW_RESULT_PT_MAIL_V GRP
     WHERE TRANSACTION_DATE = TO_CHAR(sysdate -1 - 8.5/24,'YYYY-MM');

  END;

  BEGIN
     SELECT  REPLACE(TO_CHAR(ROUND(RP.ORDER_FG_AMT) + ROUND(RP.ORDER_P_AMT),'999,990'),' ','')
     ,       REPLACE(TO_CHAR(ROUND(NVL(PM.START_AMT,NVL(RP.START_AMT + RP.IPRO_START_AMT,0))), '999,990'),' ','')
     ,       REPLACE(TO_CHAR(ROUND(NVL(PM.WIP_AMT,NVL(RP.ENTER_AMT + RP.IPRO_ENTER_AMT,0)+NVL(RP.CCT_ENTER_AMT,0))), '999,990'),' ','')
     ,       REPLACE(TO_CHAR(ROUND(RP.DELIVERY_FG_AMT) + ROUND(RP.DELIVERY_P_AMT),'999,990'),' ','')
     -- 2020.06.03 경영관리팀 김흥섭S 요청 - 수주전원실적, 출고전원실적에 제품/상품 구분 추가
     ,       REPLACE(TO_CHAR(ROUND(RP.ORDER_FG_AMT), '999,990'),' ','')                                                                         --수주 제품 전월 실적
     ,       REPLACE(TO_CHAR(ROUND(RP.ORDER_P_AMT), '999,990'),' ','')                                                                          --수주 상품 전월 실적
     ,       REPLACE(TO_CHAR(ROUND(RP.DELIVERY_FG_AMT), '999,990'),' ','')                                                                      --출고 제품 전월 실적
     ,       REPLACE(TO_CHAR(ROUND(RP.DELIVERY_P_AMT), '999,990'),' ','')                                                                       --출고 상품 전월 실적
     -- 2020.07.06 J.W.Kim 경영관리팀 김흥섭S 요청-일일경영실적현황 (각 항목별 샘플 실적 추가)
     ,       REPLACE(TO_CHAR(ROUND(RP.CCT_ENTER_AMT), '999,990'),' ','')                                                                        --생산 전월 실적(CCT)
     ,       REPLACE(TO_CHAR(ROUND(RP.ORDER_SAMPLE_AMT), '999,990'),' ','')                                                                     --수주 샘플 전월 실적
     ,       REPLACE(TO_CHAR(ROUND(RP.START_SAMPLE_AMT), '999,990'),' ','')                                                                     --투입 샘플 전월 실적
     ,       REPLACE(TO_CHAR(ROUND(RP.ENTER_SAMPLE_AMT), '999,990'),' ','')                                                                     --생산 샘플 전월 실적
     ,       REPLACE(TO_CHAR(ROUND(RP.DELIVERY_SAMPLE_AMT), '999,990'),' ','')                                                                  --출고 샘플 전월 실적
     ,       REPLACE(TO_CHAR(ROUND(RP.ORDER_FG_AMT) + ROUND(RP.ORDER_P_AMT) + ROUND(RP.ORDER_SAMPLE_AMT),'999,990'),' ','')                     --수주 전월 총계
     ,       REPLACE(TO_CHAR(ROUND(RP.START_AMT) + ROUND(RP.START_SAMPLE_AMT),'999,990'),' ','')                                                --투입 전월 총계
     ,       REPLACE(TO_CHAR(ROUND(RP.ENTER_AMT) + ROUND(RP.ENTER_SAMPLE_AMT),'999,990'),' ','')                                                --생산 전월 소계
     ,       REPLACE(TO_CHAR(ROUND(RP.ENTER_AMT) + ROUND(RP.ENTER_SAMPLE_AMT) + ROUND(RP.CCT_ENTER_AMT),'999,990'),' ','')                      --생산 전월 총계
     ,       REPLACE(TO_CHAR(ROUND(RP.DELIVERY_FG_AMT) + ROUND(RP.DELIVERY_P_AMT) + ROUND(RP.DELIVERY_SAMPLE_AMT),'999,990'),' ','')            --출하 전월 총계
     INTO    v_ORDER_LM_AMT
     ,       v_START_LM_AMT
     ,       v_WIP_LM_AMT
     ,       v_DEL_LM_AMT
     ,       v_ORDER_LM_FG_AMT
     ,       v_ORDER_LM_P_AMT
     ,       v_DEL_LM_FG_AMT
     ,       v_DEL_LM_P_AMT
     ,       v_CWIP_LM_AMT        -- 생산 전월 실적 금액 (CCT)
     ,       v_ORDER_LM_SPL_AMT   -- 수주 전월 실적 금액 (샘플)
     ,       v_START_LM_SPL_AMT   -- 투입 전월 실적 금액 (샘플)
     ,       v_WIP_LM_SPL_AMT     -- 생산 전월 실적 금액 (샘플)
     ,       v_DEL_LM_SPL_AMT     -- 출고 전월 실적 금액 (샘플)
     ,       v_ORDER_LM_TOTAL_AMT -- 수주 전월 실적 금액 총계
     ,       v_START_LM_TOTAL_AMT -- 투입 전월 실적 금액 총계
     ,       v_WIP_LM_TOTAL_AMT   -- 생산 전월 실적 금액 소계
     ,       v_CWIP_LM_TOTAL_AMT  -- 생산 전월 실적 금액 총계
     ,       v_DEL_LM_TOTAL_AMT   -- 출고 전월 실적 금액 총계
     FROM    IFC_GW_RESULT_PT_MAIL_V RP
     ,       IFC_WEB_ERP_PLAN_MONTHS PM
     WHERE   1=1
     AND     RP.TRANSACTION_DATE = TO_CHAR(ADD_MONTHS(sysdate -1 - 8.5/24,-1),'YYYY-MM')
     --AND     RP.TRANSACTION_DATE = '2020-03'
     AND     RP.TRANSACTION_DATE = PM.PERIOD_NAME;
  END;
 
   --  v_DEL_LM_SPL_AMT    := '6';
   --  v_DEL_LM_TOTAL_AMT  := '237';    

  v_ORDER_PER := REPLACE(TO_CHAR(ROUND(v_ORDER_AMT1 / v_ORDER_PL_AMT1 * 100), '999,990'),' ','');
  v_START_PER := REPLACE(TO_CHAR(ROUND(v_START_AMT1 / v_START_PL_AMT1 * 100), '999,990'),' ','');
  v_WIP_PER   := REPLACE(TO_CHAR(ROUND(v_WIP_AMT1   / v_CWIP_PL_TOTAL_AMT1 * 100), '999,990'),' ','');
  v_DEL_PER   := REPLACE(TO_CHAR(ROUND(v_DEL_AMT1   / v_DEL_PL_AMT1 * 100), '999,990'),' ','');
  
 
  
  
  --v_month      := TO_CHAR(SYSDATE,'YYYY-MM');
  v_url       := 'http://erp.interflex.co.kr/ifc/rdCommon.asp?mrdPath=http://erp.interflex.co.kr/MRD/ifc_scm/ifcomr0222.mrd';
 -- v_url       := 'http://erp.interflex.co.kr/ifc_scm/ifcomr0002.mrd&rdParam=/rp[PLAN][ALL][' || v_month || ']';
  v_TITLE      :='[' || TO_CHAR(sysdate -1 - 8.5/24,'YY') ||'年 ' || TO_CHAR(sysdate -1 - 8.5/24,'MM')  ||'月 목표 대비 누적 실적 현황 ]';
  v_DY         :='※ 일수진척률:' || v_DAY ||'%';
  v_month1      := TO_CHAR(SYSDATE -1 - 8.5/24,'MM') || '월';
  v_subject :='[일일 실적 보고] ' || TO_CHAR(SYSDATE -1 - 8.5/24,'MM') ||'月 보고 드립니다';
  v_etc := '[작성기준]' ||'<br>'||'* 실적 : 양산 기준'||'<br>'||'* 투입,생산 : 제품 기준';
    
  
-- 2020.07.06 J.W.Kim 경영관리팀 김흥섭S 요청    

    v_message := v_message || '<html>';
    v_message := v_message || '<head>'; 
    v_message := v_message || '<meta content=text/html; charset=euc-kr http-equiv=Content-Type>';
    v_message := v_message || '</head>';
    v_message := v_message || '<body>';

    --상단
    v_message := v_message || '<br><br><table width=600 align=center cellspacing=0 cellpadding=0 border=0>';    
  
   --타이틀
    v_message := v_message || '<tr height=30>';
    v_message := v_message || '<td width=600 valign=middle align=center bgcolor=#FEE9FA><span style=font-size:10pt;><font color=blue><b>' || v_TITLE || '</b></font></span></td>';
    v_message := v_message || '</tr>';
   --타이틀 끝
  
  --일수진척율
    v_message := v_message || '<tr height=30>';
    v_message := v_message || '<td valign=bottom width=600 align=left><span style=font-size:8pt;><b>' || v_DY || '</b></span></td>';
    v_message := v_message || '</tr>';
  --일수진척율 끝

    v_message := v_message || '</table>';
   --상단 끝

  --표
    v_message := v_message || '<table align=center width=600 cellspacing=0 cellpadding=0 border=1 bordercolor=#999999>';
    
  --구분 ~ 일일실적
    v_message := v_message || '<tr height=30>';
    v_message := v_message || '<td colspan=3 align=center bgcolor=#CEE7FF><span style=font-size:9pt;><b>구 분</b></span></td>';
    v_message := v_message || '<td align=center width=70 bgcolor=#CEE7FF><span style=font-size:9pt;><b>전월실적</b></span></td>';
    v_message := v_message || '<td align=center width=70 bgcolor=#CEE7FF><span style=font-size:9pt;><b>목&nbsp;표</b></span></td>';
    v_message := v_message || '<td colspan=2 align=center bgcolor=#E1FDDF><span style=font-size:9pt;><b>누적실적</b></span></td>';
    v_message := v_message || '<td align=center width=70 bgcolor=#E1FDDF><span style=font-size:9pt;><b>면 적(㎡)</b></span></td>';
    v_message := v_message || '<td align=center width=70 bgcolor=#CEE7FF><span style=font-size:9pt;><b>일일실적</b></span></td>';
    v_message := v_message || '</tr>';
  --구분 ~ 일일실적 끝
  
  --수주-양산
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td rowspan=5 width=75 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>수 주</b></td>';
    v_message := v_message || '<td rowspan=3 width=35 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>양 산</b></td>';
        
  --수주-제품
    v_message := v_message || '<td align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>제 품</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_LM_FG_AMT || '억</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_PL_FG_AMT || '억</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_FG_AMT || '억</span>&nbsp;</td>';
    
  --수주-누적실적 %계
    v_message := v_message || '<td rowspan=5 align=right valign=bottom>';
    v_message := v_message || '<span style=font-size:8pt;>' || v_ORDER_PER || '%</span>&nbsp;</td>';
  --수주-누적실적 %계 끝

    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_FG_MM || '</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DORDER_FG_AMT || '억</span>&nbsp;</td>';
  --수주-제품 끝
    
  --수주-상품
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>상 품</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_LM_P_AMT || '억</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_PL_P_AMT || '억</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_P_AMT || '억</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_P_MM || '</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DORDER_P_AMT || '억</span>&nbsp;</td>';
    v_message := v_message || '</tr>';
  --수주-상품 끝

  --수주-소계
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>소 계</b></span></td>';                      
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_ORDER_LM_AMT || '억</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_ORDER_PL_AMT  || '억</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_ORDER_AMT || '억</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_ORDER_MM || '</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DORDER_AMT || '억</b></span>&nbsp;</td>';
    v_message := v_message || '</tr>';
    
  --수주-소계 끝
  
  --수주-샘플
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td colspan=2 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>샘 플</b></span></td>';                      
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_LM_SPL_AMT || '억</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_SPL_AMT || '억</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_SPL_MM || '</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DORDER_SPL_AMT || '억</span>&nbsp;</td>';
    v_message := v_message || '</tr>';
  --수주-샘플 끝
  
  --수주-총계
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td colspan=2 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>총 계</b></span></td>';                      
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_ORDER_LM_TOTAL_AMT || '억</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_ORDER_PL_AMT || '억</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_ORDER_TOTAL_AMT || '억</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_ORDER_TOTAL_MM || '</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DORDER_TOTAL_AMT  || '억</b></span>&nbsp;</td>';
    v_message := v_message || '</tr>';
   
  --수주-총계 끝

    v_message := v_message || '</tr>';
  --수주 끝-
  
  --투입
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td rowspan=3 width=75 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>투 입</b></span></td>';
    
 --투입-양산 
    v_message := v_message || '<td colspan=2 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>양 산</b></span></td>';                      
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_START_LM_AMT || '억</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_START_PL_FG_AMT || '억</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_START_AMT || '억</span>&nbsp;</td>';
 
 --투입-누적실적 %계     
    v_message := v_message || '<td rowspan=3 align=right valign=bottom>';
    v_message := v_message || '<span style=font-size:8pt;>' || v_START_PER || '%</span>&nbsp;</td>';
 --투입-누적실적 %계 끝
 
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_START_MM || '</span>&nbsp;</td>';  
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DSTART_AMT || '억</span>&nbsp;</td>';  
  --투입-양산 끝   
    
  --투입-샘플
    v_message := v_message || '<tr height=25>';   
    v_message := v_message || '<td colspan=2 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>샘 플</b></span></td>'; 
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_START_LM_SPL_AMT || '억</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_START_PL_SMP_AMT || '억</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' ||  v_START_SPL_AMT || '억</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_START_SPL_MM || '</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DSTART_SPL_AMT || '억</span>&nbsp;</td>';  
    v_message := v_message || '</tr>';  
  --투입-샘플 끝 
  
  --투입-총계 
    v_message := v_message || '<tr height=25>';   
    v_message := v_message || '<td colspan=2 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>총 계</b></span></td>'; 
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_START_LM_TOTAL_AMT || '억</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_START_PL_AMT || '억</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_START_TOTAL_AMT  || '억</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_START_TOTAL_MM || '</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DSTART_TOTAL_AMT || '억</b></span>&nbsp;</td>';  
    v_message := v_message || '</tr>';
  --투입-총계 끝
    v_message := v_message || '</tr>';
  --투입 끝
  
 --생산-IFC
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td rowspan=5 width=75 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>생 산</b></span></td>';
    v_message := v_message || '<td rowspan=3 width=35 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>IFC</b></span></td>';
    
 --생산-양산   
    v_message := v_message || '<td align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>양 산</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_WIP_LM_AMT || '억</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_WIP_PL_FG_AMT || '억</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_IWIP_AMT || '억</span>&nbsp;</td>';
 
  --생산-누적실적 총계%
    v_message := v_message || '<td rowspan=5 align=right valign=bottom>';
    v_message := v_message || '<span style=font-size:8pt;>' || v_WIP_PER || '%</span>&nbsp;</td>';
 --생산-누적실적 총계% 끝
 
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_IWIP_MM || '</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DIWIP_AMT || '억</span>&nbsp;</td>';
 --생산-양산 끝
 
 --생산-샘플
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>샘 플</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_WIP_LM_SPL_AMT || '억</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_WIP_PL_SMP_AMT || '억</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_WIP_SPL_AMT || '억</span>&nbsp;</td>'; 
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_WIP_SPL_MM  || '</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DWIP_SPL_AMT || '억</span>&nbsp;</td>'; 
    v_message := v_message || '</tr>';
 --생산-샘플 끝
 
 --생산-소계   
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>소 계</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_WIP_LM_TOTAL_AMT || '억&nbsp;</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_WIP_PL_AMT || '억&nbsp;</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_WIP_TOTAL_AMT || '억&nbsp;</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_WIP_TOTAL_MM || '&nbsp;</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DWIP_TOTAL_AMT || '억&nbsp;</b></span></td>';
    v_message := v_message || '</tr>';
  --생산-소계 끝 
    
    
  --생산-CCT
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td colspan=2 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>CCT</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_CWIP_LM_AMT || '억&nbsp;</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_WIP_PL_CCT_AMT || '억&nbsp;</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_CWIP_AMT || '억&nbsp;</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_CWIP_MM || '&nbsp;</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DCWIP_AMT || '억&nbsp;</span></td>';
    v_message := v_message || '</tr>';
  --생산-CCT끝

  --생산-총계
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td colspan=2 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>총 계</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_CWIP_LM_TOTAL_AMT  || '억</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_CWIP_PL_TOTAL_AMT  || '억</b></span>&nbsp;</td>';    
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_CWIP_TOTAL_AMT || '억</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_CWIP_TOTAL_MM || '</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_CDWIP_TOTAL_AMT || '억</b></span>&nbsp;</td>';
    v_message := v_message || '</tr>';

  --생산-총계 끝
  
    v_message := v_message || '</tr>';
  --생산  끝-
  
  --출하-양산
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td rowspan=5 width=75 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>출 하</b></span></td>';
    v_message := v_message || '<td rowspan=3 width=35 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>양 산</b></span></td>';

  --출하-제품
    v_message := v_message || '<td align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>제 품</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DEL_LM_FG_AMT || '억</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DEL_PL_FG_AMT || '억</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DELIVERY_FG_AMT || '억</span>&nbsp;</td>';
  
  --출하-누적실적 계% 
    v_message := v_message || '<td rowspan=5 align=right valign=bottom>';
    v_message := v_message || '<span style=font-size:8pt;>' || v_DEL_PER || '%</span>&nbsp;</td>';
  --출하-누적실적 계 끝%
 

    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DELIVERY_FG_MM || '</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DDEL_FG_AMT || '억</span>&nbsp;</td>';
  --출하-제품-끝

  --출하-상품
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>상 품</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DEL_LM_P_AMT || '억</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DEL_PL_P_AMT || '억</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DELIVERY_P_AMT || '억</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DELIVERY_P_MM || '</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DDEL_P_AMT || '억</span>&nbsp;</td>';
    v_message := v_message || '</tr>';
  --출하-상품 끝
   
  --출하-소계
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>소 계</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DEL_LM_AMT || '억</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DEL_PL_AMT || '억</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DEL_AMT || '억</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DEL_MM || '</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DDEL_AMT || '억</b></span>&nbsp;</td>';
    v_message := v_message || '</tr>';
    
  --출하-소계 끝
  
  --출하-샘플
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td colspan=2 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>샘 플</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DEL_LM_SPL_AMT || '억</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DELIVERY_SPL_AMT || '억</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DELIVERY_SPL_MM || '</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DDEL_SPL_AMT || '억</span>&nbsp;</td>';
    v_message := v_message || '</tr>';
  --출하-샘플 끝

  --출하 총계
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td colspan=2 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>총 계</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DEL_LM_TOTAL_AMT || '억</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DEL_PL_AMT || '억</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DELIVERY_TOTAL_AMT || '억</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DELIVERY_TOTAL_MM  || '</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DDEL_TOTAL_AMT || '억</b></span>&nbsp;</td>';
    v_message := v_message || '</tr>';

 --출하 총계 끝
    
    v_message := v_message || '</tr>';
  --출하 끝
  
    v_message := v_message || '</table><br>';
  --표 끝

  --하단
    v_message := v_message || '<table width=600 align=center cellspacing=0 cellpadding=0 border=0>';
    v_message := v_message || '<tr height=30>';
  
  --첨부(일일지표)
   -- v_message := v_message || '<td width=600 valign=middle align=left><span style=font-size:11pt;><b>첨부 : <a target=_blank href=' || v_url || '> <font color=blue>' || v_month1 || ' 일일 지표</font></a></b></span></td>';

    v_message := v_message || '<td width=600 valign=top align=left><span style=font-size:8pt;><b>첨부 : <a target=_blank href=' || v_url || '> <font color=black>' || v_month1 || ' 일일 지표</font></a></b></span></td>';
    
  --첨부(일일지표) 끝
  

  --작성기준
  --v_message := v_message || '<td width=250 valign=bottom align=right>&nbsp;<span style=font-size:8pt;><b>' || v_etc || '</b></span></td>';
  --작성기준 끝
  
    v_message := v_message || '</tr>';  
    v_message := v_message || '</table><br>';
  --하단 끝
  
    v_message := v_message ||'</body>';
    v_message := v_message ||'</html>';     
    


BEGIN
DELETE
FROM    IFC_WEB_MAIL_TEMP;

INSERT INTO IFC_WEB_MAIL_TEMP
(subject,message)
VALUES
(v_subject,v_message);
commit;
END;

END;
/
