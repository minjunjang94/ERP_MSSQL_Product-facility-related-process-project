IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SPDFacilitySave' AND xtype = 'P')    
    DROP PROC minjun_SPDFacilitySave
GO
    
/*************************************************************************************************    
 설  명 - SP-설비등록:저장_minjun
 작성일 - '2020-03-20
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SPDFacilitySave
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
           ,@ItemTblName    NVARCHAR(MAX)   -- 상세Table명
           ,@SeqName        NVARCHAR(MAX)   -- Seq명
           ,@TblColumns     NVARCHAR(MAX)
    
    -- 테이블, 키값 명칭
    SELECT  @TblName        = N'minjun_TPDFacility'
           ,@ItemTblName    = N'minjun_TPDFacilityRepair'
           ,@SeqName        = N'FacilitySeq'

    -- Xml데이터 임시테이블에 담기
    CREATE TABLE #TPDFacility (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock1', '#TPDFacility' 
    
    IF @@ERROR <> 0 RETURN
      
    -- 로그테이블 남기기(마지막 파라메터는 반드시 한줄로 보내기)  	
	SELECT @TblColumns = dbo._FGetColumnsForLog(@TblName)
    
    EXEC _SCOMLog @CompanySeq   ,      
                  @UserSeq      ,      
                  @TblName      ,		-- 테이블명      
                  '#TPDFacility'    ,		-- 임시 테이블명      
                  @SeqName      ,   -- CompanySeq를 제외한 키(키가 여러개일 경우는 , 로 연결 )      
                  @TblColumns   ,   -- 테이블 모든 필드명
                  ''            ,
                  @PgmSeq
                    
    -- =============================================================================================================================================
    -- DELETE
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #TPDFacility WHERE WorkingTag = 'D' AND Status = 0 )    
    BEGIN
        -- 디테일테이블 로그 남기기(마지막 파라메터는 반드시 한줄로 보내기)  	
    	SELECT @TblColumns = dbo._FGetColumnsForLog(@ItemTblName)
        
        -- 삭제로그 남기기
        EXEC _SCOMDELETELog @CompanySeq   ,      
                            @UserSeq      ,      
                            @ItemTblName  ,		-- 테이블명      
                            '#TPDFacility',     -- 임시 테이블명      
                            @SeqName      ,     -- CompanySeq를 제외한 키(키가 여러개일 경우는 , 로 연결 )      
                            @TblColumns   ,     -- 테이블 모든 필드명
                            ''            ,
                            @PgmSeq

        IF @@ERROR <> 0 RETURN

        -- Detail테이블 데이터 삭제
        DELETE  A
          FROM  #TPDFacility          AS M
                JOIN minjun_TPDFacilityRepair      AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                                       AND  A.FacilitySeq  = M.FacilitySeq
         WHERE  M.WorkingTag    = 'D'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
        





        SET @ItemTblName = 'minjun_TPDFacilityItem'
        -- 디테일테이블 로그 남기기(마지막 파라메터는 반드시 한줄로 보내기)  	
    	SELECT @TblColumns = dbo._FGetColumnsForLog(@ItemTblName)
        
        -- 삭제로그 남기기
        EXEC _SCOMDELETELog @CompanySeq   ,      
                            @UserSeq      ,      
                            @ItemTblName  ,		-- 테이블명      
                            '#TPDFacility',     -- 임시 테이블명      
                            @SeqName      ,     -- CompanySeq를 제외한 키(키가 여러개일 경우는 , 로 연결 )      
                            @TblColumns   ,     -- 테이블 모든 필드명
                            ''            ,
                            @PgmSeq

        IF @@ERROR <> 0 RETURN

        -- Detail테이블 데이터 삭제
        DELETE  A
          FROM  #TPDFacility          AS M
                JOIN minjun_TPDFacilityItem         AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                                       AND  A.FacilitySeq  = M.FacilitySeq
         WHERE  M.WorkingTag    = 'D'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN








        -- Master테이블 데이터 삭제
        DELETE  A
          FROM  #TPDFacility          AS M
                JOIN minjun_TPDFacility          AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                                     AND  A.FacilitySeq  = M.FacilitySeq
         WHERE  M.WorkingTag    = 'D'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- Update
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #TPDFacility WHERE WorkingTag = 'U' AND Status = 0 )    
    BEGIN
        UPDATE  A 
           SET  
            BizUnit                 = M.BizUnit         
            ,WorkCenterSeq          = M.WorkCenterSeq  
            ,FacilityName           = M.FacilityName   
            ,FacilityNo             = M.FacilityNo     
            ,DeptSeq                = M.DeptSeq        
            ,EmpSeq                 = M.EmpSeq         
            ,GuaranteeDateFr        = M.GuaranteeDateFr
            ,GuaranteeDateTo        = M.GuaranteeDateTo
            ,OperTime               = M.OperTime       
            ,IsUse                  = M.IsUse          
            ,Remark                 = M.Remark         
            ,LastUserSeq            = @UserSeq    
            ,LastDateTime           = GETDATE()
            ,PgmSeq                 = @PgmSeq
            ,FileSeq                = M.FileSeq


          FROM  #TPDFacility                        AS M
                JOIN minjun_TPDFacility             AS A  WITH(NOLOCK)  ON  A.CompanySeq        = @CompanySeq
                                                                        AND  A.FacilitySeq      = M.FacilitySeq
         WHERE  M.WorkingTag    = 'U'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- INSERT
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #TPDFacility WHERE WorkingTag = 'A' AND Status = 0 )    
    BEGIN
        INSERT INTO minjun_TPDFacility (
                CompanySeq
                ,FacilitySeq
                ,BizUnit         
                ,WorkCenterSeq  
                ,FacilityName   
                ,FacilityNo     
                ,DeptSeq        
                ,EmpSeq         
                ,GuaranteeDateFr
                ,GuaranteeDateTo
                ,OperTime       
                ,IsUse          
                ,Remark         
                ,LastUserSeq    
                ,LastDateTime   
                ,PgmSeq         
                ,FileSeq        
        )
        SELECT  
            @CompanySeq
            ,M.FacilitySeq
            ,M.BizUnit         
            ,M.WorkCenterSeq  
            ,M.FacilityName   
            ,M.FacilityNo     
            ,M.DeptSeq        
            ,M.EmpSeq         
            ,M.GuaranteeDateFr
            ,M.GuaranteeDateTo
            ,M.OperTime       
            ,M.IsUse          
            ,M.Remark   
            ,@UserSeq
            ,GETDATE()
            ,@PgmSeq
            ,M.FileSeq

          FROM  #TPDFacility    AS M
         WHERE  M.WorkingTag    = 'A'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END
    
    SELECT * FROM #TPDFacility
   
RETURN