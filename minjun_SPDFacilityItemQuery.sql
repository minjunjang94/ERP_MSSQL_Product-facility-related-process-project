IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SPDFacilityItemQuery' AND xtype = 'P')    
    DROP PROC minjun_SPDFacilityItemQuery
GO
    
/*************************************************************************************************    
 설  명 - SP-설비등록:품목조회_minjun
 작성일 - '2020-03-20
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SPDFacilityItemQuery
    @xmlDocument    NVARCHAR(MAX)          -- Xml데이터
   ,@xmlFlags       INT            = 0     -- XmlFlag
   ,@ServiceSeq     INT            = 0     -- 서비스 번호
   ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
   ,@CompanySeq     INT            = 1     -- 회사 번호
   ,@LanguageSeq    INT            = 1     -- 언어 번호
   ,@UserSeq        INT            = 0     -- 사용자 번호
   ,@PgmSeq         INT            = 0     -- 프로그램 번호
AS
    -- 변수선언
    DECLARE @docHandle      INT
           ,@FacilitySeq     INT
  
    -- Xml데이터 변수에 담기
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT  @FacilitySeq            = ISNULL(FacilitySeq       ,  0)
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock3', @xmlFlags)
      WITH (FacilitySeq        INT)
    
    -- 최종Select
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