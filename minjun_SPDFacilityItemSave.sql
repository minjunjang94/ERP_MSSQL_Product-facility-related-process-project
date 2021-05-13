IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SPDFacilityItemSave' AND xtype = 'P')    
    DROP PROC minjun_SPDFacilityItemSave 
GO
    
/*************************************************************************************************    
 ��  �� - SP-������:ǰ������_minjun
 �ۼ��� - '2020-03-20
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SPDFacilityItemSave
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
    SELECT  @TblName        = N'minjun_TPDFacilityItem'
           ,@SeqName        = N'FacilitySeq'
           ,@SerlName       = N'ItemSeq'

    -- Xml������ �ӽ����̺� ���
    CREATE TABLE #TPDFacilityItem (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock3', '#TPDFacilityItem' 
    
    IF @@ERROR <> 0 RETURN
      
    -- �α����̺� �����(������ �Ķ���ʹ� �ݵ�� ���ٷ� ������)  	
	SELECT @TblColumns = dbo._FGetColumnsForLog(@TblName)
    
    EXEC _SCOMLog @CompanySeq   ,      
                  @UserSeq      ,      
                  @TblName      ,		            -- ���̺��      
                  '#TPDFacilityItem'       ,		-- �ӽ� ���̺��      
                  'FacilitySeq, ItemSeq'     ,      -- CompanySeq�� ������ Ű(Ű�� �������� ���� , �� ���� )      
                  @TblColumns   ,                   -- ���̺� ��� �ʵ��
                  'FacilitySeq, ItemSeq_OLD' ,      --�α׸� ���� ���̺�� �ӽ����̺��� �÷� ��Ī�� �ٸ� ���, ItemSeq_OLD �÷��� �α׸� ���⵵�� �� (�������̺� Ű��Ī�� �ٸ� ���)
                  @PgmSeq
                    
    -- =============================================================================================================================================
    -- DELETE
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #TPDFacilityItem WHERE WorkingTag = 'D' AND Status = 0 )    
    BEGIN
        -- Master���̺� ������ ����
        DELETE  A
          FROM  #TPDFacilityItem                     AS M
                JOIN minjun_TPDFacilityItem          AS A  WITH(NOLOCK)  ON  A.CompanySeq       = @CompanySeq
                                                           AND  A.FacilitySeq                   = M.FacilitySeq
                                                           AND  A.ItemSeq                       = M.ItemSeq_OLD
         WHERE  M.WorkingTag    = 'D'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- Update
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #TPDFacilityItem WHERE WorkingTag = 'U' AND Status = 0 )    
    BEGIN
        UPDATE  minjun_TPDFacilityItem 
           SET   ItemSeq        = M.ItemSeq
                ,Qty            = M.Qty
                ,LastUserSeq    = @UserSeq
                ,LastDateTime   = GETDATE()
                ,PgmSeq         = @PgmSeq

          FROM  #TPDFacilityItem          AS M
                JOIN minjun_TPDFacilityItem          AS A  WITH(NOLOCK)  ON  A.CompanySeq       = @CompanySeq
                                                                        AND  A.FacilitySeq      = M.FacilitySeq
                                                                        AND  A.ItemSeq          = M.ItemSeq_OLD
         WHERE  M.WorkingTag    = 'U'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- INSERT
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #TPDFacilityItem WHERE WorkingTag = 'A' AND Status = 0 )    
    BEGIN
        INSERT INTO minjun_TPDFacilityItem (
            CompanySeq
            ,FacilitySeq
            ,ItemSeq
            ,Qty
            ,LastUserSeq
            ,LastDateTime
            ,PgmSeq
        )
        SELECT  @CompanySeq
                ,M.FacilitySeq
                ,M.ItemSeq
                ,M.Qty
                ,@UserSeq
                ,GETDATE()
                ,@PgmSeq


          FROM  #TPDFacilityItem          AS M
         WHERE  M.WorkingTag    = 'A'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    UPDATE #TPDFacilityItem
       SET ItemSeq_OLD  = ItemSeq
     where status       = 0  --'0'�̸� ���������� �۵��Ѵٴ� ��

    
    SELECT * FROM #TPDFacilityItem
   
RETURN  
 /***************************************************************************************************************/