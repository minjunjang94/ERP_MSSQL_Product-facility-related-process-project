IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SPDFacilitySave' AND xtype = 'P')    
    DROP PROC minjun_SPDFacilitySave
GO
    
/*************************************************************************************************    
 ��  �� - SP-������:����_minjun
 �ۼ��� - '2020-03-20
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SPDFacilitySave
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
           ,@ItemTblName    NVARCHAR(MAX)   -- ��Table��
           ,@SeqName        NVARCHAR(MAX)   -- Seq��
           ,@TblColumns     NVARCHAR(MAX)
    
    -- ���̺�, Ű�� ��Ī
    SELECT  @TblName        = N'minjun_TPDFacility'
           ,@ItemTblName    = N'minjun_TPDFacilityRepair'
           ,@SeqName        = N'FacilitySeq'

    -- Xml������ �ӽ����̺� ���
    CREATE TABLE #TPDFacility (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock1', '#TPDFacility' 
    
    IF @@ERROR <> 0 RETURN
      
    -- �α����̺� �����(������ �Ķ���ʹ� �ݵ�� ���ٷ� ������)  	
	SELECT @TblColumns = dbo._FGetColumnsForLog(@TblName)
    
    EXEC _SCOMLog @CompanySeq   ,      
                  @UserSeq      ,      
                  @TblName      ,		-- ���̺��      
                  '#TPDFacility'    ,		-- �ӽ� ���̺��      
                  @SeqName      ,   -- CompanySeq�� ������ Ű(Ű�� �������� ���� , �� ���� )      
                  @TblColumns   ,   -- ���̺� ��� �ʵ��
                  ''            ,
                  @PgmSeq
                    
    -- =============================================================================================================================================
    -- DELETE
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #TPDFacility WHERE WorkingTag = 'D' AND Status = 0 )    
    BEGIN
        -- ���������̺� �α� �����(������ �Ķ���ʹ� �ݵ�� ���ٷ� ������)  	
    	SELECT @TblColumns = dbo._FGetColumnsForLog(@ItemTblName)
        
        -- �����α� �����
        EXEC _SCOMDELETELog @CompanySeq   ,      
                            @UserSeq      ,      
                            @ItemTblName  ,		-- ���̺��      
                            '#TPDFacility',     -- �ӽ� ���̺��      
                            @SeqName      ,     -- CompanySeq�� ������ Ű(Ű�� �������� ���� , �� ���� )      
                            @TblColumns   ,     -- ���̺� ��� �ʵ��
                            ''            ,
                            @PgmSeq

        IF @@ERROR <> 0 RETURN

        -- Detail���̺� ������ ����
        DELETE  A
          FROM  #TPDFacility          AS M
                JOIN minjun_TPDFacilityRepair      AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                                       AND  A.FacilitySeq  = M.FacilitySeq
         WHERE  M.WorkingTag    = 'D'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
        





        SET @ItemTblName = 'minjun_TPDFacilityItem'
        -- ���������̺� �α� �����(������ �Ķ���ʹ� �ݵ�� ���ٷ� ������)  	
    	SELECT @TblColumns = dbo._FGetColumnsForLog(@ItemTblName)
        
        -- �����α� �����
        EXEC _SCOMDELETELog @CompanySeq   ,      
                            @UserSeq      ,      
                            @ItemTblName  ,		-- ���̺��      
                            '#TPDFacility',     -- �ӽ� ���̺��      
                            @SeqName      ,     -- CompanySeq�� ������ Ű(Ű�� �������� ���� , �� ���� )      
                            @TblColumns   ,     -- ���̺� ��� �ʵ��
                            ''            ,
                            @PgmSeq

        IF @@ERROR <> 0 RETURN

        -- Detail���̺� ������ ����
        DELETE  A
          FROM  #TPDFacility          AS M
                JOIN minjun_TPDFacilityItem         AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                                       AND  A.FacilitySeq  = M.FacilitySeq
         WHERE  M.WorkingTag    = 'D'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN








        -- Master���̺� ������ ����
        DELETE  A
          FROM  #TPDFacility          AS M
                JOIN minjun_TPDFacility          AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                                     AND  A.FacilitySeq  = M.FacilitySeq
         WHERE  M.WorkingTag    = 'D'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- Update
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #TPDFacility WHERE WorkingTag = 'U' AND Status = 0 )    
    BEGIN
        UPDATE  A 
           SET  
            BizUnit                 = M.BizUnit         
            ,WorkCenterSeq          = M.WorkCenterSeq  
            ,FacilityName           = M.FacilityName   
            ,FacilityNo             = M.FacilityNo     
            ,DeptSeq                = M.DeptSeq        
            ,EmpSeq                 = M.EmpSeq         
            ,GuaranteeDateFr        = M.GuaranteeDateFr
            ,GuaranteeDateTo        = M.GuaranteeDateTo
            ,OperTime               = M.OperTime       
            ,IsUse                  = M.IsUse          
            ,Remark                 = M.Remark         
            ,LastUserSeq            = @UserSeq    
            ,LastDateTime           = GETDATE()
            ,PgmSeq                 = @PgmSeq
            ,FileSeq                = M.FileSeq


          FROM  #TPDFacility                        AS M
                JOIN minjun_TPDFacility             AS A  WITH(NOLOCK)  ON  A.CompanySeq        = @CompanySeq
                                                                        AND  A.FacilitySeq      = M.FacilitySeq
         WHERE  M.WorkingTag    = 'U'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- INSERT
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #TPDFacility WHERE WorkingTag = 'A' AND Status = 0 )    
    BEGIN
        INSERT INTO minjun_TPDFacility (
                CompanySeq
                ,FacilitySeq
                ,BizUnit         
                ,WorkCenterSeq  
                ,FacilityName   
                ,FacilityNo     
                ,DeptSeq        
                ,EmpSeq         
                ,GuaranteeDateFr
                ,GuaranteeDateTo
                ,OperTime       
                ,IsUse          
                ,Remark         
                ,LastUserSeq    
                ,LastDateTime   
                ,PgmSeq         
                ,FileSeq        
        )
        SELECT  
            @CompanySeq
            ,M.FacilitySeq
            ,M.BizUnit         
            ,M.WorkCenterSeq  
            ,M.FacilityName   
            ,M.FacilityNo     
            ,M.DeptSeq        
            ,M.EmpSeq         
            ,M.GuaranteeDateFr
            ,M.GuaranteeDateTo
            ,M.OperTime       
            ,M.IsUse          
            ,M.Remark   
            ,@UserSeq
            ,GETDATE()
            ,@PgmSeq
            ,M.FileSeq

          FROM  #TPDFacility    AS M
         WHERE  M.WorkingTag    = 'A'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END
    
    SELECT * FROM #TPDFacility
   
RETURN