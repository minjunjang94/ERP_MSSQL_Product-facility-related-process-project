IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SPDFacilityQuery' AND xtype = 'P')    
    DROP PROC minjun_SPDFacilityQuery
GO
    
/*************************************************************************************************    
 설  명 - SP-설비등록:조회_minjun
 작성일 - 2020-03-20
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SPDFacilityQuery
    @xmlDocument    NVARCHAR(MAX)           -- Xml데이터
   ,@xmlFlags       INT             = 0     -- XmlFlag
   ,@ServiceSeq     INT             = 0     -- 서비스 번호
   ,@WorkingTag     NVARCHAR(10)    = ''    -- WorkingTag
   ,@CompanySeq     INT             = 1     -- 회사 번호
   ,@LanguageSeq    INT             = 1     -- 언어 번호
   ,@UserSeq        INT             = 0     -- 사용자 번호
   ,@PgmSeq         INT             = 0     -- 프로그램 번호
AS
    -- 변수선언
    DECLARE @docHandle      INT
           ,@FacilitySeq       INT
  
    -- Xml데이터 변수에 담기
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT  @FacilitySeq       = ISNULL(FacilitySeq       ,  0)
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock1', @xmlFlags)
      WITH (FacilitySeq        INT)
    
    -- 최종Select
    SELECT  
        A.FacilitySeq
        ,D.BizUnit
        ,E.WorkCenterSeq
        ,A.GuaranteeDateFr
        ,A.GuaranteeDateTo
        ,A.FacilityNo
        ,A.FacilityName
        ,C.DeptName
        ,C.DeptSeq
        ,B.EmpSeq
        ,B.EmpName
        ,A.OperTime
        ,A.IsUse
        ,A.Remark
        ,A.FileSeq
      FROM  minjun_TPDFacility                  AS A  WITH(NOLOCK)
            LEFT OUTER JOIN _TDAEmp             AS B    WITH(NOLOCK) ON B.CompanySeq      = A.CompanySeq
                                                                    AND B.EmpSeq          = A.EmpSeq
            LEFT OUTER JOIN _TDADept            AS C    WITH(NOLOCK) ON C.CompanySeq      = A.CompanySeq
                                                                    AND C.Deptseq         = A.Deptseq
            LEFT OUTER JOIN _TDABizUnit         AS D    WITH(NOLOCK) ON D.CompanySeq      = A.CompanySeq
                                                                    AND D.BizUnit         = A.BizUnit
            LEFT OUTER JOIN _TPDBaseWorkCenter  AS E    WITH(NOLOCK) ON E.CompanySeq      = A.CompanySeq
                                                                    AND E.WorkCenterSeq   = A.WorkCenterSeq


     WHERE  A.CompanySeq    = @CompanySeq
       AND  A.FacilitySeq   = @FacilitySeq
  
RETURN