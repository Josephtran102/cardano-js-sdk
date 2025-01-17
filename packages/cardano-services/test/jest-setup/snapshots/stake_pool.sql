--
-- PostgreSQL database dump
--

-- Dumped from database version 11.5
-- Dumped by pg_dump version 11.5

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

--
-- Name: stake_pool; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE stake_pool WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.utf8' LC_CTYPE = 'en_US.utf8';


ALTER DATABASE stake_pool OWNER TO postgres;

\connect stake_pool

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

--
-- Name: pgboss; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA pgboss;


ALTER SCHEMA pgboss OWNER TO postgres;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: job_state; Type: TYPE; Schema: pgboss; Owner: postgres
--

CREATE TYPE pgboss.job_state AS ENUM (
    'created',
    'retry',
    'active',
    'completed',
    'expired',
    'cancelled',
    'failed'
);


ALTER TYPE pgboss.job_state OWNER TO postgres;

--
-- Name: stake_pool_status_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.stake_pool_status_enum AS ENUM (
    'activating',
    'active',
    'retired',
    'retiring'
);


ALTER TYPE public.stake_pool_status_enum OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: archive; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.archive (
    id uuid NOT NULL,
    name text NOT NULL,
    priority integer NOT NULL,
    data jsonb,
    state pgboss.job_state NOT NULL,
    retrylimit integer NOT NULL,
    retrycount integer NOT NULL,
    retrydelay integer NOT NULL,
    retrybackoff boolean NOT NULL,
    startafter timestamp with time zone NOT NULL,
    startedon timestamp with time zone,
    singletonkey text,
    singletonon timestamp without time zone,
    expirein interval NOT NULL,
    createdon timestamp with time zone NOT NULL,
    completedon timestamp with time zone,
    keepuntil timestamp with time zone NOT NULL,
    on_complete boolean NOT NULL,
    output jsonb,
    archivedon timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE pgboss.archive OWNER TO postgres;

--
-- Name: job; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.job (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    data jsonb,
    state pgboss.job_state DEFAULT 'created'::pgboss.job_state NOT NULL,
    retrylimit integer DEFAULT 0 NOT NULL,
    retrycount integer DEFAULT 0 NOT NULL,
    retrydelay integer DEFAULT 0 NOT NULL,
    retrybackoff boolean DEFAULT false NOT NULL,
    startafter timestamp with time zone DEFAULT now() NOT NULL,
    startedon timestamp with time zone,
    singletonkey text,
    singletonon timestamp without time zone,
    expirein interval DEFAULT '00:15:00'::interval NOT NULL,
    createdon timestamp with time zone DEFAULT now() NOT NULL,
    completedon timestamp with time zone,
    keepuntil timestamp with time zone DEFAULT (now() + '14 days'::interval) NOT NULL,
    on_complete boolean DEFAULT false NOT NULL,
    output jsonb,
    block_slot integer
);


ALTER TABLE pgboss.job OWNER TO postgres;

--
-- Name: schedule; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.schedule (
    name text NOT NULL,
    cron text NOT NULL,
    timezone text,
    data jsonb,
    options jsonb,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    updated_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE pgboss.schedule OWNER TO postgres;

--
-- Name: subscription; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.subscription (
    event text NOT NULL,
    name text NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    updated_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE pgboss.subscription OWNER TO postgres;

--
-- Name: version; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.version (
    version integer NOT NULL,
    maintained_on timestamp with time zone,
    cron_on timestamp with time zone
);


ALTER TABLE pgboss.version OWNER TO postgres;

--
-- Name: block; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.block (
    height integer NOT NULL,
    hash character(64) NOT NULL,
    slot integer NOT NULL
);


ALTER TABLE public.block OWNER TO postgres;

--
-- Name: block_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.block_data (
    block_height integer NOT NULL,
    data bytea NOT NULL
);


ALTER TABLE public.block_data OWNER TO postgres;

--
-- Name: current_pool_metrics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.current_pool_metrics (
    stake_pool_id character(56) NOT NULL,
    slot integer,
    minted_blocks integer,
    live_delegators integer,
    active_stake bigint,
    live_stake bigint,
    live_pledge bigint,
    live_saturation numeric,
    active_size numeric,
    live_size numeric,
    last_ros numeric,
    ros numeric
);


ALTER TABLE public.current_pool_metrics OWNER TO postgres;

--
-- Name: pool_delisted; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pool_delisted (
    stake_pool_id character(56) NOT NULL
);


ALTER TABLE public.pool_delisted OWNER TO postgres;

--
-- Name: pool_metadata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pool_metadata (
    id integer NOT NULL,
    ticker character varying NOT NULL,
    name character varying NOT NULL,
    description character varying NOT NULL,
    homepage character varying NOT NULL,
    hash character varying NOT NULL,
    ext jsonb,
    stake_pool_id character(56),
    pool_update_id bigint NOT NULL
);


ALTER TABLE public.pool_metadata OWNER TO postgres;

--
-- Name: pool_metadata_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pool_metadata_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pool_metadata_id_seq OWNER TO postgres;

--
-- Name: pool_metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pool_metadata_id_seq OWNED BY public.pool_metadata.id;


--
-- Name: pool_registration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pool_registration (
    id bigint NOT NULL,
    reward_account character varying NOT NULL,
    pledge numeric(20,0) NOT NULL,
    cost numeric(20,0) NOT NULL,
    margin jsonb NOT NULL,
    margin_percent real NOT NULL,
    relays jsonb NOT NULL,
    owners jsonb NOT NULL,
    vrf character(64) NOT NULL,
    metadata_url character varying,
    metadata_hash character(64),
    block_slot integer NOT NULL,
    stake_pool_id character(56) NOT NULL
);


ALTER TABLE public.pool_registration OWNER TO postgres;

--
-- Name: pool_retirement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pool_retirement (
    id bigint NOT NULL,
    retire_at_epoch integer NOT NULL,
    block_slot integer NOT NULL,
    stake_pool_id character(56) NOT NULL
);


ALTER TABLE public.pool_retirement OWNER TO postgres;

--
-- Name: pool_rewards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pool_rewards (
    id integer NOT NULL,
    stake_pool_id character(56) NOT NULL,
    epoch_length integer NOT NULL,
    epoch_no integer NOT NULL,
    delegators integer NOT NULL,
    pledge bigint NOT NULL,
    active_stake numeric(20,0) NOT NULL,
    member_active_stake numeric(20,0) NOT NULL,
    leader_rewards numeric(20,0) NOT NULL,
    member_rewards numeric(20,0) NOT NULL,
    rewards numeric(20,0) NOT NULL,
    version integer NOT NULL
);


ALTER TABLE public.pool_rewards OWNER TO postgres;

--
-- Name: pool_rewards_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pool_rewards_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pool_rewards_id_seq OWNER TO postgres;

--
-- Name: pool_rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pool_rewards_id_seq OWNED BY public.pool_rewards.id;


--
-- Name: stake_pool; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stake_pool (
    id character(56) NOT NULL,
    status public.stake_pool_status_enum NOT NULL,
    last_registration_id bigint,
    last_retirement_id bigint
);


ALTER TABLE public.stake_pool OWNER TO postgres;

--
-- Name: pool_metadata id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_metadata ALTER COLUMN id SET DEFAULT nextval('public.pool_metadata_id_seq'::regclass);


--
-- Name: pool_rewards id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_rewards ALTER COLUMN id SET DEFAULT nextval('public.pool_rewards_id_seq'::regclass);


--
-- Data for Name: archive; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.archive (id, name, priority, data, state, retrylimit, retrycount, retrydelay, retrybackoff, startafter, startedon, singletonkey, singletonon, expirein, createdon, completedon, keepuntil, on_complete, output, archivedon) FROM stdin;
\.


--
-- Data for Name: job; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.job (id, name, priority, data, state, retrylimit, retrycount, retrydelay, retrybackoff, startafter, startedon, singletonkey, singletonon, expirein, createdon, completedon, keepuntil, on_complete, output, block_slot) FROM stdin;
d71e2e95-9a64-47a0-9dfc-abd3a1e4560d	__pgboss__cron	0	\N	created	2	0	0	f	2023-12-12 17:30:01.208817+00	\N	\N	2023-12-12 17:30:00	00:15:00	2023-12-12 17:29:01.208817+00	\N	2023-12-12 17:31:01.208817+00	f	\N	\N
f0ee92a6-c83b-4fb6-9ba8-e9d6ca2c3345	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 16:50:01.208907+00	2023-12-12 16:50:04.224101+00	\N	2023-12-12 16:50:00	00:15:00	2023-12-12 16:49:04.208907+00	2023-12-12 16:50:04.237503+00	2023-12-12 16:51:01.208907+00	f	\N	\N
9bf05688-4312-4e2f-91a7-7c5fb9a18389	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-12 16:41:24.028791+00	2023-12-12 16:41:24.032067+00	__pgboss__maintenance	\N	00:15:00	2023-12-12 16:41:24.028791+00	2023-12-12 16:41:24.044965+00	2023-12-12 16:49:24.028791+00	f	\N	\N
a32d2a2d-dd3a-45d7-93fd-ac8f93d8c65c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-12 16:50:00.041185+00	2023-12-12 16:51:00.029827+00	__pgboss__maintenance	\N	00:15:00	2023-12-12 16:48:00.041185+00	2023-12-12 16:51:00.040385+00	2023-12-12 16:58:00.041185+00	f	\N	\N
c8e0ae40-0af6-4df2-a998-9edaf698afe0	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 16:51:01.235812+00	2023-12-12 16:51:04.250347+00	\N	2023-12-12 16:51:00	00:15:00	2023-12-12 16:50:04.235812+00	2023-12-12 16:51:04.264845+00	2023-12-12 16:52:01.235812+00	f	\N	\N
7c899efd-39f9-4511-a8d1-edb4ac34b92f	pool-rewards	0	{"epochNo": 4}	completed	1000000	0	30	f	2023-12-12 16:51:05.221758+00	2023-12-12 16:51:06.251188+00	4	\N	00:15:00	2023-12-12 16:51:05.221758+00	2023-12-12 16:51:06.398038+00	2023-12-26 16:51:05.221758+00	f	\N	6001
a2db633e-8490-40f1-8dcf-f5e45aba4989	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 16:52:01.262882+00	2023-12-12 16:52:04.277294+00	\N	2023-12-12 16:52:00	00:15:00	2023-12-12 16:51:04.262882+00	2023-12-12 16:52:04.284679+00	2023-12-12 16:53:01.262882+00	f	\N	\N
2b8d0b06-e9e2-452d-b158-367e080e83e5	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 16:41:24.039086+00	2023-12-12 16:42:00.033418+00	\N	2023-12-12 16:41:00	00:15:00	2023-12-12 16:41:24.039086+00	2023-12-12 16:42:00.037156+00	2023-12-12 16:42:24.039086+00	f	\N	\N
fa5bd1f0-8123-4918-971f-f32c775c3e76	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-12 16:42:00.022908+00	2023-12-12 16:42:00.02855+00	__pgboss__maintenance	\N	00:15:00	2023-12-12 16:42:00.022908+00	2023-12-12 16:42:00.037771+00	2023-12-12 16:50:00.022908+00	f	\N	\N
f6ea8dea-8acc-4379-b0e9-6effc6864ec6	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-12 16:53:00.042697+00	2023-12-12 16:54:00.031443+00	__pgboss__maintenance	\N	00:15:00	2023-12-12 16:51:00.042697+00	2023-12-12 16:54:00.038466+00	2023-12-12 17:01:00.042697+00	f	\N	\N
b661e82a-3216-4420-ab18-ea8e86d08348	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 16:55:01.332157+00	2023-12-12 16:55:04.347566+00	\N	2023-12-12 16:55:00	00:15:00	2023-12-12 16:54:04.332157+00	2023-12-12 16:55:04.356081+00	2023-12-12 16:56:01.332157+00	f	\N	\N
f8fd4440-7ac2-45ba-9b40-781ab78379bd	pool-metadata	0	{"poolId": "pool1sht8xwep2fd65d9jhvjp2hzzrg0lmpk2xga4lg63a25uv7a0g5u", "metadataJson": {"url": "http://file-server/SP1.json", "hash": "14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7"}, "poolRegistrationId": "1030000000000"}	completed	1000000	0	21600	f	2023-12-12 16:41:24.143575+00	2023-12-12 16:42:00.042386+00	\N	\N	00:15:00	2023-12-12 16:41:24.143575+00	2023-12-12 16:42:00.124129+00	2023-12-26 16:41:24.143575+00	f	\N	103
0d5ae038-4c19-4fd7-b376-cd1bf7a2bebe	pool-metadata	0	{"poolId": "pool1fknsj2mn7x90p4x360wxaxq694uyv3rvma3czv04vt94ulnmhmp", "metadataJson": {"url": "http://file-server/SP3.json", "hash": "6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25"}, "poolRegistrationId": "3440000000000"}	completed	1000000	0	21600	f	2023-12-12 16:41:24.254363+00	2023-12-12 16:42:00.042386+00	\N	\N	00:15:00	2023-12-12 16:41:24.254363+00	2023-12-12 16:42:00.132722+00	2023-12-26 16:41:24.254363+00	f	\N	344
2a6807f2-b0c9-420c-8414-4543b83f8bab	pool-metadata	0	{"poolId": "pool1zgwnt4lqgzvcdmznsx4lhjcylur0rwgzgqj79j3smyahvz3a6qg", "metadataJson": {"url": "http://file-server/SP11.json", "hash": "4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9"}, "poolRegistrationId": "12220000000000"}	completed	1000000	0	21600	f	2023-12-12 16:41:24.637458+00	2023-12-12 16:42:00.042386+00	\N	\N	00:15:00	2023-12-12 16:41:24.637458+00	2023-12-12 16:42:00.13403+00	2023-12-26 16:41:24.637458+00	f	\N	1222
217fa9fc-d772-48f6-8cc3-4e6230af52db	pool-metadata	0	{"poolId": "pool14h82efshjpt9rqe3lch85ydun74wt2z4lv58phd7ql9ezwahc8d", "metadataJson": {"url": "http://file-server/SP4.json", "hash": "09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d"}, "poolRegistrationId": "4250000000000"}	completed	1000000	0	21600	f	2023-12-12 16:41:24.293369+00	2023-12-12 16:42:00.042386+00	\N	\N	00:15:00	2023-12-12 16:41:24.293369+00	2023-12-12 16:42:00.135253+00	2023-12-26 16:41:24.293369+00	f	\N	425
82f0444e-6d5e-4b91-b171-190bf648afb2	pool-metadata	0	{"poolId": "pool18wpk9px7k4c9vv6g2mgctnneu25xcst7v9mv975kl9fekuwjxhl", "metadataJson": {"url": "http://file-server/SP5.json", "hash": "0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501"}, "poolRegistrationId": "5210000000000"}	completed	1000000	0	21600	f	2023-12-12 16:41:24.338417+00	2023-12-12 16:42:00.042386+00	\N	\N	00:15:00	2023-12-12 16:41:24.338417+00	2023-12-12 16:42:00.14559+00	2023-12-26 16:41:24.338417+00	f	\N	521
b7e0bb1e-4706-426b-87d9-e46121f3fe49	pool-metadata	0	{"poolId": "pool13uytn3qpyf5sv0ne75nzu9wkq603ypmagcu8e2dchlxuzr7urnn", "metadataJson": {"url": "http://file-server/SP6.json", "hash": "3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba"}, "poolRegistrationId": "6070000000000"}	completed	1000000	0	21600	f	2023-12-12 16:41:24.367475+00	2023-12-12 16:42:00.042386+00	\N	\N	00:15:00	2023-12-12 16:41:24.367475+00	2023-12-12 16:42:00.146573+00	2023-12-26 16:41:24.367475+00	f	\N	607
be917c91-4689-4271-a01e-53a1bd0cc770	pool-metadata	0	{"poolId": "pool1va6e8tmmc52pwg9cnv24z8rct5p0h9at7h0n4enpeecpsqsx8cp", "metadataJson": {"url": "http://file-server/SP7.json", "hash": "c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405"}, "poolRegistrationId": "7350000000000"}	completed	1000000	0	21600	f	2023-12-12 16:41:24.398609+00	2023-12-12 16:42:00.042386+00	\N	\N	00:15:00	2023-12-12 16:41:24.398609+00	2023-12-12 16:42:00.147339+00	2023-12-26 16:41:24.398609+00	f	\N	735
8be439e8-916e-40f5-a320-482657d337e0	pool-metadata	0	{"poolId": "pool1z9jkqfh38ujlx3a3knxfzts2xkv4uj9l3uwuk0g28sa5gxwfy0s", "metadataJson": {"url": "http://file-server/SP10.json", "hash": "c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd"}, "poolRegistrationId": "10840000000000"}	completed	1000000	0	21600	f	2023-12-12 16:41:24.591757+00	2023-12-12 16:42:00.042386+00	\N	\N	00:15:00	2023-12-12 16:41:24.591757+00	2023-12-12 16:42:00.148032+00	2023-12-26 16:41:24.591757+00	f	\N	1084
956dd2c5-2673-400e-81dd-3022538ea359	pool-rewards	0	{"epochNo": 0}	completed	1000000	0	30	f	2023-12-12 16:41:24.964839+00	2023-12-12 16:42:00.05959+00	0	\N	00:15:00	2023-12-12 16:41:24.964839+00	2023-12-12 16:42:00.261981+00	2023-12-26 16:41:24.964839+00	f	\N	2006
8b8b4434-4b9d-4eb5-8586-1c37147aa16d	pool-metrics	0	{"slot": 3097}	completed	0	0	0	f	2023-12-12 16:41:25.290661+00	2023-12-12 16:42:00.059266+00	\N	\N	00:15:00	2023-12-12 16:41:25.290661+00	2023-12-12 16:42:00.43455+00	2023-12-26 16:41:25.290661+00	f	\N	3097
ad630bcd-6ee2-4709-b7d4-3ceabd80843c	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 16:42:00.036323+00	2023-12-12 16:42:04.034891+00	\N	2023-12-12 16:42:00	00:15:00	2023-12-12 16:42:00.036323+00	2023-12-12 16:42:04.049069+00	2023-12-12 16:43:00.036323+00	f	\N	\N
c32ecbeb-6e78-4cbe-8931-061ac361bef0	pool-rewards	0	{"epochNo": 1}	completed	1000000	1	30	f	2023-12-12 16:42:30.10668+00	2023-12-12 16:42:32.05447+00	1	\N	00:15:00	2023-12-12 16:41:25.275484+00	2023-12-12 16:42:32.203533+00	2023-12-26 16:41:25.275484+00	f	\N	3015
ee409769-aad3-4d57-8f5d-a8ce4da5ed36	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 16:43:01.047263+00	2023-12-12 16:43:04.063903+00	\N	2023-12-12 16:43:00	00:15:00	2023-12-12 16:42:04.047263+00	2023-12-12 16:43:04.078109+00	2023-12-12 16:44:01.047263+00	f	\N	\N
e3e47dcc-0709-4881-ac66-00371b5ee21e	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 16:44:01.076142+00	2023-12-12 16:44:04.085778+00	\N	2023-12-12 16:44:00	00:15:00	2023-12-12 16:43:04.076142+00	2023-12-12 16:44:04.100347+00	2023-12-12 16:45:01.076142+00	f	\N	\N
e55c2fa9-04e5-404b-981a-83d348a5c8d0	pool-rewards	0	{"epochNo": 2}	completed	1000000	0	30	f	2023-12-12 16:44:25.214078+00	2023-12-12 16:44:26.100394+00	2	\N	00:15:00	2023-12-12 16:44:25.214078+00	2023-12-12 16:44:26.239232+00	2023-12-26 16:44:25.214078+00	f	\N	4001
05d61e97-831a-4aac-abe0-4f2db72ba603	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-12 16:44:00.043276+00	2023-12-12 16:45:00.029314+00	__pgboss__maintenance	\N	00:15:00	2023-12-12 16:42:00.043276+00	2023-12-12 16:45:00.042541+00	2023-12-12 16:52:00.043276+00	f	\N	\N
bdf6056a-4a0f-41b7-a437-ddd94ebf174f	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 16:45:01.098599+00	2023-12-12 16:45:04.111854+00	\N	2023-12-12 16:45:00	00:15:00	2023-12-12 16:44:04.098599+00	2023-12-12 16:45:04.126448+00	2023-12-12 16:46:01.098599+00	f	\N	\N
0a6a6ca2-529c-4efc-84ee-e57bd7d39923	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 16:46:01.124815+00	2023-12-12 16:46:04.133708+00	\N	2023-12-12 16:46:00	00:15:00	2023-12-12 16:45:04.124815+00	2023-12-12 16:46:04.140099+00	2023-12-12 16:47:01.124815+00	f	\N	\N
6959b166-cdc0-4ad1-977a-b7ff3cf234ff	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 16:47:01.138494+00	2023-12-12 16:47:04.157692+00	\N	2023-12-12 16:47:00	00:15:00	2023-12-12 16:46:04.138494+00	2023-12-12 16:47:04.164703+00	2023-12-12 16:48:01.138494+00	f	\N	\N
8379c7ef-7de5-4d7d-9069-e65e597a0c5d	pool-rewards	0	{"epochNo": 3}	completed	1000000	0	30	f	2023-12-12 16:47:46.41989+00	2023-12-12 16:47:48.178636+00	3	\N	00:15:00	2023-12-12 16:47:46.41989+00	2023-12-12 16:47:48.30599+00	2023-12-26 16:47:46.41989+00	f	\N	5007
b9b8472b-e8ff-4fe0-a26a-418280b1ac2c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-12 16:47:00.044524+00	2023-12-12 16:48:00.028991+00	__pgboss__maintenance	\N	00:15:00	2023-12-12 16:45:00.044524+00	2023-12-12 16:48:00.038111+00	2023-12-12 16:55:00.044524+00	f	\N	\N
eeb82f5f-6152-4193-afb6-d4b4ff5c708b	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 16:48:01.163142+00	2023-12-12 16:48:04.183908+00	\N	2023-12-12 16:48:00	00:15:00	2023-12-12 16:47:04.163142+00	2023-12-12 16:48:04.19318+00	2023-12-12 16:49:01.163142+00	f	\N	\N
ee4fbbf2-36a9-4f32-b93b-2cbbcb4f4255	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 16:49:01.191354+00	2023-12-12 16:49:04.204221+00	\N	2023-12-12 16:49:00	00:15:00	2023-12-12 16:48:04.191354+00	2023-12-12 16:49:04.210614+00	2023-12-12 16:50:01.191354+00	f	\N	\N
54e2a286-085c-4569-93ea-587f1b2d32b5	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 16:53:01.283058+00	2023-12-12 16:53:04.302856+00	\N	2023-12-12 16:53:00	00:15:00	2023-12-12 16:52:04.283058+00	2023-12-12 16:53:04.31017+00	2023-12-12 16:54:01.283058+00	f	\N	\N
08b639b0-ee67-4c65-b648-cd6bd1720e2c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-12 16:56:00.040464+00	2023-12-12 16:57:00.038003+00	__pgboss__maintenance	\N	00:15:00	2023-12-12 16:54:00.040464+00	2023-12-12 16:57:00.052313+00	2023-12-12 17:04:00.040464+00	f	\N	\N
eb3cf39a-404d-45b4-8c17-1d621d7386c6	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 17:10:01.727504+00	2023-12-12 17:10:04.741851+00	\N	2023-12-12 17:10:00	00:15:00	2023-12-12 17:09:04.727504+00	2023-12-12 17:10:04.755329+00	2023-12-12 17:11:01.727504+00	f	\N	\N
c11b8b76-2c36-471e-a910-e8608fb4efa9	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-12 17:11:00.068469+00	2023-12-12 17:12:00.055853+00	__pgboss__maintenance	\N	00:15:00	2023-12-12 17:09:00.068469+00	2023-12-12 17:12:00.069839+00	2023-12-12 17:19:00.068469+00	f	\N	\N
78d25198-a0dc-4fd3-bdbf-341e3b99e464	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 17:12:01.777457+00	2023-12-12 17:12:04.790422+00	\N	2023-12-12 17:12:00	00:15:00	2023-12-12 17:11:04.777457+00	2023-12-12 17:12:04.797723+00	2023-12-12 17:13:01.777457+00	f	\N	\N
8ac90412-453e-49cf-b5e9-7b19c6da1aba	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 17:14:01.826898+00	2023-12-12 17:14:04.837603+00	\N	2023-12-12 17:14:00	00:15:00	2023-12-12 17:13:04.826898+00	2023-12-12 17:14:04.845693+00	2023-12-12 17:15:01.826898+00	f	\N	\N
6cd3ffb2-385d-425c-9214-3fc3f0b7722d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-12 17:14:00.07159+00	2023-12-12 17:15:00.057634+00	__pgboss__maintenance	\N	00:15:00	2023-12-12 17:12:00.07159+00	2023-12-12 17:15:00.064216+00	2023-12-12 17:22:00.07159+00	f	\N	\N
885256e1-5dd0-4ed8-b8f2-d3249ebb1a0f	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 17:16:01.864115+00	2023-12-12 17:16:04.882244+00	\N	2023-12-12 17:16:00	00:15:00	2023-12-12 17:15:04.864115+00	2023-12-12 17:16:04.895297+00	2023-12-12 17:17:01.864115+00	f	\N	\N
66fd5d40-39ad-4e48-b779-c6622deda41a	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 17:18:01.917833+00	2023-12-12 17:18:04.933422+00	\N	2023-12-12 17:18:00	00:15:00	2023-12-12 17:17:04.917833+00	2023-12-12 17:18:04.939208+00	2023-12-12 17:19:01.917833+00	f	\N	\N
c8f470f3-b133-4dad-a71e-ba3d01a4afde	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 17:19:01.937702+00	2023-12-12 17:19:04.960223+00	\N	2023-12-12 17:19:00	00:15:00	2023-12-12 17:18:04.937702+00	2023-12-12 17:19:04.973494+00	2023-12-12 17:20:01.937702+00	f	\N	\N
ecd6905c-5da0-41b7-bb39-960b87cb00ac	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-12 17:20:00.075372+00	2023-12-12 17:21:00.06419+00	__pgboss__maintenance	\N	00:15:00	2023-12-12 17:18:00.075372+00	2023-12-12 17:21:00.077037+00	2023-12-12 17:28:00.075372+00	f	\N	\N
0a749d78-8621-4153-bd2a-066ceda4bd88	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 17:21:01.996006+00	2023-12-12 17:21:05.011999+00	\N	2023-12-12 17:21:00	00:15:00	2023-12-12 17:20:04.996006+00	2023-12-12 17:21:05.018754+00	2023-12-12 17:22:01.996006+00	f	\N	\N
e02b6450-96d7-4d2d-9768-1ec9f28ffdcd	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 17:23:01.030757+00	2023-12-12 17:23:01.050998+00	\N	2023-12-12 17:23:00	00:15:00	2023-12-12 17:22:01.030757+00	2023-12-12 17:23:01.064901+00	2023-12-12 17:24:01.030757+00	f	\N	\N
a740b847-c04a-447f-98bf-e3a07ffcffe0	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-12 17:23:00.078803+00	2023-12-12 17:24:00.066199+00	__pgboss__maintenance	\N	00:15:00	2023-12-12 17:21:00.078803+00	2023-12-12 17:24:00.078972+00	2023-12-12 17:31:00.078803+00	f	\N	\N
361e5ebb-325f-4fd4-a2c5-b29df6f32c58	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 17:24:01.063293+00	2023-12-12 17:24:01.078566+00	\N	2023-12-12 17:24:00	00:15:00	2023-12-12 17:23:01.063293+00	2023-12-12 17:24:01.091682+00	2023-12-12 17:25:01.063293+00	f	\N	\N
0cf8331b-473a-4868-8dcc-675d22495e96	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 17:26:01.112003+00	2023-12-12 17:26:01.133569+00	\N	2023-12-12 17:26:00	00:15:00	2023-12-12 17:25:01.112003+00	2023-12-12 17:26:01.146497+00	2023-12-12 17:27:01.112003+00	f	\N	\N
75d8cf0c-360f-4ef7-8250-4b268b7e2f94	__pgboss__maintenance	0	\N	created	0	0	0	f	2023-12-12 17:29:00.075952+00	\N	__pgboss__maintenance	\N	00:15:00	2023-12-12 17:27:00.075952+00	\N	2023-12-12 17:37:00.075952+00	f	\N	\N
474a9481-920a-4ce8-a8c0-f88d70d28681	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 17:28:01.16487+00	2023-12-12 17:28:01.176935+00	\N	2023-12-12 17:28:00	00:15:00	2023-12-12 17:27:01.16487+00	2023-12-12 17:28:01.19055+00	2023-12-12 17:29:01.16487+00	f	\N	\N
f2b83951-b272-4c8d-aa01-7e8845906165	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 16:54:01.308563+00	2023-12-12 16:54:04.32688+00	\N	2023-12-12 16:54:00	00:15:00	2023-12-12 16:53:04.308563+00	2023-12-12 16:54:04.334456+00	2023-12-12 16:55:01.308563+00	f	\N	\N
ab5fe08f-da52-4c22-ac5c-99e1c6999bea	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-12 17:08:00.063763+00	2023-12-12 17:09:00.052808+00	__pgboss__maintenance	\N	00:15:00	2023-12-12 17:06:00.063763+00	2023-12-12 17:09:00.066081+00	2023-12-12 17:16:00.063763+00	f	\N	\N
437a3a59-f713-4267-ba4c-a51581d8f32d	pool-rewards	0	{"epochNo": 5}	completed	1000000	0	30	f	2023-12-12 16:54:26.210074+00	2023-12-12 16:54:26.337797+00	5	\N	00:15:00	2023-12-12 16:54:26.210074+00	2023-12-12 16:54:26.465392+00	2023-12-26 16:54:26.210074+00	f	\N	7006
4aa9f290-f3b7-47eb-be2e-7ada96cffde5	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 17:29:01.18901+00	2023-12-12 17:29:01.202591+00	\N	2023-12-12 17:29:00	00:15:00	2023-12-12 17:28:01.18901+00	2023-12-12 17:29:01.210374+00	2023-12-12 17:30:01.18901+00	f	\N	\N
4416ed6f-f320-45e0-b637-e8d6e924dccd	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 17:09:01.699851+00	2023-12-12 17:09:04.720696+00	\N	2023-12-12 17:09:00	00:15:00	2023-12-12 17:08:04.699851+00	2023-12-12 17:09:04.729109+00	2023-12-12 17:10:01.699851+00	f	\N	\N
d37390da-4d30-4341-984b-0f655105c423	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 16:56:01.35434+00	2023-12-12 16:56:04.376739+00	\N	2023-12-12 16:56:00	00:15:00	2023-12-12 16:55:04.35434+00	2023-12-12 16:56:04.391065+00	2023-12-12 16:57:01.35434+00	f	\N	\N
0770e38f-41d4-49d4-9159-2625e3fd5592	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 17:11:01.753828+00	2023-12-12 17:11:04.765495+00	\N	2023-12-12 17:11:00	00:15:00	2023-12-12 17:10:04.753828+00	2023-12-12 17:11:04.778953+00	2023-12-12 17:12:01.753828+00	f	\N	\N
9c69de96-ec29-40e7-b04f-b5baa030fe29	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 16:57:01.389469+00	2023-12-12 16:57:04.40556+00	\N	2023-12-12 16:57:00	00:15:00	2023-12-12 16:56:04.389469+00	2023-12-12 16:57:04.411982+00	2023-12-12 16:58:01.389469+00	f	\N	\N
0610b003-2f3d-4bdd-9428-c57699fedda6	pool-rewards	0	{"epochNo": 10}	completed	1000000	0	30	f	2023-12-12 17:11:07.209466+00	2023-12-12 17:11:08.767996+00	10	\N	00:15:00	2023-12-12 17:11:07.209466+00	2023-12-12 17:11:08.874533+00	2023-12-26 17:11:07.209466+00	f	\N	12011
4f48b27e-8b61-4792-b3fd-8bf1cc63ecb7	pool-rewards	0	{"epochNo": 6}	completed	1000000	0	30	f	2023-12-12 16:57:45.619231+00	2023-12-12 16:57:46.423395+00	6	\N	00:15:00	2023-12-12 16:57:45.619231+00	2023-12-12 16:57:46.540306+00	2023-12-26 16:57:45.619231+00	f	\N	8003
a137a2a2-b5ad-4de3-ac1e-a77ec10ded38	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 16:58:01.410286+00	2023-12-12 16:58:04.427786+00	\N	2023-12-12 16:58:00	00:15:00	2023-12-12 16:57:04.410286+00	2023-12-12 16:58:04.442441+00	2023-12-12 16:59:01.410286+00	f	\N	\N
d8aca4b7-f4be-4d17-b357-f3619cab85ae	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 17:13:01.796169+00	2023-12-12 17:13:04.814986+00	\N	2023-12-12 17:13:00	00:15:00	2023-12-12 17:12:04.796169+00	2023-12-12 17:13:04.828492+00	2023-12-12 17:14:01.796169+00	f	\N	\N
c72a0289-c44c-4c83-a42a-9652d9c923ec	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 16:59:01.440787+00	2023-12-12 16:59:04.453561+00	\N	2023-12-12 16:59:00	00:15:00	2023-12-12 16:58:04.440787+00	2023-12-12 16:59:04.46082+00	2023-12-12 17:00:01.440787+00	f	\N	\N
be7febdd-eef9-4d4e-aec8-28089af899b7	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-12 16:59:00.054752+00	2023-12-12 17:00:00.041879+00	__pgboss__maintenance	\N	00:15:00	2023-12-12 16:57:00.054752+00	2023-12-12 17:00:00.047769+00	2023-12-12 17:07:00.054752+00	f	\N	\N
6b57e6bb-2411-4a54-bae8-42a42eb56205	pool-rewards	0	{"epochNo": 11}	completed	1000000	0	30	f	2023-12-12 17:14:26.819207+00	2023-12-12 17:14:26.850131+00	11	\N	00:15:00	2023-12-12 17:14:26.819207+00	2023-12-12 17:14:26.983358+00	2023-12-26 17:14:26.819207+00	f	\N	13009
29a37e66-5f07-43fc-b7c1-176a709a3b15	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 17:00:01.459195+00	2023-12-12 17:00:04.479614+00	\N	2023-12-12 17:00:00	00:15:00	2023-12-12 16:59:04.459195+00	2023-12-12 17:00:04.492203+00	2023-12-12 17:01:01.459195+00	f	\N	\N
340ff3db-93ac-4cff-9b6c-0a9ac801935c	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 17:15:01.844133+00	2023-12-12 17:15:04.859672+00	\N	2023-12-12 17:15:00	00:15:00	2023-12-12 17:14:04.844133+00	2023-12-12 17:15:04.865624+00	2023-12-12 17:16:01.844133+00	f	\N	\N
3c89e97c-c60c-4d33-9023-119cdc7fcc76	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 17:01:01.490657+00	2023-12-12 17:01:04.506587+00	\N	2023-12-12 17:01:00	00:15:00	2023-12-12 17:00:04.490657+00	2023-12-12 17:01:04.514537+00	2023-12-12 17:02:01.490657+00	f	\N	\N
fe99bb50-e96e-44dd-847e-dcd1e3522374	pool-rewards	0	{"epochNo": 7}	completed	1000000	0	30	f	2023-12-12 17:01:06.622444+00	2023-12-12 17:01:08.50972+00	7	\N	00:15:00	2023-12-12 17:01:06.622444+00	2023-12-12 17:01:08.628069+00	2023-12-26 17:01:06.622444+00	f	\N	9008
4cba6a16-44ff-4be7-b6db-3396e6e35c38	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 17:17:01.893735+00	2023-12-12 17:17:04.907562+00	\N	2023-12-12 17:17:00	00:15:00	2023-12-12 17:16:04.893735+00	2023-12-12 17:17:04.919528+00	2023-12-12 17:18:01.893735+00	f	\N	\N
3416b7a2-e5ff-4a14-b789-a5d8c70965e8	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 17:02:01.513014+00	2023-12-12 17:02:04.533665+00	\N	2023-12-12 17:02:00	00:15:00	2023-12-12 17:01:04.513014+00	2023-12-12 17:02:04.539818+00	2023-12-12 17:03:01.513014+00	f	\N	\N
e7008a13-a193-4fdd-ac90-5f5ef15fa294	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-12 17:02:00.049667+00	2023-12-12 17:03:00.044339+00	__pgboss__maintenance	\N	00:15:00	2023-12-12 17:00:00.049667+00	2023-12-12 17:03:00.049505+00	2023-12-12 17:10:00.049667+00	f	\N	\N
38ae600c-ce13-475e-97b9-8d9e87efc2c7	pool-rewards	0	{"epochNo": 12}	completed	1000000	0	30	f	2023-12-12 17:17:45.608126+00	2023-12-12 17:17:46.924643+00	12	\N	00:15:00	2023-12-12 17:17:45.608126+00	2023-12-12 17:17:47.03291+00	2023-12-26 17:17:45.608126+00	f	\N	14003
7ebd88d0-b72d-4722-8207-f2ea15e84f4b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-12 17:17:00.066397+00	2023-12-12 17:18:00.060875+00	__pgboss__maintenance	\N	00:15:00	2023-12-12 17:15:00.066397+00	2023-12-12 17:18:00.073268+00	2023-12-12 17:25:00.066397+00	f	\N	\N
bb0e7286-317d-475c-b841-31a8b192f142	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 17:03:01.538174+00	2023-12-12 17:03:04.560566+00	\N	2023-12-12 17:03:00	00:15:00	2023-12-12 17:02:04.538174+00	2023-12-12 17:03:04.566512+00	2023-12-12 17:04:01.538174+00	f	\N	\N
8ad98238-b820-4c80-9081-9ee641389288	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 17:04:01.564999+00	2023-12-12 17:04:04.585913+00	\N	2023-12-12 17:04:00	00:15:00	2023-12-12 17:03:04.564999+00	2023-12-12 17:04:04.59276+00	2023-12-12 17:05:01.564999+00	f	\N	\N
d5494d56-c995-454a-bc10-7d76bae39b53	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 17:20:01.972004+00	2023-12-12 17:20:04.989577+00	\N	2023-12-12 17:20:00	00:15:00	2023-12-12 17:19:04.972004+00	2023-12-12 17:20:04.997658+00	2023-12-12 17:21:01.972004+00	f	\N	\N
e9346b38-51a1-4c80-9e7c-f6867b5f8860	pool-metrics	0	{"slot": 9994}	completed	0	0	0	f	2023-12-12 17:04:23.811684+00	2023-12-12 17:04:24.594837+00	\N	\N	00:15:00	2023-12-12 17:04:23.811684+00	2023-12-12 17:04:24.754432+00	2023-12-26 17:04:23.811684+00	f	\N	9994
35709409-f98a-4bb1-9c1d-f7de1cb8caf0	pool-rewards	0	{"epochNo": 8}	completed	1000000	0	30	f	2023-12-12 17:04:25.01641+00	2023-12-12 17:04:26.597095+00	8	\N	00:15:00	2023-12-12 17:04:25.01641+00	2023-12-12 17:04:26.706665+00	2023-12-26 17:04:25.01641+00	f	\N	10000
52968be9-3370-4a9a-a332-bccaa8899e1e	pool-rewards	0	{"epochNo": 13}	completed	1000000	0	30	f	2023-12-12 17:21:06.018665+00	2023-12-12 17:21:07.017688+00	13	\N	00:15:00	2023-12-12 17:21:06.018665+00	2023-12-12 17:21:07.146312+00	2023-12-26 17:21:06.018665+00	f	\N	15005
2be254ac-fcdf-4efa-aa71-4352de257260	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 17:05:01.591263+00	2023-12-12 17:05:04.612379+00	\N	2023-12-12 17:05:00	00:15:00	2023-12-12 17:04:04.591263+00	2023-12-12 17:05:04.619824+00	2023-12-12 17:06:01.591263+00	f	\N	\N
1bb9df15-635c-41eb-a243-1437916625f4	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 17:22:01.016882+00	2023-12-12 17:22:01.026245+00	\N	2023-12-12 17:22:00	00:15:00	2023-12-12 17:21:05.016882+00	2023-12-12 17:22:01.032825+00	2023-12-12 17:23:01.016882+00	f	\N	\N
637756e1-12bd-4f3b-b879-41d3b63f4aae	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-12 17:05:00.051267+00	2023-12-12 17:06:00.049304+00	__pgboss__maintenance	\N	00:15:00	2023-12-12 17:03:00.051267+00	2023-12-12 17:06:00.062097+00	2023-12-12 17:13:00.051267+00	f	\N	\N
20212c19-fbc8-4ef3-9627-5a5122a22369	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 17:06:01.618002+00	2023-12-12 17:06:04.638991+00	\N	2023-12-12 17:06:00	00:15:00	2023-12-12 17:05:04.618002+00	2023-12-12 17:06:04.652632+00	2023-12-12 17:07:01.618002+00	f	\N	\N
a58bc48b-9449-4188-a7a3-57ca66899d5c	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 17:07:01.651009+00	2023-12-12 17:07:04.665776+00	\N	2023-12-12 17:07:00	00:15:00	2023-12-12 17:06:04.651009+00	2023-12-12 17:07:04.678448+00	2023-12-12 17:08:01.651009+00	f	\N	\N
ef3da4f1-44ac-422d-a0df-e389786bd122	pool-rewards	0	{"epochNo": 14}	completed	1000000	0	30	f	2023-12-12 17:24:27.21189+00	2023-12-12 17:24:29.092315+00	14	\N	00:15:00	2023-12-12 17:24:27.21189+00	2023-12-12 17:24:29.203398+00	2023-12-26 17:24:27.21189+00	f	\N	16011
619c7d23-1553-4bed-85e2-437e2e296263	pool-rewards	0	{"epochNo": 9}	completed	1000000	0	30	f	2023-12-12 17:07:45.407598+00	2023-12-12 17:07:46.686135+00	9	\N	00:15:00	2023-12-12 17:07:45.407598+00	2023-12-12 17:07:46.803934+00	2023-12-26 17:07:45.407598+00	f	\N	11002
4b0c3eb7-fcef-4320-b6b4-9bd58a87c92d	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 17:25:01.090118+00	2023-12-12 17:25:01.106991+00	\N	2023-12-12 17:25:00	00:15:00	2023-12-12 17:24:01.090118+00	2023-12-12 17:25:01.113548+00	2023-12-12 17:26:01.090118+00	f	\N	\N
342cc13c-3aa6-44fd-aa02-28d874cb363b	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 17:08:01.676873+00	2023-12-12 17:08:04.69442+00	\N	2023-12-12 17:08:00	00:15:00	2023-12-12 17:07:04.676873+00	2023-12-12 17:08:04.701465+00	2023-12-12 17:09:01.676873+00	f	\N	\N
d53ecba1-9fbb-441e-9109-7686b25bee09	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-12 17:26:00.080661+00	2023-12-12 17:27:00.067643+00	__pgboss__maintenance	\N	00:15:00	2023-12-12 17:24:00.080661+00	2023-12-12 17:27:00.074242+00	2023-12-12 17:34:00.080661+00	f	\N	\N
50b5a7d1-1569-4aa3-aeb1-08e51f17ad85	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-12 17:27:01.144999+00	2023-12-12 17:27:01.153637+00	\N	2023-12-12 17:27:00	00:15:00	2023-12-12 17:26:01.144999+00	2023-12-12 17:27:01.166326+00	2023-12-12 17:28:01.144999+00	f	\N	\N
8143c5b0-d505-4812-a5ed-241c6ce2698b	pool-rewards	0	{"epochNo": 15}	completed	1000000	0	30	f	2023-12-12 17:27:45.01333+00	2023-12-12 17:27:45.171055+00	15	\N	00:15:00	2023-12-12 17:27:45.01333+00	2023-12-12 17:27:45.28004+00	2023-12-26 17:27:45.01333+00	f	\N	17000
\.


--
-- Data for Name: schedule; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.schedule (name, cron, timezone, data, options, created_on, updated_on) FROM stdin;
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.subscription (event, name, created_on, updated_on) FROM stdin;
\.


--
-- Data for Name: version; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.version (version, maintained_on, cron_on) FROM stdin;
20	2023-12-12 17:27:00.072941+00	2023-12-12 17:29:01.206567+00
\.


--
-- Data for Name: block; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block (height, hash, slot) FROM stdin;
0	e843f4a8f57ca2e1852f660ca13e61655092a3040ad3083f1fa348ab8d39b6b1	0
1	5e5a729c8e950d3e0300e3af08adbf54c56248e03cb4a2f64481eb15f84c04e6	11
2	3575b93c15b1aab242ff119aaa31cd42f0a700ef262b40f5af2fc34a370395d9	14
3	1993acb2323550ebf7569a824e9d01596ebca84e1d18ccbfa1618e628e068c1b	15
4	1af182dbed46953ed198f311a813488d9df4404d112485e0349d2f856ee3d7ec	36
5	69d8e99df0e4e90e71c31ff63a3377c9eef0465aaf6814d1eeec918be91705fd	52
6	065713ffc129420d4354e222c662b5b08df03506c0998bea39f564b477d27b17	56
7	aa1d9773c445c671d4e8ffd19ff7c9e8b574c9c3cfc8d4943adeebab03e61053	72
8	6eec599a9886c23845f1a37adebe3b94bf8e9e39d8f37b71d29fd4e9815c02f3	73
9	991b1d73611aaa12c6c50fad38649c69fbfd4acda9496df815760b3dce243925	103
10	06425dab37a5c8658f91dfa048bed64a5fe83f6250ad95318d8fe23852339ac1	105
11	e8ca0af436d0f336712277fe2852c7eecf49add8561c364792a4a5d5751c46b5	107
12	b87128462e27fa4716f9755be9dcf2c6911d5e8fce30d13b62166db53375cddf	131
13	6663c779071ea95ccdf34dee538111b47f163e5ad888decb35c17f7aee6d7b59	160
14	c2fb1960d8881a286874b4a83b831d47626f14f900c4f58042413475fe78e8e5	172
15	00be6a0d5a9e2c0806f081f460642c52a8d87432d306e951c91204096d1022b3	177
16	16a17fddd7f42779411188f3225c68fdd107499e9d0628a323676b87d8ceaa02	181
17	d13baf2105729794b4c6300647a889ab4c3bedce92a369b27e227d2de2d0d5a9	192
18	ac21f1fb49bf1645302189541d9e5fda2032ec3188d1f835f26e8d49f18fcc3f	210
19	2fa7302adb7af0cfa28d1f98f8c42c5f8d598c431584937338dc10a7103d8bfa	212
20	433014c845296e9c67439a126df8aa5855e88e1e884cb36860da0a907c73b42d	214
21	afd2dd56fd7fdcb7bc32d3c863eba8295babfdb2541ba3f7f6f906a1475a2a04	215
22	446a0269495feaa86c28de8d087b4af8ebda097c13c42feb9a4f9807a75eb0f9	221
23	9b6e646cf7723254f196fedc72318437f513f32652a4fb0570c6d86ae951bf8b	229
24	9b71915fc22e09a07972759f4f388bfd19b56485e2b68f038ef8f0a262bc3e72	233
25	a0825866cddf1747df45eb17f11616efa20eafacfba80ac9fe0e6d4b644affc8	237
26	82890e7d654c1c9357858e889bc277ecf50de071dd273981a65644131d58187f	266
27	02213ebee2d4612b27bb58eb4a67bb80365c655a9ca61f27dca54f2cf3f0a5dc	273
28	c3f1da8776d021febbaef1f495d6188b1c3d96b7506039172948d8cd3cdf7d25	280
29	9af37d7e06b6d5dd03089b57da04e8f96bcec949bb5cde0b2465dac1c84ff33a	284
30	2d315e4bc17a4523549810a7afe13ea86a902b1fea08ab7f20f0e795f98a488d	288
31	70ddaac4a51ce8e3ec2dddee6e4c1b07f3a26c65939d3914ed5eaf620c168de3	310
32	30f1ddbf8d62e7761b9e0948cbb094d8bf5c1695916edaacca3466dac1184b88	314
33	0670a1087f3d5fe5a4b0c58856c9f65fe2397d0f8269b31993d21da3c6670b06	321
34	dca5b209b06fc1d4a1ff4f807d71c2280fdd65155b6d2f4e85a694192135bf78	327
35	fa9f5c3f8438414af5f934ff65f4ef3e235b22d2102d9964c1328659f15161d5	334
36	47784b190d24fe02178daee3285140f1eeebd1292857f04f20c3e7f338d2dac1	344
37	2ce7f629729060f340490865a29a898523ec8067cbad49ae81a1324d93fed5c6	365
38	cb89052313b3b5b0acbff1bc444c45cec808440148c2714394f2ed7ddfbf9a0a	391
39	3e0c6c5eb00a0dfa8bc278c9198ff5cfef890706b90d8984b68cb1c0824a53c3	396
40	61313e91c91716aac2637ef9a54d90878bdc9ce485fcc7aa59152feede99a37b	401
41	c707110ff1b627a155244c73c9ad6ab394aea81924b720142fa04b7298b6dad1	409
42	551cb66376f7fc6395819bffdb32f70353ddceb8686ec6978da9359122375eca	415
43	a7097b2e54626eed9aa94cfa504b7464ec1b41a9de8d5a480749ee9ede6cfeef	425
44	b99998681ca1f4dc020d71df19e05c2491b8d859b861208f16cbeb67d98c2a7c	440
45	ede3d25046d23f027fda981e9f92f255f7fab57c0ceb227bf11d02f7eac4cfb6	441
46	02919c1c91692aae39cc381fe501bca29b5090395df9b90d4e8762614dde3fef	444
47	c7fa11c4b11cbc7dc5a14d7bec4441c1c7d0270f73f4af5a62265e68b7611979	464
48	08d4704f632836a5e2cd6ff55b6d1771ce782c49b34d3c41ffb2b01aa3a93aa3	466
49	f96832ca5017d4a6a07ec5ed8268d22006e6430c2fb4610052a380c02469be29	485
50	5160b25bc86b7b2a6f62714f832bb45223f99330a1a3e1116e9f8db307f87fb1	489
51	f512b20b7340b4fe92e9d2ed148dfd331cefcb24d516fe29ea2ff85b5d2daae0	501
52	0d4c663a40806a3bbc25060562909d6d073a4de9c60e312fd24dea8c21507d07	521
53	f7ff1c6b9632ed487eda78a72a74e176af4a825db203134d632074fe117afc33	540
54	763287943cdc70ee91292102dd9bffdff9d8d77f07907ff30e4ba53875823967	553
55	2cec250674237a14695260b9ad26975cc3411894e7cf7a2ab21707ef2ef440fd	561
56	add5e1b914b230873954f0c8a843e496cf1aae6082a35c965ca3d20c2b7abebd	562
57	bf172e5037333717ae309815f7ed2c9a5259161218984ec2272bff27cdbcec93	564
58	284624c61c8cf327c2c12b392039a10a8d585a474e4ed57ab64cdc93ac32eed6	583
59	82a93ead85b95b650b76c3ec496eb43a83f8b46c0f78965487a12a783fa62997	607
60	119f59feaaba3a9873090102d1136e30cc97dad2281372b3ca6bb6d05d0da137	627
61	72c50c4c055fb81f13d6fdae6ed140e78cfc8b14275f9ad6d3f92437b327e09b	633
62	6bea036eec859a75a5af8e56d8ba6451ce7626f083c529304aea97b44a9719a7	637
63	a4166237d20b3cd83ac650f9214cf6fe1691aeb4da4e219448c217119c083136	643
64	943aaf02822d17b1aa16d1734a8efdd03794709667fed3a7c3af23d8b05fc641	649
65	c139eb40cd209cad1afa25e1ec0530f856cb5765ee282f8c2ef307e324475e9e	656
66	b215936fa9e89b40f64edf32620dc79ccce53dac2fe488ec615a971d0f49c3be	718
67	89e127d742cea7cc2eca128e7134ad0bc53e47a5668f2b319224f78cb02c9b5b	735
68	8477c1f7f4ccb4dc8a4b396fa586c7d2d1c5e6e40b532e7d5c39b350cdc6b30e	749
69	605a8b0b73f1e9d1e62ae531dcc6d06c6f8c9553e52eeca149fc57d8a479b26d	753
70	9bc8b0fa9ada93f46108ed1e2b45713f7b77bd3865bc2245ed438f5e821f8e85	755
71	2baf7027d70c7cd58d87bebf00d753c5d8a57432f2f7274abe618f09b9f5f426	767
72	787c5267c0904f40a8affb8c27f57d6bbd8cdaf55ac8d05aedf15d703cbe63cc	784
73	69fcf9f417dc70c277d59149eb419b0bf32598775663a1a9f9ee5ef197f3eab5	785
74	7792bc96acb5748ad455617da68b6363e94f2f91bd4e44f790ac05e6f41701c3	793
75	7c67fee17bc056092a2b921174795ba3e9db59c9df8efd3e64495b2110ea94b1	794
76	7e4acfd3ccc3c2e00ee3f748c219bd37b206a001a11ff17c154e3b569f1b9eb3	802
77	b877c3717879f7dbef4059c2fd2ff9472f61cc9328314dcb2e5120c02148539a	805
78	f7563c6bdb062e23311f1709a5f449e3dc9288e76f50f6089a9d1948a970ef9c	807
79	42fc11c2f2a909b928f9cf78c7b2bfa54e4036351b833845098eac0491c37dc8	810
80	c96fe02ff1b0da77a2faace3f858919e7b68b0242236c98d5f2d6bcdc8cb96c5	813
81	c6d5158d71b400324ba9d719eb34b53bc8f49a37997b4234c4c10fe33a22c7ed	818
82	bd12b0a08a3cb78cdae720543a3794487f24388c0725013b301c8109ca3bfa12	872
83	1fff87c422c3841454e9b65e13538d58bb6e80e71a3c0a4b7f4829b739caf374	889
84	a9d6050df5e0ac6a949e349f7358df6bb0d9a2f122e1fbb8c86c480cfdee3711	890
85	8583205379d270a241ab2ad841bd95e87fa40b5df69549fcdf1cfa010821c21e	892
86	58233c61ecb74b2fe2c8b2860e35f5547c9212fe5521b3da86a70f9acdcf658c	904
87	fca844d9a0be750d22d47e58cdb85edf09aa71c6bb5faf4649e1642ee528969d	928
88	08bff20e3d110a38fe548dd2969609d44c43db807e09907c1873800f7759787c	931
89	a18536f676e26443d4b050ee2f970477d40d6a5e142e6b76f67510f2ac7c9070	942
90	9f7dec280f916bc4eea8679347150a596f6f487f5f83e11ffed07ae9ea228604	949
91	0a853fce9e8daccec161d27c92710a3019c3867264ebc7e68c2d15e900369490	952
92	572606b4f70fd5e1922cc46cacbc1bd747c0a20ecdea0db18ef3ee232d07cb18	956
93	d5804d3c6497f81aaef7d7b6efb703ce24de6002eee268be3dba06787c9cc5fd	986
94	da19ba0ca29a4076e4f54f57d1087f5c91faf16f7c7e5024f1d7b9a15672f540	989
95	76326a5f9c104dc5fd136b9a7223eb3c9581e68663a2a88f1e680b123965594c	990
96	d9fa02cc51bddaa7d4b425c243b4d36b0a3d6b4ac9a129d579f6eaa985d694ac	991
97	8c844090a7a72c1a8653ff4d55d2b5ce97a7986f3b6b4f86462875a84c213f38	992
98	406796c31ff7f63cf89ff3aa0583cf672e9e6a6b18ea09c1e4cce0b73c7b7bdb	1009
99	8df64ad5c0886bdfaadffa3e8d44018533e3cc89856a492d8dc3e7434f69b552	1023
100	2f69dc362a40bd672217e02d41ab354490d006a20615451c491a91716351356f	1033
101	06354ce6a7cc219cfb4713173d25b461c85d964b81c1b1e2e7ccf43efea66b6c	1036
102	0c6037d9fc0240a471e94ce6c638d307e3a35961a1e49bdc95d14734b18f8096	1040
103	663f20209996ab81e1d8e1222acd112575c737464c3d36f64489d670caecdb4d	1042
104	1c0958011b137526b22d97104d70b6ffe19902e28ee7217294220f5fbaad2110	1046
105	01e4a2ebabfbb908532629b979602b86d8c664ed470915aafc54e6360b1e09c5	1049
106	314004eab8ed06c338f5ef3d142c1f9777ebae1585127bf73e6595b757c3bd5a	1062
107	ad62f1b05cb734f5b5f4530d7e733f559771d212749332c192dd706b097664c8	1063
108	89758b8331fcdef5d58d75d5771f09dea4f7a56f87c51c384aa0a08724373962	1064
109	f01599178a85ba8311c3adda1fec0f07847acacd1fc1d2236d675c307890c11f	1073
110	5ec8ad6aba22cfe257f6a40632858404b582e0baa67f12019c16bc0e9f60ea6f	1084
111	74aca0d804008de11511f30751be9612cb1b3d4e7472a86a65b5dea8c05e0980	1116
112	c21b87b21b916d0100bfc64ef7e3ef718caa21c1776554ff9552153dfbb27225	1141
113	deeb4c7fe500ccdcf5f3f30b9ebd50522ee97556aacb482401840c6ef924b60b	1157
114	6934a50234f9ef48a34c5a9e622489f4cc6169b4b5237a089f57a6e2c44f9072	1161
115	d56bdee3186e53aa7c0186f05f0fbffd58a247158bc56c92c4f4e9ea4b740df8	1170
116	2986ef7c160b5bfa9a7a0ac1bb8d502673aff930949f2c3a6cd885850de7fb1a	1173
117	d08439b5ac1deab1097bc1e1a8609a94dfaa817caecf33000ff83a4335fddbe3	1181
118	c1568c2c1c53e2a6c52f350bd7ce9113bcbc64cdedb7955c0795215b8fedc2a5	1183
119	da9f61c3bd66f1eecc9c993457da2e4da57c7e74f177deda1f6b54439cea1645	1199
120	eb5d107871a1dce4fc92b36b61dfec42b1b94a1c0d60aa34f80a449b18f0ee2a	1201
121	956dac86f89573cb8e3e919b63e03913f5ad1993e1b98fc8cbc3cfefa9b19089	1222
122	f8f85415272410cb3819779762254c2a72659d1de6fb4d07dce4d53e2865985a	1236
123	8394b97db14a54a6add8b794bfb17537816ab07cf754b09bfe8a2dfa256bca44	1268
124	00e52c7e3fce2ca068206bfdf466f7b5a5a42c21c4dbf02ac24cd0ffbde951f3	1270
125	f028e878591f7588706ae5c0882df6f8b3d429100329913bd964dca70d6a559e	1297
126	e8b258565dddd741eda40fd0cd4c14e5e98112cbdb7cbdac45045e487214ff9f	1317
127	e0332705febe3cb3b156e584320256ea6d28160de48338e6f8ad7de61b14544a	1334
128	9a16aa6037f588a0d6898e9475d9d242c383d0f9fb6a6800d554fb9e2123c3ab	1343
129	14e50dac9151fe7253f0e158dd9db4eee1021bb735b3bfcad0d9bd887a22ae39	1356
130	aaf6822da0223c8b70d6c63466ea21952e4b45b4acb659185e1afa2deba89716	1360
131	8aeeb9ffd1c06099c6ffd1c8e44d7eee7ac8354eb484c35f3bf12ff7aa1a00c4	1377
132	93dc7a05527e2945bfa5f7ece8cac6a260203142d22d73031b3dc186935fdcf0	1390
133	a281ce7cd0410485cb2049a3dcbd6113b3292144cd59bea7a326b712e750bb02	1393
134	b13e8e4e743867d4dec3f89b929abef260c92029ae9c088d605e5dafb4cd0d02	1420
135	bb32bb296364d5357ad694963f6f4ec2b2d237c53df12b36252e88bc92ed65ad	1425
136	ee583b3581d603f40142fb9363a3b029e4939c4d10e856da7ad8606002344910	1429
137	e4a25cebd57af4869c6284df3d292f0aa7bf2c41649e4af4bd4e91c8a23ac987	1437
138	4c6c2ad5a5d56420b19c07465ef248bd0b2b23ab110a8cfe77feb91e21d14461	1446
139	200e9f5cbe475b223d14d59c364246ed8621ac45da548c6aa0db9ab4a00d7aa9	1448
140	47ce589345067efbd2eb0d4382288e9befe718188f624520218a6be3fbedf0f0	1454
141	a54b98e9cc4f8398a30b7d626b3feb3eb67d56aec4f81de380e0cc9194f70b7c	1461
142	b011278e96bc85680301adca49f0bb8af39fa2f3a0bc4ad2f7480fb02d7f9c72	1464
143	4344ca2b4d60fa6839f130df3bbc74c2df23a3c8d788f494fbf13bfda9505898	1481
144	8c9809605dcef2594bbaddc7d49fe81f20b830da9d11baec023bf3551ff85048	1485
145	6be585a30e63397961431df4ec5879ea1e4092497e80e92da4954c9860a3b09e	1492
146	3cc4131ca7bebc7e6670a62ba4d4d5bbad24176d2c1f7f428b169007bce6f9eb	1509
147	634bb6d74299ab90edfcd19534d5d01c2713d77652de09d1f68527ca5551db1d	1514
148	41792d04b3e9b0dbdebf466f82f9439fed755ed82a7dbf5c7133021828a3b9b1	1522
149	fc21a4489ddb0b8a7d00da8cf82aa689c5d4390ce515e8f43a870eaf7ca13416	1524
150	682571f6465b57063d238e831b933f8809085b41e51d75165b2ae81d4de89fba	1526
151	01cb867d394bc7786a427bb4a792a85bce6a6be65178c2ac4ab29e4fc1004d4d	1536
152	4ff78357d6d147c9f1c57501032be95c461739d2d31282c2608a2f52160bfb78	1559
153	52f58357a91c47f33902c07ddeb2d20f08728e53f1d3d88e2fbf0ce094c4aee4	1562
154	fb99a8be3d40e414bc06265fe7996be40f8d4b8f5f449e1e6392aba349555d8e	1567
155	015ea5faf16ce2ac7a00b883446735c607c2c14a9fd819707c5f677b137307cf	1570
156	646774acd82a1985b6b42817a61d1fdce9ce491b3c9eb7382891853b19255490	1595
157	5d140f6d192ca9e68e2ec95c5e913458972ff6255d43289a7b9f0c94e4ef7cac	1599
158	11cdf96a3884fa4276d68ed6f0030760507cc795b83f7b7fcead6c744bfe4822	1614
159	47fd257c2f8ee43b14baa9cf9ba99dcebebb42a99fc47bced44150633c89b551	1625
160	71af48d42fca911d5395c7c15b0c51c8f1a9310a849e0b605b8f0d7b7e85eea2	1642
161	3cfe09b03d7cc8b8f03320fef59ff536b5ec7405cfc812849eae2c678dc46510	1645
162	375c4264b48632d6c80dd1a688c4c65e4be4db285d99613541823d26bad83b08	1646
163	7bfeb82421f8ce5adb735b7733bc8c3abe1feaf7c18d4acd9879368740e718f5	1648
164	4a53ac807e0383ca5f12bdb6e6b04be4030b6d4fb21668795537457df674d823	1652
165	606506537ad63efe281f4301f04c19b19e53f26a0f7d489ec4b314b1e2f21b22	1664
166	d46e934d3cd871058a4327637760257ea982e791f079c3e1c3d32ce690719c45	1680
167	cc9aaab5e5011e7ff66e81c6a07c3008740718fdb40c822964a3a7c87c583227	1694
168	6b1d478b3cd9a2ab0c8c43f66d2c82145902a2521ad6cc5c02a329cde9fb2014	1699
169	404b19b9bbb9cd7fb0487400cfbf0a634737363cb3505fddd1451590a50402cb	1701
170	41ffac46f326f18fdbc0c2824416f8649917bf6fc52170ce59c599ef74351f50	1706
171	0dc4f73f02094a990a951e17746ea0e5816cc627d53408dfa461abd126926880	1709
172	a37080e79dc6e9969ddecb6a6d5fee7587243ef848dc0c4e3db4cf5633ae168b	1711
173	63d109abfb92519fbf99ebfcc8b5550eb8aee7256622796055fec1eef1abdf63	1714
174	e9b6e4ca6441f23bed603dc6e2c4d488ca0aefbeef9110b8837db5b88d7f07d1	1715
175	554496cce94ae1d343442008d552b27ce7049088d8a2f395050d6c761caf5bb5	1726
176	50866e1e55d5c94c1ecff5694d5253338c5bc8e74cee293c21ff5e9ebd36c4b5	1728
177	22d0e88eb0705d03723168d232326ec9b7fa262d016fee2b40d8ba657047185d	1733
178	61595c6dd4e1f1a466f44bc7ae91d0fefa3e59ddc374995f24fd04c1042aa735	1741
179	12d8d288bdda4cccd6d98bca2240c75fb1c97fe7e912dd9bbd4591dacd9c0c13	1744
180	6f5b9b838830c114bd2616d3f168a421a3e282313dd098cd179c489c57bbea88	1749
181	8f77b8fbacf9dddb51cdca993071a13b21eded7113e980094f7c669289492a60	1767
182	38f908be8f2ddc12995f53602e7035ef609a42605ece6bb32a72e3fdb45cc8d8	1781
183	b4a34d554ec699b0f818371b1f66d5665f51056cb19c304e7d22271bf02bb09e	1790
184	738c470355b519d77232ff0be415774d4c56352506553de070100f03ca257b46	1795
185	ad826277b435de218f1e7aba98d7186a79d027bc7dcd36922f4a622dc63a16da	1796
186	c32ab182ec7a7998b1817c0b501b5bfc16cfd58c47789a49386188d03a7f82c2	1801
187	1bbdf6a6055e122b53572d6e3073f01c8bb7f71a3d44f10530335f785645db49	1803
188	cd99f1100e9ba260a777bb76e199bfb1c1e3bac252eade44c3523c349cc70e06	1819
189	d870c59694baae644536b8e3594847b4dd87322bef4097404d14d8fbd9ee4428	1824
190	7644708635bcef3c7f413da53cc2b0d64108b3571d35acb55b39c988ff326e59	1837
191	a745c5e349414e358ae92fbb00e21b3cc738d307ee9279cfd9cc419bc3ef31a7	1861
192	64ad878634ab76fccff7c3189724234e7f93926c37c73382032f25d365daabc3	1869
193	514835cd3946c9b41bedc2044129d16cd49af0ea43b67d54179df9039b0ccad9	1876
194	4f62b2a0888d38d067532b93967ef30764628c9c471cf5edebeeb52be01265bb	1901
195	53f0d9a1eb57b4a0ca2634fafd0054aef5bdfddcbcb3ae9adae8bfa864fef759	1910
196	11a0f68dddb08e538d4f4e15e0c1656cf556f784484f3a1623de0b6566aea9da	1915
197	2e068706699be3fe8f4a55f7212cad4cae4416453856e3ed3dac5e3c217665d0	1917
198	9e9091570b091067fbdf5d5a2086c9927326b62569801b4b551227f4a47293d5	1920
199	6db477908c9eab52c5974c4b45ee450f65604eb14032cee4ab5a869d41e4cd00	1923
200	db970c2fbc0a5c56c0ffdcd01bcf80981561adc692a5d78dbc363c8e83a63291	1924
201	ead7c411ce72b09e96056fb5a86d185d8d0b49ae1428ef3d8fb321b3476ac8ba	1935
202	2d82d2f633434a0d45afac10797b87fefb6cd2433e3fa7442695428938fac1af	1964
203	e99df205f6a12fb7b4dbc3952f8cf0a29da6a248c6719fe69938fcb425174a74	1975
204	381e374b775f0a29e15a4f325c2cde9c35bcb22c02bca7d0808bc07ab5ca2cb3	1977
205	49f33f9e7ad12f88f8bbc6ba62a5a94f208e1531e49826c3a6e1f51ebfac89ca	1990
206	b7475628d0d6cbd4412e77be984e206d56dab565ca40c5b2f8e9db728e8daf47	2006
207	87a68d2cb3510cdb5fe90269f95adcf558ed86bd28faa16cc726bba8845cee41	2008
208	16138f5af6628458dda399260edc34cba0b75ddb44c9a347b4afeba25758fe8f	2033
209	5d286cc4c7be0b8ba37bf43a20adc16abf5ddb0e87668d1ba990856e87425014	2051
210	30c80cd0819558e1224914343adddd5738cd776d8d76297ec8a4eae346280c05	2060
211	9feed28893eb7bc224b44f50efa4eedf4ea09b24e61b9956b30f026e8e698a13	2079
212	e32607a5f0637390d946e3e39933884aa241be984c8e9297e0ac1752e534ff4d	2082
213	dd2df17445a783b05bcfd86b06fcd03c3bd4d4a033af283c16dbf494b1fc2673	2086
214	c000f467fafed87fecce3778faeef6fd6e2658643f57c7a972a5fca706f88f50	2097
215	3c9660c7c2c4db433387cdc396d6963bd5d79fb1b7bd65eb7c26f0991299fcf5	2110
216	b037644f460362650e091fa4d00ad20f03f8f41f8efc528e916a022c8a7f5741	2115
217	7c369d0193ee7db644581b97155582fac4071ca32605d547aad4609c7979a00b	2153
218	dc0849b1c41a3324d3f6dfe12baee3462c2c59a86c7cc3477b603afd6b17ae26	2158
219	aa166cc17bd4ed483980e71820c34cbca082087671f0ab6e096f04c08fb8380c	2180
220	d9280f922f9f5bd890d12df57cbb3f6a381e0bd331d2a40c43a8890882aaeed0	2193
221	2234412865bf3c7bdfeba47e0250291957ed09d757d609b9123b6a43a63f80eb	2205
222	0575986bacb49d94c5d851e7738f89a5ee29cbe391200178ccfc06e018b6f9be	2211
223	1c9be9b7efb04d31f33d76af3ae1392555d8a16b9c2863aab40d422130f513e8	2215
224	1fd6c3887e47e61d04cdc507a9f19d3d6312f354d486c55f1cb9adbc4ce97f6c	2217
225	6e22f34adbb98284761277071d77ab7a9456d8551fe0bfee33e12fc1654a8e4d	2219
226	70eea8e21e19d758e036938b3a917f07c29681abf34973991936b89f54ad07a5	2223
227	3c4d05aafff0fea9d85077d5612fefd3330668d8152e013e5a497963060580fd	2237
228	fe4832260e6c90c51443bf215dfce3a77cec7b7b9b23b0b58dead3b2557b73ed	2245
229	c0b738d8fd173eaa422daa8811f00bafb59e440ae291a7dccf97b7a743b34d31	2248
230	9e88fde9a94f94f8d1dee5464548a4c2932db0509368ca4a4d0bef2df1d40bd1	2273
231	2c543f8aba99f95f185416228d2a692bb4ab13db5315e5d283b39278149ccaaf	2274
232	85ae5d8bd102918b98e1a491bc229b813f2fddb6ed003d2d57b342e0d43c8f95	2275
233	de656a2d8c189d97a2db84bc491140a47b26d41c58e8ed0271f931bc65f69d14	2278
234	76732e0b8a17176d5bd7ffbbb1bece5a271b64e4247b405de0b3a5dddc18605f	2283
235	346cb8cca457c42fb35d31a8560dbd40153defe1f5d331e27195a94f9d9825f4	2291
236	b68592ef59996f5e5b853349cb2b20716b5ce2426ffd85c049f3adaf2f52d4bf	2299
237	38b6cf44ef68879eaf703e1a63504b3008da670b4a3b51e45feed2aab70bb21c	2303
238	373907b2ea3194b0dd29fa62de2e7d695aaa47a450aaf96a21ecba30da2ad59f	2304
239	8d8b0877799a56eeb039857228b73877e7d04d15371c7c80c5c43b05e107347e	2309
240	28b73efa1172baf105e81a6923cb0f417fcd4687553d6386b4ea9c6f12b5af38	2326
241	962e93c07946ef520e101047607bbc35328b3b6fe985d9a488e150f983722c3a	2328
242	a3f0fa7ee640be0f2f68fdb5bc671be110f364cde3e3d0d9ddd34acd836f109b	2334
243	0ba489a15b0a60a0f1e5825f07e2cb95badf9680593920d688a4ecb12fd287e9	2336
244	45f314167bd4fd324d51167faf1191d16ec26d347f3faf6df253b6c69fdb2c73	2363
245	2e72b717c74b9912365ed321031a83a1bdfb705b933b0f4ce79911e2c5e95f3c	2367
246	c766e470cba84b0fca9dc182f9f5f2b3e3aed44d8a956bdf46315c53bf68ceac	2372
247	48d198b45c1ea265c6d711ecc33a12cf1fa55ed0ad8cbd54de772574c9b09748	2382
248	f7a82d38e24d9fa0127eb16102f70d758685114d46c8a0f120ddadffde513cf3	2396
249	29c7d67d76ea53e5456a050e61c7ba8f3719c58ebdcac83307a44fe1e24a91fc	2404
250	ed2278847b9652c4d57a19c4f0458bffcd5a056da74f18d9c22ec06df42b2370	2411
251	fe5409d63be281e2c6fdebb7fc96b10c2b50fd77aa55dff1ce5d0636bb5c6df9	2416
252	10f3748feb16693ea38774334f0458ebe15f23cbb653e9473a68f9c671340f87	2423
253	ab6ae1c895a62af1b2b1054684bf61054aa3f8d377502fe7cfa310e91dad48a2	2427
254	ccd5c535828cc364ef04446d783b7d7313a21b8567473ddb905bdc9d3ef31f1c	2438
255	50306633e635e2df8f3a12f866dbebe902c8eac3d4b9f906fdabd572b08c9e32	2443
256	1e1a29cc782e6b253761914c11cc1610e2ffea12a925eb57187eec9d1395508f	2448
257	86506b627dff437d57e06b4c30ede7b03dfc18b47460f3ef963275ebc5725d5e	2485
258	1ea3e2dad0d72f481c28269e3ac25732c2db04e53cb0dc066dee6b1f3701ad0c	2490
259	4731c79a8478c50a34083eec5341f349828fc2bcc6bc46cbbdb6ee24d008e385	2491
260	75cb33be06033858637060fcd520c0bf8048126e17f75d5f0f4fad4afc76d636	2501
261	7385118c192bcbe4b2204b3b8331c1e7ba5ebc67d8c4f760c24096dca90c24c9	2535
262	f309620b3bdb95f8640abfe299b17971d39825be03f70a18d4cab0f27a464a34	2540
263	6d72f583f922cbdbb7749f8c010a8b057b7224519fcce3398cbfa63552dab964	2546
264	732d81b3ec244e33d5e65a013c610821ec40ea6dfb8861d9bcd2cb2a772f2668	2570
265	9bc6e0aa31bf9103fd11abe4a598f9e1df2c0c18bb52710183184152e2b70f91	2579
266	5d3e8770a6b3600cac2a019d964120894ffdc8d5568129ff155b68e521e9f225	2604
267	1c2244bb67410dee17f16eb4022adc3feb7a0c464e2d1487dd933fd748ddf74f	2608
268	53f5b223632b28b5d1d3084633eb4d5ff3e6a2e7cb6c3ae73f674ba8626028e7	2611
269	0e87b12b04179fa0952900631cf45fa296380df9bc41e7bb98d039a7ad59c869	2627
270	c7f2496497f0dba682f663001a56eb978241e2d8f66d0156bd6ec3de2f22355d	2635
271	19bc9adf7b9fa244323bee53eb4aa396c1952d84b749da9bf1e187760ad6874e	2639
272	0016daf87f0f104aa165eef3457b9f10f02e4a10b0bb4e9aae7e8280dbd1440a	2685
273	29f73ed5d9fb953703f380b78ef672d1c54cec23716407b47a7d6ad1c4e024cd	2688
274	e256b2f222e071ecd0925b7da49f2fd851ff9034a8ee0f0d9d527211115d33e2	2690
275	05d1db046f6df03b0d1d118e0194fa637a7cb1133f83ffad31a042f8eff72b4e	2693
276	b389295287523d49570e11cea8611b3a2fa69e7a74a53cbe8af379fe7f0fc6a2	2694
277	2ebf0797e6f37ee2bf98c6939497242b63658a88c5ff1d57e65964bafd9cc25a	2697
278	ba2cab67cedec6789103f7b12342aa8916eb4fd947f6e019698e44a8f8171c26	2706
279	88d0a36e0fa3ae2c5d208ab4d51f5b5023613817f1ddc011bd96cf62bb16f222	2727
280	99717eb7d8963e42f443877b95a092de9652dccd1ee8741d6c57d55428f5a6cd	2752
281	0b3f65f54664d4bd52c837923bb00323c56b483d2230a763f42aedaa8de0fa26	2757
282	9e484fcc428cd7dd007d7d3f17a81197d221d7f896de4d1127950423e7ab0ca4	2759
283	7dc798afe78556b2fe4c86fb6297a2595a167e8655353b427f80bd63de820853	2769
284	639a4129c8d899b408feafecc8631a61b10887292d93cc06cdf4e1841ba708f1	2787
285	9a304329284d9ce7971ed60e44eaf6fa1bbdb3c9de9efd80b15d0f8e3dd4e725	2797
286	009b03ecafd58562addb6e25fc136ea58794a6a93440ead4c4657b1bf187e136	2800
287	539a41ff68ae5aa617c9e4d79fe0cddc1ed058c164421b2ed810846fe44b36fc	2802
288	b3d1dc70b21dc5acf881fda9695f266299d06669f035b87d79fabb130fbc4e44	2809
289	a13c4913c6b5bd273fe35ee6ee0502c345a3295748f6a2e3b967a88e911be325	2810
290	263fbed513d42f8285048e955230575dcfc21e4e5d8feb8dcdda2dc074e404e0	2847
291	4459073a8fdf369710b71d3e9135cc024e14891e1d3c6cdef50716d991d334c1	2863
292	6aea3239deef951068e4fb7a87bf9920cd788f057fb1cefd725885097145e41e	2871
293	364680172904fd3225cd6fc7d448a1756856d45f179d8606d945f6207fcbe6ea	2878
294	24f001af7feacdc1e3a2adeca76c8977bc5f488223e9e50332c341586ab19bf1	2881
295	62832144a100a8d8d8768e9a7f54e28e6da7cb47b4300a8f7b9609efc40679c8	2886
296	7f28ec42dfc7216aad86a5edade4bc35decdc1c0f120231426f9d8ad356e35a6	2889
297	57684099a088e3f403609f2d96c20989fd3a6d4defc98093e5823d374759dcc1	2898
298	5763f356735bfd36e047cda55bc6568009e931682f33fdaa825bd7dca753ce70	2899
299	901f1a44077f6884d1157bb43b5ec69a8c27e51c79e7b9c8b2a874dada9c6a68	2905
300	695b63efbccb9dbf265abbd1184294023c8a8633d324a963b62f5a4e9d0924db	2914
301	2d0458701281a5ad7fa74b42104323c08c6d0d49af6567a32d6baeeff21705ec	2923
302	a56c6f0d404b9d950fa17d3654b884d6c5c321f69e78c8a826259b1b9553d336	2950
303	4eb4764c8cbc5d5ba45dab08852532caf0614cca05b2f07bd10476be564383f6	2970
304	5b639ea95be8cea547281991118ce525af1eef654040373eee63b3e9f69915b0	2979
305	03c714c018c53295c148851548d6bdde79045f19d9444d93b71d44eacda7d86a	2982
306	f050bf71b921e4540641e7b1846b5a13d2debc5626fa86f3253a5b277630f268	2983
307	1961779c4beb8c85a13163cdc9d8154ae87ec271af4f3e837b72cf5b25aad85f	3015
308	8e8b7d17fd5c894a6256bc2a6e36d5004739bdb9c515195c3b3a6eeb0b67b95e	3037
309	80f7dd07513bc5b6ec9c114785d1a3e9ea951d47c4e42d8c92ab24ce398a4eb6	3049
310	f8742d6b8403cd7616f8668f7cb1aee4f5c24be6542a7f4e2f5495548addaa91	3070
311	6eae4ce96ba9b6c4c3547e0e770a7434a9ca4f72fa1dfcf81ff28f4d21bae013	3085
312	110213a71e83fc0d5a0f504a033ee6eb1659a7fff3349fe749d3e3677918d790	3097
313	a36e5b11abccca43312255d8d7cc09f6f6248dbc4d643b35ae10b2c40796a012	3121
314	ea67ea84a0054d55244fe079f92af72e97e21198043fd71a14e8e5515f7d0eac	3124
315	e466f19744b964fd7a0b64f83816149ae7cb1c873d621307c2b87f34ec7f3999	3128
316	596bfdfebb2f41873959a0b3f35e163b097c2c6a3a55f5f2db74dafdcb259c31	3149
317	33ecaaebda5473adbc3a486a4490a04eba1d680d3956495b9fb0259320387975	3179
318	f004ef67618a3f2084c6a5f4f0da1cd02ec20d151b056488559f78135734bc72	3182
319	7f746811a13cc78709d34dbbe3eb77d16a690b1eae134dec370f72b82579d179	3191
320	8aa768c9b87b3761ac1604382e9b9c3617991a527db07f933b5d21e57f01074a	3229
321	69322d8c86f5825d5ac2e3b3fcd6a743cdf4e23359ad17a6ffcf94641e7535c0	3231
322	fa02402f8bf46a3daaba8b489623c54c8e12aae16454d947e633cdbafbff83e3	3260
323	681e910811ee51275d92a2c14001ab68bbf0c6446a5ecb458617fb1544222fac	3263
324	1d5ce64264e3fd9722eb4a2e3dfe156fc53e0296b8431fbd2a84cc67779e6e6e	3269
325	b00cda80046c3942e48bdb4b01c741a1ab45042591fd4169c89fb9f265b3cb7f	3272
326	52f640d016fb06868fb7bbd6920e917f4bdc0068f98408ae1f779658139f9458	3287
327	91edc414d81cca6b1b8fb2824eb3560dd8b56a31b402307a26abcefb019f54da	3307
328	9eca80dd004d68d291b87ab2c79145a86fa4c20e739449100a11fa2a17500cec	3311
329	5f87abed9b397e6d9a54397bcff4ded87d48f2fb8f5fb13e7e48e78a1ad8a02c	3315
330	3cc096684973c119f1e5133b02187be1f7c8b1eb6018d2307fa05e6a1cc5a88e	3351
331	105579f565ed14b27685bb91254e200b2aa748b34efba9d9083966679920659c	3368
332	8d1c32167c32260b22bc49608d131ea5e0eeaf1a696c4ca6e79ce7b20dc41547	3380
333	8305bb1dea20fae9134fa878721bc7609db5f75aacd7dbecb3d3f87e90591c11	3391
334	825f751148526868910f537387e1ae83a159a45b4e8ba5a5dfd01ff40f1d0f17	3394
335	f6e5ae2c2e22b766e896fd26dfeb2dcd72d5c82337faf3b0d00f1c2cd28ea82d	3402
336	21ab9313a2babbcaaf436f98760be38909aab76463f8724609e0b74ed51e8904	3403
337	de0da84b3247bf97cff5faa1a0e0c66c9b1e690bf2ed77769eec4e634e9d1657	3437
338	bbd5df470451103a82a30179dc5c2c0bd31352cba8697ab260e3a956e2e1e8c4	3447
339	f2cbd9a7bb552bc1eb6ecaff8b36e66b341780d69a21c0765c812fecd48e86e1	3460
340	55dddc67d7adb43ef81c11affae9b7a7d75da7429987412483048290e74f4e07	3478
341	ed8abb9a19a25424bc24fcfbf6de187a54beb782f81e01545d7d6fa63441ee93	3482
342	6c0c06d589b042e272bceb93524fdcd4fdf58353fec51203cdb9d98832d70274	3494
343	3ee604b7f286cd88ca40b681f7cd6935c1bba22f28b200fa86da218a1d2c9854	3506
344	42b52be32d211c3aaf01b1886d5cf746ee87ec66f596beed649f554effc9d29d	3509
345	1b3e157a60f7288e0038cfe982b467453048e29fc6af3b3c1543de6dec0ce31a	3516
346	830b694b9cdf67f118b6f46d1e540bd1c68136d51049c52377d12a6b907369b4	3518
347	024c23411cefdde22a0a99571665a9cd2374ce1b642fd668f50cb01049cdd232	3536
348	212fa378533a51fb63946c7cbba62731df12ab054dc12410030eb9fcb6ec65ee	3552
349	e74f695ffe820290cf631cf420921afc9139b69fdb859552b45182f40fa06f8b	3562
350	17f9edd289ee8a453888671ca437a3d6aecd030a7632a39d3c87176ba25a62a2	3573
351	04288d05120fc5135b0fb12025468b948e0d3885e2c7b332a9ddac2323bc1d4e	3574
352	6b45f4f49bab48b839e780b65e15bf130de7fe1e2b3e665053d9038854069640	3577
353	824887ea68afcc06157f99e0a2985557301909048a2711fa161baff6afdda76f	3582
354	707d8a64d84c0af57af8006932d897e26f92e046b874a18712f47f0ce43cd789	3597
355	ef68e9ad02acaa96da9332df70ab3695e671c7eea4ffac6a98d97128eb600cf7	3610
356	dd704d61d92f50887fb2002b7a825302041595298c6bc8f44f782ca33f1f92c6	3633
357	7aa8963b100fae813b3b1bc7028837afa2d873cc5a2745e11ece615d77340e2b	3643
358	0def47f3616a94ac911b23588e90b040ff7cf19ed4a31c7f073f95de660e4b6b	3658
359	8d9ab4e2c30df6fefb8c937af0ed383f43e28ebb75b2bd691fcdd7646270deea	3671
360	1682649a37c0a4ff6a0552e1aa224a5ae59d597657b48893dc389be042efc3c8	3674
361	f124d1e49f04e9887309e4f4e9a60d2f7f29ffdae2f55b498bd60506fa31dd76	3675
362	05462b13d8691b0b9d689724bb27494529a5360ef95f2cd2cd413948995a6278	3687
363	523ea53464670a07e34fb0d5d015d8e68f641b3ba1550f737a7e07c068a18259	3695
364	e9b4baeaae9be95dcc25dcae8227e8920de491e3f172f1eb2faf649a14605427	3706
365	b4b6e5825076c6ec77b9dafd81ba06df535020392754d4de3f5fb8724f91c943	3714
366	fd93c58c420c335b8835561f58b7cf866978dfc7df397537c927dbc3c12fb24d	3715
367	e7098e1a1920f732750dcc544946f58055fb382a9d0fcf42297cac80b5512041	3724
368	3c7339b20714ef9c47c83c6b452d07e729b87f45584afc309123192d5d655697	3757
369	2da967b2dc7a5ce3d6a338784f93a0b4a3ced7f16b9bc2b43047fb510491dc6b	3760
370	8c52a97e1ead6a46f46b63b1d9b5ee60e5d95b4ebea9bcf31e06ca0394971a2c	3782
371	8248b4ffb8bb9e2c069cf7f3ef9fd71df4aa508aca6cb80f739fd1ca790b96b7	3800
372	f4eeb32e06fd003772072965a1fa303a160456fce16e05d1e508b4f1b548278e	3803
373	8985a344f9f94ea71b071d12a79ddba7b6e7695951b9c17949572f2a060c7372	3810
374	b15dd92915bf40b7ef6469321268b5e78358717701e8c2fee78af70fe19cff27	3818
375	e34375ecac61ac90adbb16c958038f1f6ab0dd5f1180cf3cb5963acc51200974	3826
376	6d9a5da3a2af11f401ddbcc65f620d91e2f3e1a9d9fad1d531060af9d144a9a1	3830
377	ff604447307828459193d3ccc9454227517065e0740e733b70ddaaefc0752cd4	3840
378	d473239737c952c80099313b61fabae79cada326d0ba63320ca3c81194641d9a	3841
379	9ba7796d89baf852d1bee6ef7f790c74f9201640603b232064d62417f4d5cce7	3867
380	ca4e1150925a06f596408fc8718af9f19a9b91b493540466b222f262edcbf360	3868
381	bd5f7c36ad6e30f2281d6599ed941279978e1652102a77cda64060e52107b6cf	3883
382	a8dfd3477fc495c43ee4a0e9a02955b7b5882f187ece262fc3b93c95540d5381	3897
383	6645de0ab25fa5740a655aa5abbe439f8dca7562c571d7ac2d432c2a33d262d2	3907
384	5bf6fa55d513c6ffda8839b9247544ddd71d5c2295c2d8c786834b10e4d5db9e	3912
385	6176179026cc5463ee1dae1c6c46e135aec40d7bd11f375b9ff675e058f63efe	3920
386	fb65e9132b7f812646bddea7a5d580de5dea60c7206fe949be610f62d8adc0da	3927
387	3196a1fa91b324f73bb8c63bd994580501f193fcb7bf0d604853c239354fcff5	3928
388	a27d947aaeab12dfd5aeada2dd26c6ad4caca748ba7707f72b3e1dca630ce8d1	3930
389	073c0ca04798f2eb811d08cd302e843e93ab9ce2632b946fb5dc193c47182d29	3934
390	eeb7294176f310b5f214b05c20403f4c452f6ff05ae22592e2f384ba3930948a	3939
391	0fd0565157dd6407caf0db2e3fba9093f86d9b072d60dd23021cff7d601e1d66	3940
392	59db9e950b23863f5f71fc1b1f7108a9323e3bb93c27938628ed557f039d0501	3941
393	23536396a1e77cd53fc4269b99a3ca472c8311d2d6f4c322e312140c7f626177	3942
394	b297d4c8926ed05b6a79a116e5ec1e560fef01ce5b4d9b45522ccb8511222e2f	3946
395	fffd688a596803fcfb0d95aca1de6914420a52c3a4e22972561c00202bf572cd	3959
396	d586bf551d0dc2a4b11eafd4f1d16847f2f0842a95ad7fb02a1cbcfd40dc5a08	3989
397	8cede2cc9e4d2799af52a6fc2bc5139fbdc96efbe9cd9c11474356f996e3c839	4001
398	14ead6444f0d3aaedef20d4498a6190b6a86b8bbc51033c43f6e3d582e3170b6	4002
399	7c73f4ec9f5773c68452c7d03dd7c8b2a901463ce17bbe967b83dc3da292b24c	4050
400	6500961cfc9fa30a39b6a4c517087704fe8b21a1d77f0be7ea08597db111c7d1	4054
401	ad2cc4719685ca84ac08921bd9a900b42f99514814bad926cc722a69f691a2f4	4055
402	ac5b7a9bc7b7627ee86ab6b98e802acafe0e22ab1ea07344351c72a65e8f7dc4	4064
403	2ae6fcc6637a745eb251aaa77008163254c7aa65f679568e86bd70fb5b9e74c8	4081
404	1176decbbdec63fe63b18d65f716fb6829fd2067d5d87c0e090dbd1bdeb1c69d	4086
405	42a79cc6f534a5f231a41596f0ae1a71c19e3c532771846d373c50f0136fb23b	4095
406	65a72efbef358b7bfa1c2e0403ded54682be2d554e2ebaf35578227c02d72b2c	4103
407	23222a38699dd20810d53fd84e7113418a19fbb9b4910f633f982b26102cef3b	4123
408	777adcc43ef388731b3307b83f5d73e9b6f43817d20eefb91fe3c6c414c33c97	4146
409	d16e81fb0b2bc3895b03e32689d94e064b19c2c7a8aae4d30a6c60accee4adda	4163
410	b9fafdae4e4c09201304d9827e37b2ae34c3380e7ce5717b3745bae0dad96bb1	4164
411	58b66adc7118dd7bd82a598e7db6a5e585a454bcac744b2e8d27e7a98eb500eb	4168
412	7adb6fc742fcd2e45dd748e729330cde975326a86a0b9c91cf59a01e7288268d	4173
413	0aa552380a1f70449ebf938bca821d466f54d73247f8c2e0af476cada95b60ab	4182
414	16c8c3c01e8edfb8e8c23f69867e6768e8c8eec91c3a5f98bb20f3dd897a6cd5	4185
415	a0f432ec84e8d85fafeaa75063edee013439a839e4962c76babf5b4aea453ebd	4188
416	15de9a944d81e33dddf0e6f6f0276233ee421d36850ac8854d327e9e46ea6497	4196
417	9a6befd1dac6531c3a08eeb3a17d999eb428c362e0e7ad56c83e941234ab358f	4207
418	84b1de7945b3e8c080586eaa84455b65ccc053b62647c2e55fed69b09a217b96	4209
419	83f31a893e6c6f624e89107e97b15f6b4e4e496353e38a254084334c746dc859	4229
420	2c374522ea0e2aa3d937714814e265c8144483806bd736175db099a02a86074d	4244
421	41758d9b12cf6d21387ebf9e112c3d1e259be8997b7de83e0bd19fc054da8020	4249
422	834d3e3e1b1676a239e2c8ced2e7a5f19e86de6cde9b9be01d0d1740dcbd18e6	4252
423	c9842524d237b38eb5bf0f94ae8a7058b25df558556b6fe6f07486bf6eaac234	4270
424	6fd28174fbd835cf6bb110ede510c03412695a7e30d7817f0b572654f49dd52b	4291
425	a63721182a210ca6f38699432d459ed16de9e0c50b5ec71cf1c0d2917f9bdafc	4298
426	91ad84b6b14fbbd0705e09497f67d35b0a9a8afa916359e6ef872c597aeeeca3	4329
427	70422a3f7d81ac060922a1db803ceb6d1b4d61c8e11401276bc8f1fc62e376fc	4357
428	518da7573448e962ef6110a6e4f06818e73ce57371841c296e06e562ffb1c6e7	4367
429	72e2c9a2d564626c16b2a7d9ca6cf5722069e41a5c3475c56f3568094a4a1b40	4373
430	0a046bdaaf1cba0475d07ef00a9bbd1840442c80f5b47266bf52187f67303b71	4384
431	26c830a6ecd4027e41ddc55f304538f4ae575b9b9b216cb617d9a448d2b4364a	4393
432	2eb4f70c64ed86d80e8dd5efed18dd2a66ba1fa61ea9c22316e66069b40446e0	4398
433	08d2fc0a3b518c42c18a7e550cb7d984f737017d0a468218f8442fa91914b97a	4408
434	174179e183d7b15e995ff9f2c69c2ec3c6bf635e6f5ad0f01041fe9bb3457596	4411
435	a761a2a192aedebcc28e2d2fde9dbdb7403314d4185e3b8b251bee0fe615026f	4415
436	fb72d044fb00f58767685c8649ac20630ab84a25da21d7ce10ab13903900b761	4427
437	416b3f4226ea3c25847b54a86f5238a4040449b39131ab764ff00211f5f39f89	4433
438	1ad5985fb611c64184b130abb3c3c44093d0204bfe765f27ffc0bd206ea1a43f	4443
439	9011ab9e835f098862f7650a74fe4ac08a0e28bfd715c067074b579dc139d67c	4450
440	3b1f8e6d61c86145194c750c7dc077cf74b4d664d9d0c3c2b17add2cb41db169	4455
441	8fdda0f3e79a7726aa3960141bd586f5ea89f464eae4824fb19c9d91be9a06ee	4458
442	56d3a321c009eb9782ba0482bda5f48d4faf35661c21b3b2c6f48616ae86346d	4461
443	f591817e61cc75b66f1d2ada59e0aa5402767188abc8e50728b6406c210891ad	4463
444	656b90d5d6575c9ee901868a8eddb3b6e02725f3ab3015155a69d6eea8727c3a	4469
445	c87b7b8771ac90465cc22fb93705f65d080a022209837324ab37c64f8a710944	4471
446	e9bb80628dc12c0b68e52ce4a57f7bc586fdb11d90c7b37a536c05211a5ee27c	4481
447	aba4780510b9e4e5b95489019ce3d9eadf3369700e6eed0a59db73b754c57dcd	4566
448	65682b379c10fe7216afc57b15f319c1061fc7d70269e83315b5f758fd12c86b	4574
449	8dd284ec7cd6b2a5e874d023fa532d951f4a39568aa3870e2cba8f37e6d5b5d0	4622
450	5b4b3a20a1e0fc660c7fecc26d5fa9d2577c76a2680d1c6977e1a0712ae5f78a	4626
451	30b52a8281fa0030dc2e397db9d3adc79a04c992802e3d3dd0acd13fd4fae79e	4662
452	b0b621949156aa5aeee3f2863ce1c1723220a6023cfd9a434da33856b1129747	4664
453	5894fec56374395562c55d537966d48627660dfc9087e6b10390779857576ef2	4669
454	16e231e6e4229e5e44f15d7214b8c0efcf8bc09f0e213194fa64b1d04293b81c	4677
455	89ed94b16e941c301a4f04574e271514fe6e6f5f451e1b214f72c45533682b9e	4703
456	5afeddb6d04d96420bbde422bfa9340ebb3a2199d7353744fcb283cf059d8750	4715
457	fb41cf468158292fe17df51570253af0b56375ed0f2f1a4bce96b74d5af997c7	4721
458	72b4ad4610e4d48624ec8091984c30c81aeb09ef635152fc61a390e8bbc6a2ad	4723
459	814fdc0e9de1255ff040cb82347398a8847940e1a2c45e59d08fb5dad8ce1d4b	4725
460	4694a9bfd8bcc28bca6e03615e506cf91cc404426faa80a2355a3d49bb8fe8db	4726
461	6034f631103ccfade42a369e2c77cba5b0da5d33b74fcad06513a3217ee24e91	4727
462	6356c8bb9b2ab526ffe7df06884acf8cd817e5f145a74c5cfd2e709115bec14b	4732
463	324aab5ec7f336e83f59840a2320a4f58a096f1ebb95bee785cbc1b8c37a0808	4746
464	7f58d534492be330d73603434fbd9a661ed1cde6e83a5b2f889616b4a4484a3e	4756
465	68c195eef743ca7b6ca2f7fb38d9905577fde9e0509c7190f1e3c5b2c1724c28	4763
466	354f849b90f06a794609b13e000fd5f34d34886a560de8b8ed1c9bc7651e7296	4777
467	0bd7c4576238febe416378b3f2481bc4e71ca66e34ca18cb8cdcffabd05df33d	4782
468	900e68c2f6749c657d0c1d6f1dcaa29b13bedafef2807615fb401afbdf507000	4800
469	853933c2db291e9f846ea6d589d0a36ccab89e2c4956a7ad501d5b7b3dce00eb	4807
470	217a9325dd6c946e0f948de570dff56babfd79c176c0e10e38c8d40e34176822	4808
471	4d160886e2dba4b18527eefa2f9723139d46f84f177eb108b23678cb403e70dd	4836
472	f05446afaa14ebaad19a330255954c2e13e381aca8c735fb40676414b7a0a265	4839
473	03bee835329ab4bbc07d7fe0b88b64254150528cbd5a0ce35f47a18a1f8b5c5b	4844
474	64454d92d93dff0ceb2a190fbc0d441b1c1c62b2fd0f4498b792404667716017	4846
475	76c1acc7a9ac9166d2cd5ea9314a11971c93f3ee8a9c0168249646b234b1b39b	4848
476	21b6d972e56d56e7d6dfd6ae8fad58550e213d69d21577329ae07a2ea6f22988	4865
477	b0644c5f0a13c3772b9efb15d0bee4db914cea98e6dbbe7dfd4523411703086d	4871
478	a4cd6ca54520a990eb0b42aa6c3cad418ef7e44de1c8d0cbf26deac6e957a273	4884
479	ba3605b08f696283192fd2f8b7b945fc150f7468e69c624fca1dfa985a014f36	4904
480	46ffc38a2a60e72a269dc3fab0a2291eadb1a1567d0113eae994aafed648508b	4910
481	f11d16d2247e6ca1018ddd5c8034032240eff83becee91dbbc41f97568912ce6	4913
482	0f2e7fc1cbb930e1c006e91e452397a5c75ece52fb2ad928ab2428ee4f94ed4f	4939
483	9e3c941adaac93dbe04e1269baa695774cab718867cbac3d55620d232a1bbc2c	4944
484	bc0a069992827fb9f4fefa20a299eca5a2abf5fc13a3e52b745b3996121d80d6	4957
485	ec2f1a04e414c2d2f433f85906a489d184f63e2a073b2922a4fb036f08a18e1e	4964
486	4cb63a2f4889d46d370281af5698feb29c85240ab0837d7be4170572e5dab6a9	4965
487	9ec305f5317147d1276ed6c2cf2324429f938c54e07d2dda983e2c5f35f67577	5007
488	bcea45bde0f1e9c817eae00566bdb01bac9b16bd05d4bbc60ec9925878809ed1	5008
489	6e49b8da7e7e40f880e49c9da2f84091b0682724d0ddd97176fd2c849f342ab5	5024
490	f0d0cb1d7738392869a95017234636db271b9f1815c8afc56d16ae65fa16b4fd	5043
491	ff8aeda67d8c52547430f0016c68c13875485fdbadec285fd953b05a6f37fd49	5050
492	fe5945be3ab78e55e7487eab9b8cb76138eda1264d1258c87f8b24ad3aa713ea	5051
493	b3e3b7ced52def932be5dfc4fc09e6e6681879b880524c318f1e6b1255d7ee01	5070
494	6e1f538c52435c07d903de17fdc78a4b999d9ce620eeddd96e0e3babc61580e1	5071
495	64974d152c4f43379bb8693f6b6366590e7f2486e991580ce835d6aaa088c44e	5094
496	89e67b46158e180c01e72da8e48649b40b2f1a820cba21df23eee6b83bae8c4d	5098
497	340b41e32806ff35795e20e3120c52a6d3ecab47734b976fabe04a6aabb45397	5101
498	a15ea4cf341d98cf42c637bbcb7810e9bf2363d62dfdc9740d5420bb89b054a1	5107
499	c9cd5722c24c1b97cc864643c49e5a729df7b07855bf0be9152163e790ff642f	5113
500	c9fb3154ad01a6f85d6ebae31fd276c783e35170c84a21c36cd6ceb45180bbfe	5131
501	e23978e37540d7d0bb88ea0fd2933df00f3ae053eff693ee07b2d7259e32d4da	5138
502	0a70f143ad71704fd75ce0cb889f94732cd19b3ae7bf23358e1887ac8bfad020	5147
503	3e42a488e8a36986cefb2112aaf47d89ed54e879ab73d01ff9c4c65ec6e079f6	5148
504	014dcd4c959d6a5b555ae0d119f0af1789f28961c23539cc132f5b4a90783460	5160
505	04fb63b3aed647d97666197e0ea0369b15507865552488f18cbe6f910c5a2db2	5192
506	3bef4725ceb3ff5018162d9a94c59f86725fc9e64abd057d30ae5fbf3bbd4612	5194
507	1aa00702800098ad58fa3fd986c927ed8107680f653fb865d1a72aa7033b52ac	5204
508	619f3be9299142a8d019265a1ca7e2d6e3cc7a3f921a9404dad66196441638f8	5227
509	86ae911645d71f9bd95617982d1037f37666ebf38d85f8b590849b7268d75e83	5234
510	2c6dab1a0d8d45e356f385f1f12ed4d22d893b248da5fd61b776a435883320a3	5244
511	5a70eb9b1d0633967a1cd60bd3d715348207df7ace687d8b5f99e8ce911295e6	5247
512	46950477ddbc247cf66e80953f1cd25f315206d3d0fdbc163d6b97ac1da19fef	5254
513	bced2af0bef9c29612ce6935accc65ff860b1f6863087a5deaf86ea3702214c6	5268
514	3a6ba355e5728ea5a0b2276c8897ef23b784c67ccec95b2d278bead9989129f0	5273
515	b66086821159db2c413b332ea1093d8116089bdee6be05de358d89b29db62c81	5282
516	ed763b474c2829f078947176b540428e84c4f824ac39299ca5ef99096275b4d1	5289
517	7e331ce493ad4f6a432972e0504f24477cbd7390455e71efb02a5cd8751bd680	5300
518	57f8901d24261d26c71d9c748fac4846dbf751c0a3de785f346fb6647db15b08	5301
519	2c5f493f219c4a077b570213abe1f40ab291cd93cafef292598ec4cf1017af74	5303
520	186af2ebef1f3347a1ff3781d0cda0b908f1b967704af0ad495d491374fe03e8	5311
521	4f3a264ce6ae3af9dd10e79c522c3da253f2e8e72f120788d3162893809600d5	5327
522	3d12e51e7534e3def04327172bb451a63730ec712f83f51cbb9318a528c0c260	5329
523	29cf5d851b224420042a8648845d597b9556bea70aaed256b55c1d6f25c89afa	5330
524	7590e3a21daf64d532947d470f549919e8aeea8eaa00085a1baa81f14fe8faa9	5354
525	234f7705798fac9cb448cff7faa262ff7d2f68c96865f618d7f46847d919fb94	5359
526	43beac365c55fbd4a1d06e616894868fe4f6ab333a2f1fa08798ab8f7e2141d1	5364
527	476e3cc1a4e267ab70caabd016d2268181f71fbd51b64ffdbe7336547122b203	5367
528	62744af578d171d9abf7cc754345fb6f8b602bcb21fda76630b4c8e81accf328	5395
529	cb7f53be7c41ef4417cc9de6859fcb1b432c16d9c82823065f28efe1703728d8	5400
530	250e3576faf0e4d4c966ff4f1ef2cbca29ed32543a398d268feba11eb76cdf67	5432
531	4de79cb7786fa39059454c190e846844eac14ebbc5ff1248236cb688117877ba	5437
532	ac2d805afb298af6227941fabf12a6206646f046f58a37f71ecc39f1ecf416b8	5451
533	f76a704c3e5d75acb7052e3137852e5cd18fd2c979ebd4a8089ea1311e7a275d	5452
534	53a663547a98a43147836bace428e04438616033d03e7e620ec8f11f0728ffd9	5461
535	a6dfd90fdb86e1274a08ccd42c69f3bd2de6cf00443fba4ebb9ab5df4c7afc32	5488
536	9378337c36a1c6b457022e49dcb8e5fa4308d2db0899135e434c660867c42e83	5493
537	5a58b4593030bf56ea2ce01806507a691cf3b52275110208e713c373de5c3e1e	5498
538	5796bdd31770cef9915cf98f5678e3ef3255826d3087e5ec090e440f12bef034	5500
539	64bf17b15acc98df8ea5f807a07bc2ebc0146ef9932d46ae298bdbe1dc1d8a22	5501
540	d59f72f998d22a7cb8ad117bf5ec5a4a058c159eb2544300be208152d5917e99	5503
541	0390106205d24d2e3f0fc86f9fd30b7e65a47f4f12d802c70e24cd8172755220	5510
542	95d92e9818ddc46f929ce9c1f5786a071f48b8728dfc36bae1285b95619eb278	5522
543	9ad5706b00adc2886ef163e481a9be1978085924c535818231784b04dbc38ac7	5577
544	18741aa6e68337a4f4ccfef73421f044b3561440023a80c49f31978b73f24e21	5584
545	a1d854b016eeb64d4ec4650a36d206250d5426b8e9044e4ab367e2087fe209f9	5592
546	2f1ee8ec9da01735452079b41dc157aba5774e758d1b0106c4db780cd1e149e2	5604
547	2a1c1caf5d653404bb58dc0a82fbc1f224d860df4a40e467d354de54bcf25739	5619
548	9085d38ef0d03045c372b924089acdf592267d4cbd828af7946ab733cd098b34	5620
549	0a8d7a0d96f0f6c76d7254672ed8737a31fc57f8e68c482339cbf828de9fdb54	5626
550	a0f280c805d33efcf2c2dab058a55df0f2bd503525af428aad3450919d2d66bb	5628
551	5be84d2fccf294810c77f65501cda9d044dc19380e5f3875bfe52c03fbb363ab	5632
552	292f3de21b1faa69fea1e01045eccc144c9616de7b502478152321ac3be4fbdb	5640
553	a95b738cb8f10235b4a6df8db180d342bc5271d2340ad9231924e61d80f16877	5642
554	5e39c22523d6b901926bc06fc7d324a2c6eacbb52fb24f8547f558f3ec83c942	5651
555	528bb8a22053e956aaa89e9b1107403394ddb1e3dede2d35430d01744741be98	5652
556	e74f6482768983c39a78a9f0fddfe9b95096e958c41f722522395e1baceafa9c	5655
557	4a38279a16a6ab02ca7700327efb0879893ecf77766ee7d396d21c0af24da2bd	5666
558	5552b73372f95955904429d72802e7d3a2b286fcde48537a219a9f9f36cc6e0f	5667
559	cfa6d421b76652f23260b47e0c76130db8a86d4476321ce5983d552108791d60	5682
560	cd15e799fc9bcf4f79aea11f7d15b8485002a03016fe66354ace01c24f2fc250	5683
561	b265bbe90e2abb8ddf162ba2eaa0afc054b0b2e5309b96388237136d22feb68a	5696
562	b9306e04ffd4fd69b2b7cc6932f663ba81e5ddcfcee4070dd2797304c518dbce	5702
563	f86a69cacbb2578f76bf97236f0f1b605898e5331bfd44a8a69e97ba8cedd249	5736
564	034c46804454ff34a666aa10b23748552457f258ab0401576033f10fbbcfb693	5744
565	13a95aaf3c4d1daf97e9d226f9966863a876b964c5a162e7459647d96c81ef18	5745
566	dba7db5e048418dbc8b10c41faa666eb8ac62b232350daaf05d560220c2674ee	5762
567	e0a1797d7a1b0c6fe5253c53adaa95833b6170f9ab0e567c6572c862b6efa96c	5791
568	ffc6334e3fb33f2e706a4b94f52b6e097ee77455515c35a5716d75200089ed5d	5797
569	bfca0dff5643be517d92b055f04204890498024c2e1c0055aa8c643da71bc4a3	5814
570	7bd134046f469cafcfab0f92a599e3055edc8b9269c57eff3b21c9b4d453aa93	5819
571	c0ae058d128737214a036ac685fbc0f24ed71799dada91dce345707f658d42b5	5825
572	4c54136b74af3bc2574e31a8cd0f5ea2e1a6caa04a5d0f25d8615d9ced2bce7a	5829
573	d7df513b57d9727e9c04b1d721fcb12894e091f36e595232aec15e2cd8762c61	5833
574	f826dece88485688348b8604c520344166848b76ef349faec4df4f95f4ca0feb	5840
575	51e13053537cfb30c32bec58e59b1d49684b47c2b8e01c197edb2d43b18f3922	5851
576	ed533782c8a565a8cee84a94f93affe44aea532edad7ce79327bcf81cd0a7950	5863
577	b39d57efca86789417ecf8e7ccea931db9fe84a4b924a28c3bfed789296e7e0a	5876
578	f386259776d76431f5a4a12ac2da1b1932eb1e91f2e769cccd6d0595792e98aa	5896
579	378545428bba6be82fd71d2bbd14c9abb5a0ad05889aa1bf6270dbb540acc912	5906
580	babd34800c5590d2c58a8efe248963e0538d8bc24def57228ccae75f36918570	5929
581	f8fbfff9e7246466262492a79b785ba297b207d7bee9d9c28f82acdc3e4bdd17	5938
582	e532c373c6336662d926f933222e3d5a32ac55a481d1d015632c534f0f299f38	5947
583	e2089ca7b3329c388906d07418975218a4c6fb07b9b1aae76ef8b8a595a9db4a	5948
584	2f6de9a2d84bf01791fafecdf1f56580873868c592e4e824033e4acb39a8330c	5955
585	8e017b84f3ce2f88fb8c4eda4b157fbec25b4aa54b0458d2b61a82794e169800	5960
586	b4809015e57a87cf5c4928a5f50c5425ad47cfab190b794db1592050253a77e0	5970
587	2dde5a677c6d89910597e2c8b483f3daf650e5468d05b297695098336392e43a	5973
588	7d872a6af7684e37fc281bb4bcd88634a9f389466035aa4001bbcfa8dd474c92	5989
589	bf2d0dc9562f8c921fee880f0a1d8bd496ddd878865867d6ac46ee37a0c479c6	6001
590	c67908d12f18088517c65f95aa9c3cab2e7f494e0b5aa4bb43fae5da987fe1f9	6002
591	62bde26f1345ad2ab477b583572bd537e3bd2f629405d7ec65ff03d813ec5686	6007
592	ef24727fde8a58e4d38e43dba146ae83442b3edad10899280466a508cba0025c	6010
593	4a70ed35723c28c3644e4d32a1404349033e8286b048f76721f8a92629478a80	6014
594	5d255faaf2338a34f049395042581824964587446158e8460a8fb44372f7d99c	6015
595	4fa76cc0f70a285bc1cc4501b7c59328e9f0c5035c23c1b6234782d4f43ecaa9	6031
596	e56852741a1f652bdb5ec22deb19444fa8b3377ae8ebc69d173dc221d0057a1b	6046
597	0efc47b7ccbcedb8e8561f6261eefd78a758b03dcf260155808349f66ff9c37d	6056
598	af649535d0952133c42bb7b0487df0281f55d1e18a0353304a23c828c5113eac	6064
599	9435588b18c7dea7bb1c378bd17136c38d04858361b509e08a7cc550fcfe6a39	6069
600	a2536f7a36ed5ce153849666f4e077af6a7886284c30291c2816963ebc9b13b0	6071
601	91e5549de265fa9202cdc214ac8454eec05e276bca9a554a5170f2cdb92b49d3	6073
602	480fd91667cd2e6233461c59ff62ee7a5cb1f42d4caa9df9e65374774f59a66f	6085
603	64f02e2b8e1251c4694b0ab6d36960a1f689e76c39924a7213bde9d858fa4524	6092
604	89fdf5332b76e7674ca070d1093ddbc6ef0715f77dd85c58d5fae44d7d773698	6100
605	6b70be161acdc6b12fee533a158417909c125b42767f10a8c91f4ab182f2c724	6104
606	cbc0c2294af052f5c865b9ebc9d54aa1ba15cb7295c74c7b98ef0ebdd1e0ba14	6120
607	9aa11e77ec3c6d91996ec54bb1bd3073bace0f9666c22fa8dd405f227164c670	6125
608	aefd0de2dfd36025d83a205e877c58b158f8f23618c04bd24fc736e558763e3a	6139
609	6e2801dfef1574139393906b4603084a4482c16995e2c203f8e9db716178a03a	6156
610	8035a80a55e252ba416722fa499467713d91fcb932775fba0f25decee4d61124	6195
611	6ce23ac9fd7e65547c1b91e2b3159dff399b02b7fb565841bb969174e31171ac	6199
612	a97bc76ac96ea9b10e82d112abf7a550ef641166e95060d975837734f15d84c5	6208
613	846c0ae34081101d9a3c29e174ee3cb96484db61d48401138486b3c9a61a0e3e	6209
614	915df3c00b1705cc92cda189b7ba2b7daf21aea6d8c9b17d8daa690e4b306bac	6212
615	1cc372a7245038082100b9e230f911bc6252347073a7ea5eb53fe05bad39bb04	6227
616	11006cfd3511d1bc351ea50328012bc810e6802f7c4c09f53bf4ee53f9fc89f0	6236
617	f20eda9b868eaef13a254a86844d1ca65f5b581a266b07fa6c5eafceec1ba03e	6252
618	edf71c671d16cf35a675fbb4e22700f5073eb8310ad0443eb0fc8e9de45799fc	6253
619	f6723d336b83db614ec21e338b6bc1a609165a24d0e726e49b2ec25148bdec7c	6260
620	93de49f5cb0373418b52bac56b1712a37d5851d1e9888c7e069a0b9d0e5e79c2	6268
621	6ee6df747d110296a58db3880335614ad33d2ca757f731bef4c1d3b29eb8cfef	6273
622	c26b6bb3af94c45d1927b5d667cfad4c58faa0a6031cf8d8a64b4f925606e514	6277
623	307dd3477aa3209448adb3b461000ac29f33fb211b42fe116a3640d823dbc6d3	6292
624	029fef4ac83631db4634a64d3b99eca50f93b11736b8a663693bf4fbd94c9344	6312
625	b9756d426e22be3fd2ea1ef435c9ec248f5e59a7f927f60392e179fb3e5464e7	6331
626	ec451e0238f42ffcdec9d8083fa3e48947e92a5f0cfc7790aef61c375a68e44f	6344
627	e63a92297e4310cc29251a5629e739286850de0d9922153696662db6f8ad44a1	6357
628	397e915257a036654850041a379df11f2178948aa83c7d007893ae2f395aa8cf	6367
629	b2ae0aa6608e0ac73a2b99f7f8b8cfc8b90dd5743ab996be881ee4969b0d19f4	6388
630	4dd66ab7296d102ef91b110b18fb93c2e7301764c19dc68a7b20ab697f4ba6b7	6407
631	d8e78f4de4f5ab39f7acf1ac60fb6a60a36219e2e316caaf724f97a8721d040c	6413
632	2f584593dad79543f0a79702254965882c8e791cec0bf94bfc6a469198696a90	6415
633	1cd5109f8bead85238f522c191bf02b461b5e96be4dc130ba325afd4a838d96a	6425
634	8656c43af73bfe628e7502cbc611ef0566d0b1fe728f40e3ffb53f7d4c193723	6430
635	a3bdad9ea3deb62b5b0aa3c98b12f06fa92e016987a52e8a1234e2bb17c589b1	6436
636	a80351dbd81d6f0ad107a24b62b74fbac0129d5235185d41cdedcefc2aedc729	6441
637	adaac3772c2abe26fdb89d59c6a2120b64c8feba97f9fe6f036aef2d9ba4fc26	6450
638	35e3ee3a450eb88f2090da469d4ee4af98b197efeeab2b7810269b9c90781f67	6459
639	45447494742f5fde94da0569d09f6372420274a31985da40d48fbb5a16708758	6465
640	88e103fe1fcfb15ba517c6db4c8c37ab2ee43cc6aabd3e1a8eff47f79eaecc7d	6479
641	1dd2afdbd73b498a5564acd604b759985c2eebe49dbe46ad227dbeeb7be069ff	6480
642	eb055b4bb9ab5e3dfa328012dbb70f0901c06374eec69dea30b0696c5449d401	6481
643	612c7062fb0dcf83bfa489144a72a6d79a02ba0e75d8a50bc899ee87292dcbb7	6496
644	8a6da539aa6d2c8fe335d5ef0cf9e3ec49086f1f765a9ed191aefc443bece098	6503
645	5b94fcbe4e4b064043b471f73dd95ba7ab2d92fc6b8c73f4aec09613a5128761	6506
646	4179e2a283402bb0326a241b2fd215f98d83c64e9e1040bf12036bdb5ac2c1e2	6508
647	3cfa5ea1d08268d29be985a5511d6d7c5ea7c3f86884a1129f813ffb43c33bba	6547
648	0f8758031cf9a17e546835ab78e9876b5f72142ac5e39abefbb19196557725cf	6560
649	40226f7269c90a2c00853b0399d67dc00bf3c6071b958e6efc588c9ceedd9716	6566
650	11a508c0c2ecb57ea6bbf470527cca9eb0bc6f81d62af3eacac060d23474e6ec	6568
651	4d3253c3cdb54cde0e63723637cd71093aff2362d140afcdde1c03d6cea77230	6578
652	c63d6ac92f252b533ce756b868976aaf97fd9c2deaaca15772a8c0479b0c2b48	6579
653	94df4b8b936a085175654bb43aa03079303f84326d66acb4d1eeab367f656f50	6587
654	368b9bb508fcb199460f4c824c87d8180243eaf65d3a7d3961fd9c3b20119d8a	6588
655	22f9a793f60abe3adf88c621b8ecc2a5a66e06976407490c41f5c0ac2b700014	6608
656	9d2c35fd79ef00c118b78e0f1e3a7552e7a09b6e7cecb4c91cc6a6839d240d06	6618
657	039294e0baea66d6c248dd4744395f07be3829e7ace60043bcd1e0c25753f308	6621
658	b2c7cf11a6abc1e3a226dc6cf14a0b60f1488cf441f4d7a903b9c1fc76cb9d7a	6629
659	ae14c41ea5f8b6fff431c0f3e47d34ea368d05556d108793f676f748752ea148	6650
660	21225e18023528874dd7f52a98e42ab5dcd8b7a0f8e658414541c3c62d5976a1	6655
661	03a7b42479467c6d5837be34f6ba176d73c3b0944068132427e3582b70ab2b8a	6672
662	94e0c65f0b98dcb6652a081ba9e21280efa5abab5cb2ce9c956e493e01134b66	6678
663	3f75549644460638f08d3914a9c34b091c5ea897229cd5f3a8c6aa364bc80635	6690
664	b9e554ef59d6340805a19f45dd1cbc040077eab5779eea40fe9d37cb37650072	6691
665	55710b8b045cfaaaa7ff651a7d37d16c2b96f646106426107a292b96a3320610	6697
666	47e389ae03378b180636f81ac27942f2eb6fbff20225c8fde22804b5d8162887	6701
667	4bdb6ebf9ec4916804993f8ac1897a04a28ee03856fc5018860a5231b20c1a76	6710
668	2587d7c417ed3e5e4bf7edc5cc9e4595a111334afe94976e4b6fa65061bb9dac	6714
669	169476f2a6821f677adad47482aef68f4baf16a83b32a671df811160c5bc5e33	6717
670	8681fb3bfd641fd520fbe4736e5c919577918ee1077e4b473605eeca72f4f49e	6718
671	f36a5a3a72db6fbe9706441c33da64034ccd4526211806f13285ee8b0da53aae	6719
672	4c1d31b97a1f8ba629d99a32c0a99dbd39bbce7cef23d067253a3213fcab6e6e	6728
673	206a3df4371fe924466e3d0865a7d526a6abd7ebcdfd4f80575d088b5869901c	6739
674	71218927d4f0d55e4e3b450c78752b9ab1fa8b6ac003a8ecfc4114bfc9d4ed13	6740
675	4ae76ee0cd71e0f4fc8e9d4541f4368cd9504f6661513851edba80625411b2b0	6753
676	52e22ca828b2d7438cd0c97594ba7769dbacd926b9be68f9b6f6538b795e6959	6766
677	2f4481d3aadd0e002a08a298ce3710f6e5a1ecb538f6ebb50c9e3f73ddf3c72a	6776
678	6d8672bdf9e8cfa1bcf11789d31adcd9d2dafd4e8183bd8b89e686142da90cf1	6781
679	0cd2be12774cfb4fff116ad04dadd107358f91b71ad0e5f5658371423af232f1	6787
680	5c6463fa3a70f34b031d2cc7a25fe52ac710bb983087cbbd949e874f683b879f	6792
681	97cd88247e383e117b2fecfe05716eefb4ffb2e603519fb0e1bb90d8c072a09b	6795
682	d3fa5f350a57c5b3fbaf73c507ccaf46d2994d17df0df3be26b49f732827598c	6796
683	713ea415a45f713eef96c023e1addfca03b493ecb875ba69f439be12ea395d76	6797
684	504f9255aba29140334e8ed93c97f4bc09a425a98619a869303f3b58e9fe7b1a	6802
685	acb33fba6a65e4f5ac1004bb470b3ee5568de8b0f1e7a6f1b4cc126e605a3cf1	6807
686	48e1411616ecee367de92db81b7cb2684fb293a839f8f4ae3e231e091847e24c	6822
687	4533a6fcbc40b08e4efd20fcc39728e45f749090c78ebdebb88e3a75c5f68ed6	6837
688	efe710e28ef92920ba56c805f670e1d00290c931111edc544cbe673126306034	6850
689	6cba34ad089e79d9bd16a5f8d23006aff0fcd21c17ef7d27d9ef09b1893f2a4f	6858
690	0d611505f84cd0fe40e43812d0ec1e4cd3d4d6452aa759f58efce9117e5d011f	6865
691	ec076e064aff7d99f7e43b08d485bf98464bd3b0a7975f430bdcfb02a2283422	6873
692	7757da182f4e6412d82aea5e8e4753985ba61a28bec93d038f16740a9752bbce	6882
693	64e90583d9b457276e5e11deb933bacc643227a17fa662207591727486d8d655	6889
694	b15dd3e7473b5b80089e689a22232317c033a2d9ee46e677d717327b725e6bda	6894
695	6dd273e31638ddcde952960a376f2b0fec11712c2d819002fd678da3932cd616	6906
696	c124b52a017d38a4b892d6a068cc553f9a04ec4c480a582c098dfe548635783c	6912
697	d9589556c7294f52ad7315772c9efad2cdff65b247bdf01c3f6ea176339cbff7	6924
698	c2ccf4590ceb7e82ac877383cdefc53491cd91d74054df9cf20bd048c688d836	6938
699	54b09b3b9607a3e2d191c7f51e9e9d8aa3e82764741f79681e62311acb5bcee7	6963
700	25436ad378094c608df8abbea4a08187afa43330972dc3d32d0b8a3a8a290576	6981
701	bd81af800e6bb0b1b97fcb236f1361bb8eb74b38e47d6889cec5e05518714da4	7006
702	f0bd38994865db609500d04a8cfbd169b03494b51040b2b7565ef8e173b4c925	7009
703	1e53a2070a1073588f76c585f57d8327dab4d8808e885c514e1a2046eac03227	7019
704	417d3b1929c8be3f07323908d797a9f48faa3cdd585aa07a0d56fa16ee609a15	7029
705	b03afd7ea53538867dda84ed9302e497de00955b20e14dd4aca850a718a1b9ce	7040
706	5e185873f4caf8f6a2c2d097c283c61cbb2a17243c4430a1d560bf937ee9ac84	7044
707	082b436ecb5e3c74ff9b6a3bde59bc25365c92def733da47342f95b874369409	7062
708	e34beacebbcc2828453c1f4b0902b8e71656e207af2e6acacec5295ef6c83629	7064
709	0ac5f57a78e3c27cfb069aab92563c58f27cf1cb9379175dd03c2c4003c79fa0	7065
710	e3feb56cfa350d7ff3664304a68ae4f225803c57e5e44c92a6693b9fe635cb65	7071
711	910cc604431a753a754601691e87c2c6929c1bf62e01b05cbedbfcc35d31e2cf	7074
712	63fe32273b6e2746a3a5b07e4585935f88cb699146d01676b24356668017401d	7102
713	a4522cba4cd5641f07494e023717eafb92623d3dc4bd61b11f1cfbca62f98472	7104
714	e5e150500ee5a0a9533832ab71f17d0fd5f5c0167c87348ef9bc4ba74dd3030c	7110
715	70aef1977f70a5d17a171a789f00e68ce7c5ba9d096dfbc098ef30d2183ebff6	7112
716	8e898c9d63ad0387f7f950a7cfccef815d9b630d0d2b3094ac7294bfa153c854	7114
717	bb25259286ff0f50248dd9720aa9a2db47f781b8d31a827daedccd4a1f9f195e	7115
718	f89755752277cd8d5c991899b3bdae936b4f50cf26c34f39e2073abd58806140	7136
719	8f1d6d2274849b82e0dab0603ef23b8cbdc09e5e33e87e0ec46ef7e544a428b5	7145
720	56610db08a11d455ccd809b04f49a3aafa30f147a0bde216ebf43a3abe0c6f5a	7151
721	02cf854abca2dd0ca04127754be408beda700aace163349759773878517d9f17	7153
722	d24acdb4e2ba597e0e7e5771b4f5e586f112d38ec18ace372f7d18b17e9e7b75	7200
723	9e8079bbb42ac7186c4dc9a7726b02a8309fe83c32a2e049cfa76c2cfd105581	7213
724	9cf4429752f82866ef3c67e1e19912696873ded0b8bb043c447a3f5cc2611f21	7218
725	18aaef5a9adc532f9db339ea29afda6efb96cb9e9b199f63f3581902bc88d23a	7230
726	f25c76f000c97ac714bb81ba488d32e893ce9a9fa601c14672b3d7363ef863cc	7233
727	9d9b41b5900100c01d28160619d48e139f0f892655c12080aa42ae780a6368d4	7241
728	e12d6346caa84f4e9658da88e271177de7e60ece93d792e192ce49a2fbde13ca	7244
729	6a2dac6a74783133dec4d938b5fee3dff88856355b11febff8190ac70d0077b9	7245
730	f924d383394eef1bcbb1c54d68f3955e80f1dae5b84b9857e7c1f98a75d707c3	7252
731	a4b38984ef4ab3235dd7dc0f4d876ee87605165f30c31ff89dab269396868efe	7259
732	914cd467f026a88ffea6cd23588ce97bf2a554a2750861f0a01bde0c31936c9e	7262
733	a2f7d1a2fd5cf31c76caaf4d1a8b075cef09e43fba99fd6e972560035f6a16f2	7275
734	5194733a1616a7a4582a6d14fa448807a8473e5ccec2d802f8a7e9098b0b582b	7279
735	46437365081acb4bbf78df780276b7fc01b311cc00e388b523215e13c9253890	7286
736	53d06b7b6186ae4dc55dcf8cb67cb68ed2f110590bc83cecb7863fa61d4ffe6e	7297
737	9cc5ca024970b137679407c1d2a01d079d9cd7e99e7a7b4bbf53aa2349265548	7302
738	e0f8073cd6f0daa086087603f70f9089b5c788b3f56773e97c67931a98930d42	7336
739	3549c18d30e2b27a3ccacd73481887e311e2f563d2264e62824898492510d775	7337
740	e5459899392b636e1b5932c57c378677ae7f2c716db019c09c6079e1fcab5815	7341
741	b8a446688b21418f922cdd8c2d801b3dc325e2d1bcac66dfc0f06e9f0696c04e	7352
742	c35150a4ba7ac85581adb422ce2260cf60204adad26a17c2e171ba6964ddbf48	7355
743	4df1b579edf72560563539b35f32f6976da949f391564c00b8234c6b510a1ea7	7364
744	709b5de48cfef70e273b5ecb0e4accb82242a1ae6f72ee23cd700202509bb7ca	7369
745	97318383278f67c8208e84955a94db119d291f334455f2f5c9bc4e7c4dc7c128	7394
746	9270897d3b8c6b52413961380de678e39ea5113ccd13c894c7789877b25d3e10	7397
747	83106c219c86e2fcb63060aa3b27b991cdeec79aff71428e9391915c8cfda3ab	7404
748	b7e3142d2a238291377f5368b680dd9a17ee811c8a12c64212b21d8214aa8a3e	7408
749	5830a6ea50108bb77d4962e052f9a06620610850ff212f422ce0fb610d8aa99e	7409
750	415d94ceaf66b949be106ae6c81f625283b7f25eb0c921b77c78d4af2eaafe68	7413
751	9748e68bc2fd6c3cfdae8604395959b15ec6f819a42a8c4c9f07ce9366226aa1	7441
752	22f8a1f329c8cf5162ba0f39a0f75a493a1f662c01758788b3df6f79fb7c9b21	7472
753	0dbade109939ccdacf6884073ba3b30130eb421d518046bd01e0a898ba3925b1	7485
754	b536ebdfa504a12f3ca8ca0b2e6b09bbeb4237f485386a130e332743fc4981c0	7498
755	eee2a0b1dab9666f0020911733d4a33e0af77d7d1a78f45215ce9532a41aa393	7508
756	eec63743f86f6f9591965e1df088ad82e44e4c09dd94ac5d71b7f0396c5caaa0	7511
757	511feb9fb217a494b874a08cf5d2dbfe70bc16880b7eae3c7e7b64bed5339e0d	7522
758	2db23fb458bf3997a0d9fc306baaffb7693460c40d8eaf8e5912170e57563e8e	7527
759	150ed2d882e02ae5b3c4becd622af8a838b3a2b6efd93e2da28b2302432cde9f	7534
760	03a6326169265d723949dafcf843646f90ea4097c8975555c7fdbc63b6ce1aaf	7559
761	758fd634884da395032da2800083566300c1b0d720af84aa04cecc2d2c10778b	7581
762	6c62e4fd4d3c8419d71ed6ba3bcd4b3a185658e88c56ce5bf2633a38777d1dc1	7593
763	e963308da5c54b2ca5b0a6026ea1426e47cde425f0de451aab35320ae83194ef	7604
764	cf239c13573c1e983e9ac7e9229983ea91775704f09bdeb727c6336a4629f0f4	7606
765	9715b5bbf6cf85fe38be3afcb3d8edc1b0ad9f009f4059383a2172d1df7167ba	7610
766	066023e3891a7bdfd0d7e7e5e9aa7c8cca7829cab35fab821ff4dbe19fed2006	7623
767	9be480609615dcbade870bb506fdf31997d76fc495b07ac60c9bd81ea73d4888	7625
768	fda4c4bb3cdc4799ea4da8892c2c79eba7715522a93331be9272bb4ddc6130e3	7645
769	72eee9f70ad3af9141e950ec5f3a3b91e12255693c7f5946fd6e0d0a2feb0ffc	7652
770	8beb5857cc93d3f20f4b5090785e009b50b5134ed4a943bdc527c385c0dd6bec	7654
771	169dcf787e8e1306d5f3c7b4d0956722bb1db3499673eaa33d0a20c0bbc66935	7668
772	e09173d50ee22db6b7ea2e1f7f14de3c28ead33d6c478b04e015cafd227384a5	7699
773	6d9ee9aee24bbfbf347e381ec284c820f5af0f3d60b80042ce8291895bc9fed9	7703
774	54986bd0b481645f957d41ef6eedbe975d58d3a5f7df35ad24e6723d14328891	7715
775	9bdbde52c2dd6f1cfeede9bf9cf54a102a0b254b885ce8c69d7aac764d6131b1	7719
776	2e9c2f9cf59c2ff732f9ed769ff5c0eb9ec6334f8b7e4a133b4c5cdd9be04dc4	7722
777	5fff6f1652ce628ef3d08d711514542c939608b42b162bb9d8df31009f49b234	7732
778	741014298ea4eaab0c008554604f219d2403aaae46b8e47a65372248589ab237	7739
779	72dcdd16d55a6ab519e71d04d4d811537073b5d7b12540063027e61157708c0d	7750
780	3ce060c993d3f79fbef71cb3f0d5c4300aaacaf3d7271449966582485ad8ef15	7763
781	ec22b8a4ed54a08f1724eb196eee33cf38f586bbcdce1fce17535619fc391612	7772
782	d2fb8acc5605ef05d436ec70dad6b7d5464a9adae1628d039c464ee3f027b155	7793
783	4bc8280be9d486d397aba9854ca4a7ccb522775abc5cdde3824c5122938fb0d5	7805
784	97144b6acbf61fa619d8174881ac986af28af48dccbff06d9d2cba0bb408d98c	7807
785	f9a0e52c4293abb81860b47829dc2c5cea1614aca2593235f1b611d7f024fd0e	7819
786	ba884137b24498fcd03323df2749aa34f58c9cddbfc6ea305a60940f7a85bf95	7820
787	fa8808e07fbb3ded7af0a702c6dd01c93ad8e4b068f44aea8cff6302686a97fb	7826
788	ea56bb1b063df7284d8a4d099b73078cfac0323ba0972a5f429fdffad23c2edf	7828
789	e88528149490d8557f6da5868ef4bbc496143e4ea25052fd3f18e094a90b5a39	7834
790	de9b1934d39f34bb9e63acc12edae07f6ff5052776b2e215a65d87c1b8261978	7841
791	1da5bd2876e69b22b029848eb15949e6b93fb906cb1ceb290762107f476e4589	7849
792	bd2c7e866666d2aac5adf70c5f8e08cb40cc5115626af3442ce0b4d80ac0bf50	7872
793	9d13282717cb2802256950b70f78ed8487012c863b5d6332d97a8752607bde87	7883
794	76d3fd9a1720d70c7177c765ec26404235a770d9aa1306e0b36a72b8e6a68ae9	7902
795	67f4932f11f3f167c5a97cca9a4c2c1a3aee0173db061bf15ca138d8a098693f	7905
796	30b0783f899965037220617b530f9bd5d96c025f255fac4744c31bfa6beb4b95	7909
797	3d83508ce3aadc235adefc9a42f6c00e941ae26d6bd762e651bd181a6256ba70	7944
798	399a5a3e7b9fd4551980f849349e281562d1f9e2fd9c9bfd47a771daf127a1c6	7958
799	765d7e97b85e60925343ec6b14b07cc1fcf6484f65c3c5c77164e296f26d3d5d	7968
800	56becc040938f34f2c290c263d8337cc75df34c796aca5af89077adc6e7dd285	7975
801	fcadaa85d294f6dc012186553460a0ae551d85eeb2a949ddf166d9216da21138	7977
802	324ff617a2bf6e23b84a6c3d2d5b884462ea278865b52b8b2a67270815e7f7f2	7980
803	22408595c1c7f0394c92e88388989c358a4aa0fc7206d23189eec31d03adfe39	7995
804	8fca73df86574b57cfd658dee712ee6e7a5eae5b9f9354feb8ccb65d48df5f4a	8003
805	8a1ec169f84ef8dca8e838ae1576289ce0af5291b6a48a2025a64886c1778ec9	8014
806	fecb30f4e5c4d6966c741f5169095020463f5735199a3b2f6cfa61cdd887751b	8015
807	7fb2505f89b269d4a44030e96590bf48681e784ef08feef133639bd62f0f38c9	8016
808	f1ffe807c48e1b65327b18cf2fe397f4283e8f3e7bd6265182b09f0e8a0a66d9	8017
809	e791741daf1c892df372229faf29e069c14839f1dc0b6e75d0f79bc5a89c7c27	8020
810	18c28a61769fe3ae7598122bef8562f79e92fef45081a7c32ee9d5f60b93cedd	8022
811	70014780dcd44340c837d24c096bd7da32aae0023b943ac52b4971325ba514a8	8023
812	9a189441dc1122461aba3ab96786fd0b0eee20aae259bb795b247522506037e4	8030
813	f1fcc67d29d6f2a0781eb61f243dc8e2be3c2a8e612bb3c6d763b519016a4b0a	8036
814	d9f4fa013076226e17b185603702cc36051042ee1b15f59b9908128a30038026	8038
815	4d50b94ce5b9fde30f386a26a894bd16977375275b2f447d546284705c395499	8044
816	0bc6ca6b966a6dd12239356735b1a840091ba8d2ea2cc12268f17ef2d4843bcb	8061
817	b4f680e33113da4b3f8e44b3aaa23d27083cc91cc1a2ba1516123247d835d4af	8070
818	5b5576c77f2a737bb7920d26bc6f7078ff974ff1ff50fdabea1f815c52ca11c5	8076
819	f184a8e54a3ce94bd6cb1451a39270780998b253a54bbe0045a63ded8651c3cb	8089
820	02f70f200286898602b1d087ef00a9bd1d9cfd5a870b2281e3797648e52d852e	8104
821	e9b8dc1505f497a4825707290a1c83ef9f024311f0137152b8cf2af622b80362	8107
822	de2606452ce0dcc3985fef41f823ef2f3be1b5f2d2616c661ff1bbc54c35ae2c	8113
823	ad03ceafffc79a0d4f2206a64defaddfc5e4b049fac4299707264861382b594b	8135
824	86672af7012c67cab5ef4de30faa7547ce786164558684572b8774412207b1c8	8141
825	629135f64d1ae29de5e64d96a5e6109ce312e6310fbbe10d0e4b5396fc18e2e9	8158
826	917e7512f9c0d9740dab6314546658a8f83c235e4809e4f19e26b3fa019bf291	8164
827	c018d567da55b57a1cf6abbb1ae59a7c564084a8c69d2656ce6fb39b0977ff9a	8210
828	0a497dc293626b4a07dd9e05e66138b19f302e7c2b0bed1e9ad2baf9ce4d8706	8234
829	1d25f442e654a536c3597e9f486ee7fe1b8150661399c874a79cda4d1a4202de	8240
830	b711fb5a4d557887a8dcd3fec860a2c4911d90819bba6c6bced1edc0173218d0	8311
831	2f30e7c5b61788c7d2417ca353a04101691916d86cea1169d0ca4e774d515bf1	8313
832	33b48d1f5a9e08bfb7d9e464280c0cb4063d79a9ad2c2024bc820ff3905bb2c3	8314
833	33666ab95c2ec6611898d272e7b40d690d1f24560caf8926a67825801a628981	8320
834	57f2036844f65d063be12abdd75e2fbf56ac70ab96451d936ecc2ff6a9540f93	8328
835	c56fb9564161efb647a60c585610f81526ea56ab81eec2a3f72aec850cdb2909	8333
836	e5f091b8dc51a780388411b05775d51b7097c9b10272736b2e307d06a3d7a4be	8338
837	638346a602fb4cc581a6be135c8f20f23c0eb3046081782f23d4de8bee818a8f	8360
838	e4c3c0f9e2d06b94bfc48579fa0e3b5ca3a8ed257fed3be7af82a56ce7007cab	8371
839	1d7a1842bc83f529a1de40e3a7a76e5a1625bbc43d4c61683c4807b4d5861855	8376
840	6e5e5582888e916cb3a657e1f7b84eaea99455acec08f512b712d454baad25e4	8380
841	a072f1cec4846d7a4befb0507a5a58179c0bd60dad8d13229959aa2dc00ac932	8391
842	c6e4e3bbd37c21ecf5437400be245190c3f0c4c224ad902b965c3f923241bc48	8422
843	21b0bb91815dcd41adc5a2101d8c2bcf397ac674d32c6c6348e785fbaee9d727	8423
844	cbd490fba5a3c68929e7d6b2dbf6451f424a8af6cc25e5a3a960b0a9cab0fc72	8426
845	eef98f4cabfa797606c531598664ef84c6bab0b880369454c3575ef66cffacbe	8451
846	d7ddaccbd5a25a2f2dfe60e11d5552beeaca1e41e30c18891daa39b16b8437ef	8457
847	0479d47cd81f4e3134beee01b49376dab9852d7b3e0f569a710a98f784699256	8482
848	9fb611092b1d5d1d4b5ed9662af4e034d120d66b9099e699075e4b853a9e0a26	8496
849	dfae4f877a02e19b0ace0e114747ed63992deb450cd010f6f21fbd4b7a591402	8498
850	3b2a3bd378526e87accf234d1cc5fd9e8847b84725f242e6d25e89f47bc9ed41	8530
851	4f68bcb93b19961128850cbc01b9aebe4d199ba42741f3cbd36c062c82234185	8543
852	44ff7486feed8576afaf0a75bc93b0686f6f2b2119e56d2bd8882c305b1eb497	8569
853	6f7ed08987757e8c5908bd509f0dae97bd3ebe7c309c313071aa42fd368df8fe	8641
854	fc3068093c5bd2fb11f78a0868709cd1968b7ac2b472e2bbfd6837f58f449ca8	8654
855	a1ec6445a0969bf93205d5adafa33e060ac2d74395ee8810ce6b2774553346f0	8658
856	67de5abb377e34c39f9b791be7d1785f007b55020a5e895eed36d1d25a1f603b	8661
857	fe8005adb22e791c05a64ba74412444e28b07b613e62cca0cac70ff28c65cc14	8668
858	b36cd0df1c8f4b1495c775d518a484c489328f8ab82a6f083d83f3bbaf23615f	8670
859	dedaeb51d747f5a74d9bef9db61d8135c655921e91171d48953d1b2cead2fae0	8675
860	6895895536c4f208cb3eea5a2f48417c035a516d1d069214e14fa12f2eae723a	8677
861	8a724c6065e04e7bf1707b186774e9cb40465ea28a3ade9fc444bad23855f4d5	8693
862	4bc7e4d63e2be1e214de833cf547e8e7e95aa4f57c42927c109bfc28c2a4d007	8703
863	3e2974341055691b3e65fbfadbdd64ff2a6c1cd2a2c0fb4d9dd110538fba5ac2	8710
864	e2e8671730bd5bf28222cbffc4edd0cd19cd972f3c92ea6a6e91345d06118f4e	8711
865	e11a21e4910bfa5d12ff3862810f6b4c5198fc4a823743bcc0d543572ed84b59	8717
866	2f9befd083320816461aa89920bc4fd98c02049874871d8b604f05012efbf310	8718
867	d3d9b671ead38e6261d4050c58e045bd043a1dd3d44a80d63d66b95ed9f73de8	8719
868	5dddd15267fdaba1a30f6b009e3c1e0bb57cc3951c454a5b4e2187c3926e1008	8722
869	5c00f8494c3d20c2aaae52abd5ed3a98558d61606578fd89f8e428339f4e218c	8730
870	a8df8f990c2e5bad816406b2a4c44065ceb3a358c0e5255a7e0c8be2c76fe1a6	8735
871	c41e58c0f1d2013c1e80214cc99595bf25c42167f19e01966a0f00ffc83e5de1	8738
872	11b6cf5cbd47c885c5ae049f68f4002100013f51884677697c0576887c1b1eb4	8750
873	d3df917eb54c20100dbf60e770bcc5e0a504c23ed8ebb66568dc2bf05ace309e	8765
874	d8390a1927441e4906047dd25870db66c8c1cd9a06d7ead597ca7e421b99df18	8776
875	9f75bd117a4cdd3929762c82b35fdefe98bb4e49448c93ad5b01977079b64ee5	8786
876	c2f141e83ea1991907817d7a0c6867b15429fa9055df7c5d03e8119541e57f3b	8798
877	d5c69e255a07ee1432a7991338d40b1d053754f56a163691bda1a03846a92eb0	8812
878	12c2667c266fe74445392d2e937b6cf0d1716988cf57d16c8aa3a7a5e7ef573e	8813
879	29eb864467e65c4a1e0e3ad1cf66ad2581e889e27c07a4f193f3742b8412f1ce	8841
880	236050c4882f7a5187e474a5a0cb460629602f0475d2d560240f94ca3f3c68c1	8860
881	7b87df694d3b9c649bbda9247142ff9939ed5b555c0d710d04944f5d85bec4ba	8864
882	25dd2e59721df54e737afa4dd52fa8e84fbef306a64abb3965e1b54c4ff15707	8878
883	fe2e2e946e78a62cf5ca1eab040bc95ca99c2c2aec0fa44c410f29732d9af7cd	8895
884	2c8b080659eb38f57d405dc8638c02f92d05aab7648efa77f42e66c1d794ea91	8924
885	93f83a3f225f611dcea1a024c3d1f15825deb24e8f451c4ce1ec0e657b626614	8925
886	65b64d09cbf1237cd9ee5196aec2609ce241779a1109ba8e83b6fcdf587880f9	8941
887	039f4764ae48be0e9ed36e6444eed66bc33238b234bed29afefeee19e7562aa9	8951
888	be6a87a0b77d00cfc65b6d57b60642095905730c42d02dd6b0a2062e6f1d5bc5	8952
889	8703a014f5658eaf8deebe671c7668ed64a3d5ab7148920408af55df076fb598	8954
890	33102c3b3dad6aeb5b48123653cd1c2ceebaa8afc61ba6559fccd37e6f8fc5be	8960
891	ae32b7a571d2be2e640bc0a614ac6ccc09402cbdf2f290339ce2f9dccb6adaf9	8973
892	31e3e4d7f9fa278987b10c4be117824a697d0b881d5549a4e512866b77b1c5b9	8990
893	bcab01de76ea10f6c74e817cf525b820affc8d218ae84d8e8760f24c6e657a84	8998
894	00b090659916cdf9fcf8f087eb68f5002987091a84acfdf89caaf0f2bcaf7d63	9008
895	863b25f1e523a11ada56590bce507d4ede0b9513ad37121cb3a4c4ce623daa52	9023
896	271c6186c49a0523edc94f4d6acaf44694a542bf5248ecc2876054ab32ee8fdf	9037
897	6b8b18ee48cd1a7f5e0c3dc58a25f6099d87466abfcf55e279820632ebb073f0	9049
898	50f344aae6b1ca3f5db4f8177402ab16c5b2560dba9b1160de62d149ba642d25	9050
899	96f477a3bd37a805ffc2c5591693468bb17c92c4fdbf78d893c92ca2e285f844	9052
900	d934ec4292a3b2f0de45347a47e089aadee912eb0972816839a96cc11b103082	9059
901	105b37869b52a6c605984abee917728a3325c80148fa313e8f6fbcaa10efdbe4	9063
902	25fbbfb93f3f896fae96e645c9f29208efb5b82ac209e01b86a14235187197bc	9065
903	0748d8bdec52cbd3ebff3eaa6020a2c662031f547cafa2418ef8c73694d90412	9066
904	d44dae4cdbedcecf144537e8697278e33f0120ac2634b501d7fa9395da9ccbec	9073
905	9f9fe1ef30b4528cb673dc62d507848cf142da65ffded20409ddf363e05fd37d	9077
906	13868f9b6708c2aa92fecdd07017700bbfce267db82b6950c93cb7765d13b882	9083
907	ee31b5a7eaee259e0eb8fbd28052cebaec55242d7aa4e23d93711d6a4e3a8cc3	9085
908	b30d19296eb3b4b06e2a63805ce8fdadd119549756134e3b92ba359107d5a229	9091
909	43724777400c20f8987693b106ea3066c2d90d331d7758d77c2a31637d540067	9095
910	566797bd50e30b477bcf755b8e3de075aa26b6dd433a41d87d6cff131d52b060	9104
911	5912901e730b7961848271c5614350e59f0f947d4fc59d7bc1e003e553537897	9127
912	9ab8da182a6fff59412e61cd3c9143041080726ee2f30acf73bd3d6f42873d52	9132
913	540e9395f361a58fb94e41614513dbe3b1a55740a2368a167344a58a0f535bd6	9138
914	9dbc88f339e561fd3099426d8648b4d648270d355f623f3aa334ff29b7465e32	9147
915	36f53f3aaf2628db04ce28684dfeda3c64507e0741638dfc90faf2d1aaff56cf	9149
916	8e4809fa2938f1d6530b221a67b80c185e78860f8c65fe10b445337d17ff1fe3	9153
917	e1bc352bddea2a652d7cee8bfeabc7fbf3236fa53a3dd7ed12ff884eaf5272ed	9157
918	ec6949b6f882f13d8619c680893d02d6399395d147832553e2ff83a9c78e5309	9183
919	21a5637d534216ada04c4cfc4285477de640f2021f2318c9ea40852e61f97f41	9185
920	75f7a4207f8b8bf91b5c51385db0fd8fa9d85b40c49fed8d54fb476a81446845	9191
921	bc36f52f7443e60d52f764442536d0ab17179b706f26f024056058469e9e4814	9192
922	ddda42b5b1eb22b95fbeaba1c298991870872c71834fe041f99d445f72865ae8	9210
923	faf49520849c9c6fd71541c89e16977db5962564db3bb45ba189396c47d280c6	9219
924	80750c1fe762074dbed998ad01836931456018eaf9f0dee8017f8fa9cf2e1e93	9226
925	0f0026ff11e6a5b5b93cc7f4325deec49fdef179e28df1922c3c5dd36678df54	9228
926	25d4ae14f54dbd20f106ce3b7bc4633a5933422d52967ae9eec0b7df3c1e39e3	9232
927	ded724443c84ea68c9e56b2597b2a9f886dd43f173c2935cdbd0cc56cb046f42	9241
928	83f6f728d92ca4e33c7c8a0157eb0b39286350ba33a7c13d23515cae3ae8c1a4	9247
929	df5f1983ee1a1b79af0c3c874e3c2a9eeee57aa644ffb77208c887febee9d2a1	9250
930	decb0c80035ff41125af22f2b7906fb15bc96a4b5bd92ae4f9d20031b1c0a9ad	9263
931	b0546545cff7023a2b387ca8d262677af5dd8949e591c9dbcd3a1e129afe096f	9264
932	e91423d928b2fd81c0e36ae3f9c713e9802247cd093b4a63c15f78ee048cec87	9294
933	94c930ed0c0daf4a71d12a04803b0fa415f9dbb14b36bad9ac060b08eda59bb4	9297
934	79b41d5cec780e7eb4e77605997c316bcfa2eb36cdcd1c1712090b0eaa3a7a23	9300
935	7a8b7478f8e0da0294a487aea3f824b3c4cbda06feac87b7cd8c479e8bcf6f75	9303
936	5c0a927352457867a76142a68f8bf62ec45a155c2fd828f176fd59e1a9ff3829	9320
937	9b51b2d82116ec79a9101bb0fb0eb241269a56195c76231d41790e8baa5fd1b4	9321
938	571994c16bdb5cc762d2e9a4da094abc7609d9d3cf5525b3c1ddca3cefdf35bb	9334
939	c7dc84028699e4e7ba376fd3ab9794c5934c8faa35a1ad0b4e57172b2e7434a3	9338
940	5d4c7b1b70e0111b174f4bb83ff8fdfbb1fd171286b57f40216dbf1ba53fc5c4	9339
941	bfadabacb075a8defb2338a69c410072503a82cfe081638f0080cc0306402ec4	9340
942	e4aa9b62899bd370f7687c4f784c3e87386222b95a0c5d8edaf8e3c6edb48a53	9356
943	bd84d3fd3e04c1e2a63014c403a20807615043a7688a1299da994346b36b8da9	9359
944	9a98fa1039c34ed4251ab1f1a186cbb9e81643f3a78097e3f4c38dca2b1affe5	9384
945	c4cb3290db5edb2634c209dcfffe7bb4f3d39a25659e8dc023d04e823dbce978	9411
946	9b87b9b13f7f0b39580fb63924b1774c2ec9fe4b673f4e45921ff22cdd07fd41	9412
947	a650ce2f6a43d8c834ed1feb346c5ead1c490d512aeabef31ff1c06b5063bc48	9420
948	dc131cb5ce8f2064d7977a8845e2fb5ec34bb2b926bc1dce15ef9a11a710a0e5	9427
949	74d21304b12c424747050262596e9eba2080a8ed0d1294ad3338a7ca9ad54ab2	9438
950	616fe9a4f57080435cf2232b6f184a7dd959ba441d880f8b4fb59db5f06e2c9b	9454
951	ef96221c1792169911e6a5cf909fadcf66a86e7ce6ba0e42f29e60887b65e18f	9457
952	5ec658ed9ae8b7207bc94ab824b83922e4968ef5d8c6228c11d27f593a9dd707	9484
953	1e1bf982154e044d1e153ca43dd89df51660cf74f6074bff04bf1a814d609a58	9486
954	5d43cf9b64c4e6ae77684fe98095756b8c52e8ba5b1b4344ecdd9c67df81c487	9499
955	963dc18daf1d482f4959176975c943ef690b6e9330dc5e7a47a043a31efa2eb5	9500
956	b2e4efcf22006036a1905c057697ca07aae40d7dbb29da341233be7bae5e6843	9502
957	db80f9bb73421cf67eba04c4127e55d3b7b95bca8d155033fed5d70184ac4c67	9515
958	dc23d29b0b22b777cca003c5408c7c0887915c40fc335b7699fd0e3b3ed8291d	9528
959	86eb37a44f7d4f32af059693fd8dc9df94f733779d2177914e2502ab3c5bbde0	9535
960	b7931f350d3264587a4d725e73545710d687e93f469944fe6899d5cf270e4f4b	9549
961	2f599d89cc8f52995c479096334ed45e4ba6d7103f65e868d3deb08cf6834981	9560
962	e288147612908568aeabda6095020e23e4081c5f498459b89992062042370b7c	9589
963	e83aaa842d677eed025aff99641cd8642f1da2ceab04f3cd2249d27dd4fcda5f	9597
964	468cab21238adda2015ffa9db3ccf0247cd26097dd1f26c41d714cbeaaa5e8eb	9599
965	e164c77d98cf15a57f16822bfefc28b254acf16eed57a6e95a81aaf6ab24657b	9600
966	d54387de7f35babd1639cff4b893eea82043d542baefa5ddf2a744bf7040b3ae	9606
967	88a88cd6bf7722e8cc46e8d0faadbbf6777903eef7b8330f0214d46048c4e5c1	9615
968	15ae6a808774e4150e6cc51f56dd7a04ab8b5cd0370d48bc684a5ffff761f358	9635
969	0ad0fac6868305212cd58368c5765d5a2adec1455345769371cfcc516f59cbfd	9636
970	26e1f7e0c94c94c23b189f25c3535a74c9f3fb1d765a20fc4de0311d42fd27a5	9655
971	542f0831305fab03874a4826b8d27131a62c3bae970e4208c6ca37564eec41a2	9705
972	fb0a9a5633cdcd4e2279b564f03d9f52f0114eb762a52ce246220833fb543a28	9712
973	54e760a571e286315f13d2613f6baf2e1eca249c657623f92c8d82dc99c02d5e	9726
974	8d512e7d7cdd99803bad7dee6a93d146c3e4d0a43372a23979bf89019dcff7a0	9757
975	0fa79b775d8fab8fc4ad21dd63111c1ffa5a337fb24d6b38b1c41b3ff3b14ff6	9763
976	505076465cb73c2204ec83c87c4b4d38b138345c88720dd6130cec1e3526c86a	9767
977	3e3dc8a0faa5296b120bd6153e6f08a36e0c95475b364f1cb66e3aa5149ab812	9800
978	9d98994856d21f0878967afd17f990aaf4358a120e04d552afe93248bd429e27	9827
979	79e058badb82c98c7f15f31b5d692148acca1e11b5d4bb9c18f8949eed67d83a	9840
980	d74f5760fe7e2bd2b81bc4c9ae8240a568ab9872394b73139a606e4b71861817	9847
981	fa6ed686f74dc7f57881a97e2704d376e600dcb5baa352089ac546b7fadd71c4	9849
982	0f71692b2c45e0b5640b7955894ee82e9bf35080b50ad749d15ceb1b085c7464	9855
983	51f14b6202e93a50c267b2c12f578c332ce0fef618a3f8d325d4d0541529a5b6	9859
984	851170008e45763f0ceac300a0b6bb4324277f093d65fbd87e9e0b3d5b5cd090	9863
985	fb847719db4cd7fd88beab207a6bb0767bc1e289a0f6fb1d4826c4936d38503c	9870
986	d2bf3a88579c7f5460e479703ac96cc1869c8ead951565037004cfecd55c5627	9880
987	7301d58c05ee81c8117818a414935856d495a5ccb3d07ac8a32d5eecc3b17f5e	9892
988	6f1906ca1a753be5757c0216853e77ae5a2ec566ab17e8406fb9e8e68ff40738	9901
989	cac5b926aace19ec46ff0b9c1b64e89928efd8f83c741807d5c1535fc32a52f4	9905
990	067a7f2b7fe5d5a1c248d81e70aca349cc1af60995d452336e9a7cf2017d030c	9906
991	230061747f6eaf92de2637e6f4bd6ebcc3a961d0e507bba6cb4c09c4f8e0dade	9934
992	8888edbea507be74311f104dd6469a9e2d7ea6912314b3162c830085e055de3f	9937
993	3f98f30d05e63c6705d50e500b32d22303150f6538f32b73afd8ca2dc1786205	9942
994	4213e128c0e99eba109acfb1a657b1401d717a21b0bfdbccc7278377b9d4798e	9943
995	c8b85275abe9374dc143af648c75483f7d864d9fc4eac800706ad30476dc06e6	9959
996	95e5bc441dd77abca079180283872b3a588e5c9fa87284635cd7e1ae19eec91d	9974
997	3f307eaae0502664a77d27b708291cc2cda737899e3b4966611a217943f70d5e	9982
998	86f89da836c481b075bd38efcf098d51c0507ba04a35967badd0888879897865	9986
999	8754c60cb1b9b68f4342c29e0c12bab578de7a2f881e52112f4ee615b1b5a77c	9988
1000	9b43a52014ba101e9995c6155ebf79f08c71df14813949483ecd3c3936c3adcc	9994
1001	d2232606fd7cb6ff49025d6327a259dd36637eefb3c5f6c752dde64e59bdbce9	10000
1002	c638c2ef4622a7d1ba828364de5579cd763334e0dcb4c600016d48507b0c148f	10011
1003	1ae43e26cc079262cd72c5abe43036cdcf99c2e54c3afba0544c9233fff5fd7b	10017
1004	91dfa7c6905b46a264c7f2ea9458a79b82df2e6267109ff363db183d1c60bbd1	10035
1005	31600e0ea36381767e9102d34e3afaaeb8d009fa4f4fdf7be642cbf6587f423c	10036
1006	d83c8b8073121cf2ab0a23e5125399bba9fd94532bff69d93c7919286b3a4189	10039
1007	de8b8a4bdb3d66e331e1c98659481d40b924aa75a45cfe6cf907f3ffa64e3f8f	10048
1008	d4aea6456fb77cfa036db0968108be7cabe3c180c464d18a05fe83a2bae307c0	10051
1009	a20bbd9f4826f92b99ef19b8ebef09d14196a5dc2201a8a7f2e89dae423c883e	10076
1010	7f0f9808fb63a3b16c43105ef3427a421bec29fbbb15dc42d10b8b0a72e16098	10079
1011	345fd6cb3f13bd8c7fabed9f0f1319e26fdae8b0388522aac1d653a977efdf91	10110
1012	657d8190a8cb6b8c16e84fa682c0047503bd53ae54465127adf6d9ccc7bab83b	10161
1013	d3bffb4bd5be1a09cb9a5f8b3b5931fd8d6cfc65c1fe1095903867a09f289a89	10197
1014	7a0dacaabbc9cea343ff4f71e12a134c1cfb1215d702939ff78f9a38a999e4fc	10201
1015	416dcb13756b771dca976d2b3657e447843dc4906a2b300b47d7705ba7f9896e	10207
1016	3109f60749f7e3d58e5a53ad9069fa2a5296d72ce0d76838857a78f9965da946	10215
1017	de37f7609c226ac54c5e22367f63d13c126018455bac0fe8df88c048d3d9a101	10217
1018	0894c4285e4a09d28492f89ba47ad4e9f1d2eece79f902f835ddbebd41e96359	10243
1019	5d8df2e25ac991f8db7a3397fcf4b4ad3accbe865a64920e16c776f5030538d5	10245
1020	6ffb5eabcec6c9282e28bc3dde6f53044a5a2cbb9e79a8ffab0dc9d778c7d4f7	10272
1021	e0ff7a95b9b3f75c0526c956f31ee273e1819f8e8dc0d97594c1215d48bbd623	10279
1022	0b11398db7eaa5768911f4d611114ce5a2a34c1860570825a3d4b860a10f4d15	10281
1023	891c9e8f3ca42d1f0a72eb79176935ab0c71a10d1217e32b7d5f6ecd087e143e	10283
1024	d648d78d1023fde5ee157b84a67ff68fb293b8ec56e0ff38837fab102b03b283	10288
1025	a6afc17ce77c67c960bda4e63494f3eed59eed7ef3bf600e1ca8a99256c620b3	10292
1026	bfad5c906334d5fdf1688baca48980ff2d8b38e54ff9e6908da0f703611e16b4	10295
1027	09984a081fcfe6996b09d404c1ce263976a566695e5d18c351589eb61487b438	10303
1028	7d7613b224e5778176c5388ebcad8c2a7b4c11a215a0d2a62d08fdf2d7695916	10322
1029	ba00fc12982c5f0fbbca642bd5c9f9e22fedc773813a8731fc79304bcb42cc57	10324
1030	2f29250c9d66fdfe6e7ecc12d9855dc5649b5054cae5ff665ddf1584d730c2d3	10331
1031	01914c8fd989c6da9d265b6b4050d69d7dd6a303188f842da92564f559e9febc	10342
1032	bc7f953562ed3dad291735bb6e9e865e3d5fbfde2f3cd6d6df7d456c61e9cbf3	10343
1033	86ddfbc3d01c188392f08854ada7957e6fd378a00100bd6f1c6a31b45552918d	10355
1034	89c17f2b4d1233b3042efb4433251ed44ba4ff27d60c88e3c04014f1c12fd21c	10361
1035	af9164632e344b91281c56abec9ed4002bed29548523552aa7212c4bfe095ddf	10380
1036	01d0ca8ee05aa6cac8192ceadf1c753309cbc27d5ae239ebaa97964616e40cfe	10386
1037	6715c90913fbd1833b70ea13e73662f795798d012c677f4b49f755cc9b7348a0	10392
1038	88db4373d498f7cc421f6ddc5523975183f5177ac8f77319ae2557f16b3aae14	10413
1039	a3be963624d3ed92157995c547da8f3ca8b62f3516ffc081d255faefd7b49a4a	10416
1040	e51e0369c6e4bd8d955d7d8350b46c3faa0bcac67b5c8bdc9c9521388aa6d711	10417
1041	90e58c075cf17bab8f4255dffaabbf822a483e612d50bf16de6b02debb9cf97f	10418
1042	929c0c3f9acd2f9435282178e77abf81013c7335ea3342609f4e7cbaae467a55	10419
1043	8cdbb87638f84862b630adcfdb4af5f2896ebcca38ebcfcd996243c66171f7b1	10424
1044	77107be7177b305a4f056b853c0858ef77b0f96956ec81f78eb7a257f93b7b96	10443
1045	7a02faf2a675878cfd9a756e952b162a7496806d01e6375641d022230720efcb	10454
1046	8c9db925b6c6d29b493a4cb1e8aef8211c7444a62472987609072cfe274f31d7	10464
1047	f2493be5dac47a233c3e066b6970cf2fc9ea7c3a1c76851fa1ff088169c1312a	10469
1048	cb20b4a204d1be8c18d3dd9235d4380d27b056626a767b8fc4f3dadc5a64bbb1	10481
1049	6922487ab747eacc97853b1212622628daa5f740183a81c40788fe0d2e72f73b	10491
1050	2a0ba2fb4bca9e20a62087fa23e8efebe9cd83172a1991a9289f9ca052a761f3	10492
1051	06cef44ed60dad4187239cf0baa15ca3778b054c55ab8213f57e170180065875	10514
1052	62c684636797b7dd10474f9787b3b33d34ab4972e25d33bdf6b7a0582a2c74a5	10519
1053	9ee2c98e878e4e5595bc0dfde19f8d0481471c8fd05e6d5ce18b230fdd919b10	10536
1054	3cc4e338d4f581e20881fc9e4b0d81514e09ef5ab050bf2565a933d0b2f64b7d	10537
1055	b3ee757ce3ab090b84ff8e314866d4842a84ea35c24f1804dd72bc12ceb3df06	10543
1056	e3cc4e8681030e2df1beb06114e9256368ba9de1e6ac28fdf46c5860c0927d50	10563
1057	aa9c38b8de89bdaf66dfaa6e7252b64d91a2df1e6a4b368ed40874f7235c773d	10575
1058	58c87b4f427f39a9b78fc2d6ae1a850f31c13d5d78d176831a92fdc4a3e5269b	10604
1059	9a126f536d9f2a512f04b74cfb4087fcab59b3001c9c130d13ef02292ba78cb2	10616
1060	1a874690e3aa894b464f7f6c880aa585939d997ccd559bf9a5a5b886bda4d12c	10637
1061	bcad0615aa5300fb9ef0162ff7123b26e0767c5fc155e8e2606a4bd46677e43f	10647
1062	901cbd9bfbb386882d8acca546857242c93ad58fcd8670ef121be01e80a93cd1	10649
1063	24745703d325fd1c58f03f15175ada5fead76b674c9e0f84ece4e331dba6a63f	10672
1064	0906744f864bbdb0e3bafb20f8bb15f9fe47ddcfc6db90dc8f584c17149dc668	10685
1065	b7a21b075842980b2d00fa41ef92f7daac16b52d1cda00f1bc22eb7f98e61590	10695
1066	76a555d33c92563c0a19d695d0834363f6c465887dfcdc90053e1ed4d922270f	10713
1067	a278de18a7d5b6190114c60c426c2f6ed2693da683d5a7a906c22bbd22333f19	10740
1068	54c89dd88160309b5d00a929cde7c70a6b00d6e0eecf3bf94b92151c43bf1350	10741
1069	b8b367239e96e579a05f1781482c231368002277116e0f6001a49d64d5f83144	10743
1070	1ac9e05e1ae387b8100b189cba0e506735c0cbf80de054d9d84bfab8e5e9ff30	10750
1071	5a669e75eef0d472061af558c4936026c01bce41b78ce8cbe741c9f5b6c14e0f	10758
1072	14559b332f62b2868c567ef71b4dde2b27c0dbbd6dcaddaec74c2f8d50d81d9f	10761
1073	f61c5f4273ca7f3044f4c32528654754dd49bf394e5af492f0b747a8c4b01880	10765
1074	658ba0ec58a6d3608e4b00bcb5a50d3b17760d0dedd88b38da2b65fc474550ae	10770
1075	41c750244d09b102bf8f07e77e3e2c1b45493eace3d7d584ebb4b8934304f6bf	10784
1076	a306edd7aa20f116d1d68f243145a5a58b112e6ec9fa05a58fbfbc3fae85176b	10787
1077	c3f6fe0debdb8e080bd7a9bc052d125f5be7d472d528810f30d2a0b435d0aca9	10828
1078	3992177996c9127fd23d3680a836d0f689eaee51e1b3ee6efd49bf8eadbb6b80	10833
1079	a421fc37583f4c20389e174bca30d7cf7dc1418daab7149ea9242ff9d1b9c92b	10836
1080	a2570ca042a9e4295343d8d9470d492c5c790a3a8dc1f699db694cfd26cc9525	10846
1081	6d4df83fe48dc257fae9d5fe2f0676d82f610baade114a1a81179d1b6fb7dd93	10854
1082	9b0097b8d83e5b4d320f4cd204b7296ecb451506ad94c6772022d5480543268c	10858
1083	95727235ea655381dfb3fa903d0463b8627d338236c0f1694ddc1730ea1d9aab	10869
1084	7c8d9d314f145167037e823cdaa703994b3cfde1a71c34c4a95648d1ef749016	10876
1085	85b63fc9750f6c8575d49f088be6e6f2f2357ec0f5c3968484476d84187aa225	10879
1086	54ddbf426191349dfd45d447a2a316565a02014ebffbc143932fe4d9bb666a3b	10880
1087	7c239f87c5074384969bd89fe491cbeed0e405fe6c6bdb97a448990da444c154	10885
1088	cf3ff53365ee1c0c904151f1cc51f09244d1ce47e2df5bbfe35d4bcbc7fc6987	10892
1089	09e4661300eba0392466b6c14d2e30c1fcf81a8a83db022c17ef0a86682a3d3a	10899
1090	945561f2e5699ac12b2f1d325d9e6c9dec2336a9b42a1e2cac5caa5d9f1da0a7	10916
1091	6b53bdabd64cf1bfae5ba36c873b767e0f2cd16db73ba3316eb0f17b826642d7	10950
1092	c5918c052d0789ea14fe950febae2e4e3b320724769a0e1af3a03b3ced07c25c	10960
1093	c1726697306f0e97dd027200a22f4f7f6c44478df30c631f4efa90686383e727	10967
1094	1482bea596e485131073b368a88a335678662956effcef3a7fe3735711394b74	10994
1095	d32974eb7863e2bedb46f85d02aa4cf0daca4ce025ecf8b56d00b8443edbaaa8	10995
1096	98aa7b391fc532989c9744baf1ff8a5c7caa22f06cbe96f67daf90116034d6c3	10998
1097	f39fa9d0af0d02696a3ade15d37e9ac5aa702932696e262d381af7943fd76e90	11002
1098	73fe47a75e96d31c55c2c3fbee7319069db5017b608360f98c272814965a3d12	11005
1099	09aa8dde6997937cffe047b8f442f3974a289cdea2a5d086c86c6f97227e2b0b	11039
1100	5ac2fbe357dcb11178214c87d74aabd921f23bb52b7b483f684074f01da2d324	11046
1101	9072ff5c73731c0a56630eeb9960a5594c893761d0b592f0a9b23bc64d0af1a7	11065
1102	b700a410a895ffe895177ee0403d632b7abbf826d423112993bbbb875e0564b0	11087
1103	995fb946412b5750b07d3debd70a8328e2577957f4f19a99fb2277c02069cd39	11088
1104	fc9a6c71a2fa7630832e3f152c9a84f4f7dcbbb40a8c91991f1db3b8efc0f5f6	11101
1105	28c1226f4ee70d8cb711889d69e836f852e75e13339c1725e6af3955931ae51b	11102
1106	20143d0cdd258331887b986b5bed40146d750d978324fd01f75c4cc0725e0d7b	11105
1107	a8a39b13cc881c4e631ec339de2667d615a5d3c29551174b6da70f248373c3a5	11111
1108	49004eea11ed3f998ecfe51f87d3ad3a479e50a2068444ac4dc1d378f1d7df38	11119
1109	7df90b48ae72ce40b651cb72db773ee31d8bbd7ba65f872b53891926dd085d13	11131
1110	6a50b9c822f98bf89a2a0875ee8c6de01e47dcf7a8722ce520de9483f0cc1e1a	11133
1111	98f4384112b996ae152aac707cd7d2b800b4bfb622dcde2f87d70c97fb536515	11135
1112	3c9e5ac4a0f76bad14a4d35cbdf478cab590de8ef9e685c94e868e6d85ace565	11140
1113	84e87c7d55d84a33538dad42d2873a11b7f8b184c7953de69ab8239df42a9290	11143
1114	778d2681d628f086aad17a5dfd80eba7858811091a0795daee0a9c07bce1f703	11158
1115	6c6a564b9c282809bb8886cbcce18f0abcc3cc104ebedcf7b9e95349dac2d8fd	11164
1116	63aa2dcb55230821aff1c004c2695b1c6527925a5258d81fd3281a7f671e648a	11172
1117	3cddd7b616bac87427aa4fabb797e759b3de9184e95b7c9f07544e9c4d5855c0	11179
1118	305d5ea6c5cc90799fb7126fbb474b591120752fee2e322914679e6fddde515e	11191
1119	9412375e9d24e2b0b7438fe2ae73eea18090f7126f1390f3cc5f52c39b223ade	11192
1120	1939d5dc47670118bdde39e935fc04a6da57895be46236e899b2a52e4b1b12f3	11209
1121	41a772e83d9d43d8c377ecece98fbe97db5bf7621e1532f38a2f81a11cd0cccf	11212
1122	ee5c6d873b8cbf12f0fc6bea7c5a0b2e7a261f24da4d4fa34e433a3dfbfb5ed4	11232
1123	9b92108fa8f201fb626710e2a72eb3309e17eb7a298fd094817c7544e7a69073	11246
1124	95933e554e74dd3e4caeb97183d9bf5512b58a89085f7d7e6603dc3f328d1d1e	11253
1125	e33f1c315eddca89a0e1f42d2c3a0dccc2885421efd99f3b93de2963152cd1bb	11288
1126	ba60e84779634196650b7def824a7b168f8133792b02035aaae02890b7549cca	11309
1127	ec6e1181c436f5a65d74c5e727fab2c1dee58b435b52e5b6bafe41c1b364537e	11329
1128	faa413ea3a1d24b0fb352c04db5d7608cd5335ced43d1fbef15b27f700b21ca9	11336
1129	2639a5e69058426ae7d559c0267b57aed6f9ce8493fcb97ef6943825e7daf558	11356
1130	2a7b8513f47c859f2ac030206d1592d66c4d1efa3356ef42748b433826df0c09	11368
1131	392c8000bc770b8d0f9c0680f3dffe04852d4d12c4f1051ad9ca84227a79243c	11376
1132	e47f6fe7de2a69484935292bd3bd9695679af25df70d5327692db5837803cfab	11380
1133	95081f2d81965946d64dbe042223dc4e9eaf8d79397d679ca0864ff2d480da0f	11381
1134	77de92796d6a5408a009667ce94b438ec703cf413629144d5667bafb108b7f2d	11382
1135	6aaa65361fce54e40ac04e6be4c977f5b1cfe08d2f926d701f677fc5fcfce0b6	11397
1136	feff66e4ed570b86d0cbc41ca8e006a265bb2ddc5e67462c8518e8abbd5d3b09	11401
1137	049ec5f848469c74f8d391ba2efc2a03592d2b162240f42d45ab87f78959dc8e	11406
1138	2f5d01f8fa2538488afc3678f2baca1e8428da6a463d9a541848e92be47dc7cf	11419
1139	adeac9b36546268e7cb1e5ceff24f7f06876561200716d33d3b33dba517e73c8	11427
1140	8815e35d93995c9523c26c717b9043468ee9afffe953d14db45bb7fb587f64a6	11428
1141	ec133c620978e05d77cab1eb5adecd51f680746bb6359e2d63c9f2f9f4bdef49	11439
1142	afd258c741692ad70ee06e9b694c568052ca8b56ff7235dc85cb7ee4270bf418	11448
1143	b57c1996e58ca1dc144ea4269523307c8b5ed5ad0da073e827dd00a7ae9e7f31	11452
1144	14d75d1c25b08da6df353b20918b576637003cd33354c427d66cc69890c81e92	11460
1145	7685fbbf7d2704cfd2f38878faf3a62bf4bf86ad91a68fffa8bbd3e5e23d4ed4	11462
1146	22773e4ba218dce7b56ef892b034ed2c6c36409c5e05ec9b8944059c38bffb99	11475
1147	1c365e89d517e49c9d42b45e8a754919e440e1379a1207ae6303030bdd253f58	11488
1148	52bc7e4bfec0f68b5b4979d554dcbd4f045cbd858a926762947b181414f78699	11503
1149	85f79105c72eba406fe54f635c93ddfd5c4e7276b9754e3c6754fc3eea0620df	11513
1150	9f1fcb5d095f54e5000eb14c2ade33d51f433e349ef232039208153c63bc85a2	11519
1151	60aca53fb765d77589f9a744ea1c9d92da29caae55c29c8394896ca7dee091dc	11533
1152	8b1d1a4b8f626b3ff98c3af8fb1363b9fb117cffbf3973226bd7d2ffcf4ddc86	11566
1153	5621a8a23970026149203289609b96a7a0be8aeab6928ba1a804e35ec294b152	11570
1154	404ba01101a9c3aedb5bc04cc772b5548526087d8aa36a70a7627fad34d34f0b	11592
1155	757c83d7b52bb2db2577fa9d1766bf9e0385f118eaae6917a185060b420e7654	11600
1156	d19d31a8c3b91d5a877acd75ceb9ca73141e93726ee314b4bf3475c6f93d042a	11613
1157	3500aed02b3219dce2a69e9c3056b568ff776210ff5a7652dcfb33e0a934331b	11619
1158	1afcb7592163574b1e4fa95f7b313d830bee1ff34007ce0afcc7ce7aa3ac0142	11633
1159	a558189de0296ef01960402d3c956c77b994fcc87126dc1cd56a1ee54701184f	11647
1160	a0e51d3cf2193534fe83c7d2ce19018bee1b6c3dad89dd468ab3ad87d7fad29c	11654
1161	6216b0a49c8f9a7aeb013bfa9301331d2061ad35991fe60e842fbc9769e901ec	11660
1162	a5f1e030ca32bd48e997480885769e817dadb15301ed506d15e4f70c93115e6a	11667
1163	3a70f52a90d711d343b1bb4134a3247cb60bbca66403494840749670f6d02637	11668
1164	a4ec3e0785e627607d73a92929a48d5caa39bba213ed24f31103b751df7fe6dd	11672
1165	d9bbb22abe66208a20d277bfb4978b18ed9a17b1fc34131b9161704d7ffe21c2	11675
1166	03d7792bad8bfd0d845eacc6d46a48a21b4992108018018f1d81c0d822e830e1	11695
1167	0bad435bb9dd30b06e9358d38607d5a410e4234a908b28e5e71f6d02763e2fd0	11705
1168	26e97da6fac38ff0af1cfe55bd2ffc25efe6bb4a4ff05396613121e2566ec897	11716
1169	c4205bb7ce3c5a3b5dd8283ca3dd0ea8ea624d2140829e1083e111fcf2c04f60	11727
1170	f30d9733f4191b15a318367d2fb06dafc732b4e0ffb2f753dd9c288a943e8089	11735
1171	65cf40774f746040cfacd3cc3a1871a68fd71734fefcf58b6b03a89c4d90f70d	11752
1172	fd10bcb3f285b133649b38f8c7659d8e5e7aaba258a34a078eefc96747714ddd	11757
1173	d287aa87030e2c08c198c0e76bbb8654aaab852a466e580d68be6a80c5daa476	11758
1174	f535559c8c54bb9eed0765ded7f9e911371c515eca4352263652a04f518ed2ae	11765
1175	ba12b73aab0b69ef5e2e1071ad88a43238d719aed47c2720e74e9e27de82943e	11768
1176	837920b33b2836f76d92f7bb0eee6a47ee69fc19d528480ce0d62373e37a71cd	11770
1177	64c53c91aabf678507dde0d94bf37a793e3b2118ebc297cdb6bb04975769c61b	11781
1178	c0d8b42eb5a1be957e463678e4be3e4e5e51f0e6d98519374640d1ad77eeacaf	11783
1179	2421071014edf196734712b1af89ee1167a9c3bc21ed9a88362fda57d506d881	11786
1180	b0f623331e0d6d831ac108c2d99ba1dbdd78f39146c2e6eeece6060a79e1b9bb	11793
1181	30a4c190084a28ecc8fcbf7b0ce462eace22ef6a76378b5b052a157901a857b4	11795
1182	7210455f41485d29631b5deb9ebe76a121d13331563909acbae68df689fe6be3	11797
1183	f2428cd7114128a7c693fa03491dd91c0eb77ca6547e1c4ddcd4470bece07d7c	11801
1184	f356333f1d16283b98045852c2815fcbffc5bbde407473ce72b9d6a537cc0866	11823
1185	31cf06c7ee78d1be74bb169f203ea6c6786e4c68f09ccf1b7d23ce3fe21a1e15	11825
1186	36e536b83ec6e8991a54c3dd0327ce3c42d48a1288e057b19ec498cc6cfa5684	11827
1187	5fcadc4e3d8ac147e6f6e39de6c7215e6afcc562a9f6702a0dbcc73e15a7ed21	11830
1188	3837dcb00d8d9188a3e959fe863a2140bda97e67b9528459b2cb7a9090f3325c	11852
1189	bfcc9ef46bb36ff5dcb414180717b1bf039827a9e76d45e639347ce195d2f750	11855
1190	9eaa42513469654ea348c02a964a6aa878f255384699533eea0666b0a1823368	11866
1191	7ae28b0410da080034ddd030a9bed379531fe9375bc05e785bd85288f11536fa	11868
1192	0ea5244bc634bac872aa85e4011eecae6d5d6359175ea32024e1d42174a55479	11870
1193	9eb47e9a3a6229b75a28c659a2381334b8e88b664ce39d56e0cf024165e52b6c	11881
1194	18177e8ec4b09470a0cdbcc3299bf6336d59c3558ce6f7bcabd5305fef06bd0f	11889
1195	6bbc23f76cd996e23e3c0d251c2ab5955675696c7cfcf9311898f9e53038cc73	11890
1196	c602af6adb1a8918d6352e31b0eb76510826a9f58de1e7ce154324da4578dcec	11896
1197	41ae61bcd3bdf50679b37627eb014c3fb4edc5a3f08e73865ce94b78421d3aff	11910
1198	fe4d3c97d2261951d861ea99b50752a93fc4fc5f91883b6e587dc9f73319fc9c	11919
1199	b838a3b7ec668ae8515761c1baa5bbb5d0867c9d565c2be678e09e4d23112072	11943
1200	14ff3a833bc3e2275b64ffa15650557f1c71d5135c8fa92236d53d570062df83	11948
1201	82d07f14bd41f01bcb5eac4716faddc4b56f97d0aa4a2ae07ba9acaeaa165871	11953
1202	9b50296c1e2ddfd7917287ce8877add3f1588bb1539104a1695ae5faf865f6fd	11961
1203	3dfd9ee8d84c7de349ac7da019059cb87f0ca7bbfd4fa07b2a3d05e4bad78baf	11980
1204	f43f656aa3c7de5eaef789e1dec7bc08e0f16fa7d8c3d8c49337a337e4b9c30e	11981
1205	e2c6da6aa770677544a4d11d0af635d89c39c0913aea2f05fec7ebe48c7fff0f	11991
1206	84d544435f677c903953989eea64f2d8bb2260612e1ac75e6e51b551579549ad	11992
1207	9a1fd4fdcf3cd2ba1ee71345a255a8fd0c8f7f027b4b4e4e18b8dce9b927d23e	11993
1208	6edbac69de483fd1b7f29b5d7140db7eb1818ecb3ac9761546b0deb45b773f23	12011
1209	8b8d1b0e41ce7637dafbd8fc64ccc7dfcf827334e3356e8fc901ed0f839fdd49	12016
1210	fd35c817a38c853380f5f74a9d91ac185fe1b52577e73849141a0099b3a0f78e	12022
1211	1ac0ff3f0940facf249fc50d3e50dfa7329164113ef047ad92943c60206b9ac6	12026
1212	e5f256f80a1282d81eea82c0b2535013efa9d2f28fda11204b5bc6742208c0a2	12031
1213	4e21fb62b68e0c16517c519f32de2d480d55eb946644621503fc7d8324e95391	12033
1214	bc0aa344febc2dde8a68f2b3ee87b8740522b3bbde91085d14eabf8ceb092c3e	12043
1215	d470753ddebfe21acfac0cbead90d841707cbd5856a870f1899e1eb37c1ddb4e	12045
1216	39b687e9f729fe43b9854b130ef14db332fdd086d3f06a5af072a5af0bd3661b	12054
1217	c637ccd8ea53d0928687b032475998c3b498ef85915dc88f2b472eb90e2da69d	12067
1218	72b433a01d785cb7a837746927c92c950a69dcdf371ff895ba8782f3f2b5ba00	12074
1219	3e6fe19a01b21d19f509bb672e4804bdff354d9f4727f04bfcc9e7b342aa31a8	12096
1220	0454a450724710fb7a16b93bba76bd451b308aaaaf84cdb755c1c18bdd342d9c	12108
1221	db47e12c5a9be78bd5783295040b4ecaf8d585b17129d9c650dedd71a371ab8d	12115
1222	5a0ec0957a5fd4003c1c9b7c03b72ef7b601846bb1803111f42d6468f3abd5d4	12123
1223	aaa3c909b82496148dece5ff39c32d5687084810adf5e2187f9e2f028c69caa0	12138
1224	75833d45283f9b5c854e3b13a6bdea80746248f774496d676644196948864fea	12139
1225	39aca88860a15fccaf5845c7a3449f4862a7910c096b260f7f6d603c40f077ce	12141
1226	ba7f1a3916e1f7a84642cce5ae71391e4a78db271b196c5c2360231b547f083b	12156
1227	0dbd0b1646c1a2a8b68d10d220abe05e80195564d565c1c5308b25f12a2421b7	12159
1228	cd06e9f55dd371d37cd2b1bf482dc3a91147e7ab6b0e539ec5046d5b86d95d1e	12189
1229	9f024f43f32ebfa996041ea3b367b35fab9751bc9196d5f91e73decfedbda06b	12211
1230	27756b0b7c879ae5f53e6e8433e6171388273e9ae6221ae85ecbfee4b8dbabc0	12226
1231	0a4d0268acc9e31dbaee42fe775259542a8fbe3b463d01b1de8787e5b79d0842	12232
1232	37bce629fa256314d87ccf58d8d84fd93f8d27d1a9aa798cb035bf15f727c27a	12248
1233	2d5fcef54f3df032269b6c9a8936bbcec616889550a58307c3964741a29b6a9c	12249
1234	1b7c94ff7f1c6d64f93c1a26bc7dea5779fb310f1f6654b5fffbd9071eec770a	12256
1235	9418cfb28c0f944cfa186cdf73901a875a6aa5abeb7bb09e30804d0604f51f2c	12271
1236	b6de6f0b2b4d7b6008434cbba3f3d5694c0057b383affd357bb66be89356428d	12291
1237	eda41f0299361edf0ee93fa1b3196ea45c2612d68f2c02d1e58c4c9dabc323ab	12294
1238	2ea9e8beda64a9171eeba86ed85d628ac85c55935b792bea976ab5a22ba03f65	12321
1239	8383296b139e6b5f864456a8ccd5491a140511bf57bfb46b23963b0a63e1f815	12373
1240	40c6f78bda2f77e1f019abe6fb5da90c30f8dbb7d6711948027c9f3962d42114	12376
1241	08ff2e178eecfe91a92e9303f32cf871d16008932336bfff1f4f3bf54f00cb67	12377
1242	481490cec6f9f81fce711f084c64c9a5b7d7a02ea9adfc6ca2e60a81e6b1822a	12380
1243	eb43b9a4b29e3643c0d230e10583f02682fda3fa8929f909ec40060320bab298	12381
1244	94162708b508c20464e1bd164338aa30455e76f6c9e772cd1959d2f1d277f2fb	12401
1245	264c2a80686c168b309f41e5df4fa6230b84637bb7f7d6a169411bf438567861	12460
1246	40b8e1820f187ec5e8aeb1312220a87c64b36d5a944bb113add5fc9d5b0463d0	12501
1247	fce42484484e1dc43c10c4ca5546b4f55f7ea77be4c24f864fd4326fbcaafec9	12505
1248	23f9612c5be2ff950e1aba25038344c088943475bfba97cb676052cafbcef3f3	12507
1249	12587d20dced322d0026aa75ec50a77c7b7db1386ff731732560636c16afde94	12519
1250	b1e097965a28b2f40cf94b735ddf936b63ee0846d4fec0b2e24c6f55d48c48dd	12537
1251	f927befbcb8dc9ccc1bbecfd75b828e151417bb46254cdcc986198a368ef25bb	12552
1252	8ddce96ae8331fa61c1adbcc74c38fcf031baefabe82e0f63d6282c0048efc0f	12566
1253	99aaf29a216936568b2e0ffe4fd17360a40b4d78f3e928eaebce48e85bc38fbd	12574
1254	2ff95275b89729e5096fc293bc3e91b82ced0b7dcc2acf1bfb99193650b5ce67	12591
1255	81057c8465e351e47c05f7d9fcfc876c8e72d81718e66c0d3f9614697c57d3a8	12610
1256	8009c97ea9073e9e333b3804b95145ef0558090fc66ad81d75c42ad4afb8f185	12665
1257	ec3f6fa86d1cb04f959e6cdc21ee76408e1d55f62bbf29a60074e99686306177	12683
1258	1d5836cb9609fd3e46a8136913712ec71ed1cbd11780f72bbe7f430aa1302f7e	12695
1259	58c6aac1abf976c1107831aa01a138f652b953da325e15dc5717c1c950217d7a	12704
1260	483e347affbfa3f6e4f63d6576104056619698f0d3cb6ac6ab7af9472733965e	12705
1261	b7bcc751aa6366fbcc42765a30c40e7bb5410e28ce860d32a1dce96b501d78c3	12722
1262	d13067af9ef3650dd1490680c50cbfc495bc5358f134534c6e3dcdde33341b38	12736
1263	8054cb6d949ee073bad7fb1e47d9e998acad85770d613f1e28b66e4ba533898a	12747
1264	1b1ab57dfe30a1922f3fc8d1184e54c7a99ed17ebb1c42d08d88b1d6d812d390	12756
1265	a4dc127727eedcfe984b4f4c6be7d1e0de45b0668fa7101e10c686a13280bb4c	12761
1266	799245ff5893b9fe8266bb342a97f5fd932025a3aefb0fc40add4e769e28ff47	12776
1267	bf5ef4e14d1dc3f4764be19d7122ef1779917bcc35273cddd950281be4f70451	12791
1268	612d164cf6abbd1397f66a56865ce0d5c8fe9f148174af8d03c998277cbc176e	12792
1269	2dda30ee4344f39a035000a809eb42f5603d9ce38fa0501d06e9d757c5269e56	12794
1270	089bfac29c3dc06d3b66f33da044fea97b1a9729fabfa763190adba1277b8650	12795
1271	d34448e94ebef062476c8b722abfc00f5ddb5711421cdc9309dc668a62f9110a	12816
1272	af96bbd71e43ee3bad7cd41c6fb64e3ae8f91591ec30c92e996f944f7a662f6d	12823
1273	94f8f5a50f3b1ec280934e3f5fced50fdfbbf01a5e24b91eeb1937e1fa473d26	12854
1274	d3d1fbbff9ac50e685bde0ae4ee5a5f3c911b5e0dbffc7eba0fa58b0b915a2fb	12856
1275	1e71f6b36e5b3c0ed4ee7f899cbf0af44311a84f31980e0cca8d841d07899171	12881
1276	464623ccb5af2abedd037f0b7925f299eabd8d4adb0c236e0ba8bbffffbd9a92	12884
1277	7c293170fda06998f5972cc810a5ab6d1ee562827973182cb0b2c2b632fb90a3	12888
1278	ac129cf47c545c594b7211c2c9caf2f5d4f96ef2bf19e0b2421d5b496f63a06a	12894
1279	d0cf6e6675e82e936b67a98a9ca00e0bb604fdf2e6bea3714e29d7e8484c3827	12905
1280	4d57e4e98a1cc6cdd6d82a70ef5396bcb7ac72bb468c30b78a73ec38c9d72c79	12908
1281	a8bfdbc665d8824e54c453aae805210822189960c6c9f1f0eba5cdd59579ed68	12913
1282	6f64b770197d83b8f5774eb0993e7fccadd96ab2b77dad8bb5a0d1861e75fea6	12923
1283	acaab641c5084366164a42f24e5a1944a72c4f14a3ff69b2bfe05a5df2f653ca	12930
1284	5e9b31e23d1e0bbe6814d86da3bf7f096796f6ccf97b6a4dc240c6e8a30d572d	12933
1285	289a4088051a6cf070d9a13dfad900f2685f002e88a076976ce1177f17f99f5a	12936
1286	9d3a299c3cb9706445e7d74f438db1d651537e55067e9f3c0a93d80748e026b2	12937
1287	34cf3ffe00a36abb7689c8bd88b782ae187251d9fa088ff1cd42d831bb1c4256	12938
1288	8f8e327b17668b504bf76d4a81aaf24248851bd7602ea42120396281a57c0247	12973
1289	41d8b586fa42720546b57513ec83c0cefce0366671851d31d5642a1668b31719	12979
1290	d1b9738f6e9b323a60509a69f71cd9d98777eb102f2d91ecd2ec64718d37c3e5	12982
1291	16d2e13c2b0a40a1c8cefeeac47255f591f16c4002003b08b08828edf144bb8b	12984
1292	6cf04249bebf48afc51a673ac013049e187528cf1ba00d6248567cb6a934d156	13009
1293	8b1071e499988ff7a543b4e63f2e6c76ddc6b28aeaeed6565a496f6904ba8c7f	13016
1294	07cc87a8abef244f3cd140d2d579918f50def6af6328734838e9b131c88cdff2	13019
1295	d94558009e28781de8b377cd72a36737dd8bd581adc796a53dfac324354f5e0e	13025
1296	adee24ba7c637273370d5628dcf27ee420e574590b145bcf7f21f456fff6211f	13040
1297	05536f9f06830301c72706732412cf70c54bf6d3ae2afb244115fc574eeba7a1	13052
1298	c80f05fc2571bd88626405ee4c8a7773500b4b0d4019ef9a579d1f948f35f1bd	13076
1299	0407af272cfbe786bfb8170ee8d1003b8e0b67974087ebcc00e53191cf21b95c	13089
1300	c466c5d84e502c64ee3c39d31061acf51288dd5397d23fffebb80d386dc3a88a	13096
1301	ff598c86aa6badd34ecaf2a6776511b0ea20843e4963c21ebbf8c5f6bc7da44a	13131
1302	d281085ee87f11b14531b7db3d2768facd173a7d2f3e0629e6a18a3455303079	13148
1303	01fc4c23a571856ba980c09a95d1bdfe0e2ecc88e3b58c453e380d6d4243c72a	13165
1304	8e588ae367ca6ddbefaee03d439d64571d2a9dafeeef779fe121e8f7925f8833	13168
1305	a37c026ef7d58a1964637e55a863e96919340e34f76e0e730a6e3ae78b5ec220	13169
1306	e869bd0ec5617cabc339631509da68540bc2d958706ca05b91011f1bb8709f9f	13181
1307	e3d4f572fec0323a1f5473295e8ca8d0305473d592446d9f90e81621afa2d447	13188
1308	ac8008c43a73cd523dbc35d67c48cb0c2d888e572405bc0e4f5550a43faecd3e	13190
1309	3844a31d5bdf553f64e8c78072b98408b7fdcd801a160d156eb8224dcbc1a61e	13193
1310	0ebe52a780fcf7d9c026effd0b07805dd27c39691d290a0b5aab8502ac198c38	13206
1311	0adacc4687bd2a0da1ed5fb2c242565789307eaf8932864beea2ba298c5e4364	13207
1312	b9cdc2aafe4bfff77384aac4386507e1a51809bcba6014cd1c8318a157a2486b	13224
1313	dd5a755096c5b81253c1f361c98fec5f6012129c04c6b9d951256ff3e8ee9540	13239
1314	c2a5b67b65b0dc891cadd9ec553127e2c78e5234b2e631cf57c094d94e6a8baa	13248
1315	397999cc827656f2bded6c276e238cde3b2f72ae1a116d0919c4b53846caf5d9	13250
1316	c5b8d76780e05c735d12d67d980089de0a1a26237fcd2a4f355249d64914a2de	13259
1317	ed7bcf6fe6fb3d4ff93796f67ae146aaba8773f59bf547c0cbf3e87b1ce8ab4a	13261
1318	264cce4d8406a12e1b3b48f7de81a5d617104f5b509bc7b87a1cbbc316491f83	13269
1319	c03cc04a83cf678d3a49aeb32cf0391c9fb93dd04567efd0dd2e67bba6550cf2	13276
1320	b3070738d93d6d4748be51592c6cbb267db83b810de22ded6bb283e0b83c1851	13292
1321	e3bf7fa6472a06240fe43f0c76faf0bbf2ba2e79317240f31877f667e426ba79	13310
1322	e6a9879ba220ff9f8b99e108edc58c598581243a6588264ddde816b5800d2b4b	13314
1323	e59eb2a5a8feff33ea439810296e7f5faf6a05e5693b23b3b4dc7c29ce418d8e	13347
1324	d6c9acebfb5091d2b09aba3b29c54316b7b91a84d252f4d0a2dfc39afa7011f8	13355
1325	405e907130b499abdf9f614c40328e482446a3d1ac6612f4d92a8d679c94f30d	13358
1326	fb2938ad14d5fce56992dbd10afb5635aec487d79e7d467aa2daf50d3f7edbfa	13404
1327	4f5c51655f0f974004d6d67e7a7e84beb33c17769ebe44980356643f956111ea	13409
1328	8006c6dd0eafac2c6daed1499d8a46fbe18438a00a81ce334fd598b63f953195	13416
1329	0e019fe7474e690d4c59e2be858c7173eabdf1b6899d12dc13ba708988b68c3e	13423
1330	87f20698c2843f09bffb754c4710a05a2613fd90e7c8b78afe4aee6fe34e2cc6	13427
1331	3b93826c7407bfaca1847430dcf651fc596c808e77569d253161a98e9d93e385	13447
1332	ed05c9743dcdb98c0d36749a47d529f9203fa358bd0348704e4e596be3b7d9c8	13453
1333	a251ee6e2b717bce702813c5b2eccdf9ef770ff631c5668b99e3da224625ae58	13465
1334	74c1a1feabbdd0b3a28f26b6c1f9cce22dd482829b38e3b85b7acf7f7c3fe202	13522
1335	a4066e19056b9adbd869e25790aea2c8469632e2844c15e9128ca304f6b20898	13535
1336	abec707e3a699c4911dfd1ea6ae2873621de5b380df3dfa2a8ca3f67be611424	13539
1337	bfe60095379c5746973791612c89075ef8438dcfebbb3237c026af7d03d74190	13541
1338	ae18b9232d205c94c5626e1683451f815d25fc537ecb48eab267c3caeb4719e1	13543
1339	51c060026137fce8c94b3af65e0128cccd300453ed400ae0a27e66fea4c83baa	13554
1340	28a59f5f7aaffbc2d73476fecdaf33483d610bffab5c345b6acc399a20335246	13555
1341	705a8e59e9b88f956a443a19de0318ea036d83f70202b6c85420fb78a8bbce69	13569
1342	c4ede7716024a56cfa1e8e79de19e6b6388bbbe1a02a2fcc5f2a8a3ff76dbfda	13581
1343	5e03248df71c9f546fc20f158c9159ce281f0fb7a64bb50842b031a8c2d5d9e0	13587
1344	a8970412d185dde42e31e5eec7284a80effa5365f9c8f8551b4eda730cca115c	13588
1345	5d9bfb6ad79612cefe340eb199ff6fdc755ed4cfc6e078424048ffcff3102d2c	13606
1346	ac879ad3c8e15fe937c5a524acc0c2ede5638d131d8dc6ad6b7fc57f237a001f	13609
1347	4f40b7cf21ca5e8533050ba12dc0059ed9fdad390ca8982473f7b54dfa09a2dd	13613
1348	dc5d87396153a2650d0205964e4cb95f139afcf2130aa56e49d2a567acb27a35	13618
1349	e53f14eb3f3efa07fd68055800ea23ceaa9cef27fe55cd52836fb272a89dced1	13625
1350	77ef494b5f249c14e92ca1603b995945b98c192583b60667da5f0a4af9615a33	13631
1351	41bc839a8fb7a7945b5459ce5c543e2ad259e37b285802102e8a955988325e57	13638
1352	badd9be448e41a5c5f3412f023fc4f6ec80852e4cd514705cebaa320c821cefe	13646
1353	4683b90ec8895add6e23c4744b28c2645b04a91ce79e266592bb277f18e8dce0	13662
1354	266dd5852f0dfe5108d4002d2667c22a766b0a1d03b5e00f967f2416d979ee51	13663
1355	4712c38963687c331b68ad46d9a0b05f2103e74e7c796f0c44713c2cc49c6e11	13674
1356	1eeed71e704061a33a0bed69e839060ce5402136e62df824e7a455b4a13178cf	13686
1357	da37208a9fd696ae5d32e4011cdf046138a0bf6085b98724259aba5f4bed1b80	13710
1358	393864939bba1bf1fcda3430619f1db4550cf19b3ef26d8f06f7205574b8ed26	13711
1359	2d5e3306f8480c5ff5677388c9311d969f779ccd1c9aee173e7d0c9983840532	13725
1360	f13cdfba9b41975d17d99e6a45199bc4a9b12d8b54ec12c21c855259f8adb287	13733
1361	38d34110d7ecbc842436f264d83852bbb5adff41dc12cf35bfed15a863537698	13746
1362	2fbbe3774c058d8bb33f16ecafa2448c9695631d99f851c49c6f4b60d29b5668	13766
1363	828157a613aea6538012f1a133cef584ab6a417aef9c6cdcaee63bf091c62753	13784
1364	0be50dc085fb0b7784c2a81f76fff17babf235c2cc42bc9e64da8e4a73e3626f	13786
1365	08c0fedf98427ef5060b0c8606f9f459d362d99d35ab2018faa8e37790ec7376	13789
1366	7e6648a94faa677673e3c6c4bf53bfc7c2084176d8048605f4a27cf9eaad3e86	13810
1367	4efba67410be39df296549699878546052d4f6c29e3c26fcd5567dfa61b8c39a	13835
1368	8fcc1b12d09d770784f62d62bc13ff8b5d4038f76f55b8b89c3d5ac4a9c03502	13863
1369	fddc8b973e6615016f110d4fd71cac6fe9c6b857c972ba141c48130cb3f78446	13870
1370	45c95c9b2de1d5887cab5d324494ca3240c53f075e95c88167ade05a8b4fc9ba	13871
1371	d2373505e0ed6bdb7d1ac826842df5eedcda52e66e28c0000d90c710820f9973	13873
1372	d21161ddb474b8f1b363205300ff927b99b81805ad1b0b2529eda04af99cfa7d	13888
1373	b3530cc9226fb647f8b31771a2e3f24c8c05ad87d347a9e55f069cf88c230f21	13889
1374	15b5ebe619e2be34c0e815d910f7350bfb9fac35879f7061c2bee70a32addc80	13893
1375	6125dd83cf9fd1327376821000929c4875ea7c7971aa0b6d8a8e9718012eadc8	13926
1376	40e3d93e1e14670b849240321f2a91fd731f31e263a10955e541726bedbd19db	13933
1377	8311202490eff06578bcc0df40719f46255053668655bfa4f0354181fd38c2fa	13946
1378	2a8b5d81e16e58203e36b8eb2da8518c16a6cc2d5ae3fc2f0aae685a662f4743	13949
1379	80037466d86015ade506b046257cf508855983ab4028a5f8d4ac9207a63d8501	13952
1380	df4be1769128b31f10269156217c6fde485075af4e791f7aa279b7edb30d89e6	13959
1381	59ffc8720b450cabbc274c9bf062a062d29415efda87eb66d71cac0324f9d3ab	13961
1382	6f4906bbb41b89af61fce8226e84f3b977d1e0d19db11d3744650b7cb45e3131	13970
1383	3c38d60517bf3ff3eff64935d9d92d5aff076990d17da7507a51aa039d02de96	13989
1384	66badec026875d13fd03adc324237083d8ef077856784573b66b4e9b9a8af146	13990
1385	e23ccfe72cfa917ae4b0209d9aba0f0a57cb00a1ac29197319bf0f6fc87c7f0f	14003
1386	2e1bd2c5a358f4d532bd888f0ccd51bd14d7178cc9a6e62fd253d0fe09b105cf	14011
1387	4a2d5194abb7e5b83e50d044eeac1d375bdb68cf352f75a88c4ba71e01eefb8b	14030
1388	8c3e246270ad107abf52fc212b212173efe56dc473a8643adb59ac87d8e78ee9	14040
1389	cd6665459574c858cca995b1a32d034441ddb0430d395953cbd5c876b2abe660	14045
1390	4d5628e52e3743dc6bea7850bb582b23e36590cb5d64ba9fbce06a3aae0f9755	14046
1391	126e862fe48fa68c69eaaff01e197efc2f2de9e112bb7396468049475ca7c35f	14060
1392	bb0ec669943c73c1c0c20c8dea8736d512d7e4c76ac03238ca27c4be01bbe4a4	14068
1393	2c76a4face925e3170328bc3ceaa6811f542f9f7b193657e1060494d338697ec	14084
1394	403c13f28253dc3a3726d0cd6b2ecac8c2b2edc96ec0902e7af0ebba2aedcc74	14099
1395	d6c4a260d2ac5369c50341d64ccd660a8c8375dea51226ce61c9022daf806284	14113
1396	23c7c14f9afdc9e2ca0030b7a73c3e36f97dc8d04723a9f8502a5b5a4230926c	14127
1397	447e5c31c9d20bbaf87cb947a1fab1605ddcf4b49d76e2c93783302f647c3834	14129
1398	cbb6a84e688998b64d8c446aa9d44c25f05a19a5445afc364c8918b9e7ce795e	14131
1399	1ce0576d8842ee5eaabe8d07e6f27b3cf64050f8ffac4890d72d7bb916b5a944	14135
1400	55e1ab57abfc6eb76274a91d38fb039daeb6f7466a05801be8d13394db471830	14136
1401	38ffeb0d1c199fcbd9598b0bb36279c2102d2d2ee2b57a7a25b97eb3f8ad06c0	14137
1402	4d8018f8de13391368a14ab42d64e140ae5cc908b1268065ee1a759b7253641e	14140
1403	6d265193671feb53213f5535c5e8e702f18d99b29f5499e03660e5002df85309	14147
1404	048711512ca08ad55efc3751e90302a894735a4fcf94929615a872f4e1d4ab3a	14151
1405	45954e1afce2f051c59aeacbbad6af6e462b02958bd36848f1b564cda29f4fcf	14155
1406	dc13f26efd361556307e86b70bc5661b69d9d4ad682a626ae43371612c0b9cca	14167
1407	55fc64421898ff6fd27cfff912850929986df91be6040a0b2f264fd78cc03942	14170
1408	132c5931954b5c021ca5c61556be1c46a3e31a57c46d09709c167eed2dbb9b61	14181
1409	03d24a94920d93e2559935942bf3cd399d61dbfa585ff378c04406aba4f4e8cb	14190
1410	b7a3baacdc3b55cf9a7242bc1c68cca057ff8a7791446caf15973db226e891a7	14215
1411	332a4a75eabd77009624bd75f0eaee33b2b6845f303bc26f6d0e6a2022aa3728	14217
1412	07ce8576eb2d875b4fab9b65f170d70e6f97b9fbc4ad3e020c20b31ca40b6659	14218
1413	c21e07ede577b9a5c38d6646f1d79ce4eec4a9b673f38ed06ae38712feae235a	14223
1414	70cb980d0458a207e74de7e72f3f40f5d5698fcace12685cf588a631d364115f	14245
1415	b4df8ca18a16c16687e2ad2ad6ac00617b75da7ea4a560dd4475c597c396e03b	14260
1416	f483a22363c74dba4d48a170f4a41b1f7729a8b8cc711c404730d8e7fa35929c	14273
1417	9a009324a5313007b70e51afd59fc9186c5c4b2f2b821041033559dd7e84d2b2	14281
1418	93e68b5c617e41e17249b28d705af8ca00c4daefe9060fd7dc1c3038f068c460	14286
1419	31dd3f3f4e2086df333fb69cf3190b3882055f216d7ac41eeecb4cc714f71bbe	14292
1420	aa3d2e685302f020d38774a11d7162ad4f96c761c5ae093cb792b1a5fee8d6b0	14293
1421	9c84da362880dba2adb9d64ddf0ede700c6661fc2d8214d68570065161a826b5	14298
1422	d1b5547a621baa16aa862d8c48f9b8d93f47b2bc418d1469d2629817ce3391ed	14309
1423	b0399690c78417ecccc4b05801db90b8591400e13e6ffb54cef23c9b741b0c4b	14331
1424	028e708767398a9ec6144aa4294e533d214604b9b5bab7af1d2f39fd928f3c3d	14354
1425	7121dbbf500fa5abc7b049c3cb130c11d52e80bb9f0a40eab1349b488d3e34bd	14389
1426	d12ee6864a9a4b1ef43d32f4fc7144f8a342001123f462ad4dc59b9eafec2705	14438
1427	9fd21805421f41836093ffa0b6ebdee79f6df1b37e60981b9c8233ff54b5a94e	14454
1428	16b028af964e95a302eb3f7d5286f02a0d3e8792e3bfdb9c1fd556921d8ac7b0	14460
1429	80b4c04ef9e7d6172ff6157b8bbad5cec5bb3f9518c22ada6915c72eea9d0d83	14473
1430	200f772f30e2a95907df37ebcd79c898d70be65884f9e7b561170c27e8048857	14474
1431	34b717a52bfb5be52d6e8518f0817e912f95793c73aa6698ea8c3baa35270520	14484
1432	1501f4fb8763183e95d86289a3aa4ed9df9504479bc6e82bf60a588ef72116a8	14485
1433	7892bd563ad41586613ba17b06ad9d3a003b5be97c4459e5269946a9dff84ead	14490
1434	ad9b81c61af1b4a50691f4ca9ab568f073912fc7367d512a2a62c2f0bfbdd1d1	14491
1435	64d6f17e972a5c552e5d092a27620c001a781af022d6695abdee0951e75ea675	14523
1436	ad6b420048d89326a6b6a37c3b4b4e0a42207e13242c03c29cf81ca50a815cc9	14528
1437	9b6724e60e0c23a18c60db1c204cc9d1cd414390b8da8f1c0bff39a959a8d116	14535
1438	39317ba93e477eb83911ffe2ab1f5dab528a5e82d7755e8e900ce9e664cd7d9b	14538
1439	f8e116ce0b87e0c691f48b98a2741e7a063f05cf11236c772056bfd9cecd2934	14543
1440	f48a4923349cc92acf8b75fe47c8d926e45869ea38df880ca53142e3fa344f6c	14555
1441	adff50c4ec3e5cb2ffaf68d081145e6f7e8069557b419ea0dabda0b6194b9d22	14567
1442	89f75dad25e8f692ef419d97d6d7296aa353bad7387ec1527ae9d6bea228b830	14573
1443	7ab183c8f82df6c8713f143f9f8cf5622a1433a26a894381234590e7e64c29ed	14587
1444	addbde111be187a84e610976e83e2d6176eb0be0c757f8e96f025225a302f013	14600
1445	e27feba20a3f5d2df36848fb9331e5d614657eadd94dfaa0f9c770d58b449179	14612
1446	66187b0052123345ed1288a1c2cb2645dafeceb0261121e8476c4dfd8a6af54f	14632
1447	e97ed66bda7e5bd6b76257a76dd5f4c478bce3aca945a654da0bf898d720212a	14643
1448	f5c594a3238358461e1e0f605e2615aa206251a18a3ca0fdcb66e4c0d1bfeb4b	14645
1449	07efc8e6f194eef6714b53f9111819411654c5d34b4624730df9281c178dc885	14662
1450	866110708c44d3fa02b601fb41d81877e08d3bd68fad2c50d0e06dd742183936	14674
1451	a57cc5142e0d6483bc0158c5826ca32e913afceeede0c154ccbb47fcf6f93407	14689
1452	0e2002f76a3c4d0e7e08a0174944dd45d4dca3490098c9c6b7e09a9ea4699d8e	14698
1453	f0cdeff5c157510bf9b6cb7ac71e45b07233046e9da6282d13539cba5ad20994	14736
1454	67b0f57773db021f675d9f547a625f45f69b8d9e7067a654787fdbf950c8072a	14744
1455	34922288799f7d8d53eeaf8e9bf3ecadb7ee7aa671165c52b11c84f6dc0cdc2e	14752
1456	c259a6962e691910400c7636f3d86e43ffa985ab57136fe0492d7d677d067b9c	14754
1457	dfd73a6143178fbc91fc988f2f90007fef612f385fe312aafab3a3e54d971367	14773
1458	ce187d09ce11730a7763c296c4d19e5cdbc453104b092c9212d706645385f8a7	14775
1459	6f9c06fc49826458243500033f0c9543630a8a9953bb7d03126469b6549e6e33	14789
1460	324becfb6430ab21c5e3ad7faf63cc240922c81128239c2baa1af9151c969cf0	14806
1461	151c024b2e5be1e802f92a1363f51c98f621e4221a164b331ae9184e31acbc20	14813
1462	6d5b9e8a98506f2a2ff35ed0e59b067dbda0e7bead8d76e671dbfd145f38f60f	14829
1463	ceede4e1ebf0007e0ca4b1d2fcdcb70845c83c1daffaf723e7260128834afb9b	14833
1464	4b4ab842cf26a1de3a84c267a803d4e172ac82cd6d38e303f38acee0fb1cdebd	14843
1465	bd53aa8c6af186b782ff988c7105b169944102b56d28c1aa7bc2c12a52892a55	14846
1466	3c6c1171bdc8e8e19fb6d2f7bf44fc592ad2b3dece086e55939dfc1ea5e7c976	14856
1467	cb3c6c5329d355fcbfb8072cdb6a19f9ed3691cad08a9b0112c2ba2bc10e0911	14860
1468	68269ef98330496a90ea793e8ee9f4ebf778473623d8932928ecd05de1293898	14885
1469	5a457622c9d0777c0ba33a57d3fbcf851dc581a75cf8777768415a51979e3ed0	14889
1470	70a67869b929229be289b154ebf89a7eca50c15463c217e50e6c89512ed97956	14912
1471	5f3c4c7707d92e84c58734ebba7a27111faab597aa602cde8d439b76a63cce05	14916
1472	6ce9e7168430d883a2b10aeedb1a179cfb9582f343b21d1ac3e076e280bed03f	14924
1473	471a725f085d5d3af539c5df864669ce50d047e4eb3d044875d650a0a13f523c	14932
1474	c4bdae65a031dba3f8d2817778c65fd14dbc3cbeea65fd4b2f2c9ac416b6629a	14940
1475	28f91aef67702d07031dbedbf2df33695f1fbe3d68ed63972ff16baae0f85e49	14947
1476	d3f2ea9f16079f393a85f6e658c341ca04d65e8c4ddbc13b9520ab991fe121a3	14958
1477	7f31f8da3a2cc6c48d521164a3dd18141ee85085fec688a2c985d80711b63b4f	14962
1478	c29c2457007e70da1a1961f1c7f1ec186a1d0fd949a68ba8f653f01937a2402e	14998
1479	60b68eb821f8c217e4dfe9e79107ae8d77f3c8f4c66fb3ede20bcc20f4b34dbe	14999
1480	fd1e20c93668f825ff3e824e6fcfecd48711586e622380544694bc18bfbcc29b	15005
1481	8e1f856944312b636ab63fb0b661d8eba797d55dcd5cdf7f6b5ad9fb19a66552	15006
1482	532f22c2b469ef1f0c50852fa2ea37937c47348030c93be045dfbe83ca52bb31	15025
1483	bf2f819642b73ec0329cde3ea74170e0ff6e29eb6bdca2a6fc7c1043777d121e	15054
1484	ea26cf55c5192de9709b6fef553c4eae19dea320087f45d688b1e606aabc92ee	15072
1485	b4c10affac9934f62517effb200c55d20c3d8b970459f63f09719f001e569831	15087
1486	7a5f1dc38f1e200d96cce18195225780cfac7e6940a41aa75bf6262eed52a538	15098
1487	c0e8c10c1126a89e9fa50388aa2dd8c687aa558955763e3fff0b3ed73d747937	15102
1488	8b95dde8193bcdfb0d89f1b3b7f8ec92d1b416b9eba98f533857444239585e00	15106
1489	4aef0555ebce012e388de296d3f29cce14e0624c537747969fbbb53ea234139f	15117
1490	149224485934b327add26d850acef14817ae697ce4d2da5dfca23e4a4216f724	15130
1491	9f9d28eb644f1fa56cdbcd911854e3bf1d39e7742a644bc510b8daaa28788e52	15166
1492	ce5b62af8827fcb2d636d9aee5e778bbcbd3f80151089f9041dae164ba6898c6	15176
1493	0ba8cf368d25b206aa7b3941979e36a21c12f355edfcd804dca0edd01b5509eb	15182
1494	f6b959595511fcab05f35a3d6713ddfccc4ef118a46e1402acfb54df84e728e4	15184
1495	9882f537af5b87fca83b5d78b1a53381467a4cc606ee6ff492583deb29739753	15201
1496	36e679484ff3373bcc7d6799d9ef1753e63d213eb97bcd75a5ed8280212a4459	15202
1497	cfc207a518dee722897b3ec42ec7e5b4fb7d7c1f75bd8d37bcabb535bf4acbda	15212
1498	31c9d98a90f3883b9b53bcfb90a51046dc3c956299b7342ae72b5f2ccea9d8c7	15215
1499	3fc8dadbd5c714e1e56eb2f5f6bdd2e8344d72eef2f5eec3eceb4923ef61bb32	15216
1500	b4b9071569b49fd4d27cc00ef70ffce666c56cd49127759123fdacb141480caa	15219
1501	89795b616da2fd7a7b5ffba9de803949c2253ab7f4a58e45ebbeae56ee54f022	15238
1502	c67af7a98d4d4eecc6b1599f0c00dab85face035331d69957542bb735909805a	15242
1503	5cbb56cb6f0e14ce3aa53621a068ca23b378730ba5820cafd9a9b579d8f4cdb2	15243
1504	2df204329420235ab9334b5cb80d0e809d4dc9955776542c79b2105d25840e00	15247
1505	04b825ded6587915993c90bea6eceb25bc437ae27351886039aeb9ff4e0f64e7	15255
1506	6871763599f1c7cd538cafa5c87d9b736c26b985d4986709873faa398d0cc081	15257
1507	7a0cf4016644a2b71923b37faf56f724bb74b969fb976f63ce8d240107588dfa	15258
1508	5973eb95a534964b0b3a779e3ccd6069f4655e6033820a68a9d224fed589fdce	15279
1509	a2e6b4e430a101566637ecc6562f1d2cbfb1d13df7b9608060d26730a6f39467	15280
1510	43c509f1258bc63335d734465ded9a63d56db327437cc2626a537b879c42027e	15284
1511	077c5beca0441e420ebfc2f144ec014418982e078bfb249700bad4a09ac1d803	15296
1512	faf2f92a98590810436a5885cae2467d247355375f20aed18847fd47c60358f9	15310
1513	e51ad769a1911eb6fefa27c13e37a80a33733cb895e486c896d23890d318f91b	15312
1514	c95a1a46c79d84eb682de286b62bcc281b182620b259e6ae889dffc90e5f9612	15313
1515	19a2f30cb56a7e31238141117fb9cc3d9da9f642ce845b654a8649d5e2151368	15331
1516	1d212c977c3c376764689fce14df255a5c2ba6c962cc215160a3cfa949deae20	15345
1517	ec67a014619b204ff8c3a6297711340dd58cb486bee641cd66b335e3d00e7cc3	15350
1518	b74c0ad7f7daa1c5117dd8652ab60150c05205f4a70fa8b685226a713c380760	15353
1519	5cc3975db706f368d74bfe9522432282ac36abae970c19115b51ee92633aa5ee	15357
1520	84539f0cd9a252098b941fce82e40daf2fb9636a3e3f143fb721ebb2e50da43e	15366
1521	6580f4c5b04e10b1f0b7986dda7bc95737e2cea2b70d6fdc2f164c2dab44cdfc	15382
1522	24a94d97cfe07b8e79f3c4ba3aad6e787d1042f953bebf0d9eed058142f9e3dc	15388
1523	50db55713c97a112603c5dbc9a404b2a50ad30dd584efe8b541b044e5d06e03f	15398
1524	50ed39854f5c8a78b55e4dfc90313f77fe584c116a72441740b3abfc1ae3300e	15406
1525	1970844289ba3f42d008b4a66474de528ebabd11ee7ba715b1bfc4c52ad686aa	15424
1526	b1fcc650d830a4cd4c335e548cae569eb6fa9ee363bb487f7cece4d84666b873	15428
1527	eef176cd675a65faddaf4eddb48a94a86b6c8a30f388ca85efb412cb09f6beea	15434
1528	309ddd76d87f65ed392e0a8f5f0b0774165f589b812b970bb11d97ed0c6a2225	15454
1529	02f23ea8ccd2b2fe00995b5dda16aa2a2eafb019ba034ea35cb3d719baa717f0	15465
1530	a4cf59c4ceb90ddc184ac807fdf9bda526b45195638d9bfa73da92da247da8fa	15477
1531	50df087a48f4e12c08a0029ac657d25ee6c0835d3618be1f7acffd3e099148f9	15494
1532	12862c8f81ddacfa27fdd421b8090bb37cdeac199ee7f1088dc2a8bbfa26d7d7	15498
1533	209f61f633a0de09b5dcf2ffa1369114a2410303bf20a04c4a4c22d558da9a88	15512
1534	7cc9d5710e1c9b8c2bef5c6c7debb3c2ca3e6ddae93aec3d128328e915d709c9	15526
1535	01855e31a52309ae7621ce8509d8e8988e62cfa8c54e8630de6d8ef8eda50988	15540
1536	e99589da0b37245d28027615c455ae458ba4e9c258ec0a80322ec5e630aa76c2	15570
1537	ba1ca2cab075ac88caf0cf1cfc73db19b2b2f7f5550000767c7dfbd9f92e3579	15588
1538	9c64ba163cdbd583dc1e52b57afec6b25b2ca2047e6bb06362f77c2bf5130eeb	15595
1539	1e30f6fc0c988c3d883fb56ef2beef7dae7cabc94f1482b76d1957e4c3e0232f	15597
1540	03fd7303ca3c76359856a52343fe4859c915b3b030979166882d9f20a1b03005	15615
1541	6a38042908eb46fb8ba8f1e61c4a4905a558b433d71094e7317c924ca6d527de	15666
1542	a4d77792373e5d6f5ae17c7debaa6775c4d041311bff907cca982e5d5156bf6c	15672
1543	fcb3363c493253a499fd6302d47635b255bdb52e98a55e7965756c6513ef6740	15685
1544	3f04e64d161e455dda9eacf8f6917d7283910e725d5714def5648241818b3b7a	15690
1545	70dadd49b865c901e08242c11210674a724b6852268470dc767534fd17a1cb1b	15693
1546	2c581e938a522f5dcabeca3ca768ee6eab5cab5df2577bec5e974115934c62be	15696
1547	a09b47226f23a7744ec6c38ee35197c7ab2f9f58e07102307d6ee4644cd28aae	15724
1548	4e0a07f498b7480215b4ef213336491cf51c9eef7e45ee702c6a86cd1a3da44e	15789
1549	007d927783c9ca3c0eda077251bbad3a421f8813d9acbabd4a94bd1436a7e82b	15794
1550	60c5d594b28bbd848c761e662efea60c6975ded5145e481f5aebdc97adabb2d8	15807
1551	b0e5ecf5d0f936f7da4a9372e107abde7fc690f2871c8c4b4bd05bb7d7aded77	15821
1552	46ee0fabf7fd361e1eef3eb9e6498e8870a5d4fdeabb40c78a53f560a55e9f26	15851
1553	33efb5a7b0e8c0ed328540b8dda56adb4a449843eb4c9c91b4d6a94712c85cbe	15852
1554	97466c7938f3c2101d24c80ad590cd60ec014d73beb0d66914d08f8f83c0f383	15858
1555	5810c68953d0b196eec7c623d930374119e486e78f57185845a22bb8b2e1ff97	15866
1556	392a25ee385825418cef1fd1d9739b12349543ab84c2045a17fb9680b4758e6a	15867
1557	b46dbfbb5b8f3d0313ffdc70cac51901fd158b3ad4bd841341b78c540d7b9792	15869
1558	4933d80e05f04c34ba03bfd2fc1a1cea153cf7580c0ae3f8c11b40547834c1c5	15887
1559	afb8fb987feb873c0a66ec8678c6bb40a71ef4d4fd7341a8cb23445b2d05d867	15891
1560	41284dbfdf4f43d0ab0d0b102fa3bab8ad863062a03df8e53b67cb21d0dc5ef0	15895
1561	74eea1b324ff6d1c9a15ee5ae1a4378a3733cb5621c29e01fea9673eb1795e3d	15899
1562	05fe339efcdef6dc37424c32dac0d33a5576bd3d8432ea03b71b549d40f7412b	15905
1563	73adccde832ad34874a9d9f19c38da5b5fc4cba29241a0e4deb678f43992358f	15928
1564	29fb338cee4aee71fdabe0b1be523d896289caac6d7d44d61e2963b978c7364b	15938
1565	a30eec7bcc917617bea0a6c958701fdf060c6f4c9bb23559cfa845f4f4ed33bd	15956
1566	779f908a3ed1441c369220f4d4a20e3fd633cd9aff5d78a2d3a65fd2bcdf2f73	15960
1567	a514d8faa2ed7065988227698731161032951106b572f42fdca1ecef571f7a2b	15992
1568	0f963b28cb171046f8c7caf5ca88ca7ca096d2c106b84989b9804a59e5132170	15998
1569	186cae1456f2e0c23cb9dee789f842795f22e7f1384d1d47cd20b8d24512396e	16011
1570	bc736c9451de8494b8888929f135d290f1ee11894a2da8c470c8edfcd0076041	16017
1571	009d6c1b5d9afa284046e4f8856cff27c6ac784aca54f9ccaf859206761cee05	16023
1572	f8b83ef9a2d4911ce9b355c9d5299dd144c1b474d400ef02898a7857716c3b27	16043
1573	5e441379ef23b4c2d6d8400643a573762667451c8afd1e258882644d35a2b818	16069
1574	535f13de8547e0af5cb6897a5eabba42aa1eb111207ea114202080cdf63ffd2c	16074
1575	4d35027b3a326d01a037e79fe89b2c24782792815bebea31767d87de4d8914af	16090
1576	bb1a3a95a9e1cf36de151a660a31b93b3c2c26e6231c65cd0282b63cf45b3066	16094
1577	546eab3b8d420f19942712d71d87ca07e7bddd63792d513c11b2931c6704c43c	16097
1578	e05eb5a0e241d6f8e7fff5e84261b3662073d0e018eb3d16926f7231e5c76934	16102
1579	f3d57ebb16856f4fce5638a14fe1a24ff541ca35faebcd67df5fdcd6785032f1	16126
1580	5a80e1ef400364c7008d5a576a2babd46d1b5ce08430dbef7ec4e97e5c9df944	16128
1581	fad3ec2ecd37dd7c2687a34fe0be59b7ac2f9ebf44fa2548130509283727b645	16141
1582	b5ea8745bc02e9936e1c9879f138feaa713c0dd6ff033838452fae582a66b735	16202
1583	dcf55a3470f9a9beed30e012dbc74272e8f2e7161fd0751334e7a0654e2d2c80	16207
1584	191794cf1e9e16a44383b7a1d22d8d83b8438123965f29828ef961f5b49582ad	16209
1585	b8f1f6e6310a9cab7f2d191af89e52ba4a08417f7cc5cd8a856a1e5500f5de3c	16223
1586	9fce7f41088e37e0365613133ca95dd3f03e031b666c4141a7676ad7bf668367	16240
1587	0df44ba4664cf5eb6283c5957ede7d9fc9fb0825293cae4db1ed151b220f998c	16246
1588	27de7090321bf1878a370cecce67c40e1c0881e1c5d2914fe70105cf0d570957	16286
1589	51c528cf50fecca3dcceff3ebd1a23ad3c88cdae3205b57aa64d634c5002415c	16291
1590	9f7ca74af2973c2c747f3b84a9e9bf326a59bbe57da47f7fe35ec664bd4ea365	16293
1591	bf6b546e525f4df86ed079664bb2d10e87c91838c967b66cb2e08b2ccebac813	16303
1592	f4ba3abe89b3209ea65d788f410a26e067cbbbc4e61fd7db8c39559577ccd371	16308
1593	2e25129f79e3ba002bfb8a89ce05a23975e053a6a60b4eae97d61f2b024c278d	16317
1594	0317f8b15e2b6ba3c379353d2618cad5eec7a07351b74bdcca8240c5e8c7173e	16321
1595	f425f19ed1ee3fd074a9fd94c985955777e6f796528cedf886893a18ce4f74a6	16346
1596	1ef353f7fbd14a63ae1700afac50bd98a79f3d064c4af11bc9b072cdc23a3fec	16350
1597	e619a632ceda576ecb3e0b14d87defd604462c5ae0995c914d655f089897ade7	16354
1598	3449b116bd2ab60efa33f4752cb6897f116abe6a80e7b6687d0617a36815c310	16358
1599	b771e932a402924783257d8bd8b3973bd128b91399fd94720729fa7df7522c0f	16364
1600	fefc5fdeb8cc9f5a9f5f054a532bc0ae1d5b6ba8443467ef5beb09ec1e21876f	16378
1601	f15f9851714db8c5c4aacd151581198ad57edc855a9ebda0854fcf0797e4a640	16381
1602	a73c2e0f9b7c1b6990f543f5b5f0bcce92bdc37d919fcd44d0d7bebf5bd6ec98	16382
1603	9c670627db8503dda28463d4c5445bd00dc17f4ff1d1f96aeef5b20d15e9fade	16390
1604	1f4b01ae6878d80ebfb2353f9f91cf012c31baeb776d3b5e724ef2ba9601b307	16396
1605	a2c6061fa32d1f81c2d6d92ec450fde4440e2e97e5f978e2539ea16352379a77	16398
1606	dfa1090eb536f059e239f6abddcc0ec3388f4b2cb90dc756cc9e450751b6afb6	16402
1607	23f0892ed9c5a7eaad4363dac6889314bef566dbe88ae18371c94ec7df0531be	16413
1608	1f9453e91cd4149190188498e97ca97ffb821a42323b0c0340eab96f43020aba	16415
1609	51f57174b2c129b1dc1cefe6de325312f4166c21d9047d7c0c898b067c6c63ff	16421
1610	33f59a69197d1f6a64e5538880d1cf58af458350407f38e6995c631aecc09be3	16423
1611	92c41b65dbb608cc753ff2a36c0fb1febb298245cf011aa35bca25a73e916fe4	16445
1612	435e9474b37b21791c33a02f1d155b43822266980523badc14086891c8345c5a	16450
1613	36dd9ee4921bbe95ced4954c98b17fe2439398e58432eea481e80b88a3bdbfed	16462
1614	22866dc118abd02f419a1b83f729489b322863e963654348a67584c7725261a7	16469
1615	391a24ba98fd886b88527b12588864952f947eca216007085af50d803ac45ce8	16470
1616	0036ada30db85a3098feacc026248b80f70722820bd54ca5911b7e6f0c95263f	16482
1617	73a88434793aa82a915c4d6dffca902919e448f1e53b0477202b8766d7d53bdf	16495
1618	909c06bf200d740849a9a9aa6d5fc0e53d49bbc22cab45fda31b726d17c20e58	16502
1619	8e79af2947699927b921638a359d389715bf7925efa74ac68df054874f707761	16516
1620	f165fb3541b784ad46c17ab60989951cb534a948ab1fba4d1c05991df55722c1	16529
1621	02f81b5508b5bd7c2ea1a66fe9f268d005fe0b54833374e8554a26d6d5357b99	16533
1622	48876c1223e3dea992a14222d96b012713b615174b9af554e907cfecaa115e0a	16568
1623	9f80651fc45356142c680b083ad3ec88dd43ff8316138803135f38dc31bf6a17	16582
1624	0d6bc63c5f36b81d86c8e462b463298e8c527f1b5b3b9abf86b66032cd339574	16594
1625	9be4143c33348745afb53abfc9916e25d1ed743d26888e33ae953dcd55227a94	16597
1626	e16e7eebc6040b51cc4b78882d7bfa5c75b0f1bd0aea249a2341b7fd51236676	16609
1627	a17d9ea3de90101f9c7729458110dbbe6dc4fbe500c1bd1f5396494e5c327f9c	16611
1628	9e0735df307a92b596d1bbf0ce5be9ac485aeff2eee7ef0de1acb2ea30b1822c	16620
1629	b582caebe6ff10dcaa4c46cd4a29e70147a18656364a8808c743638057a8286d	16622
1630	597b027ac09a448c3c9e1e71e53c563049cd1b160819b88acc2cc5b691fb258a	16625
1631	dfaa275cf6529bbf1094fab03e02ea1314a54a9bde12829a5292b22ad2b3699e	16635
1632	a73deabbe37bc0a73c61dcbde2b8a1aab65972f7b688f40fca68a6357c73c40a	16646
1633	e204c20ca18e26a3585c10a6f71e57c476c848766a032d057c8ae0e463c37772	16654
1634	12895a364d5d5bea23ccbd92dda32669de62ba4e605c96b29ec75543428b45ec	16659
1635	de806a2d4c5a0c42ca0ad3cce3f3c55c1b8950572fe0418513bd77b54de71285	16664
1636	cda5ab97f3ac49cbbfec86cdc5152a68a7b2e86ce85d20b062de57394a83e425	16668
1637	e18c8bb78b61961c6a0db462dcded5b4db35a1d5e075a7ff81eb7f6d7ae354c7	16669
1638	7a784cfcbda6f3caed5dea60263f9d4091c45d5610beeb0bc75e92b34a99c9db	16671
1639	2ff533ed1de1edcedde12867290e6f0d5b9eb091da51419949bc3fcf1bd202ea	16687
1640	936b7b0678284f8ddb4155cefea35fef6a5172698a397c6bede04858a662100d	16709
1641	f7a10fe6936e1f39dca4cf86338464bdd59ebe8a15b5f61a1c375ae27c047b4b	16732
1642	4a486fa19f70bcd33f3c76d2492ff94d6a12a8c98b8686da306e6ccc0677b56e	16741
1643	83384c9eda4da9613faafdb2c3d0c29150726f3346db3327c82d1f15bfa2ebcf	16768
1644	bbbe2d0cd775d5ea95464e37af3aec9cfe3f42fed3a50992e143b22d26766a48	16773
1645	0115fde49a1dcf9daf5f4f8cacc0f2d3f7f98eed1ad816221f8dc89510079ada	16774
1646	3c5298052b98e63cd12a7299c03fc457e2fd4583ad3a2ec990439f8169a531f6	16778
1647	7373df921f5e8fe2746118ffd15b066bb97786ba99c1ad6e77cb2f38ab1ab9bd	16788
1648	ce1b918b92efb8da95209547e370940b37f0223b3bedd12c867da60af2064db1	16792
1649	c7d972e3a085549ba71d49c773b11c02bf8b0bb0558d1fb5b859d9045727d463	16794
1650	acf8e3987d7e793a42f8e62972479832ab2aeb953baa173d2eabbc000ba9817d	16797
1651	c528417df7225c379c4511c09f6725ab2cc7d08b2a692a65acbd2404233c6bab	16798
1652	67faf6870fc8a7ea1d5564ccb28de2779f25e5e75607652121eaf24195e5a59f	16799
1653	232f3b9416f575c506f1ad82d0c9458f6d23b918f57a365ace99dd9994b02395	16800
1654	1685a47f2190eeb7540d5d525fe48b9972b8ed4ff3240c3f1eb4618e093e465a	16808
1655	4c936061d217a9de7e634cd5e9403750d95f73e48cef612c0dc7a61caaf39f11	16819
1656	7a29a7c014acfac78c96ab27ee50ae1bf5f0d0c8a722b4fed76c3598b10fa309	16833
1657	78e8da286ffb29ec2e48be4413868a28633344a8f6b8032254f1b6b5862e49fa	16840
1658	6e1b123eb8bd34cae1174507c49fc365ac83f8047330f64af7c4a986e435319a	16841
1659	97b5db47a6331df30b7059a4eac64e50d4ed8343688b1cd4f2942a6a4ab70f2b	16849
1660	56dfe8aa33ae506d8763162ad37cfa3caa6b258fe63a30fdd25dbed2c431bc6a	16860
1661	f603bb9eef5f7c469bc06cebc9d8a68ce13b28145cf59253a6e84dbcb20f940c	16870
1662	d32a26109f1b8054babf995b20870ce01fb0a62e9e0adeb19b5aa52593400f6f	16882
1663	7725daa4d4c31f48832f64bfe3a45bd685f2ac7850ce73a7b014768f1f8c68da	16885
1664	c7110108e006ef0b8ecefabc8a1371d2a010055254eb691aef187a1ade4c5698	16891
1665	c3712b817f9ab927f5719e6df517bf0a21d3a0ca3c9edee5a81fa6801c9916b8	16920
1666	4b015713ad7285d53d1a5c6533689025d43f3cfa1bd3176cf27a0d4553160057	16928
1667	46c78602cc5b0573dbe2d5c7dcd754666a3c624ae907b58f72f80e5bab10a23e	16946
1668	e7ec1fba5c3117ec4e0e81adbcbe2f7e3b256ed81827eead17026b99f1632ab5	16955
1669	98413c0d856feb83898286543b3ea3d6bb49438e684dbea404263983419ecec2	16957
1670	f44ac7d54fc6480f7726d4d0fd225a80dd2f0dc0c46a1d18ac29579173059a87	16965
1671	66db7986141d5bc3bf73ca192059bb388ca2011279450665300f5b6ac90033fb	16966
1672	e2b4741d432408a4c8683467b6c8ed148191d43676df5d29454cc0bbc92ac8d2	16969
1673	b388a25e178ddc5b944dec33f1fdfa644cd3363ae7dc77c62d3d75bd2294c0b5	16979
1674	60fe9ec3948f64d9265d086f78b7421cbc372a535c1197216862d0955a0fe9b3	16993
1675	cda1261a4834ffaf94579159d29ada77f74d48af1cff746919c17cca34bf027d	16995
1676	19dd7fd717e36328bb47212b537eeacd605e547ad0bd6b59ededaafa502bcec6	16997
1677	6d425e12c6a182bd4a24fe9736202ac18cb801809e6362c7a253108690976f68	17000
1678	884b143e7743e462ac56e8ff00927c6a441a5c1a1751d732e8397bfd5008618b	17002
1679	3ee2b46b69e4f1859e1b2e17e95d0fe09e5e700a5a2f095e950eedc45239532c	17022
1680	a382bbd4759885b97708b0ab5b4f34777730b6657391578948a7b7d8c6018ada	17040
1681	cb1d737d570e5b48eee4cdaf8a50e93fab3c8a7e02bf2728706bb13682479f3e	17050
1682	066a3ff8f08374cc512b272e4ab3ae3075e7d326c15eedc25dac9d5d66a8871a	17061
1683	157f7401c5048ce3b5e226a17448ba424c0adc128396678b3a40bb9d07630a98	17070
1684	97088961b650b1ff7651096ee25c0dede5582c71e30075bbbb5cd1c2023f89f2	17088
1685	706391ecae732f33286c397843612773f0039e127709c4fb86e1d14dc137c10b	17090
1686	4707ee1f8ed57788d17869877a1e208217620a24634141a4e3262ab47c5f5fb6	17092
1687	07ef78726f676e9801decbdb2fb77fd782af5d2567698b11c010144695627237	17120
1688	eb2799e644563997214b223dc770efd1682860873ef7ee6cef907c740a850d91	17127
1689	272cab2359693e63312e2771a82f1899c94b4ddb5bd20b8ede9675adecea6686	17130
1690	6ad1d5a0fbf3cd8c4ba9b6d6e755e2e331820b9332cf0f21e70300784253b7cd	17137
1691	1f7b85abc80c30a44955bba70f06ab05f27537237e24c2a6010c7626eb1ac765	17141
1692	eedbdad39a331a2fdf291e9c47c51c7b043168deda8fdc1c6ff86eca6ef4c775	17153
1693	f20ea3328d79e115f678880a12251a81f64743ace85af0e8ba0fee0cfe39c6ca	17155
1694	acf730833735cebf0d4a2acb40c6b4b46a0bbc61aff85a559e9729b2fe1d19f4	17168
1695	73344b76d1a24202fd8adfd3a2508ce211f6a467c47ef81cc9fbf2011acd1e38	17175
1696	b467612ee1477ad3a50699b97a3b6642ba0e95187bc6c4c6aef20fd47cdf113f	17178
1697	fcc8856126a72565f694f20e2025953708eecc009792c330104cde642e6737a1	17184
1698	fa714210067a50d36656112b5000c4d5a77e39317b8d47662d830fd76dccf60e	17197
1699	20848f768dfbd927f35fd5dcc9c5504b134921b43fe32414e2c10b86af733998	17215
1700	ab9478234b61a863171d413735137621410778284cde1d13ffe5c9edfff43f21	17224
1701	654a20b559cc42ee0aeb46a565b01485109abefb668f91af91ce3107e2a5c146	17231
1702	179000bd247be91011d2424363f69302d23899afd774ab17aa5198ee02949db6	17245
1703	b21f58b89be46a47b4503a5de5e0609a8571e3dee955ed5732ae6e75836c1c56	17253
1704	22cb3441f1b8642ffe239cfba2055b522b4fe7e3855be0f4d8f07eea28582017	17256
1705	f3b5e3ea395433b5c2c251fd5b9270d39e9b86ad69d4d47b9b38ed75ca793804	17262
1706	cfeb0bb4b68155630be9bc620457513d0077d6c338c5e006493c82a652a4b2af	17267
1707	95c92ed4babf279345d736a569a21cfbbe6191a2f11dffbd4334aa409a494e43	17281
1708	9fabeab3b4645e3a2616e8da13e8d7035ce7df7ee1bc5197b5807ed9bb88c7a3	17286
1709	42f13fb76e37f487fa50d7f47e95f23404fed1330474d1ebf9d76227d0719961	17295
1710	1e8eb5fd22015854d8f31c5c53e522132b05d6df1ef94f947c0f1191fdd455bb	17302
1711	a37380f72f06b2a4efbebc5dec634322adeee5ec50e5aa14b563df00c8fd6a31	17307
1712	9b576a7f8751f59a0c9c12678e2cd4bfa5f3c8f7c3231b4b74806b2888ff643f	17309
1713	c9071df2430f844ba3f1ce8057328689f238240618e322e14953d004cb561968	17311
1714	18d54c67f1ebfcb0e6fdbaf852d2bb3b0faef9c491829a7a0077775bf73bd794	17313
1715	653abd9fa256a8d1de9342bbc77e915c3adc412e03d356de560b80670727a186	17315
1716	f271c78e437037b36b15a2cef28f67e62db5b357817636e3bf628840f7fa7e31	17322
1717	1dc8d2a23c803fe2197e6053d4d68db87d4d33af98d141395563d95105928dbd	17327
1718	a7c4e93944f358359a471b37c96b46e159189a5cf08230715d8b489249e8b406	17333
1719	ab18de6e2c0f6d8da1995e36e423c55dd40871406b0751f1787e4307de56a8eb	17338
1720	bdd39fa218c02f82b0889a0a6a9d76ec9c47d4d6a5cf56865ac465cd415aceca	17340
1721	d4c8760966a5586fa98118591ca862edc266544b6714d5ee6d0e425cf0f2970d	17341
1722	16e7bbd4298897d73327b9f9055cbc3cf97961c6c4aa16c1eede0abfa4496692	17344
1723	12608ceceee8851e6aa1a533f79467401223f1f195c4fcda89f926d29e535970	17349
1724	4198982cdee03e13ec7e9f69e6f06f02dc00815c0b3ad03716d20cd2fdce7f29	17353
1725	5d941f00eeed098b2a4baebf0b801b9783b8bf20aab64ca16ec29f8643ac3cea	17359
\.


--
-- Data for Name: block_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block_data (block_height, data) FROM stdin;
1690	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313639302c2268617368223a2236616431643561306662663363643863346261396236643665373535653265333331383230623933333263663066323165373033303037383432353362376364222c22736c6f74223a31373133377d2c22697373756572566b223a2236343264373439656331393462373637316665323937646161343537623035323133313163363037323137386466376165373833633261636234653162653664222c2270726576696f7573426c6f636b223a2232373263616232333539363933653633333132653237373161383266313839396339346234646462356264323062386564653936373561646563656136363836222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3133746d776874667277366474676a736e797776646c63776c35786a32636171366576717773346e636772787178656371773270713265776e3561227d
1691	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313639312c2268617368223a2231663762383561626338306333306134343935356262613730663036616230356632373533373233376532346332613630313063373632366562316163373635222c22736c6f74223a31373134317d2c22697373756572566b223a2239643864653731643430363862316435626662323566306532343464393535323134353230396561303236353131613633376437386561376235333330316564222c2270726576696f7573426c6f636b223a2236616431643561306662663363643863346261396236643665373535653265333331383230623933333263663066323165373033303037383432353362376364222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317974646a376d6d38336438376133643874727873756571686378777770746c73326b7778347264733638756164377a6e65773271356a79656137227d
1692	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b22626c6f62223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b7b225f5f74797065223a22626967696e74222c2276616c7565223a22373231227d2c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b223632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961222c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b227669727475616c4068616e646c222c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b226175676d656e746174696f6e73222c5b5d5d2c5b22636f7265222c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2268616e646c65456e636f64696e67222c227574662d38225d2c5b226f67222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b22707265666978222c2224225d2c5b227465726d736f66757365222c2268747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f225d2c5b2276657273696f6e222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d5d7d5d2c5b226465736372697074696f6e222c225468652048616e646c65205374616e64617264225d2c5b22696d616765222c22697066733a2f2f736f6d652d68617368225d2c5b226e616d65222c22247669727475616c4068616e646c225d2c5b2277656273697465222c2268747470733a2f2f63617264616e6f2e6f72672f225d5d7d5d5d7d5d5d7d5d5d7d2c2273637269707473223a5b5d7d2c22626f6479223a7b22617578696c696172794461746148617368223a2231323461306263656630393965636233363831303065336632326339383664363435313066623435373637376666313237396537336166626233663633353766222c22636572746966696361746573223a5b5d2c22636f6c6c61746572616c73223a5b5d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313931333733227d2c22696e70757473223a5b7b22696e646578223a332c2274784964223a2234343562373464373464336137363266636339346136366234366534373962313830643732616431373831303132633639653736366535343334626632653132227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b22363231373362393062353637616434626366323534616430663736656233373464373439643062323566643832373836616636613833396130303030303030303736363937323734373536313663343036383631366536343663222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171707730646a676a307835396e67726a767174686e37656e68767275786e736176737735746836336c61336d6a656c33746b63393734737232336a6d6c7a6771357a646134677476386b39637933383735367239793371676d6b71716a7a36616137222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b22363231373362393062353637616434626366323534616430663736656233373464373439643062323566643832373836616636613833396130303030303030303736363937323734373536313663343036383631366536343663222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22363331383931383639393930227d7d7d5d2c22726571756972656445787472615369676e617475726573223a5b5d2c22736372697074496e7465677269747948617368223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c69644265666f7265223a7b225f5f74797065223a22756e646566696e6564227d2c22696e76616c6964486572656166746572223a31383538317d2c227769746864726177616c73223a5b5d7d2c226964223a2262306565303339333664363864323662353664383666633734306437663339363432333361363939663539626263306461353734353161396664376133666432222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c22646174756d73223a5b5d2c2272656465656d657273223a5b5d2c2273637269707473223a5b7b225f5f74797065223a226e6174697665222c226b657948617368223a223563663663393132373961383539613037323630313737396662333362623037633334653164363431643435646635316666363362393637222c226b696e64223a307d5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2233363863663661313161633765323939313735363861333636616636326135393663623963646538313734626665376636653838333933656364623164636336222c226535663636333032666365623530386331633365373764613730343332346331633566353134313830633566643730643333376661613533346364303134366361306664383365383365363565303132613230326637366630363462666464363032616237396634396437663939323539663537616165393634616265383031225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313931333733227d2c22686561646572223a7b22626c6f636b4e6f223a313639322c2268617368223a2265656462646164333961333331613266646632393165396334376335316337623034333136386465646138666463316336666638366563613665663463373735222c22736c6f74223a31373135337d2c22697373756572566b223a2239643864653731643430363862316435626662323566306532343464393535323134353230396561303236353131613633376437386561376235333330316564222c2270726576696f7573426c6f636b223a2231663762383561626338306333306134343935356262613730663036616230356632373533373233376532346332613630313063373632366562316163373635222c2273697a65223a3731362c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22363331383931383639393930227d2c227478436f756e74223a312c22767266223a227672665f766b317974646a376d6d38336438376133643874727873756571686378777770746c73326b7778347264733638756164377a6e65773271356a79656137227d
1693	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313639332c2268617368223a2266323065613333323864373965313135663637383838306131323235316138316636343734336163653835616630653862613066656530636665333963366361222c22736c6f74223a31373135357d2c22697373756572566b223a2238353063393037323164363865646362313761656465373138643465356461313434363639333238653033363037666632373963373861336438653830333863222c2270726576696f7573426c6f636b223a2265656462646164333961333331613266646632393165396334376335316337623034333136386465646138666463316336666638366563613665663463373735222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316379746b356d73383838386d63336d6a6d746b75707038307172707664786871767a786b6d3738646b3771336c327a3867616173346138763873227d
1694	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313639342c2268617368223a2261636637333038333337333563656266306434613261636234306336623462343661306262633631616666383561353539653937323962326665316431396634222c22736c6f74223a31373136387d2c22697373756572566b223a2238306537656566623762643938643164626435396437636164643831663264353135343639383734643165663339353135373861646139356131363434633361222c2270726576696f7573426c6f636b223a2266323065613333323864373965313135663637383838306131323235316138316636343734336163653835616630653862613066656530636665333963366361222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3135736468677a64396b346b333668386c686e32746b6d6b3530616b736a617a646565783039397570647a6761327a7a6b77373071363870396e34227d
1713	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313731332c2268617368223a2263393037316466323433306638343462613366316365383035373332383638396632333832343036313865333232653134393533643030346362353631393638222c22736c6f74223a31373331317d2c22697373756572566b223a2232353833326166386532326463353263346562636362646466313435306163383737613962613333323834323936626138393936373930323539666233353134222c2270726576696f7573426c6f636b223a2239623537366137663837353166353961306339633132363738653263643462666135663363386637633332333162346237343830366232383838666636343366222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31777a76717a306570617073756d396e7165376b6a357a6d36716a74706a666567737a3935757a7272787966396b77777a30396e716d666a727170227d
1714	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a22506f6f6c526567697374726174696f6e4365727469666963617465222c22706f6f6c506172616d6574657273223a7b226964223a22706f6f6c316d37793267616b7765777179617a303574766d717177766c3268346a6a327178746b6e6b7a6577306468747577757570726571222c22767266223a2236343164303432656433396332633235386433383130363063313432346634306566386162666532356566353636663463623232343737633432623261303134222c22706c65646765223a7b225f5f74797065223a22626967696e74222c2276616c7565223a223530303030303030227d2c22636f7374223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2231303030227d2c226d617267696e223a7b2264656e6f6d696e61746f72223a352c226e756d657261746f72223a317d2c227265776172644163636f756e74223a227374616b655f7465737431757a3579687478707068337a71306673787666393233766d3363746e64673370786e7839326e6737363475663575736e716b673576222c226f776e657273223a5b227374616b655f7465737431757a3579687478707068337a71306673787666393233766d3363746e64673370786e7839326e6737363475663575736e716b673576225d2c2272656c617973223a5b7b225f5f747970656e616d65223a2252656c6179427941646472657373222c2269707634223a223132372e302e302e32222c2269707636223a7b225f5f74797065223a22756e646566696e6564227d2c22706f7274223a363030307d5d2c226d657461646174614a736f6e223a7b225f5f74797065223a22756e646566696e6564227d7d7d5d2c22636f6c6c61746572616c73223a5b5d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313831363439227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2265363464373635353437316561313162323063323636663965333936366531393066393465346238643033313036626436396363376466326532316164373264227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2236323137336239306235363761643462636632353461643066373665623337346437343964306232356664383237383661663661383339613238333233323332323936383631366536343663363533363338222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2236383138333531227d7d7d5d2c22726571756972656445787472615369676e617475726573223a5b5d2c22736372697074496e7465677269747948617368223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c69644265666f7265223a7b225f5f74797065223a22756e646566696e6564227d2c22696e76616c6964486572656166746572223a31383734397d2c227769746864726177616c73223a5b5d7d2c226964223a2266313734343061383634623733383334643235646235323730363266666232343061316439663466383135396232376364383739636639306538356432623362222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c22646174756d73223a5b5d2c2272656465656d657273223a5b5d2c2273637269707473223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2238343435333239353736633961353736656365373235376266653939333039323766393233396566383736313564363963333137623834316135326137666436222c226438323630646434623261656635316430393135303232656665616165653964396233656438663763386233386661616338303039383735346238386236353334666635306233313064366464303531656534396564343437626161616437643737643239613138616433343032623932636433326237346631346233363037225d2c5b2261323864383864383665633264633963626666373466613030643362363534636330343734396430643165396265303934343762663530386163613330353030222c223032623235386436646263633961336136333537353236353732396638303034663139666439633834616435313631306266343534646366313663313030396363613030633566353534623731313739393136306562303737343065666163303137633736633264323831633933623533653739353338613364353533373035225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313831363439227d2c22686561646572223a7b22626c6f636b4e6f223a313731342c2268617368223a2231386435346336376631656266636230653666646261663835326432626233623066616566396334393138323961376130303737373735626637336264373934222c22736c6f74223a31373331337d2c22697373756572566b223a2232353833326166386532326463353263346562636362646466313435306163383737613962613333323834323936626138393936373930323539666233353134222c2270726576696f7573426c6f636b223a2263393037316466323433306638343462613366316365383035373332383638396632333832343036313865333232653134393533643030346362353631393638222c2273697a65223a3539342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2239383138333531227d2c227478436f756e74223a312c22767266223a227672665f766b31777a76717a306570617073756d396e7165376b6a357a6d36716a74706a666567737a3935757a7272787966396b77777a30396e716d666a727170227d
1715	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313731352c2268617368223a2236353361626439666132353661386431646539333432626263373765393135633361646334313265303364333536646535363062383036373037323761313836222c22736c6f74223a31373331357d2c22697373756572566b223a2232353833326166386532326463353263346562636362646466313435306163383737613962613333323834323936626138393936373930323539666233353134222c2270726576696f7573426c6f636b223a2231386435346336376631656266636230653666646261663835326432626233623066616566396334393138323961376130303737373735626637336264373934222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31777a76717a306570617073756d396e7165376b6a357a6d36716a74706a666567737a3935757a7272787966396b77777a30396e716d666a727170227d
1716	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313731362c2268617368223a2266323731633738653433373033376233366231356132636566323866363765363264623562333537383137363336653362663632383834306637666137653331222c22736c6f74223a31373332327d2c22697373756572566b223a2238306537656566623762643938643164626435396437636164643831663264353135343639383734643165663339353135373861646139356131363434633361222c2270726576696f7573426c6f636b223a2236353361626439666132353661386431646539333432626263373765393135633361646334313265303364333536646535363062383036373037323761313836222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3135736468677a64396b346b333668386c686e32746b6d6b3530616b736a617a646565783039397570647a6761327a7a6b77373071363870396e34227d
1717	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313731372c2268617368223a2231646338643261323363383033666532313937653630353364346436386462383764346433336166393864313431333935353633643935313035393238646264222c22736c6f74223a31373332377d2c22697373756572566b223a2265633038623338383961373631323139653532376534656366636639393136633333623130346232353531373865663636383832666664386561373738633330222c2270726576696f7573426c6f636b223a2266323731633738653433373033376233366231356132636566323866363765363264623562333537383137363336653362663632383834306637666137653331222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31776366783439676b67656a727436683074646e68746d686c6e636875346e30393975766b676335373267646338326d76796a68733279707a6170227d
1718	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b65526567697374726174696f6e4365727469666963617465222c227374616b6543726564656e7469616c223a7b2268617368223a226138346261636331306465323230336433303333313235353435396238653137333661323231333463633535346431656435373839613732222c2274797065223a307d7d5d2c22636f6c6c61746572616c73223a5b5d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313639393839227d2c22696e70757473223a5b7b22696e646578223a342c2274784964223a2233353634323465303435383039623236333838653334666663303263393133396331663364643062323463326363663761656233316235623064373533316434227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936383330303131227d7d7d5d2c22726571756972656445787472615369676e617475726573223a5b5d2c22736372697074496e7465677269747948617368223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c69644265666f7265223a7b225f5f74797065223a22756e646566696e6564227d2c22696e76616c6964486572656166746572223a31383736377d2c227769746864726177616c73223a5b5d7d2c226964223a2261656663613962643139663134343362393861313565306638393765613163363939363734353666636665663030626230383666303930383634636665323037222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c22646174756d73223a5b5d2c2272656465656d657273223a5b5d2c2273637269707473223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2261323864383864383665633264633963626666373466613030643362363534636330343734396430643165396265303934343762663530386163613330353030222c223365306630373461346465343138336530363462646333393734666433656366646630393838646631663563643965333766636238366161303134333733396330396537363336366431646437623738663230333939313432666564313264346264383033666466663335366138643732663234303566333537373562643039225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313639393839227d2c22686561646572223a7b22626c6f636b4e6f223a313731382c2268617368223a2261376334653933393434663335383335396134373162333763393662343665313539313839613563663038323330373135643862343839323439653862343036222c22736c6f74223a31373333337d2c22697373756572566b223a2236343264373439656331393462373637316665323937646161343537623035323133313163363037323137386466376165373833633261636234653162653664222c2270726576696f7573426c6f636b223a2231646338643261323363383033666532313937653630353364346436386462383764346433336166393864313431333935353633643935313035393238646264222c2273697a65223a3332392c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393939383330303131227d2c227478436f756e74223a312c22767266223a227672665f766b3133746d776874667277366474676a736e797776646c63776c35786a32636171366576717773346e636772787178656371773270713265776e3561227d
1695	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313639352c2268617368223a2237333334346237366431613234323032666438616466643361323530386365323131663661343637633437656638316363396662663230313161636431653338222c22736c6f74223a31373137357d2c22697373756572566b223a2231303438383030653039313630326432636565396631626638336339633133306132623831376332656238646630323931313931303035333966653831303435222c2270726576696f7573426c6f636b223a2261636637333038333337333563656266306434613261636234306336623462343661306262633631616666383561353539653937323962326665316431396634222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316e37726b6e6b7a6130327038676c6d78393066726567386d70706d6b6564746a67743363677761686d776c653671686d71787a71323771336461227d
1696	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313639362c2268617368223a2262343637363132656531343737616433613530363939623937613362363634326261306539353138376263366334633661656632306664343763646631313366222c22736c6f74223a31373137387d2c22697373756572566b223a2238353063393037323164363865646362313761656465373138643465356461313434363639333238653033363037666632373963373861336438653830333863222c2270726576696f7573426c6f636b223a2237333334346237366431613234323032666438616466643361323530386365323131663661343637633437656638316363396662663230313161636431653338222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316379746b356d73383838386d63336d6a6d746b75707038307172707664786871767a786b6d3738646b3771336c327a3867616173346138763873227d
1697	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313639372c2268617368223a2266636338383536313236613732353635663639346632306532303235393533373038656563633030393739326333333031303463646536343265363733376131222c22736c6f74223a31373138347d2c22697373756572566b223a2238306537656566623762643938643164626435396437636164643831663264353135343639383734643165663339353135373861646139356131363434633361222c2270726576696f7573426c6f636b223a2262343637363132656531343737616433613530363939623937613362363634326261306539353138376263366334633661656632306664343763646631313366222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3135736468677a64396b346b333668386c686e32746b6d6b3530616b736a617a646565783039397570647a6761327a7a6b77373071363870396e34227d
1698	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313639382c2268617368223a2266613731343231303036376135306433363635363131326235303030633464356137376533393331376238643437363632643833306664373664636366363065222c22736c6f74223a31373139377d2c22697373756572566b223a2265633038623338383961373631323139653532376534656366636639393136633333623130346232353531373865663636383832666664386561373738633330222c2270726576696f7573426c6f636b223a2266636338383536313236613732353635663639346632306532303235393533373038656563633030393739326333333031303463646536343265363733376131222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31776366783439676b67656a727436683074646e68746d686c6e636875346e30393975766b676335373267646338326d76796a68733279707a6170227d
1699	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313639392c2268617368223a2232303834386637363864666264393237663335666435646363396335353034623133343932316234336665333234313465326331306238366166373333393938222c22736c6f74223a31373231357d2c22697373756572566b223a2236343264373439656331393462373637316665323937646161343537623035323133313163363037323137386466376165373833633261636234653162653664222c2270726576696f7573426c6f636b223a2266613731343231303036376135306433363635363131326235303030633464356137376533393331376238643437363632643833306664373664636366363065222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3133746d776874667277366474676a736e797776646c63776c35786a32636171366576717773346e636772787178656371773270713265776e3561227d
1700	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313730302c2268617368223a2261623934373832333462363161383633313731643431333733353133373632313431303737383238346364653164313366666535633965646666663433663231222c22736c6f74223a31373232347d2c22697373756572566b223a2237633465646631323365393963396462663130653232383265643161316662326138336363396561323766376566626538336166653166636232343563646232222c2270726576696f7573426c6f636b223a2232303834386637363864666264393237663335666435646363396335353034623133343932316234336665333234313465326331306238366166373333393938222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31356d6d3333666b64676177643568673238617a7474717873326b76687a38376470657a3076367535787338646d6e387838336571346637707264227d
1701	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a22506f6f6c526567697374726174696f6e4365727469666963617465222c22706f6f6c506172616d6574657273223a7b226964223a22706f6f6c3165346571366a3037766c64307775397177706a6b356d6579343236637775737a6a376c7876383974687433753674386e766734222c22767266223a2232656535613463343233323234626239633432313037666331386136303535366436613833636563316439646433376137316635366166373139386663373539222c22706c65646765223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22353030303030303030303030303030227d2c22636f7374223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2231303030227d2c226d617267696e223a7b2264656e6f6d696e61746f72223a352c226e756d657261746f72223a317d2c227265776172644163636f756e74223a227374616b655f7465737431757273747872777a7a75366d78733338633070613066706e7365306a73647633643466797939326c7a7a7367337173737672777973222c226f776e657273223a5b227374616b655f7465737431757273747872777a7a75366d78733338633070613066706e7365306a73647633643466797939326c7a7a7367337173737672777973225d2c2272656c617973223a5b7b225f5f747970656e616d65223a2252656c6179427941646472657373222c2269707634223a223132372e302e302e31222c2269707636223a7b225f5f74797065223a22756e646566696e6564227d2c22706f7274223a363030307d5d2c226d657461646174614a736f6e223a7b225f5f74797065223a22756e646566696e6564227d7d7d5d2c22636f6c6c61746572616c73223a5b5d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313739383839227d2c22696e70757473223a5b7b22696e646578223a322c2274784964223a2233353634323465303435383039623236333838653334666663303263393133396331663364643062323463326363663761656233316235623064373533316434227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936383230313131227d7d7d5d2c22726571756972656445787472615369676e617475726573223a5b5d2c22736372697074496e7465677269747948617368223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c69644265666f7265223a7b225f5f74797065223a22756e646566696e6564227d2c22696e76616c6964486572656166746572223a31383635357d2c227769746864726177616c73223a5b5d7d2c226964223a2231353336306331613466343963303166623861656163653730366233313835383835303563396364626362396637323132333635623534396337666162346565222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c22646174756d73223a5b5d2c2272656465656d657273223a5b5d2c2273637269707473223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2263396237386631316366356165383965363837303730376233333731623265613930323837356264613266623439363332613036353539393966313039353963222c223334316437363931343066333937356238386466663065343765303734313762616664333233383463353439353664653963633762646530326336316532326465633831386166356531353165363733303465633436613230656261363561323834666235303439393632333861363138656633303031353132313566383034225d2c5b2262316237376531633633303234366137323964623564303164376630633133313261643538393565323634386330383864653632373236306334636135633836222c226562663165396663366136366631663930326638343261366538336334643232393636336636656565623539383962653630626639346561333230653564653633303735323135666637336633393633316632653361346237626530653263326162343436356566343437353261626435333337613163656136656531373034225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313739383839227d2c22686561646572223a7b22626c6f636b4e6f223a313730312c2268617368223a2236353461323062353539636334326565306165623436613536356230313438353130396162656662363638663931616639316365333130376532613563313436222c22736c6f74223a31373233317d2c22697373756572566b223a2239643864653731643430363862316435626662323566306532343464393535323134353230396561303236353131613633376437386561376235333330316564222c2270726576696f7573426c6f636b223a2261623934373832333462363161383633313731643431333733353133373632313431303737383238346364653164313366666535633965646666663433663231222c2273697a65223a3535342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393939383230313131227d2c227478436f756e74223a312c22767266223a227672665f766b317974646a376d6d38336438376133643874727873756571686378777770746c73326b7778347264733638756164377a6e65773271356a79656137227d
1702	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313730322c2268617368223a2231373930303062643234376265393130313164323432343336336636393330326432333839396166643737346162313761613531393865653032393439646236222c22736c6f74223a31373234357d2c22697373756572566b223a2231303438383030653039313630326432636565396631626638336339633133306132623831376332656238646630323931313931303035333966653831303435222c2270726576696f7573426c6f636b223a2236353461323062353539636334326565306165623436613536356230313438353130396162656662363638663931616639316365333130376532613563313436222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316e37726b6e6b7a6130327038676c6d78393066726567386d70706d6b6564746a67743363677761686d776c653671686d71787a71323771336461227d
1703	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313730332c2268617368223a2262323166353862383962653436613437623435303361356465356530363039613835373165336465653935356564353733326165366537353833366331633536222c22736c6f74223a31373235337d2c22697373756572566b223a2232353833326166386532326463353263346562636362646466313435306163383737613962613333323834323936626138393936373930323539666233353134222c2270726576696f7573426c6f636b223a2231373930303062643234376265393130313164323432343336336636393330326432333839396166643737346162313761613531393865653032393439646236222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31777a76717a306570617073756d396e7165376b6a357a6d36716a74706a666567737a3935757a7272787966396b77777a30396e716d666a727170227d
1704	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313730342c2268617368223a2232326362333434316631623836343266666532333963666261323035356235323262346665376533383535626530663464386630376565613238353832303137222c22736c6f74223a31373235367d2c22697373756572566b223a2236343264373439656331393462373637316665323937646161343537623035323133313163363037323137386466376165373833633261636234653162653664222c2270726576696f7573426c6f636b223a2262323166353862383962653436613437623435303361356465356530363039613835373165336465653935356564353733326165366537353833366331633536222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3133746d776874667277366474676a736e797776646c63776c35786a32636171366576717773346e636772787178656371773270713265776e3561227d
1719	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313731392c2268617368223a2261623138646536653263306636643864613139393565333665343233633535646434303837313430366230373531663137383765343330376465353661386562222c22736c6f74223a31373333387d2c22697373756572566b223a2234663030366266616334353335353030353865316436633337363862626632666635323161633633373537393865333039343436373938373562346564376263222c2270726576696f7573426c6f636b223a2261376334653933393434663335383335396134373162333763393662343665313539313839613563663038323330373135643862343839323439653862343036222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31327068707a39306c68326d38747779756663647179393570646b7538356d636c737868336e65327068377668646836356c766371797234337873227d
1720	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313732302c2268617368223a2262646433396661323138633032663832623038383961306136613964373665633963343764346436613563663536383635616334363563643431356163656361222c22736c6f74223a31373334307d2c22697373756572566b223a2265633038623338383961373631323139653532376534656366636639393136633333623130346232353531373865663636383832666664386561373738633330222c2270726576696f7573426c6f636b223a2261623138646536653263306636643864613139393565333665343233633535646434303837313430366230373531663137383765343330376465353661386562222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31776366783439676b67656a727436683074646e68746d686c6e636875346e30393975766b676335373267646338326d76796a68733279707a6170227d
1705	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b65526567697374726174696f6e4365727469666963617465222c227374616b6543726564656e7469616c223a7b2268617368223a226530623330646332313733356233343232376333633364376134333338363566323833353931366435323432313535663130613038383832222c2274797065223a307d7d5d2c22636f6c6c61746572616c73223a5b5d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313731353733227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2231353336306331613466343963303166623861656163653730366233313835383835303563396364626362396637323132333635623534396337666162346565227d2c7b22696e646578223a312c2274784964223a2231353336306331613466343963303166623861656163653730366233313835383835303563396364626362396637323132333635623534396337666162346565227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936363438353338227d7d7d5d2c22726571756972656445787472615369676e617475726573223a5b5d2c22736372697074496e7465677269747948617368223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c69644265666f7265223a7b225f5f74797065223a22756e646566696e6564227d2c22696e76616c6964486572656166746572223a31383639367d2c227769746864726177616c73223a5b5d7d2c226964223a2231316438396463336536353266643134653234336634316535306434653464303065326264646564323163633165336537303335333437343032363235356464222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c22646174756d73223a5b5d2c2272656465656d657273223a5b5d2c2273637269707473223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2263396237386631316366356165383965363837303730376233333731623265613930323837356264613266623439363332613036353539393966313039353963222c223666613638646335306461663964636130356538343934643764303065313437353164356131663933373966363463313730336339396162343931303731653931613561336238396363383239626237306634333833323964333231393763316363323463393866343936613463663333383431306164373361343634313030225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313731353733227d2c22686561646572223a7b22626c6f636b4e6f223a313730352c2268617368223a2266336235653365613339353433336235633263323531666435623932373064333965396238366164363964346434376239623338656437356361373933383034222c22736c6f74223a31373236327d2c22697373756572566b223a2238306537656566623762643938643164626435396437636164643831663264353135343639383734643165663339353135373861646139356131363434633361222c2270726576696f7573426c6f636b223a2232326362333434316631623836343266666532333963666261323035356235323262346665376533383535626530663464386630376565613238353832303137222c2273697a65223a3336352c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393939363438353338227d2c227478436f756e74223a312c22767266223a227672665f766b3135736468677a64396b346b333668386c686e32746b6d6b3530616b736a617a646565783039397570647a6761327a7a6b77373071363870396e34227d
1706	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313730362c2268617368223a2263666562306262346236383135353633306265396263363230343537353133643030373764366333333863356530303634393363383261363532613462326166222c22736c6f74223a31373236377d2c22697373756572566b223a2238353063393037323164363865646362313761656465373138643465356461313434363639333238653033363037666632373963373861336438653830333863222c2270726576696f7573426c6f636b223a2266336235653365613339353433336235633263323531666435623932373064333965396238366164363964346434376239623338656437356361373933383034222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316379746b356d73383838386d63336d6a6d746b75707038307172707664786871767a786b6d3738646b3771336c327a3867616173346138763873227d
1707	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313730372c2268617368223a2239356339326564346261626632373933343564373336613536396132316366626265363139316132663131646666626434333334616134303961343934653433222c22736c6f74223a31373238317d2c22697373756572566b223a2239643864653731643430363862316435626662323566306532343464393535323134353230396561303236353131613633376437386561376235333330316564222c2270726576696f7573426c6f636b223a2263666562306262346236383135353633306265396263363230343537353133643030373764366333333863356530303634393363383261363532613462326166222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317974646a376d6d38336438376133643874727873756571686378777770746c73326b7778347264733638756164377a6e65773271356a79656137227d
1708	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313730382c2268617368223a2239666162656162336234363435653361323631366538646131336538643730333563653764663765653162633531393762353830376564396262383863376133222c22736c6f74223a31373238367d2c22697373756572566b223a2238353063393037323164363865646362313761656465373138643465356461313434363639333238653033363037666632373963373861336438653830333863222c2270726576696f7573426c6f636b223a2239356339326564346261626632373933343564373336613536396132316366626265363139316132663131646666626434333334616134303961343934653433222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316379746b356d73383838386d63336d6a6d746b75707038307172707664786871767a786b6d3738646b3771336c327a3867616173346138763873227d
1709	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b6544656c65676174696f6e4365727469666963617465222c22706f6f6c4964223a22706f6f6c3165346571366a3037766c64307775397177706a6b356d6579343236637775737a6a376c7876383974687433753674386e766734222c227374616b6543726564656e7469616c223a7b2268617368223a226530623330646332313733356233343232376333633364376134333338363566323833353931366435323432313535663130613038383832222c2274797065223a307d7d5d2c22636f6c6c61746572616c73223a5b5d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313735373533227d2c22696e70757473223a5b7b22696e646578223a312c2274784964223a2231316438396463336536353266643134653234336634316535306434653464303065326264646564323163633165336537303335333437343032363235356464227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393933343732373835227d7d7d5d2c22726571756972656445787472615369676e617475726573223a5b5d2c22736372697074496e7465677269747948617368223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c69644265666f7265223a7b225f5f74797065223a22756e646566696e6564227d2c22696e76616c6964486572656166746572223a31383732367d2c227769746864726177616c73223a5b5d7d2c226964223a2266323335623232333561326261313961336635656364373666333630663666353464373066333833623938323163346332343237656136386465396133663932222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c22646174756d73223a5b5d2c2272656465656d657273223a5b5d2c2273637269707473223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2263396237386631316366356165383965363837303730376233333731623265613930323837356264613266623439363332613036353539393966313039353963222c223862623431386633386439653334336533616637333436643865336365383438366135336438666536333865653866383132663935363939666437663338306530353237343062343332366333343534353865616233643164323136373666316639333962363039653561666531383761313565386233393335336263393030225d2c5b2262316237376531633633303234366137323964623564303164376630633133313261643538393565323634386330383864653632373236306334636135633836222c223833656238333330616132363230653161633637373362343563623231396634653335616435353134616537613533653132356331386331386265656336633466343531616662396130613738653733366462316432383033383262383735323132623131383737306639626432396534383032666364333136643439313063225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313735373533227d2c22686561646572223a7b22626c6f636b4e6f223a313730392c2268617368223a2234326631336662373665333766343837666135306437663437653935663233343034666564313333303437346431656266396437363232376430373139393631222c22736c6f74223a31373239357d2c22697373756572566b223a2237633465646631323365393963396462663130653232383265643161316662326138336363396561323766376566626538336166653166636232343563646232222c2270726576696f7573426c6f636b223a2239666162656162336234363435653361323631366538646131336538643730333563653764663765653162633531393762353830376564396262383863376133222c2273697a65223a3436302c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936343732373835227d2c227478436f756e74223a312c22767266223a227672665f766b31356d6d3333666b64676177643568673238617a7474717873326b76687a38376470657a3076367535787338646d6e387838336571346637707264227d
1710	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313731302c2268617368223a2231653865623566643232303135383534643866333163356335336535323231333262303564366466316566393466393437633066313139316664643435356262222c22736c6f74223a31373330327d2c22697373756572566b223a2239643864653731643430363862316435626662323566306532343464393535323134353230396561303236353131613633376437386561376235333330316564222c2270726576696f7573426c6f636b223a2234326631336662373665333766343837666135306437663437653935663233343034666564313333303437346431656266396437363232376430373139393631222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317974646a376d6d38336438376133643874727873756571686378777770746c73326b7778347264733638756164377a6e65773271356a79656137227d
1711	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313731312c2268617368223a2261333733383066373266303662326134656662656263356465633633343332326164656565356563353065356161313462353633646630306338666436613331222c22736c6f74223a31373330377d2c22697373756572566b223a2265633038623338383961373631323139653532376534656366636639393136633333623130346232353531373865663636383832666664386561373738633330222c2270726576696f7573426c6f636b223a2231653865623566643232303135383534643866333163356335336535323231333262303564366466316566393466393437633066313139316664643435356262222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31776366783439676b67656a727436683074646e68746d686c6e636875346e30393975766b676335373267646338326d76796a68733279707a6170227d
1712	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313731322c2268617368223a2239623537366137663837353166353961306339633132363738653263643462666135663363386637633332333162346237343830366232383838666636343366222c22736c6f74223a31373330397d2c22697373756572566b223a2237633465646631323365393963396462663130653232383265643161316662326138336363396561323766376566626538336166653166636232343563646232222c2270726576696f7573426c6f636b223a2261333733383066373266303662326134656662656263356465633633343332326164656565356563353065356161313462353633646630306338666436613331222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31356d6d3333666b64676177643568673238617a7474717873326b76687a38376470657a3076367535787338646d6e387838336571346637707264227d
1721	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313732312c2268617368223a2264346338373630393636613535383666613938313138353931636138363265646332363635343462363731346435656536643065343235636630663239373064222c22736c6f74223a31373334317d2c22697373756572566b223a2265633038623338383961373631323139653532376534656366636639393136633333623130346232353531373865663636383832666664386561373738633330222c2270726576696f7573426c6f636b223a2262646433396661323138633032663832623038383961306136613964373665633963343764346436613563663536383635616334363563643431356163656361222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31776366783439676b67656a727436683074646e68746d686c6e636875346e30393975766b676335373267646338326d76796a68733279707a6170227d
1722	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b6544656c65676174696f6e4365727469666963617465222c22706f6f6c4964223a22706f6f6c316d37793267616b7765777179617a303574766d717177766c3268346a6a327178746b6e6b7a6577306468747577757570726571222c227374616b6543726564656e7469616c223a7b2268617368223a226138346261636331306465323230336433303333313235353435396238653137333661323231333463633535346431656435373839613732222c2274797065223a307d7d5d2c22636f6c6c61746572616c73223a5b5d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313739333137227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2230336363666464633863323163373539316334393364373037356566626439373665303330616534306239643839613165303535333930386434333765393731227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b223534326566626433306639373065356462393766396165303564316266386635663561363136313733353062373263323234343433343039222c7b225f5f74797065223a22626967696e74222c2276616c7565223a223133353030303030303030303030303030227d5d2c5b2235343265666264333066393730653564623937663961653035643162663866356635613631363137333530623732633232343434333430393734343235343433222c7b225f5f74797065223a22626967696e74222c2276616c7565223a223133353030303030303030303030303030227d5d2c5b2235343265666264333066393730653564623937663961653035643162663866356635613631363137333530623732633232343434333430393734343535343438222c7b225f5f74797065223a22626967696e74222c2276616c7565223a223133353030303030303030303030303030227d5d2c5b2235343265666264333066393730653564623937663961653035643162663866356635613631363137333530623732633232343434333430393734346434393465222c7b225f5f74797065223a22626967696e74222c2276616c7565223a223133353030303030303030303030303030227d5d5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2236383230363833227d7d7d5d2c22726571756972656445787472615369676e617475726573223a5b5d2c22736372697074496e7465677269747948617368223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c69644265666f7265223a7b225f5f74797065223a22756e646566696e6564227d2c22696e76616c6964486572656166746572223a31383738317d2c227769746864726177616c73223a5b5d7d2c226964223a2264303939626635396332356562306335336362303139626666326263613161623038383865363432623132363065336134643231616435623561363735633932222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c22646174756d73223a5b5d2c2272656465656d657273223a5b5d2c2273637269707473223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2238343435333239353736633961353736656365373235376266653939333039323766393233396566383736313564363963333137623834316135326137666436222c223862373138633037313336353463366134323836663565383565316333633532643536333362373931383931323036376236386363313234633134383164666361383538386432343130623738303564656631336462386233353365303333393536343837663561356365316533336662326162653231663030653264353030225d2c5b2261323864383864383665633264633963626666373466613030643362363534636330343734396430643165396265303934343762663530386163613330353030222c226435323932653666613566373366656566343938616161663433656334313838663936323965636438356665353339646339376331643139346337343637303863623164303134303662393939363837373938353234646638353139656638663237353161643737663033613637373237353964366366646133636436303030225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313739333137227d2c22686561646572223a7b22626c6f636b4e6f223a313732322c2268617368223a2231366537626264343239383839376437333332376239663930353563626333636639373936316336633461613136633165656465306162666134343936363932222c22736c6f74223a31373334347d2c22697373756572566b223a2237633465646631323365393963396462663130653232383265643161316662326138336363396561323766376566626538336166653166636232343563646232222c2270726576696f7573426c6f636b223a2264346338373630393636613535383666613938313138353931636138363265646332363635343462363731346435656536643065343235636630663239373064222c2273697a65223a3534312c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2239383230363833227d2c227478436f756e74223a312c22767266223a227672665f766b31356d6d3333666b64676177643568673238617a7474717873326b76687a38376470657a3076367535787338646d6e387838336571346637707264227d
1723	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313732332c2268617368223a2231323630386365636565653838353165366161316135333366373934363734303132323366316631393563346663646138396639323664323965353335393730222c22736c6f74223a31373334397d2c22697373756572566b223a2238306537656566623762643938643164626435396437636164643831663264353135343639383734643165663339353135373861646139356131363434633361222c2270726576696f7573426c6f636b223a2231366537626264343239383839376437333332376239663930353563626333636639373936316336633461613136633165656465306162666134343936363932222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3135736468677a64396b346b333668386c686e32746b6d6b3530616b736a617a646565783039397570647a6761327a7a6b77373071363870396e34227d
1724	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313732342c2268617368223a2234313938393832636465653033653133656337653966363965366630366630326463303038313563306233616430333731366432306364326664636537663239222c22736c6f74223a31373335337d2c22697373756572566b223a2231303438383030653039313630326432636565396631626638336339633133306132623831376332656238646630323931313931303035333966653831303435222c2270726576696f7573426c6f636b223a2231323630386365636565653838353165366161316135333366373934363734303132323366316631393563346663646138396639323664323965353335393730222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316e37726b6e6b7a6130327038676c6d78393066726567386d70706d6b6564746a67743363677761686d776c653671686d71787a71323771336461227d
1725	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313732352c2268617368223a2235643934316630306565656430393862326134626165626630623830316239373833623862663230616162363463613136656332396638363433616333636561222c22736c6f74223a31373335397d2c22697373756572566b223a2232353833326166386532326463353263346562636362646466313435306163383737613962613333323834323936626138393936373930323539666233353134222c2270726576696f7573426c6f636b223a2234313938393832636465653033653133656337653966363965366630366630326463303038313563306233616430333731366432306364326664636537663239222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31777a76717a306570617073756d396e7165376b6a357a6d36716a74706a666567737a3935757a7272787966396b77777a30396e716d666a727170227d
\.


--
-- Data for Name: current_pool_metrics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.current_pool_metrics (stake_pool_id, slot, minted_blocks, live_delegators, active_stake, live_stake, live_pledge, live_saturation, active_size, live_size, last_ros, ros) FROM stdin;
pool14h82efshjpt9rqe3lch85ydun74wt2z4lv58phd7ql9ezwahc8d	9994	101	3	3732314636757059	3744275373803366	7383856460089	27.35877530744145	0.9968055936457052	0.0031944063542947987	45.770973672436966	46.5601705688504
pool18wpk9px7k4c9vv6g2mgctnneu25xcst7v9mv975kl9fekuwjxhl	9994	90	2	3725080338595105	3733269382903620	5361587925989	27.27835642741767	0.9978064684145171	0.002193531585482855	46.38779188183555	46.756431056604285
pool13uytn3qpyf5sv0ne75nzu9wkq603ypmagcu8e2dchlxuzr7urnn	9994	87	2	3722390799679566	3728694651643134	5659750799378	27.244929653969532	0.998309367606492	0.0016906323935079737	44.67610961057036	42.24676307869394
pool1va6e8tmmc52pwg9cnv24z8rct5p0h9at7h0n4enpeecpsqsx8cp	9994	113	8	3742646267811223	3746414312924813	7785402992969	27.374404167228153	0.9989942262657414	0.001005773734258586	46.93133820971292	51.617530735916965
pool17q7k3syvupxcm6cx8ayt0y66craxuhgq6rt7ecd6na0g7dtggyf	9994	81	2	0	3704463679837889	300000000	27.06787811611022	0	1	27.49949393106357	27.49949393106357
pool1z9jkqfh38ujlx3a3knxfzts2xkv4uj9l3uwuk0g28sa5gxwfy0s	9994	37	2	0	3709626085742585	500000000	27.10559892697273	0	1	24.925080037122008	24.925080037122008
pool1vnedz2r7ke2m964j5fq7z0j3pxf566rkca79wp9gj5ng7kh96l6	9994	82	2	3693686858460393	3693686858460393	300000000	26.98913373831734	1	0	0	5.377678812657862
pool1zgwnt4lqgzvcdmznsx4lhjcylur0rwgzgqj79j3smyahvz3a6qg	9994	104	2	3725384548839730	3734220387654942	500000000	27.285305255351044	0.9976338196737337	0.0023661803262663428	50.97838791643037	46.496159919455096
pool1sht8xwep2fd65d9jhvjp2hzzrg0lmpk2xga4lg63a25uv7a0g5u	9994	102	2	3729159484055699	3737344893524091	6734597180025	27.30813548162631	0.9978098329959926	0.002190167004007426	50.777555446012244	52.156740967679156
pool1rs6afqrmxvqa524hjnar4pky069zdtrxenvy33wdfej9xs7k0rl	9994	91	2	3723272343810142	3728945825425662	6304669710495	27.246764937540657	0.9984785293535681	0.0015214706464319327	45.43328731973516	43.66821178809901
pool1fknsj2mn7x90p4x360wxaxq694uyv3rvma3czv04vt94ulnmhmp	9994	113	2	3696758242504176	3696758242504176	200279041	27.011575812563436	1	0	0	2.9332794320319833
\.


--
-- Data for Name: pool_delisted; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_delisted (stake_pool_id) FROM stdin;
\.


--
-- Data for Name: pool_metadata; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_metadata (id, ticker, name, description, homepage, hash, ext, stake_pool_id, pool_update_id) FROM stdin;
1	SP1	stake pool - 1	This is the stake pool 1 description.	https://stakepool1.com	14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	\N	pool1sht8xwep2fd65d9jhvjp2hzzrg0lmpk2xga4lg63a25uv7a0g5u	1030000000000
2	SP3	Stake Pool - 3	This is the stake pool 3 description.	https://stakepool3.com	6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	\N	pool1fknsj2mn7x90p4x360wxaxq694uyv3rvma3czv04vt94ulnmhmp	3440000000000
3	SP4	Same Name	This is the stake pool 4 description.	https://stakepool4.com	09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	\N	pool14h82efshjpt9rqe3lch85ydun74wt2z4lv58phd7ql9ezwahc8d	4250000000000
4	SP11	Stake Pool - 10 + 1	This is the stake pool 11 description.	https://stakepool11.com	4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	\N	pool1zgwnt4lqgzvcdmznsx4lhjcylur0rwgzgqj79j3smyahvz3a6qg	12220000000000
5	SP5	Same Name	This is the stake pool 5 description.	https://stakepool5.com	0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	\N	pool18wpk9px7k4c9vv6g2mgctnneu25xcst7v9mv975kl9fekuwjxhl	5210000000000
6	SP6a7	Stake Pool - 6	This is the stake pool 6 description.	https://stakepool6.com	3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	\N	pool13uytn3qpyf5sv0ne75nzu9wkq603ypmagcu8e2dchlxuzr7urnn	6070000000000
7	SP6a7		This is the stake pool 7 description.	https://stakepool7.com	c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	\N	pool1va6e8tmmc52pwg9cnv24z8rct5p0h9at7h0n4enpeecpsqsx8cp	7350000000000
8	SP10	Stake Pool - 10	This is the stake pool 10 description.	https://stakepool10.com	c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	\N	pool1z9jkqfh38ujlx3a3knxfzts2xkv4uj9l3uwuk0g28sa5gxwfy0s	10840000000000
\.


--
-- Data for Name: pool_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_registration (id, reward_account, pledge, cost, margin, margin_percent, relays, owners, vrf, metadata_url, metadata_hash, block_slot, stake_pool_id) FROM stdin;
1030000000000	stake_test1uq6lk8spwmwtxfyc9ztrf3fq8k6mtlz4h7qk3jg69kyaemquj6wfy	400000000	390000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 3001, "__typename": "RelayByAddress"}]	["stake_test1uq6lk8spwmwtxfyc9ztrf3fq8k6mtlz4h7qk3jg69kyaemquj6wfy"]	896becb1df5b1789eeb33d526d8df6f662ae26c0cc7035bd02c87bc8abb4c2ec	http://file-server/SP1.json	14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	103	pool1sht8xwep2fd65d9jhvjp2hzzrg0lmpk2xga4lg63a25uv7a0g5u
2100000000000	stake_test1ur703pj0q5rfp60e2nkdmdmnzhhkryjkjjw6rve7gyk0aqqjnzcxk	500000000	390000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 3002, "__typename": "RelayByAddress"}]	["stake_test1ur703pj0q5rfp60e2nkdmdmnzhhkryjkjjw6rve7gyk0aqqjnzcxk"]	5e0dd096c576b183cb1f895941b1c0fda57965cc10b2f9664bec9b6bae5d4287	\N	\N	210	pool1rs6afqrmxvqa524hjnar4pky069zdtrxenvy33wdfej9xs7k0rl
3440000000000	stake_test1up93r2m3jeqh4mga2c6se9usuje0gtt77hxk4dxp8d5kgtcwnh2sk	600000000	390000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 3003, "__typename": "RelayByAddress"}]	["stake_test1up93r2m3jeqh4mga2c6se9usuje0gtt77hxk4dxp8d5kgtcwnh2sk"]	7fb45535e1349bbe2fcb7edb95f5894e77a45ff087630602fa1e1ac41e512f0b	http://file-server/SP3.json	6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	344	pool1fknsj2mn7x90p4x360wxaxq694uyv3rvma3czv04vt94ulnmhmp
4250000000000	stake_test1ura3f5sjhpvgmx6wx5uvg5xg90uqq8mdqa55jwd5xxjt50srjt50h	420000000	370000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 3004, "__typename": "RelayByAddress"}]	["stake_test1ura3f5sjhpvgmx6wx5uvg5xg90uqq8mdqa55jwd5xxjt50srjt50h"]	ad94f15bf73aaa8335632ac5f5c29969e33898bd3b11211fe87f22b5b6b320b3	http://file-server/SP4.json	09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	425	pool14h82efshjpt9rqe3lch85ydun74wt2z4lv58phd7ql9ezwahc8d
5210000000000	stake_test1uzeh4afp9k0ztqavwk3k6khle67gnas8px9vmfwwut3sj2c489ejm	410000000	390000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 3005, "__typename": "RelayByAddress"}]	["stake_test1uzeh4afp9k0ztqavwk3k6khle67gnas8px9vmfwwut3sj2c489ejm"]	7a469777bbc86164cf220dd2ccb851dc6f2b12343c383b2dd8c9a10fc76ea0dd	http://file-server/SP5.json	0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	521	pool18wpk9px7k4c9vv6g2mgctnneu25xcst7v9mv975kl9fekuwjxhl
6070000000000	stake_test1uzsvcpjsqjl89wvuwkfrpay0dftha9mww2xgzr87kdp8knc22l07t	410000000	400000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 3006, "__typename": "RelayByAddress"}]	["stake_test1uzsvcpjsqjl89wvuwkfrpay0dftha9mww2xgzr87kdp8knc22l07t"]	0266b33debfdc230200fc8111cab74c12a16fa0f87f3768c91e49912f8f16d7d	http://file-server/SP6.json	3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	607	pool13uytn3qpyf5sv0ne75nzu9wkq603ypmagcu8e2dchlxuzr7urnn
7350000000000	stake_test1uz7ksz5gfdhm69cu76a208lc48yvnqz0zdvmh9kydfcv24g6g03n4	410000000	390000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 3007, "__typename": "RelayByAddress"}]	["stake_test1uz7ksz5gfdhm69cu76a208lc48yvnqz0zdvmh9kydfcv24g6g03n4"]	31fe14dabf216d1cb9c1ab2d0aa7ca4cc1a98ad3fc023e361571017e85f3311a	http://file-server/SP7.json	c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	735	pool1va6e8tmmc52pwg9cnv24z8rct5p0h9at7h0n4enpeecpsqsx8cp
8070000000000	stake_test1uq6g7pd9vxvtdd6ayw2mf632y7x3y6yvjpgduxgzkjn5dgsz09wyr	500000000	380000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 3008, "__typename": "RelayByAddress"}]	["stake_test1uq6g7pd9vxvtdd6ayw2mf632y7x3y6yvjpgduxgzkjn5dgsz09wyr"]	f2817cb1f4802a8234f4563c7c039aaea9b9e89b1448cc7114e697059fb01b33	\N	\N	807	pool17q7k3syvupxcm6cx8ayt0y66craxuhgq6rt7ecd6na0g7dtggyf
9860000000000	stake_test1upcm6cu75kq8uuv6um60r7vmh34attz20dsxj8k08xqtznqzm6wzj	500000000	390000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 3009, "__typename": "RelayByAddress"}]	["stake_test1upcm6cu75kq8uuv6um60r7vmh34attz20dsxj8k08xqtznqzm6wzj"]	ede56caa5e1ea9301dc4350ef24446c5e0cedcd1b4528c382ebb95ff36246772	\N	\N	986	pool1vnedz2r7ke2m964j5fq7z0j3pxf566rkca79wp9gj5ng7kh96l6
10840000000000	stake_test1uzuy338j364u0pwem9hd4d542s98gtjupveevu5xl02le6sy4x034	400000000	410000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 30010, "__typename": "RelayByAddress"}]	["stake_test1uzuy338j364u0pwem9hd4d542s98gtjupveevu5xl02le6sy4x034"]	5398df365ad8e2af5ed4eefd18b75c5116f1c0219986a1059501160004c25e6c	http://file-server/SP10.json	c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	1084	pool1z9jkqfh38ujlx3a3knxfzts2xkv4uj9l3uwuk0g28sa5gxwfy0s
12220000000000	stake_test1uzqthhcdnp65jn55gzxmy0wjrx6uwmu2nhxc4m37d5xgc8qdc3xvj	400000000	390000000	{"numerator": 3, "denominator": 20}	0.150000006	[{"ipv4": "127.0.0.1", "port": 30011, "__typename": "RelayByAddress"}]	["stake_test1uzqthhcdnp65jn55gzxmy0wjrx6uwmu2nhxc4m37d5xgc8qdc3xvj"]	44fd29a940a2d869332e759a78b66debb7f6ae950a882500c446c30de3ad4d77	http://file-server/SP11.json	4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	1222	pool1zgwnt4lqgzvcdmznsx4lhjcylur0rwgzgqj79j3smyahvz3a6qg
172310000000000	stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys	500000000000000	1000	{"numerator": 1, "denominator": 5}	0.200000003	[{"ipv4": "127.0.0.1", "port": 6000, "__typename": "RelayByAddress"}]	["stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys"]	2ee5a4c423224bb9c42107fc18a60556d6a83cec1d9dd37a71f56af7198fc759	\N	\N	17231	pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4
173130000000000	stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v	50000000	1000	{"numerator": 1, "denominator": 5}	0.200000003	[{"ipv4": "127.0.0.2", "port": 6000, "__typename": "RelayByAddress"}]	["stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v"]	641d042ed39c2c258d381060c1424f40ef8abfe25ef566f4cb22477c42b2a014	\N	\N	17313	pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq
\.


--
-- Data for Name: pool_retirement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_retirement (id, retire_at_epoch, block_slot, stake_pool_id) FROM stdin;
8890000000000	5	889	pool17q7k3syvupxcm6cx8ayt0y66craxuhgq6rt7ecd6na0g7dtggyf
10230000000000	18	1023	pool1vnedz2r7ke2m964j5fq7z0j3pxf566rkca79wp9gj5ng7kh96l6
11410000000000	5	1141	pool1z9jkqfh38ujlx3a3knxfzts2xkv4uj9l3uwuk0g28sa5gxwfy0s
12680000000000	18	1268	pool1zgwnt4lqgzvcdmznsx4lhjcylur0rwgzgqj79j3smyahvz3a6qg
\.


--
-- Data for Name: pool_rewards; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_rewards (id, stake_pool_id, epoch_length, epoch_no, delegators, pledge, active_stake, member_active_stake, leader_rewards, member_rewards, rewards, version) FROM stdin;
1	pool17q7k3syvupxcm6cx8ayt0y66craxuhgq6rt7ecd6na0g7dtggyf	1000000	1	0	500000000	0	0	0	9802969154112	9802969154112	1
2	pool1vnedz2r7ke2m964j5fq7z0j3pxf566rkca79wp9gj5ng7kh96l6	1000000	1	0	500000000	0	0	0	2450742288528	2450742288528	1
3	pool1z9jkqfh38ujlx3a3knxfzts2xkv4uj9l3uwuk0g28sa5gxwfy0s	1000000	1	0	400000000	0	0	0	6535312769408	6535312769408	1
4	pool1sht8xwep2fd65d9jhvjp2hzzrg0lmpk2xga4lg63a25uv7a0g5u	1000000	1	0	400000000	0	0	0	4901484577056	4901484577056	1
5	pool1rs6afqrmxvqa524hjnar4pky069zdtrxenvy33wdfej9xs7k0rl	1000000	1	0	500000000	0	0	0	8986055057936	8986055057936	1
6	pool1fknsj2mn7x90p4x360wxaxq694uyv3rvma3czv04vt94ulnmhmp	1000000	1	0	600000000	0	0	0	9802969154112	9802969154112	1
7	pool14h82efshjpt9rqe3lch85ydun74wt2z4lv58phd7ql9ezwahc8d	1000000	1	0	420000000	0	0	0	7352226865584	7352226865584	1
8	pool18wpk9px7k4c9vv6g2mgctnneu25xcst7v9mv975kl9fekuwjxhl	1000000	1	0	410000000	0	0	0	6535312769408	6535312769408	1
9	pool13uytn3qpyf5sv0ne75nzu9wkq603ypmagcu8e2dchlxuzr7urnn	1000000	1	0	410000000	0	0	0	8986055057936	8986055057936	1
10	pool1va6e8tmmc52pwg9cnv24z8rct5p0h9at7h0n4enpeecpsqsx8cp	1000000	1	0	410000000	0	0	0	9802969154112	9802969154112	1
11	pool17q7k3syvupxcm6cx8ayt0y66craxuhgq6rt7ecd6na0g7dtggyf	1000000	2	2	500000000	3681818481265842	3681818181265842	0	12842229417935	12842229417935	1
12	pool1vnedz2r7ke2m964j5fq7z0j3pxf566rkca79wp9gj5ng7kh96l6	1000000	2	2	500000000	3681818481446391	3681818181446391	0	9417634906023	9417634906023	1
13	pool1z9jkqfh38ujlx3a3knxfzts2xkv4uj9l3uwuk0g28sa5gxwfy0s	1000000	2	1	400000000	3681818181818181	3681818181818181	0	4280743487471	4280743487471	1
14	pool1zgwnt4lqgzvcdmznsx4lhjcylur0rwgzgqj79j3smyahvz3a6qg	1000000	2	1	400000000	3681818181818190	3681818181818190	0	4280743487471	4280743487471	1
15	pool1sht8xwep2fd65d9jhvjp2hzzrg0lmpk2xga4lg63a25uv7a0g5u	1000000	2	2	400000000	3681818681443619	3681818181443619	0	10273782975769	10273782975769	1
16	pool1rs6afqrmxvqa524hjnar4pky069zdtrxenvy33wdfej9xs7k0rl	1000000	2	2	500000000	3681818781446391	3681818181446391	0	5136891348360	5136891348360	1
17	pool1fknsj2mn7x90p4x360wxaxq694uyv3rvma3czv04vt94ulnmhmp	1000000	2	2	600000000	3681818381443619	3681818181443619	0	5136891906445	5136891906445	1
18	pool14h82efshjpt9rqe3lch85ydun74wt2z4lv58phd7ql9ezwahc8d	1000000	2	2	420000000	3681818681443619	3681818181443619	0	8561485813141	8561485813141	1
19	pool18wpk9px7k4c9vv6g2mgctnneu25xcst7v9mv975kl9fekuwjxhl	1000000	2	2	410000000	3681818681443619	3681818181443619	0	13698377301026	13698377301026	1
20	pool13uytn3qpyf5sv0ne75nzu9wkq603ypmagcu8e2dchlxuzr7urnn	1000000	2	2	410000000	3681818681443619	3681818181443619	0	3424594325255	3424594325255	1
21	pool1va6e8tmmc52pwg9cnv24z8rct5p0h9at7h0n4enpeecpsqsx8cp	1000000	2	2	410000000	3681818681443619	3681818181443619	0	9417634394455	9417634394455	1
22	pool1vnedz2r7ke2m964j5fq7z0j3pxf566rkca79wp9gj5ng7kh96l6	1000000	3	2	500000000	3681818481265842	3681818181265842	0	0	0	1
23	pool1zgwnt4lqgzvcdmznsx4lhjcylur0rwgzgqj79j3smyahvz3a6qg	1000000	3	2	400000000	3681818681263035	3681818181263035	0	2542507073422	2542507073422	1
24	pool1sht8xwep2fd65d9jhvjp2hzzrg0lmpk2xga4lg63a25uv7a0g5u	1000000	3	2	400000000	3681818681443619	3681818181443619	890209660412	5042306843950	5932516504362	1
25	pool1rs6afqrmxvqa524hjnar4pky069zdtrxenvy33wdfej9xs7k0rl	1000000	3	2	500000000	3681818781446391	3681818181446391	1271586176013	7203437171455	8475023347468	1
26	pool1fknsj2mn7x90p4x360wxaxq694uyv3rvma3czv04vt94ulnmhmp	1000000	3	2	600000000	3681818381443619	3681818181443619	0	0	0	1
27	pool14h82efshjpt9rqe3lch85ydun74wt2z4lv58phd7ql9ezwahc8d	1000000	3	2	420000000	3681818681443619	3681818181443619	890192660414	5042323843948	5932516504362	1
28	pool18wpk9px7k4c9vv6g2mgctnneu25xcst7v9mv975kl9fekuwjxhl	1000000	3	2	410000000	3681818681443619	3681818181443619	635958757424	3601553031405	4237511788829	1
29	pool13uytn3qpyf5sv0ne75nzu9wkq603ypmagcu8e2dchlxuzr7urnn	1000000	3	2	410000000	3681818681443619	3681818181443619	1780096320868	10084936687857	11865033008725	1
30	pool1va6e8tmmc52pwg9cnv24z8rct5p0h9at7h0n4enpeecpsqsx8cp	1000000	3	2	410000000	3681818681443619	3681818181443619	2542840529832	14407206625490	16950047155322	1
31	pool17q7k3syvupxcm6cx8ayt0y66craxuhgq6rt7ecd6na0g7dtggyf	1000000	3	2	500000000	3681818481265842	3681818181265842	0	0	0	1
32	pool1z9jkqfh38ujlx3a3knxfzts2xkv4uj9l3uwuk0g28sa5gxwfy0s	1000000	3	2	400000000	3681818681263026	3681818181263026	0	1695004715614	1695004715614	1
33	pool1vnedz2r7ke2m964j5fq7z0j3pxf566rkca79wp9gj5ng7kh96l6	1000000	4	2	500000000	3684269223554370	3684268923554370	0	0	0	1
34	pool1zgwnt4lqgzvcdmznsx4lhjcylur0rwgzgqj79j3smyahvz3a6qg	1000000	4	2	400000000	3694889306801851	3694888806801851	625103990355	3540042751710	4165146742065	1
35	pool1sht8xwep2fd65d9jhvjp2hzzrg0lmpk2xga4lg63a25uv7a0g5u	1000000	4	2	400000000	3686720166020675	3686719666020675	1753570764941	9934682018932	11688252783873	1
36	pool1rs6afqrmxvqa524hjnar4pky069zdtrxenvy33wdfej9xs7k0rl	1000000	4	2	500000000	3690804836504327	3690804236504327	875981097705	4961677509660	5837658607365	1
37	pool1fknsj2mn7x90p4x360wxaxq694uyv3rvma3czv04vt94ulnmhmp	1000000	4	2	600000000	3691621350597731	3691621150597731	0	0	0	1
38	pool14h82efshjpt9rqe3lch85ydun74wt2z4lv58phd7ql9ezwahc8d	1000000	4	2	420000000	3689170908309203	3689170408309203	876351787390	4963892310111	5840244097501	1
39	pool18wpk9px7k4c9vv6g2mgctnneu25xcst7v9mv975kl9fekuwjxhl	1000000	4	2	410000000	3688353994213027	3688353494213027	1001738718773	5674304278256	6676042997029	1
40	pool13uytn3qpyf5sv0ne75nzu9wkq603ypmagcu8e2dchlxuzr7urnn	1000000	4	2	410000000	3690804736501555	3690804236501555	625803919270	3543952341827	4169756261097	1
41	pool1va6e8tmmc52pwg9cnv24z8rct5p0h9at7h0n4enpeecpsqsx8cp	1000000	4	2	410000000	3691621650597731	3691621150597731	1000852317751	5669281348206	6670133665957	1
42	pool17q7k3syvupxcm6cx8ayt0y66craxuhgq6rt7ecd6na0g7dtggyf	1000000	4	2	500000000	3691621450419954	3691621150419954	0	0	0	1
43	pool1z9jkqfh38ujlx3a3knxfzts2xkv4uj9l3uwuk0g28sa5gxwfy0s	1000000	4	2	400000000	3688353994032434	3688353494032434	1001755718820	5674287278535	6676042997355	1
44	pool1vnedz2r7ke2m964j5fq7z0j3pxf566rkca79wp9gj5ng7kh96l6	1000000	5	2	500000000	3693686858460393	3693686557693031	0	0	0	1
45	pool1zgwnt4lqgzvcdmznsx4lhjcylur0rwgzgqj79j3smyahvz3a6qg	1000000	5	2	400000000	3699170050289322	3699169550289322	1087234427169	6158779537601	7246013964770	1
46	pool1sht8xwep2fd65d9jhvjp2hzzrg0lmpk2xga4lg63a25uv7a0g5u	1000000	5	2	400000000	3696993948996444	3696993447601240	1208712273272	6847153357696	8055865630968	1
47	pool1rs6afqrmxvqa524hjnar4pky069zdtrxenvy33wdfej9xs7k0rl	1000000	5	2	500000000	3695941727852687	3695941127015565	1088183981473	6164159214432	7252343195905	1
48	pool1fknsj2mn7x90p4x360wxaxq694uyv3rvma3czv04vt94ulnmhmp	1000000	5	2	600000000	3696758242504176	3696758042225135	0	0	0	1
49	pool14h82efshjpt9rqe3lch85ydun74wt2z4lv58phd7ql9ezwahc8d	1000000	5	2	420000000	3697732394122344	3697731892959674	1691709738998	9584249861146	11275959600144	1
50	pool18wpk9px7k4c9vv6g2mgctnneu25xcst7v9mv975kl9fekuwjxhl	1000000	5	2	410000000	3702052371514053	3702051869653780	845042263079	4786358498441	5631400761520	1
51	pool13uytn3qpyf5sv0ne75nzu9wkq603ypmagcu8e2dchlxuzr7urnn	1000000	5	2	410000000	3694229330826810	3694228830361742	846839554318	4796486475868	5643326030186	1
52	pool1va6e8tmmc52pwg9cnv24z8rct5p0h9at7h0n4enpeecpsqsx8cp	1000000	5	2	410000000	3701039284992186	3701038783713249	1086685481266	6155668835573	7242354316839	1
53	pool1vnedz2r7ke2m964j5fq7z0j3pxf566rkca79wp9gj5ng7kh96l6	1000000	6	2	500000000	3693686858460393	3693686557693031	0	0	0	1
54	pool1zgwnt4lqgzvcdmznsx4lhjcylur0rwgzgqj79j3smyahvz3a6qg	1000000	6	2	400000000	3701712557362744	3701712057017466	1839457524137	10421373246014	12260830770151	1
55	pool1sht8xwep2fd65d9jhvjp2hzzrg0lmpk2xga4lg63a25uv7a0g5u	1000000	6	2	400000000	3702926465500806	3702035754445190	974993168891	5513906971161	6488900140052	1
56	pool1rs6afqrmxvqa524hjnar4pky069zdtrxenvy33wdfej9xs7k0rl	1000000	6	2	500000000	3704416751200155	3703144564187020	866853044926	4898737761791	5765590806717	1
57	pool1fknsj2mn7x90p4x360wxaxq694uyv3rvma3czv04vt94ulnmhmp	1000000	6	2	600000000	3696758242504176	3696758042225135	0	0	0	1
58	pool14h82efshjpt9rqe3lch85ydun74wt2z4lv58phd7ql9ezwahc8d	1000000	6	2	420000000	3703664910626706	3702774216803622	1732700430101	9800822002607	11533522432708	1
59	pool18wpk9px7k4c9vv6g2mgctnneu25xcst7v9mv975kl9fekuwjxhl	1000000	6	2	410000000	3706289883302882	3705653422685185	973729471014	5509282062660	6483011533674	1
60	pool13uytn3qpyf5sv0ne75nzu9wkq603ypmagcu8e2dchlxuzr7urnn	1000000	6	2	410000000	3706094363835535	3704313767049599	975490563265	5507862989483	6483353552748	1
61	pool1va6e8tmmc52pwg9cnv24z8rct5p0h9at7h0n4enpeecpsqsx8cp	1000000	6	2	410000000	3717989332147508	3715445990338739	865352975629	4879190447424	5744543423053	1
62	pool1vnedz2r7ke2m964j5fq7z0j3pxf566rkca79wp9gj5ng7kh96l6	1000000	7	2	500000000	3693686858460393	3693686557693031	0	0	0	1
63	pool1zgwnt4lqgzvcdmznsx4lhjcylur0rwgzgqj79j3smyahvz3a6qg	1000000	7	2	400000000	3705877704104809	3705252099769176	1326975138221	7508863676991	8835838815212	1
64	pool1sht8xwep2fd65d9jhvjp2hzzrg0lmpk2xga4lg63a25uv7a0g5u	1000000	7	2	400000000	3714614718284679	3711970436464122	1233095512882	6952313955510	8185409468392	1
65	pool1rs6afqrmxvqa524hjnar4pky069zdtrxenvy33wdfej9xs7k0rl	1000000	7	2	500000000	3710254409807520	3708106241696680	854145664438	4819335951082	5673481615520	1
66	pool1fknsj2mn7x90p4x360wxaxq694uyv3rvma3czv04vt94ulnmhmp	1000000	7	2	600000000	3696758242504176	3696758042225135	0	0	0	1
67	pool14h82efshjpt9rqe3lch85ydun74wt2z4lv58phd7ql9ezwahc8d	1000000	7	2	420000000	3709505154724207	3707738109113733	1422800693713	8034911905382	9457712599095	1
68	pool18wpk9px7k4c9vv6g2mgctnneu25xcst7v9mv975kl9fekuwjxhl	1000000	7	2	410000000	3712965926299911	3711327726963441	1231759128094	6957285180421	8189044308515	1
69	pool13uytn3qpyf5sv0ne75nzu9wkq603ypmagcu8e2dchlxuzr7urnn	1000000	7	2	410000000	3710264120096632	3707857719391426	949392840016	5354459123552	6303851963568	1
70	pool1va6e8tmmc52pwg9cnv24z8rct5p0h9at7h0n4enpeecpsqsx8cp	1000000	7	8	410000000	3729659386952443	3726115192825923	946057055487	5325013123373	6271070178860	1
71	pool1vnedz2r7ke2m964j5fq7z0j3pxf566rkca79wp9gj5ng7kh96l6	1000000	8	2	500000000	3693686858460393	3693686557693031	0	0	0	1
72	pool1zgwnt4lqgzvcdmznsx4lhjcylur0rwgzgqj79j3smyahvz3a6qg	1000000	8	2	400000000	3713123718069579	3711410879306777	1249692061906	7057663984239	8307356046145	1
73	pool1sht8xwep2fd65d9jhvjp2hzzrg0lmpk2xga4lg63a25uv7a0g5u	1000000	8	2	400000000	3722670583915647	3718817589821818	673514404423	3788205719888	4461720124311	1
74	pool1rs6afqrmxvqa524hjnar4pky069zdtrxenvy33wdfej9xs7k0rl	1000000	8	2	500000000	3717506753003425	3714270400911112	1347318908818	7588516512071	8935835420889	1
75	pool1fknsj2mn7x90p4x360wxaxq694uyv3rvma3czv04vt94ulnmhmp	1000000	8	2	600000000	3696758242504176	3696758042225135	0	0	0	1
76	pool14h82efshjpt9rqe3lch85ydun74wt2z4lv58phd7ql9ezwahc8d	1000000	8	2	420000000	3720781114324351	3717322358974879	769599986803	4332098132135	5101698118938	1
77	pool18wpk9px7k4c9vv6g2mgctnneu25xcst7v9mv975kl9fekuwjxhl	1000000	8	2	410000000	3718597327061431	3716114085461882	672857727332	3793749651629	4466607378961	1
78	pool13uytn3qpyf5sv0ne75nzu9wkq603ypmagcu8e2dchlxuzr7urnn	1000000	8	2	410000000	3715907446126818	3712654205867294	481627136573	2711116205251	3192743341824	1
79	pool1va6e8tmmc52pwg9cnv24z8rct5p0h9at7h0n4enpeecpsqsx8cp	1000000	8	8	410000000	3736901741269282	3732270861661496	1343113354067	7546343961338	8889457315405	1
80	pool1vnedz2r7ke2m964j5fq7z0j3pxf566rkca79wp9gj5ng7kh96l6	1000000	9	2	500000000	3693686858460393	3693686557693031	0	0	0	1
81	pool1zgwnt4lqgzvcdmznsx4lhjcylur0rwgzgqj79j3smyahvz3a6qg	1000000	9	2	400000000	3725384548839730	3721832252552791	709245242290	3991448830590	4700694072880	1
82	pool1sht8xwep2fd65d9jhvjp2hzzrg0lmpk2xga4lg63a25uv7a0g5u	1000000	9	2	400000000	3729159484055699	3724331496792979	1508141903443	8470721411055	9978863314498	1
83	pool1rs6afqrmxvqa524hjnar4pky069zdtrxenvy33wdfej9xs7k0rl	1000000	9	2	500000000	3723272343810142	3719169138672903	1420150982413	7986570552231	9406721534644	1
84	pool1fknsj2mn7x90p4x360wxaxq694uyv3rvma3czv04vt94ulnmhmp	1000000	9	2	600000000	3696758242504176	3696758042225135	0	0	0	1
85	pool14h82efshjpt9rqe3lch85ydun74wt2z4lv58phd7ql9ezwahc8d	1000000	9	2	420000000	3732314636757059	3727123180977486	709656288858	3982309628342	4691965917200	1
86	pool18wpk9px7k4c9vv6g2mgctnneu25xcst7v9mv975kl9fekuwjxhl	1000000	9	2	410000000	3725080338595105	3721623367524542	1063636203430	5987980732113	7051616935543	1
87	pool13uytn3qpyf5sv0ne75nzu9wkq603ypmagcu8e2dchlxuzr7urnn	1000000	9	2	410000000	3722390799679566	3718162068856777	799330292461	4493203662630	5292533955091	1
88	pool1va6e8tmmc52pwg9cnv24z8rct5p0h9at7h0n4enpeecpsqsx8cp	1000000	9	8	410000000	3742646267811223	3737150035227808	1061870032351	5956650480210	7018520512561	1
89	pool1vnedz2r7ke2m964j5fq7z0j3pxf566rkca79wp9gj5ng7kh96l6	1000000	10	2	500000000	3693686858460393	3693686557693031	0	0	0	1
90	pool1zgwnt4lqgzvcdmznsx4lhjcylur0rwgzgqj79j3smyahvz3a6qg	1000000	10	2	400000000	3734220387654942	3729341116229782	840872456050	4721551076766	5562423532816	1
91	pool1sht8xwep2fd65d9jhvjp2hzzrg0lmpk2xga4lg63a25uv7a0g5u	1000000	10	2	400000000	3737344893524091	3731283810748489	1402543227481	7860412138242	9262955365723	1
92	pool1rs6afqrmxvqa524hjnar4pky069zdtrxenvy33wdfej9xs7k0rl	1000000	10	2	500000000	3728945825425662	3723988474623985	655094118006	3677354852653	4332448970659	1
93	pool1fknsj2mn7x90p4x360wxaxq694uyv3rvma3czv04vt94ulnmhmp	1000000	10	2	600000000	3696758242504176	3696758042225135	0	0	0	1
94	pool14h82efshjpt9rqe3lch85ydun74wt2z4lv58phd7ql9ezwahc8d	1000000	10	2	420000000	3741772349356154	3735158092882868	1028227737103	5756568570290	6784796307393	1
95	pool18wpk9px7k4c9vv6g2mgctnneu25xcst7v9mv975kl9fekuwjxhl	1000000	10	2	410000000	3733269382903620	3728580652704963	1027628057000	5772621433508	6800249490508	1
96	pool13uytn3qpyf5sv0ne75nzu9wkq603ypmagcu8e2dchlxuzr7urnn	1000000	10	2	410000000	3728694651643134	3723516527980329	1497540789914	8405866786718	9903407576632	1
97	pool1va6e8tmmc52pwg9cnv24z8rct5p0h9at7h0n4enpeecpsqsx8cp	1000000	10	8	410000000	3748917337990083	3742475048351181	1212487900185	6790625631548	8003113531733	1
98	pool1vnedz2r7ke2m964j5fq7z0j3pxf566rkca79wp9gj5ng7kh96l6	1000000	11	2	500000000	3693686858460393	3693686557693031	0	0	0	1
99	pool1zgwnt4lqgzvcdmznsx4lhjcylur0rwgzgqj79j3smyahvz3a6qg	1000000	11	2	400000000	3742527743701087	3736398780214021	663131786385	3714912003697	4378043790082	1
100	pool1sht8xwep2fd65d9jhvjp2hzzrg0lmpk2xga4lg63a25uv7a0g5u	1000000	11	2	400000000	3741806613648402	3735072016468377	663863080617	3715024456690	4378887537307	1
101	pool1rs6afqrmxvqa524hjnar4pky069zdtrxenvy33wdfej9xs7k0rl	1000000	11	2	500000000	3737881660846551	3731576991136056	1327945746085	7439025407203	8766971153288	1
102	pool1fknsj2mn7x90p4x360wxaxq694uyv3rvma3czv04vt94ulnmhmp	1000000	11	2	600000000	3696758242504176	3696758042225135	0	0	0	1
103	pool14h82efshjpt9rqe3lch85ydun74wt2z4lv58phd7ql9ezwahc8d	1000000	11	3	420000000	3749377071922304	3741993215462215	1574516489298	8804342806231	10378859295529	1
104	pool18wpk9px7k4c9vv6g2mgctnneu25xcst7v9mv975kl9fekuwjxhl	1000000	11	2	410000000	3737735990282581	3732374402356592	1326117764890	7441195063046	8767312827936	1
105	pool13uytn3qpyf5sv0ne75nzu9wkq603ypmagcu8e2dchlxuzr7urnn	1000000	11	2	410000000	3731887394984958	3726227644185580	913667849073	5123306031253	6036973880326	1
106	pool1va6e8tmmc52pwg9cnv24z8rct5p0h9at7h0n4enpeecpsqsx8cp	1000000	11	8	410000000	3755303770240218	3747518367247249	1076342608849	6013774714208	7090117323057	1
107	pool1vnedz2r7ke2m964j5fq7z0j3pxf566rkca79wp9gj5ng7kh96l6	1000000	12	2	500000000	3693686858460393	3693686557693031	0	0	0	1
108	pool1zgwnt4lqgzvcdmznsx4lhjcylur0rwgzgqj79j3smyahvz3a6qg	1000000	12	2	400000000	3747228437773967	3740390229044611	996338590556	5575751153335	6572089743891	1
109	pool1sht8xwep2fd65d9jhvjp2hzzrg0lmpk2xga4lg63a25uv7a0g5u	1000000	12	2	400000000	3751785476962900	3743542737879432	1269079882515	7085238209783	8354318092298	1
110	pool1rs6afqrmxvqa524hjnar4pky069zdtrxenvy33wdfej9xs7k0rl	1000000	12	2	500000000	3747288382381195	3739563561688287	544319887497	3040398991509	3584718879006	1
111	pool1fknsj2mn7x90p4x360wxaxq694uyv3rvma3czv04vt94ulnmhmp	1000000	12	2	600000000	3696758242504176	3696758042225135	0	0	0	1
112	pool14h82efshjpt9rqe3lch85ydun74wt2z4lv58phd7ql9ezwahc8d	1000000	12	3	420000000	3754069037839504	3745975525090557	815254665016	4552111494478	5367366159494	1
113	pool18wpk9px7k4c9vv6g2mgctnneu25xcst7v9mv975kl9fekuwjxhl	1000000	12	2	410000000	3744787607218124	3738362383088705	1177477463980	6594600182723	7772077646703	1
114	pool13uytn3qpyf5sv0ne75nzu9wkq603ypmagcu8e2dchlxuzr7urnn	1000000	12	2	410000000	3737179928940049	3730720847848210	363301231189	2032975402497	2396276633686	1
115	pool1va6e8tmmc52pwg9cnv24z8rct5p0h9at7h0n4enpeecpsqsx8cp	1000000	12	8	410000000	3762322290752779	3753475017727459	633475765846	3531984668742	4165460434588	1
116	pool1vnedz2r7ke2m964j5fq7z0j3pxf566rkca79wp9gj5ng7kh96l6	1000000	13	2	500000000	3693686858460393	3693686557693031	0	0	0	1
117	pool1zgwnt4lqgzvcdmznsx4lhjcylur0rwgzgqj79j3smyahvz3a6qg	1000000	13	2	400000000	3752790861306783	3745111780121377	894636251964	4999060675667	5893696927631	1
118	pool1sht8xwep2fd65d9jhvjp2hzzrg0lmpk2xga4lg63a25uv7a0g5u	1000000	13	2	400000000	3761048432328623	3751403150017674	1253236390565	6979823436821	8233059827386	1
119	pool1rs6afqrmxvqa524hjnar4pky069zdtrxenvy33wdfej9xs7k0rl	1000000	13	2	500000000	3751620831351854	3743240916540940	895854431950	4999680581741	5895535013691	1
120	pool1fknsj2mn7x90p4x360wxaxq694uyv3rvma3czv04vt94ulnmhmp	1000000	13	2	600000000	3696758242504176	3696758042225135	0	0	0	1
121	pool14h82efshjpt9rqe3lch85ydun74wt2z4lv58phd7ql9ezwahc8d	1000000	13	3	420000000	3758350809699685	3749229069213635	716223670967	3991758758399	4707982429366	1
122	pool18wpk9px7k4c9vv6g2mgctnneu25xcst7v9mv975kl9fekuwjxhl	1000000	13	2	410000000	3751587856708632	3744135004522213	805194813225	4500833336108	5306028149333	1
123	pool13uytn3qpyf5sv0ne75nzu9wkq603ypmagcu8e2dchlxuzr7urnn	1000000	13	2	410000000	3747083336516681	3739126714634928	717183188516	4004956135961	4722139324477	1
124	pool1va6e8tmmc52pwg9cnv24z8rct5p0h9at7h0n4enpeecpsqsx8cp	1000000	13	8	410000000	3772828408502212	3762768647576707	892976552419	4969418864101	5862395416520	1
125	pool1vnedz2r7ke2m964j5fq7z0j3pxf566rkca79wp9gj5ng7kh96l6	1000000	14	2	500000000	3693686858460393	3693686557693031	0	0	0	1
126	pool1zgwnt4lqgzvcdmznsx4lhjcylur0rwgzgqj79j3smyahvz3a6qg	1000000	14	2	400000000	3757168905096865	3748826692125074	1411759167291	7880844377049	9292603544340	1
127	pool1sht8xwep2fd65d9jhvjp2hzzrg0lmpk2xga4lg63a25uv7a0g5u	1000000	14	2	400000000	3765427319865930	3755118174474364	883087730562	4912051525609	5795139256171	1
128	pool1rs6afqrmxvqa524hjnar4pky069zdtrxenvy33wdfej9xs7k0rl	1000000	14	2	500000000	3760387802505142	3750679941948143	530232386551	2951511011788	3481743398339	1
129	pool1fknsj2mn7x90p4x360wxaxq694uyv3rvma3czv04vt94ulnmhmp	1000000	14	2	600000000	3696758242504176	3696758042225135	0	0	0	1
130	pool14h82efshjpt9rqe3lch85ydun74wt2z4lv58phd7ql9ezwahc8d	1000000	14	3	420000000	3768729668995214	3758033412019866	353304543811	1962719962496	2316024506307	1
131	pool18wpk9px7k4c9vv6g2mgctnneu25xcst7v9mv975kl9fekuwjxhl	1000000	14	2	410000000	3760355169536568	3751576199585259	794093741527	4428566678678	5222660420205	1
132	pool13uytn3qpyf5sv0ne75nzu9wkq603ypmagcu8e2dchlxuzr7urnn	1000000	14	2	410000000	3753120310397007	3744250020666181	1326041506222	7395171993316	8721213499538	1
133	pool1va6e8tmmc52pwg9cnv24z8rct5p0h9at7h0n4enpeecpsqsx8cp	1000000	14	8	410000000	3779918525825269	3768782422290915	1408962380195	7827713184541	9236675564736	1
134	pool1vnedz2r7ke2m964j5fq7z0j3pxf566rkca79wp9gj5ng7kh96l6	1000000	15	2	500000000	3693686858460393	3693686557693031	0	0	0	1
135	pool1zgwnt4lqgzvcdmznsx4lhjcylur0rwgzgqj79j3smyahvz3a6qg	1000000	15	2	400000000	3763740994840756	3754402443278409	782508143479	4359708376349	5142216519828	1
136	pool1sht8xwep2fd65d9jhvjp2hzzrg0lmpk2xga4lg63a25uv7a0g5u	1000000	15	2	400000000	3773781637958228	3762203412684147	869946865015	4828425329943	5698372194958	1
137	pool1rs6afqrmxvqa524hjnar4pky069zdtrxenvy33wdfej9xs7k0rl	1000000	15	2	500000000	3763972521384148	3753720340939652	1131604413882	6295584786740	7427189200622	1
138	pool1fknsj2mn7x90p4x360wxaxq694uyv3rvma3czv04vt94ulnmhmp	1000000	15	2	600000000	3696758242504176	3696758042225135	0	0	0	1
139	pool14h82efshjpt9rqe3lch85ydun74wt2z4lv58phd7ql9ezwahc8d	1000000	15	3	420000000	3774091145917605	3762579634277241	521988481805	2896754445827	3418742927632	1
140	pool18wpk9px7k4c9vv6g2mgctnneu25xcst7v9mv975kl9fekuwjxhl	1000000	15	2	410000000	3768127247183271	3758170799767982	695415310176	3870123153878	4565538464054	1
141	pool13uytn3qpyf5sv0ne75nzu9wkq603ypmagcu8e2dchlxuzr7urnn	1000000	15	2	410000000	3755516587030693	3746282996068678	1393746762084	7767991436000	9161738198084	1
142	pool1va6e8tmmc52pwg9cnv24z8rct5p0h9at7h0n4enpeecpsqsx8cp	1000000	15	9	410000000	3784089874489891	3772320295189691	520801281556	2888908276435	3409709557991	1
\.


--
-- Data for Name: stake_pool; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_pool (id, status, last_registration_id, last_retirement_id) FROM stdin;
pool1vnedz2r7ke2m964j5fq7z0j3pxf566rkca79wp9gj5ng7kh96l6	retiring	9860000000000	10230000000000
pool1zgwnt4lqgzvcdmznsx4lhjcylur0rwgzgqj79j3smyahvz3a6qg	retiring	12220000000000	12680000000000
pool1sht8xwep2fd65d9jhvjp2hzzrg0lmpk2xga4lg63a25uv7a0g5u	active	1030000000000	\N
pool1rs6afqrmxvqa524hjnar4pky069zdtrxenvy33wdfej9xs7k0rl	active	2100000000000	\N
pool1fknsj2mn7x90p4x360wxaxq694uyv3rvma3czv04vt94ulnmhmp	active	3440000000000	\N
pool14h82efshjpt9rqe3lch85ydun74wt2z4lv58phd7ql9ezwahc8d	active	4250000000000	\N
pool18wpk9px7k4c9vv6g2mgctnneu25xcst7v9mv975kl9fekuwjxhl	active	5210000000000	\N
pool13uytn3qpyf5sv0ne75nzu9wkq603ypmagcu8e2dchlxuzr7urnn	active	6070000000000	\N
pool1va6e8tmmc52pwg9cnv24z8rct5p0h9at7h0n4enpeecpsqsx8cp	active	7350000000000	\N
pool17q7k3syvupxcm6cx8ayt0y66craxuhgq6rt7ecd6na0g7dtggyf	retired	8070000000000	8890000000000
pool1z9jkqfh38ujlx3a3knxfzts2xkv4uj9l3uwuk0g28sa5gxwfy0s	retired	10840000000000	11410000000000
pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4	activating	172310000000000	\N
pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq	activating	173130000000000	\N
\.


--
-- Name: pool_metadata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pool_metadata_id_seq', 8, true);


--
-- Name: pool_rewards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pool_rewards_id_seq', 142, true);


--
-- Name: job job_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.job
    ADD CONSTRAINT job_pkey PRIMARY KEY (id);


--
-- Name: schedule schedule_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.schedule
    ADD CONSTRAINT schedule_pkey PRIMARY KEY (name);


--
-- Name: subscription subscription_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.subscription
    ADD CONSTRAINT subscription_pkey PRIMARY KEY (event, name);


--
-- Name: version version_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.version
    ADD CONSTRAINT version_pkey PRIMARY KEY (version);


--
-- Name: block_data PK_block_data_block_height; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.block_data
    ADD CONSTRAINT "PK_block_data_block_height" PRIMARY KEY (block_height);


--
-- Name: block PK_block_slot; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.block
    ADD CONSTRAINT "PK_block_slot" PRIMARY KEY (slot);


--
-- Name: current_pool_metrics PK_current_pool_metrics_stake_pool_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_pool_metrics
    ADD CONSTRAINT "PK_current_pool_metrics_stake_pool_id" PRIMARY KEY (stake_pool_id);


--
-- Name: pool_delisted PK_pool_delisted_stake_pool_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_delisted
    ADD CONSTRAINT "PK_pool_delisted_stake_pool_id" PRIMARY KEY (stake_pool_id);


--
-- Name: pool_metadata PK_pool_metadata_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_metadata
    ADD CONSTRAINT "PK_pool_metadata_id" PRIMARY KEY (id);


--
-- Name: pool_registration PK_pool_registration_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_registration
    ADD CONSTRAINT "PK_pool_registration_id" PRIMARY KEY (id);


--
-- Name: pool_retirement PK_pool_retirement_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_retirement
    ADD CONSTRAINT "PK_pool_retirement_id" PRIMARY KEY (id);


--
-- Name: pool_rewards PK_pool_rewards_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_rewards
    ADD CONSTRAINT "PK_pool_rewards_id" PRIMARY KEY (id);


--
-- Name: stake_pool PK_stake_pool_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stake_pool
    ADD CONSTRAINT "PK_stake_pool_id" PRIMARY KEY (id);


--
-- Name: pool_metadata REL_pool_metadata_pool_update_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_metadata
    ADD CONSTRAINT "REL_pool_metadata_pool_update_id" UNIQUE (pool_update_id);


--
-- Name: stake_pool REL_stake_pool_last_registration_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stake_pool
    ADD CONSTRAINT "REL_stake_pool_last_registration_id" UNIQUE (last_registration_id);


--
-- Name: stake_pool REL_stake_pool_last_retirement_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stake_pool
    ADD CONSTRAINT "REL_stake_pool_last_retirement_id" UNIQUE (last_retirement_id);


--
-- Name: pool_rewards UQ_pool_rewards_epoch_no_stake_pool_id}; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_rewards
    ADD CONSTRAINT "UQ_pool_rewards_epoch_no_stake_pool_id}" UNIQUE (epoch_no, stake_pool_id);


--
-- Name: archive_archivedon_idx; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX archive_archivedon_idx ON pgboss.archive USING btree (archivedon);


--
-- Name: archive_id_idx; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX archive_id_idx ON pgboss.archive USING btree (id);


--
-- Name: job_fetch; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX job_fetch ON pgboss.job USING btree (name text_pattern_ops, startafter) WHERE (state < 'active'::pgboss.job_state);


--
-- Name: job_name; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX job_name ON pgboss.job USING btree (name text_pattern_ops);


--
-- Name: job_singleton_queue; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE UNIQUE INDEX job_singleton_queue ON pgboss.job USING btree (name, singletonkey) WHERE ((state < 'active'::pgboss.job_state) AND (singletonon IS NULL) AND (singletonkey ~~ '\_\_pgboss\_\_singleton\_queue%'::text));


--
-- Name: job_singletonkey; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE UNIQUE INDEX job_singletonkey ON pgboss.job USING btree (name, singletonkey) WHERE ((state < 'completed'::pgboss.job_state) AND (singletonon IS NULL) AND (NOT (singletonkey ~~ '\_\_pgboss\_\_singleton\_queue%'::text)));


--
-- Name: job_singletonkeyon; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE UNIQUE INDEX job_singletonkeyon ON pgboss.job USING btree (name, singletonon, singletonkey) WHERE (state < 'expired'::pgboss.job_state);


--
-- Name: job_singletonon; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE UNIQUE INDEX job_singletonon ON pgboss.job USING btree (name, singletonon) WHERE ((state < 'expired'::pgboss.job_state) AND (singletonkey IS NULL));


--
-- Name: IDX_block_hash; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_block_hash" ON public.block USING btree (hash);


--
-- Name: IDX_block_height; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_block_height" ON public.block USING btree (height);


--
-- Name: IDX_pool_metadata_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_pool_metadata_name" ON public.pool_metadata USING btree (name);


--
-- Name: IDX_pool_metadata_ticker; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_pool_metadata_ticker" ON public.pool_metadata USING btree (ticker);


--
-- Name: IDX_stake_pool_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_stake_pool_status" ON public.stake_pool USING btree (status);


--
-- Name: job job_block_slot_fkey; Type: FK CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.job
    ADD CONSTRAINT job_block_slot_fkey FOREIGN KEY (block_slot) REFERENCES public.block(slot) ON DELETE CASCADE;


--
-- Name: block_data FK_block_data_block_height; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.block_data
    ADD CONSTRAINT "FK_block_data_block_height" FOREIGN KEY (block_height) REFERENCES public.block(height) ON DELETE CASCADE;


--
-- Name: current_pool_metrics FK_current_pool_metrics_stake_pool_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_pool_metrics
    ADD CONSTRAINT "FK_current_pool_metrics_stake_pool_id" FOREIGN KEY (stake_pool_id) REFERENCES public.stake_pool(id) ON DELETE CASCADE;


--
-- Name: pool_metadata FK_pool_metadata_pool_update_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_metadata
    ADD CONSTRAINT "FK_pool_metadata_pool_update_id" FOREIGN KEY (pool_update_id) REFERENCES public.pool_registration(id) ON DELETE CASCADE;


--
-- Name: pool_metadata FK_pool_metadata_stake_pool_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_metadata
    ADD CONSTRAINT "FK_pool_metadata_stake_pool_id" FOREIGN KEY (stake_pool_id) REFERENCES public.stake_pool(id);


--
-- Name: pool_registration FK_pool_registration_block_slot; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_registration
    ADD CONSTRAINT "FK_pool_registration_block_slot" FOREIGN KEY (block_slot) REFERENCES public.block(slot) ON DELETE CASCADE;


--
-- Name: pool_registration FK_pool_registration_stake_pool_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_registration
    ADD CONSTRAINT "FK_pool_registration_stake_pool_id" FOREIGN KEY (stake_pool_id) REFERENCES public.stake_pool(id) ON DELETE CASCADE;


--
-- Name: pool_retirement FK_pool_retirement_block_slot; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_retirement
    ADD CONSTRAINT "FK_pool_retirement_block_slot" FOREIGN KEY (block_slot) REFERENCES public.block(slot) ON DELETE CASCADE;


--
-- Name: pool_retirement FK_pool_retirement_stake_pool_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_retirement
    ADD CONSTRAINT "FK_pool_retirement_stake_pool_id" FOREIGN KEY (stake_pool_id) REFERENCES public.stake_pool(id) ON DELETE CASCADE;


--
-- Name: pool_rewards FK_pool_rewards_stake_pool_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_rewards
    ADD CONSTRAINT "FK_pool_rewards_stake_pool_id" FOREIGN KEY (stake_pool_id) REFERENCES public.stake_pool(id);


--
-- Name: stake_pool FK_stake_pool_last_registration_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stake_pool
    ADD CONSTRAINT "FK_stake_pool_last_registration_id" FOREIGN KEY (last_registration_id) REFERENCES public.pool_registration(id) ON DELETE SET NULL;


--
-- Name: stake_pool FK_stake_pool_last_retirement_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stake_pool
    ADD CONSTRAINT "FK_stake_pool_last_retirement_id" FOREIGN KEY (last_retirement_id) REFERENCES public.pool_retirement(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

