-- RELEA Database Triggers
-- Tyler Cazier 8/9/15
PRINT '';
PRINT 'Tyler Cazier CS 3550 - Final Project - RELEA Database - Demonstration';
PRINT '';

-- Switch to 'master' and create custom error message.
USE CAZIER_RELEA;
GO

-- Test referential integrity across databases.  Bad ReservationID example.
INSERT INTO PURCHASE 
VALUES(0.00,8,5000);

-- Insert a good PurchaseID for testing.
INSERT INTO PURCHASE 
VALUES(0.00,8,10);

Select * from PURCHASE;

-- Create a new ticket for testing.
INSERT INTO TICKET
VALUES('A',0,0,0,0.00,19,12,7);

Select * from Ticket;

-- Display User, Ticket, Purchase, Event, Seat, and Ticket Information.
SELECT *
FROM RELEAUSER ru, PURCHASE p, EVENT e, TICKET t, SEAT s
WHERE ru.ReleaUserID = p.ReleaUserID
  AND p.PurchaseID = t.PurchaseID
  AND t.EventID = e.EventID
  AND t.SeatID = s.SeatID
  AND t.TicketID = 9;

-- Demo fn_CaclulateTicketPrice and sp_ApplyDiscounts.
DECLARE @TicketPrice smallmoney
SET @TicketPrice = dbo.fn_CalculateTicketPrice(9);

EXEC sp_ApplyDiscount
	@DollarAmount = @TicketPrice,
	@TicketID = 9;

-- Display Updated User, Ticket, Purchase, Event, Seat, and Ticket Information.
SELECT *
FROM RELEAUSER ru, PURCHASE p, EVENT e, TICKET t, SEAT s
WHERE ru.ReleaUserID = p.ReleaUserID
  AND p.PurchaseID = t.PurchaseID
  AND t.EventID = e.EventID
  AND t.SeatID = s.SeatID
  AND t.TicketID = 9;

-- Demo sp_CreateFolioTransact.
EXEC sp_CreateFolioTransact
		@TransactAmount = 37.80,
		@RELEATransactID = 9,
		@TransactType = 'T';

--Show Changes.
SELECT * FROM OPENQUERY (TITAN_CAZIER_RELEA, 'SELECT * FROM CAZIER_TRAMS.dbo.FOLIOTRANSACTION');

-- Demo sp_CreateFolioTransact.
DECLARE @CancellationCredit smallmoney;
SET @CancellationCredit = dbo.fn_CalculateTicketCancellation(10);

EXEC sp_CreateFolioTransact
		@TransactAmount = @CancellationCredit,
		@RELEATransactID = 9,
		@TransactType = 'X';

--Show Changes.
SELECT * FROM OPENQUERY (TITAN_CAZIER_RELEA, 'SELECT * FROM CAZIER_TRAMS.dbo.FOLIOTRANSACTION');

-- Demo sp_ViewBill
EXEC sp_ViewBill
	@PurchaseID =12;