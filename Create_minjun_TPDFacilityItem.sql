IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_TPDFacilityItem' AND xtype = 'U' )
    Drop table minjun_TPDFacilityItem

CREATE TABLE minjun_TPDFacilityItem
(
    CompanySeq		INT 	 NOT NULL, 
    FacilitySeq		INT 	 NOT NULL, 
    ItemSeq		INT 	 NOT NULL, 
    Qty		DECIMAL(19,5) 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL, 
    PgmSeq		INT 	 NULL, 
    FileSeq		INT 	 NULL, 
CONSTRAINT PKminjun_TPDFacilityItem PRIMARY KEY CLUSTERED (CompanySeq ASC, FacilitySeq ASC, ItemSeq ASC)

)


IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_TPDFacilityItemLog' AND xtype = 'U' )
    Drop table minjun_TPDFacilityItemLog

CREATE TABLE minjun_TPDFacilityItemLog
(
    LogSeq		INT IDENTITY(1,1) NOT NULL, 
    LogUserSeq		INT NOT NULL, 
    LogDateTime		DATETIME NOT NULL, 
    LogType		NCHAR(1) NOT NULL, 
    LogPgmSeq		INT NULL, 
    CompanySeq		INT 	 NOT NULL, 
    FacilitySeq		INT 	 NOT NULL, 
    ItemSeq		INT 	 NOT NULL, 
    Qty		DECIMAL(19,5) 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL, 
    PgmSeq		INT 	 NULL, 
    FileSeq		INT 	 NULL
)

CREATE UNIQUE CLUSTERED INDEX IDXTempminjun_TPDFacilityItemLog ON minjun_TPDFacilityItemLog (LogSeq)
go