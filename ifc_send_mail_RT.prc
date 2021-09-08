CREATE OR REPLACE PROCEDURE ifc_send_mail_RT(
                           Errbuf     OUT VARCHAR2,
                           Retcode    OUT VARCHAR2)
IS

--> ��Ŀ��Ʈ �� : Dally Performence Status Send Mail (ERP)
--> ���Ϻ����� ���ν��� : JOB_SCHEDULE_DAILY_REPORT (SPC)

  --  v_to_name        VARCHAR2(100);
  --  v_to_email       VARCHAR2(100);
  --  v_org_code       VARCHAR2(10);
    v_subject        VARCHAR2(250);
    v_message        LONG;
    v_ORDER_PL_AMT   VARCHAR2(100);
    v_START_PL_AMT   VARCHAR2(100); -- ���� ��ȹ �ݾ�(�Ұ�)
    v_WIP_PL_AMT     VARCHAR2(100); -- ���� ��ȹ �ݾ�(�Ұ�)
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
    v_CWIP_LM_AMT    VARCHAR2(100);   -- ���� ���� ���� �ݾ� (CCT)
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
   
    -- 2020.06.03 J.W Kim �濵������ ���ＷS ��û - ���ְ�ȹ�ݾ�, ����ȹ�ݾ׿� ��ǰ/��ǰ ���� �߰�
    v_ORDER_PL_FG_AMT VARCHAR2(100);    -- ���� ��ȹ �ݾ� (��ǰ)
    v_ORDER_PL_P_AMT  VARCHAR2(100);    -- ���� ��ȹ �ݾ� (��ǰ)
    v_DEL_PL_FG_AMT   VARCHAR2(100);    -- ��� ��ȹ �ݾ� (��ǰ)
    v_DEL_PL_P_AMT    VARCHAR2(100);    -- ��� ��ȹ �ݾ� (��ǰ)
    v_DORDER_FG_AMT   VARCHAR2(100);    -- ���� ���� ���� �ݾ� (��ǰ)
    v_DORDER_P_AMT    VARCHAR2(100);    -- ���� ���� ���� �ݾ� (��ǰ)
    v_DDEL_FG_AMT     VARCHAR2(100);    -- ��� ���� ���� �ݾ� (��ǰ)
    v_DDEL_P_AMT      VARCHAR2(100);    -- ��� ���� ���� �ݾ� (��ǰ)
    v_ORDER_FG_AMT    VARCHAR2(100);    -- ���� ���� ���� �ݾ� (��ǰ)
    v_ORDER_P_AMT     VARCHAR2(100);    -- ���� ���� ���� �ݾ� (��ǰ)
    v_DELIVERY_FG_AMT VARCHAR2(100);    -- ��� ���� ���� �ݾ� (��ǰ)
    v_DELIVERY_P_AMT  VARCHAR2(100);    -- ��� ���� ���� �ݾ� (��ǰ)
    v_ORDER_FG_MM     VARCHAR2(100);    -- ���� ���� ���� (��ǰ)
    v_ORDER_P_MM      VARCHAR2(100);    -- ���� ���� ���� (��ǰ)
    v_DELIVERY_FG_MM  VARCHAR2(100);    -- ��� ���� ���� (��ǰ)
    v_DELIVERY_P_MM   VARCHAR2(100);    -- ��� ���� ���� (��ǰ)
    v_ORDER_LM_FG_AMT VARCHAR2(100);    -- ���� ���� ���� (��ǰ)
    v_ORDER_LM_P_AMT  VARCHAR2(100);    -- ���� ���� ���� (��ǰ)
    v_DEL_LM_FG_AMT   VARCHAR2(100);    -- ��� ���� ���� (��ǰ)
    v_DEL_LM_P_AMT    VARCHAR2(100);    -- ���� ���� ���� (��ǰ)
    
    -- 2020.07.06 J.W.Kim �濵������ ���ＷS ��û-���ϰ濵������Ȳ (�� �׸� ���� ���� �߰�)
    v_DORDER_SPL_AMT   VARCHAR2(100);   -- ���� ���� ���� �ݾ� (����)
    v_DSTART_SPL_AMT   VARCHAR2(100);   -- ���� ���� ���� �ݾ� (����)
    v_DWIP_SPL_AMT     VARCHAR2(100);   -- ���� ���� ���� �ݾ� (����)
    v_DDEL_SPL_AMT     VARCHAR2(100);   -- ��� ���� ���� �ݾ� (����)
    v_ORDER_SPL_AMT    VARCHAR2(100);   -- ���� ���� ���� �ݾ� (����)
    v_START_SPL_AMT    VARCHAR2(100);   -- ���� ���� ���� �ݾ� (����)
    v_WIP_SPL_AMT      VARCHAR2(100);   -- ���� ���� ���� �ݾ� (����)
    v_DELIVERY_SPL_AMT VARCHAR2(100);   -- ��� ���� ���� �ݾ� (����)
    v_ORDER_SPL_MM     VARCHAR2(100);   -- ���� ���� ���� (����)
    v_START_SPL_MM     VARCHAR2(100);   -- ���� ���� ���� (����)
    v_WIP_SPL_MM       VARCHAR2(100);   -- ���� ���� ���� (����)   
    v_DELIVERY_SPL_MM  VARCHAR2(100);   -- ��� ���� ���� (����)
    v_ORDER_LM_SPL_AMT VARCHAR2(100);   -- ���� ���� ���� �ݾ� (����)
    v_START_LM_SPL_AMT VARCHAR2(100);   -- ���� ���� ���� �ݾ� (����)
    v_WIP_LM_SPL_AMT   VARCHAR2(100);   -- ���� ���� ���� �ݾ� (����)
    v_DEL_LM_SPL_AMT   VARCHAR2(100);   -- ��� ���� ���� �ݾ� (����)
    
    v_DORDER_TOTAL_AMT   VARCHAR2(100); -- ���� ���� ���� �Ѱ�
    v_DSTART_TOTAL_AMT   VARCHAR2(100); -- ���� ���� ���� �Ѱ�
    
    v_DWIP_TOTAL_AMT     VARCHAR2(100); -- ���� ���� ���� �Ұ�
    v_CDWIP_TOTAL_AMT    VARCHAR2(100); -- ���� ���� ���� �Ѱ�
    
    v_DDEL_TOTAL_AMT     VARCHAR2(100); -- ��� ���� ���� �Ѱ�
    v_ORDER_TOTAL_AMT    VARCHAR2(100); -- ���� ���� ���� �Ѱ�
    v_START_TOTAL_AMT    VARCHAR2(100); -- ���� ���� ���� �Ѱ�
    v_WIP_TOTAL_AMT      VARCHAR2(100); -- ���� ���� ���� �Ұ�
    v_CWIP_TOTAL_AMT     VARCHAR2(100); -- ���� ���� ���� �Ѱ�
    v_DELIVERY_TOTAL_AMT VARCHAR2(100); -- ��� ���� ���� �Ѱ�
    v_ORDER_TOTAL_MM     VARCHAR2(100); -- ���� ���� ���� �Ѱ�
    v_START_TOTAL_MM     VARCHAR2(100); -- ���� ���� ���� �Ѱ�
    v_WIP_TOTAL_MM       VARCHAR2(100); -- ���� ���� ���� �Ұ�
    v_CWIP_TOTAL_MM      VARCHAR2(100); -- ���� ���� ���� �Ѱ�
    v_DELIVERY_TOTAL_MM  VARCHAR2(100); -- ��� ���� ���� �Ѱ�
    v_ORDER_LM_TOTAL_AMT VARCHAR2(100); -- ���� ���� ���� �ݾ� �Ѱ�
    v_START_LM_TOTAL_AMT VARCHAR2(100); -- ���� ���� ���� �ݾ� �Ѱ�  
    v_WIP_LM_TOTAL_AMT   VARCHAR2(100); -- ���� ���� ���� �ݾ� �Ұ�
    v_CWIP_LM_TOTAL_AMT  VARCHAR2(100); -- ���� ���� ���� �ݾ� �Ѱ�
    v_DEL_LM_TOTAL_AMT   VARCHAR2(100); -- ��� ���� ���� �ݾ� �Ѱ�

   -- 2020.07.14 J.W.Kim �濵������ ���ＷS ��û-���ϰ濵������Ȳ (����/���� ��ǥ ���� �߰�)
    v_START_PL_FG_AMT    VARCHAR2(100); -- ���� ��ȹ �ݾ�(���)
    v_WIP_PL_FG_AMT      VARCHAR2(100); -- ���� ��ȹ �ݾ�(���)
    v_START_PL_SMP_AMT   VARCHAR2(100); -- ���� ��ȹ �ݾ�(����)
    v_WIP_PL_SMP_AMT     VARCHAR2(100); -- ���� ��ȹ �ݾ�(����)   
    
   -- 2020.09.16 J.W.Kim �濵������ ���ＷS ��û-���ϰ濵������Ȳ (���� ��ǥ CCT �߰�)
    v_WIP_PL_CCT_AMT     VARCHAR2(100); -- ���� ��ȹ �ݾ�(CCT)
    v_CWIP_PL_TOTAL_AMT  VARCHAR2(100); -- ���� ��ȹ �Ѱ�    
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
    
    --�ߺ� ���� ����
    IF (V_Run_Count > 0) THEN
        fnd_file.put_line (fnd_file.log, '��ġ ���α׷��� �̹� �������Դϴ�.');
        dbms_output.put_line('��ġ ���α׷��� �̹� �������Դϴ�.');
        Return;
    END IF;

  BEGIN
    SELECT REPLACE(TO_CHAR(ROUND(PM.Order_Pl_Fg_Amt) + ROUND(PM.Order_Pl_p_Amt),'999,990'),' ','')
    ,      REPLACE(TO_CHAR(ROUND(PM.Start_Pl_Fg_Amt) + ROUND(PM.Start_Pl_Smp_Amt),'999,990'),' ','')
--    ,      REPLACE(TO_CHAR(ROUND(PM.START_PL_AMT), '999,990'),' ','')
    ,      REPLACE(TO_CHAR(ROUND(PM.Wip_Pl_Fg_Amt) + ROUND(PM.Wip_Pl_Smp_Amt),'999,990'),' ','')
--    ,      REPLACE(TO_CHAR(ROUND(PM.WIP_PL_AMT), '999,990'),' ','')
    ,      REPLACE(TO_CHAR(ROUND(PM.Wip_Pl_Fg_Amt) + ROUND(PM.Wip_Pl_Smp_Amt) + ROUND(PM.Wip_Pl_Cct_Amt),'999,990'),' ','')                   --���� ��ȹ �Ѱ�
    ,      REPLACE(TO_CHAR(ROUND(PM.Del_Pl_Fg_Amt) + ROUND(PM.Del_Pl_p_Amt),'999,990'),' ','')
    ,      ROUND(PM.ORDER_PL_AMT)
    ,      ROUND(PM.START_PL_AMT)
    ,      ROUND(PM.WIP_PL_AMT)
    ,      ROUND(PM.CWIP_PL_TOTAL_AMT)
    ,      ROUND(PM.DEL_PL_AMT)
    ,      ROUND(TO_NUMBER(TO_CHAR(SYSDATE -1 - 8.5/24,'DD'))/ TO_NUMBER(TO_CHAR(last_day(sysdate -1 - 8.5/24),'DD')) * 100) as CNT1
 
    -- 2020.06.03 �濵������ ���ＷS ��û - ���ְ�ȹ�ݾ�, ����ȹ�ݾ׿� ��ǰ/��ǰ ���� �߰�
    ,      REPLACE(TO_CHAR(ROUND(PM.Order_Pl_Fg_Amt), '999,990'),' ','') --���� ��ǰ ��ȹ �ݾ�
    ,      REPLACE(TO_CHAR(ROUND(PM.Order_Pl_p_Amt), '999,990'),' ','')  --���� ��ǰ ��ȹ �ݾ�
    ,      REPLACE(TO_CHAR(ROUND(PM.Del_Pl_Fg_Amt), '999,990'),' ','')   --��� ��ǰ ��ȹ �ݾ�
    ,      REPLACE(TO_CHAR(ROUND(PM.Del_Pl_p_Amt), '999,990'),' ','')    --��� ��ǰ ��ȹ �ݾ�
    
    -- 2020.07.16 �濵������ ���ＷS ��û - ���԰�ȹ�ݾ�, �����ȹ�ݾ׿� ���/���� ���� �߰�
    ,      REPLACE(TO_CHAR(ROUND(PM.Start_Pl_Fg_Amt), '999,990'),' ','') --���� ��� ��ȹ �ݾ�
    ,      REPLACE(TO_CHAR(ROUND(PM.Start_Pl_Smp_Amt), '999,990'),' ','')--���� ���� ��ȹ �ݾ�
    ,      REPLACE(TO_CHAR(ROUND(PM.Wip_Pl_Fg_Amt), '999,990'),' ','')   --���� ��� ��ȹ �ݾ�
    ,      REPLACE(TO_CHAR(ROUND(PM.Wip_Pl_Smp_Amt), '999,990'),' ','')  --���� ���� ��ȹ �ݾ�
   
    -- 2020.09.16 J.W.Kim �濵������ ���ＷS ��û-���ϰ濵������Ȳ (���� ��ǥ CCT �߰�)
    ,      REPLACE(TO_CHAR(ROUND(PM.Wip_Pl_Cct_Amt), '999,990'),' ','')  --���� CCT ��ȹ �ݾ� 
   
    INTO   v_ORDER_PL_AMT
    ,      v_START_PL_AMT
    ,      v_WIP_PL_AMT
    ,      v_CWIP_PL_TOTAL_AMT  -- ���� ��ȹ ���� �ݾ� �Ѱ�
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
    ,      v_START_PL_FG_AMT   -- ���� ��ȹ �ݾ�(���)
    ,      v_START_PL_SMP_AMT  -- ���� ��ȹ �ݾ�(����)
    ,      v_WIP_PL_FG_AMT     -- ���� ��ȹ �ݾ�(���)
    ,      v_WIP_PL_SMP_AMT    -- ���� ��ȹ �ݾ�(����)
    ,      v_WIP_PL_CCT_AMT    -- ���� ��ȹ �ݾ�(CCT)    
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
     -- 2020.06.03 �濵������ ���ＷS ��û - ���� ����( ����/��ǰ )�� ��ǰ/��ǰ ���� �߰�
     ,       REPLACE(TO_CHAR(ROUND(GRP.ORDER_FG_AMT), '999,990'),' ','')                                                                            --���� ��ǰ ���� ����
     ,       REPLACE(TO_CHAR(ROUND(GRP.ORDER_P_AMT), '999,990'),' ','')                                                                             --���� ��ǰ ���� ����
     ,       REPLACE(TO_CHAR(ROUND(GRP.DELIVERY_FG_AMT), '999,990'),' ','')                                                                         --��� ��ǰ ���� ����
     ,       REPLACE(TO_CHAR(ROUND(GRP.DELIVERY_P_AMT), '999,990'),' ','')                                                                          --��� ��ǰ ���� ����
     -- 2020.07.06 J.W.Kim �濵������ ���ＷS ��û-���ϰ濵������Ȳ (�� �׸� ���� ���� �߰�)
     ,       REPLACE(TO_CHAR(ROUND(GRP.ORDER_SAMPLE_AMT), '999,990'),' ','')                                                                        --���� ���� ���� (����)
     ,       REPLACE(TO_CHAR(ROUND(GRP.START_SAMPLE_AMT), '999,990'),' ','')                                                                        --���� ���� ���� (����)
     ,       REPLACE(TO_CHAR(ROUND(GRP.ENTER_SAMPLE_AMT), '999,990'),' ','')                                                                        --���� ���� ���� (����)
     ,       REPLACE(TO_CHAR(ROUND(GRP.DELIVERY_SAMPLE_AMT), '999,990'),' ','')                                                                     --��� ���� ���� (����)
     ,       REPLACE(TO_CHAR(ROUND(GRP.ORDER_FG_AMT) + ROUND(GRP.ORDER_P_AMT) + ROUND(GRP.ORDER_SAMPLE_AMT),'999,990'),' ','')                      --���� ���� �Ѱ�
     ,       REPLACE(TO_CHAR(ROUND(GRP.START_AMT) + ROUND(GRP.START_SAMPLE_AMT),'999,990'),' ','')                                                  --���� ���� �Ѱ�
     ,       REPLACE(TO_CHAR(ROUND(GRP.ENTER_AMT) + ROUND(GRP.ENTER_SAMPLE_AMT),'999,990'),' ','')                                                  --���� ���� �Ұ�
     ,       REPLACE(TO_CHAR(ROUND(GRP.ENTER_AMT) + ROUND(GRP.ENTER_SAMPLE_AMT) + ROUND(GRP.CCT_ENTER_AMT),'999,990'),' ','')                       --���� ���� �Ѱ�
     ,       REPLACE(TO_CHAR(ROUND(GRP.DELIVERY_FG_AMT) + ROUND(GRP.DELIVERY_P_AMT) + ROUND(GRP.DELIVERY_SAMPLE_AMT),'999,990'),' ','')             --���� ���� �Ѱ�
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
     ,       v_DORDER_SPL_AMT   -- ���� ���� ���� �ݾ� (����)
     ,       v_DSTART_SPL_AMT   -- ���� ���� ���� �ݾ� (����)
     ,       v_DWIP_SPL_AMT     -- ���� ���� ���� �ݾ� (����)
     ,       v_DDEL_SPL_AMT     -- ��� ���� ���� �ݾ� (����)
     ,       v_DORDER_TOTAL_AMT -- ���� ���� ���� �Ѱ�
     ,       v_DSTART_TOTAL_AMT -- ���� ���� ���� �Ѱ�
     ,       v_DWIP_TOTAL_AMT   -- ���� ���� ���� �Ұ�
     ,       v_CDWIP_TOTAL_AMT  -- ���� ���� ���� �Ѱ�
     ,       v_DDEL_TOTAL_AMT   -- ��� ���� ���� �Ѱ�
     FROM IFC_GW_RESULT_PT_DAILY_V GRP
     WHERE GRP.TRANSACTION_DATE = TO_CHAR(sysdate -1 - 8.5/24,'YYYY-MM-DD');
  END;

  BEGIN
     SELECT  REPLACE(TO_CHAR(ROUND(GRP.ORDER_FG_AMT) + ROUND(GRP.ORDER_P_AMT),'999,990'),' ','')
     ,       REPLACE(TO_CHAR(ROUND(GRP.START_AMT + GRP.IPRO_START_AMT,1), '999,990'),' ','')
     ,       ROUND(GRP.ORDER_AMT)
     ,       ROUND(GRP.START_AMT + GRP.IPRO_START_AMT) + ROUND(GRP.START_SAMPLE_AMT)                                             --2020.08.31 ���Դ������� ���ý����߰�
     ,       REPLACE(TO_CHAR(ROUND(GRP.ENTER_AMT + GRP.IPRO_ENTER_AMT), '999,990'),' ','')
     ,       REPLACE(TO_CHAR(ROUND(GRP.CCT_ENTER_AMT), '999,990'),' ','')
     ,       REPLACE(TO_CHAR(ROUND(GRP.ENTER_AMT) + ROUND(GRP.CCT_ENTER_AMT),'999,990'),' ','')
     ,       REPLACE(TO_CHAR(ROUND(GRP.DELIVERY_FG_AMT) + ROUND(GRP.DELIVERY_P_AMT),'999,990'),' ','')
     ,       ROUND(GRP.ENTER_AMT + GRP.IPRO_ENTER_AMT) + ROUND(NVL(GRP.CCT_ENTER_AMT,0)) + ROUND(GRP.ENTER_SAMPLE_AMT)           --2020.08.31 ���괩������ ���ý����߰�
     ,       ROUND(GRP.DELIVERY_AMT)
     ,       REPLACE(TO_CHAR(ROUND(GRP.ORDER_FG_MM) + ROUND(GRP.ORDER_P_MM),'999,990'),' ','')
     ,       REPLACE(TO_CHAR(ROUND(GRP.START_MM + GRP.IPRO_START_MM), '999,990'),' ','')
     ,       REPLACE(TO_CHAR(ROUND(GRP.ENTER_MM + GRP.IPRO_ENTER_MM), '999,990'),' ','')
     ,       REPLACE(TO_CHAR(ROUND(CCT_ENTER_MM), '999,990'),' ','')
     ,       REPLACE(TO_CHAR(ROUND(GRP.ENTER_MM)+ ROUND(GRP.CCT_ENTER_MM),'999,990'),' ','') 
     ,       REPLACE(TO_CHAR(ROUND(GRP.DELIVERY_FG_MM) + ROUND(GRP.DELIVERY_P_MM),'999,990'),' ','')
     -- 2020.06.03 �濵������ ���ＷS ��û - ���ִ�������, ����������� ��ǰ/��ǰ ���� �߰�
     ,       REPLACE(TO_CHAR(ROUND(GRP.ORDER_FG_AMT), '999,990'),' ','')                                                                        --���� ��ǰ ���� ����
     ,       REPLACE(TO_CHAR(ROUND(GRP.ORDER_P_AMT), '999,990'),' ','')                                                                         --���� ��ǰ ���� ����
     ,       REPLACE(TO_CHAR(ROUND(GRP.DELIVERY_FG_AMT), '999,990'),' ','')                                                                     --��� ��ǰ ���� ����
     ,       REPLACE(TO_CHAR(ROUND(GRP.DELIVERY_P_AMT), '999,990'),' ','')                                                                      --��� ��ǰ ���� ����
     ,       REPLACE(TO_CHAR(ROUND(GRP.ORDER_FG_MM), '999,990'),' ','')                                                                         --���� ��ǰ ���� ����
     ,       REPLACE(TO_CHAR(ROUND(GRP.ORDER_P_MM), '999,990'),' ','')                                                                          --���� ��ǰ ���� ����
     ,       REPLACE(TO_CHAR(ROUND(GRP.DELIVERY_FG_MM), '999,990'),' ','')                                                                      --��� ��ǰ ���� ����
     ,       REPLACE(TO_CHAR(ROUND(GRP.DELIVERY_P_MM), '999,990'),' ','')                                                                       --��� ��ǰ ���� ����
     -- 2020.07.06 J.W.Kim �濵������ ���ＷS ��û-���ϰ濵������Ȳ (�� �׸� ���� ���� �߰�)
     ,       REPLACE(TO_CHAR(ROUND(GRP.ORDER_SAMPLE_AMT), '999,990'),' ','')                                                                    --���� ���� ���� ����
     ,       REPLACE(TO_CHAR(ROUND(GRP.START_SAMPLE_AMT), '999,990'),' ','')                                                                    --���� ���� ���� ����
     ,       REPLACE(TO_CHAR(ROUND(GRP.ENTER_SAMPLE_AMT), '999,990'),' ','')                                                                    --���� ���� ���� ����
     ,       REPLACE(TO_CHAR(ROUND(GRP.DELIVERY_SAMPLE_AMT), '999,990'),' ','')                                                                 --��� ���� ���� ����
     ,       REPLACE(TO_CHAR(ROUND(GRP.ORDER_SAMPLE_MM), '999,990'),' ','')                                                                     --���� ���� ���� ����
     ,       REPLACE(TO_CHAR(ROUND(GRP.START_SAMPLE_MM), '999,990'),' ','')                                                                     --���� ���� ���� ����
     ,       REPLACE(TO_CHAR(ROUND(GRP.ENTER_SAMPLE_MM), '999,990'),' ','')                                                                     --���� ���� ���� ����
     ,       REPLACE(TO_CHAR(ROUND(GRP.DELIVERY_SAMPLE_MM), '999,990'),' ','')                                                                  --��� ���� ���� ����
     ,       REPLACE(TO_CHAR(ROUND(GRP.ORDER_FG_AMT) + ROUND(GRP.ORDER_P_AMT) + ROUND(GRP.ORDER_SAMPLE_AMT),'999,990'),' ','')                  --���� ���� ���� �Ѱ�
     ,       REPLACE(TO_CHAR(ROUND(GRP.START_AMT) + ROUND(GRP.START_SAMPLE_AMT),'999,990'),' ','')                                              --���� ���� ���� �Ѱ�
     ,       REPLACE(TO_CHAR(ROUND(GRP.ENTER_AMT) + ROUND(GRP.ENTER_SAMPLE_AMT),'999,990'),' ','')                                              --���� ���� ���� �Ұ�
     ,       REPLACE(TO_CHAR(ROUND(GRP.ENTER_AMT) + ROUND(GRP.ENTER_SAMPLE_AMT) + ROUND(GRP.CCT_ENTER_AMT),'999,990'),' ','')                   --���� ���� ���� �Ѱ�
     ,       REPLACE(TO_CHAR(ROUND(GRP.DELIVERY_FG_AMT) + ROUND(GRP.DELIVERY_P_AMT) + ROUND(GRP.DELIVERY_SAMPLE_AMT),'999,990'),' ','')         --���� ���� ���� �Ѱ�
     ,       REPLACE(TO_CHAR(ROUND(GRP.ORDER_FG_MM) + ROUND(GRP.ORDER_P_MM) + ROUND(GRP.ORDER_SAMPLE_MM),'999,990'),' ','')                     --���� ���� ���� �Ѱ�
     ,       REPLACE(TO_CHAR(ROUND(GRP.START_MM) + ROUND(GRP.START_SAMPLE_MM),'999,990'),' ','')                                                --���� ���� ���� �Ѱ�
     ,       REPLACE(TO_CHAR(ROUND(GRP.ENTER_MM) + ROUND(GRP.ENTER_SAMPLE_MM),'999,990'),' ','')                                                --���� ���� ���� �Ұ�
     ,       REPLACE(TO_CHAR(ROUND(GRP.ENTER_MM) + ROUND(GRP.ENTER_SAMPLE_MM) + ROUND(GRP.CCT_ENTER_MM),'999,990'),' ','')                      --���� ���� ���� �Ѱ�
     ,       REPLACE(TO_CHAR(ROUND(GRP.DELIVERY_FG_MM) + ROUND(GRP.DELIVERY_P_MM) + ROUND(GRP.DELIVERY_SAMPLE_MM),'999,990'),' ','')            --���� ���� ���� �Ѱ�
     
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
     ,       v_ORDER_SPL_AMT      -- ���� ���� ���� �ݾ� (����)
     ,       v_START_SPL_AMT      -- ���� ���� ���� �ݾ� (����)
     ,       v_WIP_SPL_AMT        -- ���� ���� ���� �ݾ� (����)
     ,       v_DELIVERY_SPL_AMT   -- ��� ���� ���� �ݾ� (����)
     ,       v_ORDER_SPL_MM       -- ���� ���� ���� (����)
     ,       v_START_SPL_MM       -- ���� ���� ���� (����)
     ,       v_WIP_SPL_MM         -- ���� ���� ���� (����)   
     ,       v_DELIVERY_SPL_MM    -- ��� ���� ���� (����)
     ,       v_ORDER_TOTAL_AMT    -- ���� ���� ���� �Ѱ�
     ,       v_START_TOTAL_AMT    -- ���� ���� ���� �Ѱ�
     ,       v_WIP_TOTAL_AMT      -- ���� ���� ���� �Ұ�
     ,       v_CWIP_TOTAL_AMT     -- ���� ���� ���� �Ѱ�
     ,       v_DELIVERY_TOTAL_AMT -- ��� ���� ���� �Ѱ�
     ,       v_ORDER_TOTAL_MM     -- ���� ���� ���� �Ѱ�
     ,       v_START_TOTAL_MM     -- ���� ���� ���� �Ѱ�
     ,       v_WIP_TOTAL_MM       -- ���� ���� ���� �Ұ�   
     ,       v_CWIP_TOTAL_MM      -- ���� ���� ���� �Ѱ�   
     ,       v_DELIVERY_TOTAL_MM  -- ��� ���� ���� �Ѱ�
     
     FROM IFC_GW_RESULT_PT_MAIL_V GRP
     WHERE TRANSACTION_DATE = TO_CHAR(sysdate -1 - 8.5/24,'YYYY-MM');

  END;

  BEGIN
     SELECT  REPLACE(TO_CHAR(ROUND(RP.ORDER_FG_AMT) + ROUND(RP.ORDER_P_AMT),'999,990'),' ','')
     ,       REPLACE(TO_CHAR(ROUND(NVL(PM.START_AMT,NVL(RP.START_AMT + RP.IPRO_START_AMT,0))), '999,990'),' ','')
     ,       REPLACE(TO_CHAR(ROUND(NVL(PM.WIP_AMT,NVL(RP.ENTER_AMT + RP.IPRO_ENTER_AMT,0)+NVL(RP.CCT_ENTER_AMT,0))), '999,990'),' ','')
     ,       REPLACE(TO_CHAR(ROUND(RP.DELIVERY_FG_AMT) + ROUND(RP.DELIVERY_P_AMT),'999,990'),' ','')
     -- 2020.06.03 �濵������ ���ＷS ��û - ������������, ������������� ��ǰ/��ǰ ���� �߰�
     ,       REPLACE(TO_CHAR(ROUND(RP.ORDER_FG_AMT), '999,990'),' ','')                                                                         --���� ��ǰ ���� ����
     ,       REPLACE(TO_CHAR(ROUND(RP.ORDER_P_AMT), '999,990'),' ','')                                                                          --���� ��ǰ ���� ����
     ,       REPLACE(TO_CHAR(ROUND(RP.DELIVERY_FG_AMT), '999,990'),' ','')                                                                      --��� ��ǰ ���� ����
     ,       REPLACE(TO_CHAR(ROUND(RP.DELIVERY_P_AMT), '999,990'),' ','')                                                                       --��� ��ǰ ���� ����
     -- 2020.07.06 J.W.Kim �濵������ ���ＷS ��û-���ϰ濵������Ȳ (�� �׸� ���� ���� �߰�)
     ,       REPLACE(TO_CHAR(ROUND(RP.CCT_ENTER_AMT), '999,990'),' ','')                                                                        --���� ���� ����(CCT)
     ,       REPLACE(TO_CHAR(ROUND(RP.ORDER_SAMPLE_AMT), '999,990'),' ','')                                                                     --���� ���� ���� ����
     ,       REPLACE(TO_CHAR(ROUND(RP.START_SAMPLE_AMT), '999,990'),' ','')                                                                     --���� ���� ���� ����
     ,       REPLACE(TO_CHAR(ROUND(RP.ENTER_SAMPLE_AMT), '999,990'),' ','')                                                                     --���� ���� ���� ����
     ,       REPLACE(TO_CHAR(ROUND(RP.DELIVERY_SAMPLE_AMT), '999,990'),' ','')                                                                  --��� ���� ���� ����
     ,       REPLACE(TO_CHAR(ROUND(RP.ORDER_FG_AMT) + ROUND(RP.ORDER_P_AMT) + ROUND(RP.ORDER_SAMPLE_AMT),'999,990'),' ','')                     --���� ���� �Ѱ�
     ,       REPLACE(TO_CHAR(ROUND(RP.START_AMT) + ROUND(RP.START_SAMPLE_AMT),'999,990'),' ','')                                                --���� ���� �Ѱ�
     ,       REPLACE(TO_CHAR(ROUND(RP.ENTER_AMT) + ROUND(RP.ENTER_SAMPLE_AMT),'999,990'),' ','')                                                --���� ���� �Ұ�
     ,       REPLACE(TO_CHAR(ROUND(RP.ENTER_AMT) + ROUND(RP.ENTER_SAMPLE_AMT) + ROUND(RP.CCT_ENTER_AMT),'999,990'),' ','')                      --���� ���� �Ѱ�
     ,       REPLACE(TO_CHAR(ROUND(RP.DELIVERY_FG_AMT) + ROUND(RP.DELIVERY_P_AMT) + ROUND(RP.DELIVERY_SAMPLE_AMT),'999,990'),' ','')            --���� ���� �Ѱ�
     INTO    v_ORDER_LM_AMT
     ,       v_START_LM_AMT
     ,       v_WIP_LM_AMT
     ,       v_DEL_LM_AMT
     ,       v_ORDER_LM_FG_AMT
     ,       v_ORDER_LM_P_AMT
     ,       v_DEL_LM_FG_AMT
     ,       v_DEL_LM_P_AMT
     ,       v_CWIP_LM_AMT        -- ���� ���� ���� �ݾ� (CCT)
     ,       v_ORDER_LM_SPL_AMT   -- ���� ���� ���� �ݾ� (����)
     ,       v_START_LM_SPL_AMT   -- ���� ���� ���� �ݾ� (����)
     ,       v_WIP_LM_SPL_AMT     -- ���� ���� ���� �ݾ� (����)
     ,       v_DEL_LM_SPL_AMT     -- ��� ���� ���� �ݾ� (����)
     ,       v_ORDER_LM_TOTAL_AMT -- ���� ���� ���� �ݾ� �Ѱ�
     ,       v_START_LM_TOTAL_AMT -- ���� ���� ���� �ݾ� �Ѱ�
     ,       v_WIP_LM_TOTAL_AMT   -- ���� ���� ���� �ݾ� �Ұ�
     ,       v_CWIP_LM_TOTAL_AMT  -- ���� ���� ���� �ݾ� �Ѱ�
     ,       v_DEL_LM_TOTAL_AMT   -- ��� ���� ���� �ݾ� �Ѱ�
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
  v_TITLE      :='[' || TO_CHAR(sysdate -1 - 8.5/24,'YY') ||'Ҵ ' || TO_CHAR(sysdate -1 - 8.5/24,'MM')  ||'�� ��ǥ ��� ���� ���� ��Ȳ ]';
  v_DY         :='�� �ϼ���ô��:' || v_DAY ||'%';
  v_month1      := TO_CHAR(SYSDATE -1 - 8.5/24,'MM') || '��';
  v_subject :='[���� ���� ����] ' || TO_CHAR(SYSDATE -1 - 8.5/24,'MM') ||'�� ���� �帳�ϴ�';
  v_etc := '[�ۼ�����]' ||'<br>'||'* ���� : ��� ����'||'<br>'||'* ����,���� : ��ǰ ����';
    
  
-- 2020.07.06 J.W.Kim �濵������ ���ＷS ��û    

    v_message := v_message || '<html>';
    v_message := v_message || '<head>'; 
    v_message := v_message || '<meta content=text/html; charset=euc-kr http-equiv=Content-Type>';
    v_message := v_message || '</head>';
    v_message := v_message || '<body>';

    --���
    v_message := v_message || '<br><br><table width=600 align=center cellspacing=0 cellpadding=0 border=0>';    
  
   --Ÿ��Ʋ
    v_message := v_message || '<tr height=30>';
    v_message := v_message || '<td width=600 valign=middle align=center bgcolor=#FEE9FA><span style=font-size:10pt;><font color=blue><b>' || v_TITLE || '</b></font></span></td>';
    v_message := v_message || '</tr>';
   --Ÿ��Ʋ ��
  
  --�ϼ���ô��
    v_message := v_message || '<tr height=30>';
    v_message := v_message || '<td valign=bottom width=600 align=left><span style=font-size:8pt;><b>' || v_DY || '</b></span></td>';
    v_message := v_message || '</tr>';
  --�ϼ���ô�� ��

    v_message := v_message || '</table>';
   --��� ��

  --ǥ
    v_message := v_message || '<table align=center width=600 cellspacing=0 cellpadding=0 border=1 bordercolor=#999999>';
    
  --���� ~ ���Ͻ���
    v_message := v_message || '<tr height=30>';
    v_message := v_message || '<td colspan=3 align=center bgcolor=#CEE7FF><span style=font-size:9pt;><b>�� ��</b></span></td>';
    v_message := v_message || '<td align=center width=70 bgcolor=#CEE7FF><span style=font-size:9pt;><b>��������</b></span></td>';
    v_message := v_message || '<td align=center width=70 bgcolor=#CEE7FF><span style=font-size:9pt;><b>��&nbsp;ǥ</b></span></td>';
    v_message := v_message || '<td colspan=2 align=center bgcolor=#E1FDDF><span style=font-size:9pt;><b>��������</b></span></td>';
    v_message := v_message || '<td align=center width=70 bgcolor=#E1FDDF><span style=font-size:9pt;><b>�� ��(��)</b></span></td>';
    v_message := v_message || '<td align=center width=70 bgcolor=#CEE7FF><span style=font-size:9pt;><b>���Ͻ���</b></span></td>';
    v_message := v_message || '</tr>';
  --���� ~ ���Ͻ��� ��
  
  --����-���
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td rowspan=5 width=75 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>�� ��</b></td>';
    v_message := v_message || '<td rowspan=3 width=35 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>�� ��</b></td>';
        
  --����-��ǰ
    v_message := v_message || '<td align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>�� ǰ</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_LM_FG_AMT || '��</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_PL_FG_AMT || '��</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_FG_AMT || '��</span>&nbsp;</td>';
    
  --����-�������� %��
    v_message := v_message || '<td rowspan=5 align=right valign=bottom>';
    v_message := v_message || '<span style=font-size:8pt;>' || v_ORDER_PER || '%</span>&nbsp;</td>';
  --����-�������� %�� ��

    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_FG_MM || '</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DORDER_FG_AMT || '��</span>&nbsp;</td>';
  --����-��ǰ ��
    
  --����-��ǰ
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>�� ǰ</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_LM_P_AMT || '��</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_PL_P_AMT || '��</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_P_AMT || '��</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_P_MM || '</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DORDER_P_AMT || '��</span>&nbsp;</td>';
    v_message := v_message || '</tr>';
  --����-��ǰ ��

  --����-�Ұ�
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>�� ��</b></span></td>';                      
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_ORDER_LM_AMT || '��</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_ORDER_PL_AMT  || '��</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_ORDER_AMT || '��</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_ORDER_MM || '</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DORDER_AMT || '��</b></span>&nbsp;</td>';
    v_message := v_message || '</tr>';
    
  --����-�Ұ� ��
  
  --����-����
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td colspan=2 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>�� ��</b></span></td>';                      
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_LM_SPL_AMT || '��</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_SPL_AMT || '��</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_ORDER_SPL_MM || '</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DORDER_SPL_AMT || '��</span>&nbsp;</td>';
    v_message := v_message || '</tr>';
  --����-���� ��
  
  --����-�Ѱ�
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td colspan=2 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>�� ��</b></span></td>';                      
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_ORDER_LM_TOTAL_AMT || '��</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_ORDER_PL_AMT || '��</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_ORDER_TOTAL_AMT || '��</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_ORDER_TOTAL_MM || '</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DORDER_TOTAL_AMT  || '��</b></span>&nbsp;</td>';
    v_message := v_message || '</tr>';
   
  --����-�Ѱ� ��

    v_message := v_message || '</tr>';
  --���� ��-
  
  --����
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td rowspan=3 width=75 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>�� ��</b></span></td>';
    
 --����-��� 
    v_message := v_message || '<td colspan=2 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>�� ��</b></span></td>';                      
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_START_LM_AMT || '��</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_START_PL_FG_AMT || '��</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_START_AMT || '��</span>&nbsp;</td>';
 
 --����-�������� %��     
    v_message := v_message || '<td rowspan=3 align=right valign=bottom>';
    v_message := v_message || '<span style=font-size:8pt;>' || v_START_PER || '%</span>&nbsp;</td>';
 --����-�������� %�� ��
 
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_START_MM || '</span>&nbsp;</td>';  
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DSTART_AMT || '��</span>&nbsp;</td>';  
  --����-��� ��   
    
  --����-����
    v_message := v_message || '<tr height=25>';   
    v_message := v_message || '<td colspan=2 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>�� ��</b></span></td>'; 
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_START_LM_SPL_AMT || '��</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_START_PL_SMP_AMT || '��</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' ||  v_START_SPL_AMT || '��</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_START_SPL_MM || '</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DSTART_SPL_AMT || '��</span>&nbsp;</td>';  
    v_message := v_message || '</tr>';  
  --����-���� �� 
  
  --����-�Ѱ� 
    v_message := v_message || '<tr height=25>';   
    v_message := v_message || '<td colspan=2 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>�� ��</b></span></td>'; 
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_START_LM_TOTAL_AMT || '��</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_START_PL_AMT || '��</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_START_TOTAL_AMT  || '��</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_START_TOTAL_MM || '</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DSTART_TOTAL_AMT || '��</b></span>&nbsp;</td>';  
    v_message := v_message || '</tr>';
  --����-�Ѱ� ��
    v_message := v_message || '</tr>';
  --���� ��
  
 --����-IFC
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td rowspan=5 width=75 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>�� ��</b></span></td>';
    v_message := v_message || '<td rowspan=3 width=35 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>IFC</b></span></td>';
    
 --����-���   
    v_message := v_message || '<td align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>�� ��</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_WIP_LM_AMT || '��</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_WIP_PL_FG_AMT || '��</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_IWIP_AMT || '��</span>&nbsp;</td>';
 
  --����-�������� �Ѱ�%
    v_message := v_message || '<td rowspan=5 align=right valign=bottom>';
    v_message := v_message || '<span style=font-size:8pt;>' || v_WIP_PER || '%</span>&nbsp;</td>';
 --����-�������� �Ѱ�% ��
 
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_IWIP_MM || '</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DIWIP_AMT || '��</span>&nbsp;</td>';
 --����-��� ��
 
 --����-����
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>�� ��</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_WIP_LM_SPL_AMT || '��</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_WIP_PL_SMP_AMT || '��</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_WIP_SPL_AMT || '��</span>&nbsp;</td>'; 
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_WIP_SPL_MM  || '</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DWIP_SPL_AMT || '��</span>&nbsp;</td>'; 
    v_message := v_message || '</tr>';
 --����-���� ��
 
 --����-�Ұ�   
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>�� ��</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_WIP_LM_TOTAL_AMT || '��&nbsp;</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_WIP_PL_AMT || '��&nbsp;</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_WIP_TOTAL_AMT || '��&nbsp;</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_WIP_TOTAL_MM || '&nbsp;</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DWIP_TOTAL_AMT || '��&nbsp;</b></span></td>';
    v_message := v_message || '</tr>';
  --����-�Ұ� �� 
    
    
  --����-CCT
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td colspan=2 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>CCT</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_CWIP_LM_AMT || '��&nbsp;</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_WIP_PL_CCT_AMT || '��&nbsp;</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_CWIP_AMT || '��&nbsp;</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_CWIP_MM || '&nbsp;</span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DCWIP_AMT || '��&nbsp;</span></td>';
    v_message := v_message || '</tr>';
  --����-CCT��

  --����-�Ѱ�
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td colspan=2 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>�� ��</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_CWIP_LM_TOTAL_AMT  || '��</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_CWIP_PL_TOTAL_AMT  || '��</b></span>&nbsp;</td>';    
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_CWIP_TOTAL_AMT || '��</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_CWIP_TOTAL_MM || '</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_CDWIP_TOTAL_AMT || '��</b></span>&nbsp;</td>';
    v_message := v_message || '</tr>';

  --����-�Ѱ� ��
  
    v_message := v_message || '</tr>';
  --����  ��-
  
  --����-���
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td rowspan=5 width=75 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>�� ��</b></span></td>';
    v_message := v_message || '<td rowspan=3 width=35 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>�� ��</b></span></td>';

  --����-��ǰ
    v_message := v_message || '<td align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>�� ǰ</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DEL_LM_FG_AMT || '��</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DEL_PL_FG_AMT || '��</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DELIVERY_FG_AMT || '��</span>&nbsp;</td>';
  
  --����-�������� ��% 
    v_message := v_message || '<td rowspan=5 align=right valign=bottom>';
    v_message := v_message || '<span style=font-size:8pt;>' || v_DEL_PER || '%</span>&nbsp;</td>';
  --����-�������� �� ��%
 

    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DELIVERY_FG_MM || '</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DDEL_FG_AMT || '��</span>&nbsp;</td>';
  --����-��ǰ-��

  --����-��ǰ
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>�� ǰ</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DEL_LM_P_AMT || '��</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DEL_PL_P_AMT || '��</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DELIVERY_P_AMT || '��</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DELIVERY_P_MM || '</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DDEL_P_AMT || '��</span>&nbsp;</td>';
    v_message := v_message || '</tr>';
  --����-��ǰ ��
   
  --����-�Ұ�
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>�� ��</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DEL_LM_AMT || '��</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DEL_PL_AMT || '��</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DEL_AMT || '��</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DEL_MM || '</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DDEL_AMT || '��</b></span>&nbsp;</td>';
    v_message := v_message || '</tr>';
    
  --����-�Ұ� ��
  
  --����-����
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td colspan=2 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>�� ��</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DEL_LM_SPL_AMT || '��</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DELIVERY_SPL_AMT || '��</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DELIVERY_SPL_MM || '</span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;>' || v_DDEL_SPL_AMT || '��</span>&nbsp;</td>';
    v_message := v_message || '</tr>';
  --����-���� ��

  --���� �Ѱ�
    v_message := v_message || '<tr height=25>';
    v_message := v_message || '<td colspan=2 align=center bgcolor=#FFFFDD><span style=font-size:9pt;><b>�� ��</b></span></td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DEL_LM_TOTAL_AMT || '��</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DEL_PL_AMT || '��</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DELIVERY_TOTAL_AMT || '��</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DELIVERY_TOTAL_MM  || '</b></span>&nbsp;</td>';
    v_message := v_message || '<td align=right>';
    v_message := v_message || '<span style=font-size:9pt;><b>' || v_DDEL_TOTAL_AMT || '��</b></span>&nbsp;</td>';
    v_message := v_message || '</tr>';

 --���� �Ѱ� ��
    
    v_message := v_message || '</tr>';
  --���� ��
  
    v_message := v_message || '</table><br>';
  --ǥ ��

  --�ϴ�
    v_message := v_message || '<table width=600 align=center cellspacing=0 cellpadding=0 border=0>';
    v_message := v_message || '<tr height=30>';
  
  --÷��(������ǥ)
   -- v_message := v_message || '<td width=600 valign=middle align=left><span style=font-size:11pt;><b>÷�� : <a target=_blank href=' || v_url || '> <font color=blue>' || v_month1 || ' ���� ��ǥ</font></a></b></span></td>';

    v_message := v_message || '<td width=600 valign=top align=left><span style=font-size:8pt;><b>÷�� : <a target=_blank href=' || v_url || '> <font color=black>' || v_month1 || ' ���� ��ǥ</font></a></b></span></td>';
    
  --÷��(������ǥ) ��
  

  --�ۼ�����
  --v_message := v_message || '<td width=250 valign=bottom align=right>&nbsp;<span style=font-size:8pt;><b>' || v_etc || '</b></span></td>';
  --�ۼ����� ��
  
    v_message := v_message || '</tr>';  
    v_message := v_message || '</table><br>';
  --�ϴ� ��
  
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
