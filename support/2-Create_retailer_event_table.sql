CREATE SEQUENCE us.retailer_event_id_seq INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;
CREATE SEQUENCE sg.retailer_event_id_seq INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

ALTER SEQUENCE us.retailer_user_id_seq OWNER TO bucket;
ALTER SEQUENCE sg.retailer_user_id_seq OWNER TO bucket;

CREATE TABLE IF NOT EXISTS us.retailer_event ( id integer NOT NULL DEFAULT nextval('us.retailer_event_id_seq'::regclass), created integer NOT NULL DEFAULT 0, createdby text COLLATE pg_catalog.default, modified integer NOT NULL DEFAULT 0, modifiedby text COLLATE pg_catalog.default, deleted integer NOT NULL DEFAULT 0, deletedby text COLLATE pg_catalog.default, retailer_id int default 0, event_name text COLLATE pg_catalog.default, event_message int default 0, start_date int default 0, end_date int default 0, CONSTRAINT retailer_event_pkey PRIMARY KEY (id) );

CREATE TABLE IF NOT EXISTS sg.retailer_event ( id integer NOT NULL DEFAULT nextval('sg.retailer_event_id_seq'::regclass), created integer NOT NULL DEFAULT 0, createdby text COLLATE pg_catalog.default, modified integer NOT NULL DEFAULT 0, modifiedby text COLLATE pg_catalog.default, deleted integer NOT NULL DEFAULT 0, deletedby text COLLATE pg_catalog.default, retailer_id int default 0, event_name text COLLATE pg_catalog.default, event_message int default 0, start_date int default 0, end_date int default 0, CONSTRAINT retailer_event_pkey PRIMARY KEY (id) );

ALTER TABLE us.retailer_event OWNER TO bucket;
ALTER TABLE sg.retailer_event OWNER TO bucket;
