IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SPDFacilityItemCheck' AND xtype = 'P')    
    DROP PROC minjun_SPDFacilityItemCheck
GO
    
/*************************************************************************************************    
 설  명 - SP-설비등록:품목체크_minjun
 작성일 - '2020-03-20
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SPDFacilityItemCheck
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
    SELECT  @TblName    = N'minjun_TPDFacilityItem'
           ,@SeqName    = N'FacilitySeq'
           ,@SerlName   = N'ItemSeq'
           ,@MaxSerl    = 0
    
    -- Xml데이터 임시테이블에 담기
    CREATE TABLE #TPDFacilityItem (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock3', '#TPDFacilityItem' 
    
    IF @@ERROR <> 0 RETURN
    
    -- 체크구문
EXEC dbo._SCOMMessage   @MessageType    OUTPUT
                           ,@Status         OUTPUT
                           ,@Results        OUTPUT
                           ,6                       -- SELECT * FROM _TCAMessageLanguage WITH(NOLOCK) WHERE LanguageSeq = 1 AND Message LIKE '%중복된%'
                           ,@LanguageSeq
                           ,22646, '생산'                   -- SELECT * FROM _TCADictionary WITH(NOLOCK) WHERE LanguageSeq = 1 AND Word LIKE '생산'
                           ,7, '품목'                   -- SELECT * FROM _TCADictionary WITH(NOLOCK) WHERE LanguageSeq = 1 AND Word LIKE '품목'
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



/*    -- 채번해야 하는 데이터 수 확인
    SELECT @Count = COUNT(1) FROM #TPDFacilityItem WHERE WorkingTag = 'A' AND Status = 0 
     
    -- 채번
    IF @Count > 0
    BEGIN
        -- Serl Max값 가져오기
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