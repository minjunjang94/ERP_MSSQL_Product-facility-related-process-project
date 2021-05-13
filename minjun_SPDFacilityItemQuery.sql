IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SPDFacilityItemQuery' AND xtype = 'P')    
    DROP PROC minjun_SPDFacilityItemQuery
GO
    
/*************************************************************************************************    
 ��  �� - SP-������:ǰ����ȸ_minjun
 �ۼ��� - '2020-03-20
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SPDFacilityItemQuery
    @xmlDocument    NVARCHAR(MAX)          -- Xml������
   ,@xmlFlags       INT            = 0     -- XmlFlag
   ,@ServiceSeq     INT            = 0     -- ���� ��ȣ
   ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
   ,@CompanySeq     INT            = 1     -- ȸ�� ��ȣ
   ,@LanguageSeq    INT            = 1     -- ��� ��ȣ
   ,@UserSeq        INT            = 0     -- ����� ��ȣ
   ,@PgmSeq         INT            = 0     -- ���α׷� ��ȣ
AS
    -- ��������
    DECLARE @docHandle      INT
           ,@FacilitySeq     INT
  
    -- Xml������ ������ ���
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT  @FacilitySeq            = ISNULL(FacilitySeq       ,  0)
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock3', @xmlFlags)
      WITH (FacilitySeq        INT)
    
    -- ����Select
    SELECT  

            A.FacilitySeq
            ,I.ItemSeq
            ,I.ItemName
            ,A.Qty
            ,U.UnitName
            ,U.UnitSeq
            ,A.ItemSeq      AS ItemSeq_OLD

      FROM  minjun_TPDFacilityItem                  AS A  WITH(NOLOCK)               
            JOIN minjun_TPDFacility                 AS A1 WITH(NOLOCK)  ON      A1.CompanySeq   = A.CompanySeq
                                                                        AND     A1.FacilitySeq  = A.FacilitySeq
            LEFT OUTER JOIN _TDAItem                AS I  WITH(NOLOCK)  ON      I.CompanySeq    = A.CompanySeq
                                                                        AND     I.ItemSeq       = A.ItemSeq
            LEFT OUTER JOIN _TDAUnit                AS U  WITH(NOLOCK)  ON      U.CompanySeq    = I.CompanySeq
                                                                        AND     U.UnitSeq       = I.UnitSeq


     WHERE  A.CompanySeq    = @CompanySeq
       AND  A.FacilitySeq   = @FacilitySeq


  
RETURN