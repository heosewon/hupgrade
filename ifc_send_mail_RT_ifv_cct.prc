CREATE OR REPLACE PROCEDURE ifc_send_mail_RT_ifv_cct(
                           Errbuf     OUT VARCHAR2,
                           Retcode    OUT VARCHAR2)
IS

--> 컨커런트 명 : Dally Performence Status Send Mail (ERP)
--> 메일보내는 프로시져 : JOB_SCHEDULE_DAILY_REPORT_IFV_CCT (SPC)


-------------------------------------------------------------------------   IFV -------------------------------------------------------------------------
  --  v_to_name        VARCHAR2(100);
  --  v_to_email       VARCHAR2(100);
  --  v_org_code       VARCHAR2(10);
    v_subject        VARCHAR2(250);
    v_message        LONG;

    v_TITLE_ifv          VARCHAR2(300);
    v_DY_ifv             VARCHAR2(300);
    v_DAY_ifv            NUMBER;
    v_month_ifv          VARCHAR2(30);
    v_month1_ifv         VARCHAR2(30);
 --  v_url_ifv            VARCHAR2(400);
    v_etc_ifv            VARCHAR2(500);



   -- 2021.01.22 경영관리팀 김원재J 요청 - 계획금액 - IFV

    v_ORDER_PL_FG_AMT_ifv    VARCHAR2(100);  --수주계획-제품
    v_ORDER_PL_SPL_AMT_ifv   VARCHAR2(100);  --수주계획-샘플
    v_ORDER_PL_AMT_ifv       VARCHAR2(100);  --수주계획-총계
    v_START_PL_FG_AMT_ifv    VARCHAR2(100);  --투입계획-양산
    v_START_PL_SMP_AMT_ifv   VARCHAR2(100);  --투입계획-샘플
    v_START_PL_AMT_ifv       VARCHAR2(100);  --투입계획-총계
    v_WIP_PL_FG_AMT_ifv      VARCHAR2(100);  --생산계획-양산
    v_WIP_PL_SMP_AMT_ifv     VARCHAR2(100);  --생산계획-샘플
    v_WIP_PL_AMT_ifv         VARCHAR2(100);  --생산계획-총계
    v_DEL_PL_FG_AMT_ifv      VARCHAR2(100);  --출고계획-제품
    v_DEL_PL_SPL_AMT_ifv     VARCHAR2(100);  --출고계획-샘플
    v_DEL_PL_AMT_ifv         VARCHAR2(100);  --출고계획-총계

   -- 일일실적금액, 면적 - IFV

    v_DORDER_FG_AMT_ifv      VARCHAR2(100);  --수주일일실적-제품
    v_DORDER_SPL_AMT_ifv     VARCHAR2(100);  --수주일일실적-샘플
    v_DORDER_TOTAL_AMT_ifv   VARCHAR2(100);  --수주일일실적-총계
    v_DSTART_AMT_ifv         VARCHAR2(100);  --투입일일실적-양산
    v_DSTART_SPL_AMT_ifv     VARCHAR2(100);  --투입일일실적-샘플
    v_DSTART_TOTAL_AMT_ifv   VARCHAR2(100);  --투입일일실적-총계
    v_DWIP_AMT_ifv           VARCHAR2(100);  --생산일일실적-양산
    v_DWIP_SPL_AMT_ifv       VARCHAR2(100);  --생산일일실적-샘플
    v_DWIP_TOTAL_AMT_ifv     VARCHAR2(100);  --생산일일실적-총계
    v_DDEL_FG_AMT_ifv        VARCHAR2(100);  --출하일일실적-제품
    v_DDEL_SPL_AMT_ifv       VARCHAR2(100);  --출하일일실적-샘플
    v_DDEL_TOTAL_AMT_ifv     VARCHAR2(100);  --출하일일실적-총계
    v_ORDER_FG_MM_ifv        VARCHAR2(100);  --수주면적-제품
    v_ORDER_SPL_MM_ifv       VARCHAR2(100);  --수주면적-샘플
    v_ORDER_TOTAL_MM_ifv     VARCHAR2(100);  --수주면적-총계
    v_START_MM_ifv           VARCHAR2(100);  --투입면적-양산
    v_START_SPL_MM_ifv       VARCHAR2(100);  --투입면적-샘플
    v_START_TOTAL_MM_ifv     VARCHAR2(100);  --투입면적-총계
    v_WIP_MM_ifv             VARCHAR2(100);  --생산면적-양산
    v_WIP_SPL_MM_ifv         VARCHAR2(100);  --생산면적-샘플
    v_WIP_TOTAL_MM_ifv       VARCHAR2(100);  --생산면적-총계
    v_DELIVERY_FG_MM_ifv     VARCHAR2(100);  --출고면적-제품
    v_DELIVERY_SPL_MM_ifv    VARCHAR2(100);  --출고면적-샘플
    v_DELIVERY_TOTAL_MM_ifv  VARCHAR2(100);  --출고면적-총계

  -- 전월실적 - IFV

    v_ORDER_LM_FG_AMT_ifv    VARCHAR2(100);    -- 수주 전월실적-제품
    v_ORDER_LM_SPL_AMT_ifv   VARCHAR2(100);    -- 수주 전월실적-샘플
    v_ORDER_LM_TOTAL_AMT_ifv VARCHAR2(100);    -- 수주 전월실적-총계

    v_START_LM_AMT_ifv       VARCHAR2(100);   -- 투입 전월실적-양산
    v_START_LM_SPL_AMT_ifv   VARCHAR2(100);   -- 투입 전월실적-샘플
    v_START_LM_TOTAL_AMT_ifv VARCHAR2(100);   -- 투입 전월실적-총계

    v_WIP_LM_AMT_ifv         VARCHAR2(100);   -- 생산 전월실적-양산
    v_WIP_LM_SPL_AMT_ifv     VARCHAR2(100);   -- 생산 전월실적-샘플
    v_WIP_LM_TOTAL_AMT_ifv   VARCHAR2(100);   -- 생산 전월실적-총계

    v_DEL_LM_FG_AMT_ifv      VARCHAR2(100);    -- 출고 전월실적-제품
    v_DEL_LM_SPL_AMT_ifv     VARCHAR2(100);    -- 츨거 전월실적-샘플
    v_DEL_LM_TOTAL_AMT_ifv   VARCHAR2(100);    -- 출고 전월실적-총계


  -- 누적실적, % - IFV

    v_ORDER_FG_AMT_ifv       VARCHAR2(100);    -- 수주 누적실적 -제품
    v_ORDER_SPL_AMT_ifv      VARCHAR2(100);    -- 수주 누적실적 -샘플
    v_ORDER_TOTAL_AMT_ifv    VARCHAR2(100);    -- 수주 누적실적 -총계

    v_START_AMT_ifv          VARCHAR2(100);   -- 투입 누적실적 -양산
    v_START_SPL_AMT_ifv      VARCHAR2(100);   -- 투입 누적실적 -샘플
    v_START_TOTAL_AMT_ifv    VARCHAR2(100);   -- 투입 누적실적 -총계

    v_WIP_AMT_ifv            VARCHAR2(100);   -- 생산 누적실적-양산
    v_WIP_SPL_AMT_ifv        VARCHAR2(100);   -- 생산 누적실적-샘플
    v_WIP_TOTAL_AMT_ifv      VARCHAR2(100);   -- 생산 누적실적-총계


    v_DELIVERY_FG_AMT_ifv    VARCHAR2(100);   -- 출고 누적실적-제품
    v_DELIVERY_SPL_AMT_ifv   VARCHAR2(100);   -- 출고 누적실적-샘플
    v_DELIVERY_TOTAL_AMT_ifv VARCHAR2(100);   -- 출고 누적실적-총계


    v_ORDER_PER_ifv          VARCHAR2(100);   -- 수주 누적실적  %
    v_START_PER_ifv          VARCHAR2(100);   -- 투입 누적실적  %
    v_WIP_PER_ifv            VARCHAR2(100);   -- 생산 누적실적  %
    v_DEL_PER_ifv            VARCHAR2(100);   -- 출고 누적실적  %

    v_ORDER_PL_AMT1_ifv      VARCHAR2(100);
    v_START_PL_AMT1_ifv      VARCHAR2(100);
    v_WIP_PL_AMT1_ifv        VARCHAR2(100);
    v_DEL_PL_AMT1_ifv        VARCHAR2(100);

    v_ORDER_TOTAL_AMT1_ifv     VARCHAR2(100);
    v_START_TOTAL_AMT1_ifv     VARCHAR2(100);
    v_WIP_TOTAL_AMT1_ifv       VARCHAR2(100);
    v_DELIVERY_TOTAL_AMT1_ifv  VARCHAR2(100);



--7월 1일 CCT 영풍 소속 메일링 X

-------------------------------------------------------------------------   CCT -------------------------------------------------------------------------

/*  --  v_to_name_cct       VARCHAR2(100);
  --  v_to_email_cct      VARCHAR2(100);
  --  v_org_code_cct       VARCHAR2(10);
  --  v_subject       VARCHAR2(250);
  --  v_message        LONG;

    v_TITLE_cct          VARCHAR2(300);
    v_DY_cct             VARCHAR2(300);
    v_DAY_cct            NUMBER;
    v_month_cct          VARCHAR2(30);
    v_month1_cct         VARCHAR2(30);
 --  v_url_cct            VARCHAR2(400);
    v_etc_cct            VARCHAR2(500);


   -- 2021.01.22 경영관리팀 김원재J 요청 - 계획금액 - CCT

    v_ORDER_PL_FG_AMT_cct    VARCHAR2(100);  --수주계획-제품
    v_ORDER_PL_P_AMT_cct     VARCHAR2(100);  --수주계획-상품
    v_ORDER_PL_AMT_cct       VARCHAR2(100);  --수주계획-총계
    v_START_PL_FG_AMT_cct    VARCHAR2(100);  --투입계획-양산
    v_START_PL_SMP_AMT_cct   VARCHAR2(100);  --투입계획-샘플
    v_START_PL_AMT_cct       VARCHAR2(100);  --투입계획-총계
    v_WIP_PL_FG_AMT_cct      VARCHAR2(100);  --생산계획-양산
    v_WIP_PL_SMP_AMT_cct     VARCHAR2(100);  --생산계획-샘플
    v_WIP_PL_AMT_cct         VARCHAR2(100);  --생산계획-총계
    v_DEL_PL_FG_AMT_cct      VARCHAR2(100);  --출고계획-제품
    v_DEL_PL_P_AMT_cct       VARCHAR2(100);  --출고계획-상품
    v_DEL_PL_AMT_cct         VARCHAR2(100);  --출고계획-총계

   -- 일일실적금액, 면적 - CCT

    v_DORDER_FG_AMT_cct      VARCHAR2(100);  --수주일일실적-제품
    v_DORDER_P_AMT_cct        VARCHAR2(100);  --수주일일실적-상품
    v_DORDER_TOTAL_AMT_cct   VARCHAR2(100);  --수주일일실적-총계
    v_DSTART_AMT_cct         VARCHAR2(100);  --투입일일실적-양산
    v_DSTART_SPL_AMT_cct     VARCHAR2(100);  --투입일일실적-샘플
    v_DSTART_TOTAL_AMT_cct   VARCHAR2(100);  --투입일일실적-총계
    v_DWIP_AMT_cct           VARCHAR2(100);  --생산일일실적-양산
    v_DWIP_SPL_AMT_cct       VARCHAR2(100);  --생산일일실적-샘플
    v_DWIP_TOTAL_AMT_cct     VARCHAR2(100);  --생산일일실적-총계
    v_DDEL_FG_AMT_cct        VARCHAR2(100);  --출하일일실적-제품
    v_DDEL_P_AMT_cct         VARCHAR2(100);  --출하일일실적-상품
    v_DDEL_TOTAL_AMT_cct     VARCHAR2(100);  --출하일일실적-총계
    v_ORDER_FG_MM_cct        VARCHAR2(100);  --수주면적-제품
    v_ORDER_P_MM_cct         VARCHAR2(100);  --수주면적-상품
    v_ORDER_TOTAL_MM_cct     VARCHAR2(100);  --수주면적-총계
    v_START_MM_cct           VARCHAR2(100);  --투입면적-양산
    v_START_SPL_MM_cct       VARCHAR2(100);  --투입면적-샘플
    v_START_TOTAL_MM_cct     VARCHAR2(100);  --투입면적-총계
    v_WIP_MM_cct             VARCHAR2(100);  --생산면적-양산
    v_WIP_SPL_MM_cct         VARCHAR2(100);  --생산면적-샘플
    v_WIP_TOTAL_MM_cct       VARCHAR2(100);  --생산면적-총계
    v_DELIVERY_FG_MM_cct     VARCHAR2(100);  --출고면적-제품
    v_DELIVERY_P_MM_cct      VARCHAR2(100);  --출고면적-상품
    v_DELIVERY_TOTAL_MM_cct  VARCHAR2(100);  --출고면적-총계

  -- 전월실적 - CCT

    v_ORDER_LM_FG_AMT_cct    VARCHAR2(100);    -- 수주 전월실적-제품
    v_ORDER_LM_P_AMT_cct     VARCHAR2(100);    -- 수주 전월실적-상품
    v_ORDER_LM_TOTAL_AMT_cct VARCHAR2(100);    -- 수주 전월실적-총계

    v_START_LM_AMT_cct       VARCHAR2(100);   -- 투입 전월실적-양산
    v_START_LM_SPL_AMT_cct   VARCHAR2(100);   -- 투입 전월실적-샘플
    v_START_LM_TOTAL_AMT_cct VARCHAR2(100);   -- 투입 전월실적-총계

    v_WIP_LM_AMT_cct         VARCHAR2(100);   -- 생산 전월실적-양산
    v_WIP_LM_SPL_AMT_cct     VARCHAR2(100);   -- 생산 전월실적-샘플
    v_WIP_LM_TOTAL_AMT_cct   VARCHAR2(100);   -- 생산 전월실적-총계

    v_DEL_LM_FG_AMT_cct      VARCHAR2(100);    -- 출고 전월실적-제품
    v_DEL_LM_P_AMT_cct       VARCHAR2(100);    -- 츨거 전월실적-상품
    v_DEL_LM_TOTAL_AMT_cct   VARCHAR2(100);    -- 출고 전월실적-총계


  -- 누적실적, % - CCT

    v_ORDER_FG_AMT_cct       VARCHAR2(100);    -- 수주 누적실적 -제품
    v_ORDER_P_AMT_cct        VARCHAR2(100);    -- 수주 누적실적 -상품
    v_ORDER_TOTAL_AMT_cct    VARCHAR2(100);    -- 수주 누적실적 -총계

    v_START_AMT_cct          VARCHAR2(100);   -- 투입 누적실적 -양산
    v_START_SPL_AMT_cct      VARCHAR2(100);   -- 투입 누적실적 -샘플
    v_START_TOTAL_AMT_cct    VARCHAR2(100);   -- 투입 누적실적 -총계

    v_WIP_AMT_cct            VARCHAR2(100);   -- 생산 누적실적-양산
    v_WIP_SPL_AMT_cct        VARCHAR2(100);   -- 생산 누적실적-샘플
    v_WIP_TOTAL_AMT_cct      VARCHAR2(100);   -- 생산 누적실적-총계


    v_DELIVERY_FG_AMT_cct    VARCHAR2(100);   -- 출고 누적실적-제품
    v_DELIVERY_P_AMT_cct     VARCHAR2(100);   -- 출고 누적실적-상품
    v_DELIVERY_TOTAL_AMT_cct VARCHAR2(100);   -- 출고 누적실적-총계


    v_ORDER_PER_cct          VARCHAR2(100);   -- 수주 누적실적  %
    v_START_PER_cct          VARCHAR2(100);   -- 투입 누적실적  %
    v_WIP_PER_cct            VARCHAR2(100);   -- 생산 누적실적  %
    v_DEL_PER_cct            VARCHAR2(100);   -- 출고 누적실적  %

    v_ORDER_PL_AMT1_cct      VARCHAR2(100);
    v_START_PL_AMT1_cct      VARCHAR2(100);
    v_WIP_PL_AMT1_cct        VARCHAR2(100);
    v_DEL_PL_AMT1_cct        VARCHAR2(100);

    v_ORDER_TOTAL_AMT1_cct     VARCHAR2(100);
    v_START_TOTAL_AMT1_cct     VARCHAR2(100);
    v_WIP_TOTAL_AMT1_cct       VARCHAR2(100);
    v_DELIVERY_TOTAL_AMT1_cct  VARCHAR2(100);*/



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
       AND pb.concurrent_program_name = 'IFCEISC0064'
       AND r.request_id              != FND_GLOBAL.Conc_Request_ID;

    --중복 실행 방지
    IF (V_Run_Count > 0) THEN
        fnd_file.put_line (fnd_file.log, '배치 프로그램이 이미 실행중입니다.');
        dbms_output.put_line('배치 프로그램이 이미 실행중입니다.');
        Return;
    END IF;

-------------------------------------------------------------------------  IFV -------------------------------------------------------------------------

  BEGIN
    SELECT REPLACE(TO_CHAR(ROUND(PM.order_pl_fg_amt/1000),'999,999,999'),' ','')      --수주계획-제품
    ,      REPLACE(TO_CHAR(ROUND(PM.order_PL_spl_amt/1000),'999,999,999'),' ','')     --수주계획-샘플
    ,      REPLACE(TO_CHAR(ROUND(PM.order_pl_amt/1000),'999,999,999'),' ','')         --수주계획-총계

    ,      REPLACE(TO_CHAR(ROUND(PM.start_pl_fg_amt/1000),'999,999,999'),' ','')      --투입계획-양산
    ,      REPLACE(TO_CHAR(ROUND(PM.start_pl_smp_amt/1000),'999,999,999'),' ','')     --투입계획-샘플
    ,      REPLACE(TO_CHAR(ROUND(PM.start_pl_amt/1000),'999,999,999'),' ','')         --투입계획-총계

    ,      REPLACE(TO_CHAR(ROUND(PM.wip_pl_fg_amt/1000),'999,999,999'),' ','')        --생산계획-양산
    ,      REPLACE(TO_CHAR(ROUND(PM.wip_pl_smp_amt/1000),'999,999,999'),' ','')       --생산계획-샘플
    ,      REPLACE(TO_CHAR(ROUND(PM.wip_pl_amt/1000),'999,999,999'),' ','')           --생산계획-총계

    ,      REPLACE(TO_CHAR(ROUND(PM.del_pl_fg_amt/1000),'999,999,999'),' ','')        --출하계획-제품
    ,      REPLACE(TO_CHAR(ROUND(PM.del_pl_spl_amt/1000),'999,999,999'),' ','')       --출하계획-샘플
    ,      REPLACE(TO_CHAR(ROUND(PM.del_pl_amt/1000),'999,999,999'),' ','')           --출하계획-총계

    --,      ROUND(PM.ORDER_PL_AMT/1000)
    --,      ROUND(PM.START_PL_AMT/1000)
    --,      ROUND(PM.WIP_PL_AMT/1000)
    --,      ROUND(PM.DEL_PL_AMT/1000)
    --,      ROUND(TO_NUMBER(TO_CHAR(SYSDATE -1 - 8.5/24,'DD'))/ TO_NUMBER(TO_CHAR(last_day(sysdate -1 - 8.5/24),'DD')) * 100) as CNT1
    
    -- IFV 4월 계획 등록 안함 -> 분모 0 방지 
    ,      DECODE(ROUND(PM.ORDER_PL_AMT/1000),0,'1',ROUND(PM.ORDER_PL_AMT/1000))
    ,      DECODE(ROUND(PM.START_PL_AMT/1000),0,'1',ROUND(PM.START_PL_AMT/1000))
    ,      DECODE(ROUND(PM.WIP_PL_AMT/1000),0,'1',ROUND(PM.WIP_PL_AMT/1000))
    ,      DECODE(ROUND(PM.DEL_PL_AMT/1000),0,'1',ROUND(PM.DEL_PL_AMT/1000))
    ,      ROUND(TO_NUMBER(TO_CHAR(SYSDATE -1 - 8.5/24,'DD'))/ TO_NUMBER(TO_CHAR(last_day(sysdate -1 - 8.5/24),'DD')) * 100) as CNT1

    INTO   v_ORDER_PL_FG_AMT_ifv
    ,      v_ORDER_PL_SPL_AMT_ifv
    ,      v_ORDER_PL_AMT_ifv
    ,      v_START_PL_FG_AMT_ifv
    ,      v_START_PL_SMP_AMT_ifv
    ,      v_START_PL_AMT_ifv
    ,      v_WIP_PL_FG_AMT_ifv
    ,      v_WIP_PL_SMP_AMT_ifv
    ,      v_WIP_PL_AMT_ifv
    ,      v_DEL_PL_FG_AMT_ifv
    ,      v_DEL_PL_SPL_AMT_ifv
    ,      v_DEL_PL_AMT_ifv

    ,      v_ORDER_PL_AMT1_ifv
    ,      v_START_PL_AMT1_ifv
    ,      v_WIP_PL_AMT1_ifv
    ,      v_DEL_PL_AMT1_ifv
    ,      v_DAY_ifv
    FROM   IFC_ERP_PLAN_MONTH_IFV PM
    WHERE  1=1
      AND PM.PERIOD_NAME = TO_CHAR(sysdate-1,'YYYY-MM');
  END;

  BEGIN
    SELECT   REPLACE(TO_CHAR(ROUND(ESD.dorder_fg_amt/1000), '999,999,999'),' ','')         --수주일일실적-제품
     ,       REPLACE(TO_CHAR(ROUND(ESD.dorder_spl_amt/1000), '999,999,999'),' ','')        --수주일일실적-샘플
     ,       REPLACE(TO_CHAR(ROUND(ESD.dorder_total_amt/1000), '999,999,999'),' ','')      --수주일일실적-총계

     ,       REPLACE(TO_CHAR(ROUND(ESD.dstart_amt/1000), '999,999,999'),' ','')            --투입일일실적-양산
     ,       REPLACE(TO_CHAR(ROUND(ESD.dstart_spl_amt/1000), '999,999,999'),' ','')        --투입일일실적-샘플
     ,       REPLACE(TO_CHAR(ROUND(ESD.dstart_total_amt/1000), '999,999,999'),' ','')      --투입일일실적-총계

     ,       REPLACE(TO_CHAR(ROUND(ESD.dwip_amt/1000), '999,999,999'),' ','')              --생산일일실적-양산
     ,       REPLACE(TO_CHAR(ROUND(ESD.dwip_spl_amt/1000), '999,999,999'),' ','')          --생산일일실적-샘플
     ,       REPLACE(TO_CHAR(ROUND(ESD.dwip_total_amt/1000), '999,999,999'),' ','')        --생산일일실적-총계

     ,       REPLACE(TO_CHAR(ROUND(ESD.ddel_fg_amt/1000), '999,999,999'),' ','')           --출하일일실적-제품
     ,       REPLACE(TO_CHAR(ROUND(ESD.ddel_spl_amt/1000), '999,999,999'),' ','')          --출하일일실적-샘플
     ,       REPLACE(TO_CHAR(ROUND(ESD.ddel_total_amt/1000), '999,999,999'),' ','')        --출하일일실적-총계


     INTO    v_DORDER_FG_AMT_ifv
     ,       v_DORDER_SPL_AMT_ifv
     ,       v_DORDER_TOTAL_AMT_ifv
     ,       v_DSTART_AMT_ifv
     ,       v_DSTART_SPL_AMT_ifv
     ,       v_DSTART_TOTAL_AMT_ifv
     ,       v_DWIP_AMT_ifv
     ,       v_DWIP_SPL_AMT_ifv
     ,       v_DWIP_TOTAL_AMT_ifv
     ,       v_DDEL_FG_AMT_ifv
     ,       v_DDEL_SPL_AMT_ifv
     ,       v_DDEL_TOTAL_AMT_ifv
     FROM IFC_EIS_SUMMARY_DAILY_IFV ESD
     WHERE 1=1
     AND TO_CHAR(ESD.FIND_DATE,'YYYY-MM-DD') = TO_CHAR(sysdate -1 - 8.5/24,'YYYY-MM-DD');
  END;

  BEGIN
    SELECT   REPLACE(TO_CHAR(ROUND(SUM(ESD.order_fg_mm)), '999,999,999'),' ','')          --수주면적-제품
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.order_spl_mm)), '999,999,999'),' ','')         --수주면적-샘플
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.order_total_mm)), '999,999,999'),' ','')       --수주면적-총계
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.start_mm)), '999,999,999'),' ','')             --투입면적-양산
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.start_spl_mm)), '999,999,999'),' ','')         --투입면적-샘플
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.start_total_mm)), '999,999,999'),' ','')       --투입면적-총계
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.wip_mm)), '999,999,999'),' ','')               --생산면적-양산
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.wip_spl_mm)), '999,999,999'),' ','')           --생산면적-샘플
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.wip_total_mm)), '999,999,999'),' ','')         --생산면적-총계
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.delivery_fg_mm)), '999,999,999'),' ','')       --출하면적-제품
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.delivery_spl_mm)), '999,999,999'),' ','')      --출하면적-샘플
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.delivery_total_mm)), '999,999,999'),' ','')    --출하면적-총계
     
     INTO    v_ORDER_FG_MM_ifv
     ,       v_ORDER_SPL_MM_ifv
     ,       v_ORDER_TOTAL_MM_ifv
     ,       v_START_MM_ifv
     ,       v_START_SPL_MM_ifv
     ,       v_START_TOTAL_MM_ifv
     ,       v_WIP_MM_ifv
     ,       v_WIP_SPL_MM_ifv
     ,       v_WIP_TOTAL_MM_ifv
     ,       v_DELIVERY_FG_MM_ifv
     ,       v_DELIVERY_SPL_MM_ifv
     ,       v_DELIVERY_TOTAL_MM_ifv

     FROM IFC_EIS_SUMMARY_DAILY_IFV ESD
     WHERE 1=1
     AND  TO_CHAR(ESD.FIND_DATE,'YYYY-MM') = TO_CHAR(sysdate -1 - 8.5/24,'YYYY-MM');
   END;

   BEGIN
    SELECT   REPLACE(TO_CHAR(ROUND(SUM(ESD.dorder_fg_amt/1000)), '999,999,999'),' ','')       --수주누적실적-제품
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.dorder_spl_amt/1000)), '999,999,999'),' ','')      --수주누적실적-샘플
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.dorder_total_amt/1000)), '999,999,999'),' ','')    --수주누적실적-총계

     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.dstart_amt/1000)), '999,999,999'),' ','')          --투입누적실적-양산
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.dstart_spl_amt/1000)), '999,999,999'),' ','')      --투입누적실적-샘플
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.dstart_total_amt/1000)), '999,999,999'),' ','')    --투입누적실적-총계

     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.dwip_amt/1000)), '999,999,999'),' ','')            --생산누적실적-양산
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.dwip_spl_amt/1000)), '999,999,999'),' ','')        --생산누적실적-샘플
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.dwip_total_amt/1000)), '999,999,999'),' ','')      --생산누적실적-총계

     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.ddel_fg_amt/1000)), '999,999,999'),' ','')         --출하누적실적-제품
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.ddel_spl_amt/1000)), '999,999,999'),' ','')        --출하누적실적-샘플
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.ddel_total_amt/1000)), '999,999,999'),' ','')      --출하누적실적-총계

     ,       ROUND(SUM(ESD.dorder_total_amt/1000))
     ,       ROUND(SUM(ESD.dstart_total_amt/1000))
     ,       ROUND(SUM(ESD.dwip_total_amt/1000))
     ,       ROUND(SUM(ESD.ddel_total_amt/1000))



     INTO    v_ORDER_FG_AMT_ifv
     ,       v_ORDER_SPL_AMT_ifv
     ,       v_ORDER_TOTAL_AMT_ifv
     ,       v_START_AMT_ifv
     ,       v_START_SPL_AMT_ifv
     ,       v_START_TOTAL_AMT_ifv
     ,       v_WIP_AMT_ifv
     ,       v_WIP_SPL_AMT_ifv
     ,       v_WIP_TOTAL_AMT_ifv
     ,       v_DELIVERY_FG_AMT_ifv
     ,       v_DELIVERY_SPL_AMT_ifv
     ,       v_DELIVERY_TOTAL_AMT_ifv

     ,       v_ORDER_TOTAL_AMT1_ifv
     ,       v_START_TOTAL_AMT1_ifv
     ,       v_WIP_TOTAL_AMT1_ifv
     ,       v_DELIVERY_TOTAL_AMT1_ifv

     FROM IFC_EIS_SUMMARY_DAILY_IFV ESD
     WHERE 1=1
     AND  TO_CHAR(ESD.FIND_DATE,'YYYY-MM') = TO_CHAR(sysdate -1 - 8.5/24,'YYYY-MM');
   END;

  BEGIN
   SELECT    REPLACE(TO_CHAR(SUM(ROUND(ESD.dorder_fg_amt/1000)), '999,999,999'),' ','')       --수주전월실적-제품
     ,       REPLACE(TO_CHAR(SUM(ROUND(ESD.dorder_spl_amt/1000)), '999,999,999'),' ','')      --수주전월실적-샘플
     ,       REPLACE(TO_CHAR(SUM(ROUND(ESD.dorder_total_amt/1000)), '999,999,999'),' ','')    --수주전월실적-총계

     ,       REPLACE(TO_CHAR(SUM(ROUND(ESD.dstart_amt/1000)), '999,999,999'),' ','')          --투입전월실적-양산
     ,       REPLACE(TO_CHAR(SUM(ROUND(ESD.dstart_spl_amt/1000)), '999,999,999'),' ','')      --투입전월실적-샘플
     ,       REPLACE(TO_CHAR(SUM(ROUND(ESD.dstart_total_amt/1000)), '999,999,999'),' ','')    --투입전월실적-총계

     ,       REPLACE(TO_CHAR(SUM(ROUND(ESD.dwip_amt/1000)), '999,999,999'),' ','')            --생산전월실적-양산
     ,       REPLACE(TO_CHAR(SUM(ROUND(ESD.dwip_spl_amt/1000)), '999,999,999'),' ','')        --생산전월실적-샘플
     ,       REPLACE(TO_CHAR(SUM(ROUND(ESD.dwip_total_amt/1000)), '999,999,999'),' ','')      --생산전월실적-총계

     ,       REPLACE(TO_CHAR(SUM(ROUND(ESD.ddel_fg_amt/1000)), '999,999,999'),' ','')         --출하전월실적-제품
     ,       REPLACE(TO_CHAR(SUM(ROUND(ESD.ddel_spl_amt/1000)), '999,999,999'),' ','')        --출하전월실적-샘플
     ,       REPLACE(TO_CHAR(SUM(ROUND(ESD.ddel_total_amt/1000)), '999,999,999'),' ','')      --출하전월실적-총계


     INTO    v_ORDER_LM_FG_AMT_ifv
     ,       v_ORDER_LM_SPL_AMT_ifv
     ,       v_ORDER_LM_TOTAL_AMT_ifv
     ,       v_START_LM_AMT_ifv
     ,       v_START_LM_SPL_AMT_ifv
     ,       v_START_LM_TOTAL_AMT_ifv
     ,       v_WIP_LM_AMT_ifv
     ,       v_WIP_LM_SPL_AMT_ifv
     ,       v_WIP_LM_TOTAL_AMT_ifv
     ,       v_DEL_LM_FG_AMT_ifv
     ,       v_DEL_LM_SPL_AMT_ifv
     ,       v_DEL_LM_TOTAL_AMT_ifv
     FROM IFC_EIS_SUMMARY_DAILY_IFV ESD
     WHERE 1=1
     AND   TO_CHAR(ESD.FIND_DATE,'YYYY-MM') =  TO_CHAR(ADD_MONTHS(sysdate -1 - 8.5/24,-1),'YYYY-MM');
  END;

/*     v_ORDER_LM_FG_AMT      := '$38,402';
     v_ORDER_LM_SPL_AMT     := '$515';
     v_ORDER_LM_TOTAL_AMT   := '$38,918';
     v_START_LM_AMT         := '$88,042';
     v_START_LM_SPL_AMT     := '$4,370';
     v_START_LM_TOTAL_AMT   := '$92,412';
     v_WIP_LM_AMT           := '$41,821';
     v_WIP_LM_SPL_AMT       := '$2,322';
     v_WIP_LM_TOTAL_AMT     := '$44,144';
     v_DEL_LM_FG_AMT        := '$32,046';
     v_DEL_LM_SPL_AMT       := '$1,814';
     v_DEL_LM_TOTAL_AMT     := '$33,860';*/

/*  v_ORDER_PER := REPLACE(TO_CHAR(ROUND(v_ORDER_TOTAL_AMT1     / v_ORDER_PL_AMT1 * 100),'999,999,999'),' ','' );
  v_START_PER := REPLACE(TO_CHAR(ROUND(v_START_TOTAL_AMT1     / v_START_PL_AMT1 * 100),'999,999,999'),' ','' );
  v_WIP_PER   := REPLACE(TO_CHAR(ROUND(v_WIP_TOTAL_AMT1       / v_WIP_PL_AMT1 * 100),'999,999,999'),' ','' );
  v_DEL_PER   := REPLACE(TO_CHAR(ROUND(v_DELIVERY_TOTAL_AMT1  / v_DEL_PL_AMT1 * 100), '999,999,999'),' ','');*/


  v_ORDER_PER_ifv := REPLACE(ROUND(v_ORDER_TOTAL_AMT1_ifv     / v_ORDER_PL_AMT1_ifv * 100),' ','' );
  v_START_PER_ifv := REPLACE(ROUND(v_START_TOTAL_AMT1_ifv     / v_START_PL_AMT1_ifv * 100),' ','' );
  v_WIP_PER_ifv   := REPLACE(ROUND(v_WIP_TOTAL_AMT1_ifv       / v_WIP_PL_AMT1_ifv * 100),' ','' );
  v_DEL_PER_ifv   := REPLACE(ROUND(v_DELIVERY_TOTAL_AMT1_ifv  / v_DEL_PL_AMT1_ifv * 100),' ','');
  


  --v_month_ifv      := TO_CHAR(SYSDATE,'YYYY-MM');
  --v_url_ifv       := 'http://erp.interflex.co.kr/ifc/rdCommon.asp?mrdPath=http://erp.interflex.co.kr/MRD/ifc_scm/ifcomr0222.mrd';
 -- v_url_ifv       := 'http://erp.interflex.co.kr/ifc_scm/ifcomr0002.mrd&rdParam=/rp[PLAN][ALL][' || v_month || ']';
  v_TITLE_ifv      :='[' || TO_CHAR(sysdate -1 - 8.5/24,'YY') ||'年 ' || TO_CHAR(sysdate -1 - 8.5/24,'MM')  ||'月 목표 대비 누적 실적 현황-IFV ]';
  v_DY_ifv         :='※ 일수진척률:' || v_DAY_ifv ||'%';
  v_month1_ifv      := TO_CHAR(SYSDATE -1 - 8.5/24,'MM') || '월';
  v_subject :='[IFV-일일 실적 보고] ' || TO_CHAR(SYSDATE -1 - 8.5/24,'MM') ||'月 보고 드립니다';
  --v_etc_ifv := '[작성기준]' ||'<br>'||'* 실적 : 양산 기준'||'<br>'||'* 투입,생산 : 제품 기준';


--7월 1일 CCT 영풍 소속 메일링 X
-------------------------------------------------------------------------  CCT -------------------------------------------------------------------------

/*
BEGIN
    SELECT REPLACE(TO_CHAR(ROUND(PM.order_pl_fg_amt),'999,999,999'),' ','')      --수주계획-제품
    ,      REPLACE(TO_CHAR(ROUND(PM.order_PL_p_amt),'999,999,999'),' ','')       --수주계획-상품
    ,      REPLACE(TO_CHAR(ROUND(PM.order_pl_amt),'999,999,999'),' ','')         --수주계획-총계

    ,      REPLACE(TO_CHAR(ROUND(PM.start_pl_fg_amt),'999,999,999'),' ','')      --투입계획-양산
    ,      REPLACE(TO_CHAR(ROUND(PM.start_pl_smp_amt),'999,999,999'),' ','')     --투입계획-샘플
    ,      REPLACE(TO_CHAR(ROUND(PM.start_pl_amt),'999,999,999'),' ','')         --투입계획-총계

    ,      REPLACE(TO_CHAR(ROUND(PM.wip_pl_fg_amt),'999,999,999'),' ','')        --생산계획-양산
    ,      REPLACE(TO_CHAR(ROUND(PM.wip_pl_smp_amt),'999,999,999'),' ','')       --생산계획-샘플
    ,      REPLACE(TO_CHAR(ROUND(PM.wip_pl_amt),'999,999,999'),' ','')           --생산계획-총계

    ,      REPLACE(TO_CHAR(ROUND(PM.del_pl_fg_amt),'999,999,999'),' ','')        --출하계획-제품
    ,      REPLACE(TO_CHAR(ROUND(PM.del_pl_p_amt),'999,999,999'),' ','')         --출하계획-상품
    ,      REPLACE(TO_CHAR(ROUND(PM.del_pl_amt),'999,999,999'),' ','')           --출하계획-총계

    ,      ROUND(PM.ORDER_PL_AMT)
    ,      ROUND(PM.START_PL_AMT)
    ,      ROUND(PM.WIP_PL_AMT)
    ,      ROUND(PM.DEL_PL_AMT)
    ,      ROUND(TO_NUMBER(TO_CHAR(SYSDATE -1 - 8.5/24,'DD'))/ TO_NUMBER(TO_CHAR(last_day(sysdate -1 - 8.5/24),'DD')) * 100) as CNT1

    INTO   v_ORDER_PL_FG_AMT_cct
    ,      v_ORDER_PL_P_AMT_cct
    ,      v_ORDER_PL_AMT_cct
    ,      v_START_PL_FG_AMT_cct
    ,      v_START_PL_SMP_AMT_cct
    ,      v_START_PL_AMT_cct
    ,      v_WIP_PL_FG_AMT_cct
    ,      v_WIP_PL_SMP_AMT_cct
    ,      v_WIP_PL_AMT_cct
    ,      v_DEL_PL_FG_AMT_cct
    ,      v_DEL_PL_P_AMT_cct
    ,      v_DEL_PL_AMT_cct

    ,      v_ORDER_PL_AMT1_cct
    ,      v_START_PL_AMT1_cct
    ,      v_WIP_PL_AMT1_cct
    ,      v_DEL_PL_AMT1_cct
    ,      v_DAY_cct
    FROM   IFC_ERP_PLAN_MONTH_CCT PM
    WHERE  1=1
      AND PM.PERIOD_NAME = TO_CHAR(sysdate-1,'YYYY-MM');
  END;

  BEGIN
     SELECT  REPLACE(TO_CHAR(ROUND(ESD.dorder_fg_amt), '999,999,999'),' ','')         --수주일일실적-제품
     ,       REPLACE(TO_CHAR(ROUND(ESD.dorder_p_amt), '999,999,999'),' ','')          --수주일일실적-상품
     ,       REPLACE(TO_CHAR(ROUND(ESD.dorder_total_amt), '999,999,999'),' ','')      --수주일일실적-총계

     ,       REPLACE(TO_CHAR(ROUND(ESD.dstart_amt), '999,999,999'),' ','')            --투입일일실적-양산
     ,       REPLACE(TO_CHAR(ROUND(ESD.dstart_spl_amt), '999,999,999'),' ','')        --투입일일실적-샘플
     ,       REPLACE(TO_CHAR(ROUND(ESD.dstart_total_amt), '999,999,999'),' ','')      --투입일일실적-총계

     ,       REPLACE(TO_CHAR(ROUND(ESD.dwip_amt), '999,999,999'),' ','')              --생산일일실적-양산
     ,       REPLACE(TO_CHAR(ROUND(ESD.dwip_spl_amt), '999,999,999'),' ','')          --생산일일실적-샘플
     ,       REPLACE(TO_CHAR(ROUND(ESD.dwip_total_amt), '999,999,999'),' ','')        --생산일일실적-총계

     ,       REPLACE(TO_CHAR(ROUND(ESD.ddel_fg_amt), '999,999,999'),' ','')           --출하일일실적-제품
     ,       REPLACE(TO_CHAR(ROUND(ESD.ddel_p_amt), '999,999,999'),' ','')            --출하일일실적-상품
     ,       REPLACE(TO_CHAR(ROUND(ESD.ddel_total_amt), '999,999,999'),' ','')        --출하일일실적-총계


     INTO    v_DORDER_FG_AMT_cct
     ,       v_DORDER_P_AMT_cct
     ,       v_DORDER_TOTAL_AMT_cct
     ,       v_DSTART_AMT_cct
     ,       v_DSTART_SPL_AMT_cct
     ,       v_DSTART_TOTAL_AMT_cct
     ,       v_DWIP_AMT_cct
     ,       v_DWIP_SPL_AMT_cct
     ,       v_DWIP_TOTAL_AMT_cct
     ,       v_DDEL_FG_AMT_cct
     ,       v_DDEL_P_AMT_cct
     ,       v_DDEL_TOTAL_AMT_cct
     FROM IFC_EIS_SUMMARY_DAILY_CCT ESD
     WHERE 1=1
     AND TO_CHAR(ESD.FIND_DATE,'YYYY-MM-DD') = TO_CHAR(sysdate -1 - 8.5/24,'YYYY-MM-DD');
  END;

  BEGIN
    SELECT   REPLACE(TO_CHAR(ROUND(SUM(ESD.order_fg_mm)), '999,999,999'),' ','')          --수주면적-제품
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.order_p_mm)), '999,999,999'),' ','')           --수주면적-상품
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.order_total_mm)), '999,999,999'),' ','')       --수주면적-총계
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.start_mm)), '999,999,999'),' ','')             --투입면적-양산
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.start_spl_mm)), '999,999,999'),' ','')         --투입면적-샘플
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.start_total_mm)), '999,999,999'),' ','')       --투입면적-총계
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.wip_mm)), '999,999,999'),' ','')               --생산면적-양산
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.wip_spl_mm)), '999,999,999'),' ','')           --생산면적-샘플
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.wip_total_mm)), '999,999,999'),' ','')         --생산면적-총계
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.delivery_fg_mm)), '999,999,999'),' ','')       --출하면적-제품
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.delivery_p_mm)), '999,999,999'),' ','')        --출하면적-상품
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.delivery_total_mm)), '999,999,999'),' ','')    --출하면적-총계


     INTO    v_ORDER_FG_MM_cct
     ,       v_ORDER_P_MM_cct
     ,       v_ORDER_TOTAL_MM_cct
     ,       v_START_MM_cct
     ,       v_START_SPL_MM_cct
     ,       v_START_TOTAL_MM_cct
     ,       v_WIP_MM_cct
     ,       v_WIP_SPL_MM_cct
     ,       v_WIP_TOTAL_MM_cct
     ,       v_DELIVERY_FG_MM_cct
     ,       v_DELIVERY_P_MM_cct
     ,       v_DELIVERY_TOTAL_MM_cct

     FROM IFC_EIS_SUMMARY_DAILY_CCT ESD
     WHERE 1=1
     AND  TO_CHAR(ESD.FIND_DATE,'YYYY-MM') = TO_CHAR(sysdate -1 - 8.5/24,'YYYY-MM');
   END;

   BEGIN
    SELECT   REPLACE(TO_CHAR(ROUND(SUM(ESD.dorder_fg_amt)), '999,999,999'),' ','')       --수주누적실적-제품
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.dorder_p_amt)), '999,999,999'),' ','')        --수주누적실적-상품
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.dorder_total_amt)), '999,999,999'),' ','')    --수주누적실적-총계

     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.dstart_amt)), '999,999,999'),' ','')          --투입누적실적-양산
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.dstart_spl_amt)), '999,999,999'),' ','')      --투입누적실적-샘플
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.dstart_total_amt)), '999,999,999'),' ','')    --투입누적실적-총계

     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.dwip_amt)), '999,999,999'),' ','')            --생산누적실적-양산
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.dwip_spl_amt)), '999,999,999'),' ','')        --생산누적실적-샘플
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.dwip_total_amt)), '999,999,999'),' ','')      --생산누적실적-총계

     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.ddel_fg_amt)), '999,999,999'),' ','')         --출하누적실적-제품
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.ddel_p_amt)), '999,999,999'),' ','')          --출하누적실적-상품
     ,       REPLACE(TO_CHAR(ROUND(SUM(ESD.ddel_total_amt)), '999,999,999'),' ','')      --출하누적실적-총계

     ,       ROUND(SUM(ESD.dorder_total_amt))
     ,       ROUND(SUM(ESD.dstart_total_amt))
     ,       ROUND(SUM(ESD.dwip_total_amt))
     ,       ROUND(SUM(ESD.ddel_total_amt))


     INTO    v_ORDER_FG_AMT_cct
     ,       v_ORDER_P_AMT_cct
     ,       v_ORDER_TOTAL_AMT_cct
     ,       v_START_AMT_cct
     ,       v_START_SPL_AMT_cct
     ,       v_START_TOTAL_AMT_cct
     ,       v_WIP_AMT_cct
     ,       v_WIP_SPL_AMT_cct
     ,       v_WIP_TOTAL_AMT_cct
     ,       v_DELIVERY_FG_AMT_cct
     ,       v_DELIVERY_P_AMT_cct
     ,       v_DELIVERY_TOTAL_AMT_cct

     ,       v_ORDER_TOTAL_AMT1_cct
     ,       v_START_TOTAL_AMT1_cct
     ,       v_WIP_TOTAL_AMT1_cct
     ,       v_DELIVERY_TOTAL_AMT1_cct

     FROM IFC_EIS_SUMMARY_DAILY_CCT ESD
     WHERE 1=1
     AND  TO_CHAR(ESD.FIND_DATE,'YYYY-MM') = TO_CHAR(sysdate -1 - 8.5/24,'YYYY-MM');
   END;

  BEGIN
    SELECT   REPLACE(TO_CHAR(SUM(ROUND(ESD.dorder_fg_amt)), '999,999,999'),' ','')       --수주전월실적-제품
     ,       REPLACE(TO_CHAR(SUM(ROUND(ESD.dorder_p_amt)), '999,999,999'),' ','')        --수주전월실적-상품
     ,       REPLACE(TO_CHAR(SUM(ROUND(ESD.dorder_total_amt)), '999,999,999'),' ','')    --수주전월실적-총계

     ,       REPLACE(TO_CHAR(SUM(ROUND(ESD.dstart_amt)), '999,999,999'),' ','')          --투입전월실적-양산
     ,       REPLACE(TO_CHAR(SUM(ROUND(ESD.dstart_spl_amt)), '999,999,999'),' ','')      --투입전월실적-샘플
     ,       REPLACE(TO_CHAR(SUM(ROUND(ESD.dstart_total_amt)), '999,999,999'),' ','')    --투입전월실적-총계

     ,       REPLACE(TO_CHAR(SUM(ROUND(ESD.dwip_amt)), '999,999,999'),' ','')            --생산전월실적-양산
     ,       REPLACE(TO_CHAR(SUM(ROUND(ESD.dwip_spl_amt)), '999,999,999'),' ','')        --생산전월실적-샘플
     ,       REPLACE(TO_CHAR(SUM(ROUND(ESD.dwip_total_amt)), '999,999,999'),' ','')      --생산전월실적-총계

     ,       REPLACE(TO_CHAR(SUM(ROUND(ESD.ddel_fg_amt)), '999,999,999'),' ','')         --출하전월실적-제품
     ,       REPLACE(TO_CHAR(SUM(ROUND(ESD.ddel_p_amt)), '999,999,999'),' ','')          --출하전월실적-상품
     ,       REPLACE(TO_CHAR(SUM(ROUND(ESD.ddel_total_amt)), '999,999,999'),' ','')      --출하전월실적-총계


     INTO    v_ORDER_LM_FG_AMT_cct
     ,       v_ORDER_LM_P_AMT_cct
     ,       v_ORDER_LM_TOTAL_AMT_cct
     ,       v_START_LM_AMT_cct
     ,       v_START_LM_SPL_AMT_cct
     ,       v_START_LM_TOTAL_AMT_cct
     ,       v_WIP_LM_AMT_cct
     ,       v_WIP_LM_SPL_AMT_cct
     ,       v_WIP_LM_TOTAL_AMT_cct
     ,       v_DEL_LM_FG_AMT_cct
     ,       v_DEL_LM_P_AMT_cct
     ,       v_DEL_LM_TOTAL_AMT_cct
     FROM IFC_EIS_SUMMARY_DAILY_CCT ESD
     WHERE 1=1
     AND   TO_CHAR(ESD.FIND_DATE,'YYYY-MM') =  TO_CHAR(ADD_MONTHS(sysdate -1 - 8.5/24,-1),'YYYY-MM');
  END;


  v_ORDER_PER_cct := REPLACE(ROUND(v_ORDER_TOTAL_AMT1_cct     / v_ORDER_PL_AMT1_cct * 100),' ','' );
  v_START_PER_cct := REPLACE(ROUND(v_START_TOTAL_AMT1_cct     / v_START_PL_AMT1_cct * 100),' ','' );
  v_WIP_PER_cct   := REPLACE(ROUND(v_WIP_TOTAL_AMT1_cct       / v_WIP_PL_AMT1_cct * 100),' ','' );
  v_DEL_PER_cct   := REPLACE(ROUND(v_DELIVERY_TOTAL_AMT1_cct  / v_DEL_PL_AMT1_cct * 100),' ','');




  --v_month_cct      := TO_CHAR(SYSDATE,'YYYY-MM');
  --v_url_cct       := 'http://erp.interflex.co.kr/ifc/rdCommon.asp?mrdPath=http://erp.interflex.co.kr/MRD/ifc_scm/ifcomr0222.mrd';
 -- v_url_cct       := 'http://erp.interflex.co.kr/ifc_scm/ifcomr0002.mrd&rdParam=/rp[PLAN][ALL][' || v_month || ']';
  v_TITLE_cct      :='[' || TO_CHAR(sysdate -1 - 8.5/24,'YY') ||'年 ' || TO_CHAR(sysdate -1 - 8.5/24,'MM')  ||'月 목표 대비 누적 실적 현황-CCT ]';
  v_DY_cct         :='※ 일수진척률:' || v_DAY_cct ||'%';
  v_month1_cct      := TO_CHAR(SYSDATE -1 - 8.5/24,'MM') || '월';
  --v_subject :='[CCT-일일 실적 보고] ' || TO_CHAR(SYSDATE -1 - 8.5/24,'MM') ||'月 보고 드립니다';
  --v_etc_cct := '[작성기준]' ||'<br>'||'* 실적 : 양산 기준'||'<br>'||'* 투입,생산 : 제품 기준';*/

-------------------------------------------------------------------------  IFV -------------------------------------------------------------------------

-- 2021.01.14 경영관리팀 김원재J 요청

    v_message := v_message || '<html>';
    v_message := v_message || '<head>';
    v_message := v_message || '<meta content=text/html; charset=euc-kr http-equiv=Content-Type>';
    v_message := v_message || '</head>';
    v_message := v_message || '<body>';

    --상단
    v_message := v_message || '<br><br><table width=600 align=center cellspacing=0 cellpadding=0 border=0>';

   --타이틀
    v_message := v_message || '<tr height=30>';
    v_message := v_message || '<td colspan=2 width=600 valign=middle align=center bgcolor=#FEE9FA><span style=font-size:10pt;><font color=blue><b>' || v_TITLE_ifv || '</b></font></span></td>';
    v_message := v_message || '</tr>';
   --타이틀 끝

  --일수진척율, 단위
    v_message := v_message || '<tr height=30>';
    v_message := v_message || '<td valign=bottom width=600 align=left><span style=font-size:8pt;><b>' || v_DY_ifv || '</b></span></td>';
    v_message := v_message || '<td valign=bottom width=600 align=right><span style=font-size:8pt;><b>(단위 : KUSD)</b></span></td>';
    v_message := v_message || '</tr>';

  --일수진척율, 단위 끝

    v_message := v_message || '</table>';
   --상단 끝

  --표
    v_message := v_message || '<table align=center width=600 cellspacing=0 cellpadding=0 border=1 bordercolor=#999999>';

  --구분 ~ 일일실적
    v_message := v_message || '<tr height=30>';
    v_message := v_message || '<td colspan=2 align=center bgcolor=#CEE7FF><span style=font-size:9pt;><b>구 분</b></span></td>';
    v_message := v_message || '<td align=center width=70 bgcolor=#CEE7FF><span style=font-size:9pt;><b>전월실적</b></span></td>';
    v_message := v_message || '<td align=center width=70 bgcolor=#CEE7FF><span style=font-size:9pt;><b>목&nbsp;표</b></span></td>';
    v_message := v_message || '<td colspan=2 align=center bgcolor=#E1FDDF><span style=font-size:9pt;><b>누적실적</b></span></td>';
    v_message := v_message || '<td align=center width=70 bgcolor=#E1FDDF><span style=font-size:9pt;><b>면 적(㎡)</b></span></td>';
    v_message := v_message || '<td align=center width=70 bgcolor=#CEE7FF><span style=font-size:9pt;><b>일일실적</b></span></td>';
    v_message := v_message || '</tr>';
  --구분 ~ 일일실적 끝

  --수주-양산
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td rowspan=3 width=75 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>수 주</b></td>';


  --수주-제품
    v_message := v_message || '<td align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>제 품</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_LM_FG_AMT_ifv || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_PL_FG_AMT_ifv || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_FG_AMT_ifv || '</span></td>';

  --수주-누적실적 %계
    v_message := v_message || '<td rowspan=3 align=right valign=bottom>';
    v_message := v_message || '<span style=font-size:8pt;>' || v_ORDER_PER_ifv || '%</span></td>';
  --수주-누적실적 %계 끝

    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_FG_MM_ifv || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DORDER_FG_AMT_ifv || '</span></td>';
  --수주-제품 끝

  --수주-샘플
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td colspan=1 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>샘 플</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_LM_SPL_AMT_ifv || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_PL_SPL_AMT_ifv || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_SPL_AMT_ifv || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_SPL_MM_ifv || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DORDER_SPL_AMT_ifv || '</span></td>';
    v_message := v_message || '</tr>';
  --수주-샘플 끝

  --수주-총계
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td colspan=1 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>총 계</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_ORDER_LM_TOTAL_AMT_ifv || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_ORDER_PL_AMT_ifv || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_ORDER_TOTAL_AMT_ifv || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_ORDER_TOTAL_MM_ifv || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DORDER_TOTAL_AMT_ifv  || '</b></span></td>';
    v_message := v_message || '</tr>';

  --수주-총계 끝

    v_message := v_message || '</tr>';
  --수주 끝-

  --투입
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td rowspan=3 width=75 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>투 입</b></span></td>';

 --투입-양산
    v_message := v_message || '<td colspan=1 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>양 산</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_START_LM_AMT_ifv || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_START_PL_FG_AMT_ifv || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_START_AMT_ifv || '</span></td>';

 --투입-누적실적 %계
    v_message := v_message || '<td rowspan=3 align=right valign=bottom>';
    v_message := v_message || '<span style=font-size:8pt;>' || v_START_PER_ifv || '%</span></td>';
 --투입-누적실적 %계 끝

    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_START_MM_ifv || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DSTART_AMT_ifv || '</span></td>';
  --투입-양산 끝

  --투입-샘플
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td colspan=1 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>샘 플</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_START_LM_SPL_AMT_ifv || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_START_PL_SMP_AMT_ifv || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' ||  v_START_SPL_AMT_ifv || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_START_SPL_MM_ifv || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DSTART_SPL_AMT_ifv || '</span></td>';
    v_message := v_message || '</tr>';
  --투입-샘플 끝

  --투입-총계
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td colspan=1 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>총 계</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_START_LM_TOTAL_AMT_ifv || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_START_PL_AMT_ifv || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_START_TOTAL_AMT_ifv  || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_START_TOTAL_MM_ifv || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DSTART_TOTAL_AMT_ifv || '</b></span></td>';
    v_message := v_message || '</tr>';
  --투입-총계 끝
    v_message := v_message || '</tr>';
  --투입 끝

 --생산-
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td rowspan=3 width=75 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>생 산</b></span></td>';

 --생산-양산
    v_message := v_message || '<td align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>양 산</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_WIP_LM_AMT_ifv || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_WIP_PL_FG_AMT_ifv || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_WIP_AMT_ifv || '</span></td>';

  --생산-누적실적 총계%
    v_message := v_message || '<td rowspan=3 align=right valign=bottom>';
    v_message := v_message || '<span style=font-size:8pt;>' || v_WIP_PER_ifv || '%</span></td>';
 --생산-누적실적 총계% 끝

    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_WIP_MM_ifv || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DWIP_AMT_ifv || '</span></td>';
 --생산-양산 끝

 --생산-샘플
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>샘 플</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_WIP_LM_SPL_AMT_ifv || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_WIP_PL_SMP_AMT_ifv || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_WIP_SPL_AMT_ifv || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_WIP_SPL_MM_ifv  || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DWIP_SPL_AMT_ifv || '</span></td>';
    v_message := v_message || '</tr>';
 --생산-샘플 끝



  --생산-총계
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td colspan=1 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>총 계</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_WIP_LM_TOTAL_AMT_ifv  || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_WIP_PL_AMT_ifv  || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_WIP_TOTAL_AMT_ifv || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_WIP_TOTAL_MM_ifv || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DWIP_TOTAL_AMT_ifv || '</b></span></td>';
    v_message := v_message || '</tr>';

  --생산-총계 끝

    v_message := v_message || '</tr>';
  --생산  끝-

  --출하
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td rowspan=3 width=75 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>출 하</b></span></td>';

  --출하-제품
    v_message := v_message || '<td align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>제 품</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DEL_LM_FG_AMT_ifv || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DEL_PL_FG_AMT_ifv || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DELIVERY_FG_AMT_ifv || '</span></td>';

  --출하-누적실적 계%
    v_message := v_message || '<td rowspan=3 align=right valign=bottom>';
    v_message := v_message || '<span style=font-size:8pt;>' || v_DEL_PER_ifv || '%</span></td>';
  --출하-누적실적 계 끝%


    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DELIVERY_FG_MM_ifv || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DDEL_FG_AMT_ifv || '</span></td>';
  --출하-제품-끝

  --출하-샘플
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td colspan=1 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>샘 플</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DEL_LM_SPL_AMT_ifv || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DEL_PL_SPL_AMT_ifv || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DELIVERY_SPL_AMT_ifv || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DELIVERY_SPL_MM_ifv || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DDEL_SPL_AMT_ifv || '</span></td>';
    v_message := v_message || '</tr>';
  --출하-샘플 끝

  --출하 총계
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td colspan=1 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>총 계</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DEL_LM_TOTAL_AMT_ifv || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DEL_PL_AMT_ifv || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DELIVERY_TOTAL_AMT_ifv || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DELIVERY_TOTAL_MM_ifv  || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DDEL_TOTAL_AMT_ifv || '</b></span></td>';
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
   --v_message := v_message || '<td width=600 valign=middle align=left><span style=font-size:11pt;><b>첨부 : <a target=_blank href=' || v_url_ifv || '> <font color=blue>' || v_month1_ifv || ' 일일 지표</font></a></b></span></td>';

   --v_message := v_message || '<td width=600 valign=top align=left><span style=font-size:8pt;><b>첨부 :  <font color=black>' || v_month1_ifv || ' 일일 지표</font></b></span></td>';
   --<a target=_blank href=' || v_url || '></a>
  --첨부(일일지표) 끝


  --작성기준
  --v_message := v_message || '<td width=250 valign=bottom align=right>;<span style=font-size:8pt;><b>' || v_etc_ifv || '</b></span></td>';
  --작성기준 끝

  v_message := v_message || '</tr>';
  v_message := v_message || '</table><br>';
  --하단 끝


--7월 1일 CCT 영풍 소속 메일링 X

/*-------------------------------------------------------------------------  CCT -------------------------------------------------------------------------

   --상단
    v_message := v_message || '<br><br><table width=600 align=center cellspacing=0 cellpadding=0 border=0>';

   --타이틀
    v_message := v_message || '<tr height=30>';
    v_message := v_message || '<td colspan=2 width=600 valign=middle align=center bgcolor=#FEE9FA><span style=font-size:10pt;><font color=blue><b>' || v_TITLE_cct || '</b></font></span></td>';
    v_message := v_message || '</tr>';
   --타이틀 끝

  --일수진척율
    v_message := v_message || '<tr height=30>';
    v_message := v_message || '<td valign=bottom width=600 align=left><span style=font-size:8pt;><b>' || v_DY_cct || '</b></span></td>';
    v_message := v_message || '<td valign=bottom width=600 align=right><span style=font-size:8pt;><b>(단위 : KUSD)</b></span></td>';
    v_message := v_message || '</tr>';

  --일수진척율 끝

    v_message := v_message || '</table>';
   --상단 끝

  --표
    v_message := v_message || '<table align=center width=600 cellspacing=0 cellpadding=0 border=1 bordercolor=#999999>';

  --구분 ~ 일일실적
    v_message := v_message || '<tr height=30>';
    v_message := v_message || '<td colspan=2 align=center bgcolor=#CEE7FF><span style=font-size:9pt;><b>구 분</b></span></td>';
    v_message := v_message || '<td align=center width=70 bgcolor=#CEE7FF><span style=font-size:9pt;><b>전월실적</b></span></td>';
    v_message := v_message || '<td align=center width=70 bgcolor=#CEE7FF><span style=font-size:9pt;><b>목&nbsp;표</b></span></td>';
    v_message := v_message || '<td colspan=2 align=center bgcolor=#E1FDDF><span style=font-size:9pt;><b>누적실적</b></span></td>';
    v_message := v_message || '<td align=center width=70 bgcolor=#E1FDDF><span style=font-size:9pt;><b>면 적(㎡)</b></span></td>';
    v_message := v_message || '<td align=center width=70 bgcolor=#CEE7FF><span style=font-size:9pt;><b>일일실적</b></span></td>';
    v_message := v_message || '</tr>';
  --구분 ~ 일일실적 끝

  --수주-양산
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td rowspan=3 width=75 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>수 주</b></td>';


  --수주-제품
    v_message := v_message || '<td align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>제 품</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_LM_FG_AMT_cct || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_PL_FG_AMT_cct || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_FG_AMT_cct || '</span></td>';

  --수주-누적실적 %계
    v_message := v_message || '<td rowspan=3 align=right valign=bottom>';
    v_message := v_message || '<span style=font-size:8pt;>' || v_ORDER_PER_cct || '%</span></td>';
  --수주-누적실적 %계 끝

    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_FG_MM_cct || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DORDER_FG_AMT_cct || '</span></td>';
  --수주-제품 끝

  --수주-상품
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td colspan=1 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>샘 플</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_LM_P_AMT_cct || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_PL_P_AMT_cct || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_P_AMT_cct || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_P_MM_cct || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DORDER_P_AMT_cct || '</span></td>';
    v_message := v_message || '</tr>';
  --수주-상품 끝

  --수주-총계
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td colspan=1 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>총 계</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_ORDER_LM_TOTAL_AMT_cct || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_ORDER_PL_AMT_cct || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_ORDER_TOTAL_AMT_cct || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_ORDER_TOTAL_MM_cct || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DORDER_TOTAL_AMT_cct  || '</b></span></td>';
    v_message := v_message || '</tr>';

  --수주-총계 끝

    v_message := v_message || '</tr>';
  --수주 끝-

  --투입
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td rowspan=3 width=75 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>투 입</b></span></td>';

 --투입-양산
    v_message := v_message || '<td colspan=1 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>양 산</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_START_LM_AMT_cct || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_START_PL_FG_AMT_cct || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_START_AMT_cct || '</span></td>';

 --투입-누적실적 %계
    v_message := v_message || '<td rowspan=3 align=right valign=bottom>';
    v_message := v_message || '<span style=font-size:8pt;>' || v_START_PER_cct || '%</span></td>';
 --투입-누적실적 %계 끝

    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_START_MM_cct || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DSTART_AMT_cct || '</span></td>';
  --투입-양산 끝

  --투입-샘플
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td colspan=1 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>샘 플</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_START_LM_SPL_AMT_cct || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_START_PL_SMP_AMT_cct || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' ||  v_START_SPL_AMT_cct || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_START_SPL_MM_cct || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DSTART_SPL_AMT_cct || '</span></td>';
    v_message := v_message || '</tr>';
  --투입-샘플 끝

  --투입-총계
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td colspan=1 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>총 계</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_START_LM_TOTAL_AMT_cct || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_START_PL_AMT_cct || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_START_TOTAL_AMT_cct  || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_START_TOTAL_MM_cct || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DSTART_TOTAL_AMT_cct || '</b></span></td>';
    v_message := v_message || '</tr>';
  --투입-총계 끝
    v_message := v_message || '</tr>';
  --투입 끝

 --생산-
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td rowspan=3 width=75 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>생 산</b></span></td>';

 --생산-양산
    v_message := v_message || '<td align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>양 산</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_WIP_LM_AMT_cct || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_WIP_PL_FG_AMT_cct || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_WIP_AMT_cct || '</span></td>';

  --생산-누적실적 총계%
    v_message := v_message || '<td rowspan=3 align=right valign=bottom>';
    v_message := v_message || '<span style=font-size:8pt;>' || v_WIP_PER_cct || '%</span></td>';
 --생산-누적실적 총계% 끝

    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_WIP_MM_cct || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DWIP_AMT_cct || '</span></td>';
 --생산-양산 끝

 --생산-샘플
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>샘 플</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_WIP_LM_SPL_AMT_cct || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_WIP_PL_SMP_AMT_cct || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_WIP_SPL_AMT_cct || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_WIP_SPL_MM_cct  || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DWIP_SPL_AMT_cct || '</span></td>';
    v_message := v_message || '</tr>';
 --생산-샘플 끝



  --생산-총계
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td colspan=1 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>총 계</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_WIP_LM_TOTAL_AMT_cct  || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_WIP_PL_AMT_cct  || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_WIP_TOTAL_AMT_cct || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_WIP_TOTAL_MM_cct || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DWIP_TOTAL_AMT_cct || '</b></span></td>';
    v_message := v_message || '</tr>';

  --생산-총계 끝

    v_message := v_message || '</tr>';
  --생산  끝-

  --출하
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td rowspan=3 width=75 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>출 하</b></span></td>';

  --출하-제품
    v_message := v_message || '<td align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>제 품</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DEL_LM_FG_AMT_cct || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DEL_PL_FG_AMT_cct || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DELIVERY_FG_AMT_cct || '</span></td>';

  --출하-누적실적 계%
    v_message := v_message || '<td rowspan=3 align=right valign=bottom>';
    v_message := v_message || '<span style=font-size:8pt;>' || v_DEL_PER_cct || '%</span></td>';
  --출하-누적실적 계 끝%


    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DELIVERY_FG_MM_cct || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DDEL_FG_AMT_cct || '</span></td>';
  --출하-제품-끝

  --출하-상품
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td colspan=1 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>샘 플</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DEL_LM_P_AMT_cct || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DEL_PL_P_AMT_cct || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DELIVERY_P_AMT_cct || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DELIVERY_P_MM_cct || '</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DDEL_P_AMT_cct || '</span></td>';
    v_message := v_message || '</tr>';
  --출하-상품 끝

  --출하 총계
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td colspan=1 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>총 계</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DEL_LM_TOTAL_AMT_cct || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DEL_PL_AMT_cct || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DELIVERY_TOTAL_AMT_cct || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DELIVERY_TOTAL_MM_cct  || '</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DDEL_TOTAL_AMT_cct || '</b></span></td>';
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
   --v_message := v_message || '<td width=600 valign=middle align=left><span style=font-size:11pt;><b>첨부 : <a target=_blank href=' || v_url || '> <font color=blue>' || v_month1 || ' 일일 지표</font></a></b></span></td>';

   --v_message := v_message || '<td width=600 valign=top align=left><span style=font-size:8pt;><b>첨부 :  <font color=black>' || v_month1 || ' 일일 지표</font></b></span></td>';
   --<a target=_blank href=' || v_url || '></a>
  --첨부(일일지표) 끝


  --작성기준
  --v_message := v_message || '<td width=250 valign=bottom align=right>;<span style=font-size:8pt;><b>' || v_etc || '</b></span></td>';
  --작성기준 끝

  v_message := v_message || '</tr>';
  v_message := v_message || '</table><br>';
  --하단 끝*/

  v_message := v_message ||'</body>';

  v_message := v_message ||'</html>';
 



BEGIN
DELETE
FROM    IFC_WEB_MAIL_TEMP_IFV_CCT;

INSERT INTO IFC_WEB_MAIL_TEMP_IFV_CCT
(subject,message)
VALUES
(v_subject,v_message);
commit;
END;

END;
/
