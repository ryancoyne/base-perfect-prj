CREATE SEQUENCE us.retailer_user_id_seq;

ALTER SEQUENCE us.retailer_user_id_seq OWNER TO bucket;

CREATE TABLE us.retailer_user
(
    id integer NOT NULL DEFAULT nextval('us.retailer_user_id_seq'::regclass),
    created integer NOT NULL DEFAULT 0,
    createdby text COLLATE pg_catalog."default",
    modified integer NOT NULL DEFAULT 0,
    modifiedby text COLLATE pg_catalog."default",
    deleted integer NOT NULL DEFAULT 0,
    deletedby text COLLATE pg_catalog."default",
    retailer_id integer NOT NULL DEFAULT 0,
    user_custom_id text COLLATE pg_catalog."default",
    account_id text COLLATE pg_catalog."default",
    date_start integer NOT NULL DEFAULT 0,
    date_end integer NOT NULL DEFAULT 0,
    may_use_terminal boolean NOT NULL DEFAULT false,
    CONSTRAINT retailer_user_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE us.retailer_user OWNER to bucket;


CREATE SEQUENCE sg.retailer_user_id_seq;

ALTER SEQUENCE sg.retailer_user_id_seq OWNER TO bucket;

CREATE TABLE sg.retailer_user
(
    id integer NOT NULL DEFAULT nextval('sg.retailer_user_id_seq'::regclass),
    created integer NOT NULL DEFAULT 0,
    createdby text COLLATE pg_catalog."default",
    modified integer NOT NULL DEFAULT 0,
    modifiedby text COLLATE pg_catalog."default",
    deleted integer NOT NULL DEFAULT 0,
    deletedby text COLLATE pg_catalog."default",
    retailer_id integer NOT NULL DEFAULT 0,
    user_custom_id text COLLATE pg_catalog."default",
    account_id text COLLATE pg_catalog."default",
    date_start integer NOT NULL DEFAULT 0,
    date_end integer NOT NULL DEFAULT 0,
    may_use_terminal boolean NOT NULL DEFAULT false,
    CONSTRAINT retailer_user_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE sg.retailer_user OWNER to bucket;
