IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SPDFacilityRepairCheck' AND xtype = 'P')    
    DROP PROC minjun_SPDFacilityRepairCheck
GO
    
/*************************************************************************************************    
 설  명 - SP-설비등록:수리이력체크_minjun
 작성일 - '2020-03-20
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SPDFacilityRepairCheck
     @xmlDocument    NVARCHAR(MAX)          -- Xml데이터
    ,@xmlFlags       INT            = 0     -- XmlFlag
    ,@ServiceSeq     INT            = 0     -- 서비스 번호
    ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
    ,@CompanySeq     INT            = 1     -- 회사 번호
    ,@LanguageSeq    INT            = 1     -- 언어 번호
    ,@UserSeq        INT            = 0     -- 사용자 번호
    ,@PgmSeq         INT            = 0     -- 프로그램 번호
 AS    
    DECLARE @MessageType    INT             -- 오류메시지 타입
           ,@Status         INT             -- 상태변수
           ,@Results        NVARCHAR(250)   -- 결과문구
           ,@Count          INT             -- 채번데이터 Row 수
           ,@Seq            INT             -- Seq
           ,@MaxNo          NVARCHAR(20)    -- 채번 데이터 최대 No
           ,@MaxSerl        INT             -- Serl값 최대값
           ,@TblName        NVARCHAR(MAX)   -- Table명
           ,@SeqName        NVARCHAR(MAX)   -- Seq명
           ,@SerlName       NVARCHAR(MAX)   -- Serl명
    
    -- 테이블, 키값 명칭
    SELECT  @TblName    = N'minjun_TPDFacilityRepair'
           ,@SeqName    = N'FacilitySeq'
           ,@SerlName   = N'Serl'
           ,@MaxSerl    = 0
    
    -- Xml데이터 임시테이블에 담기
    CREATE TABLE #TPDFacilityRepair (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock2', '#TPDFacilityRepair' 
    
    IF @@ERROR <> 0 RETURN
    
    -- 체크구문
    EXEC dbo._SCOMMessage   @MessageType    OUTPUT
                           ,@Status         OUTPUT
                           ,@Results        OUTPUT
                           ,0                       -- SELECT * FROM _TCAMessageLanguage WITH(NOLOCK) WHERE LanguageSeq = 1 AND Message LIKE '%%'
                           ,@LanguageSeq
                           ,0, ''                   -- SELECT * FROM _TCADictionary WITH(NOLOCK) WHERE LanguageSeq = 1 AND Word LIKE '%%'
                           ,0, ''                   -- SELECT * FROM _TCADictionary WITH(NOLOCK) WHERE LanguageSeq = 1 AND Word LIKE '%%'
    UPDATE  #TPDFacilityRepair
       SET  Result          = @Results
           ,MessageType     = @MessageType
           ,Status          = @Status
      FROM  #TPDFacilityRepair     AS M
     WHERE  M.WorkingTag IN('')
       AND  M.Status = 0

    -- 채번해야 하는 데이터 수 확인
    SELECT @Count = COUNT(1) FROM #TPDFacilityRepair WHERE WorkingTag = 'A' AND Status = 0 
     
    -- 채번
    IF @Count > 0
    BEGIN
        -- Serl Max값 가져오기
        SELECT  @MaxSerl    = MAX(ISNULL(A.Serl, 0))
          FROM  #TPDFacilityRepair                 AS M
                LEFT OUTER JOIN minjun_TPDFacilityRepair  AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                                              AND  A.FacilitySeq      = M.FacilitySeq
         WHERE  M.WorkingTag IN('A')
           AND  M.Status = 0                    
        
        UPDATE  #TPDFacilityRepair
           SET  Serl = @MaxSerl + DataSeq
         WHERE  WorkingTag  = 'A'
           AND  Status      = 0
    END
   
    SELECT * FROM #TPDFacilityRepair
    
RETURN