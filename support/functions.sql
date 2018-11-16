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
  ELSE

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
  END IF;

END $function$

LANGUAGE plpgsql;

THE NEW FUNCTION:

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
