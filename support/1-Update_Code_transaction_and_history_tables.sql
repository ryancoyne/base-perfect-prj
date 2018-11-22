
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
