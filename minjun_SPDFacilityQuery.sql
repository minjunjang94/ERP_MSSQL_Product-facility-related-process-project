IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SPDFacilityQuery' AND xtype = 'P')    
    DROP PROC minjun_SPDFacilityQuery
GO
    
/*************************************************************************************************    
 ��  �� - SP-������:��ȸ_minjun
 �ۼ��� - 2020-03-20
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SPDFacilityQuery
    @xmlDocument    NVARCHAR(MAX)           -- Xml������
   ,@xmlFlags       INT             = 0     -- XmlFlag
   ,@ServiceSeq     INT             = 0     -- ���� ��ȣ
   ,@WorkingTag     NVARCHAR(10)    = ''    -- WorkingTag
   ,@CompanySeq     INT             = 1     -- ȸ�� ��ȣ
   ,@LanguageSeq    INT             = 1     -- ��� ��ȣ
   ,@UserSeq        INT             = 0     -- ����� ��ȣ
   ,@PgmSeq         INT             = 0     -- ���α׷� ��ȣ
AS
    -- ��������
    DECLARE @docHandle      INT
           ,@FacilitySeq       INT
  
    -- Xml������ ������ ���
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT  @FacilitySeq       = ISNULL(FacilitySeq       ,  0)
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock1', @xmlFlags)
      WITH (FacilitySeq        INT)
    
    -- ����Select
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