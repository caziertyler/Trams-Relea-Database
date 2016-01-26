-- RELEA Database Tests
-- Tyler Cazier 8/9/15
PRINT '';
PRINT 'Tyler Cazier CS 3550 - Final Project - RELEA Database - Testing';
PRINT '';

-- Switch to CAZIER_RELEA.
USE CAZIER_RELEA;
GO

-- Test Functions
PRINT '';
PRINT 'Test Tickets';
PRINT '';

--Test fn_CalculateTicketCancellation
PRINT '';
PRINT 'fn_CalculateTicketCancellation - Same day cancellation.';
PRINT '';
	INSERT INTO TICKET VALUES('A',0,0,0,50.00,40,5,3);
	SELECT * FROM TICKET;
	UPDATE TICKET SET TicketPrice=dbo.fn_CalculateTicketCancellation(8) WHERE TicketID = 8;
	SELECT * FROM TICKET WHERE TicketID = 8;

PRINT '';
PRINT 'fn_CalculateTicketCancellation -  2 - 6 days out cancellation.';
PRINT '';
	INSERT INTO TICKET VALUES('A',0,0,0,50.00,40,5,1);
	SELECT * FROM TICKET;
	UPDATE TICKET SET TicketPrice=dbo.fn_CalculateTicketCancellation(10) WHERE TicketID =10;
	SELECT * FROM TICKET WHERE TicketID = 10;

PRINT '';
PRINT 'fn_CalculateTicketCancellation - 12 or more days out cancellation.';
PRINT '';
	SELECT * FROM TICKET WHERE TicketID = 5;
	UPDATE TICKET SET TicketPrice=dbo.fn_CalculateTicketCancellation(5) WHERE TicketID =5;
	SELECT * FROM TICKET WHERE TicketID = 5;

--Test fn_CalculateTicketCancellation
PRINT '';
PRINT 'fn_CalculateTicketPrice - TicketID.';
PRINT '';
	SELECT * FROM EVENT e, TICKET t, SEAT s WHERE e.EventID = t.EventID AND t.SeatID = s.SeatID AND TicketID = 5;
	UPDATE TICKET SET TicketPrice=dbo.fn_CalculateTicketPrice(5) WHERE TicketID = 5;
	SELECT * FROM TICKET WHERE TicketID = 5;

-- Test Stored Procedures
PRINT '';
PRINT 'Test Stored Procedures';
PRINT '';

-- Test sp_UpdateDiscounts
PRINT '';
PRINT 'sp_UpdateDiscounts - Test user with Basic Pass.';
PRINT '';
	PRINT '';
	PRINT 'Before Test - UserID 4.';
	PRINT '';
		SELECT * FROM RELEAUSER WHERE ReleaUserID = 4;
	PRINT '';
	PRINT 'Perform Test - UserID 4.';
	PRINT '';
		EXEC sp_UpdateDiscounts
				@ReleaUserID = 4,
				@PassID = 1
	PRINT '';
	PRINT 'After Test - UserID 4.';
		SELECT * FROM RELEAUSER WHERE ReleaUserID = 4;

PRINT '';
PRINT 'sp_UpdateDiscounts - Test user with All-Inclusive Pass.';
PRINT '';
PRINT '';
	PRINT '';
	PRINT 'Before Test - UserID 4.';
	PRINT '';
		SELECT * FROM RELEAUSER WHERE ReleaUserID = 4;
	PRINT '';
	PRINT 'Perform Test - UserID 4.';
	PRINT '';
		EXEC sp_UpdateDiscounts
				@ReleaUserID = 4,
				@PassID = 3
	PRINT '';
	PRINT 'After Test - UserID 4.';
		SELECT * FROM RELEAUSER WHERE ReleaUserID = 4;

-- Test sp_CreateFolioTransact
PRINT '';
PRINT 'sp_CreateFolioTransact - Test on ticket.';
PRINT '';
	PRINT '';
	PRINT 'Perform Test - Ticket ID = 7.';
	PRINT '';
		EXEC sp_CreateFolioTransact
				@TransactAmount = 45.00,
				@ReleaTransactID = 7,
				@TransactType = 'T'
	PRINT '';
	PRINT 'Perform Test - Pass ID = 7.';
	PRINT '';
		EXEC sp_CreateFolioTransact
				@TransactAmount = 50.00,
				@ReleaTransactID = 3,
				@TransactType = 'P'
	PRINT '';
	PRINT 'Perform Test - Pass ID = 7. (For Tax)';
	PRINT '';
		EXEC sp_CreateFolioTransact
				@TransactAmount = 12.00,
				@ReleaTransactID = 4,
				@TransactType = 'G'
	PRINT '';
	PRINT 'Display sp_CreateFolioTransact Test Results.';
		SELECT * FROM OPENQUERY (TITAN_CAZIER_RELEA, 'SELECT * FROM CAZIER_TRAMS.dbo.FOLIOTRANSACTION');

--sp_Apply Discount Test 1

PRINT '';
PRINT 'sp_Apply Discount - Test Discount on user with both all-inclusive and basic'
PRINT 'discounts.';
PRINT '';

	PRINT '';
	PRINT 'Purchase ticket for test.'
	PRINT '';

	INSERT INTO TICKET
	VALUES('A',0,0,0,35.00,100,4,4);

	PRINT '';
	PRINT 'Before Test - UserID 8, PurchaseID 4, and TicketID 8.'
	PRINT '';

	SELECT * FROM RELEAUSER WHERE ReleaUserID = 8;
	SELECT * FROM PURCHASE WHERE PurchaseID = 4;
	SELECT * FROM TICKET WHERE TicketID = 8;

	PRINT '';
	PRINT 'Test Stored Procedure.'
	PRINT '';


	EXEC sp_ApplyDiscount
			@DollarAmount = 35.00,
			@TicketID = 8

	PRINT '';
	PRINT 'After Test - UserID 8, PurchaseID 4, and TicketID 8.'
	PRINT '';
	SELECT * FROM RELEAUSER WHERE ReleaUserID = 8;
	SELECT * FROM PURCHASE WHERE PurchaseID = 4;
	SELECT * FROM TICKET WHERE TicketID = 8;

--sp_Apply Discount Test 2

PRINT '';
PRINT 'sp_Apply Discount - Test Discount on user only a basic discount.';
PRINT '';

	PRINT '';
	PRINT 'Purchase ticket for test.'
	PRINT '';

	INSERT INTO TICKET
	VALUES('A',0,0,0,15.00,100,9,9);

	PRINT '';
	PRINT 'Before Test - UserID 8, PurchaseID 4, and TicketID 8.'
	PRINT '';

	SELECT * FROM RELEAUSER WHERE ReleaUserID = 10;
	SELECT * FROM PURCHASE WHERE PurchaseID = 9;
	SELECT * FROM TICKET WHERE TicketID = 9;

	PRINT '';
	PRINT 'Test Stored Procedure.'
	PRINT '';


	EXEC sp_ApplyDiscount
			@DollarAmount = 15.00,
			@TicketID = 9

	PRINT '';
	PRINT 'After Test - UserID 8, PurchaseID 4, and TicketID 8.'
	PRINT '';
	SELECT * FROM RELEAUSER WHERE ReleaUserID = 10;
	SELECT * FROM PURCHASE WHERE PurchaseID = 9;
	SELECT * FROM TICKET WHERE TicketID = 9;

--sp_Apply Discount Test 3

PRINT '';
PRINT 'sp_Apply Discount - Test Discount on user with no discounts.';
PRINT '';

	PRINT '';
	PRINT 'Purchase ticket for test.'
	PRINT '';

	INSERT INTO TICKET
	VALUES('A',0,0,0,40.00,100,6,9);

	PRINT '';
	PRINT 'Before Test - UserID 8, PurchaseID 4, and TicketID 8.'
	PRINT '';

	SELECT * FROM RELEAUSER WHERE ReleaUserID = 3;
	SELECT * FROM PURCHASE WHERE PurchaseID = 6;
	SELECT * FROM TICKET WHERE TicketID = 10;

	PRINT '';
	PRINT 'Test Stored Procedure.'
	PRINT '';


	EXEC sp_ApplyDiscount
			@DollarAmount = 40.00,
			@TicketID = 10

	PRINT '';
	PRINT 'After Test - UserID 8, PurchaseID 4, and TicketID 8.'
	PRINT '';
	SELECT * FROM RELEAUSER WHERE ReleaUserID = 3;
	SELECT * FROM PURCHASE WHERE PurchaseID = 6;
	SELECT * FROM TICKET WHERE TicketID = 10;

PRINT '';
PRINT 'Test Triggers';
PRINT '';

PRINT '';
PRINT 'Referential Integrity';
PRINT '';

-- Referential Integrity.

PRINT '';
PRINT 'tr_ValidatePropertyID - Test insert into VENUE Table with good PropertyID.';
PRINT '';
INSERT INTO VENUE
VALUES('The Amazing Showhouse','The best Events in all of the land.','North-east end of the resort.',10000);

PRINT '';
PRINT 'tr_ValidatePropertyID - Test insert into VENUE Table with bad PropertyID.';
PRINT '';
INSERT INTO VENUE
VALUES('The Amazing Showhouse','The best Events in all of the land.','North-east end of the resort.',10050);

PRINT '';
PRINT 'tr_ValidatePropertyID - Test results.';
PRINT '';
SELECT * FROM VENUE;

PRINT '';
PRINT 'tr_ValidateEventID - Test insert into TICKET Table with good EventID.';
PRINT '';
INSERT INTO TICKET
VALUES('A',0,0,0,5.00,5,5,4);

PRINT '';
PRINT 'tr_ValidateEventID - Test insert into TICKET Table with bad EventID.';
PRINT '';
INSERT INTO TICKET
VALUES('A',0,0,0,5.00,5,5,300);

PRINT '';
PRINT 'tr_ValidatePropertyID - Test results.';
PRINT '';
SELECT * FROM TICKET;


