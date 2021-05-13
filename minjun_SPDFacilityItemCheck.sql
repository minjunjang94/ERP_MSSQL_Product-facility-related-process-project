IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SPDFacilityItemCheck' AND xtype = 'P')    
    DROP PROC minjun_SPDFacilityItemCheck
GO
    
/*************************************************************************************************    
 ��  �� - SP-������:ǰ��üũ_minjun
 �ۼ��� - '2020-03-20
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SPDFacilityItemCheck
     @xmlDocument    NVARCHAR(MAX)          -- Xml������
    ,@xmlFlags       INT            = 0     -- XmlFlag
    ,@ServiceSeq     INT            = 0     -- ���� ��ȣ
    ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
    ,@CompanySeq     INT            = 1     -- ȸ�� ��ȣ
    ,@LanguageSeq    INT            = 1     -- ��� ��ȣ
    ,@UserSeq        INT            = 0     -- ����� ��ȣ
    ,@PgmSeq         INT            = 0     -- ���α׷� ��ȣ
 AS    
    DECLARE @MessageType    INT             -- �����޽��� Ÿ��
           ,@Status         INT             -- ���º���
           ,@Results        NVARCHAR(250)   -- �������
           ,@Count          INT             -- ä�������� Row ��
           ,@Seq            INT             -- Seq
           ,@MaxNo          NVARCHAR(20)    -- ä�� ������ �ִ� No
           ,@MaxSerl        INT             -- Serl�� �ִ밪
           ,@TblName        NVARCHAR(MAX)   -- Table��
           ,@SeqName        NVARCHAR(MAX)   -- Seq��
           ,@SerlName       NVARCHAR(MAX)   -- Serl��
    
    -- ���̺�, Ű�� ��Ī
    SELECT  @TblName    = N'minjun_TPDFacilityItem'
           ,@SeqName    = N'FacilitySeq'
           ,@SerlName   = N'ItemSeq'
           ,@MaxSerl    = 0
    
    -- Xml������ �ӽ����̺� ���
    CREATE TABLE #TPDFacilityItem (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock3', '#TPDFacilityItem' 
    
    IF @@ERROR <> 0 RETURN
    
    -- üũ����
EXEC dbo._SCOMMessage   @MessageType    OUTPUT
                           ,@Status         OUTPUT
                           ,@Results        OUTPUT
                           ,6                       -- SELECT * FROM _TCAMessageLanguage WITH(NOLOCK) WHERE LanguageSeq = 1 AND Message LIKE '%�ߺ���%'
                           ,@LanguageSeq
                           ,22646, '����'                   -- SELECT * FROM _TCADictionary WITH(NOLOCK) WHERE LanguageSeq = 1 AND Word LIKE '����'
                           ,7, 'ǰ��'                   -- SELECT * FROM _TCADictionary WITH(NOLOCK) WHERE LanguageSeq = 1 AND Word LIKE 'ǰ��'
    UPDATE  #TPDFacilityItem
       SET  Result          = @Results
           ,MessageType     = @MessageType
           ,Status          = @Status
      FROM  #TPDFacilityItem    AS M
            JOIN(SELECT Z.FacilitySeq
                       ,Z.ItemSeq
                   FROM(SELECT X.FacilitySeq
                              ,X.ItemSeq
                          FROM minjun_TPDFacilityItem   AS X
                         WHERE X.CompanySeq  = @CompanySeq
                           AND X.FacilitySeq IN(SELECT  FacilitySeq 
                                                   FROM  #TPDFacilityItem 
                                                 WHERE  Status = 0)
                           AND NOT EXISTS(SELECT 1 
                                            FROM #TPDFacilityItem 
                                           WHERE WorkingTag IN('U', 'D') 
                                             AND Status = 0 
                                             AND FacilitySeq = X.FacilitySeq 
                                             AND ItemSeq_OLD = X.ItemSeq    )
                        UNION ALL
                        SELECT Y.FacilitySeq
                              ,Y.ItemSeq
                          FROM #TPDFacilityItem     AS Y
                         WHERE Y.WorkingTag IN('A', 'U')
                           AND Y.Status = 0        )AS Z
                 GROUP BY Z.FacilitySeq, Z.ItemSeq
                 HAVING COUNT(Z.ItemSeq) > 1
                               )AS A    ON  A.FacilitySeq       = M.FacilitySeq
                                       AND  A.ItemSeq           = M.ItemSeq
     WHERE  M.WorkingTag IN('A', 'U')
       AND  M.Status = 0



/*    -- ä���ؾ� �ϴ� ������ �� Ȯ��
    SELECT @Count = COUNT(1) FROM #TPDFacilityItem WHERE WorkingTag = 'A' AND Status = 0 
     
    -- ä��
    IF @Count > 0
    BEGIN
        -- Serl Max�� ��������
        SELECT  @MaxSerl    = MAX(ISNULL(A.ItemSeq, 0))
          FROM  #TPDFacilityItem                 AS M
                LEFT OUTER JOIN minjun_TPDFacilityItem  AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                              AND  A.FacilitySeq      = M.FacilitySeq
         WHERE  M.WorkingTag IN('A')
           AND  M.Status = 0                    
        
        UPDATE  #TPDFacilityItem
           SET  ItemSeq = @MaxSerl + DataSeq
         WHERE  WorkingTag  = 'A'
           AND  Status      = 0
    END
*/

   

    SELECT * FROM #TPDFacilityItem
    
RETURN