
ALTER TABLE us.code_transaction ADD COLUMN retailer_user_id integer DEFAULT 0;
ALTER TABLE sg.code_transaction ADD COLUMN retailer_user_id integer DEFAULT 0;
ALTER TABLE us.code_transaction_history ADD COLUMN retailer_user_id integer DEFAULT 0;
ALTER TABLE sg.code_transaction_history ADD COLUMN retailer_user_id integer DEFAULT 0;

ALTER TABLE us.code_transaction ADD COLUMN event_id integer DEFAULT 0;
ALTER TABLE sg.code_transaction ADD COLUMN event_id integer DEFAULT 0;
ALTER TABLE us.code_transaction_history ADD COLUMN event_id integer DEFAULT 0;
ALTER TABLE sg.code_transaction_history ADD COLUMN event_id integer DEFAULT 0;
