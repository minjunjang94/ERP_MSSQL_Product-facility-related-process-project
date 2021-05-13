IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SPDFacilityItemSave' AND xtype = 'P')    
    DROP PROC minjun_SPDFacilityItemSave 
GO
    
/*************************************************************************************************    
 설  명 - SP-설비등록:품목저장_minjun
 작성일 - '2020-03-20
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SPDFacilityItemSave
     @xmlDocument    NVARCHAR(MAX)          -- Xml데이터
    ,@xmlFlags       INT            = 0     -- XmlFlag
    ,@ServiceSeq     INT            = 0     -- 서비스 번호
    ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
    ,@CompanySeq     INT            = 1     -- 회사 번호
    ,@LanguageSeq    INT            = 1     -- 언어 번호
    ,@UserSeq        INT            = 0     -- 사용자 번호
    ,@PgmSeq         INT            = 0     -- 프로그램 번호
 AS
    DECLARE @TblName        NVARCHAR(MAX)   -- Table명
           ,@SeqName        NVARCHAR(MAX)   -- Seq명
           ,@SerlName       NVARCHAR(MAX)   -- Serl명
           ,@TblColumns     NVARCHAR(MAX)
    
    -- 테이블, 키값 명칭
    SELECT  @TblName        = N'minjun_TPDFacilityItem'
           ,@SeqName        = N'FacilitySeq'
           ,@SerlName       = N'ItemSeq'

    -- Xml데이터 임시테이블에 담기
    CREATE TABLE #TPDFacilityItem (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock3', '#TPDFacilityItem' 
    
    IF @@ERROR <> 0 RETURN
      
    -- 로그테이블 남기기(마지막 파라메터는 반드시 한줄로 보내기)  	
	SELECT @TblColumns = dbo._FGetColumnsForLog(@TblName)
    
    EXEC _SCOMLog @CompanySeq   ,      
                  @UserSeq      ,      
                  @TblName      ,		            -- 테이블명      
                  '#TPDFacilityItem'       ,		-- 임시 테이블명      
                  'FacilitySeq, ItemSeq'     ,      -- CompanySeq를 제외한 키(키가 여러개일 경우는 , 로 연결 )      
                  @TblColumns   ,                   -- 테이블 모든 필드명
                  'FacilitySeq, ItemSeq_OLD' ,      --로그를 남길 테이블과 임시테이블의 컬러 명칭이 다를 경우, ItemSeq_OLD 컬럼에 로그를 남기도록 함 (템프테이블에 키명칭이 다를 경우)
                  @PgmSeq
                    
    -- =============================================================================================================================================
    -- DELETE
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #TPDFacilityItem WHERE WorkingTag = 'D' AND Status = 0 )    
    BEGIN
        -- Master테이블 데이터 삭제
        DELETE  A
          FROM  #TPDFacilityItem                     AS M
                JOIN minjun_TPDFacilityItem          AS A  WITH(NOLOCK)  ON  A.CompanySeq       = @CompanySeq
                                                           AND  A.FacilitySeq                   = M.FacilitySeq
                                                           AND  A.ItemSeq                       = M.ItemSeq_OLD
         WHERE  M.WorkingTag    = 'D'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- Update
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #TPDFacilityItem WHERE WorkingTag = 'U' AND Status = 0 )    
    BEGIN
        UPDATE  minjun_TPDFacilityItem 
           SET   ItemSeq        = M.ItemSeq
                ,Qty            = M.Qty
                ,LastUserSeq    = @UserSeq
                ,LastDateTime   = GETDATE()
                ,PgmSeq         = @PgmSeq

          FROM  #TPDFacilityItem          AS M
                JOIN minjun_TPDFacilityItem          AS A  WITH(NOLOCK)  ON  A.CompanySeq       = @CompanySeq
                                                                        AND  A.FacilitySeq      = M.FacilitySeq
                                                                        AND  A.ItemSeq          = M.ItemSeq_OLD
         WHERE  M.WorkingTag    = 'U'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- INSERT
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #TPDFacilityItem WHERE WorkingTag = 'A' AND Status = 0 )    
    BEGIN
        INSERT INTO minjun_TPDFacilityItem (
            CompanySeq
            ,FacilitySeq
            ,ItemSeq
            ,Qty
            ,LastUserSeq
            ,LastDateTime
            ,PgmSeq
        )
        SELECT  @CompanySeq
                ,M.FacilitySeq
                ,M.ItemSeq
                ,M.Qty
                ,@UserSeq
                ,GETDATE()
                ,@PgmSeq


          FROM  #TPDFacilityItem          AS M
         WHERE  M.WorkingTag    = 'A'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    UPDATE #TPDFacilityItem
       SET ItemSeq_OLD  = ItemSeq
     where status       = 0  --'0'이면 정상적으로 작동한다는 뜻

    
    SELECT * FROM #TPDFacilityItem
   
RETURN  
 /***************************************************************************************************************/