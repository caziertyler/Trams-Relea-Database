-- RELEA Database Stored Procedures
-- Tyler Cazier 8/9/15
PRINT '';
PRINT 'Tyler Cazier CS 3550 - Final Project - RELEA Database -Stored Procedures';
PRINT '';

-- Switch to and use CAZIER_RELEA database.
USE CAZIER_RELEA;
GO

PRINT '';
PRINT 'Create a Stored Procedure, sp_CreateFolioTransact, that receives a dollar amount a';
PRINT 'a ticket, pass, or purchase ID and creates a new Folio Transaction based'
PRINT '';
-- Drop the function if it already exists.
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_NAME = 'sp_CreateFolioTransact')
	DROP PROCEDURE sp_CreateFolioTransact;
GO
-- Create function variables.
CREATE PROCEDURE sp_CreateFolioTransact
	(
	@TransactAmount		smallmoney,
	@RELEATransactID	bigint,
	@TransactType		char(1)
	)
AS
BEGIN
	DECLARE @ReservationID int
	DECLARE @FolioID int

	--If the purchase is a ticket, do the following:
	IF (@TransactType = 'T')
	BEGIN
		SET @ReservationID = (	SELECT ReservationID
						FROM PURCHASE p, TICKET t
						WHERE p.PurchaseID = t.PurchaseID
							AND TicketID = @ReleaTransactID )
		SET @FolioID = (	SELECT FolioID
							FROM OPENQUERY	(TITAN_CAZIER_RELEA, 'SELECT * FROM CAZIER_TRAMS.dbo.FOLIO')
							WHERE ReservationID = @ReservationID )

		INSERT INTO TITAN_CAZIER_RELEA.CAZIER_TRAMS.dbo.FOLIOTRANSACTION (
			TransDate,
			TransAmount,
			TransDescription,
			TransCategoryID,
			FolioID
			)
		VALUES (
			GETDATE(),
			@TransactAmount,
			'RELEA Ticket Purchase TicketID' + CONVERT(varchar(10), @RELEATransactID) + '.',
			16,
			@FolioID)
	END

	--If the purchase is a pass, do the following:
	ELSE IF (@TransactType = 'P')
	BEGIN
	SET @ReservationID = (	SELECT ReservationID
						FROM PURCHASE pu, PASS p
						WHERE pu.PurchaseID = p.PurchaseID
							AND PassID = @ReleaTransactID )
	SET @FolioID = (	SELECT FolioID
						FROM OPENQUERY	(TITAN_CAZIER_RELEA, 'SELECT * FROM CAZIER_TRAMS.dbo.FOLIO')
						WHERE ReservationID = @ReservationID )
			INSERT INTO TITAN_CAZIER_RELEA.CAZIER_TRAMS.dbo.FOLIOTRANSACTION (
			TransDate,
			TransAmount,
			TransDescription,
			TransCategoryID,
			FolioID
			)
		VALUES (
			GETDATE(),
			@TransactAmount,
			'RELEA Pass Purchase PassID ' + CONVERT(varchar(10), @RELEATransactID) + '.',
			17,
			@FolioID)
	END

		--If the purchase is a pass, do the following:
	ELSE IF (@TransactType = 'X')
	BEGIN
	SET @ReservationID = (	SELECT ReservationID
						FROM PURCHASE
						WHERE PurchaseID = @ReleaTransactID )
	SET @FolioID = (	SELECT FolioID
						FROM OPENQUERY	(TITAN_CAZIER_RELEA, 'SELECT * FROM CAZIER_TRAMS.dbo.FOLIO')
						WHERE ReservationID = @ReservationID )
			INSERT INTO TITAN_CAZIER_RELEA.CAZIER_TRAMS.dbo.FOLIOTRANSACTION (
			TransDate,
			TransAmount,
			TransDescription,
			TransCategoryID,
			FolioID
			)
		VALUES (
			GETDATE(),
			@TransactAmount,
			'Cancellation credit for Ticket/PassID ' + CONVERT(varchar(10), @RELEATransactID) + '.',
			11,
			@FolioID)
	END

	--Any other RELEA transaction will be a tax. Do the following:
	ELSE
	BEGIN
		SET @ReservationID = (	SELECT ReservationID
							FROM PURCHASE
							WHERE PurchaseID = @ReleaTransactID )
		SET @FolioID = (	SELECT FolioID
							FROM OPENQUERY	(TITAN_CAZIER_RELEA, 'SELECT * FROM CAZIER_TRAMS.dbo.FOLIO')
							WHERE ReservationID = @ReservationID )
		INSERT INTO TITAN_CAZIER_RELEA.CAZIER_TRAMS.dbo.FOLIOTRANSACTION (
		TransDate,
		TransAmount,
		TransDescription,
		TransCategoryID,
		FolioID
		)
		VALUES (
			GETDATE(),
			@TransactAmount,
			'RELEA Purchase Tax for PurchaseID ' + CONVERT(varchar(10), @RELEATransactID) + '.',
			15,
			@FolioID)
	END
END;
GO

PRINT '';
PRINT 'Create a Stored Procedure, sp_UpdatePurchaseTotal, that receives a dollar amount and';
PRINT 'a PurchaseID and adds the dollar amount to the purchase total.'
PRINT '';
-- Drop the function if it already exists.
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_NAME = 'sp_UpdatePurchaseTotal')
	DROP PROCEDURE sp_UpdatePurchaseTotal;

GO
-- Create funciton variables.
CREATE PROCEDURE sp_UpdatePurchaseTotal
	(
	@AmountToAdd	smallmoney,
	@PurchaseID		bigint
	)
AS
BEGIN
	UPDATE PURCHASE
	SET PurchaseTotal = PurchaseTotal + @AmountToAdd
	WHERE PurchaseID = @PurchaseID
END;
GO

PRINT '';
PRINT 'Create a Stored Procedure, sp_UpdateDiscounts, that receives a ReleaUserID and';
PRINT 'a PassID and updates the users discounts based on the pass.'
PRINT '';
-- Drop the function if it already exists.
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_NAME = 'sp_UpdateDiscounts')
	DROP PROCEDURE sp_UpdateDiscounts;

GO
-- Create funciton variables.
CREATE PROCEDURE sp_UpdateDiscounts
	(
	@ReleaUserID	int,
	@PassID			int
	)
AS
BEGIN
	DECLARE @PassTypeID smallint
	SET @PassTypeID = (	SELECT PassTypeID
						FROM PASS
						WHERE PassID = @PassID )
	IF (@PassTypeID IS NOT NULL AND @PassTypeID = 1)
	BEGIN
		UPDATE RELEAUSER
		SET ReleaBasicDiscounts = ReleaBasicDiscounts + 3
		WHERE ReleaUserID = @ReleaUserID
	END
	ELSE IF (@PassTypeID IS NOT NULL AND @PassTypeID = 2)
	BEGIN
		UPDATE RELEAUSER
		SET ReleaAllInclusiveDiscounts = ReleaAllInclusiveDiscounts + 3
		WHERE ReleaUserID = @ReleaUserID
	END
END;
GO

PRINT '';
PRINT 'Create a Stored Procedure, sp_ApplyDiscount, that receives a dollar amount and';
PRINT 'TicketID. If the purchaser has any available discounts, the discount is';
PRINT 'applied and the new dollar amount is returned.  Otherwise, the original dollar';
PRINT 'amount is returned.';
PRINT '';
-- Drop the function if it already exists.
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_NAME = 'sp_ApplyDiscount')
	DROP PROCEDURE sp_ApplyDiscount;

GO
-- Create funciton variables.
CREATE PROCEDURE sp_ApplyDiscount
	(
	@DollarAmount	smallmoney,
	@TicketID		bigint
	)
AS
BEGIN

	-- DECLARE variables
	DECLARE @BasicDiscounts tinyint
	DECLARE @AllInclusiveDiscounts tinyint
	DECLARE @FinalPrice smallmoney
	DECLARE @ReleaUserID int
	DECLARE @PurchaseID bigint

	-- SET values
	SET @FinalPrice = @DollarAmount;
	SET @BasicDiscounts = (	SELECT ReleaBasicDiscounts
							FROM TICKET t, PURCHASE p, RELEAUSER ru
							WHERE t.PurchaseID = p.PurchaseID
							  AND p.ReleaUserID = ru.ReleaUserID
							  AND t.TicketID = @TicketID )
	SET @AllInclusiveDiscounts = (	SELECT ReleaAllInclusiveDiscounts
							FROM TICKET t, PURCHASE p, RELEAUSER ru
							WHERE t.PurchaseID = p.PurchaseID
							  AND p.ReleaUserID = ru.ReleaUserID
							  AND t.TicketID = @TicketID )
	SET @ReleaUserID = (	SELECT ru.ReleaUserID
							FROM TICKET t, PURCHASE p, RELEAUSER ru
							WHERE t.PurchaseID = p.PurchaseID
							  AND p.ReleaUserID = ru.ReleaUserID
							  AND t.TicketID = @TicketID )

	SET @PurchaseID = (	SELECT PurchaseID FROM TICKET WHERE TicketID = @TicketID )
	
	--Work of stored procedure.

	-- If all-inclusive discounts are available, perform the following.
	IF (@AllInclusiveDiscounts IS NOT NULL AND @AllInclusiveDiscounts > 0)
	BEGIN
		SET @FinalPrice = (@DollarAmount *.6)

		UPDATE RELEAUSER
		SET ReleaAllInclusiveDiscounts = (@AllInclusiveDiscounts - 1)
		WHERE ReleaUserID = @ReleaUserID

		UPDATE TICKET
		SET TicketIsPremium = 1, TicketIsReduced = 1, TicketPrice = @FinalPrice
		WHERE TicketID = @TicketID
	END

	-- If basic discounts are available, perform the following.
	ELSE IF (@BasicDiscounts IS NOT NULL AND @BasicDiscounts > 0)
	BEGIN
		SET @FinalPrice = (@DollarAmount *.6)

		UPDATE RELEAUSER
		SET ReleaBasicDiscounts = (@BasicDiscounts - 1)
		WHERE ReleaUserID = @ReleaUserID

		UPDATE TICKET
		SET TicketIsReduced = 1, TicketPrice = @FinalPrice
		WHERE TicketID = @TicketID
	END

	-- If no discounts are available, return the normal rate.
	ELSE
	BEGIN
		UPDATE TICKET
		SET TicketPrice = @FinalPrice
		WHERE TicketID = @TicketID
	END


	-- Call Update Purchase
	EXEC sp_UpdatePurchaseTotal
		@AmountToAdd = @FinalPrice,
		@PurchaseID = @PurchaseID
END;
GO

PRINT '';
PRINT 'Create a stored procedure, sp_ViewBill, that takes a PurchaseID'
PRINT 'and prints all purchases associate with ID along with user details.';
PRINT '';
-- Drop the stored procedure if it already exists.
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_NAME = 'sp_ViewBill')
	DROP PROCEDURE sp_ViewBill;
GO
-- Create stored procedure variables.
CREATE PROCEDURE sp_ViewBill
	@PurchaseID		int
AS
BEGIN
	-- Declare variables for formatting output.
	DECLARE @ReleaUser			varchar(100);
DECLARE @ErrMessage			varchar(MAX);

	-- Check to make sure reservation exists.
	IF NOT EXISTS (SELECT PurchaseID FROM PURCHASE WHERE PurchaseID = @PurchaseID)
	BEGIN
		SET @ErrMessage = ('"' + CONVERT(varchar,@PurchaseID) + '" is not a valid FolioID.')
		RAISERROR (@ErrMessage, -1, -1, @PurchaseID)
		RETURN -1
	END;

	-- Format Folio Details.
	DECLARE @ReservationID int
	DECLARE @FolioID int
	DECLARE @TransDescription varchar(50)
	DECLARE @TransAmount varchar(30)
	DECLARE @TransDate	varchar(30)
	SET @ReservationID = (SELECT ReservationID FROM PURCHASE WHERE PurchaseID = @PurchaseID)
	SET @FolioID = (	SELECT FolioID
						FROM OPENQUERY	(TITAN_CAZIER_RELEA, 'SELECT * FROM CAZIER_TRAMS.dbo.FOLIO')
						WHERE ReservationID = @ReservationID ) 

	SELECT @ReleaUser = ru.ReleaFirstName + ' ' + ru.ReleaLastName
	FROM RELEAUSER ru, PURCHASE pu
	WHERE ru.ReleaUserId = pu.ReleaUserID;
	-- Print Folio Details
	PRINT'';
	PRINT 'Purchase Details:';
	Print'';
	PRINT 'Name:           ' + @ReleaUser;
	PRINT 'Purchase:	   ' + CONVERT(varchar(10), @PurchaseID);
	-- Print Transaction Details
	PRINT'';
	PRINT 'Transaction Details:';
	PRINT'';
	-- Create New Cursor
	DECLARE FolioDetailCursor CURSOR FOR
	SELECT  TransDescription, '$' + CONVERT(varchar,TransAmount), CONVERT(varchar,TransDate)
	FROM OPENQUERY	(TITAN_CAZIER_RELEA, 'SELECT * FROM CAZIER_TRAMS.dbo.FOLIO') f, OPENQUERY (TITAN_CAZIER_RELEA, 'SELECT * FROM CAZIER_TRAMS.dbo.FOLIOTRANSACTION') ft
	WHERE   f.FolioID = ft.FolioID
	  AND   f.FolioID = @FolioID
	  AND	(ft.TransDescription LIKE '%Pass%' OR ft.TransDescription LIKE '%Ticket%' OR ft.TransDescription LIKE '%Purchase%')
	  AND	f.FolioID = @FolioID
	-- Open Cursor
	OPEN FolioDetailCursor
	-- Fetch First Transaction.
	FETCH NEXT FROM FolioDetailCursor
	INTO @TransDescription, @TransAmount, @TransDate

	WHILE @@Fetch_Status = 0
	BEGIN
		PRINT 'Transaction Description:  ' + @TransDescription;
		PRINT 'Transaction Amount:       ' + @TransAmount;
		PRINT 'Transaction Date:         ' + @TransDate;
		PRINT '';

		FETCH NEXT FROM FolioDetailCursor
		INTO @TransDescription, @TransAmount, @TransDate
	END -- FETCH
	-- Close and Deallocate cursor.
	CLOSE FolioDetailCursor;
	DEALLOCATE FolioDetailCursor;
END;
GO