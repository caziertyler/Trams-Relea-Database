-- RELEA Database User Defined Functions
-- Tyler Cazier 8/9/15
PRINT '';
PRINT 'Tyler Cazier CS 3550 - Final Project - RELEA Database - User Defined Functions';
PRINT '';

-- Switch to and use CAZIER_RELEA database.
USE CAZIER_RELEA;
GO


PRINT '';
PRINT 'Write a function, fn_CalculateTicketCalculation, that takes a TicketID';
PRINT 'and calculates the penalty for cancelling.';
PRINT '';
-- Drop the function if it already exists.
IF EXISTS(SELECT name FROM sys.objects WHERE name = N'fn_CalculateTicketCancellation')
	DROP FUNCTION dbo.fn_CalculateTicketCancellation;
GO
-- Create funciton variables.
CREATE FUNCTION dbo.fn_CalculateTicketCancellation
	(
	@TicketID	bigint
	)
RETURNS smallmoney
AS
BEGIN
	-- DECLARE variables cancellation days, check in date, and cancellation fees.
	DECLARE @CancellationReturn	smallmoney
	DECLARE @CancellationDays	int
	DECLARE @EventStartDate		date
	DECLARE @TicketPrice		smallmoney

    -- Initialize variables.
	SET @CancellationDays = 12
	SET @CancellationReturn = 0
	SET @TicketPrice = (SELECT TicketPrice FROM TICKET WHERE TicketID = @TicketID)
	SET @EventStartDate = (SELECT EventStartDateTime FROM EVENT e, TICKET t WHERE t.EventID = e.EventID AND TicketID = @TicketID)
	

	-- Calculate and set Cancellation Days deposit if the reservation day is vaild.
	IF (@EventStartDate IS NOT NULL)
	BEGIN
		SET @CancellationDays = DATEDIFF(dd, GETDATE(), @EventStartDate)
	END

	-- Set the Cancellation Fee.
	SET @CancellationReturn =
	CASE
		WHEN @CancellationDays >= 12 THEN -(@TicketPrice * .8)
		WHEN @CancellationDays <= 11 AND @CancellationDays >= 7 THEN -(@TicketPrice * .5)
		WHEN @CancellationDays <= 6 AND @CancellationDays >= 2 THEN -(@TicketPrice * .3)
		ELSE -(@TicketPrice * .2)
	END
	RETURN @CancellationReturn
END;
GO

PRINT '';
PRINT 'Write a function, fn_CalculatePassCalculation, that takes a PassID';
PRINT 'and calculates the penalty for cancelling.';
PRINT '';
-- Drop the function if it already exists.
IF EXISTS(SELECT name FROM sys.objects WHERE name = N'fn_CalculatePassCancellation')
	DROP FUNCTION dbo.fn_CalculatePassCancellation;
GO
-- Create funciton variables.
CREATE FUNCTION dbo.fn_CalculatePassCancellation
	(
	@PassID	bigint
	)
RETURNS smallmoney
AS
BEGIN
	-- DECLARE variables cancellation days, check in date, and cancellation fees.
	DECLARE @CancellationReturn	smallmoney
	DECLARE @PassCost		smallmoney

    -- Initialize variables.
	SET @CancellationReturn = 0
	SET @PassCost = (SELECT PassCost FROM PASS p, PASSTYPE pt WHERE p.PassTypeID = pt.PassTypeID AND PassID = @PassID)
	RETURN @CancellationReturn
END;
GO

PRINT '';
PRINT 'Write a function, fn_CalculateTicketPrice, that takes a TicketID';
PRINT 'and calculates the cost of seat for a particular event, the TicketPice.';
PRINT '';
-- Drop the function if it already exists.
IF EXISTS(SELECT name FROM sys.objects WHERE name = N'fn_CalculateTicketPrice')
	DROP FUNCTION dbo.fn_CalculateTicketPrice;
GO
-- Create funciton variables.
CREATE FUNCTION dbo.fn_CalculateTicketPrice
	(
	@TicketID	bigint
	)
RETURNS smallmoney
AS
BEGIN
	DECLARE @EventBasePrice smallmoney
	DECLARE @SeatValueRate decimal(3,2)
	DECLARE @TicketPrice smallmoney
	SET @EventBasePrice = (SELECT EventBasePrice FROM EVENT e, TICKET t WHERE t.EventID = e.EventID AND TicketID = @TicketID)	
	SET @SeatValueRate = (SELECT SeatValueRate FROM TICKET t, SEAT s WHERE s.SeatID = t.SeatID AND TicketID = @TicketID)
	-- Calculate Ticket Price
	IF (@EventBasePrice IS NOT NULL AND @SeatValueRate IS NOT NULL)
	BEGIN
		SET @TicketPrice = CONVERT(smallmoney, (@EventBasePrice * @SeatValueRate));
	END
	ELSE
	BEGIN
		SET @TicketPrice = 0
	END
	RETURN @TicketPrice
END;
GO