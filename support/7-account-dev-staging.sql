--
-- PostgreSQL database dump
--

-- Dumped from database version 10.4
-- Dumped by pg_dump version 10.4

-- Started on 2018-12-06 10:54:42 EST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4775 (class 0 OID 452226)
-- Dependencies: 217
-- Data for Name: account; Type: TABLE DATA; Schema: public; Owner: bucket
--

INSERT INTO public.account (id, username, password, email, usertype, source, remoteid, passvalidation, passreset, detail) VALUES ('SAMPLE1S-AMPL-E1SA-MPLE-1SAMPLE1SAMP', 'sample1', 'ce5ed7d9905e319990cde1499c7356c7c05ae1a3d58a3a0bee9d40777c462bbb', 'bucket.sample1@gmail.com', 'standard', 'local', '', '', '', '{"created": 1540308993}');
INSERT INTO public.account (id, username, password, email, usertype, source, remoteid, passvalidation, passreset, detail) VALUES ('SAMPLE2S-AMPL-E2SA-MPLE-2SAMPLE2SAMP', 'sample2', 'ce5ed7d9905e319990cde1499c7356c7c05ae1a3d58a3a0bee9d40777c462bbb', 'bucket.sample2@gmail.com', 'standard', 'local', '', '', '', '{"created": 1540308993}');
INSERT INTO public.account (id, username, password, email, usertype, source, remoteid, passvalidation, passreset, detail) VALUES ('AUTO_CREATED_USER', 'AUTO_CREATED_USER', NULL, 'testing@buckettechnologies.com', 'standard', 'local', NULL, NULL, NULL, '{"created": 1540308994}');
INSERT INTO public.account (id, username, password, email, usertype, source, remoteid, passvalidation, passreset, detail) VALUES ('AUTO_MODIFIED_USER', 'AUTO_MODIFIED_USER', NULL, 'testing@buckettechnologies.com', 'standard', 'local', NULL, NULL, NULL, '{"created": 1540308994}');
INSERT INTO public.account (id, username, password, email, usertype, source, remoteid, passvalidation, passreset, detail) VALUES ('AUTO_DELETED_USER', 'AUTO_DELETED_USER', NULL, 'testing@buckettechnologies.com', 'standard', 'local', NULL, NULL, NULL, '{"created": 1540308994}');
INSERT INTO public.account (id, username, password, email, usertype, source, remoteid, passvalidation, passreset, detail) VALUES ('DDFC31B4-E629-4757-A825-3AA910946438', 'bucketme1', NULL, 'bucket1@buckettechnologies.com', 'standard', 'local', NULL, NULL, NULL, '{"created": 1540308994}');
INSERT INTO public.account (id, username, password, email, usertype, source, remoteid, passvalidation, passreset, detail) VALUES ('74661586-8147-4073-8B0D-8DA2946C4D0D', 'bucketme2', NULL, 'bucket2@buckettechnologies.com', 'standard', 'local', NULL, NULL, NULL, '{"created": 1540308994}');
INSERT INTO public.account (id, username, password, email, usertype, source, remoteid, passvalidation, passreset, detail) VALUES ('6EFEE12F-D08C-41A9-9349-381E73352280', 'bucketme3', NULL, 'bucket3@buckettechnologies.com', 'standard', 'local', NULL, NULL, NULL, '{"created": 1540308994}');
INSERT INTO public.account (id, username, password, email, usertype, source, remoteid, passvalidation, passreset, detail) VALUES ('sVvhSbe24EGxT53D5uRdhA', '', '64b4d0f47c93ce23d157e68a58767356283dc9b63c459d45d0e0e39b3a64b9b9', 'mike@clearcodex.com', 'admin', 'local', '', 'AaGFZOZprpF_ZdW5MjDloQ', 'CqAT0Lb5dawtKG3x5vq16g', '{"created": 1541693794, "countries": ["us"], "last_seen": 1541693836}');
INSERT INTO public.account (id, username, password, email, usertype, source, remoteid, passvalidation, passreset, detail) VALUES ('sVvhSbe24EGxT53D512345', 'mikesilvers', '64b4d0f47c93ce23d157e68a58767356283dc9b63c459d45d0e0e39b3a64b9b9', '', 'standard', 'local', '', 'AaGFZOZprpF_ZdW5MXDloQ', 'CqAT0Lb5dawtKG3x5vX16g', '{"created": 1541693794, "retailer": "us.1", "last_seen": 1541693836}');
INSERT INTO public.account (id, username, password, email, usertype, source, remoteid, passvalidation, passreset, detail) VALUES ('sVvhSbe24EGxT53D54321', 'retailer_standard', '64b4d0f47c93ce23d157e68a58767356283dc9b63c459d45d0e0e39b3a64b9b9', NULL, 'admin3', 'local', NULL, NULL, NULL, '{"created": 1541693794, "retailer": "us.3", "last_seen": 1541693836}');
INSERT INTO public.account (id, username, password, email, usertype, source, remoteid, passvalidation, passreset, detail) VALUES ('sVvhSbe24EGxT53333444', 'retailer_admin', '64b4d0f47c93ce23d157e68a58767356283dc9b63c459d45d0e0e39b3a64b9b9', NULL, 'admin2', 'local', NULL, NULL, NULL, '{"created": 1541693794, "retailer": "us.1", "last_seen": 1541693836}');
INSERT INTO public.account (id, username, password, email, usertype, source, remoteid, passvalidation, passreset, detail) VALUES ('sVvhSbe24EGxT53333333', 'bucket_standard', '64b4d0f47c93ce23d157e68a58767356283dc9b63c459d45d0e0e39b3a64b9b9', NULL, 'admin1', 'local', NULL, NULL, NULL, '{"created": 1541693794, "last_seen": 1541693836}');
INSERT INTO public.account (id, username, password, email, usertype, source, remoteid, passvalidation, passreset, detail) VALUES ('sVvhSbe24EGxT54444444', 'bucket_admin', '64b4d0f47c93ce23d157e68a58767356283dc9b63c459d45d0e0e39b3a64b9b9', NULL, 'admin', 'local', NULL, NULL, NULL, '{"created": 1541693794, "last_seen": 1541693836}');


-- Completed on 2018-12-06 10:54:42 EST

--
-- PostgreSQL database dump complete
--

