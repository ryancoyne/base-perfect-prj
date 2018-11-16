
CREATE OR REPLACE FUNCTION us.getTransactionReport(fromDate int, toDate int, retailerId int, terminalId int=0, retailerUserId int=0, offsetBy int=0, limitBy int=200)
RETURNS TABLE (id int, created int, amount numeric, total_amount numeric, client_location text,
client_transaction_id text, terminal_id int, disputed int, disputedby text, customer_code text, redeemed int)
AS $function$

BEGIN

IF terminalId = 0 AND retailerUserId = 0 THEN

RETURN QUERY
SELECT ct.id, ct.created, ct.amount, ct.total_amount, ct.client_location, ct.client_transaction_id, ct.terminal_id, ct.disputed, ct.disputedby, ct.customer_code, ct.redeemed
FROM us.code_transaction AS ct
WHERE (ct.created BETWEEN fromDate AND toDate) AND (ct.retailer_id = retailerId)
UNION
SELECT cth.id, cth.created, cth.amount, cth.total_amount, cth.client_location, cth.client_transaction_id, cth.terminal_id, cth.disputed, cth.disputedby, cth.customer_code, cth.redeemed
FROM us.code_transaction_history AS cth
WHERE (cth.created BETWEEN fromDate AND toDate) AND (cth.retailer_id = retailerId)
ORDER BY created DESC
OFFSET offsetBy LIMIT limitBy;

ELSIF (retailerUserId = 0) AND (terminalId > 0) THEN

RETURN QUERY
SELECT ct.id, ct.created, ct.amount, ct.total_amount, ct.client_location, ct.client_transaction_id, ct.terminal_id, ct.disputed, ct.disputedby, ct.customer_code, ct.redeemed
FROM us.code_transaction AS ct
WHERE (ct.created BETWEEN fromDate AND toDate) AND (ct.retailer_id = retailerId) AND (ct.terminal_id = terminalId)
UNION
SELECT cth.id, cth.created, cth.amount, cth.total_amount, cth.client_location, cth.client_transaction_id, cth.terminal_id, cth.disputed, cth.disputedby, cth.customer_code, cth.redeemed
FROM us.code_transaction_history AS cth
WHERE (cth.created BETWEEN fromDate AND toDate) AND (cth.retailer_id = retailerId) AND (cth.terminal_id = terminalId)
ORDER BY created DESC
OFFSET offsetBy LIMIT limitBy;

ELSIF (retailerUserId > 0) AND (terminalId > 0) THEN

RETURN QUERY
SELECT ct.id, ct.created, ct.amount, ct.total_amount, ct.client_location, ct.client_transaction_id, ct.terminal_id, ct.disputed, ct.disputedby, ct.customer_code, ct.redeemed
FROM us.code_transaction AS ct
WHERE (ct.created BETWEEN fromDate AND toDate) AND (ct.retailer_id = retailerId) AND (ct.terminal_id = terminalId) AND (ct.retailer_user_id = retailerUserId)
UNION
SELECT cth.id, cth.created, cth.amount, cth.total_amount, cth.client_location, cth.client_transaction_id, cth.terminal_id, cth.disputed, cth.disputedby, cth.customer_code, cth.redeemed
FROM us.code_transaction_history AS cth
WHERE (cth.created BETWEEN fromDate AND toDate) AND (cth.retailer_id = retailerId) AND (cth.terminal_id = terminalId) AND (cth.retailer_user_id = retailerUserId)
ORDER BY created DESC
OFFSET offsetBy LIMIT limitBy;

ELSE

RETURN QUERY
SELECT ct.id, ct.created, ct.amount, ct.total_amount, ct.client_location, ct.client_transaction_id, ct.terminal_id, ct.disputed, ct.disputedby, ct.customer_code, ct.redeemed
FROM us.code_transaction AS ct
WHERE (ct.created BETWEEN fromDate AND toDate) AND (ct.retailer_id = retailerId) AND (ct.retailer_user_id = retailerUserId)
UNION
SELECT cth.id, cth.created, cth.amount, cth.total_amount, cth.client_location, cth.client_transaction_id, cth.terminal_id, cth.disputed, cth.disputedby, cth.customer_code, cth.redeemed
FROM us.code_transaction_history AS cth
WHERE (cth.created BETWEEN fromDate AND toDate) AND (cth.retailer_id = retailerId) AND (cth.retailer_user_id = retailerUserId)
ORDER BY created DESC
OFFSET offsetBy LIMIT limitBy;
END IF;

END $function$

LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION us.getTransactionReportTotals(fromDate bigint, toDate bigint, retailerId int, terminalId int=0, retailerUserId int=0, offsetBy int=0, limitBy int=200, OUT total_count bigint, OUT total_value numeric)
AS
$$

DECLARE
var_r record;

BEGIN

total_count := 0;
total_value = 0;

IF terminalId = 0 AND retailerUserId = 0 THEN

FOR var_r IN(

SELECT ct.redeemed, count(*) over () as the_count, sum(ct.amount) over () as the_value
FROM us.code_transaction AS ct
WHERE (ct.created BETWEEN fromDate AND toDate) AND (ct.retailer_id = retailerId)
UNION
SELECT cth.redeemed, count(*) over () as the_count, sum(cth.amount) over () as the_value
FROM us.code_transaction_history AS cth
WHERE (cth.created BETWEEN fromDate AND toDate) AND (cth.retailer_id = retailerId))
LOOP
total_count := total_count + var_r.the_count;
total_value := total_value + var_r.the_value;
END LOOP;
RETURN;

ELSIF (retailerUserId = 0) AND (terminalId > 0) THEN

FOR var_r IN(

SELECT ct.redeemed, count(*) over () as the_count, sum(ct.amount) over () as the_value
FROM us.code_transaction AS ct
WHERE (ct.created BETWEEN fromDate AND toDate) AND (ct.retailer_id = retailerId) AND (ct.terminal_id = terminalId)
UNION
SELECT cth.redeemed, count(*) over () as the_count, sum(cth.amount) over () as the_value
FROM us.code_transaction_history AS cth
WHERE (cth.created BETWEEN fromDate AND toDate) AND (cth.retailer_id = retailerId) AND (cth.terminal_id = terminalId))
LOOP
total_count := total_count + var_r.the_count;
total_value := total_value + var_r.the_value;
END LOOP;
RETURN;

ELSIF (retailerUserId > 0) AND (terminalId > 0) THEN

FOR var_r IN(
SELECT ct.redeemed, count(*) over () as the_count, sum(ct.amount) over () as the_value
FROM us.code_transaction AS ct
WHERE (ct.created BETWEEN fromDate AND toDate) AND (ct.retailer_id = retailerId) AND (ct.terminal_id = terminalId) AND (ct.retailer_user_id = retailerUserId)
UNION
SELECT cth.redeemed, count(*) over () as the_count, sum(cth.amount) over () as the_value
FROM us.code_transaction_history AS cth
WHERE (cth.created BETWEEN fromDate AND toDate) AND (cth.retailer_id = retailerId) AND (cth.terminal_id = terminalId) AND (cth.retailer_user_id = retailerUserId))
LOOP
total_count := total_count + var_r.the_count;
total_value := total_value + var_r.the_value;
END LOOP;
RETURN;

ELSE

FOR var_r IN(
SELECT ct.redeemed, count(*) over () as the_count, sum(ct.amount) over () as the_value
FROM us.code_transaction AS ct
WHERE (ct.created BETWEEN fromDate AND toDate) AND (ct.retailer_id = retailerId) AND (ct.retailer_user_id = retailerUserId)
UNION
SELECT cth.redeemed, count(*) over () as the_count, sum(cth.amount) over () as the_value
FROM us.code_transaction_history AS cth
WHERE (cth.created BETWEEN fromDate AND toDate) AND (cth.retailer_id = retailerId) AND (cth.retailer_user_id = retailerUserId))
LOOP
total_count := total_count + var_r.the_count;
total_value := total_value + var_r.the_value;
END LOOP;
RETURN;
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

