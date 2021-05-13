IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_TPDFacility' AND xtype = 'U' )
    Drop table minjun_TPDFacility

CREATE TABLE minjun_TPDFacility
(
    CompanySeq		INT 	 NOT NULL, 
    FacilitySeq		INT 	 NOT NULL, 
    BizUnit		INT 	 NULL, 
    WorkCenterSeq		INT 	 NULL, 
    FacilityName		NVARCHAR(100) 	 NULL, 
    FacilityNo		NVARCHAR(50) 	 NULL, 
    DeptSeq		INT 	 NULL, 
    EmpSeq		INT 	 NULL, 
    GuaranteeDateFr		NCHAR(8) 	 NULL, 
    GuaranteeDateTo		NCHAR(8) 	 NULL, 
    OperTime		DECIMAL(19,5) 	 NULL, 
    IsUse		NCHAR(1) 	 NULL, 
    Remark		NVARCHAR(MAX) 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL, 
    PgmSeq		INT 	 NULL, 
    FileSeq		INT 	 NULL, 
CONSTRAINT PKminjun_TPDFacility PRIMARY KEY CLUSTERED (CompanySeq ASC, FacilitySeq ASC)

)


IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_TPDFacilityLog' AND xtype = 'U' )
    Drop table minjun_TPDFacilityLog

CREATE TABLE minjun_TPDFacilityLog
(
    LogSeq		INT IDENTITY(1,1) NOT NULL, 
    LogUserSeq		INT NOT NULL, 
    LogDateTime		DATETIME NOT NULL, 
    LogType		NCHAR(1) NOT NULL, 
    LogPgmSeq		INT NULL, 
    CompanySeq		INT 	 NOT NULL, 
    FacilitySeq		INT 	 NOT NULL, 
    BizUnit		INT 	 NULL, 
    WorkCenterSeq		INT 	 NULL, 
    FacilityName		NVARCHAR(100) 	 NULL, 
    FacilityNo		NVARCHAR(50) 	 NULL, 
    DeptSeq		INT 	 NULL, 
    EmpSeq		INT 	 NULL, 
    GuaranteeDateFr		NCHAR(8) 	 NULL, 
    GuaranteeDateTo		NCHAR(8) 	 NULL, 
    OperTime		DECIMAL(19,5) 	 NULL, 
    IsUse		NCHAR(1) 	 NULL, 
    Remark		NVARCHAR(MAX) 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL, 
    PgmSeq		INT 	 NULL, 
    FileSeq		INT 	 NULL
)

CREATE UNIQUE CLUSTERED INDEX IDXTempminjun_TPDFacilityLog ON minjun_TPDFacilityLog (LogSeq)
go