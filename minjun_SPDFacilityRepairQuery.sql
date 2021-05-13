IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SPDFacilityRepairQuery' AND xtype = 'P')    
    DROP PROC minjun_SPDFacilityRepairQuery
GO
    
/*************************************************************************************************    
 ��  �� - SP-������_�����̷���ȸ_minjun
 �ۼ��� - '2020-03-20
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SPDFacilityRepairQuery
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
           ,@FacilitySeq      INT
  
    -- Xml������ ������ ���
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT  @FacilitySeq           = ISNULL(FacilitySeq      ,  0)
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock2', @xmlFlags)
      WITH (FacilitySeq       INT)
    
    -- ����Select
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