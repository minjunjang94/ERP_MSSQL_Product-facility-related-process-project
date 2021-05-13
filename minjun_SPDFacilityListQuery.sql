IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SPDFacilityListQuery' AND xtype = 'P')    
    DROP PROC minjun_SPDFacilityListQuery
GO
    
/*************************************************************************************************    
 설  명 - SP-설비조회_minjun
 작성일 - '2020-03-23
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SPDFacilityListQuery
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
    DECLARE  @docHandle          INT
            ,@BizUnit            INT
            ,@WorkCenterSeq      INT
            ,@GuaranteeDateFr    NCHAR(8)
            ,@GuaranteeDateTo    NCHAR(8)
            ,@FacilityNo         NVARCHAR(100)
            ,@FacilityName       NVARCHAR(100)
            ,@DeptSeq            INT
            ,@EmpSeq             INT
            ,@IsUse              NCHAR(1)
            ,@IsRepair           NCHAR(1)
            

  
    -- Xml데이터 변수에 담기
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument  

    SELECT  @BizUnit            = RTRIM(LTRIM(ISNULL(BizUnit            ,  0)))
           ,@WorkCenterSeq      = RTRIM(LTRIM(ISNULL(WorkCenterSeq      ,  0)))
           ,@GuaranteeDateFr    = RTRIM(LTRIM(ISNULL(GuaranteeDateFr    , '')))
           ,@GuaranteeDateTo    = RTRIM(LTRIM(ISNULL(GuaranteeDateTo    , '')))
           ,@FacilityNo         = RTRIM(LTRIM(ISNULL(FacilityNo         , '')))
           ,@FacilityName       = RTRIM(LTRIM(ISNULL(FacilityName       , '')))
           ,@DeptSeq            = RTRIM(LTRIM(ISNULL(DeptSeq            ,  0)))
           ,@EmpSeq             = RTRIM(LTRIM(ISNULL(EmpSeq             ,  0)))
           ,@IsUse              = RTRIM(LTRIM(ISNULL(IsUse              , '')))
           ,@IsRepair           = RTRIM(LTRIM(ISNULL(IsRepair           , '')))

           
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock1', @xmlFlags)
      WITH (BizUnit             INT
           ,WorkCenterSeq       INT
           ,GuaranteeDateFr     NCHAR(8)
           ,GuaranteeDateTo     NCHAR(8)
           ,FacilityNo          NVARCHAR(100)
           ,FacilityName        NVARCHAR(100)
           ,DeptSeq             INT
           ,EmpSeq              INT
           ,IsUse               NCHAR(1)
           ,IsRepair            NCHAR(1)
           )

          IF @GuaranteeDateFr = '' SET @GuaranteeDateFr = '19000101'
          IF @GuaranteeDateTo = '' SET @GuaranteeDateTo = '99991231'       
    


    -- 최종Select
    SELECT  
                A.FacilitySeq
               ,B.BizUnitName
               ,B.BizUnit
               ,C.WorkCenterName
               ,C.WorkCenterSeq
               ,A.GuaranteeDateFr
               ,A.GuaranteeDateTo
               ,A.FacilityNo
               ,A.FacilityName
               ,D.DeptName
               ,D.DeptSeq
               ,E.EmpName
               ,E.EmpSeq
               ,A.OperTime
               ,A.IsUse
               ,CASE WHEN EXISTS(SELECT 1 
                                   FROM KNLEE_TPDFacilityRepair   WITH(NOLOCK)
                                  WHERE CompanySeq    = A.CompanySeq
                                    AND FacilitySeq   = A.FacilitySeq)    
                        THEN '1'
                        ELSE '0'
                END                 AS IsRepair
               ,A.Remark


      FROM  minjun_TPDFacility                  AS A   WITH(NOLOCK)
            LEFT OUTER JOIN _TDABizUnit         AS B   WITH(NOLOCK) ON  B.CompanySeq        = A.CompanySeq
                                                                   AND  B.BizUnit           = A.BizUnit
            LEFT OUTER JOIN _TDAEmp             AS E   WITH(NOLOCK) ON  E.CompanySeq        = A.CompanySEq
                                                                   AND  E.EmpSeq            = A.EmpSeq
            LEFT OUTER JOIN _TDADept            AS D   WITH(NOLOCK) ON  D.CompanySeq        = A.CompanySeq
                                                                   AND  D.DeptSeq           = A.DeptSeq
            LEFT OUTER JOIN _TPDBaseWorkCenter  AS C   WITH(NOLOCK) ON  C.CompanySeq        = A.CompanySeq
                                                                   AND  C.WorkCenterSeq     = A.WorkCenterSeq


     WHERE  A.CompanySeq    =  @CompanySeq
       AND (@BizUnit                = 0                 OR  B.BizUnit           = @BizUnit              )
       AND (@WorkCenterSeq          = 0                 OR  C.WorkCenterSeq     = @WorkCenterSeq        )
       AND((@GuaranteeDateFr  BETWEEN A.GuaranteeDateFr AND A.GuaranteeDateTo                           )
        OR (@GuaranteeDateTo  BETWEEN A.GuaranteeDateFr AND A.GuaranteeDateTo                           )
        OR (@GuaranteeDateFr        < A.GuaranteeDateFr AND @GuaranteeDateTo    > A.GuaranteeDateTo     ))
       AND (@FacilityNo             = ''                OR  A.FacilityNo     LIKE @FacilityNo   + '%'   )
       AND (@FacilityName           = ''                OR  A.FacilityName   LIKE @FacilityName + '%'   )
       AND (@EmpSeq                 = 0                 OR  E.EmpSeq            = @EmpSeq               )
       AND (@DeptSeq                = 0                 OR  D.DeptSeq           = @DeptSeq              )
       AND((@IsUse                  = '0'                                                               )   
        OR (@IsUse                  = '1'               AND A.IsUse             = @IsUse                ))
       AND((@IsRepair               = '0'                                                               )
        OR (@IsRepair               = '1'               AND EXISTS(SELECT 1 
                                                                     FROM KNLEE_TPDFacilityRepair   WITH(NOLOCK)
                                                                    WHERE CompanySeq    = A.CompanySeq
                                                                      AND FacilitySeq   = A.FacilitySeq)))


RETURN