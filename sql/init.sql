--
-- PostgreSQL database dump
--

-- Dumped from database version 13.4
-- Dumped by pg_dump version 13.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: counter; Type: TABLE; Schema: public; Owner: maharj
--

CREATE TABLE public.counter (
    id bigint NOT NULL,
    created timestamp with time zone NOT NULL,
    current_value bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.counter OWNER TO maharj;

--
-- Name: counter_event; Type: TABLE; Schema: public; Owner: maharj
--

CREATE TABLE public.counter_event (
    id bigint NOT NULL,
    created timestamp with time zone NOT NULL,
    event text NOT NULL
);


ALTER TABLE public.counter_event OWNER TO maharj;

--
-- Name: counter_event_id_seq; Type: SEQUENCE; Schema: public; Owner: maharj
--

CREATE SEQUENCE public.counter_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.counter_event_id_seq OWNER TO maharj;

--
-- Name: counter_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: maharj
--

ALTER SEQUENCE public.counter_event_id_seq OWNED BY public.counter_event.id;


--
-- Name: counter_id_seq; Type: SEQUENCE; Schema: public; Owner: maharj
--

CREATE SEQUENCE public.counter_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.counter_id_seq OWNER TO maharj;

--
-- Name: counter_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: maharj
--

ALTER SEQUENCE public.counter_id_seq OWNED BY public.counter.id;


--
-- Name: counter id; Type: DEFAULT; Schema: public; Owner: maharj
--

ALTER TABLE ONLY public.counter ALTER COLUMN id SET DEFAULT nextval('public.counter_id_seq'::regclass);


--
-- Name: counter_event id; Type: DEFAULT; Schema: public; Owner: maharj
--

ALTER TABLE ONLY public.counter_event ALTER COLUMN id SET DEFAULT nextval('public.counter_event_id_seq'::regclass);


--
-- Name: counter_event counter_event_pkey; Type: CONSTRAINT; Schema: public; Owner: maharj
--

ALTER TABLE ONLY public.counter_event
    ADD CONSTRAINT counter_event_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

