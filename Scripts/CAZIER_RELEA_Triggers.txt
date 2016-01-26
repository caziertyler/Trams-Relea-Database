-- RELEA Database Triggers
-- Tyler Cazier 8/9/15
PRINT '';
PRINT 'Tyler Cazier CS 3550 - Final Project - RELEA Database - Triggers';
PRINT '';

-- Switch to 'master' and create custom error message.
USE MASTER;
GO

PRINT '';
PRINT 'Create custom error messages.';
PRINT '';
PRINT '';
PRINT 'Create error for when referential integrity rules are violated.';
PRINT '';
IF EXISTS(SELECT * FROM sysmessages WHERE error = 62466)
	EXEC sp_dropmessage 62466;
GO
-- Custom error messages.
EXEC sp_addmessage
@msgnum = 62466,
@severity = 16,
@msgtext = 'Sorry, the %s %s was not found in the database.  Please ensure that valid data is entered.';
GO

-- Switch to and use CAZIER_RELEA database.
USE CAZIER_RELEA;

PRINT '';
PRINT 'Create triggers that enforce referential integrity.';
PRINT '';
PRINT '';
PRINT 'Create trigger - tr_ValidPropertyID';
PRINT 'Ensures that a valid PropertyID is entered.  It references the PROPERTY table from CAZIER_TRAMS.';
PRINT '';

--Check to see if the trigger exist. If so, drop.
IF EXISTS(SELECT * FROM sys.objects WHERE name = N'tr_ValidPropertyID')
	DROP TRIGGER tr_ValidPropertyID;
GO
--New Trigger tr_UnitMustExist.
CREATE TRIGGER tr_ValidPropertyID ON VENUE
AFTER INSERT, UPDATE
AS
DECLARE @PropertyID varchar(15)
--Check to see if the inserted or updated PropertyID value is in the Property table
IF EXISTS ( SELECT 'PLACEHOLDER'
			FROM Inserted i
			LEFT OUTER JOIN
			(SELECT PropertyID
			FROM OPENQUERY (TITAN_CAZIER_RELEA, 'SELECT PropertyID FROM CAZIER_TRAMS.dbo.PROPERTY')) p
			ON i.PropertyID  = p.PropertyID
			WHERE p.PropertyID IS NULL )
	BEGIN
		SELECT @PropertyID = CONVERT(varchar(15), (SELECT PropertyID FROM Inserted))
		RAISERROR (62466,16,1,'PropertyID',@PropertyID)
		ROLLBACK
	END;
GO

--Check to see if the trigger exist. If so, drop.
IF EXISTS(SELECT * FROM sys.objects WHERE name = N'tr_ValidEventID')
	DROP TRIGGER tr_ValidEventID;
GO
--New Trigger tr_UnitMustExist.
CREATE TRIGGER tr_ValidEventID ON TICKET
AFTER INSERT, UPDATE
AS
DECLARE @EventID varchar(15)
--Check to see if the inserted or updated PropertyID value is in the Property table
IF EXISTS ( SELECT 'PLACEHOLDER'
			FROM Inserted i
			LEFT JOIN "EVENT" e
			ON i.EventID  = e.EventID
			WHERE e.EventID IS NULL )
	BEGIN
		SELECT @EventID = CONVERT(varchar(15), (SELECT EventID FROM Inserted))
		RAISERROR (62466,16,1,'EventID',@EventID)
		ROLLBACK
	END;
GO

--Check to see if the trigger exist. If so, drop.
IF EXISTS(SELECT * FROM sys.objects WHERE name = N'tr_ValidReservationtID')
	DROP TRIGGER tr_ValidReservationID;
GO
--New Trigger tr_UnitMustExist.
CREATE TRIGGER tr_ValidReservationID ON PURCHASE
AFTER INSERT, UPDATE
AS
DECLARE @ReservationID varchar(15)
--Check to see if the inserted or updated PropertyID value is in the Property table
IF EXISTS ( SELECT 'PLACEHOLDER'
			FROM Inserted i
			LEFT OUTER JOIN
			(SELECT ReservationID
			FROM OPENQUERY (TITAN_CAZIER_RELEA, 'SELECT ReservationID FROM CAZIER_TRAMS.dbo.RESERVATION')) r
			ON i.ReservationID  = r.ReservationID
			WHERE r.ReservationID IS NULL )
	BEGIN
		SELECT @ReservationID = CONVERT(varchar(15), (SELECT ReservationID FROM Inserted))
		RAISERROR (62466,16,1,'ReservationID',@ReservationID)
		ROLLBACK
	END;
GO