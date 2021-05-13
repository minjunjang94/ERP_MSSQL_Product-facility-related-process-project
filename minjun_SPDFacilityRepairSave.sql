IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SPDFacilityRepairSave' AND xtype = 'P')    
    DROP PROC minjun_SPDFacilityRepairSave
GO
    
/*************************************************************************************************    
 ��  �� - SP-������:�����̷�����_minjun
 �ۼ��� - '2020-03-20
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SPDFacilityRepairSave
     @xmlDocument    NVARCHAR(MAX)          -- Xml������
    ,@xmlFlags       INT            = 0     -- XmlFlag
    ,@ServiceSeq     INT            = 0     -- ���� ��ȣ
    ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
    ,@CompanySeq     INT            = 1     -- ȸ�� ��ȣ
    ,@LanguageSeq    INT            = 1     -- ��� ��ȣ
    ,@UserSeq        INT            = 0     -- ����� ��ȣ
    ,@PgmSeq         INT            = 0     -- ���α׷� ��ȣ
 AS
    DECLARE @TblName        NVARCHAR(MAX)   -- Table��
           ,@SeqName        NVARCHAR(MAX)   -- Seq��
           ,@SerlName       NVARCHAR(MAX)   -- Serl��
           ,@TblColumns     NVARCHAR(MAX)
    
    -- ���̺�, Ű�� ��Ī
    SELECT  @TblName        = N'minjun_TPDFacilityRepair'
           ,@SeqName        = N'FacilitySeq'
           ,@SerlName       = N'Serl'

    -- Xml������ �ӽ����̺� ���
    CREATE TABLE #TPDFacilityRepair (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock2', '#TPDFacilityRepair' 
    
    IF @@ERROR <> 0 RETURN
      
    -- �α����̺� �����(������ �Ķ���ʹ� �ݵ�� ���ٷ� ������)  	
	SELECT @TblColumns = dbo._FGetColumnsForLog(@TblName)
    
    EXEC _SCOMLog @CompanySeq   ,      
                  @UserSeq      ,      
                  @TblName      ,		        -- ���̺��      
                  '#TPDFacilityRepair' ,		-- �ӽ� ���̺��      
                  'FacilitySeq, Serl' ,         -- CompanySeq�� ������ Ű(Ű�� �������� ���� , �� ���� )      
                  @TblColumns   ,               -- ���̺� ��� �ʵ��
                  ''            ,
                  @PgmSeq
                    
    -- =============================================================================================================================================
    -- DELETE
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #TPDFacilityRepair WHERE WorkingTag = 'D' AND Status = 0 )    
    BEGIN
        -- Master���̺� ������ ����
        DELETE  A
          FROM  #TPDFacilityRepair                      AS M
                JOIN minjun_TPDFacilityRepair           AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                                            AND  A.FacilitySeq       = M.FacilitySeq
                                                                            AND  A.Serl              = M.Serl
         WHERE  M.WorkingTag    = 'D'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- Update
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #TPDFacilityRepair WHERE WorkingTag = 'U' AND Status = 0 )    
    BEGIN
        UPDATE  minjun_TPDFacilityRepair 
           SET  
            RepairDate      = M.RepairDate      
            ,CustSeq        = M.CustSeq         
            ,EmpName        = M.EmpName         
            ,EmpSeq         = M.EmpSeq          
            ,Amt            = M.Amt             
            ,Time           = M.Time            
            ,Reason         = M.Reason          
            ,Remark         = M.Remark   
            ,FileSeq        = M.FileSeq                
            ,LastUserSeq    = @UserSeq                                
            ,LastDateTime   = GETDATE() 
            ,PgmSeq         = @PgmSeq   
                     
                                        
          FROM  #TPDFacilityRepair                      AS M
                JOIN minjun_TPDFacilityRepair           AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                                            AND  A.FacilitySeq  = M.FacilitySeq
                                                                            AND  A.Serl         = M.Serl
         WHERE  M.WorkingTag    = 'U'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- INSERT
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #TPDFacilityRepair WHERE WorkingTag = 'A' AND Status = 0 )    
    BEGIN
        INSERT INTO minjun_TPDFacilityRepair (
                CompanySeq
                ,FacilitySeq
                ,Serl
                ,RepairDate
                ,CustSeq
                ,EmpSeq
                ,Amt
                ,Time
                ,Reason
                ,Remark
                ,LastUserSeq
                ,LastDateTime
                ,PgmSeq
                ,FileSeq
        )
        SELECT  
            @CompanySeq
            ,M.FacilitySeq
            ,M.Serl
            ,M.RepairDate
            ,M.CustSeq
            ,M.EmpSeq         
            ,M.Amt            
            ,M.Time           
            ,M.Reason         
            ,M.Remark         
            ,@UserSeq      
            ,GETDATE() 
            ,@PgmSeq   
            ,M.FileSeq        
                            

          FROM  #TPDFacilityRepair          AS M
         WHERE  M.WorkingTag    = 'A'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END
    
    SELECT * FROM #TPDFacilityRepair
   
RETURN  
 /***************************************************************************************************************/