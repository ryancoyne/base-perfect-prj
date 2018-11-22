
-- THIS IS ALL THE NEW STUFF FOR DEV --

ALTER TABLE us.code_transaction ADD COLUMN refunded integer DEFAULT 0;
ALTER TABLE us.code_transaction ADD COLUMN refundedby text COLLATE pg_catalog.default;
ALTER TABLE us.code_transaction ADD COLUMN refunded_reason text COLLATE pg_catalog.default;

ALTER TABLE sg.code_transaction ADD COLUMN refunded integer DEFAULT 0;
ALTER TABLE sg.code_transaction ADD COLUMN refundedby text COLLATE pg_catalog.default;
ALTER TABLE sg.code_transaction ADD COLUMN refunded_reason text COLLATE pg_catalog.default;

ALTER TABLE us.code_transaction_history ADD COLUMN refunded integer DEFAULT 0;
ALTER TABLE us.code_transaction_history ADD COLUMN refundedby text COLLATE pg_catalog.default;
ALTER TABLE us.code_transaction_history ADD COLUMN refunded_reason text COLLATE pg_catalog.default;

ALTER TABLE sg.code_transaction_history ADD COLUMN refunded integer DEFAULT 0;
ALTER TABLE sg.code_transaction_history ADD COLUMN refundedby text COLLATE pg_catalog.default;
ALTER TABLE sg.code_transaction_history ADD COLUMN refunded_reason text COLLATE pg_catalog.default;





-- THIS STUFF SHOULD BE READY FOR WHEN IT GOES INTO STAGING --

ALTER TABLE us.code_transaction ADD COLUMN retailer_user_id integer DEFAULT 0;
ALTER TABLE sg.code_transaction ADD COLUMN retailer_user_id integer DEFAULT 0;
ALTER TABLE us.code_transaction_history ADD COLUMN retailer_user_id integer DEFAULT 0;
ALTER TABLE sg.code_transaction_history ADD COLUMN retailer_user_id integer DEFAULT 0;

ALTER TABLE us.code_transaction ADD COLUMN event_id integer DEFAULT 0;
ALTER TABLE sg.code_transaction ADD COLUMN event_id integer DEFAULT 0;
ALTER TABLE us.code_transaction_history ADD COLUMN event_id integer DEFAULT 0;
ALTER TABLE sg.code_transaction_history ADD COLUMN event_id integer DEFAULT 0;
