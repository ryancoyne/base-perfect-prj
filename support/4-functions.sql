
CREATE OR REPLACE FUNCTION us.getTransactionReport(fromDate bigint, toDate bigint, retailerId int, terminalId int=0, retailerUserId int=0, offsetBy int=0, limitBy int=200)
RETURNS TABLE (id int, created int, amount numeric, total_amount numeric, client_location text, client_transaction_id text, terminal_id int, disputed int, disputedby text, refunded int, refundedby text, customer_code text, redeemed int, retailer_user_id int, serial_number text)
AS $function$

BEGIN

IF terminalId = 0 AND retailerUserId = 0 THEN

RETURN QUERY
SELECT ct.id, ct.created, ct.amount, ct.total_amount, ct.client_location, ct.client_transaction_id, ct.terminal_id, ct.disputed, ct.disputedby, ct.refunded, ct.refundedby, ct.customer_code, ct.redeemed, ct.retailer_user_id, tm.serial_number
FROM us.code_transaction AS ct
JOIN us.terminal AS tm ON tm.id = ct.terminal_id
WHERE (ct.created BETWEEN fromDate AND toDate) AND (ct.retailer_id = retailerId)
UNION
SELECT cth.id, cth.created, cth.amount, cth.total_amount, cth.client_location, cth.client_transaction_id, cth.terminal_id, cth.disputed, cth.disputedby, ct.hrefunded, cth.refundedby, cth.customer_code, cth.redeemed, cth.retailer_user_id, tm.serial_number
FROM us.code_transaction_history AS cth
JOIN us.terminal AS tm ON tm.id = cth.terminal_id
WHERE (cth.created BETWEEN fromDate AND toDate) AND (cth.retailer_id = retailerId)
ORDER BY created DESC
OFFSET offsetBy LIMIT limitBy;

ELSIF (retailerUserId = 0) AND (terminalId > 0) THEN

RETURN QUERY
SELECT ct.id, ct.created, ct.amount, ct.total_amount, ct.client_location, ct.client_transaction_id, ct.terminal_id, ct.disputed, ct.disputedby, ct.refunded, ct.refundedby, ct.customer_code, ct.redeemed, ct.retailer_user_id, tm.serial_number
FROM us.code_transaction AS ct
JOIN us.terminal AS tm ON tm.id = ct.terminal_id
WHERE (ct.created BETWEEN fromDate AND toDate) AND (ct.retailer_id = retailerId) AND (ct.terminal_id = terminalId)
UNION
SELECT cth.id, cth.created, cth.amount, cth.total_amount, cth.client_location, cth.client_transaction_id, cth.terminal_id, cth.disputed, cth.disputedby, cth.refunded, cth.refundedby, cth.customer_code, cth.redeemed, cth.retailer_user_id, tm.serial_number
FROM us.code_transaction_history AS cth
JOIN us.terminal AS tm ON tm.id = cth.terminal_id
WHERE (cth.created BETWEEN fromDate AND toDate) AND (cth.retailer_id = retailerId) AND (cth.terminal_id = terminalId)
ORDER BY created DESC
OFFSET offsetBy LIMIT limitBy;

ELSIF (retailerUserId > 0) AND (terminalId > 0) THEN

RETURN QUERY
SELECT ct.id, ct.created, ct.amount, ct.total_amount, ct.client_location, ct.client_transaction_id, ct.terminal_id, ct.disputed, ct.disputedby, ct.refunded, ct.refundedby, ct.customer_code, ct.redeemed, ct.retailer_user_id, tm.serial_number
FROM us.code_transaction AS ct
JOIN us.terminal AS tm ON tm.id = ct.terminal_id
WHERE (ct.created BETWEEN fromDate AND toDate) AND (ct.retailer_id = retailerId) AND (ct.terminal_id = terminalId) AND (ct.retailer_user_id = retailerUserId)
UNION
SELECT cth.id, cth.created, cth.amount, cth.total_amount, cth.client_location, cth.client_transaction_id, cth.terminal_id, cth.disputed, cth.disputedby, cth.refunded, cth.refundedby, cth.customer_code, cth.redeemed, cth.retailer_user_id, tm.serial_number
FROM us.code_transaction_history AS cth
JOIN us.terminal AS tm ON tm.id = cth.terminal_id
WHERE (cth.created BETWEEN fromDate AND toDate) AND (cth.retailer_id = retailerId) AND (cth.terminal_id = terminalId) AND (cth.retailer_user_id = retailerUserId)
ORDER BY created DESC
OFFSET offsetBy LIMIT limitBy;

ELSE

RETURN QUERY
SELECT ct.id, ct.created, ct.amount, ct.total_amount, ct.client_location, ct.client_transaction_id, ct.terminal_id, ct.disputed, ct.disputedby, ct.refunded, ct.refundedby, ct.customer_code, ct.redeemed, ct.retailer_user_id, tm.serial_number
FROM us.code_transaction AS ct
JOIN us.terminal AS tm ON tm.id = ct.terminal_id
WHERE (ct.created BETWEEN fromDate AND toDate) AND (ct.retailer_id = retailerId) AND (ct.retailer_user_id = retailerUserId)
UNION
SELECT cth.id, cth.created, cth.amount, cth.total_amount, cth.client_location, cth.client_transaction_id, cth.terminal_id, cth.disputed, cth.disputedby, cth.refunded, cth.refundedby, cth.customer_code, cth.redeemed, cth.retailer_user_id, tm.serial_number
FROM us.code_transaction_history AS cth
JOIN us.terminal AS tm ON tm.id = cth.terminal_id
WHERE (cth.created BETWEEN fromDate AND toDate) AND (cth.retailer_id = retailerId) AND (cth.retailer_user_id = retailerUserId)
ORDER BY created DESC
OFFSET offsetBy LIMIT limitBy;
END IF;

END $function$

LANGUAGE plpgsql;

-- THIS IS THE NEW UPDATED FUNCTION FOR GETTING THE REPORT TOTAL --

CREATE OR REPLACE FUNCTION us.getTransactionReportTotals(fromDate bigint, toDate bigint, retailerId int, terminalId int=0, retailerUserId int=0, OUT total_count bigint, OUT total_value numeric, OUT total_sales numeric, OUT total_refund_value numeric, OUT total_refund_sales numeric)
AS
$$

DECLARE
var_r record;

BEGIN

total_count := 0;
total_value := 0.0;
total_sales := 0.0;
total_refund_value := 0.0;
total_refund_sales := 0.0;

IF terminalId = 0 AND retailerUserId = 0 THEN

FOR var_r IN (SELECT ct.redeemed, ct.amount, ct.total_amount, ct.refunded FROM us.code_transaction AS ct WHERE (ct.created BETWEEN fromDate AND toDate) AND (ct.retailer_id = retailerId) UNION ALL SELECT cth.redeemed, cth.amount, cth.total_amount, cth.refunded FROM us.code_transaction_history AS cth WHERE (cth.created BETWEEN fromDate AND toDate) AND (cth.retailer_id = retailerId))
LOOP
total_count := total_count + 1;
IF var_r.refunded = 0 THEN
total_value := total_value + var_r.amount;
total_sales := total_sales + var_r.total_amount;
ELSE
total_refund_value := total_refund_value + var_r.amount;
total_refund_sales := total_refund_sales + var_r.total_amount;
END IF;
END LOOP;

ELSIF (retailerUserId = 0) AND (terminalId > 0) THEN

FOR var_r IN (SELECT ct.redeemed, ct.amount, ct.total_amount, ct.refunded FROM us.code_transaction AS ct WHERE (ct.created BETWEEN fromDate AND toDate) AND (ct.retailer_id = retailerId) AND (ct.terminal_id = terminalId) UNION ALL SELECT cth.redeemed, cth.amount, cth.total_amount, cth.refunded FROM us.code_transaction_history AS cth WHERE (cth.created BETWEEN fromDate AND toDate) AND (cth.retailer_id = retailerId) AND (cth.terminal_id = terminalId))
LOOP
total_count := total_count + 1;
IF var_r.refunded = 0 THEN
total_value := total_value + var_r.amount;
total_sales := total_sales + var_r.total_amount;
ELSE
total_refund_value := total_refund_value + var_r.amount;
total_refund_sales := total_refund_sales + var_r.total_amount;
END IF;
END LOOP;

ELSIF (retailerUserId > 0) AND (terminalId > 0) THEN

FOR var_r IN (SELECT ct.redeemed, ct.amount, ct.total_amount, ct.refunded FROM us.code_transaction AS ct WHERE (ct.created BETWEEN fromDate AND toDate) AND (ct.retailer_id = retailerId) AND (ct.terminal_id = terminalId) AND (ct.retailer_user_id = retailerUserId) UNION ALL SELECT cth.redeemed, cth.amount, cth.total_amount, cth.refunded FROM us.code_transaction_history AS cth WHERE (cth.created BETWEEN fromDate AND toDate) AND (cth.retailer_id = retailerId) AND (cth.terminal_id = terminalId) AND (cth.retailer_user_id = retailerUserId))
LOOP
total_count := total_count + 1;
IF var_r.refunded = 0 THEN
total_value := total_value + var_r.amount;
total_sales := total_sales + var_r.total_amount;
ELSE
total_refund_value := total_refund_value + var_r.amount;
total_refund_sales := total_refund_sales + var_r.total_amount;
END IF;
END LOOP;

ELSE

FOR var_r IN (SELECT ct.redeemed, ct.amount, ct.total_amount, ct.refunded FROM us.code_transaction AS ct WHERE (ct.created BETWEEN fromDate AND toDate) AND (ct.retailer_id = retailerId) AND (ct.retailer_user_id = retailerUserId) UNION ALL SELECT cth.redeemed, cth.amount, cth.total_amount, cth.refunded FROM us.code_transaction_history AS cth WHERE (cth.created BETWEEN fromDate AND toDate) AND (cth.retailer_id = retailerId) AND (cth.retailer_user_id = retailerUserId))
LOOP
total_count := total_count + 1;
IF var_r.refunded = 0 THEN
total_value := total_value + var_r.amount;
total_sales := total_sales + var_r.total_amount;
ELSE
total_refund_value := total_refund_value + var_r.amount;
total_refund_sales := total_refund_sales + var_r.total_amount;
END IF;
END LOOP;

END IF;
END;
$$ LANGUAGE plpgsql;


-- THIS IS THE FUNCTION TO GET EVENTS ASSOCIATED WITH THE RETAILER: --

CREATE OR REPLACE FUNCTION us.getRetailerEvents(retailerId int, eventId int=0, fromDate int=0, toDate int=0, offsetBy int=0, limitBy int=200)
RETURNS TABLE (id int, created int, modified int, event_name text, event_message text, start_date int, end_date int, retailer_id int)
AS $function$

BEGIN

IF fromDate > 0 AND toDate > 0 AND eventId > 0 THEN

RETURN QUERY
SELECT re.id, re.created, re.modified, re.event_name, re.event_message, re.start_date, re.end_date, re.retailer_id
FROM us.retailer_event_view_deleted_no as re
WHERE ((re.start_date BETWEEN fromDate AND toDate) OR (re.end_date BETWEEN fromDate AND toDate)) AND (re.retailer_id = retailerId) AND (re.id = eventId)
ORDER BY created DESC
OFFSET offsetBy LIMIT limitBy;

ELSIF fromDate = 0 AND toDate = 0 AND eventId = 0 THEN

RETURN QUERY
SELECT re.id, re.created, re.modified, re.event_name, re.event_message, re.start_date, re.end_date, re.retailer_id
FROM us.retailer_event_view_deleted_no as re
WHERE (re.retailer_id = retailerId)
ORDER BY created DESC
OFFSET offsetBy LIMIT limitBy;

ELSIF fromDate = 0 AND toDate = 0 AND eventId > 0 THEN

RETURN QUERY
SELECT re.id, re.created, re.modified, re.event_name, re.event_message, re.start_date, re.end_date, re.retailer_id
FROM us.retailer_event_view_deleted_no as re
WHERE (re.retailer_id = retailerId) AND (re.id = eventId)
ORDER BY created DESC
OFFSET offsetBy LIMIT limitBy;

ELSE

RETURN QUERY
SELECT re.id, re.created, re.modified, re.event_name, re.event_message, re.start_date, re.end_date, re.retailer_id
FROM us.retailer_event_view_deleted_no as re
WHERE ((re.start_date BETWEEN fromDate AND toDate) OR (re.end_date BETWEEN fromDate AND toDate)) AND (re.retailer_id = retailerId)
ORDER BY created DESC
OFFSET offsetBy LIMIT limitBy;

END IF;

END $function$

LANGUAGE plpgsql;

ALTER FUNCTION us.getRetailerEvents OWNER to bucket;
ALTER FUNCTION us.getTransactionReport OWNER to bucket;
ALTER FUNCTION us.getTransactionReportTotals OWNER to bucket;
