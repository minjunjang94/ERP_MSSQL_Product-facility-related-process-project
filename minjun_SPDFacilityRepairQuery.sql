IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SPDFacilityRepairQuery' AND xtype = 'P')    
    DROP PROC minjun_SPDFacilityRepairQuery
GO
    
/*************************************************************************************************    
 설  명 - SP-설비등록_수리이력조회_minjun
 작성일 - '2020-03-20
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SPDFacilityRepairQuery
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
           ,@FacilitySeq      INT
  
    -- Xml데이터 변수에 담기
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT  @FacilitySeq           = ISNULL(FacilitySeq      ,  0)
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock2', @xmlFlags)
      WITH (FacilitySeq       INT)
    
    -- 최종Select
    SELECT 
        B.FacilitySeq 
        ,B.Serl
        ,B.RepairDate
        ,B.CustSeq
        ,C.EmpName
        ,C.EmpSeq
        ,B.Amt
        ,B.Time
        ,B.Reason
        ,B.Remark
        ,B.CustSeq

      FROM  minjun_TPDFacility              AS  A  WITH(NOLOCK)
            JOIN minjun_TPDFacilityRepair   AS  B   WITH(NOLOCK) ON B.CompanySeq        = A.CompanySeq
                                                                AND B.FacilitySeq       = A.FacilitySeq
            LEFT OUTER JOIN _TDAEmp         AS  C   WITH(NOLOCK) ON C.CompanySeq        = B.CompanySeq
                                                                AND C.EmpSeq            = B.EmpSeq
     WHERE  A.CompanySeq    = @CompanySeq
       AND  A.FacilitySeq     = @FacilitySeq
  
RETURN