IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_TPDFacilityRepair' AND xtype = 'U' )
    Drop table minjun_TPDFacilityRepair

CREATE TABLE minjun_TPDFacilityRepair
(
    CompanySeq		INT 	 NOT NULL, 
    FacilitySeq		INT 	 NOT NULL, 
    Serl		INT 	 NOT NULL, 
    RepairDate		NCHAR(8) 	 NULL, 
    CustSeq		INT 	 NULL, 
    EmpSeq		INT 	 NULL, 
    Amt		DECIMAL(19,5) 	 NULL, 
    Time		DECIMAL(19,5) 	 NULL, 
    Reason		NVARCHAR(MAX) 	 NULL, 
    Remark		NVARCHAR(MAX) 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL, 
    PgmSeq		INT 	 NULL, 
    FileSeq		INT 	 NULL, 
CONSTRAINT PKminjun_TPDFacilityRepair PRIMARY KEY CLUSTERED (CompanySeq ASC, FacilitySeq ASC, Serl ASC)

)


IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_TPDFacilityRepairLog' AND xtype = 'U' )
    Drop table minjun_TPDFacilityRepairLog

CREATE TABLE minjun_TPDFacilityRepairLog
(
    LogSeq		INT IDENTITY(1,1) NOT NULL, 
    LogUserSeq		INT NOT NULL, 
    LogDateTime		DATETIME NOT NULL, 
    LogType		NCHAR(1) NOT NULL, 
    LogPgmSeq		INT NULL, 
    CompanySeq		INT 	 NOT NULL, 
    FacilitySeq		INT 	 NOT NULL, 
    Serl		INT 	 NOT NULL, 
    RepairDate		NCHAR(8) 	 NULL, 
    CustSeq		INT 	 NULL, 
    EmpSeq		INT 	 NULL, 
    Amt		DECIMAL(19,5) 	 NULL, 
    Time		DECIMAL(19,5) 	 NULL, 
    Reason		NVARCHAR(MAX) 	 NULL, 
    Remark		NVARCHAR(MAX) 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL, 
    PgmSeq		INT 	 NULL, 
    FileSeq		INT 	 NULL
)

CREATE UNIQUE CLUSTERED INDEX IDXTempminjun_TPDFacilityRepairLog ON minjun_TPDFacilityRepairLog (LogSeq)
go