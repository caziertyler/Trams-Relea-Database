-- RELEA Database
-- Tyler Cazier 6/17/15
-- Comments
PRINT '';
PRINT 'Tyler Cazier CS 3550 - Final Project - RELEA Database Creation Script';
PRINT '';

-- Switch to and use 'Master' database.
USE Master;

PRINT '';
PRINT 'Create RELEA Database';
PRINT '';

-- Check to see if database already exists.  If so, delete.
IF EXISTS(SELECT * FROM sysdatabases WHERE name='CAZIER_RELEA')
DROP DATABASE CAZIER_RELEA;

GO

-- Create database.
CREATE DATABASE CAZIER_RELEA

-- Use primary partition.
ON PRIMARY
(
NAME = 'CAZIER_RELEA',
FILENAME = 'C:\Stage\CAZIER_RELEA.mdf',
SIZE = 4MB,
MAXSIZE = 4MB,
FILEGROWTH = 500KB
)

-- Create log file.
LOG ON
(
NAME = 'CAZIER_RELEA_Log',
FILENAME = 'C:\Stage\CAZIER_RELEA.ldf',
SIZE = 1200KB, 
MAXSIZE = 5MB,
FILEGROWTH = 500KB
);

GO

PRINT '';
PRINT 'Create tables.';
PRINT '';

--	Database created.  Begin creating tables.

-- Switch to and use CAZIER_RELEA database.
USE CAZIER_RELEA;

-- Create RELEAUSER Table
CREATE TABLE "RELEAUSER"
(
ReleaUserID			int				NOT NULL  IDENTITY(1,1),
ReleaFirstName		nvarchar(30)	NOT	NULL,
ReleaLastName		nvarchar(30)	NOT NULL,
ReleaUserLogin		varchar(200)	NOT	NULL,
ReleaUserPassword	varchar(20)		NOT	NULL,
ReleaAddress		varchar(200)	NOT NULL,
ReleaCity			varchar(50)		NOT NULL,
ReleaState			char(2),
ReleaPostalCode		varchar(10)		NOT NULL,
ReleaCountry		varchar(20)		NOT NULL,
ReleaBasicDiscounts tinyint			NOT NULL,
ReleaAllInclusiveDiscounts tinyint	NOT NULL
);

-- Create PERFORMER Table
CREATE TABLE "PERFORMER"
(
PerformerID			int				NOT NULL	IDENTITY(1,1),
PerformerName		nvarchar(30)	NOT NULL,
PerformerType		varchar(20)		NOT NULL
);

-- Create PASSTYPE Table
CREATE TABLE "PASSTYPE"
(
PassTypeID			smallint		NOT NULL	IDENTITY(1,1),
PassType			varchar(15)		NOT	NULL,
PassCost			smallmoney		NOT	NULL
);

-- Create SEAT Table
CREATE TABLE "SEAT"
(
SeatID				int				NOT NULL	IDENTITY(1,1),
SeatNumber			char(10)		NOT NULL,
SeatValueRate		decimal(3,2)	NOT NULL,
VenueID				int				NOT NULL
);

-- Create VENUE Table
CREATE TABLE "VENUE"
(
VenueID				int				NOT NULL	IDENTITY(1,1),
VenueName			varchar(30)		NOT	NULL,
VenueDescription	varchar(1300)	NOT NULL,
VenueLocation		varchar(100),
PropertyID			smallint		NOT NULL
);

-- Create EVENT Table
CREATE TABLE "EVENT"
(
EventID				int				NOT NULL	IDENTITY(1,1),
EventStartDateTime	smalldatetime	NOT NULL,
EventEndDateTime	smalldatetime	NOT NULL,
EventIsAdult		bit				NOT	NULL,
EventName			varchar(50)		NOT NULL,
EventBasePrice		smallmoney		NOT NULL,
VenueID				int				NOT NULL
);

-- Create PURCHASE Table
CREATE TABLE "PURCHASE"
(
PurchaseID			bigint			NOT NULL	IDENTITY(1,1),
PurchaseTotal		smallmoney		NOT NULL,
ReleaUserID			int				NOT NULL,
ReservationID		int				NOT NULL
);	

-- Create SEATPURCHASE Table
CREATE TABLE "TICKET"
(
TicketID			bigint			NOT NULL	IDENTITY(1,1),
TicketStatus		char(1)			NOT NULL,
TicketWillPickUp	bit				NOT NULL,
TicketIsReduced		bit				NOT NULL,
TicketIsPremium		bit				NOT NULL,
TicketPrice			smallmoney		NOT NULL,
SeatID				int				NOT NULL,
PurchaseID			bigint			NOT NULL,
EventID				int				NOT NULL
);

-- Create PERFORMEREVENT Table
CREATE TABLE "PERFORMEREVENT"
(
PerformerID			int				NOT NULL,
EventID				int				NOT NULL
);

-- Create PURCHASEPASS Table
CREATE TABLE "PASS"
(
PassID				int				NOT NULL	IDENTITY(1,1),
PassStatus			char(1)			NOT NULL,
PurchaseID			bigint			NOT NULL,
PassTypeID			smallint		NOT NULL	
);

GO

PRINT '';
PRINT 'Create primary-key constraints.';
PRINT '';

-- Add Primary Keys to each of the tables.

ALTER TABLE "RELEAUSER"
	ADD CONSTRAINT PK_ReleaUserID
	PRIMARY KEY (ReleaUserID);

ALTER TABLE "PERFORMER"
	ADD CONSTRAINT PK_PerformerID
	PRIMARY KEY (PerformerID);

ALTER TABLE "PASSTYPE"
	ADD CONSTRAINT PK_PassTypeID
	PRIMARY KEY (PassTypeID);

ALTER TABLE "SEAT"
	ADD CONSTRAINT PK_SeatID
	PRIMARY KEY (SeatID);

ALTER TABLE "VENUE"
	ADD CONSTRAINT PK_VenueID
	PRIMARY KEY (VenueID);

ALTER TABLE "EVENT"
	ADD CONSTRAINT PK_EventID
	PRIMARY KEY (EventID);

ALTER TABLE "PURCHASE"
	ADD CONSTRAINT PK_PurchaseID
	PRIMARY KEY (PurchaseID);

ALTER TABLE "TICKET"
	ADD CONSTRAINT PK_TicketID
	PRIMARY KEY (TicketID);

ALTER TABLE "PERFORMEREVENT"
	ADD CONSTRAINT PK_PerformerIDEventID
	PRIMARY KEY (PerformerID, EventID);

ALTER TABLE "PASS"
	ADD CONSTRAINT PK_PassID
	PRIMARY KEY (PassID);	

GO

PRINT '';
PRINT 'Create foreign-key constraints.';
PRINT '';

-- Alter each of the tables to add Foreign Keys

ALTER TABLE "SEAT"

	ADD CONSTRAINT FK_SEAT_VenueID
	FOREIGN KEY (VenueID) REFERENCES "VENUE" (VenueID)
	ON UPDATE Cascade
	ON DELETE Cascade;

ALTER TABLE "EVENT"

	ADD CONSTRAINT FK_EVENT_VenueID
	FOREIGN KEY (VenueID) REFERENCES "VENUE" (VenueID)
	ON UPDATE Cascade
	ON DELETE Cascade;

ALTER TABLE "PURCHASE"

	ADD CONSTRAINT FK_PURCHASE_ReleaUserID
	FOREIGN KEY (ReleaUserID) REFERENCES "RELEAUSER" (ReleaUserID)
	ON UPDATE Cascade
	ON DELETE Cascade;

ALTER TABLE "TICKET"

	ADD CONSTRAINT FK_TICKET_SeatID
	FOREIGN KEY (SeatID) REFERENCES "SEAT" (SeatID)
	ON UPDATE Cascade
	ON DELETE Cascade,
	
	CONSTRAINT FK_TICKET_PurchaseID
	FOREIGN KEY (PurchaseID) REFERENCES "PURCHASE" (PurchaseID)
	ON UPDATE Cascade
	ON DELETE Cascade;

ALTER TABLE "PERFORMEREVENT"

	ADD CONSTRAINT FK_PERFORMEREVENT_PerformerID
	FOREIGN KEY (PerformerID) REFERENCES "PERFORMER" (PerformerID)
	ON UPDATE Cascade
	ON DELETE Cascade,
	
	CONSTRAINT FK_PERFORMEREVENT_EventID
	FOREIGN KEY (EventID) REFERENCES "EVENT" (EventID)
	ON UPDATE Cascade
	ON DELETE Cascade;

ALTER TABLE "PASS"

	ADD CONSTRAINT FK_PASS_PurchaseID
	FOREIGN KEY (PurchaseID) REFERENCES "PURCHASE" (PurchaseID)
	ON UPDATE Cascade
	ON DELETE Cascade,
	
	CONSTRAINT FK_PASS_PassTypeID
	FOREIGN KEY (PassTypeID) REFERENCES "PASSTYPE" (PassTypeID)
	ON UPDATE Cascade
	ON DELETE Cascade;

GO

PRINT '';
PRINT 'Create check constraints.';
PRINT '';

-- Check constraints.

-- Ensure conly valid a TICKETSTATUS PurchaseStatus can be entered
ALTER TABLE "RELEAUSER"
	ADD CONSTRAINT CK_ReleaBasicDiscounts
	CHECK (ReleaBasicDiscounts >= 0
	  AND  ReleaBasicDiscounts <= 6);

ALTER TABLE "RELEAUSER"
	ADD CONSTRAINT CK_ReleaAllInclusiveDiscounts
	CHECK (ReleaAllInclusiveDiscounts >= 0
	  AND  ReleaAllInclusiveDiscounts <= 6);

ALTER TABLE "TICKET"
	ADD CONSTRAINT CK_TicketStatus
	CHECK (TicketStatus IN ('A', 'C', 'X'));

ALTER TABLE "PASS"
	ADD CONSTRAINT CK_PassStatus
	CHECK (PassStatus IN ('O', 'X'));

PRINT '';
PRINT 'Create default constraints.';
PRINT '';

-- Add defaults

-- Set PURCHASE PurchaseStatus default
ALTER TABLE "TICKET"
	ADD CONSTRAINT DK_TicketStatus
	DEFAULT 'A' FOR TicketStatus;

ALTER TABLE "PASS"
	ADD CONSTRAINT DK_PassStatus
	DEFAULT 'O' FOR PassStatus;

GO

PRINT '';
PRINT 'Populate Sample Data.';
PRINT '';

-- Populate Data	

BULK INSERT RELEAUSER FROM 'C:\stage\DATA-RELEAUSER.txt' WITH (FIELDTERMINATOR='|',FIRSTROW=1,DATAFILETYPE='widechar');
BULK INSERT PERFORMER FROM 'C:\stage\DATA-PERFORMER.txt' WITH (FIELDTERMINATOR='|',FIRSTROW=1,DATAFILETYPE='widechar');
BULK INSERT PASSTYPE FROM 'C:\stage\DATA-PASSTYPE.txt' WITH (FIELDTERMINATOR='|',FIRSTROW=1);
BULK INSERT SEAT FROM 'C:\stage\DATA-SEAT.txt' WITH (FIELDTERMINATOR='|',FIRSTROW=1);
BULK INSERT VENUE FROM 'C:\stage\DATA-VENUE.txt' WITH (FIELDTERMINATOR='|',FIRSTROW=1);
BULK INSERT "EVENT" FROM 'C:\stage\DATA-EVENT.txt' WITH (FIELDTERMINATOR='|',FIRSTROW=1);
BULK INSERT PURCHASE FROM 'C:\stage\DATA-PURCHASE.txt' WITH (FIELDTERMINATOR='|',FIRSTROW=1);
BULK INSERT TICKET FROM 'C:\stage\DATA-TICKET.txt' WITH (FIELDTERMINATOR='|',FIRSTROW=1);
BULK INSERT PERFORMEREVENT FROM 'C:\stage\DATA-PERFORMEREVENT.txt' WITH (FIELDTERMINATOR='|',FIRSTROW=1);
BULK INSERT PASS FROM 'C:\stage\DATA-PASS.txt' WITH (FIELDTERMINATOR='|',FIRSTROW=1);

USE Master;
GO

PRINT '';
PRINT 'Create new linked server. Connection is to the CAZIER_TRAMS database on the titan server.';
PRINT '';

-- Check to see if database already exists.  If so, delete.
IF EXISTS(SELECT * FROM sys.Servers WHERE name='TITAN_CAZIER_RELEA')
EXEC sp_dropserver 'TITAN_CAZIER_RELEA', 'droplogins';
GO

--  Create linked server.
Exec sp_addlinkedserver
@server='TITAN_CAZIER_RELEA',
@srvproduct='',
@provider='MSDASQL',
@provstr='DRIVER={SQL Server};SERVER=titan.cs.weber.edu,#;UID=#;PWD=#;Initial Catalog=CAZIER_TRAMS';
GO

PRINT '';
PRINT 'Define server options.';
PRINT '';

-- Create server options
Exec sp_serveroption 'TITAN_CAZIER_RELEA', 'data access', 'true'; -- Enable server.
Exec sp_serveroption 'TITAN_CAZIER_RELEA', 'rpc', 'true'; -- Allow Remote to Local.
Exec sp_serveroption 'TITAN_CAZIER_RELEA', 'rpc out', 'true'; -- Allow Local to Remote.
Exec sp_serveroption 'TITAN_CAZIER_RELEA', 'collation compatible', 'true'; -- Maps server collation.
GO

PRINT '';
PRINT 'Create linked server login.';
PRINT '';

-- Create linked server login account.
Exec sp_addlinkedsrvlogin
	@rmtsrvname='TITAN_CAZIER_RELEA',
	@useself='false',
	@locallogin='#',
	@rmtuser='#',
	@rmtpassword='#';
	GO

PRINT '';
PRINT 'Insert needed RELEA related Transaction Types into CAZIER_TRAMS database.';
PRINT '';

USE CAZIER_RELEA;
GO

-- Insert a few RELEA related Transaction Types.
INSERT INTO TITAN_CAZIER_RELEA.CAZIER_TRAMS.dbo.TRANSCATEGORY (
		TransCategoryDescription,
		TransTaxType
		)
	VALUES (
		'RELEA Ticket Purchase.',
		'G'
		);
GO

-- Insert a few RELEA related Transaction 
INSERT INTO TITAN_CAZIER_RELEA.CAZIER_TRAMS.dbo.TRANSCATEGORY (
		TransCategoryDescription,
		TransTaxType
		)
	VALUES (
		'RELEA Pass Purchase.',
		'G'
		)
