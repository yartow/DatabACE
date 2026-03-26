--
-- PostgreSQL database dump
--


-- Dumped from database version 16.10
-- Dumped by pg_dump version 16.10

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
-- Name: pace_version_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.pace_version_type AS ENUM (
    'PACE',
    'Score Key',
    'Material'
);


--
-- Name: user_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_role AS ENUM (
    'teacher',
    'parent'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: courses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.courses (
    id integer NOT NULL,
    ace_alias text,
    level integer,
    subject_id integer,
    subject_group_id integer,
    course_type text,
    pass_threshold real,
    icce_alias text,
    certificate_name text,
    remarks character varying(3000),
    active integer DEFAULT 1 NOT NULL,
    icce_id character varying(10),
    credits real
);


--
-- Name: dates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dates (
    id integer NOT NULL,
    date integer,
    weekend integer,
    holiday integer,
    day_off integer,
    week_day text,
    remark text,
    term integer,
    term_week integer,
    week integer,
    year_term text
);


--
-- Name: enrollments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.enrollments (
    id integer NOT NULL,
    student_id integer NOT NULL,
    course_id integer NOT NULL,
    date_started text,
    date_ended text,
    grade real,
    remarks text,
    number character varying(10) NOT NULL,
    term smallint,
    is_repeat boolean DEFAULT false NOT NULL,
    year_term text
);


--
-- Name: enrollments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.enrollments ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.enrollments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: families; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.families (
    id integer NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    address text,
    city text,
    postal_code text
);


--
-- Name: families_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.families ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.families_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: inventory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventory (
    id integer NOT NULL,
    pace_versions_id integer NOT NULL,
    student_id integer NOT NULL,
    number_in_possession smallint
);


--
-- Name: inventory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.inventory ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.inventory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: invitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invitations (
    id integer NOT NULL,
    token text NOT NULL,
    role public.user_role NOT NULL,
    family_id integer,
    email text,
    created_by text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    used_by text,
    used_at timestamp without time zone,
    expires_at timestamp without time zone NOT NULL
);


--
-- Name: invitations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.invitations ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.invitations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: order_list_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_list_items (
    id integer NOT NULL,
    order_list_id integer NOT NULL,
    pace_id integer,
    course_id integer,
    enrollment_number character varying(10),
    student_id integer NOT NULL,
    enrollment_id integer,
    quantity smallint DEFAULT 1 NOT NULL,
    initially_to_order smallint,
    from_inventory smallint,
    final_to_order smallint,
    delivered boolean DEFAULT false NOT NULL
);


--
-- Name: order_list_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.order_list_items ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.order_list_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: order_lists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_lists (
    id integer NOT NULL,
    name text NOT NULL,
    term smallint,
    year_term text,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: order_lists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.order_lists ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.order_lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: pace_courses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pace_courses (
    id integer NOT NULL,
    pace_id integer NOT NULL,
    course_id integer NOT NULL,
    alias integer,
    number character varying(10)
);


--
-- Name: pace_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pace_versions (
    id integer NOT NULL,
    year_revised integer,
    type public.pace_version_type,
    edition smallint,
    pace_id integer NOT NULL
);


--
-- Name: pace_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.pace_versions ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.pace_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: paces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.paces (
    id integer NOT NULL,
    number integer,
    edition integer,
    edition_order integer,
    type text,
    weight smallint,
    star_value smallint DEFAULT 1
);


--
-- Name: parents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parents (
    id integer NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    phone_number text,
    family_id integer
);


--
-- Name: parents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.parents ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.parents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: personnel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.personnel (
    id integer NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    "group" text NOT NULL,
    type text NOT NULL,
    rank integer,
    email text,
    is_admin boolean DEFAULT false NOT NULL
);


--
-- Name: personnel_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.personnel ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.personnel_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    sid character varying NOT NULL,
    sess jsonb NOT NULL,
    expire timestamp without time zone NOT NULL
);


--
-- Name: students; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.students (
    id integer NOT NULL,
    surname text NOT NULL,
    first_names text,
    call_name text NOT NULL,
    alias text NOT NULL,
    is_dyslexic boolean DEFAULT false NOT NULL,
    active boolean DEFAULT true NOT NULL,
    reason_inactive text,
    remarks text,
    date_of_birth text,
    family_id integer,
    "group" text
);


--
-- Name: students_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.students ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.students_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: subject_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subject_groups (
    id integer NOT NULL,
    subject_group text NOT NULL,
    remarks character varying(1200)
);


--
-- Name: subjects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subjects (
    id integer NOT NULL,
    subject text NOT NULL,
    color_id integer,
    color text,
    color_code text,
    subject_group_id integer
);


--
-- Name: supplementary_activities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.supplementary_activities (
    id integer NOT NULL,
    student_id integer NOT NULL,
    year_term text,
    term integer,
    grade character varying(4),
    activity text NOT NULL
);


--
-- Name: supplementary_activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.supplementary_activities ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.supplementary_activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: user_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_profiles (
    id integer NOT NULL,
    user_id text NOT NULL,
    role public.user_role DEFAULT 'parent'::public.user_role NOT NULL,
    family_id integer,
    is_admin boolean DEFAULT false NOT NULL,
    first_name text,
    last_name text,
    email text
);


--
-- Name: user_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.user_profiles ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.user_profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    email character varying,
    first_name character varying,
    last_name character varying,
    profile_image_url character varying,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Data for Name: courses; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (148, 'US History', 10, 6, 2, 'Further Credit Option', 0.8, 'US History', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (159, 'ICCE Physical Science', 9, 5, 2, 'Core', 0.8, 'CEE Physical Science I-B', 'Physical Science I', 'Dit is verplicht vanaf 2024-01 voor General. De formele naam is "ICCE …" maar de publisher is "CEE". Oorspronkelijk heeft Afrika (AEE) dit vak gemaakt, maar Europe (CEE) heeft hier weer een selectie van gemaakt. De originele versie is te vinden in ID=160. Dit bestaat uit PACEs 85–88, 97–100.  General Overview  PACE 1085 - Atoms, Elements, Sub-Atomic Particles - Decomposition, Particle Model, Change of State PACE 1086 - Particle Model, Density, Expansion - Chemical Reactions, Careers in Chemistry PACE 1087 - Static Electricity, Electric Discharge - Electrical Energy Transfer, Circuits, History - Careers in Electricity PACE 1088 - Light Radiation, Spectrum, Reflection - Opaque/Transparent Substances, Careers PACE 1097 - Compounds, Periodic Table, Chemical Reactions - Oxygen Reactions, Acids, Bases, pH PACE 1098 - Acid-Base Reactions, Neutralization - Reactions with Metals, Careers in Chemistry PACE 1099 - Types of Forces, Energy and Grid - Electricity Generation, Consumption, Careers PACE 1100 - Electric Cells, Resistance, Circuits - Safety, Wiring, National Grid', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (80, 'World Geography', 9, 6, 2, 'Core', 0.8, 'Social Studies Level 9 World Geography', 'World Geography', NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (91, 'History of Civilisation I', 10, 6, 2, 'Core', 0.8, 'Social Studies Level 10', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (50, 'Social Studies Level 7', 7, 6, 2, 'Core', 0.8, 'Social Studies Level 7', NULL, 'Deze zes PACEs gaan over "Career" en de volgende zes (79-84) over "American Constitution", maar die worden niet gedaan in Nederland. In plaats daarvan worden drie PACEs "Staatsinrichting" gedaan.', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (58, 'British and European History', 8, 6, 1, 'Further Credit Option', 0.8, 'Social Studies Level 8 British and European History', NULL, 'SS Level 8 bestaat uit History en Geography. Binnen History moet gekozen worden voor dit vak (British European) OF voor American History. Daarna volgt World Geography', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (95, 'Old Testament Survey', 10, 7, 1, 'Core', 0.8, 'Old Testament Survey', 'Old Testament Survey', 'Ik kan alleen PACEs 1-10 vinden, zijn waarschijnlijk oude edities', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (102, 'ICCE Literature 10 Part 1', 10, 4, 2, 'Further Credit Option', 0.8, 'ICCE Literature 10 Part 1', NULL, 'Beide vakken hebben dezelfde naam. Specification is niet duidelijk, is moeilijk met twee karakters. Beter is "I10" vs "I09". ', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (53, 'General Maths', 8, 1, 2, 'Core', 0.8, 'General Maths', 'General Maths', NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (1000, 'HSK 3 Chinese', 8, 2, 4, 'Further Credit Option', 0.8, 'HSK 3 Chinese', 'HSK 3 Chinese', 'To Verify', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (114, 'N.T. Greek II', 12, 2, 2, 'Further Credit Option', 0.8, 'N.T. Greek II', NULL, 'Nieuwe nummering?', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (118, 'American History', 8, 6, 2, 'Further Credit Option', 0.8, 'Social Studies Level 8 American History', NULL, 'Credit Option', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (120, 'Collectivism', 12, 6, 1, 'Further Credit Option', 0.8, 'Social Studies Level 12 Collectivism', NULL, 'Over communisme en zo', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (123, 'Christian Counselling II', 12, 7, 1, 'Further Credit Option', 0.8, 'Christian Counselling II', NULL, 'Apologetics option only?', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (125, 'Life of Christ II', 12, 7, 1, 'Further Credit Option', 0.8, 'Life of Christ II', NULL, 'Only possible to choose this as an option for Apologetics III', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (126, 'New Testament Church History II', 12, 7, 1, 'Further Credit Option', 0.8, 'New Testament Church History II', NULL, 'Only possible to choose this as an option for Apologetics III', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (127, 'English Composition I', 10, 2, 2, 'Core', 0.8, 'English Composition I', NULL, 'Welk level? Staat niet op het blad', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (144, 'Sciences Essay Advanced', 12, 5, 7, 'CourseWork', 0.8, 'Sciences Essay Advanced', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (145, 'English III Dissertation', 12, 2, 7, 'CourseWork', 0.8, 'English III Dissertation', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (147, 'UK Social Studies', 5, 6, 2, 'Core', 0.8, 'Social Studies Level 5 UK', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (149, 'Animal Science', 2, 5, 2, 'Core', 0.8, 'Science Level 2 Animal', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (162, 'Biographies of Christians', 12, 7, 1, 'Further Credit Option', 0.8, 'Biographies of Christians', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (163, 'College Old Testament Survey', 12, 7, 1, 'Further Credit Option', 0.8, 'College Old Testament Survey', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (164, 'Civics', 12, 6, 2, 'Further Credit Option', 0.8, 'Social Studies Level 12', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (165, 'Economics', 12, 6, 2, 'Further Credit Option', 0.8, 'Social Studies Level 12', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (155, 'Algebra I & Geometry II', 12, 1, 2, 'Core', 0.8, 'Algebra I & Geometry II', NULL, 'De naamgeving is misleidend, er staat "Geometry II" maar hiermee wordt bedoeld de tweede helft van Geometry', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (59, 'World History', 10, 6, 1, 'Further Credit Option', 0.8, 'Social Studies Level 9 World History', NULL, 'Dit was tot 1/1/2024 een optie voor het Enrollment-Course "British and European History /  World History" binnen General (level 8), waarbij de leerling mag kiezen tussen Eur. of World History (alleen de 3rd Edition mocht dan gebruikt worden). Na deze periode is dit een keuzevak geworden binnen Intermediate (level 10) en alleen met de 4th Editions.', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (121, 'History of Civilisation II', 11, 6, 2, 'Core', 0.8, 'Social Studies Level 11', NULL, 'Dit staat ook onder FCO, maar is verplicht!?', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (12, 'Literature and Creative Writing Level 2', 2, 4, 2, 'Core', 0.8, 'Literature and Creative Writing Level 2', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (13, 'Science Level 2', 2, 5, 2, 'Core', 0.8, 'Science Level 2', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (14, 'Social Studies Level 2', 2, 6, 2, 'Core', 0.8, 'Social Studies Level 2', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (15, 'Bible Reading Level 2', 2, 7, 1, 'Core', 0.8, 'Bible Reading Level 2', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (16, 'Maths Level 3', 3, 1, 2, 'Core', 0.8, 'Maths Level 3', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (17, 'English Level 3', 3, 2, 2, 'Core', 0.8, 'English Level 3', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (18, 'Word Building Level 3', 3, 3, 2, 'Core', 0.9, 'Word Building Level 3', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (19, 'Literature and Creative Writing Level 3', 3, 4, 2, 'Core', 0.8, 'Literature and Creative Writing Level 3', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (20, 'Science Level 3', 3, 5, 2, 'Core', 0.8, 'Science Level 3', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (21, 'Social Studies Level 3', 3, 6, 2, 'Core', 0.8, 'Social Studies Level 3', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (22, 'Bible Reading Level 3', 3, 7, 1, 'Core', 0.8, 'Bible Reading Level 3', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (23, 'Maths Level 4', 4, 1, 2, 'Core', 0.8, 'Maths Level 4', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (24, 'English Level 4', 4, 2, 2, 'Core', 0.8, 'English Level 4', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (25, 'Word Building Level 4', 4, 3, 2, 'Core', 0.9, 'Word Building Level 4', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (26, 'Literature and Creative Writing Level 4', 4, 4, 2, 'Core', 0.8, 'Literature and Creative Writing Level 4', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (27, 'Science Level 4', 4, 5, 2, 'Core', 0.8, 'Science Level 4', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (28, 'Social Studies Level 4', 4, 6, 2, 'Core', 0.8, 'Social Studies Level 4', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (29, 'Bible Reading Level 4', 4, 7, 1, 'Core', 0.8, 'Bible Reading Level 4', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (30, 'Maths Level 5', 5, 1, 2, 'Core', 0.8, 'Maths Level 5', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (31, 'English Level 5', 5, 2, 2, 'Core', 0.8, 'English Level 5', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (32, 'Word Building Level 5', 5, 3, 2, 'Core', 0.9, 'Word Building Level 5', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (33, 'Literature and Creative Writing Level 5', 5, 4, 2, 'Core', 0.8, 'Literature and Creative Writing Level 5', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (34, 'Science Level 5', 5, 5, 2, 'Core', 0.8, 'Science Level 5', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (35, 'Social Studies Level 5', 5, 6, 2, 'Core', 0.8, 'Social Studies Level 5', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (36, 'Bible Reading Level 5', 5, 7, 1, 'Core', 0.8, 'Bible Reading Level 5', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (37, 'Maths Level 6', 6, 1, 2, 'Core', 0.8, 'Maths Level 6', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (38, 'English Level 6', 6, 2, 2, 'Core', 0.8, 'English Level 6', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (40, 'Literature and Creative Writing Level 6', 6, 4, 2, 'Core', 0.8, 'Literature and Creative Writing Level 6', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (42, 'Social Studies Level 6', 6, 6, 2, 'Core', 0.8, 'Social Studies Level 6', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (43, 'Bible Reading Level 6', 6, 7, 1, 'Core', 0.8, 'Bible Reading Level 6', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (44, 'Maths Level 7', 7, 1, 2, 'Core', 0.8, 'Maths Level 7', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (45, 'English Level 7', 7, 2, 2, 'Core', 0.8, 'English Level 7', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (46, 'Beginning Art', 7, 3, 2, 'Core', 0.8, 'Beginning Art', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (47, 'Word Building Level 7', 7, 3, 2, 'Core', 0.9, 'Word Building Level 7', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (49, 'Science Level 7', 7, 5, 2, 'Core', 0.8, 'Science Level 7', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (55, 'Word Building Level 8', 8, 3, 1, 'Core', 0.9, 'Word Building Level 8', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (62, 'English I', 9, 2, 1, 'Core', 0.8, 'English I', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (63, 'French I', 9, 2, 1, 'Further Credit Option', 0.8, 'French I', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (65, 'Spanish I', 9, 2, 1, 'Further Credit Option', 0.8, 'Spanish I', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (66, 'Advanced Art', 9, 8, 2, 'Further Credit Option', 0.8, 'Advanced Art', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (67, 'Complete Art', 9, 10, 2, 'Further Credit Option', 0.8, 'Complete Art', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (69, 'Music', 9, 10, 3, 'Further Credit Option', 0.8, 'Music', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (70, 'Music Theory/Performance Grade 5', 9, 10, 3, 'Further Credit Option', 0.8, 'Music Theory/Performance Grade 5', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (72, 'Speech', 9, 3, 3, 'Core', 0.8, 'Speech', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (75, 'Biology / Science Level 9', 9, 5, 2, 'Core', 0.8, 'Science Level 9', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (76, 'Health', 9, 5, 2, 'Further Credit Option', 0.8, 'Health', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (77, 'Nutrition Science', 9, 5, 2, 'Further Credit Option', 0.8, 'Nutrition Science', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (79, 'A.C.E. Training', 9, 10, 4, 'Further Credit Option', 0.8, 'A.C.E. Training', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (82, 'Missions', 9, 7, 1, 'Further Credit Option', 0.8, 'Missions', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (73, 'ICCE Literature Level 9', 9, 4, 2, 'Core', 0.8, 'ICCE Literature Level 9', NULL, 'Voor Essays vanaf een bepaald niveau worden er geen sterren gegeven. Dit vak heeft geen lesmateriaal. Het zijn gewoon vier boeken waar een essay voor moet worden geschreven.', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (84, 'A.C.E. Training + 30 hours of service', 9, 10, 4, 'Further Credit Option', 0.8, 'A.C.E. Training + 30 hours of service', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (87, 'English II', 10, 2, 2, 'Core', 0.8, 'English II', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (89, 'Music Theory/Performance Grade 6', 10, 10, 3, 'Further Credit Option', 0.8, 'Music Theory/Performance Grade 6', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (54, 'General English', 8, 2, 1, 'Core', 0.8, 'General English', 'General English', NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (57, 'Earth Science', 8, 5, 2, 'Core', 0.8, 'Science Level 8', 'Earth Science', NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (64, 'Rosetta Stone Level 9', 9, 2, 1, 'Further Credit Option', 0.8, 'Rosetta Stone Level 9', NULL, 'Extended Levels only', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (60, 'New Testament Survey', 8, 7, 1, 'Core', 0.8, 'New Testament Survey', 'New Testament Survey', NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (61, 'Algebra I', 9, 1, 1, 'Core', 0.8, 'Algebra I', 'Maths I', NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (68, 'Word Building / Etymology', 9, 3, 1, 'Core', 0.9, 'Word Building Level 9', 'Etymology', NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (74, 'Astronomy', 9, 5, 2, 'Further Credit Option', 0.8, 'Astronomy', 'Astronomy', NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (85, 'ECDL Course', 9, 10, 3, 'Core', 0.8, 'ECDL Course', NULL, 'Wat is dit? ', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (86, 'Geometry', 10, 1, 2, 'Core', 0.8, 'Geometry', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (48, 'Literature Level 7', 7, 4, 2, 'Core', 0.8, 'Literature Level 7', NULL, 'Alleen even getallen hebben PACE beschikbaar', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (51, 'Staatsinrichting', 7, 6, 2, 'Core', 0.8, 'Staatsinrichting', NULL, 'Bij bestellen rekening houden dat dit 1 boek is. ', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (52, 'Bible Reading Level 7', 7, 7, 2, 'Core', 0.8, 'Bible Reading Level 7', NULL, 'Dit bestaat nog niet. Misschien komt er later nog materiaal beschikbaar voor dit niveau. ', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (56, 'Literature Level 8', 8, 4, 1, 'Core', 0.8, 'Literature Level 8', NULL, 'Alleen even getallen hebben PACE beschikbaar', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (71, 'Music Theory/Performance', 9, 10, 3, 'Further Credit Option', 0.8, 'Music Theory/Performance', NULL, 'Is duplicate of 70? Or perhaps the other one is theory and this one is performance', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (78, 'Sport + Health', 9, 5, 3, 'Further Credit Option', 0.8, 'Sport + Health', NULL, 'Is een combinatie vak dat alleen met Health samen gedaan kan worden? ON HOLD Informatie moet nog bevestigd worden', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (81, 'Apologetics I', 9, 7, 1, 'Core', 0.8, 'Apologetics I', NULL, 'Dit zijn resp. PACE''s 97,102 in de oude editie (2018). 2 sterren voor de twee toetsen, en 1 ster voor het essay', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (88, 'Rosetta Stone Level 10', 10, 2, 2, 'Further Credit Option', 0.8, 'Rosetta Stone Level 10', NULL, 'Each six stars', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (96, 'Auto Mechanics', 10, 10, 3, 'Further Credit Option', 0.8, 'Auto Mechanics', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (98, 'Algebra II', 11, 1, 2, 'Core', 0.8, 'Algebra II', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (99, 'British Literature', 11, 4, 2, 'Core', 0.8, 'British Literature', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (101, 'English III', 11, 2, 2, 'Core', 0.8, 'English III', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (104, 'N.T. Greek I', 11, 2, 2, 'Further Credit Option', 0.8, 'N.T. Greek I', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (105, 'Chemistry', 11, 5, 2, 'Core', 0.8, 'Science Level 11', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (107, 'Accounting (US)', 12, 1, 3, 'Further Credit Option', 0.8, 'Accounting (US)', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (108, 'College Maths I', 12, 1, 2, 'Further Credit Option', 0.8, 'College Maths I', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (109, 'College Maths II', 12, 1, 2, 'Further Credit Option', 0.8, 'College Maths II', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (110, 'Higher Maths', 12, 1, 2, 'Further Credit Option', 0.8, 'Higher Maths', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (111, 'Trigonometry', 12, 1, 2, 'Further Credit Option', 0.8, 'Trigonometry', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (115, 'Music Theory/Performance Grade 7/8', 12, 10, 3, 'Further Credit Option', 0.8, 'Music Theory/Performance Grade 7/8', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (116, 'College Physical Science', 12, 5, 2, 'Further Credit Option', 0.8, 'College Physical Science', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (117, 'Physics', 12, 5, 2, 'Further Credit Option', 0.8, 'Science Level 12', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (122, 'US Constitution', 12, 6, 2, 'Further Credit Option', 0.8, 'Social Studies Level 12 US Constitution', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (129, 'ICCE Biology', 9, 5, 2, 'Further Credit Option', 0.8, 'ICCE Biology', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (130, 'Biology Apologia', 10, 5, 2, 'Further Credit Option', 0.8, 'Biology Apologia', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (131, 'Life of Christ', 12, 7, 1, 'Further Credit Option', 0.8, 'Life of Christ', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (133, 'Social Studies Essay General', 9, 6, 7, 'CourseWork', 0.8, 'Social Studies Essay General', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (134, 'Science Essay General', 9, 5, 7, 'CourseWork', 0.8, 'Science Essay General', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (135, 'Biblical Studies Essay Intermediate', 10, 7, 7, 'CourseWork', 0.8, 'Biblical Studies Essay Intermediate', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (136, 'English Essay Intermediate', 10, 2, 7, 'CourseWork', 0.8, 'English Essay Intermediate', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (137, 'Social Studies Essay Intermediate', 10, 6, 7, 'CourseWork', 0.8, 'Social Studies Essay Intermediate', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (138, 'Science Essay Intermediate', 10, 5, 7, 'CourseWork', 0.8, 'Science Essay Intermediate', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (92, 'Apologetics II', 10, 7, 1, 'Further Credit Option', 0.8, 'Apologetics II', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (106, 'New Testament Church History', 12, 7, 1, 'Core', 0.8, 'New Testament Church History', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (132, 'Dutch Language Staatsexamen VMBO', 9, 2, 2, 'Further Credit Option', 0.55, 'Dutch Language Staatsexamen VMBO', NULL, 'To verify', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (100, 'Dutch Language Staatsexamen HAVO', 11, 2, 2, 'Core', 0.55, 'Dutch Language Staatsexamen HAVO', NULL, 'To Verify Staatsexamen Havo, where is VWO?', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (128, 'Rosetta Stone Spanish', NULL, NULL, NULL, 'Further Credit Option', 0.8, 'Rosetta Stone Spanish', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (83, 'Successful Living', 9, 7, 1, 'Core', 0.8, 'Successful Living', NULL, 'Vroeger kwam dit na BS Level 9 (NTS). Dit is vanaf 2024-01 een keuze voor General en Intermediate geworden (verplichting is vervallen). In plaats daarvan is ICCE Phys Science verplicht geworden in Level 9.', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (1, 'Maths Reading Readiness', 0, 1, 2, 'Core', 0.8, 'Maths Reading Readiness', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (2, 'Maths Level 1', 1, 1, 2, 'Core', 0.8, 'Maths Level 1', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (3, 'English Level 1', 1, 2, 2, 'Core', 0.8, 'English Level 1', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (4, 'Word Building Level 1', 1, 3, 2, 'Core', 0.9, 'Word Building Level 1', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (5, 'Literature and Creative Writing Level 1', 1, 4, 2, 'Core', 0.8, 'Literature and Creative Writing Level 1', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (6, 'Science Level 1', 1, 5, 2, 'Core', 0.8, 'Science Level 1', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (7, 'Social Studies Level 1', 1, 6, 2, 'Core', 0.8, 'Social Studies Level 1', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (8, 'Bible Reading Level 1', 1, 7, 1, 'Core', 0.8, 'Bible Reading Level 1', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (9, 'Maths Level 2', 2, 1, 2, 'Core', 0.8, 'Maths Level 2', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (10, 'English Level 2', 2, 2, 2, 'Core', 0.8, 'English Level 2', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (11, 'Word Building Level 2', 2, 3, 2, 'Core', 0.9, 'Word Building Level 2', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (39, 'Word Building Level 6', 6, 3, 2, 'Core', 0.9, 'Word Building Level 6', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (41, 'Science Level 6', 6, 5, 2, 'Core', 0.8, 'Science Level 6', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (94, 'Life of Christ I', 10, 7, 1, 'Further Credit Option', 0.8, 'Life of Christ I', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (139, 'Biblical Studies Essay Advanced', 12, 7, 7, 'CourseWork', 0.8, 'Biblical Studies Essay Advanced', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (140, 'Maths Paper Advanced', 12, 1, 7, 'CourseWork', 0.8, 'Maths Paper Advanced', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (141, 'English Essay Advanced', 12, 2, 7, 'CourseWork', 0.8, 'English Essay Advanced', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (119, 'Civics and Economics', 12, 6, 2, 'Further Credit Option', 0.8, 'Social Studies Level 12', NULL, 'Is een combinatie van twee vakken', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (124, 'Christian Growth', 12, 7, 1, 'Further Credit Option', 0.8, 'Christian Growth', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (90, 'Physical Science', 10, 5, 2, 'Core', 0.8, 'Science Level 10', NULL, 'Dat klopt', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (97, 'Digital Savvy', 10, 11, 3, 'Further Credit Option', 0.8, 'Digital Savvy', NULL, 'From approved list', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (103, 'ICCE Literature 10', 10, 4, 2, 'Further Credit Option', 0.8, 'ICCE Literature 10', NULL, 'Overlap with the previous one and the same name', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (112, 'English Composition II', 12, 2, 2, 'Further Credit Option', 0.8, 'English Composition II', NULL, 'Where is English Composition I?', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (113, 'English IV', 12, 2, 2, 'Core', 0.8, 'English IV', NULL, 'mogelijk English IV te kiezen als III nog niet gedaan is? ', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (142, 'Social Studies Essay Advanced', 12, 6, 7, 'CourseWork', 0.8, 'Social Studies Essay Advanced', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (143, 'Sciences Project Advanced', 12, 5, 7, 'CourseWork', 0.8, 'Sciences Project Advanced', NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (166, 'Business Math', 10, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (93, 'Christian Counselling I', 10, 7, 1, 'Further Credit Option', 0.8, 'Christian Counselling I', NULL, 'Correct gespeld? Is Amerikaans materiaal maar Britse spelling?', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (146, 'Literature Level 9', 9, 4, 2, 'Core', 0.8, 'Literature Level 9', NULL, 'Alleen even getallen hebben PACE beschikbaar. 106 is niet meer te verkrijgen, dus is vervangen door Poetry of After the Flood. Daarom staat er ipv 106 "106P". Er moeten zes PACEs in totaal worden gedaan met de keuze uit deze vijf beschikbare, of Poetry 1 of 2, of After the Flood. ', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (150, 'Grammar', 6, 2, 2, 'Further Credit Option', 0.8, 'English Grammar', NULL, 'Elective', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (151, 'Apologetics I', 9, 7, 1, 'Core', 0.8, NULL, NULL, 'Dit zijn alleen twee PACE''s 97,102. Vroeger waren dit aparte PACEs, maar nu gebundeld in één PACE "Apologetics 01".', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (152, 'Apologetics II', 10, 7, 1, 'Core', 0.8, NULL, NULL, 'Dit zijn alleen vier PACE''s 98-101. De sterren worden niet gegeven voor de toetsen maar voor de essays voor de boeken die ze moeten lezen. Vroeger waren dit aparte PACEs, maar nu gebundeld in één PACE "Apologetics 02".', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (153, 'World History', 10, 6, 2, 'Core', 0.8, 'Social Studies Level 12 World History', NULL, 'Dit lijkt op ID59 maar zie opmerking daar. Dit valt ook onder een andere SubjectGroupID (klopt dat?). ', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (154, 'Algebra I & Geometry I', 12, 1, 2, 'Core', 0.8, 'Algebra I & Geometry I', NULL, 'Dit is een nieuwe optie waarbij de leerling de eerste helft van Algebra 1 en Geometry I mag doen, en dan bij Intermediate de tweede helft van Algebra 1 en Geometry. ', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (999, 'Rosetta Stone Language X', NULL, NULL, 2, 'Core', 0.8, NULL, NULL, 'Moet ik dit toevoegen voor elke unit en taal?', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (161, 'New Testament Church History I', 12, 7, 1, 'Further Credit Option', 0.8, 'New Testament Church History I', NULL, 'Only possible to choose this as an option for Apologetics II', 1, NULL, NULL);
INSERT INTO public.courses (id, ace_alias, level, subject_id, subject_group_id, course_type, pass_threshold, icce_alias, certificate_name, remarks, active, icce_id, credits) VALUES (160, 'ICCE Physical Science', 9, 5, 2, 'Core', 0.8, 'AEE Physical Science', 'Physical Science I', 'De publisher is "AEE". Dit bestaat uit PACEs 85–88, 97–100. Niet te verwarren met ID=159.', 1, NULL, NULL);


--
-- Data for Name: dates; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (2, 44793, 1, 1, 1, 'Saturday', 'Zomervakantie', 5, 5, 33, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (3, 44794, 1, 1, 1, 'Sunday', 'Zomervakantie', 5, 5, 33, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (4, 44795, 0, 0, 0, 'Monday', NULL, 1, 1, 34, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (5, 44796, 0, 0, 0, 'Tuesday', NULL, 1, 1, 34, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (6, 44797, 0, 0, 0, 'Wednesday', NULL, 1, 1, 34, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (8, 44799, 0, 0, 0, 'Friday', NULL, 1, 1, 34, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (9, 44800, 1, 0, 1, 'Saturday', NULL, 1, 1, 34, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (10, 44801, 1, 0, 1, 'Sunday', NULL, 1, 1, 34, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (11, 44802, 0, 0, 0, 'Monday', NULL, 1, 2, 35, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (12, 44803, 0, 0, 0, 'Tuesday', NULL, 1, 2, 35, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (13, 44804, 0, 0, 0, 'Wednesday', NULL, 1, 2, 35, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (14, 44805, 0, 0, 0, 'Thursday', NULL, 1, 2, 35, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (15, 44806, 0, 0, 0, 'Friday', NULL, 1, 2, 35, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (17, 44808, 1, 0, 1, 'Sunday', NULL, 1, 2, 35, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (18, 44809, 0, 0, 0, 'Monday', NULL, 1, 3, 36, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (19, 44810, 0, 0, 0, 'Tuesday', NULL, 1, 3, 36, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (20, 44811, 0, 0, 0, 'Wednesday', NULL, 1, 3, 36, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (21, 44812, 0, 0, 0, 'Thursday', NULL, 1, 3, 36, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (22, 44813, 0, 0, 0, 'Friday', NULL, 1, 3, 36, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (24, 44815, 1, 0, 1, 'Sunday', NULL, 1, 3, 36, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (25, 44816, 0, 0, 0, 'Monday', NULL, 1, 4, 37, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (26, 44817, 0, 0, 0, 'Tuesday', NULL, 1, 4, 37, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (27, 44818, 0, 0, 0, 'Wednesday', NULL, 1, 4, 37, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (28, 44819, 0, 0, 0, 'Thursday', NULL, 1, 4, 37, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (29, 44820, 0, 0, 0, 'Friday', NULL, 1, 4, 37, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (31, 44822, 1, 0, 1, 'Sunday', NULL, 1, 4, 37, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (32, 44823, 0, 0, 0, 'Monday', NULL, 1, 5, 38, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (33, 44824, 0, 0, 0, 'Tuesday', NULL, 1, 5, 38, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (34, 44825, 0, 0, 0, 'Wednesday', NULL, 1, 5, 38, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (35, 44826, 0, 0, 0, 'Thursday', NULL, 1, 5, 38, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (36, 44827, 0, 0, 0, 'Friday', NULL, 1, 5, 38, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (37, 44828, 1, 0, 1, 'Saturday', NULL, 1, 5, 38, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (38, 44829, 1, 0, 1, 'Sunday', NULL, 1, 5, 38, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (40, 44831, 0, 0, 0, 'Tuesday', NULL, 1, 6, 39, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (41, 44832, 0, 0, 0, 'Wednesday', NULL, 1, 6, 39, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (42, 44833, 0, 0, 0, 'Thursday', NULL, 1, 6, 39, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (43, 44834, 0, 0, 0, 'Friday', NULL, 1, 6, 39, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (44, 44835, 1, 0, 1, 'Saturday', NULL, 1, 6, 39, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (45, 44836, 1, 0, 1, 'Sunday', NULL, 1, 6, 39, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (47, 44838, 0, 0, 0, 'Tuesday', NULL, 1, 7, 40, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (48, 44839, 0, 0, 0, 'Wednesday', NULL, 1, 7, 40, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (49, 44840, 0, 0, 0, 'Thursday', NULL, 1, 7, 40, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (50, 44841, 0, 0, 0, 'Friday', NULL, 1, 7, 40, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (51, 44842, 1, 0, 1, 'Saturday', NULL, 1, 7, 40, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (52, 44843, 1, 0, 1, 'Sunday', NULL, 1, 7, 40, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (54, 44845, 0, 0, 0, 'Tuesday', NULL, 1, 8, 41, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (55, 44846, 0, 0, 0, 'Wednesday', NULL, 1, 8, 41, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (56, 44847, 0, 0, 0, 'Thursday', NULL, 1, 8, 41, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (57, 44848, 0, 0, 0, 'Friday', NULL, 1, 8, 41, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (58, 44849, 1, 0, 1, 'Saturday', NULL, 1, 8, 41, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (59, 44850, 1, 0, 1, 'Sunday', NULL, 1, 8, 41, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (61, 44852, 0, 0, 0, 'Tuesday', NULL, 1, 9, 42, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (62, 44853, 0, 0, 0, 'Wednesday', NULL, 1, 9, 42, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (63, 44854, 0, 0, 0, 'Thursday', NULL, 1, 9, 42, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (64, 44855, 0, 0, 0, 'Friday', NULL, 1, 9, 42, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (65, 44856, 1, 0, 1, 'Saturday', NULL, 1, 9, 42, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (66, 44857, 1, 0, 1, 'Sunday', NULL, 1, 9, 42, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (68, 44859, 0, 1, 1, 'Tuesday', 'Najaarsvakantie', 1, 10, 43, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (69, 44860, 0, 1, 1, 'Wednesday', 'Najaarsvakantie', 1, 10, 43, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (70, 44861, 0, 1, 1, 'Thursday', 'Najaarsvakantie', 1, 10, 43, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (71, 44862, 0, 1, 1, 'Friday', 'Najaarsvakantie', 1, 10, 43, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (72, 44863, 1, 1, 1, 'Saturday', 'Najaarsvakantie', 1, 10, 43, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (73, 44864, 1, 1, 1, 'Sunday', 'Najaarsvakantie', 1, 10, 43, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (75, 44866, 0, 0, 0, 'Tuesday', NULL, 2, 1, 44, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (76, 44867, 0, 0, 0, 'Wednesday', NULL, 2, 1, 44, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (77, 44868, 0, 0, 0, 'Thursday', NULL, 2, 1, 44, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (78, 44869, 0, 0, 0, 'Friday', NULL, 2, 1, 44, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (79, 44870, 1, 0, 1, 'Saturday', NULL, 2, 1, 44, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (80, 44871, 1, 0, 1, 'Sunday', NULL, 2, 1, 44, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (81, 44872, 0, 0, 0, 'Monday', NULL, 2, 2, 45, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (83, 44874, 0, 0, 0, 'Wednesday', NULL, 2, 2, 45, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (84, 44875, 0, 0, 0, 'Thursday', NULL, 2, 2, 45, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (85, 44876, 0, 0, 0, 'Friday', NULL, 2, 2, 45, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (86, 44877, 1, 0, 1, 'Saturday', NULL, 2, 2, 45, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (87, 44878, 1, 0, 1, 'Sunday', NULL, 2, 2, 45, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (88, 44879, 0, 0, 0, 'Monday', NULL, 2, 3, 46, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (90, 44881, 0, 0, 0, 'Wednesday', NULL, 2, 3, 46, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (91, 44882, 0, 0, 0, 'Thursday', NULL, 2, 3, 46, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (92, 44883, 0, 0, 0, 'Friday', NULL, 2, 3, 46, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (93, 44884, 1, 0, 1, 'Saturday', NULL, 2, 3, 46, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (94, 44885, 1, 0, 1, 'Sunday', NULL, 2, 3, 46, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (95, 44886, 0, 0, 0, 'Monday', NULL, 2, 4, 47, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (97, 44888, 0, 0, 0, 'Wednesday', NULL, 2, 4, 47, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (98, 44889, 0, 0, 0, 'Thursday', NULL, 2, 4, 47, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (99, 44890, 0, 0, 0, 'Friday', NULL, 2, 4, 47, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (100, 44891, 1, 0, 1, 'Saturday', NULL, 2, 4, 47, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (101, 44892, 1, 0, 1, 'Sunday', NULL, 2, 4, 47, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (103, 44894, 0, 0, 0, 'Tuesday', NULL, 2, 5, 48, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (104, 44895, 0, 0, 0, 'Wednesday', NULL, 2, 5, 48, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (105, 44896, 0, 0, 0, 'Thursday', NULL, 2, 5, 48, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (106, 44897, 0, 0, 0, 'Friday', NULL, 2, 5, 48, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (108, 44899, 1, 0, 1, 'Sunday', NULL, 2, 5, 48, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (109, 44900, 0, 0, 0, 'Monday', NULL, 2, 6, 49, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (110, 44901, 0, 0, 0, 'Tuesday', NULL, 2, 6, 49, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (111, 44902, 0, 0, 0, 'Wednesday', NULL, 2, 6, 49, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (112, 44903, 0, 0, 0, 'Thursday', NULL, 2, 6, 49, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (113, 44904, 0, 0, 0, 'Friday', NULL, 2, 6, 49, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (115, 44906, 1, 0, 1, 'Sunday', NULL, 2, 6, 49, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (116, 44907, 0, 0, 0, 'Monday', NULL, 2, 7, 50, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (117, 44908, 0, 0, 0, 'Tuesday', NULL, 2, 7, 50, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (118, 44909, 0, 0, 0, 'Wednesday', NULL, 2, 7, 50, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (119, 44910, 0, 0, 0, 'Thursday', NULL, 2, 7, 50, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (120, 44911, 0, 0, 0, 'Friday', NULL, 2, 7, 50, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (121, 44912, 1, 0, 1, 'Saturday', NULL, 2, 7, 50, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (122, 44913, 1, 0, 1, 'Sunday', NULL, 2, 7, 50, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (124, 44915, 0, 0, 0, 'Tuesday', NULL, 2, 8, 51, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (125, 44916, 0, 0, 0, 'Wednesday', NULL, 2, 8, 51, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (126, 44917, 0, 0, 0, 'Thursday', NULL, 2, 8, 51, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (127, 44918, 0, 0, 0, 'Friday', NULL, 2, 8, 51, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (128, 44919, 1, 0, 1, 'Saturday', NULL, 2, 8, 51, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (130, 44921, 0, 1, 1, 'Monday', 'Kerstvakantie', 2, 9, 52, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (131, 44922, 0, 1, 1, 'Tuesday', 'Kerstvakantie', 2, 9, 52, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (132, 44923, 0, 1, 1, 'Wednesday', 'Kerstvakantie', 2, 9, 52, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (133, 44924, 0, 1, 1, 'Thursday', 'Kerstvakantie', 2, 9, 52, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (134, 44925, 0, 1, 1, 'Friday', 'Kerstvakantie', 2, 9, 52, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (135, 44926, 1, 1, 1, 'Saturday', 'Kerstvakantie', 2, 9, 52, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (136, 44927, 1, 1, 1, 'Sunday', 'Kerstvakantie', 2, 9, 52, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (138, 44929, 0, 1, 1, 'Tuesday', 'Kerstvakantie', 2, 9, 1, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (139, 44930, 0, 1, 1, 'Wednesday', 'Kerstvakantie', 2, 9, 1, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (140, 44931, 0, 1, 1, 'Thursday', 'Kerstvakantie', 2, 9, 1, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (141, 44932, 0, 1, 1, 'Friday', 'Kerstvakantie', 2, 9, 1, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (142, 44933, 1, 1, 1, 'Saturday', 'Kerstvakantie', 2, 9, 1, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (143, 44934, 1, 1, 1, 'Sunday', 'Kerstvakantie', 2, 9, 1, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (145, 44936, 0, 0, 0, 'Tuesday', NULL, 3, 1, 2, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (146, 44937, 0, 0, 0, 'Wednesday', NULL, 3, 1, 2, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (147, 44938, 0, 0, 0, 'Thursday', NULL, 3, 1, 2, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (148, 44939, 0, 0, 0, 'Friday', NULL, 3, 1, 2, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (149, 44940, 1, 0, 1, 'Saturday', NULL, 3, 1, 2, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (150, 44941, 1, 0, 1, 'Sunday', NULL, 3, 1, 2, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (151, 44942, 0, 0, 0, 'Monday', NULL, 3, 2, 3, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (152, 44943, 0, 0, 0, 'Tuesday', NULL, 3, 2, 3, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (154, 44945, 0, 0, 0, 'Thursday', NULL, 3, 2, 3, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (155, 44946, 0, 0, 0, 'Friday', NULL, 3, 2, 3, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (156, 44947, 1, 0, 1, 'Saturday', NULL, 3, 2, 3, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (157, 44948, 1, 0, 1, 'Sunday', NULL, 3, 2, 3, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (158, 44949, 0, 0, 0, 'Monday', NULL, 3, 3, 4, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (159, 44950, 0, 0, 0, 'Tuesday', NULL, 3, 3, 4, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (161, 44952, 0, 0, 0, 'Thursday', NULL, 3, 3, 4, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (162, 44953, 0, 0, 0, 'Friday', NULL, 3, 3, 4, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (163, 44954, 1, 0, 1, 'Saturday', NULL, 3, 3, 4, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (164, 44955, 1, 0, 1, 'Sunday', NULL, 3, 3, 4, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (165, 44956, 0, 0, 0, 'Monday', NULL, 3, 4, 5, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (166, 44957, 0, 0, 0, 'Tuesday', NULL, 3, 4, 5, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (168, 44959, 0, 0, 0, 'Thursday', NULL, 3, 4, 5, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (169, 44960, 0, 0, 0, 'Friday', NULL, 3, 4, 5, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (170, 44961, 1, 0, 1, 'Saturday', NULL, 3, 4, 5, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (171, 44962, 1, 0, 1, 'Sunday', NULL, 3, 4, 5, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (172, 44963, 0, 0, 0, 'Monday', NULL, 3, 5, 6, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (173, 44964, 0, 0, 0, 'Tuesday', NULL, 3, 5, 6, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (174, 44965, 0, 0, 0, 'Wednesday', NULL, 3, 5, 6, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (176, 44967, 0, 0, 0, 'Friday', NULL, 3, 5, 6, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (177, 44968, 1, 0, 1, 'Saturday', NULL, 3, 5, 6, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (178, 44969, 1, 0, 1, 'Sunday', NULL, 3, 5, 6, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (179, 44970, 0, 0, 0, 'Monday', NULL, 3, 6, 7, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (180, 44971, 0, 0, 0, 'Tuesday', NULL, 3, 6, 7, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (181, 44972, 0, 0, 0, 'Wednesday', NULL, 3, 6, 7, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (182, 44973, 0, 0, 0, 'Thursday', NULL, 3, 6, 7, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (184, 44975, 1, 0, 1, 'Saturday', NULL, 3, 6, 7, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (185, 44976, 1, 0, 1, 'Sunday', NULL, 3, 6, 7, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (186, 44977, 0, 0, 0, 'Monday', NULL, 3, 7, 8, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (187, 44978, 0, 0, 0, 'Tuesday', NULL, 3, 7, 8, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (188, 44979, 0, 0, 0, 'Wednesday', NULL, 3, 7, 8, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (189, 44980, 0, 0, 0, 'Thursday', NULL, 3, 7, 8, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (191, 44982, 1, 0, 1, 'Saturday', NULL, 3, 7, 8, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (192, 44983, 1, 0, 1, 'Sunday', NULL, 3, 7, 8, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (193, 44984, 0, 1, 1, 'Monday', 'Voorjaarsvakantie', 3, 8, 9, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (194, 44985, 0, 1, 1, 'Tuesday', 'Voorjaarsvakantie', 3, 8, 9, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (195, 44986, 0, 1, 1, 'Wednesday', 'Voorjaarsvakantie', 3, 8, 9, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (197, 44988, 0, 1, 1, 'Friday', 'Voorjaarsvakantie', 3, 8, 9, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (198, 44989, 1, 1, 1, 'Saturday', 'Voorjaarsvakantie', 3, 8, 9, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (199, 44990, 1, 1, 1, 'Sunday', 'Voorjaarsvakantie', 3, 8, 9, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (200, 44991, 0, 1, 1, 'Monday', 'Studiedag', 4, 1, 10, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (201, 44992, 0, 0, 0, 'Tuesday', NULL, 4, 1, 10, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (203, 44994, 0, 0, 0, 'Thursday', NULL, 4, 1, 10, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (204, 44995, 0, 0, 0, 'Friday', NULL, 4, 1, 10, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (205, 44996, 1, 0, 1, 'Saturday', NULL, 4, 1, 10, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (206, 44997, 1, 0, 1, 'Sunday', NULL, 4, 1, 10, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (207, 44998, 0, 0, 0, 'Monday', NULL, 4, 2, 11, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (209, 45000, 0, 0, 0, 'Wednesday', NULL, 4, 2, 11, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (210, 45001, 0, 0, 0, 'Thursday', NULL, 4, 2, 11, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (211, 45002, 0, 0, 0, 'Friday', NULL, 4, 2, 11, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (212, 45003, 1, 0, 1, 'Saturday', NULL, 4, 2, 11, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (213, 45004, 1, 0, 1, 'Sunday', NULL, 4, 2, 11, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (214, 45005, 0, 0, 0, 'Monday', NULL, 4, 3, 12, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (216, 45007, 0, 0, 0, 'Wednesday', NULL, 4, 3, 12, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (217, 45008, 0, 0, 0, 'Thursday', NULL, 4, 3, 12, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (218, 45009, 0, 0, 0, 'Friday', NULL, 4, 3, 12, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (219, 45010, 1, 0, 1, 'Saturday', NULL, 4, 3, 12, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (220, 45011, 1, 0, 1, 'Sunday', NULL, 4, 3, 12, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (221, 45012, 0, 0, 0, 'Monday', NULL, 4, 4, 13, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (223, 45014, 0, 0, 0, 'Wednesday', NULL, 4, 4, 13, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (224, 45015, 0, 0, 0, 'Thursday', NULL, 4, 4, 13, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (225, 45016, 0, 0, 0, 'Friday', NULL, 4, 4, 13, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (226, 45017, 1, 0, 1, 'Saturday', NULL, 4, 4, 13, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (227, 45018, 1, 0, 1, 'Sunday', NULL, 4, 4, 13, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (228, 45019, 0, 0, 0, 'Monday', NULL, 4, 5, 14, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (230, 45021, 0, 0, 0, 'Wednesday', NULL, 4, 5, 14, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (231, 45022, 0, 0, 0, 'Thursday', NULL, 4, 5, 14, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (232, 45023, 0, 0, 0, 'Friday', NULL, 4, 5, 14, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (233, 45024, 1, 0, 1, 'Saturday', NULL, 4, 5, 14, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (234, 45025, 1, 0, 1, 'Sunday', NULL, 4, 5, 14, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (235, 45026, 0, 0, 0, 'Monday', NULL, 4, 6, 15, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (237, 45028, 0, 0, 0, 'Wednesday', NULL, 4, 6, 15, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (238, 45029, 0, 0, 0, 'Thursday', NULL, 4, 6, 15, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (239, 45030, 0, 0, 0, 'Friday', NULL, 4, 6, 15, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (240, 45031, 1, 0, 1, 'Saturday', NULL, 4, 6, 15, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (241, 45032, 1, 0, 1, 'Sunday', NULL, 4, 6, 15, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (242, 45033, 0, 0, 0, 'Monday', NULL, 4, 7, 16, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (244, 45035, 0, 0, 0, 'Wednesday', NULL, 4, 7, 16, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (245, 45036, 0, 0, 0, 'Thursday', NULL, 4, 7, 16, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (246, 45037, 0, 0, 0, 'Friday', NULL, 4, 7, 16, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (247, 45038, 1, 0, 1, 'Saturday', NULL, 4, 7, 16, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (248, 45039, 1, 0, 1, 'Sunday', NULL, 4, 7, 16, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (249, 45040, 0, 0, 0, 'Monday', NULL, 4, 8, 17, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (251, 45042, 0, 0, 0, 'Wednesday', NULL, 4, 8, 17, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (252, 45043, 0, 0, 0, 'Thursday', NULL, 4, 8, 17, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (253, 45044, 0, 0, 0, 'Friday', NULL, 4, 8, 17, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (254, 45045, 1, 1, 1, 'Saturday', 'Meivakantie', 4, 8, 17, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (255, 45046, 1, 1, 1, 'Sunday', 'Meivakantie', 4, 8, 17, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (256, 45047, 0, 1, 1, 'Monday', 'Meivakantie', 4, 9, 18, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (258, 45049, 0, 1, 1, 'Wednesday', 'Meivakantie', 4, 9, 18, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (259, 45050, 0, 1, 1, 'Thursday', 'Meivakantie', 4, 9, 18, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (260, 45051, 0, 1, 1, 'Friday', 'Meivakantie', 4, 9, 18, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (261, 45052, 1, 1, 1, 'Saturday', 'Meivakantie', 4, 9, 18, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (262, 45053, 1, 1, 1, 'Sunday', 'Meivakantie', 4, 9, 18, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (263, 45054, 0, 1, 1, 'Monday', 'Meivakantie', 4, 10, 19, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (265, 45056, 0, 1, 1, 'Wednesday', 'Meivakantie', 4, 10, 19, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (266, 45057, 0, 1, 1, 'Thursday', 'Meivakantie', 4, 10, 19, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (267, 45058, 0, 1, 1, 'Friday', 'Meivakantie', 4, 10, 19, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (268, 45059, 1, 1, 1, 'Saturday', 'Meivakantie', 4, 10, 19, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (269, 45060, 1, 1, 1, 'Sunday', 'Meivakantie', 4, 10, 19, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (270, 45061, 0, 1, 1, 'Monday', 'Studiedag', 5, 1, 20, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (271, 45062, 0, 0, 0, 'Tuesday', NULL, 5, 1, 20, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (273, 45064, 0, 0, 0, 'Thursday', NULL, 5, 1, 20, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (274, 45065, 0, 0, 0, 'Friday', NULL, 5, 1, 20, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (275, 45066, 1, 0, 1, 'Saturday', NULL, 5, 1, 20, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (276, 45067, 1, 0, 1, 'Sunday', NULL, 5, 1, 20, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (277, 45068, 0, 0, 0, 'Monday', NULL, 5, 2, 21, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (278, 45069, 0, 0, 0, 'Tuesday', NULL, 5, 2, 21, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (279, 45070, 0, 0, 0, 'Wednesday', NULL, 5, 2, 21, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (281, 45072, 0, 0, 0, 'Friday', NULL, 5, 2, 21, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (282, 45073, 1, 0, 1, 'Saturday', NULL, 5, 2, 21, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (283, 45074, 1, 0, 1, 'Sunday', NULL, 5, 2, 21, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (284, 45075, 0, 0, 0, 'Monday', NULL, 5, 3, 22, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (285, 45076, 0, 0, 0, 'Tuesday', NULL, 5, 3, 22, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (286, 45077, 0, 0, 0, 'Wednesday', NULL, 5, 3, 22, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (288, 45079, 0, 0, 0, 'Friday', NULL, 5, 3, 22, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (289, 45080, 1, 0, 1, 'Saturday', NULL, 5, 3, 22, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (290, 45081, 1, 0, 1, 'Sunday', NULL, 5, 3, 22, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (291, 45082, 0, 0, 0, 'Monday', NULL, 5, 4, 23, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (292, 45083, 0, 0, 0, 'Tuesday', NULL, 5, 4, 23, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (293, 45084, 0, 0, 0, 'Wednesday', NULL, 5, 4, 23, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (294, 45085, 0, 0, 0, 'Thursday', NULL, 5, 4, 23, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (295, 45086, 0, 0, 0, 'Friday', NULL, 5, 4, 23, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (297, 45088, 1, 0, 1, 'Sunday', NULL, 5, 4, 23, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (298, 45089, 0, 0, 0, 'Monday', NULL, 5, 5, 24, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (299, 45090, 0, 0, 0, 'Tuesday', NULL, 5, 5, 24, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (300, 45091, 0, 0, 0, 'Wednesday', NULL, 5, 5, 24, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (301, 45092, 0, 0, 0, 'Thursday', NULL, 5, 5, 24, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (302, 45093, 0, 0, 0, 'Friday', NULL, 5, 5, 24, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (304, 45095, 1, 0, 1, 'Sunday', NULL, 5, 5, 24, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (305, 45096, 0, 0, 0, 'Monday', NULL, 5, 6, 25, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (307, 45098, 0, 0, 0, 'Wednesday', NULL, 5, 6, 25, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (308, 45099, 0, 0, 0, 'Thursday', NULL, 5, 6, 25, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (309, 45100, 0, 0, 0, 'Friday', NULL, 5, 6, 25, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (310, 45101, 1, 0, 1, 'Saturday', NULL, 5, 6, 25, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (311, 45102, 1, 0, 1, 'Sunday', NULL, 5, 6, 25, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (312, 45103, 0, 0, 0, 'Monday', NULL, 5, 7, 26, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (314, 45105, 0, 0, 0, 'Wednesday', NULL, 5, 7, 26, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (315, 45106, 0, 0, 0, 'Thursday', NULL, 5, 7, 26, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (316, 45107, 0, 0, 0, 'Friday', NULL, 5, 7, 26, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (317, 45108, 1, 0, 1, 'Saturday', NULL, 5, 7, 26, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (318, 45109, 1, 0, 1, 'Sunday', NULL, 5, 7, 26, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (319, 45110, 0, 0, 0, 'Monday', NULL, 5, 8, 27, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (321, 45112, 0, 0, 0, 'Wednesday', NULL, 5, 8, 27, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (322, 45113, 0, 0, 0, 'Thursday', NULL, 5, 8, 27, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (323, 45114, 0, 0, 0, 'Friday', NULL, 5, 8, 27, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (324, 45115, 1, 1, 1, 'Saturday', 'Zomervakantie', 5, 8, 27, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (325, 45116, 1, 1, 1, 'Sunday', 'Zomervakantie', 5, 8, 27, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (326, 45117, 0, 1, 1, 'Monday', 'Zomervakantie', 5, 9, 28, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (328, 45119, 0, 1, 1, 'Wednesday', 'Zomervakantie', 5, 9, 28, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (329, 45120, 0, 1, 1, 'Thursday', 'Zomervakantie', 5, 9, 28, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (330, 45121, 0, 1, 1, 'Friday', 'Zomervakantie', 5, 9, 28, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (331, 45122, 1, 1, 1, 'Saturday', 'Zomervakantie', 5, 9, 28, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (332, 45123, 1, 1, 1, 'Sunday', 'Zomervakantie', 5, 9, 28, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (333, 45124, 0, 1, 1, 'Monday', 'Zomervakantie', 5, 10, 29, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (335, 45126, 0, 1, 1, 'Wednesday', 'Zomervakantie', 5, 10, 29, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (336, 45127, 0, 1, 1, 'Thursday', 'Zomervakantie', 5, 10, 29, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (337, 45128, 0, 1, 1, 'Friday', 'Zomervakantie', 5, 10, 29, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (338, 45129, 1, 1, 1, 'Saturday', 'Zomervakantie', 5, 10, 29, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (339, 45130, 1, 1, 1, 'Sunday', 'Zomervakantie', 5, 10, 29, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (340, 45131, 0, 1, 1, 'Monday', 'Zomervakantie', 5, 11, 30, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (341, 45132, 0, 1, 1, 'Tuesday', 'Zomervakantie', 5, 11, 30, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (343, 45134, 0, 1, 1, 'Thursday', 'Zomervakantie', 5, 11, 30, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (344, 45135, 0, 1, 1, 'Friday', 'Zomervakantie', 5, 11, 30, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (345, 45136, 1, 1, 1, 'Saturday', 'Zomervakantie', 5, 11, 30, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (346, 45137, 1, 1, 1, 'Sunday', 'Zomervakantie', 5, 11, 30, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (347, 45138, 0, 1, 1, 'Monday', 'Zomervakantie', 5, 12, 31, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (348, 45139, 0, 1, 1, 'Tuesday', 'Zomervakantie', 5, 12, 31, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (349, 45140, 0, 1, 1, 'Wednesday', 'Zomervakantie', 5, 12, 31, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (351, 45142, 0, 1, 1, 'Friday', 'Zomervakantie', 5, 12, 31, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (352, 45143, 1, 1, 1, 'Saturday', 'Zomervakantie', 5, 12, 31, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (353, 45144, 1, 1, 1, 'Sunday', 'Zomervakantie', 5, 12, 31, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (354, 45145, 0, 1, 1, 'Monday', 'Zomervakantie', 5, 13, 32, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (355, 45146, 0, 1, 1, 'Tuesday', 'Zomervakantie', 5, 13, 32, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (356, 45147, 0, 1, 1, 'Wednesday', 'Zomervakantie', 5, 13, 32, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (358, 45149, 0, 1, 1, 'Friday', 'Zomervakantie', 5, 13, 32, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (359, 45150, 1, 1, 1, 'Saturday', 'Zomervakantie', 5, 13, 32, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (360, 45151, 1, 1, 1, 'Sunday', 'Zomervakantie', 5, 13, 32, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (361, 45152, 0, 1, 1, 'Monday', 'Zomervakantie', 5, 14, 33, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (362, 45153, 0, 1, 1, 'Tuesday', 'Zomervakantie', 5, 14, 33, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (363, 45154, 0, 1, 1, 'Wednesday', 'Zomervakantie', 5, 14, 33, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (364, 45155, 0, 1, 1, 'Thursday', 'Zomervakantie', 5, 14, 33, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (366, 45157, 1, 1, 1, 'Saturday', 'Zomervakantie', 5, 14, 33, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (367, 45158, 1, 1, 1, 'Sunday', 'Zomervakantie', 5, 14, 33, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (368, 45159, 0, 0, 0, 'Monday', NULL, 1, 1, 34, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (369, 45160, 0, 0, 0, 'Tuesday', NULL, 1, 1, 34, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (370, 45161, 0, 0, 0, 'Wednesday', NULL, 1, 1, 34, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (371, 45162, 0, 0, 0, 'Thursday', NULL, 1, 1, 34, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (372, 45163, 0, 0, 0, 'Friday', NULL, 1, 1, 34, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (374, 45165, 1, 0, 1, 'Sunday', NULL, 1, 1, 34, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (375, 45166, 0, 0, 0, 'Monday', NULL, 1, 2, 35, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (376, 45167, 0, 0, 0, 'Tuesday', NULL, 1, 2, 35, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (377, 45168, 0, 0, 0, 'Wednesday', NULL, 1, 2, 35, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (378, 45169, 0, 0, 0, 'Thursday', NULL, 1, 2, 35, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (379, 45170, 0, 0, 0, 'Friday', NULL, 1, 2, 35, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (381, 45172, 1, 0, 1, 'Sunday', NULL, 1, 2, 35, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (382, 45173, 0, 0, 0, 'Monday', NULL, 1, 3, 36, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (383, 45174, 0, 0, 0, 'Tuesday', NULL, 1, 3, 36, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (384, 45175, 0, 0, 0, 'Wednesday', NULL, 1, 3, 36, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (385, 45176, 0, 0, 0, 'Thursday', NULL, 1, 3, 36, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (386, 45177, 0, 0, 0, 'Friday', NULL, 1, 3, 36, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (387, 45178, 1, 0, 1, 'Saturday', NULL, 1, 3, 36, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (388, 45179, 1, 0, 1, 'Sunday', NULL, 1, 3, 36, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (390, 45181, 0, 0, 0, 'Tuesday', NULL, 1, 4, 37, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (391, 45182, 0, 0, 0, 'Wednesday', NULL, 1, 4, 37, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (392, 45183, 0, 0, 0, 'Thursday', NULL, 1, 4, 37, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (393, 45184, 0, 0, 0, 'Friday', NULL, 1, 4, 37, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (394, 45185, 1, 0, 1, 'Saturday', NULL, 1, 4, 37, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (395, 45186, 1, 0, 1, 'Sunday', NULL, 1, 4, 37, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (397, 45188, 0, 0, 0, 'Tuesday', NULL, 1, 5, 38, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (398, 45189, 0, 0, 0, 'Wednesday', NULL, 1, 5, 38, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (399, 45190, 0, 0, 0, 'Thursday', NULL, 1, 5, 38, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (400, 45191, 0, 0, 0, 'Friday', NULL, 1, 5, 38, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (401, 45192, 1, 0, 1, 'Saturday', NULL, 1, 5, 38, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (402, 45193, 1, 0, 1, 'Sunday', NULL, 1, 5, 38, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (404, 45195, 0, 0, 0, 'Tuesday', NULL, 1, 6, 39, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (405, 45196, 0, 0, 0, 'Wednesday', NULL, 1, 6, 39, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (407, 45198, 0, 0, 0, 'Friday', NULL, 1, 6, 39, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (408, 45199, 1, 0, 1, 'Saturday', NULL, 1, 6, 39, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (409, 45200, 1, 0, 1, 'Sunday', NULL, 1, 6, 39, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (410, 45201, 0, 0, 0, 'Monday', NULL, 1, 7, 40, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (411, 45202, 0, 0, 0, 'Tuesday', NULL, 1, 7, 40, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (412, 45203, 0, 0, 0, 'Wednesday', NULL, 1, 7, 40, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (413, 45204, 0, 0, 0, 'Thursday', NULL, 1, 7, 40, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (415, 45206, 1, 0, 1, 'Saturday', NULL, 1, 7, 40, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (416, 45207, 1, 0, 1, 'Sunday', NULL, 1, 7, 40, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (417, 45208, 0, 0, 0, 'Monday', NULL, 1, 8, 41, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (418, 45209, 0, 0, 0, 'Tuesday', NULL, 1, 8, 41, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (419, 45210, 0, 0, 0, 'Wednesday', NULL, 1, 8, 41, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (420, 45211, 0, 0, 0, 'Thursday', NULL, 1, 8, 41, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (422, 45213, 1, 1, 1, 'Saturday', 'Herfstvakantie', 1, 8, 41, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (423, 45214, 1, 1, 1, 'Sunday', 'Herfstvakantie', 1, 8, 41, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (424, 45215, 0, 1, 1, 'Monday', 'Herfstvakantie', 1, 9, 42, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (425, 45216, 0, 1, 1, 'Tuesday', 'Herfstvakantie', 1, 9, 42, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (426, 45217, 0, 1, 1, 'Wednesday', 'Herfstvakantie', 1, 9, 42, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (427, 45218, 0, 1, 1, 'Thursday', 'Herfstvakantie', 1, 9, 42, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (429, 45220, 1, 1, 1, 'Saturday', 'Herfstvakantie', 1, 9, 42, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (430, 45221, 1, 1, 1, 'Sunday', 'Herfstvakantie', 1, 9, 42, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (431, 45222, 0, 1, 1, 'Monday', 'Studiedag', 2, 1, 43, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (432, 45223, 0, 0, 0, 'Tuesday', NULL, 2, 1, 43, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (433, 45224, 0, 0, 0, 'Wednesday', NULL, 2, 1, 43, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (434, 45225, 0, 0, 0, 'Thursday', NULL, 2, 1, 43, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (435, 45226, 0, 0, 0, 'Friday', NULL, 2, 1, 43, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (437, 45228, 1, 0, 1, 'Sunday', NULL, 2, 1, 43, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (438, 45229, 0, 0, 0, 'Monday', NULL, 2, 2, 44, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (439, 45230, 0, 0, 0, 'Tuesday', NULL, 2, 2, 44, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (440, 45231, 0, 0, 0, 'Wednesday', NULL, 2, 2, 44, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (441, 45232, 0, 0, 0, 'Thursday', NULL, 2, 2, 44, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (442, 45233, 0, 0, 0, 'Friday', NULL, 2, 2, 44, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (444, 45235, 1, 0, 1, 'Sunday', NULL, 2, 2, 44, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (445, 45236, 0, 0, 0, 'Monday', NULL, 2, 3, 45, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (446, 45237, 0, 0, 0, 'Tuesday', NULL, 2, 3, 45, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (447, 45238, 0, 0, 0, 'Wednesday', NULL, 2, 3, 45, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (448, 45239, 0, 0, 0, 'Thursday', NULL, 2, 3, 45, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (449, 45240, 0, 0, 0, 'Friday', NULL, 2, 3, 45, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (450, 45241, 1, 0, 1, 'Saturday', NULL, 2, 3, 45, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (452, 45243, 0, 0, 0, 'Monday', NULL, 2, 4, 46, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (453, 45244, 0, 0, 0, 'Tuesday', NULL, 2, 4, 46, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (454, 45245, 0, 0, 0, 'Wednesday', NULL, 2, 4, 46, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (455, 45246, 0, 0, 0, 'Thursday', NULL, 2, 4, 46, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (456, 45247, 0, 0, 0, 'Friday', NULL, 2, 4, 46, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (457, 45248, 1, 0, 1, 'Saturday', NULL, 2, 4, 46, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (459, 45250, 0, 0, 0, 'Monday', NULL, 2, 5, 47, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (460, 45251, 0, 0, 0, 'Tuesday', NULL, 2, 5, 47, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (461, 45252, 0, 0, 0, 'Wednesday', NULL, 2, 5, 47, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (462, 45253, 0, 0, 0, 'Thursday', NULL, 2, 5, 47, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (463, 45254, 0, 0, 0, 'Friday', NULL, 2, 5, 47, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (464, 45255, 1, 0, 1, 'Saturday', NULL, 2, 5, 47, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (466, 45257, 0, 0, 0, 'Monday', NULL, 2, 6, 48, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (467, 45258, 0, 0, 0, 'Tuesday', NULL, 2, 6, 48, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (468, 45259, 0, 0, 0, 'Wednesday', NULL, 2, 6, 48, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (469, 45260, 0, 0, 0, 'Thursday', NULL, 2, 6, 48, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (470, 45261, 0, 0, 0, 'Friday', NULL, 2, 6, 48, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (471, 45262, 1, 0, 1, 'Saturday', NULL, 2, 6, 48, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (473, 45264, 0, 0, 0, 'Monday', NULL, 2, 7, 49, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (474, 45265, 0, 0, 0, 'Tuesday', NULL, 2, 7, 49, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (475, 45266, 0, 0, 0, 'Wednesday', NULL, 2, 7, 49, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (476, 45267, 0, 0, 0, 'Thursday', NULL, 2, 7, 49, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (477, 45268, 0, 0, 0, 'Friday', NULL, 2, 7, 49, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (478, 45269, 1, 0, 1, 'Saturday', NULL, 2, 7, 49, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (480, 45271, 0, 0, 0, 'Monday', NULL, 2, 8, 50, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (481, 45272, 0, 0, 0, 'Tuesday', NULL, 2, 8, 50, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (482, 45273, 0, 0, 0, 'Wednesday', NULL, 2, 8, 50, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (483, 45274, 0, 0, 0, 'Thursday', NULL, 2, 8, 50, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (484, 45275, 0, 0, 0, 'Friday', NULL, 2, 8, 50, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (485, 45276, 1, 0, 1, 'Saturday', NULL, 2, 8, 50, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (487, 45278, 0, 0, 0, 'Monday', NULL, 2, 9, 51, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (488, 45279, 0, 0, 0, 'Tuesday', NULL, 2, 9, 51, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (489, 45280, 0, 0, 0, 'Wednesday', NULL, 2, 9, 51, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (490, 45281, 0, 0, 0, 'Thursday', NULL, 2, 9, 51, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (491, 45282, 0, 0, 0, 'Friday', NULL, 2, 9, 51, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (492, 45283, 1, 1, 1, 'Saturday', 'Kerstvakantie', 2, 9, 51, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (494, 45285, 0, 1, 1, 'Monday', 'Kerstvakantie', 2, 10, 52, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (495, 45286, 0, 1, 1, 'Tuesday', 'Kerstvakantie', 2, 10, 52, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (496, 45287, 0, 1, 1, 'Wednesday', 'Kerstvakantie', 2, 10, 52, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (497, 45288, 0, 1, 1, 'Thursday', 'Kerstvakantie', 2, 10, 52, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (498, 45289, 0, 1, 1, 'Friday', 'Kerstvakantie', 2, 10, 52, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (499, 45290, 1, 1, 1, 'Saturday', 'Kerstvakantie', 2, 10, 52, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (501, 45292, 0, 1, 1, 'Monday', 'Kerstvakantie', 2, 10, 1, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (502, 45293, 0, 1, 1, 'Tuesday', 'Kerstvakantie', 2, 10, 1, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (503, 45294, 0, 1, 1, 'Wednesday', 'Kerstvakantie', 2, 10, 1, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (505, 45296, 0, 1, 1, 'Friday', 'Kerstvakantie', 2, 10, 1, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (506, 45297, 1, 1, 1, 'Saturday', 'Kerstvakantie', 2, 10, 1, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (507, 45298, 1, 1, 1, 'Sunday', 'Kerstvakantie', 2, 10, 1, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (508, 45299, 0, 1, 1, 'Monday', 'Studiedag', 3, 1, 2, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (509, 45300, 0, 0, 0, 'Tuesday', NULL, 3, 1, 2, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (510, 45301, 0, 0, 0, 'Wednesday', NULL, 3, 1, 2, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (512, 45303, 0, 0, 0, 'Friday', NULL, 3, 1, 2, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (513, 45304, 1, 0, 1, 'Saturday', NULL, 3, 1, 2, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (514, 45305, 1, 0, 1, 'Sunday', NULL, 3, 1, 2, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (515, 45306, 0, 0, 0, 'Monday', NULL, 3, 2, 3, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (516, 45307, 0, 0, 0, 'Tuesday', NULL, 3, 2, 3, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (517, 45308, 0, 0, 0, 'Wednesday', NULL, 3, 2, 3, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (518, 45309, 0, 0, 0, 'Thursday', NULL, 3, 2, 3, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (519, 45310, 0, 0, 0, 'Friday', NULL, 3, 2, 3, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (521, 45312, 1, 0, 1, 'Sunday', NULL, 3, 2, 3, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (522, 45313, 0, 0, 0, 'Monday', NULL, 3, 3, 4, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (523, 45314, 0, 0, 0, 'Tuesday', NULL, 3, 3, 4, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (524, 45315, 0, 0, 0, 'Wednesday', NULL, 3, 3, 4, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (525, 45316, 0, 0, 0, 'Thursday', NULL, 3, 3, 4, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (526, 45317, 0, 0, 0, 'Friday', NULL, 3, 3, 4, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (528, 45319, 1, 0, 1, 'Sunday', NULL, 3, 3, 4, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (529, 45320, 0, 0, 0, 'Monday', NULL, 3, 4, 5, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (530, 45321, 0, 0, 0, 'Tuesday', NULL, 3, 4, 5, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (531, 45322, 0, 0, 0, 'Wednesday', NULL, 3, 4, 5, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (532, 45323, 0, 0, 0, 'Thursday', NULL, 3, 4, 5, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (533, 45324, 0, 0, 0, 'Friday', NULL, 3, 4, 5, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (535, 45326, 1, 0, 1, 'Sunday', NULL, 3, 4, 5, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (536, 45327, 0, 0, 0, 'Monday', NULL, 3, 5, 6, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (537, 45328, 0, 0, 0, 'Tuesday', NULL, 3, 5, 6, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (538, 45329, 0, 0, 0, 'Wednesday', NULL, 3, 5, 6, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (539, 45330, 0, 0, 0, 'Thursday', NULL, 3, 5, 6, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (540, 45331, 0, 0, 0, 'Friday', NULL, 3, 5, 6, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (541, 45332, 1, 0, 1, 'Saturday', NULL, 3, 5, 6, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (542, 45333, 1, 0, 1, 'Sunday', NULL, 3, 5, 6, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (544, 45335, 0, 0, 0, 'Tuesday', NULL, 3, 6, 7, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (545, 45336, 0, 0, 0, 'Wednesday', NULL, 3, 6, 7, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (546, 45337, 0, 0, 0, 'Thursday', NULL, 3, 6, 7, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (547, 45338, 0, 0, 0, 'Friday', NULL, 3, 6, 7, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (549, 45340, 1, 1, 1, 'Sunday', 'Voorjaarsvakantie', 3, 6, 7, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (550, 45341, 0, 1, 1, 'Monday', 'Voorjaarsvakantie', 3, 7, 8, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (551, 45342, 0, 1, 1, 'Tuesday', 'Voorjaarsvakantie', 3, 7, 8, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (552, 45343, 0, 1, 1, 'Wednesday', 'Voorjaarsvakantie', 3, 7, 8, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (553, 45344, 0, 1, 1, 'Thursday', 'Voorjaarsvakantie', 3, 7, 8, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (554, 45345, 0, 1, 1, 'Friday', 'Voorjaarsvakantie', 3, 7, 8, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (555, 45346, 1, 1, 1, 'Saturday', 'Voorjaarsvakantie', 3, 7, 8, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (556, 45347, 1, 1, 1, 'Sunday', 'Voorjaarsvakantie', 3, 7, 8, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (558, 45349, 0, 0, 0, 'Tuesday', NULL, 4, 1, 9, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (559, 45350, 0, 0, 0, 'Wednesday', NULL, 4, 1, 9, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (560, 45351, 0, 0, 0, 'Thursday', NULL, 4, 1, 9, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (561, 45352, 0, 0, 0, 'Friday', NULL, 4, 1, 9, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (562, 45353, 1, 0, 1, 'Saturday', NULL, 4, 1, 9, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (563, 45354, 1, 0, 1, 'Sunday', NULL, 4, 1, 9, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (564, 45355, 0, 0, 0, 'Monday', NULL, 4, 2, 10, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (565, 45356, 0, 0, 0, 'Tuesday', NULL, 4, 2, 10, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (567, 45358, 0, 0, 0, 'Thursday', NULL, 4, 2, 10, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (568, 45359, 0, 0, 0, 'Friday', NULL, 4, 2, 10, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (569, 45360, 1, 0, 1, 'Saturday', NULL, 4, 2, 10, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (570, 45361, 1, 0, 1, 'Sunday', NULL, 4, 2, 10, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (571, 45362, 0, 0, 0, 'Monday', NULL, 4, 3, 11, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (572, 45363, 0, 0, 0, 'Tuesday', NULL, 4, 3, 11, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (574, 45365, 0, 0, 0, 'Thursday', NULL, 4, 3, 11, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (575, 45366, 0, 0, 0, 'Friday', NULL, 4, 3, 11, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (576, 45367, 1, 0, 1, 'Saturday', NULL, 4, 3, 11, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (577, 45368, 1, 0, 1, 'Sunday', NULL, 4, 3, 11, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (578, 45369, 0, 0, 0, 'Monday', NULL, 4, 4, 12, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (579, 45370, 0, 0, 0, 'Tuesday', NULL, 4, 4, 12, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (581, 45372, 0, 0, 0, 'Thursday', NULL, 4, 4, 12, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (582, 45373, 0, 0, 0, 'Friday', NULL, 4, 4, 12, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (583, 45374, 1, 0, 1, 'Saturday', NULL, 4, 4, 12, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (584, 45375, 1, 0, 1, 'Sunday', NULL, 4, 4, 12, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (585, 45376, 0, 0, 0, 'Monday', NULL, 4, 5, 13, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (586, 45377, 0, 0, 0, 'Tuesday', NULL, 4, 5, 13, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (587, 45378, 0, 0, 0, 'Wednesday', NULL, 4, 5, 13, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (589, 45380, 0, 0, 0, 'Friday', NULL, 4, 5, 13, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (590, 45381, 1, 0, 1, 'Saturday', NULL, 4, 5, 13, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (591, 45382, 1, 0, 1, 'Sunday', NULL, 4, 5, 13, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (592, 45383, 0, 0, 0, 'Monday', NULL, 4, 6, 14, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (593, 45384, 0, 0, 0, 'Tuesday', NULL, 4, 6, 14, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (594, 45385, 0, 0, 0, 'Wednesday', NULL, 4, 6, 14, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (595, 45386, 0, 0, 0, 'Thursday', NULL, 4, 6, 14, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (597, 45388, 1, 0, 1, 'Saturday', NULL, 4, 6, 14, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (598, 45389, 1, 0, 1, 'Sunday', NULL, 4, 6, 14, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (599, 45390, 0, 0, 0, 'Monday', NULL, 4, 7, 15, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (600, 45391, 0, 0, 0, 'Tuesday', NULL, 4, 7, 15, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (601, 45392, 0, 0, 0, 'Wednesday', NULL, 4, 7, 15, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (602, 45393, 0, 0, 0, 'Thursday', NULL, 4, 7, 15, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (605, 45396, 1, 0, 1, 'Sunday', NULL, 4, 7, 15, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (606, 45397, 0, 0, 0, 'Monday', NULL, 4, 8, 16, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (607, 45398, 0, 0, 0, 'Tuesday', NULL, 4, 8, 16, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (608, 45399, 0, 0, 0, 'Wednesday', NULL, 4, 8, 16, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (610, 45401, 0, 0, 0, 'Friday', NULL, 4, 8, 16, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (611, 45402, 1, 0, 1, 'Saturday', NULL, 4, 8, 16, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (612, 45403, 1, 0, 1, 'Sunday', NULL, 4, 8, 16, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (613, 45404, 0, 0, 0, 'Monday', NULL, 4, 9, 17, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (614, 45405, 0, 0, 0, 'Tuesday', NULL, 4, 9, 17, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (615, 45406, 0, 0, 0, 'Wednesday', NULL, 4, 9, 17, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (616, 45407, 0, 0, 0, 'Thursday', NULL, 4, 9, 17, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (618, 45409, 1, 1, 1, 'Saturday', 'Meivakantie', 4, 9, 17, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (619, 45410, 1, 1, 1, 'Sunday', 'Meivakantie', 4, 9, 17, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (620, 45411, 0, 1, 1, 'Monday', 'Meivakantie', 4, 10, 18, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (621, 45412, 0, 1, 1, 'Tuesday', 'Meivakantie', 4, 10, 18, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (622, 45413, 0, 1, 1, 'Wednesday', 'Meivakantie', 4, 10, 18, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (623, 45414, 0, 1, 1, 'Thursday', 'Meivakantie', 4, 10, 18, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (625, 45416, 1, 1, 1, 'Saturday', 'Meivakantie', 4, 10, 18, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (626, 45417, 1, 1, 1, 'Sunday', 'Meivakantie', 4, 10, 18, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (627, 45418, 0, 1, 1, 'Monday', 'Studiedag', 5, 1, 19, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (628, 45419, 0, 0, 0, 'Tuesday', NULL, 5, 1, 19, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (629, 45420, 0, 0, 0, 'Wednesday', NULL, 5, 1, 19, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (630, 45421, 0, 0, 0, 'Thursday', NULL, 5, 1, 19, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (631, 45422, 0, 0, 0, 'Friday', NULL, 5, 1, 19, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (633, 45424, 1, 0, 1, 'Sunday', NULL, 5, 1, 19, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (634, 45425, 0, 0, 0, 'Monday', NULL, 5, 2, 20, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (635, 45426, 0, 0, 0, 'Tuesday', NULL, 5, 2, 20, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (636, 45427, 0, 0, 0, 'Wednesday', NULL, 5, 2, 20, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (637, 45428, 0, 0, 0, 'Thursday', NULL, 5, 2, 20, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (638, 45429, 0, 0, 0, 'Friday', NULL, 5, 2, 20, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (640, 45431, 1, 0, 1, 'Sunday', NULL, 5, 2, 20, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (641, 45432, 0, 0, 0, 'Monday', NULL, 5, 3, 21, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (642, 45433, 0, 0, 0, 'Tuesday', NULL, 5, 3, 21, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (643, 45434, 0, 0, 0, 'Wednesday', NULL, 5, 3, 21, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (644, 45435, 0, 0, 0, 'Thursday', NULL, 5, 3, 21, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (645, 45436, 0, 0, 0, 'Friday', NULL, 5, 3, 21, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (646, 45437, 1, 0, 1, 'Saturday', NULL, 5, 3, 21, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (648, 45439, 0, 0, 0, 'Monday', NULL, 5, 4, 22, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (649, 45440, 0, 0, 0, 'Tuesday', NULL, 5, 4, 22, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (650, 45441, 0, 0, 0, 'Wednesday', NULL, 5, 4, 22, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (651, 45442, 0, 0, 0, 'Thursday', NULL, 5, 4, 22, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (652, 45443, 0, 0, 0, 'Friday', NULL, 5, 4, 22, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (653, 45444, 1, 0, 1, 'Saturday', NULL, 5, 4, 22, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (655, 45446, 0, 0, 0, 'Monday', NULL, 5, 5, 23, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (656, 45447, 0, 0, 0, 'Tuesday', NULL, 5, 5, 23, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (657, 45448, 0, 0, 0, 'Wednesday', NULL, 5, 5, 23, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (658, 45449, 0, 0, 0, 'Thursday', NULL, 5, 5, 23, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (659, 45450, 0, 0, 0, 'Friday', NULL, 5, 5, 23, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (660, 45451, 1, 0, 1, 'Saturday', NULL, 5, 5, 23, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (662, 45453, 0, 0, 0, 'Monday', NULL, 5, 6, 24, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (663, 45454, 0, 0, 0, 'Tuesday', NULL, 5, 6, 24, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (664, 45455, 0, 0, 0, 'Wednesday', NULL, 5, 6, 24, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (665, 45456, 0, 0, 0, 'Thursday', NULL, 5, 6, 24, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (666, 45457, 0, 0, 0, 'Friday', NULL, 5, 6, 24, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (667, 45458, 1, 0, 1, 'Saturday', NULL, 5, 6, 24, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (669, 45460, 0, 0, 0, 'Monday', NULL, 5, 7, 25, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (670, 45461, 0, 0, 0, 'Tuesday', NULL, 5, 7, 25, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (671, 45462, 0, 0, 0, 'Wednesday', NULL, 5, 7, 25, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (672, 45463, 0, 0, 0, 'Thursday', NULL, 5, 7, 25, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (673, 45464, 0, 0, 0, 'Friday', NULL, 5, 7, 25, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (674, 45465, 1, 0, 1, 'Saturday', NULL, 5, 7, 25, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (676, 45467, 0, 0, 0, 'Monday', NULL, 5, 8, 26, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (677, 45468, 0, 0, 0, 'Tuesday', NULL, 5, 8, 26, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (678, 45469, 0, 0, 0, 'Wednesday', NULL, 5, 8, 26, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (679, 45470, 0, 0, 0, 'Thursday', NULL, 5, 8, 26, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (680, 45471, 0, 0, 0, 'Friday', NULL, 5, 8, 26, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (681, 45472, 1, 0, 1, 'Saturday', NULL, 5, 8, 26, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (683, 45474, 0, 0, 0, 'Monday', NULL, 5, 9, 27, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (684, 45475, 0, 0, 0, 'Tuesday', NULL, 5, 9, 27, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (685, 45476, 0, 0, 0, 'Wednesday', NULL, 5, 9, 27, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (686, 45477, 0, 0, 0, 'Thursday', NULL, 5, 9, 27, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (687, 45478, 0, 0, 0, 'Friday', NULL, 5, 9, 27, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (688, 45479, 1, 0, 1, 'Saturday', NULL, 5, 9, 27, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (690, 45481, 0, 0, 0, 'Monday', NULL, 5, 10, 28, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (691, 45482, 0, 0, 0, 'Tuesday', NULL, 5, 10, 28, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (692, 45483, 0, 0, 0, 'Wednesday', NULL, 5, 10, 28, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (693, 45484, 0, 0, 0, 'Thursday', NULL, 5, 10, 28, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (694, 45485, 0, 0, 0, 'Friday', NULL, 5, 10, 28, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (695, 45486, 1, 1, 1, 'Saturday', 'Zomervakantie', 5, 10, 28, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (697, 45488, 0, 1, 1, 'Monday', 'Zomervakantie', 5, 11, 29, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (698, 45489, 0, 1, 1, 'Tuesday', 'Zomervakantie', 5, 11, 29, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (699, 45490, 0, 1, 1, 'Wednesday', 'Zomervakantie', 5, 11, 29, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (700, 45491, 0, 1, 1, 'Thursday', 'Zomervakantie', 5, 11, 29, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (701, 45492, 0, 1, 1, 'Friday', 'Zomervakantie', 5, 11, 29, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (702, 45493, 1, 1, 1, 'Saturday', 'Zomervakantie', 5, 11, 29, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (704, 45495, 0, 1, 1, 'Monday', 'Zomervakantie', 5, 12, 30, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (706, 45497, 0, 1, 1, 'Wednesday', 'Zomervakantie', 5, 12, 30, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (707, 45498, 0, 1, 1, 'Thursday', 'Zomervakantie', 5, 12, 30, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (708, 45499, 0, 1, 1, 'Friday', 'Zomervakantie', 5, 12, 30, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (709, 45500, 1, 1, 1, 'Saturday', 'Zomervakantie', 5, 12, 30, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (711, 45502, 0, 1, 1, 'Monday', 'Zomervakantie', 5, 13, 31, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (712, 45503, 0, 1, 1, 'Tuesday', 'Zomervakantie', 5, 13, 31, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (713, 45504, 0, 1, 1, 'Wednesday', 'Zomervakantie', 5, 13, 31, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (714, 45505, 0, 1, 1, 'Thursday', 'Zomervakantie', 5, 13, 31, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (715, 45506, 0, 1, 1, 'Friday', 'Zomervakantie', 5, 13, 31, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (716, 45507, 1, 1, 1, 'Saturday', 'Zomervakantie', 5, 13, 31, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (718, 45509, 0, 1, 1, 'Monday', 'Zomervakantie', 5, 14, 32, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (719, 45510, 0, 1, 1, 'Tuesday', 'Zomervakantie', 5, 14, 32, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (720, 45511, 0, 1, 1, 'Wednesday', 'Zomervakantie', 5, 14, 32, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (721, 45512, 0, 1, 1, 'Thursday', 'Zomervakantie', 5, 14, 32, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (722, 45513, 0, 1, 1, 'Friday', 'Zomervakantie', 5, 14, 32, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (723, 45514, 1, 1, 1, 'Saturday', 'Zomervakantie', 5, 14, 32, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (724, 45515, 1, 1, 1, 'Sunday', 'Zomervakantie', 5, 14, 32, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (726, 45517, 0, 1, 1, 'Tuesday', 'Zomervakantie', 5, 15, 33, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (727, 45518, 0, 1, 1, 'Wednesday', 'Zomervakantie', 5, 15, 33, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (728, 45519, 0, 1, 1, 'Thursday', 'Zomervakantie', 5, 15, 33, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (729, 45520, 0, 1, 1, 'Friday', 'Zomervakantie', 5, 15, 33, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (730, 45521, 1, 1, 1, 'Saturday', 'Zomervakantie', 5, 15, 33, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (731, 45522, 1, 1, 1, 'Sunday', 'Zomervakantie', 5, 15, 33, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (732, 45523, 0, 1, 1, 'Monday', 'Zomervakantie', 5, 16, 34, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (734, 45525, 0, 1, 1, 'Wednesday', 'Zomervakantie', 5, 16, 34, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (735, 45526, 0, 1, 1, 'Thursday', 'Zomervakantie', 5, 16, 34, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (736, 45527, 0, 1, 1, 'Friday', 'Zomervakantie', 5, 16, 34, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (737, 45528, 1, 1, 1, 'Saturday', 'Zomervakantie', 5, 16, 34, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (738, 45529, 1, 1, 1, 'Sunday', 'Zomervakantie', 5, 16, 34, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (739, 45530, 0, 0, 0, 'Monday', NULL, 1, 1, 35, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (740, 45531, 0, 0, 0, 'Tuesday', NULL, 1, 1, 35, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (742, 45533, 0, 0, 0, 'Thursday', NULL, 1, 1, 35, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (743, 45534, 0, 0, 0, 'Friday', NULL, 1, 1, 35, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (744, 45535, 1, 0, 1, 'Saturday', NULL, 1, 1, 35, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (745, 45536, 1, 0, 1, 'Sunday', NULL, 1, 1, 35, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (746, 45537, 0, 0, 0, 'Monday', NULL, 1, 2, 36, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (747, 45538, 0, 0, 0, 'Tuesday', NULL, 1, 2, 36, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (749, 45540, 0, 0, 0, 'Thursday', NULL, 1, 2, 36, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (750, 45541, 0, 0, 0, 'Friday', NULL, 1, 2, 36, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (751, 45542, 1, 0, 1, 'Saturday', NULL, 1, 2, 36, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (752, 45543, 1, 0, 1, 'Sunday', NULL, 1, 2, 36, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (753, 45544, 0, 0, 0, 'Monday', NULL, 1, 3, 37, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (754, 45545, 0, 0, 0, 'Tuesday', NULL, 1, 3, 37, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (755, 45546, 0, 0, 0, 'Wednesday', NULL, 1, 3, 37, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (757, 45548, 0, 0, 0, 'Friday', NULL, 1, 3, 37, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (758, 45549, 1, 0, 1, 'Saturday', NULL, 1, 3, 37, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (759, 45550, 1, 0, 1, 'Sunday', NULL, 1, 3, 37, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (760, 45551, 0, 0, 0, 'Monday', NULL, 1, 4, 38, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (761, 45552, 0, 0, 0, 'Tuesday', NULL, 1, 4, 38, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (762, 45553, 0, 0, 0, 'Wednesday', NULL, 1, 4, 38, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (764, 45555, 0, 0, 0, 'Friday', NULL, 1, 4, 38, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (765, 45556, 1, 0, 1, 'Saturday', NULL, 1, 4, 38, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (766, 45557, 1, 0, 1, 'Sunday', NULL, 1, 4, 38, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (767, 45558, 0, 0, 0, 'Monday', NULL, 1, 5, 39, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (768, 45559, 0, 0, 0, 'Tuesday', NULL, 1, 5, 39, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (769, 45560, 0, 0, 0, 'Wednesday', NULL, 1, 5, 39, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (770, 45561, 0, 0, 0, 'Thursday', NULL, 1, 5, 39, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (771, 45562, 0, 0, 0, 'Friday', NULL, 1, 5, 39, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (773, 45564, 1, 0, 1, 'Sunday', NULL, 1, 5, 39, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (774, 45565, 0, 0, 0, 'Monday', NULL, 1, 6, 40, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (775, 45566, 0, 0, 0, 'Tuesday', NULL, 1, 6, 40, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (776, 45567, 0, 0, 0, 'Wednesday', NULL, 1, 6, 40, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (777, 45568, 0, 0, 0, 'Thursday', NULL, 1, 6, 40, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (778, 45569, 0, 0, 0, 'Friday', NULL, 1, 6, 40, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (780, 45571, 1, 0, 1, 'Sunday', NULL, 1, 6, 40, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (781, 45572, 0, 0, 0, 'Monday', NULL, 1, 7, 41, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (782, 45573, 0, 0, 0, 'Tuesday', NULL, 1, 7, 41, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (783, 45574, 0, 0, 0, 'Wednesday', NULL, 1, 7, 41, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (784, 45575, 0, 0, 0, 'Thursday', NULL, 1, 7, 41, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (785, 45576, 0, 0, 0, 'Friday', NULL, 1, 7, 41, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (787, 45578, 1, 0, 1, 'Sunday', NULL, 1, 7, 41, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (788, 45579, 0, 0, 0, 'Monday', NULL, 1, 8, 42, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (789, 45580, 0, 0, 0, 'Tuesday', NULL, 1, 8, 42, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (790, 45581, 0, 0, 0, 'Wednesday', NULL, 1, 8, 42, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (791, 45582, 0, 0, 0, 'Thursday', NULL, 1, 8, 42, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (792, 45583, 0, 0, 0, 'Friday', NULL, 1, 8, 42, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (793, 45584, 1, 0, 1, 'Saturday', NULL, 1, 8, 42, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (794, 45585, 1, 0, 1, 'Sunday', NULL, 1, 8, 42, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (796, 45587, 0, 0, 0, 'Tuesday', NULL, 1, 9, 43, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (797, 45588, 0, 0, 0, 'Wednesday', NULL, 1, 9, 43, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (798, 45589, 0, 0, 0, 'Thursday', NULL, 1, 9, 43, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (799, 45590, 0, 0, 0, 'Friday', NULL, 1, 9, 43, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (800, 45591, 1, 0, 1, 'Saturday', NULL, 1, 9, 43, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (801, 45592, 1, 0, 1, 'Sunday', NULL, 1, 9, 43, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (803, 45594, 0, 1, 1, 'Tuesday', 'Herfstvakantie', 1, 10, 44, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (804, 45595, 0, 1, 1, 'Wednesday', 'Herfstvakantie', 1, 10, 44, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (806, 45597, 0, 1, 1, 'Friday', 'Herfstvakantie', 1, 10, 44, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (807, 45598, 1, 1, 1, 'Saturday', 'Herfstvakantie', 1, 10, 44, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (808, 45599, 1, 1, 1, 'Sunday', 'Herfstvakantie', 1, 10, 44, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (810, 45601, 0, 0, 0, 'Tuesday', NULL, 2, 1, 45, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (811, 45602, 0, 0, 0, 'Wednesday', NULL, 2, 1, 45, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (812, 45603, 0, 0, 0, 'Thursday', NULL, 2, 1, 45, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (813, 45604, 0, 0, 0, 'Friday', NULL, 2, 1, 45, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (814, 45605, 1, 0, 1, 'Saturday', NULL, 2, 1, 45, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (815, 45606, 1, 0, 1, 'Sunday', NULL, 2, 1, 45, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (816, 45607, 0, 0, 0, 'Monday', NULL, 2, 2, 46, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (817, 45608, 0, 0, 0, 'Tuesday', NULL, 2, 2, 46, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (819, 45610, 0, 0, 0, 'Thursday', NULL, 2, 2, 46, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (820, 45611, 0, 0, 0, 'Friday', NULL, 2, 2, 46, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (821, 45612, 1, 0, 1, 'Saturday', NULL, 2, 2, 46, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (822, 45613, 1, 0, 1, 'Sunday', NULL, 2, 2, 46, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (823, 45614, 0, 0, 0, 'Monday', NULL, 2, 3, 47, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (824, 45615, 0, 0, 0, 'Tuesday', NULL, 2, 3, 47, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (826, 45617, 0, 0, 0, 'Thursday', NULL, 2, 3, 47, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (827, 45618, 0, 0, 0, 'Friday', NULL, 2, 3, 47, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (828, 45619, 1, 0, 1, 'Saturday', NULL, 2, 3, 47, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (829, 45620, 1, 0, 1, 'Sunday', NULL, 2, 3, 47, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (830, 45621, 0, 0, 0, 'Monday', NULL, 2, 4, 48, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (831, 45622, 0, 0, 0, 'Tuesday', NULL, 2, 4, 48, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (833, 45624, 0, 0, 0, 'Thursday', NULL, 2, 4, 48, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (834, 45625, 0, 0, 0, 'Friday', NULL, 2, 4, 48, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (835, 45626, 1, 0, 1, 'Saturday', NULL, 2, 4, 48, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (836, 45627, 1, 0, 1, 'Sunday', NULL, 2, 4, 48, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (837, 45628, 0, 0, 0, 'Monday', NULL, 2, 5, 49, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (838, 45629, 0, 0, 0, 'Tuesday', NULL, 2, 5, 49, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (839, 45630, 0, 0, 0, 'Wednesday', NULL, 2, 5, 49, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (841, 45632, 0, 0, 0, 'Friday', NULL, 2, 5, 49, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (842, 45633, 1, 0, 1, 'Saturday', NULL, 2, 5, 49, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (843, 45634, 1, 0, 1, 'Sunday', NULL, 2, 5, 49, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (844, 45635, 0, 0, 0, 'Monday', NULL, 2, 6, 50, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (845, 45636, 0, 0, 0, 'Tuesday', NULL, 2, 6, 50, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (846, 45637, 0, 0, 0, 'Wednesday', NULL, 2, 6, 50, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (847, 45638, 0, 0, 0, 'Thursday', NULL, 2, 6, 50, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (849, 45640, 1, 0, 1, 'Saturday', NULL, 2, 6, 50, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (850, 45641, 1, 0, 1, 'Sunday', NULL, 2, 6, 50, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (851, 45642, 0, 0, 0, 'Monday', NULL, 2, 7, 51, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (852, 45643, 0, 0, 0, 'Tuesday', NULL, 2, 7, 51, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (853, 45644, 0, 0, 0, 'Wednesday', NULL, 2, 7, 51, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (854, 45645, 0, 0, 0, 'Thursday', NULL, 2, 7, 51, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (856, 45647, 1, 1, 1, 'Saturday', 'Kerstvakantie', 2, 7, 51, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (857, 45648, 1, 1, 1, 'Sunday', 'Kerstvakantie', 2, 7, 51, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (858, 45649, 0, 1, 1, 'Monday', 'Kerstvakantie', 2, 8, 52, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (859, 45650, 0, 1, 1, 'Tuesday', 'Kerstvakantie', 2, 8, 52, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (860, 45651, 0, 1, 1, 'Wednesday', 'Kerstvakantie', 2, 8, 52, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (861, 45652, 0, 1, 1, 'Thursday', 'Kerstvakantie', 2, 8, 52, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (863, 45654, 1, 1, 1, 'Saturday', 'Kerstvakantie', 2, 8, 52, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (864, 45655, 1, 1, 1, 'Sunday', 'Kerstvakantie', 2, 8, 52, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (865, 45656, 0, 1, 1, 'Monday', 'Kerstvakantie', 2, 8, 1, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (866, 45657, 0, 1, 1, 'Tuesday', 'Kerstvakantie', 2, 8, 1, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (867, 45658, 0, 1, 1, 'Wednesday', 'Kerstvakantie', 2, 8, 1, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (868, 45659, 0, 1, 1, 'Thursday', 'Kerstvakantie', 2, 8, 1, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (870, 45661, 1, 1, 1, 'Saturday', 'Kerstvakantie', 2, 8, 1, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (871, 45662, 1, 1, 1, 'Sunday', 'Kerstvakantie', 2, 8, 1, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (872, 45663, 0, 0, 0, 'Monday', NULL, 3, 1, 2, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (873, 45664, 0, 0, 0, 'Tuesday', NULL, 3, 1, 2, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (874, 45665, 0, 0, 0, 'Wednesday', NULL, 3, 1, 2, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (875, 45666, 0, 0, 0, 'Thursday', NULL, 3, 1, 2, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (876, 45667, 0, 0, 0, 'Friday', NULL, 3, 1, 2, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (878, 45669, 1, 0, 1, 'Sunday', NULL, 3, 1, 2, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (879, 45670, 0, 0, 0, 'Monday', NULL, 3, 2, 3, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (880, 45671, 0, 0, 0, 'Tuesday', NULL, 3, 2, 3, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (881, 45672, 0, 0, 0, 'Wednesday', NULL, 3, 2, 3, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (882, 45673, 0, 0, 0, 'Thursday', NULL, 3, 2, 3, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (883, 45674, 0, 0, 0, 'Friday', NULL, 3, 2, 3, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (884, 45675, 1, 0, 1, 'Saturday', NULL, 3, 2, 3, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (886, 45677, 0, 0, 0, 'Monday', NULL, 3, 3, 4, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (887, 45678, 0, 0, 0, 'Tuesday', NULL, 3, 3, 4, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (888, 45679, 0, 0, 0, 'Wednesday', NULL, 3, 3, 4, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (889, 45680, 0, 0, 0, 'Thursday', NULL, 3, 3, 4, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (890, 45681, 0, 0, 0, 'Friday', NULL, 3, 3, 4, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (891, 45682, 1, 0, 1, 'Saturday', NULL, 3, 3, 4, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (893, 45684, 0, 0, 0, 'Monday', NULL, 3, 4, 5, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (894, 45685, 0, 0, 0, 'Tuesday', NULL, 3, 4, 5, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (895, 45686, 0, 0, 0, 'Wednesday', NULL, 3, 4, 5, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (896, 45687, 0, 0, 0, 'Thursday', NULL, 3, 4, 5, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (897, 45688, 0, 0, 0, 'Friday', NULL, 3, 4, 5, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (898, 45689, 1, 0, 1, 'Saturday', NULL, 3, 4, 5, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (900, 45691, 0, 0, 0, 'Monday', NULL, 3, 5, 6, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (901, 45692, 0, 0, 0, 'Tuesday', NULL, 3, 5, 6, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (902, 45693, 0, 0, 0, 'Wednesday', NULL, 3, 5, 6, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (903, 45694, 0, 0, 0, 'Thursday', NULL, 3, 5, 6, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (904, 45695, 0, 0, 0, 'Friday', NULL, 3, 5, 6, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (905, 45696, 1, 0, 1, 'Saturday', NULL, 3, 5, 6, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (907, 45698, 0, 0, 0, 'Monday', NULL, 3, 6, 7, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (909, 45700, 0, 0, 0, 'Wednesday', NULL, 3, 6, 7, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (910, 45701, 0, 0, 0, 'Thursday', NULL, 3, 6, 7, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (911, 45702, 0, 0, 0, 'Friday', NULL, 3, 6, 7, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (912, 45703, 1, 0, 1, 'Saturday', NULL, 3, 6, 7, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (913, 45704, 1, 0, 1, 'Sunday', NULL, 3, 6, 7, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (914, 45705, 0, 0, 0, 'Monday', NULL, 3, 7, 8, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (916, 45707, 0, 0, 0, 'Wednesday', NULL, 3, 7, 8, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (917, 45708, 0, 0, 0, 'Thursday', NULL, 3, 7, 8, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (918, 45709, 0, 0, 0, 'Friday', NULL, 3, 7, 8, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (919, 45710, 1, 0, 1, 'Saturday', NULL, 3, 7, 8, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (920, 45711, 1, 0, 1, 'Sunday', NULL, 3, 7, 8, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (921, 45712, 0, 0, 0, 'Monday', NULL, 3, 8, 9, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (923, 45714, 0, 0, 0, 'Wednesday', NULL, 3, 8, 9, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (924, 45715, 0, 0, 0, 'Thursday', NULL, 3, 8, 9, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (925, 45716, 0, 0, 0, 'Friday', NULL, 3, 8, 9, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (926, 45717, 1, 0, 1, 'Saturday', NULL, 3, 8, 9, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (927, 45718, 1, 0, 1, 'Sunday', NULL, 3, 8, 9, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (928, 45719, 0, 0, 0, 'Monday', NULL, 3, 9, 10, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (930, 45721, 0, 0, 0, 'Wednesday', NULL, 3, 9, 10, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (931, 45722, 0, 0, 0, 'Thursday', NULL, 3, 9, 10, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (932, 45723, 0, 0, 0, 'Friday', NULL, 3, 9, 10, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (933, 45724, 1, 0, 1, 'Saturday', NULL, 3, 9, 10, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (934, 45725, 1, 0, 1, 'Sunday', NULL, 3, 9, 10, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (935, 45726, 0, 0, 0, 'Monday', NULL, 3, 10, 11, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (937, 45728, 0, 0, 0, 'Wednesday', NULL, 3, 10, 11, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (938, 45729, 0, 0, 0, 'Thursday', NULL, 3, 10, 11, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (939, 45730, 0, 0, 0, 'Friday', NULL, 3, 10, 11, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (940, 45731, 1, 0, 1, 'Saturday', NULL, 3, 10, 11, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (941, 45732, 1, 0, 1, 'Sunday', NULL, 3, 10, 11, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (942, 45733, 0, 0, 0, 'Monday', NULL, 3, 11, 12, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (944, 45735, 0, 0, 0, 'Wednesday', NULL, 3, 11, 12, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (945, 45736, 0, 0, 0, 'Thursday', NULL, 3, 11, 12, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (946, 45737, 0, 0, 0, 'Friday', NULL, 3, 11, 12, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (947, 45738, 1, 0, 1, 'Saturday', NULL, 3, 11, 12, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (948, 45739, 1, 0, 1, 'Sunday', NULL, 3, 11, 12, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (949, 45740, 0, 0, 0, 'Monday', NULL, 3, 12, 13, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (951, 45742, 0, 0, 0, 'Wednesday', NULL, 3, 12, 13, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (952, 45743, 0, 0, 0, 'Thursday', NULL, 3, 12, 13, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (953, 45744, 0, 0, 0, 'Friday', NULL, 3, 12, 13, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (954, 45745, 1, 0, 1, 'Saturday', NULL, 3, 12, 13, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (955, 45746, 1, 0, 1, 'Sunday', NULL, 3, 12, 13, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (956, 45747, 0, 0, 0, 'Monday', NULL, 3, 13, 14, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (958, 45749, 0, 0, 0, 'Wednesday', NULL, 3, 13, 14, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (959, 45750, 0, 0, 0, 'Thursday', NULL, 3, 13, 14, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (960, 45751, 0, 0, 0, 'Friday', NULL, 3, 13, 14, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (961, 45752, 1, 0, 1, 'Saturday', NULL, 3, 13, 14, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (962, 45753, 1, 0, 1, 'Sunday', NULL, 3, 13, 14, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (963, 45754, 0, 0, 0, 'Monday', NULL, 3, 14, 15, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (965, 45756, 0, 0, 0, 'Wednesday', NULL, 3, 14, 15, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (966, 45757, 0, 0, 0, 'Thursday', NULL, 3, 14, 15, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (967, 45758, 0, 0, 0, 'Friday', NULL, 3, 14, 15, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (968, 45759, 1, 0, 1, 'Saturday', NULL, 3, 14, 15, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (969, 45760, 1, 0, 1, 'Sunday', NULL, 3, 14, 15, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (970, 45761, 0, 0, 0, 'Monday', NULL, 3, 15, 16, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (972, 45763, 0, 0, 0, 'Wednesday', NULL, 3, 15, 16, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (973, 45764, 0, 0, 0, 'Thursday', NULL, 3, 15, 16, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (974, 45765, 0, 0, 0, 'Friday', NULL, 3, 15, 16, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (975, 45766, 1, 0, 1, 'Saturday', NULL, 3, 15, 16, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (976, 45767, 1, 0, 1, 'Sunday', NULL, 3, 15, 16, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (977, 45768, 0, 0, 0, 'Monday', NULL, 3, 16, 17, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (979, 45770, 0, 0, 0, 'Wednesday', NULL, 3, 16, 17, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (980, 45771, 0, 0, 0, 'Thursday', NULL, 3, 16, 17, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (981, 45772, 0, 0, 0, 'Friday', NULL, 3, 16, 17, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (982, 45773, 1, 0, 1, 'Saturday', NULL, 3, 16, 17, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (983, 45774, 1, 0, 1, 'Sunday', NULL, 3, 16, 17, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (984, 45775, 0, 0, 0, 'Monday', NULL, 3, 17, 18, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (986, 45777, 0, 0, 0, 'Wednesday', NULL, 3, 17, 18, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (987, 45778, 0, 0, 0, 'Thursday', NULL, 3, 17, 18, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (988, 45779, 0, 0, 0, 'Friday', NULL, 3, 17, 18, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (989, 45780, 1, 0, 1, 'Saturday', NULL, 3, 17, 18, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (990, 45781, 1, 0, 1, 'Sunday', NULL, 3, 17, 18, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (991, 45782, 0, 0, 0, 'Monday', NULL, 3, 18, 19, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (993, 45784, 0, 0, 0, 'Wednesday', NULL, 3, 18, 19, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (994, 45785, 0, 0, 0, 'Thursday', NULL, 3, 18, 19, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (995, 45786, 0, 0, 0, 'Friday', NULL, 3, 18, 19, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (996, 45787, 1, 0, 1, 'Saturday', NULL, 3, 18, 19, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (997, 45788, 1, 0, 1, 'Sunday', NULL, 3, 18, 19, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (998, 45789, 0, 0, 0, 'Monday', NULL, 3, 19, 20, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1000, 45791, 0, 0, 0, 'Wednesday', NULL, 3, 19, 20, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1001, 45792, 0, 1, 1, 'Thursday', NULL, NULL, 19, 20, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1002, 45793, 0, 0, 0, 'Friday', NULL, NULL, 19, 20, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1003, 45794, 1, 0, 1, 'Saturday', NULL, NULL, 19, 20, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1004, 45795, 1, 0, 1, 'Sunday', NULL, NULL, 19, 20, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1005, 45796, 0, 0, 0, 'Monday', NULL, NULL, 20, 21, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1007, 45798, 0, 0, 0, 'Wednesday', NULL, NULL, 20, 21, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1008, 45799, 0, 0, 0, 'Thursday', NULL, NULL, 20, 21, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1113, 45904, 0, 0, 0, 'Thursday', NULL, 1, 1, 36, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1114, 45905, 0, 0, 0, 'Friday', NULL, 1, 1, 36, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1115, 45906, 1, 0, 1, 'Saturday', NULL, 1, 1, 36, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1009, 45800, 0, 0, 0, 'Friday', NULL, NULL, 20, 21, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1010, 45801, 1, 0, 1, 'Saturday', NULL, NULL, 20, 21, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1011, 45802, 1, 0, 1, 'Sunday', NULL, NULL, 20, 21, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1013, 45804, 0, 0, 0, 'Tuesday', NULL, NULL, 21, 22, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1014, 45805, 0, 0, 0, 'Wednesday', NULL, NULL, 21, 22, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1015, 45806, 0, 0, 0, 'Thursday', NULL, NULL, 21, 22, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1016, 45807, 0, 0, 0, 'Friday', NULL, NULL, 21, 22, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1017, 45808, 1, 0, 1, 'Saturday', NULL, NULL, 21, 22, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1018, 45809, 1, 0, 1, 'Sunday', NULL, NULL, 21, 22, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1020, 45811, 0, 0, 0, 'Tuesday', NULL, NULL, 22, 23, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1021, 45812, 0, 0, 0, 'Wednesday', NULL, NULL, 22, 23, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1022, 45813, 0, 0, 0, 'Thursday', NULL, NULL, 22, 23, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1023, 45814, 0, 0, 0, 'Friday', NULL, NULL, 22, 23, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1024, 45815, 1, 0, 1, 'Saturday', NULL, NULL, 22, 23, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1025, 45816, 1, 0, 1, 'Sunday', NULL, NULL, 22, 23, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1027, 45818, 0, 0, 0, 'Tuesday', NULL, NULL, 23, 24, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1028, 45819, 0, 0, 0, 'Wednesday', NULL, NULL, 23, 24, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1029, 45820, 0, 0, 0, 'Thursday', NULL, NULL, 23, 24, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1030, 45821, 0, 0, 0, 'Friday', NULL, NULL, 23, 24, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1031, 45822, 1, 0, 1, 'Saturday', NULL, NULL, 23, 24, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1032, 45823, 1, 0, 1, 'Sunday', NULL, NULL, 23, 24, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1034, 45825, 0, 0, 0, 'Tuesday', NULL, NULL, 24, 25, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1035, 45826, 0, 0, 0, 'Wednesday', NULL, NULL, 24, 25, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1036, 45827, 0, 0, 0, 'Thursday', NULL, NULL, 24, 25, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1037, 45828, 0, 0, 0, 'Friday', NULL, NULL, 24, 25, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1038, 45829, 1, 0, 1, 'Saturday', NULL, NULL, 24, 25, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1039, 45830, 1, 0, 1, 'Sunday', NULL, NULL, 24, 25, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1041, 45832, 0, 0, 0, 'Tuesday', NULL, NULL, 25, 26, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1042, 45833, 0, 0, 0, 'Wednesday', NULL, NULL, 25, 26, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1043, 45834, 0, 0, 0, 'Thursday', NULL, NULL, 25, 26, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1044, 45835, 0, 0, 0, 'Friday', NULL, NULL, 25, 26, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1045, 45836, 1, 0, 1, 'Saturday', NULL, NULL, 25, 26, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1046, 45837, 1, 0, 1, 'Sunday', NULL, NULL, 25, 26, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1048, 45839, 0, 0, 0, 'Tuesday', NULL, NULL, 26, 27, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1049, 45840, 0, 0, 0, 'Wednesday', NULL, NULL, 26, 27, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1050, 45841, 0, 0, 0, 'Thursday', NULL, NULL, 26, 27, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1051, 45842, 0, 0, 0, 'Friday', NULL, NULL, 26, 27, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1052, 45843, 1, 0, 1, 'Saturday', NULL, NULL, 26, 27, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1053, 45844, 1, 0, 1, 'Sunday', NULL, NULL, 26, 27, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1055, 45846, 0, 0, 0, 'Tuesday', NULL, NULL, 27, 28, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1056, 45847, 0, 0, 0, 'Wednesday', NULL, NULL, 27, 28, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1057, 45848, 0, 0, 0, 'Thursday', NULL, NULL, 27, 28, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1058, 45849, 0, 0, 0, 'Friday', NULL, NULL, 27, 28, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1059, 45850, 1, 0, 1, 'Saturday', NULL, NULL, 27, 28, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1060, 45851, 1, 0, 1, 'Sunday', NULL, NULL, 27, 28, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1062, 45853, 0, 0, 0, 'Tuesday', NULL, NULL, 28, 29, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1063, 45854, 0, 0, 0, 'Wednesday', NULL, NULL, 28, 29, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1064, 45855, 0, 0, 0, 'Thursday', NULL, NULL, 28, 29, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1065, 45856, 0, 0, 0, 'Friday', NULL, NULL, 28, 29, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1066, 45857, 1, 0, 1, 'Saturday', NULL, NULL, 28, 29, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1067, 45858, 1, 0, 1, 'Sunday', NULL, NULL, 28, 29, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1069, 45860, 0, 0, 0, 'Tuesday', NULL, NULL, 29, 30, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1070, 45861, 0, 0, 0, 'Wednesday', NULL, NULL, 29, 30, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1071, 45862, 0, 0, 0, 'Thursday', NULL, NULL, 29, 30, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1072, 45863, 0, 0, 0, 'Friday', NULL, NULL, 29, 30, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1073, 45864, 1, 0, 1, 'Saturday', NULL, NULL, 29, 30, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1074, 45865, 1, 0, 1, 'Sunday', NULL, NULL, 29, 30, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1076, 45867, 0, 0, 0, 'Tuesday', NULL, NULL, 30, 31, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1077, 45868, 0, 0, 0, 'Wednesday', NULL, NULL, 30, 31, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1078, 45869, 0, 0, 0, 'Thursday', NULL, NULL, 30, 31, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1079, 45870, 0, 0, 0, 'Friday', NULL, NULL, 30, 31, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1080, 45871, 1, 0, 1, 'Saturday', NULL, NULL, 30, 31, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1081, 45872, 1, 0, 1, 'Sunday', NULL, NULL, 30, 31, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1083, 45874, 0, 0, 0, 'Tuesday', NULL, NULL, 31, 32, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1084, 45875, 0, 0, 0, 'Wednesday', NULL, NULL, 31, 32, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1085, 45876, 0, 0, 0, 'Thursday', NULL, NULL, 31, 32, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1086, 45877, 0, 0, 0, 'Friday', NULL, NULL, 31, 32, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1087, 45878, 1, 0, 1, 'Saturday', NULL, NULL, 31, 32, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1088, 45879, 1, 0, 1, 'Sunday', NULL, NULL, 31, 32, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1090, 45881, 0, 0, 0, 'Tuesday', NULL, NULL, 32, 33, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1091, 45882, 0, 0, 0, 'Wednesday', NULL, NULL, 32, 33, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1092, 45883, 0, 0, 0, 'Thursday', NULL, NULL, 32, 33, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1093, 45884, 0, 0, 0, 'Friday', NULL, NULL, 32, 33, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1094, 45885, 1, 0, 1, 'Saturday', NULL, NULL, 32, 33, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1095, 45886, 1, 0, 1, 'Sunday', NULL, NULL, 32, 33, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1097, 45888, 0, 0, 0, 'Tuesday', NULL, NULL, 33, 34, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1098, 45889, 0, 0, 0, 'Wednesday', NULL, NULL, 33, 34, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1099, 45890, 0, 0, 0, 'Thursday', NULL, NULL, 33, 34, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1100, 45891, 0, 0, 0, 'Friday', NULL, NULL, 33, 34, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1101, 45892, 1, 0, 1, 'Saturday', NULL, NULL, 33, 34, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1102, 45893, 1, 0, 1, 'Sunday', NULL, NULL, 33, 34, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1104, 45895, 0, 0, 0, 'Tuesday', NULL, NULL, 34, 35, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1105, 45896, 0, 0, 0, 'Wednesday', NULL, NULL, 34, 35, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1106, 45897, 0, 0, 0, 'Thursday', NULL, NULL, 34, 35, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1107, 45898, 0, 0, 0, 'Friday', NULL, NULL, 34, 35, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1108, 45899, 1, 0, 1, 'Saturday', NULL, NULL, 34, 35, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1109, 45900, 1, 0, 1, 'Sunday', NULL, NULL, 34, 35, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1118, 45909, 0, 0, 0, 'Tuesday', NULL, 1, 2, 37, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1119, 45910, 0, 0, 0, 'Wednesday', NULL, 1, 2, 37, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1120, 45911, 0, 0, 0, 'Thursday', NULL, 1, 2, 37, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1121, 45912, 0, 0, 0, 'Friday', NULL, 1, 2, 37, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1123, 45914, 1, 0, 1, 'Sunday', NULL, 1, 2, 37, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1124, 45915, 0, 0, 0, 'Monday', NULL, 1, 3, 38, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1125, 45916, 0, 0, 0, 'Tuesday', NULL, 1, 3, 38, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1126, 45917, 0, 0, 0, 'Wednesday', NULL, 1, 3, 38, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1127, 45918, 0, 0, 0, 'Thursday', NULL, 1, 3, 38, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1128, 45919, 0, 0, 0, 'Friday', NULL, 1, 3, 38, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1129, 45920, 1, 0, 1, 'Saturday', NULL, 1, 3, 38, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1131, 45922, 0, 0, 0, 'Monday', NULL, 1, 4, 39, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1132, 45923, 0, 0, 0, 'Tuesday', NULL, 1, 4, 39, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1133, 45924, 0, 0, 0, 'Wednesday', NULL, 1, 4, 39, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1134, 45925, 0, 0, 0, 'Thursday', NULL, 1, 4, 39, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1135, 45926, 0, 0, 0, 'Friday', NULL, 1, 4, 39, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1136, 45927, 1, 0, 1, 'Saturday', NULL, 1, 4, 39, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1138, 45929, 0, 0, 0, 'Monday', NULL, 1, 5, 40, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1139, 45930, 0, 0, 0, 'Tuesday', NULL, 1, 5, 40, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1140, 45931, 0, 0, 0, 'Wednesday', NULL, 1, 5, 40, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1141, 45932, 0, 0, 0, 'Thursday', NULL, 1, 5, 40, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1142, 45933, 0, 0, 0, 'Friday', NULL, 1, 5, 40, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1143, 45934, 1, 0, 1, 'Saturday', NULL, 1, 5, 40, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1145, 45936, 0, 0, 0, 'Monday', NULL, 1, 6, 41, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1146, 45937, 0, 0, 0, 'Tuesday', NULL, 1, 6, 41, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1147, 45938, 0, 0, 0, 'Wednesday', NULL, 1, 6, 41, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1148, 45939, 0, 0, 0, 'Thursday', NULL, 1, 6, 41, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1149, 45940, 0, 0, 0, 'Friday', NULL, 1, 6, 41, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1150, 45941, 1, 0, 1, 'Saturday', NULL, 1, 6, 41, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1152, 45943, 0, 0, 0, 'Monday', NULL, 1, 7, 42, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1153, 45944, 0, 0, 0, 'Tuesday', NULL, 1, 7, 42, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1154, 45945, 0, 0, 0, 'Wednesday', NULL, 1, 7, 42, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1155, 45946, 0, 0, 0, 'Thursday', NULL, 1, 7, 42, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1156, 45947, 0, 0, 0, 'Friday', NULL, 1, 7, 42, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1157, 45948, 1, 0, 1, 'Saturday', NULL, 1, 7, 42, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1159, 45950, 0, 1, 1, 'Monday', NULL, 1, 8, 43, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1160, 45951, 0, 1, 1, 'Tuesday', NULL, 1, 8, 43, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1161, 45952, 0, 1, 1, 'Wednesday', NULL, 1, 8, 43, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1162, 45953, 0, 1, 1, 'Thursday', NULL, 1, 8, 43, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1163, 45954, 0, 1, 1, 'Friday', NULL, 1, 8, 43, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1164, 45955, 1, 1, 1, 'Saturday', NULL, 1, 8, 43, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1166, 45957, 0, 1, 1, 'Monday', NULL, 2, 1, 44, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1167, 45958, 0, 0, 0, 'Tuesday', NULL, 2, 1, 44, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1168, 45959, 0, 0, 0, 'Wednesday', NULL, 2, 1, 44, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1169, 45960, 0, 0, 0, 'Thursday', NULL, 2, 1, 44, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1170, 45961, 0, 0, 0, 'Friday', NULL, 2, 1, 44, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1171, 45962, 1, 0, 1, 'Saturday', NULL, 2, 1, 44, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1173, 45964, 0, 0, 0, 'Monday', NULL, 2, 2, 45, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1174, 45965, 0, 0, 0, 'Tuesday', NULL, 2, 2, 45, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1175, 45966, 0, 0, 0, 'Wednesday', NULL, 2, 2, 45, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1176, 45967, 0, 0, 0, 'Thursday', NULL, 2, 2, 45, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1177, 45968, 0, 0, 0, 'Friday', NULL, 2, 2, 45, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1178, 45969, 1, 0, 1, 'Saturday', NULL, 2, 2, 45, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1180, 45971, 0, 0, 0, 'Monday', NULL, 2, 3, 46, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1181, 45972, 0, 0, 0, 'Tuesday', NULL, 2, 3, 46, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1182, 45973, 0, 0, 0, 'Wednesday', NULL, 2, 3, 46, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1183, 45974, 0, 0, 0, 'Thursday', NULL, 2, 3, 46, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1184, 45975, 0, 0, 0, 'Friday', NULL, 2, 3, 46, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1185, 45976, 1, 0, 1, 'Saturday', NULL, 2, 3, 46, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1187, 45978, 0, 0, 0, 'Monday', NULL, 2, 4, 47, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1188, 45979, 0, 0, 0, 'Tuesday', NULL, 2, 4, 47, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1189, 45980, 0, 0, 0, 'Wednesday', NULL, 2, 4, 47, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1190, 45981, 0, 0, 0, 'Thursday', NULL, 2, 4, 47, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1191, 45982, 0, 0, 0, 'Friday', NULL, 2, 4, 47, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1192, 45983, 1, 0, 1, 'Saturday', NULL, 2, 4, 47, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1194, 45985, 0, 0, 0, 'Monday', NULL, 2, 5, 48, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1195, 45986, 0, 0, 0, 'Tuesday', NULL, 2, 5, 48, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1196, 45987, 0, 0, 0, 'Wednesday', NULL, 2, 5, 48, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1197, 45988, 0, 0, 0, 'Thursday', NULL, 2, 5, 48, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1198, 45989, 0, 0, 0, 'Friday', NULL, 2, 5, 48, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1199, 45990, 1, 0, 1, 'Saturday', NULL, 2, 5, 48, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1201, 45992, 0, 0, 0, 'Monday', NULL, 2, 6, 49, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1202, 45993, 0, 0, 0, 'Tuesday', NULL, 2, 6, 49, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1203, 45994, 0, 0, 0, 'Wednesday', NULL, 2, 6, 49, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1204, 45995, 0, 0, 0, 'Thursday', NULL, 2, 6, 49, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1205, 45996, 0, 0, 0, 'Friday', NULL, 2, 6, 49, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1206, 45997, 1, 0, 1, 'Saturday', NULL, 2, 6, 49, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1208, 45999, 0, 0, 0, 'Monday', NULL, 2, 7, 50, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1209, 46000, 0, 0, 0, 'Tuesday', NULL, 2, 7, 50, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1210, 46001, 0, 0, 0, 'Wednesday', NULL, 2, 7, 50, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1211, 46002, 0, 0, 0, 'Thursday', NULL, 2, 7, 50, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1212, 46003, 0, 0, 0, 'Friday', NULL, 2, 7, 50, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1213, 46004, 1, 0, 1, 'Saturday', NULL, 2, 7, 50, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1215, 46006, 0, 0, 0, 'Monday', NULL, 2, 8, 51, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1216, 46007, 0, 0, 0, 'Tuesday', NULL, 2, 8, 51, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1217, 46008, 0, 0, 0, 'Wednesday', NULL, 2, 8, 51, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1117, 45908, 0, 0, 0, 'Monday', NULL, 1, 2, 37, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1220, 46011, 1, 1, 1, 'Saturday', NULL, 2, 8, 51, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1221, 46012, 1, 1, 1, 'Sunday', NULL, 2, 8, 51, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1222, 46013, 0, 1, 1, 'Monday', NULL, 2, 9, 52, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1223, 46014, 0, 1, 1, 'Tuesday', NULL, 2, 9, 52, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1225, 46016, 0, 1, 1, 'Thursday', NULL, 2, 9, 52, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1226, 46017, 0, 1, 1, 'Friday', NULL, 2, 9, 52, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1227, 46018, 1, 1, 1, 'Saturday', NULL, 2, 9, 52, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1228, 46019, 1, 1, 1, 'Sunday', NULL, 2, 9, 52, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1229, 46020, 0, 1, 1, 'Monday', NULL, 2, 9, 1, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1230, 46021, 0, 1, 1, 'Tuesday', NULL, 2, 9, 1, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1231, 46022, 0, 1, 1, 'Wednesday', NULL, 2, 9, 1, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1233, 46024, 0, 1, 1, 'Friday', NULL, 2, 9, 1, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1234, 46025, 1, 1, 1, 'Saturday', NULL, 2, 9, 1, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1235, 46026, 1, 1, 1, 'Sunday', NULL, 2, 9, 1, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1236, 46027, 0, 1, 1, 'Monday', NULL, 3, 1, 2, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1237, 46028, 0, 0, 0, 'Tuesday', NULL, 3, 1, 2, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1238, 46029, 0, 0, 0, 'Wednesday', NULL, 3, 1, 2, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1240, 46031, 0, 0, 0, 'Friday', NULL, 3, 1, 2, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1241, 46032, 1, 0, 1, 'Saturday', NULL, 3, 1, 2, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1242, 46033, 1, 0, 1, 'Sunday', NULL, 3, 1, 2, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1243, 46034, 0, 0, 0, 'Monday', NULL, 3, 2, 3, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1244, 46035, 0, 0, 0, 'Tuesday', NULL, 3, 2, 3, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1245, 46036, 0, 0, 0, 'Wednesday', NULL, 3, 2, 3, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1246, 46037, 0, 0, 0, 'Thursday', NULL, 3, 2, 3, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1247, 46038, 0, 0, 0, 'Friday', NULL, 3, 2, 3, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1249, 46040, 1, 0, 1, 'Sunday', NULL, 3, 2, 3, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1250, 46041, 0, 0, 0, 'Monday', NULL, 3, 3, 4, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1251, 46042, 0, 0, 0, 'Tuesday', NULL, 3, 3, 4, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1252, 46043, 0, 0, 0, 'Wednesday', NULL, 3, 3, 4, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1253, 46044, 0, 0, 0, 'Thursday', NULL, 3, 3, 4, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1254, 46045, 0, 0, 0, 'Friday', NULL, 3, 3, 4, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1256, 46047, 1, 0, 1, 'Sunday', NULL, 3, 3, 4, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1257, 46048, 0, 0, 0, 'Monday', NULL, 3, 4, 5, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1258, 46049, 0, 0, 0, 'Tuesday', NULL, 3, 4, 5, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1259, 46050, 0, 0, 0, 'Wednesday', NULL, 3, 4, 5, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1260, 46051, 0, 0, 0, 'Thursday', NULL, 3, 4, 5, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1261, 46052, 0, 0, 0, 'Friday', NULL, 3, 4, 5, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1263, 46054, 1, 0, 1, 'Sunday', NULL, 3, 4, 5, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1264, 46055, 0, 0, 0, 'Monday', NULL, 3, 5, 6, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1265, 46056, 0, 0, 0, 'Tuesday', NULL, 3, 5, 6, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1266, 46057, 0, 0, 0, 'Wednesday', NULL, 3, 5, 6, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1267, 46058, 0, 0, 0, 'Thursday', NULL, 3, 5, 6, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1268, 46059, 0, 0, 0, 'Friday', NULL, 3, 5, 6, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1269, 46060, 1, 0, 1, 'Saturday', NULL, 3, 5, 6, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1270, 46061, 1, 0, 1, 'Sunday', NULL, 3, 5, 6, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1272, 46063, 0, 0, 0, 'Tuesday', NULL, 3, 6, 7, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1273, 46064, 0, 0, 0, 'Wednesday', NULL, 3, 6, 7, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1274, 46065, 0, 0, 0, 'Thursday', NULL, 3, 6, 7, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1275, 46066, 0, 0, 0, 'Friday', NULL, 3, 6, 7, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1276, 46067, 1, 0, 1, 'Saturday', NULL, 3, 6, 7, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1277, 46068, 1, 0, 1, 'Sunday', NULL, 3, 6, 7, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1279, 46070, 0, 0, 0, 'Tuesday', NULL, 3, 7, 8, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1280, 46071, 0, 0, 0, 'Wednesday', NULL, 3, 7, 8, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1281, 46072, 0, 0, 0, 'Thursday', NULL, 3, 7, 8, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1282, 46073, 0, 0, 0, 'Friday', NULL, 3, 7, 8, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1283, 46074, 1, 0, 1, 'Saturday', NULL, 3, 7, 8, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1284, 46075, 1, 0, 1, 'Sunday', NULL, 3, 7, 8, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1286, 46077, 0, 0, 0, 'Tuesday', NULL, 3, 8, 9, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1287, 46078, 0, 0, 0, 'Wednesday', NULL, 3, 8, 9, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1288, 46079, 0, 0, 0, 'Thursday', NULL, 3, 8, 9, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1289, 46080, 0, 0, 0, 'Friday', NULL, 3, 8, 9, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1290, 46081, 1, 0, 1, 'Saturday', NULL, 3, 8, 9, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1291, 46082, 1, 0, 1, 'Sunday', NULL, 3, 8, 9, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1293, 46084, 0, 0, 0, 'Tuesday', NULL, 4, 1, 10, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1294, 46085, 0, 0, 0, 'Wednesday', NULL, 4, 1, 10, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1295, 46086, 0, 0, 0, 'Thursday', NULL, 4, 1, 10, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1296, 46087, 0, 0, 0, 'Friday', NULL, 4, 1, 10, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1297, 46088, 1, 0, 1, 'Saturday', NULL, 4, 1, 10, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1298, 46089, 1, 0, 1, 'Sunday', NULL, 4, 1, 10, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1300, 46091, 0, 0, 0, 'Tuesday', NULL, 4, 2, 11, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1301, 46092, 0, 0, 0, 'Wednesday', NULL, 4, 2, 11, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1302, 46093, 0, 0, 0, 'Thursday', NULL, 4, 2, 11, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1303, 46094, 0, 0, 0, 'Friday', NULL, 4, 2, 11, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1304, 46095, 1, 0, 1, 'Saturday', NULL, 4, 2, 11, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1305, 46096, 1, 0, 1, 'Sunday', NULL, 4, 2, 11, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1307, 46098, 0, 0, 0, 'Tuesday', NULL, 4, 3, 12, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1308, 46099, 0, 0, 0, 'Wednesday', NULL, 4, 3, 12, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1309, 46100, 0, 0, 0, 'Thursday', NULL, 4, 3, 12, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1310, 46101, 0, 0, 0, 'Friday', NULL, 4, 3, 12, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1311, 46102, 1, 0, 1, 'Saturday', NULL, 4, 3, 12, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1312, 46103, 1, 0, 1, 'Sunday', NULL, 4, 3, 12, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1314, 46105, 0, 0, 0, 'Tuesday', NULL, 4, 4, 13, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1315, 46106, 0, 0, 0, 'Wednesday', NULL, 4, 4, 13, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1316, 46107, 0, 0, 0, 'Thursday', NULL, 4, 4, 13, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1317, 46108, 0, 0, 0, 'Friday', NULL, 4, 4, 13, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1318, 46109, 1, 0, 1, 'Saturday', NULL, 4, 4, 13, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1319, 46110, 1, 0, 1, 'Sunday', NULL, 4, 4, 13, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1322, 46113, 0, 0, 0, 'Wednesday', NULL, 4, 5, 14, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1323, 46114, 0, 0, 0, 'Thursday', NULL, 4, 5, 14, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1324, 46115, 0, 1, 1, 'Friday', NULL, 4, 5, 14, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1326, 46117, 1, 0, 1, 'Sunday', NULL, 4, 5, 14, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1327, 46118, 0, 1, 1, 'Monday', NULL, 4, 6, 15, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1328, 46119, 0, 0, 0, 'Tuesday', NULL, 4, 6, 15, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1329, 46120, 0, 0, 0, 'Wednesday', NULL, 4, 6, 15, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1330, 46121, 0, 0, 0, 'Thursday', NULL, 4, 6, 15, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1331, 46122, 0, 0, 0, 'Friday', NULL, 4, 6, 15, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1332, 46123, 1, 0, 1, 'Saturday', NULL, 4, 6, 15, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1333, 46124, 1, 0, 1, 'Sunday', NULL, 4, 6, 15, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1335, 46126, 0, 0, 0, 'Tuesday', NULL, 4, 7, 16, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1336, 46127, 0, 0, 0, 'Wednesday', NULL, 4, 7, 16, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1337, 46128, 0, 0, 0, 'Thursday', NULL, 4, 7, 16, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1338, 46129, 0, 0, 0, 'Friday', NULL, 4, 7, 16, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1339, 46130, 1, 0, 1, 'Saturday', NULL, 4, 7, 16, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1340, 46131, 1, 0, 1, 'Sunday', NULL, 4, 7, 16, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1342, 46133, 0, 1, 1, 'Tuesday', NULL, 4, 8, 17, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1343, 46134, 0, 1, 1, 'Wednesday', NULL, 4, 8, 17, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1344, 46135, 0, 1, 1, 'Thursday', NULL, 4, 8, 17, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1345, 46136, 0, 1, 1, 'Friday', NULL, 4, 8, 17, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1346, 46137, 1, 1, 1, 'Saturday', NULL, 4, 8, 17, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1347, 46138, 1, 1, 1, 'Sunday', NULL, 4, 8, 17, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1349, 46140, 0, 1, 1, 'Tuesday', NULL, 4, 9, 18, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1350, 46141, 0, 1, 1, 'Wednesday', NULL, 4, 9, 18, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1351, 46142, 0, 1, 1, 'Thursday', NULL, 4, 9, 18, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1352, 46143, 0, 1, 1, 'Friday', NULL, 4, 9, 18, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1353, 46144, 1, 1, 1, 'Saturday', NULL, 4, 9, 18, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1354, 46145, 1, 1, 1, 'Sunday', NULL, 4, 9, 18, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1356, 46147, 0, 1, 1, 'Tuesday', NULL, 5, 1, 19, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1357, 46148, 0, 0, 0, 'Wednesday', NULL, 5, 1, 19, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1358, 46149, 0, 0, 0, 'Thursday', NULL, 5, 1, 19, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1359, 46150, 0, 0, 0, 'Friday', NULL, 5, 1, 19, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1360, 46151, 1, 0, 1, 'Saturday', NULL, 5, 1, 19, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1361, 46152, 1, 0, 1, 'Sunday', NULL, 5, 1, 19, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1363, 46154, 0, 0, 0, 'Tuesday', NULL, 5, 2, 20, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1364, 46155, 0, 0, 0, 'Wednesday', NULL, 5, 2, 20, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1365, 46156, 0, 0, 0, 'Thursday', NULL, 5, 2, 20, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1366, 46157, 0, 0, 0, 'Friday', NULL, 5, 2, 20, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1367, 46158, 1, 0, 1, 'Saturday', NULL, 5, 2, 20, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1368, 46159, 1, 0, 1, 'Sunday', NULL, 5, 2, 20, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1370, 46161, 0, 0, 0, 'Tuesday', NULL, 5, 3, 21, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1371, 46162, 0, 0, 0, 'Wednesday', NULL, 5, 3, 21, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1372, 46163, 0, 0, 0, 'Thursday', NULL, 5, 3, 21, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1373, 46164, 0, 0, 0, 'Friday', NULL, 5, 3, 21, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1374, 46165, 1, 0, 1, 'Saturday', NULL, 5, 3, 21, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1375, 46166, 1, 0, 1, 'Sunday', NULL, 5, 3, 21, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1377, 46168, 0, 0, 0, 'Tuesday', NULL, 5, 4, 22, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1378, 46169, 0, 0, 0, 'Wednesday', NULL, 5, 4, 22, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1379, 46170, 0, 0, 0, 'Thursday', NULL, 5, 4, 22, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1380, 46171, 0, 0, 0, 'Friday', NULL, 5, 4, 22, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1381, 46172, 1, 0, 1, 'Saturday', NULL, 5, 4, 22, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1382, 46173, 1, 0, 1, 'Sunday', NULL, 5, 4, 22, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1384, 46175, 0, 0, 0, 'Tuesday', NULL, 5, 5, 23, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1385, 46176, 0, 0, 0, 'Wednesday', NULL, 5, 5, 23, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1386, 46177, 0, 0, 0, 'Thursday', NULL, 5, 5, 23, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1387, 46178, 0, 0, 0, 'Friday', NULL, 5, 5, 23, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1388, 46179, 1, 0, 1, 'Saturday', NULL, 5, 5, 23, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1389, 46180, 1, 0, 1, 'Sunday', NULL, 5, 5, 23, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1391, 46182, 0, 0, 0, 'Tuesday', NULL, 5, 6, 24, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1392, 46183, 0, 0, 0, 'Wednesday', NULL, 5, 6, 24, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1393, 46184, 0, 0, 0, 'Thursday', NULL, 5, 6, 24, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1394, 46185, 0, 0, 0, 'Friday', NULL, 5, 6, 24, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1395, 46186, 1, 0, 1, 'Saturday', NULL, 5, 6, 24, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1396, 46187, 1, 0, 1, 'Sunday', NULL, 5, 6, 24, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1398, 46189, 0, 0, 0, 'Tuesday', NULL, 5, 7, 25, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1399, 46190, 0, 0, 0, 'Wednesday', NULL, 5, 7, 25, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1400, 46191, 0, 0, 0, 'Thursday', NULL, 5, 7, 25, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1401, 46192, 0, 0, 0, 'Friday', NULL, 5, 7, 25, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1402, 46193, 1, 0, 1, 'Saturday', NULL, 5, 7, 25, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1403, 46194, 1, 0, 1, 'Sunday', NULL, 5, 7, 25, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1405, 46196, 0, 0, 0, 'Tuesday', NULL, 5, 8, 26, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1406, 46197, 0, 0, 0, 'Wednesday', NULL, 5, 8, 26, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1407, 46198, 0, 0, 0, 'Thursday', NULL, 5, 8, 26, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1408, 46199, 0, 0, 0, 'Friday', NULL, 5, 8, 26, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1409, 46200, 1, 0, 1, 'Saturday', NULL, 5, 8, 26, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1410, 46201, 1, 0, 1, 'Sunday', NULL, 5, 8, 26, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1412, 46203, 0, 0, 0, 'Tuesday', NULL, 5, 9, 27, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1413, 46204, 0, 0, 0, 'Wednesday', NULL, 5, 9, 27, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1414, 46205, 0, 0, 0, 'Thursday', NULL, 5, 9, 27, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1415, 46206, 0, 0, 0, 'Friday', NULL, 5, 9, 27, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1416, 46207, 1, 0, 1, 'Saturday', NULL, 5, 9, 27, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1417, 46208, 1, 0, 1, 'Sunday', NULL, 5, 9, 27, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1419, 46210, 0, 0, 0, 'Tuesday', NULL, 5, 10, 28, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1420, 46211, 0, 0, 0, 'Wednesday', NULL, 5, 10, 28, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1421, 46212, 0, 0, 0, 'Thursday', NULL, 5, 10, 28, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1321, 46112, 0, 0, 0, 'Tuesday', NULL, 4, 5, 14, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1424, 46215, 1, 0, 1, 'Sunday', NULL, 5, 10, 28, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1425, 46216, 0, 1, 1, 'Monday', NULL, 5, 11, 29, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1426, 46217, 0, 0, 0, 'Tuesday', NULL, 5, 11, 29, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1427, 46218, 0, 0, 0, 'Wednesday', NULL, 5, 11, 29, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1429, 46220, 0, 0, 0, 'Friday', NULL, 5, 11, 29, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1430, 46221, 1, 0, 1, 'Saturday', NULL, 5, 11, 29, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1431, 46222, 1, 0, 1, 'Sunday', NULL, 5, 11, 29, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1432, 46223, 0, 0, 0, 'Monday', NULL, 5, 12, 30, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1433, 46224, 0, 0, 0, 'Tuesday', NULL, 5, 12, 30, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1434, 46225, 0, 0, 0, 'Wednesday', NULL, 5, 12, 30, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1435, 46226, 0, 0, 0, 'Thursday', NULL, 5, 12, 30, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1437, 46228, 1, 0, 1, 'Saturday', NULL, 5, 12, 30, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1438, 46229, 1, 0, 1, 'Sunday', NULL, 5, 12, 30, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1439, 46230, 0, 0, 0, 'Monday', NULL, 5, 13, 31, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1440, 46231, 0, 0, 0, 'Tuesday', NULL, 5, 13, 31, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1441, 46232, 0, 0, 0, 'Wednesday', NULL, 5, 13, 31, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1442, 46233, 0, 0, 0, 'Thursday', NULL, 5, 13, 31, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1444, 46235, 1, 0, 1, 'Saturday', NULL, 5, 13, 31, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1445, 46236, 1, 0, 1, 'Sunday', NULL, 5, 13, 31, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1446, 46237, 0, 0, 0, 'Monday', NULL, 5, 14, 32, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1447, 46238, 0, 0, 0, 'Tuesday', NULL, 5, 14, 32, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1448, 46239, 0, 0, 0, 'Wednesday', NULL, 5, 14, 32, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1449, 46240, 0, 0, 0, 'Thursday', NULL, 5, 14, 32, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1451, 46242, 1, 0, 1, 'Saturday', NULL, 5, 14, 32, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1452, 46243, 1, 0, 1, 'Sunday', NULL, 5, 14, 32, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1453, 46244, 0, 0, 0, 'Monday', NULL, 5, 15, 33, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1454, 46245, 0, 0, 0, 'Tuesday', NULL, 5, 15, 33, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1455, 46246, 0, 0, 0, 'Wednesday', NULL, 5, 15, 33, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1456, 46247, 0, 0, 0, 'Thursday', NULL, 5, 15, 33, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1458, 46249, 1, 0, 1, 'Saturday', NULL, 5, 15, 33, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1459, 46250, 1, 0, 1, 'Sunday', NULL, 5, 15, 33, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1460, 46251, 0, 0, 0, 'Monday', NULL, 5, 16, 34, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1461, 46252, 0, 0, 0, 'Tuesday', NULL, 5, 16, 34, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1462, 46253, 0, 0, 0, 'Wednesday', NULL, 5, 16, 34, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1463, 46254, 0, 0, 0, 'Thursday', NULL, 5, 16, 34, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1465, 46256, 1, 0, 1, 'Saturday', NULL, 5, 16, 34, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1466, 46257, 1, 0, 1, 'Sunday', NULL, 5, 16, 34, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1467, 46258, 0, 0, 0, 'Monday', NULL, 5, 17, 35, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1468, 46259, 0, 0, 0, 'Tuesday', NULL, 5, 17, 35, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1469, 46260, 0, 0, 0, 'Wednesday', NULL, 5, 17, 35, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1470, 46261, 0, 0, 0, 'Thursday', NULL, 5, 17, 35, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1472, 46263, 1, 0, 1, 'Saturday', NULL, 5, 17, 35, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1473, 46264, 1, 0, 1, 'Sunday', NULL, 5, 17, 35, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1474, 46265, 0, 0, 0, 'Monday', NULL, 1, 1, 36, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1475, 46266, 0, 0, 0, 'Tuesday', NULL, 1, 1, 36, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1476, 46267, 0, 0, 0, 'Wednesday', NULL, 1, 1, 36, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1477, 46268, 0, 0, 0, 'Thursday', NULL, 1, 1, 36, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1479, 46270, 1, 0, 1, 'Saturday', NULL, 1, 1, 36, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1480, 46271, 1, 0, 1, 'Sunday', NULL, 1, 1, 36, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1481, 46272, 0, 0, 0, 'Monday', NULL, 1, 2, 37, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1482, 46273, 0, 0, 0, 'Tuesday', NULL, 1, 2, 37, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1483, 46274, 0, 0, 0, 'Wednesday', NULL, 1, 2, 37, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1484, 46275, 0, 0, 0, 'Thursday', NULL, 1, 2, 37, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1486, 46277, 1, 0, 1, 'Saturday', NULL, 1, 2, 37, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1487, 46278, 1, 0, 1, 'Sunday', NULL, 1, 2, 37, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1488, 46279, 0, 0, 0, 'Monday', NULL, 1, 3, 38, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1489, 46280, 0, 0, 0, 'Tuesday', NULL, 1, 3, 38, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1490, 46281, 0, 0, 0, 'Wednesday', NULL, 1, 3, 38, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1491, 46282, 0, 0, 0, 'Thursday', NULL, 1, 3, 38, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1493, 46284, 1, 0, 1, 'Saturday', NULL, 1, 3, 38, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1494, 46285, 1, 0, 1, 'Sunday', NULL, 1, 3, 38, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1495, 46286, 0, 0, 0, 'Monday', NULL, 1, 4, 39, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1496, 46287, 0, 0, 0, 'Tuesday', NULL, 1, 4, 39, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1497, 46288, 0, 0, 0, 'Wednesday', NULL, 1, 4, 39, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1498, 46289, 0, 0, 0, 'Thursday', NULL, 1, 4, 39, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1501, 46292, 1, 0, 1, 'Sunday', NULL, 1, 4, 39, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1502, 46293, 0, 0, 0, 'Monday', NULL, 1, 5, 40, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1503, 46294, 0, 0, 0, 'Tuesday', NULL, 1, 5, 40, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1504, 46295, 0, 0, 0, 'Wednesday', NULL, 1, 5, 40, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1505, 46296, 0, 0, 0, 'Thursday', NULL, 1, 5, 40, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1507, 46298, 1, 0, 1, 'Saturday', NULL, 1, 5, 40, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1508, 46299, 1, 0, 1, 'Sunday', NULL, 1, 5, 40, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1509, 46300, 0, 0, 0, 'Monday', NULL, 1, 6, 41, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1510, 46301, 0, 0, 0, 'Tuesday', NULL, 1, 6, 41, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1511, 46302, 0, 0, 0, 'Wednesday', NULL, 1, 6, 41, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1512, 46303, 0, 0, 0, 'Thursday', NULL, 1, 6, 41, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1514, 46305, 1, 0, 1, 'Saturday', NULL, 1, 6, 41, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1515, 46306, 1, 0, 1, 'Sunday', NULL, 1, 6, 41, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1516, 46307, 0, 0, 0, 'Monday', NULL, 1, 7, 42, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1517, 46308, 0, 0, 0, 'Tuesday', NULL, 1, 7, 42, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1518, 46309, 0, 0, 0, 'Wednesday', NULL, 1, 7, 42, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1519, 46310, 0, 0, 0, 'Thursday', NULL, 1, 7, 42, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1521, 46312, 1, 0, 1, 'Saturday', NULL, 1, 7, 42, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1522, 46313, 1, 0, 1, 'Sunday', NULL, 1, 7, 42, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1523, 46314, 0, 0, 0, 'Monday', NULL, 1, 8, 43, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1423, 46214, 1, 0, 1, 'Saturday', NULL, 5, 10, 28, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1526, 46317, 0, 0, 0, 'Thursday', NULL, 1, 8, 43, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1527, 46318, 0, 0, 0, 'Friday', NULL, 1, 8, 43, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1529, 46320, 1, 0, 1, 'Sunday', NULL, 1, 8, 43, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1530, 46321, 0, 0, 0, 'Monday', NULL, 1, 9, 44, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1531, 46322, 0, 0, 0, 'Tuesday', NULL, 1, 9, 44, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1532, 46323, 0, 0, 0, 'Wednesday', NULL, 1, 9, 44, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1533, 46324, 0, 0, 0, 'Thursday', NULL, 1, 9, 44, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1534, 46325, 0, 0, 0, 'Friday', NULL, 1, 9, 44, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1535, 46326, 1, 0, 1, 'Saturday', NULL, 1, 9, 44, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1537, 46328, 0, 0, 0, 'Monday', NULL, 1, 10, 45, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1538, 46329, 0, 0, 0, 'Tuesday', NULL, 1, 10, 45, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1539, 46330, 0, 0, 0, 'Wednesday', NULL, 1, 10, 45, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1540, 46331, 0, 0, 0, 'Thursday', NULL, 1, 10, 45, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1541, 46332, 0, 0, 0, 'Friday', NULL, 1, 10, 45, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1542, 46333, 1, 0, 1, 'Saturday', NULL, 1, 10, 45, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1544, 46335, 0, 0, 0, 'Monday', NULL, 1, 11, 46, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1545, 46336, 0, 0, 0, 'Tuesday', NULL, 1, 11, 46, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1546, 46337, 0, 0, 0, 'Wednesday', NULL, 1, 11, 46, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1547, 46338, 0, 0, 0, 'Thursday', NULL, 1, 11, 46, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1548, 46339, 0, 0, 0, 'Friday', NULL, 1, 11, 46, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1549, 46340, 1, 0, 1, 'Saturday', NULL, 1, 11, 46, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1551, 46342, 0, 0, 0, 'Monday', NULL, 1, 12, 47, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1552, 46343, 0, 0, 0, 'Tuesday', NULL, 1, 12, 47, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1553, 46344, 0, 0, 0, 'Wednesday', NULL, 1, 12, 47, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1554, 46345, 0, 0, 0, 'Thursday', NULL, 1, 12, 47, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1555, 46346, 0, 0, 0, 'Friday', NULL, 1, 12, 47, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1556, 46347, 1, 0, 1, 'Saturday', NULL, 1, 12, 47, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1558, 46349, 0, 0, 0, 'Monday', NULL, 1, 13, 48, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1559, 46350, 0, 0, 0, 'Tuesday', NULL, 1, 13, 48, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1560, 46351, 0, 0, 0, 'Wednesday', NULL, 1, 13, 48, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1561, 46352, 0, 0, 0, 'Thursday', NULL, 1, 13, 48, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1562, 46353, 0, 0, 0, 'Friday', NULL, 1, 13, 48, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1563, 46354, 1, 0, 1, 'Saturday', NULL, 1, 13, 48, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1565, 46356, 0, 0, 0, 'Monday', NULL, 1, 14, 49, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1566, 46357, 0, 0, 0, 'Tuesday', NULL, 1, 14, 49, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1567, 46358, 0, 0, 0, 'Wednesday', NULL, 1, 14, 49, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1568, 46359, 0, 0, 0, 'Thursday', NULL, 1, 14, 49, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1569, 46360, 0, 0, 0, 'Friday', NULL, 1, 14, 49, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1570, 46361, 1, 0, 1, 'Saturday', NULL, 1, 14, 49, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1572, 46363, 0, 0, 0, 'Monday', NULL, 1, 15, 50, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1573, 46364, 0, 0, 0, 'Tuesday', NULL, 1, 15, 50, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1574, 46365, 0, 0, 0, 'Wednesday', NULL, 1, 15, 50, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1575, 46366, 0, 0, 0, 'Thursday', NULL, 1, 15, 50, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1576, 46367, 0, 0, 0, 'Friday', NULL, 1, 15, 50, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1577, 46368, 1, 0, 1, 'Saturday', NULL, 1, 15, 50, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1579, 46370, 0, 0, 0, 'Monday', NULL, 1, 16, 51, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1580, 46371, 0, 0, 0, 'Tuesday', NULL, 1, 16, 51, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1581, 46372, 0, 0, 0, 'Wednesday', NULL, 1, 16, 51, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1582, 46373, 0, 0, 0, 'Thursday', NULL, 1, 16, 51, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1583, 46374, 0, 0, 0, 'Friday', NULL, 1, 16, 51, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1584, 46375, 1, 0, 1, 'Saturday', NULL, 1, 16, 51, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1586, 46377, 0, 0, 0, 'Monday', NULL, 1, 17, 52, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1587, 46378, 0, 0, 0, 'Tuesday', NULL, 1, 17, 52, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1588, 46379, 0, 0, 0, 'Wednesday', NULL, 1, 17, 52, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1589, 46380, 0, 0, 0, 'Thursday', NULL, 1, 17, 52, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1590, 46381, 0, 0, 0, 'Friday', NULL, 1, 17, 52, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1591, 46382, 1, 0, 1, 'Saturday', NULL, 1, 17, 52, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1593, 46384, 0, 0, 0, 'Monday', NULL, 1, 18, 53, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1594, 46385, 0, 0, 0, 'Tuesday', NULL, 1, 18, 53, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1595, 46386, 0, 0, 0, 'Wednesday', NULL, 1, 18, 53, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1596, 46387, 0, 0, 0, 'Thursday', NULL, 1, 18, 53, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1597, 46388, 0, 0, 0, 'Friday', NULL, 1, 18, 53, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1598, 46389, 1, 0, 1, 'Saturday', NULL, 1, 18, 53, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1600, 46391, 0, 0, 0, 'Monday', NULL, 1, 18, 1, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1601, 46392, 0, 0, 0, 'Tuesday', NULL, 1, 18, 1, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1602, 46393, 0, 0, 0, 'Wednesday', NULL, 1, 18, 1, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1603, 46394, 0, 0, 0, 'Thursday', NULL, 1, 18, 1, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1604, 46395, 0, 0, 0, 'Friday', NULL, 1, 18, 1, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1605, 46396, 1, 0, 1, 'Saturday', NULL, 1, 18, 1, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1607, 46398, 0, 0, 0, 'Monday', NULL, 1, 19, 2, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1608, 46399, 0, 0, 0, 'Tuesday', NULL, 1, 19, 2, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1609, 46400, 0, 0, 0, 'Wednesday', NULL, 1, 19, 2, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1610, 46401, 0, 0, 0, 'Thursday', NULL, 1, 19, 2, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1611, 46402, 0, 0, 0, 'Friday', NULL, 1, 19, 2, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1612, 46403, 1, 0, 1, 'Saturday', NULL, 1, 19, 2, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1614, 46405, 0, 0, 0, 'Monday', NULL, 1, 20, 3, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1615, 46406, 0, 0, 0, 'Tuesday', NULL, 1, 20, 3, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1616, 46407, 0, 0, 0, 'Wednesday', NULL, 1, 20, 3, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1617, 46408, 0, 0, 0, 'Thursday', NULL, 1, 20, 3, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1618, 46409, 0, 0, 0, 'Friday', NULL, 1, 20, 3, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1619, 46410, 1, 0, 1, 'Saturday', NULL, 1, 20, 3, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1621, 46412, 0, 0, 0, 'Monday', NULL, 1, 21, 4, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1622, 46413, 0, 0, 0, 'Tuesday', NULL, 1, 21, 4, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1110, 45901, 0, 0, 0, 'Monday', NULL, 1, 1, 36, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1112, 45903, 0, 0, 0, 'Wednesday', NULL, 1, 1, 36, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1116, 45907, 1, 0, 1, 'Sunday', NULL, 1, 1, 36, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1525, 46316, 0, 0, 0, 'Wednesday', NULL, 1, 8, 43, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1, 44792, 0, 1, 1, 'Friday', 'Zomervakantie', 5, 5, 33, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (7, 44798, 0, 0, 0, 'Thursday', NULL, 1, 1, 34, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (16, 44807, 1, 0, 1, 'Saturday', NULL, 1, 2, 35, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (23, 44814, 1, 0, 1, 'Saturday', NULL, 1, 3, 36, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (30, 44821, 1, 0, 1, 'Saturday', NULL, 1, 4, 37, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (39, 44830, 0, 0, 0, 'Monday', NULL, 1, 6, 39, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (46, 44837, 0, 0, 0, 'Monday', NULL, 1, 7, 40, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (53, 44844, 0, 0, 0, 'Monday', NULL, 1, 8, 41, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (60, 44851, 0, 0, 0, 'Monday', NULL, 1, 9, 42, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (67, 44858, 0, 1, 1, 'Monday', 'Najaarsvakantie', 1, 10, 43, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (74, 44865, 0, 1, 1, 'Monday', 'Studiedag', 2, 1, 44, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (82, 44873, 0, 0, 0, 'Tuesday', NULL, 2, 2, 45, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (89, 44880, 0, 0, 0, 'Tuesday', NULL, 2, 3, 46, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (96, 44887, 0, 0, 0, 'Tuesday', NULL, 2, 4, 47, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (102, 44893, 0, 0, 0, 'Monday', NULL, 2, 5, 48, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (107, 44898, 1, 0, 1, 'Saturday', NULL, 2, 5, 48, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (114, 44905, 1, 0, 1, 'Saturday', NULL, 2, 6, 49, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (123, 44914, 0, 0, 0, 'Monday', NULL, 2, 8, 51, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (129, 44920, 1, 1, 1, 'Sunday', 'Kerstvakantie', 2, 8, 51, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (137, 44928, 0, 1, 1, 'Monday', 'Kerstvakantie', 2, 9, 1, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (144, 44935, 0, 1, 1, 'Monday', 'Studiedag', 3, 1, 2, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1130, 45921, 1, 0, 1, 'Sunday', NULL, 1, 3, 38, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1137, 45928, 1, 0, 1, 'Sunday', NULL, 1, 4, 39, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1144, 45935, 1, 0, 1, 'Sunday', NULL, 1, 5, 40, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1151, 45942, 1, 0, 1, 'Sunday', NULL, 1, 6, 41, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1158, 45949, 1, 0, 1, 'Sunday', NULL, 1, 7, 42, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1165, 45956, 1, 1, 1, 'Sunday', NULL, 1, 8, 43, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1172, 45963, 1, 0, 1, 'Sunday', NULL, 2, 1, 44, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1179, 45970, 1, 0, 1, 'Sunday', NULL, 2, 2, 45, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1186, 45977, 1, 0, 1, 'Sunday', NULL, 2, 3, 46, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1193, 45984, 1, 0, 1, 'Sunday', NULL, 2, 4, 47, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1200, 45991, 1, 0, 1, 'Sunday', NULL, 2, 5, 48, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1207, 45998, 1, 0, 1, 'Sunday', NULL, 2, 6, 49, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1214, 46005, 1, 0, 1, 'Sunday', NULL, 2, 7, 50, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1218, 46009, 0, 1, 1, 'Thursday', NULL, 2, 8, 51, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1224, 46015, 0, 1, 1, 'Wednesday', NULL, 2, 9, 52, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1232, 46023, 0, 1, 1, 'Thursday', NULL, 2, 9, 1, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1239, 46030, 0, 0, 0, 'Thursday', NULL, 3, 1, 2, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1248, 46039, 1, 0, 1, 'Saturday', NULL, 3, 2, 3, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1255, 46046, 1, 0, 1, 'Saturday', NULL, 3, 3, 4, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1262, 46053, 1, 0, 1, 'Saturday', NULL, 3, 4, 5, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1271, 46062, 0, 0, 0, 'Monday', NULL, 3, 6, 7, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1278, 46069, 0, 0, 0, 'Monday', NULL, 3, 7, 8, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1285, 46076, 0, 0, 0, 'Monday', NULL, 3, 8, 9, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1292, 46083, 0, 1, 1, 'Monday', NULL, 4, 1, 10, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1306, 46097, 0, 0, 0, 'Monday', NULL, 4, 3, 12, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1313, 46104, 0, 0, 0, 'Monday', NULL, 4, 4, 13, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1320, 46111, 0, 0, 0, 'Monday', NULL, 4, 5, 14, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1325, 46116, 1, 0, 1, 'Saturday', NULL, 4, 5, 14, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1334, 46125, 0, 0, 0, 'Monday', NULL, 4, 7, 16, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1341, 46132, 0, 1, 1, 'Monday', NULL, 4, 8, 17, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1348, 46139, 0, 1, 1, 'Monday', NULL, 4, 9, 18, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1355, 46146, 0, 1, 1, 'Monday', NULL, 5, 1, 19, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1362, 46153, 0, 0, 0, 'Monday', NULL, 5, 2, 20, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1369, 46160, 0, 0, 0, 'Monday', NULL, 5, 3, 21, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1376, 46167, 0, 1, 1, 'Monday', NULL, 5, 4, 22, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1383, 46174, 0, 0, 0, 'Monday', NULL, 5, 5, 23, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1390, 46181, 0, 0, 0, 'Monday', NULL, 5, 6, 24, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1397, 46188, 0, 0, 0, 'Monday', NULL, 5, 7, 25, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1404, 46195, 0, 0, 0, 'Monday', NULL, 5, 8, 26, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1411, 46202, 0, 0, 0, 'Monday', NULL, 5, 9, 27, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1418, 46209, 0, 0, 0, 'Monday', NULL, 5, 10, 28, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1422, 46213, 0, 0, 0, 'Friday', NULL, 5, 10, 28, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1436, 46227, 0, 0, 0, 'Friday', NULL, 5, 12, 30, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1443, 46234, 0, 0, 0, 'Friday', NULL, 5, 13, 31, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1450, 46241, 0, 0, 0, 'Friday', NULL, 5, 14, 32, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1457, 46248, 0, 0, 0, 'Friday', NULL, 5, 15, 33, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1464, 46255, 0, 0, 0, 'Friday', NULL, 5, 16, 34, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1471, 46262, 0, 0, 0, 'Friday', NULL, 5, 17, 35, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1478, 46269, 0, 0, 0, 'Friday', NULL, 1, 1, 36, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1485, 46276, 0, 0, 0, 'Friday', NULL, 1, 2, 37, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1492, 46283, 0, 0, 0, 'Friday', NULL, 1, 3, 38, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1499, 46290, 0, 0, 0, 'Friday', NULL, 1, 4, 39, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1506, 46297, 0, 0, 0, 'Friday', NULL, 1, 5, 40, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1513, 46304, 0, 0, 0, 'Friday', NULL, 1, 6, 41, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1520, 46311, 0, 0, 0, 'Friday', NULL, 1, 7, 42, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1524, 46315, 0, 0, 0, 'Tuesday', NULL, 1, 8, 43, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1528, 46319, 1, 0, 1, 'Saturday', NULL, 1, 8, 43, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1536, 46327, 1, 0, 1, 'Sunday', NULL, 1, 9, 44, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1543, 46334, 1, 0, 1, 'Sunday', NULL, 1, 10, 45, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1550, 46341, 1, 0, 1, 'Sunday', NULL, 1, 11, 46, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1557, 46348, 1, 0, 1, 'Sunday', NULL, 1, 12, 47, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1564, 46355, 1, 0, 1, 'Sunday', NULL, 1, 13, 48, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1571, 46362, 1, 0, 1, 'Sunday', NULL, 1, 14, 49, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1578, 46369, 1, 0, 1, 'Sunday', NULL, 1, 15, 50, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1585, 46376, 1, 0, 1, 'Sunday', NULL, 1, 16, 51, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1592, 46383, 1, 0, 1, 'Sunday', NULL, 1, 17, 52, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1606, 46397, 1, 0, 1, 'Sunday', NULL, 1, 18, 1, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1613, 46404, 1, 0, 1, 'Sunday', NULL, 1, 19, 2, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1620, 46411, 1, 0, 1, 'Sunday', NULL, 1, 20, 3, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (153, 44944, 0, 0, 0, 'Wednesday', NULL, 3, 2, 3, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (160, 44951, 0, 0, 0, 'Wednesday', NULL, 3, 3, 4, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (167, 44958, 0, 0, 0, 'Wednesday', NULL, 3, 4, 5, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (175, 44966, 0, 0, 0, 'Thursday', NULL, 3, 5, 6, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (183, 44974, 0, 0, 0, 'Friday', NULL, 3, 6, 7, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (190, 44981, 0, 0, 0, 'Friday', NULL, 3, 7, 8, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (196, 44987, 0, 1, 1, 'Thursday', 'Voorjaarsvakantie', 3, 8, 9, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (202, 44993, 0, 0, 0, 'Wednesday', NULL, 4, 1, 10, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (208, 44999, 0, 0, 0, 'Tuesday', NULL, 4, 2, 11, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (215, 45006, 0, 0, 0, 'Tuesday', NULL, 4, 3, 12, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (222, 45013, 0, 0, 0, 'Tuesday', NULL, 4, 4, 13, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (229, 45020, 0, 0, 0, 'Tuesday', NULL, 4, 5, 14, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (236, 45027, 0, 0, 0, 'Tuesday', NULL, 4, 6, 15, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (243, 45034, 0, 0, 0, 'Tuesday', NULL, 4, 7, 16, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (250, 45041, 0, 0, 0, 'Tuesday', NULL, 4, 8, 17, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (257, 45048, 0, 1, 1, 'Tuesday', 'Meivakantie', 4, 9, 18, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (264, 45055, 0, 1, 1, 'Tuesday', 'Meivakantie', 4, 10, 19, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (272, 45063, 0, 0, 0, 'Wednesday', NULL, 5, 1, 20, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (280, 45071, 0, 0, 0, 'Thursday', NULL, 5, 2, 21, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (287, 45078, 0, 0, 0, 'Thursday', NULL, 5, 3, 22, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (296, 45087, 1, 0, 1, 'Saturday', NULL, 5, 4, 23, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (303, 45094, 1, 0, 1, 'Saturday', NULL, 5, 5, 24, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (306, 45097, 0, 0, 0, 'Tuesday', NULL, 5, 6, 25, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (313, 45104, 0, 0, 0, 'Tuesday', NULL, 5, 7, 26, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (320, 45111, 0, 0, 0, 'Tuesday', NULL, 5, 8, 27, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (327, 45118, 0, 1, 1, 'Tuesday', 'Zomervakantie', 5, 9, 28, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (334, 45125, 0, 1, 1, 'Tuesday', 'Zomervakantie', 5, 10, 29, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (342, 45133, 0, 1, 1, 'Wednesday', 'Zomervakantie', 5, 11, 30, '22–23');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (350, 45141, 0, 1, 1, 'Thursday', 'Zomervakantie', 5, 12, 31, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (357, 45148, 0, 1, 1, 'Thursday', 'Zomervakantie', 5, 13, 32, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (365, 45156, 0, 1, 1, 'Friday', 'Zomervakantie', 5, 14, 33, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (373, 45164, 1, 0, 1, 'Saturday', NULL, 1, 1, 34, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (380, 45171, 1, 0, 1, 'Saturday', NULL, 1, 2, 35, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (389, 45180, 0, 0, 0, 'Monday', NULL, 1, 4, 37, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (396, 45187, 0, 0, 0, 'Monday', NULL, 1, 5, 38, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (403, 45194, 0, 0, 0, 'Monday', NULL, 1, 6, 39, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (406, 45197, 0, 0, 0, 'Thursday', NULL, 1, 6, 39, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (414, 45205, 0, 0, 0, 'Friday', NULL, 1, 7, 40, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (421, 45212, 0, 0, 0, 'Friday', NULL, 1, 8, 41, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (428, 45219, 0, 1, 1, 'Friday', 'Herfstvakantie', 1, 9, 42, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (436, 45227, 1, 0, 1, 'Saturday', NULL, 2, 1, 43, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (443, 45234, 1, 0, 1, 'Saturday', NULL, 2, 2, 44, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (451, 45242, 1, 0, 1, 'Sunday', NULL, 2, 3, 45, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (458, 45249, 1, 0, 1, 'Sunday', NULL, 2, 4, 46, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (465, 45256, 1, 0, 1, 'Sunday', NULL, 2, 5, 47, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (472, 45263, 1, 0, 1, 'Sunday', NULL, 2, 6, 48, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (479, 45270, 1, 0, 1, 'Sunday', NULL, 2, 7, 49, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (486, 45277, 1, 0, 1, 'Sunday', NULL, 2, 8, 50, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (493, 45284, 1, 1, 1, 'Sunday', 'Kerstvakantie', 2, 9, 51, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (500, 45291, 1, 1, 1, 'Sunday', 'Kerstvakantie', 2, 10, 52, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (504, 45295, 0, 1, 1, 'Thursday', 'Kerstvakantie', 2, 10, 1, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (511, 45302, 0, 0, 0, 'Thursday', NULL, 3, 1, 2, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (520, 45311, 1, 0, 1, 'Saturday', NULL, 3, 2, 3, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (527, 45318, 1, 0, 1, 'Saturday', NULL, 3, 3, 4, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (534, 45325, 1, 0, 1, 'Saturday', NULL, 3, 4, 5, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (543, 45334, 0, 0, 0, 'Monday', NULL, 3, 6, 7, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (548, 45339, 1, 1, 1, 'Saturday', 'Voorjaarsvakantie', 3, 6, 7, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (557, 45348, 0, 0, 0, 'Monday', 'Studiedag', 4, 1, 9, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (566, 45357, 0, 0, 0, 'Wednesday', NULL, 4, 2, 10, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (573, 45364, 0, 0, 0, 'Wednesday', NULL, 4, 3, 11, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (580, 45371, 0, 0, 0, 'Wednesday', NULL, 4, 4, 12, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (588, 45379, 0, 0, 0, 'Thursday', NULL, 4, 5, 13, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (596, 45387, 0, 0, 0, 'Friday', NULL, 4, 6, 14, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (603, 45394, 0, 0, 0, 'Friday', NULL, 4, 7, 15, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (604, 45395, 1, 0, 1, 'Saturday', NULL, 4, 7, 15, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (609, 45400, 0, 0, 0, 'Thursday', NULL, 4, 8, 16, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (617, 45408, 0, 0, 0, 'Friday', NULL, 4, 9, 17, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (624, 45415, 0, 1, 1, 'Friday', 'Meivakantie', 4, 10, 18, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (632, 45423, 1, 0, 1, 'Saturday', NULL, 5, 1, 19, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (639, 45430, 1, 0, 1, 'Saturday', NULL, 5, 2, 20, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (647, 45438, 1, 0, 1, 'Sunday', NULL, 5, 3, 21, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (654, 45445, 1, 0, 1, 'Sunday', NULL, 5, 4, 22, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (661, 45452, 1, 0, 1, 'Sunday', NULL, 5, 5, 23, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (668, 45459, 1, 0, 1, 'Sunday', NULL, 5, 6, 24, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (675, 45466, 1, 0, 1, 'Sunday', NULL, 5, 7, 25, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (682, 45473, 1, 0, 1, 'Sunday', NULL, 5, 8, 26, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (689, 45480, 1, 0, 1, 'Sunday', NULL, 5, 9, 27, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (696, 45487, 1, 1, 1, 'Sunday', 'Zomervakantie', 5, 10, 28, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (703, 45494, 1, 1, 1, 'Sunday', 'Zomervakantie', 5, 11, 29, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (705, 45496, 0, 1, 1, 'Tuesday', 'Zomervakantie', 5, 12, 30, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (710, 45501, 1, 1, 1, 'Sunday', 'Zomervakantie', 5, 12, 30, '23–24');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (717, 45508, 1, 1, 1, 'Sunday', 'Zomervakantie', 5, 13, 31, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (725, 45516, 0, 1, 1, 'Monday', 'Zomervakantie', 5, 15, 33, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (733, 45524, 0, 1, 1, 'Tuesday', 'Zomervakantie', 5, 16, 34, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (741, 45532, 0, 0, 0, 'Wednesday', NULL, 1, 1, 35, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (748, 45539, 0, 0, 0, 'Wednesday', NULL, 1, 2, 36, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (756, 45547, 0, 0, 0, 'Thursday', NULL, 1, 3, 37, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (763, 45554, 0, 0, 0, 'Thursday', NULL, 1, 4, 38, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (772, 45563, 1, 0, 1, 'Saturday', NULL, 1, 5, 39, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (779, 45570, 1, 0, 1, 'Saturday', NULL, 1, 6, 40, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (786, 45577, 1, 0, 1, 'Saturday', NULL, 1, 7, 41, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (795, 45586, 0, 0, 0, 'Monday', NULL, 1, 9, 43, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (802, 45593, 0, 1, 1, 'Monday', 'Herfstvakantie', 1, 10, 44, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (805, 45596, 0, 1, 1, 'Thursday', 'Herfstvakantie', 1, 10, 44, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (809, 45600, 0, 1, 1, 'Monday', 'Studiedag', 2, 1, 45, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (818, 45609, 0, 0, 0, 'Wednesday', NULL, 2, 2, 46, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (825, 45616, 0, 0, 0, 'Wednesday', NULL, 2, 3, 47, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (832, 45623, 0, 0, 0, 'Wednesday', NULL, 2, 4, 48, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (840, 45631, 0, 0, 0, 'Thursday', NULL, 2, 5, 49, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (848, 45639, 0, 0, 0, 'Friday', NULL, 2, 6, 50, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (855, 45646, 0, 0, 0, 'Friday', NULL, 2, 7, 51, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (862, 45653, 0, 1, 1, 'Friday', 'Kerstvakantie', 2, 8, 52, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (869, 45660, 0, 1, 1, 'Friday', 'Kerstvakantie', 2, 8, 1, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (877, 45668, 1, 0, 1, 'Saturday', NULL, 3, 1, 2, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (885, 45676, 1, 0, 1, 'Sunday', NULL, 3, 2, 3, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (892, 45683, 1, 0, 1, 'Sunday', NULL, 3, 3, 4, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (899, 45690, 1, 0, 1, 'Sunday', NULL, 3, 4, 5, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (906, 45697, 1, 0, 1, 'Sunday', NULL, 3, 5, 6, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (908, 45699, 0, 0, 0, 'Tuesday', NULL, 3, 6, 7, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (915, 45706, 0, 0, 0, 'Tuesday', NULL, 3, 7, 8, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (922, 45713, 0, 0, 0, 'Tuesday', NULL, 3, 8, 9, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (929, 45720, 0, 0, 0, 'Tuesday', NULL, 3, 9, 10, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (936, 45727, 0, 0, 0, 'Tuesday', NULL, 3, 10, 11, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (943, 45734, 0, 0, 0, 'Tuesday', NULL, 3, 11, 12, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (950, 45741, 0, 0, 0, 'Tuesday', NULL, 3, 12, 13, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (957, 45748, 0, 0, 0, 'Tuesday', NULL, 3, 13, 14, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (964, 45755, 0, 0, 0, 'Tuesday', NULL, 3, 14, 15, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (971, 45762, 0, 0, 0, 'Tuesday', NULL, 3, 15, 16, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (978, 45769, 0, 0, 0, 'Tuesday', NULL, 3, 16, 17, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (985, 45776, 0, 0, 0, 'Tuesday', NULL, 3, 17, 18, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (992, 45783, 0, 0, 0, 'Tuesday', NULL, 3, 18, 19, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (999, 45790, 0, 0, 0, 'Tuesday', NULL, 3, 19, 20, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1006, 45797, 0, 0, 0, 'Tuesday', NULL, NULL, 20, 21, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1012, 45803, 0, 0, 0, 'Monday', NULL, NULL, 21, 22, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1019, 45810, 0, 0, 0, 'Monday', NULL, NULL, 22, 23, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1026, 45817, 0, 0, 0, 'Monday', NULL, NULL, 23, 24, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1033, 45824, 0, 0, 0, 'Monday', NULL, NULL, 24, 25, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1040, 45831, 0, 0, 0, 'Monday', NULL, NULL, 25, 26, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1047, 45838, 0, 0, 0, 'Monday', NULL, NULL, 26, 27, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1054, 45845, 0, 0, 0, 'Monday', NULL, NULL, 27, 28, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1061, 45852, 0, 0, 0, 'Monday', NULL, NULL, 28, 29, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1068, 45859, 0, 0, 0, 'Monday', NULL, NULL, 29, 30, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1075, 45866, 0, 0, 0, 'Monday', NULL, NULL, 30, 31, '24–25');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1082, 45873, 0, 0, 0, 'Monday', NULL, NULL, 31, 32, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1089, 45880, 0, 0, 0, 'Monday', NULL, NULL, 32, 33, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1096, 45887, 0, 0, 0, 'Monday', NULL, NULL, 33, 34, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1103, 45894, 0, 0, 0, 'Monday', NULL, NULL, 34, 35, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1111, 45902, 0, 0, 0, 'Tuesday', NULL, 1, 1, 36, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1219, 46010, 0, 1, 1, 'Friday', NULL, 2, 8, 51, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1500, 46291, 1, 0, 1, 'Saturday', NULL, 1, 4, 39, '26–27');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1122, 45913, 1, 0, 1, 'Saturday', NULL, 1, 2, 37, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1299, 46090, 0, 0, 0, 'Monday', NULL, 4, 2, 11, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1428, 46219, 0, 0, 0, 'Thursday', NULL, 5, 11, 29, '25–26');
INSERT INTO public.dates (id, date, weekend, holiday, day_off, week_day, remark, term, term_week, week, year_term) VALUES (1599, 46390, 1, 0, 1, 'Sunday', NULL, 1, 18, 53, '26–27');


--
-- Data for Name: enrollments; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (109, 23, 87, NULL, NULL, NULL, NULL, '109', 5, false, NULL);
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (110, 23, 87, NULL, NULL, NULL, NULL, '110', 5, false, NULL);
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (111, 23, 87, NULL, NULL, NULL, NULL, '111', 5, false, NULL);
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (103, 29, 61, NULL, NULL, NULL, NULL, '103', 5, false, NULL);
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (104, 29, 61, NULL, NULL, NULL, NULL, '104', 5, false, NULL);
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (105, 29, 61, NULL, NULL, NULL, NULL, '105', 5, false, NULL);
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (76, 29, 54, '2025-09-05', '2025-09-19', 100, NULL, '95', 1, false, '25–26');
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (77, 29, 54, '2025-10-01', '2025-10-15', 100, NULL, '96', 1, false, '25–26');
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (79, 29, 55, '2025-10-01', '2025-10-15', 100, NULL, '96', 1, false, '25–26');
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (80, 29, 159, '2025-09-12', '2025-09-26', 100, NULL, '98', 1, false, '25–26');
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (81, 29, 57, '2025-09-05', '2025-09-19', 97.5, NULL, '96', 1, false, '25–26');
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (82, 29, 75, '2025-10-01', '2025-10-15', 100, NULL, '97', 1, false, '25–26');
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (83, 29, 118, '2025-09-19', '2025-10-03', 100, NULL, '96', 1, false, '25–26');
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (84, 29, 80, '2025-10-01', '2025-10-15', 98, NULL, '97', 1, false, '25–26');
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (85, 29, 60, '2025-09-12', '2025-09-26', 99, NULL, '108', 1, false, '25–26');
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (86, 29, 97, '2025-09-12', '2025-09-26', 100, NULL, '9–10', 1, false, '25–26');
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (102, 29, 61, NULL, NULL, NULL, NULL, '102', 4, false, NULL);
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (87, 29, 61, '2026-01-30', '2026-02-13', 99, NULL, '100', 3, false, '25–26');
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (107, 29, 62, '2026-01-29', '2026-02-12', 100, NULL, '100', 3, false, '25–26');
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (108, 29, 62, '2026-01-09', '2026-01-23', 98, NULL, '99', 3, false, '25–26');
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (75, 29, 53, '2025-09-19', '2025-10-03', 97.5, NULL, '96', 1, false, '25–26');
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (101, 29, 61, '2026-02-14', NULL, NULL, NULL, '101', 4, false, NULL);
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (78, 29, 55, '2025-09-05', '2025-09-19', 99.5, NULL, '95', 1, false, '25–26');
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (88, 29, 61, '2026-01-09', '2026-01-23', 100, NULL, '99', 3, false, '25–26');
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (91, 29, 68, '2026-01-30', '2026-02-13', 99, NULL, '100', 3, false, '25–26');
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (92, 29, 68, '2026-01-09', '2026-01-23', 100, NULL, '99', 3, false, '25–26');
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (93, 29, 56, '2026-01-08', '2026-01-22', 100, NULL, '102', 3, false, '25–26');
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (94, 29, 57, '2026-01-30', '2026-02-13', 100, NULL, '100', 3, false, '25–26');
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (95, 29, 57, '2026-01-16', '2026-01-30', 100, NULL, '99', 3, false, '25–26');
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (96, 29, 74, '2026-02-05', '2026-02-19', 92, NULL, '4', 3, false, '25–26');
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (97, 29, 80, '2026-02-05', '2026-02-19', 100, NULL, '100', 3, false, '25–26');
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (98, 29, 80, '2026-01-16', '2026-01-30', 97.5, NULL, '99', 3, false, '25–26');
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (99, 29, 97, '2026-01-16', '2026-01-30', 100, NULL, '16–17', 3, false, '25–26');
INSERT INTO public.enrollments (id, student_id, course_id, date_started, date_ended, grade, remarks, number, term, is_repeat, year_term) OVERRIDING SYSTEM VALUE VALUES (100, 29, 97, '2026-02-05', '2026-02-19', 100, NULL, '18–19', 3, false, '25–26');


--
-- Data for Name: families; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.families (id, first_name, last_name, address, city, postal_code) OVERRIDING SYSTEM VALUE VALUES (1, 'Paul', 'Littel', NULL, NULL, NULL);
INSERT INTO public.families (id, first_name, last_name, address, city, postal_code) OVERRIDING SYSTEM VALUE VALUES (2, 'Andrew', 'Yong', 'Polderlaan 197', 'Waddinxveen', NULL);
INSERT INTO public.families (id, first_name, last_name, address, city, postal_code) OVERRIDING SYSTEM VALUE VALUES (3, 'Ado', 'Adeleke', NULL, NULL, NULL);
INSERT INTO public.families (id, first_name, last_name, address, city, postal_code) OVERRIDING SYSTEM VALUE VALUES (4, 'Onbekend', 'Harkes', NULL, NULL, NULL);


--
-- Data for Name: inventory; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.inventory (id, pace_versions_id, student_id, number_in_possession) OVERRIDING SYSTEM VALUE VALUES (1, 1, 9996, 3);
INSERT INTO public.inventory (id, pace_versions_id, student_id, number_in_possession) OVERRIDING SYSTEM VALUE VALUES (2, 1, 9997, 2);
INSERT INTO public.inventory (id, pace_versions_id, student_id, number_in_possession) OVERRIDING SYSTEM VALUE VALUES (3, 2, 9997, 4);
INSERT INTO public.inventory (id, pace_versions_id, student_id, number_in_possession) OVERRIDING SYSTEM VALUE VALUES (4, 2, 9998, 1);
INSERT INTO public.inventory (id, pace_versions_id, student_id, number_in_possession) OVERRIDING SYSTEM VALUE VALUES (5, 3, 9996, 5);
INSERT INTO public.inventory (id, pace_versions_id, student_id, number_in_possession) OVERRIDING SYSTEM VALUE VALUES (6, 3, 9999, 2);
INSERT INTO public.inventory (id, pace_versions_id, student_id, number_in_possession) OVERRIDING SYSTEM VALUE VALUES (7, 4, 9998, 3);
INSERT INTO public.inventory (id, pace_versions_id, student_id, number_in_possession) OVERRIDING SYSTEM VALUE VALUES (8, 4, 9999, 6);
INSERT INTO public.inventory (id, pace_versions_id, student_id, number_in_possession) OVERRIDING SYSTEM VALUE VALUES (9, 5, 9996, 2);
INSERT INTO public.inventory (id, pace_versions_id, student_id, number_in_possession) OVERRIDING SYSTEM VALUE VALUES (10, 5, 9997, 3);
INSERT INTO public.inventory (id, pace_versions_id, student_id, number_in_possession) OVERRIDING SYSTEM VALUE VALUES (11, 5, 9998, 1);
INSERT INTO public.inventory (id, pace_versions_id, student_id, number_in_possession) OVERRIDING SYSTEM VALUE VALUES (12, 6, 9999, 4);
INSERT INTO public.inventory (id, pace_versions_id, student_id, number_in_possession) OVERRIDING SYSTEM VALUE VALUES (13, 7, 9996, 2);
INSERT INTO public.inventory (id, pace_versions_id, student_id, number_in_possession) OVERRIDING SYSTEM VALUE VALUES (14, 8, 9997, 5);
INSERT INTO public.inventory (id, pace_versions_id, student_id, number_in_possession) OVERRIDING SYSTEM VALUE VALUES (15, 9, 9998, 3);
INSERT INTO public.inventory (id, pace_versions_id, student_id, number_in_possession) OVERRIDING SYSTEM VALUE VALUES (16, 10, 9999, 1);
INSERT INTO public.inventory (id, pace_versions_id, student_id, number_in_possession) OVERRIDING SYSTEM VALUE VALUES (17, 11, 9996, 4);
INSERT INTO public.inventory (id, pace_versions_id, student_id, number_in_possession) OVERRIDING SYSTEM VALUE VALUES (18, 12, 9997, 2);


--
-- Data for Name: invitations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.invitations (id, token, role, family_id, email, created_by, created_at, used_by, used_at, expires_at) OVERRIDING SYSTEM VALUE VALUES (2, 'c7b9e5c7-c4dd-48fc-94e8-25265b508f62', 'parent', 2, 'sandra.mo@gmail.com', '49604856', '2026-03-10 15:48:02.547653', '55888484', '2026-03-10 15:49:25.195', '2026-03-17 15:48:02.547');
INSERT INTO public.invitations (id, token, role, family_id, email, created_by, created_at, used_by, used_at, expires_at) OVERRIDING SYSTEM VALUE VALUES (1, 'f00f62ac-6859-4059-bb64-b7bb00cff217', 'teacher', NULL, 's.bezemer@ceder.nl', '49604856', '2026-03-10 15:47:37.877547', '56013081', '2026-03-13 15:18:14.903', '2026-03-17 15:47:37.876');


--
-- Data for Name: order_list_items; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.order_list_items (id, order_list_id, pace_id, course_id, enrollment_number, student_id, enrollment_id, quantity, initially_to_order, from_inventory, final_to_order, delivered) OVERRIDING SYSTEM VALUE VALUES (9, 1, 712, 62, '100', 29, 107, 1, 1, 0, 1, false);
INSERT INTO public.order_list_items (id, order_list_id, pace_id, course_id, enrollment_number, student_id, enrollment_id, quantity, initially_to_order, from_inventory, final_to_order, delivered) OVERRIDING SYSTEM VALUE VALUES (10, 1, 772, 68, '100', 29, 91, 1, 1, 0, 1, false);
INSERT INTO public.order_list_items (id, order_list_id, pace_id, course_id, enrollment_number, student_id, enrollment_id, quantity, initially_to_order, from_inventory, final_to_order, delivered) OVERRIDING SYSTEM VALUE VALUES (1, 1, 815, 74, '4', 29, 96, 1, 1, 0, 1, true);
INSERT INTO public.order_list_items (id, order_list_id, pace_id, course_id, enrollment_number, student_id, enrollment_id, quantity, initially_to_order, from_inventory, final_to_order, delivered) OVERRIDING SYSTEM VALUE VALUES (2, 1, 1334, 97, '16–17', 29, 99, 1, 1, 0, 1, true);
INSERT INTO public.order_list_items (id, order_list_id, pace_id, course_id, enrollment_number, student_id, enrollment_id, quantity, initially_to_order, from_inventory, final_to_order, delivered) OVERRIDING SYSTEM VALUE VALUES (3, 1, 1336, 97, '18–19', 29, 100, 1, 1, 0, 1, true);
INSERT INTO public.order_list_items (id, order_list_id, pace_id, course_id, enrollment_number, student_id, enrollment_id, quantity, initially_to_order, from_inventory, final_to_order, delivered) OVERRIDING SYSTEM VALUE VALUES (4, 1, 771, 68, '99', 29, 92, 1, 1, 0, 1, true);
INSERT INTO public.order_list_items (id, order_list_id, pace_id, course_id, enrollment_number, student_id, enrollment_id, quantity, initially_to_order, from_inventory, final_to_order, delivered) OVERRIDING SYSTEM VALUE VALUES (7, 1, 711, 62, '99', 29, 108, 1, 1, 0, 1, true);
INSERT INTO public.order_list_items (id, order_list_id, pace_id, course_id, enrollment_number, student_id, enrollment_id, quantity, initially_to_order, from_inventory, final_to_order, delivered) OVERRIDING SYSTEM VALUE VALUES (12, 1, NULL, 57, '99', 29, 95, 1, 1, 0, 1, true);
INSERT INTO public.order_list_items (id, order_list_id, pace_id, course_id, enrollment_number, student_id, enrollment_id, quantity, initially_to_order, from_inventory, final_to_order, delivered) OVERRIDING SYSTEM VALUE VALUES (13, 1, NULL, 57, '100', 29, 94, 1, 1, 0, 1, true);
INSERT INTO public.order_list_items (id, order_list_id, pace_id, course_id, enrollment_number, student_id, enrollment_id, quantity, initially_to_order, from_inventory, final_to_order, delivered) OVERRIDING SYSTEM VALUE VALUES (14, 1, NULL, 56, '102', 29, 93, 1, 1, 0, 1, true);
INSERT INTO public.order_list_items (id, order_list_id, pace_id, course_id, enrollment_number, student_id, enrollment_id, quantity, initially_to_order, from_inventory, final_to_order, delivered) OVERRIDING SYSTEM VALUE VALUES (8, 1, 700, 61, '100', 29, 87, 1, 1, 0, 1, true);
INSERT INTO public.order_list_items (id, order_list_id, pace_id, course_id, enrollment_number, student_id, enrollment_id, quantity, initially_to_order, from_inventory, final_to_order, delivered) OVERRIDING SYSTEM VALUE VALUES (6, 1, 859, 80, '99', 29, 98, 1, 1, 0, 1, true);
INSERT INTO public.order_list_items (id, order_list_id, pace_id, course_id, enrollment_number, student_id, enrollment_id, quantity, initially_to_order, from_inventory, final_to_order, delivered) OVERRIDING SYSTEM VALUE VALUES (11, 1, 860, 80, '100', 29, 97, 1, 1, 0, 1, true);
INSERT INTO public.order_list_items (id, order_list_id, pace_id, course_id, enrollment_number, student_id, enrollment_id, quantity, initially_to_order, from_inventory, final_to_order, delivered) OVERRIDING SYSTEM VALUE VALUES (5, 1, 699, 61, '99', 29, 88, 1, 1, 0, 1, true);


--
-- Data for Name: order_lists; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.order_lists (id, name, term, year_term, created_at) OVERRIDING SYSTEM VALUE VALUES (1, 'Order list 2026-03-16 23:17', 3, '25–26', '2026-03-16 22:17:16.257839');


--
-- Data for Name: pace_courses; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1, 1, 1, 0, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (2, 2, 1, 0, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (3, 3, 1, 0, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (4, 4, 1, 0, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (5, 5, 1, 0, '6');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (6, 6, 1, 0, '7');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (7, 7, 1, 0, '8');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (8, 8, 1, 0, '9');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (9, 9, 1, 0, '10');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (10, 10, 1, 0, '11');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (11, 11, 1, 0, '12');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (12, 12, 2, 0, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (13, 13, 2, 0, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (14, 14, 2, 0, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (15, 15, 2, 0, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (16, 16, 2, 0, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (17, 17, 2, 0, '6');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (18, 18, 2, 0, '7');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (19, 19, 2, 0, '8');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (20, 20, 2, 0, '9');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (21, 21, 2, 0, '10');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (22, 22, 2, 0, '11');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (23, 23, 2, 0, '12');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (24, 24, 3, 0, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (25, 25, 3, 0, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (26, 26, 3, 0, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (27, 27, 3, 0, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (28, 28, 3, 0, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (29, 29, 3, 0, '6');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (30, 30, 3, 0, '7');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (31, 31, 3, 0, '8');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (32, 32, 3, 0, '9');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (33, 33, 3, 0, '10');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (34, 34, 3, 0, '11');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (35, 35, 3, 0, '12');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (36, 36, 4, 0, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (37, 37, 4, 0, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (38, 38, 4, 0, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (39, 39, 4, 0, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (40, 40, 4, 0, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (41, 41, 4, 0, '6');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (42, 42, 4, 0, '7');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (43, 43, 4, 0, '8');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (44, 44, 4, 0, '9');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (45, 45, 4, 0, '10');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (46, 46, 4, 0, '11');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (47, 47, 4, 0, '12');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (48, 48, 5, 0, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (49, 49, 5, 0, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (50, 50, 5, 0, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (51, 51, 5, 0, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (52, 52, 5, 0, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (53, 53, 5, 0, '6');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (54, 54, 5, 0, '7');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (55, 55, 5, 0, '8');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (56, 56, 5, 0, '9');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (57, 57, 5, 0, '10');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (58, 58, 5, 0, '11');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (59, 59, 5, 0, '12');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (60, 60, 6, NULL, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (61, 61, 6, NULL, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (62, 62, 6, NULL, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (63, 63, 6, NULL, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (64, 64, 6, NULL, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (65, 65, 6, NULL, '6');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (66, 66, 6, NULL, '7');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (67, 67, 6, NULL, '8');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (68, 68, 6, NULL, '9');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (69, 69, 6, NULL, '10');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (70, 70, 6, NULL, '11');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (71, 71, 6, NULL, '12');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (72, 72, 7, 0, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (73, 73, 7, 0, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (74, 74, 7, 0, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (75, 75, 7, 0, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (76, 76, 7, 0, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (77, 77, 7, 0, '6');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (78, 78, 7, 0, '7');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (79, 79, 7, 0, '8');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (80, 80, 7, 0, '9');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (81, 81, 7, 0, '10');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (82, 82, 7, 0, '11');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (83, 83, 7, 0, '12');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (84, 84, 8, 0, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (85, 85, 8, 0, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (86, 86, 8, 0, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (87, 87, 8, 0, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (88, 88, 8, 0, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (89, 89, 8, 0, '6');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (90, 90, 8, 0, '7');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (91, 91, 8, 0, '8');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (92, 92, 8, 0, '9');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (93, 93, 8, 0, '10');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (94, 94, 8, 0, '11');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (95, 95, 8, 0, '12');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (96, 96, 9, 0, '13');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (97, 97, 9, 0, '14');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (98, 98, 9, 0, '15');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (99, 99, 9, 0, '16');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (100, 100, 9, 0, '17');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (101, 101, 9, 0, '18');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (102, 102, 9, 0, '19');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (103, 103, 9, 0, '20');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (104, 104, 9, 0, '21');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (105, 105, 9, 0, '22');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (106, 106, 9, 0, '23');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (107, 107, 9, 0, '24');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (108, 108, 10, 0, '13');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (109, 109, 10, 0, '14');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (110, 110, 10, 0, '15');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (111, 111, 10, 0, '16');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (112, 112, 10, 0, '17');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (113, 113, 10, 0, '18');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (114, 114, 10, 0, '19');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (115, 115, 10, 0, '20');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (116, 116, 10, 0, '21');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (117, 117, 10, 0, '22');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (118, 118, 10, 0, '23');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (119, 119, 10, 0, '24');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (120, 120, 11, 0, '13');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (121, 121, 11, 0, '14');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (122, 122, 11, 0, '15');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (123, 123, 11, 0, '16');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (124, 124, 11, 0, '17');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (125, 125, 11, 0, '18');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (126, 126, 11, 0, '19');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (127, 127, 11, 0, '20');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (128, 128, 11, 0, '21');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (129, 129, 11, 0, '22');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (130, 130, 11, 0, '23');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (131, 131, 11, 0, '24');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (132, 132, 12, 0, '13');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (133, 133, 12, 0, '14');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (134, 134, 12, 0, '15');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (135, 135, 12, 0, '16');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (136, 136, 12, 0, '17');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (137, 137, 12, 0, '18');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (138, 138, 12, 0, '19');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (139, 139, 12, 0, '20');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (140, 140, 12, 0, '21');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (141, 141, 12, 0, '22');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (142, 142, 12, 0, '23');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (143, 143, 12, 0, '24');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (144, 144, 13, NULL, '13');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (145, 145, 13, NULL, '14');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (146, 146, 13, NULL, '15');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (147, 147, 13, NULL, '16');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (148, 148, 13, NULL, '17');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (149, 149, 13, NULL, '18');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (150, 150, 13, NULL, '19');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (151, 151, 13, NULL, '20');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (152, 152, 13, NULL, '21');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (153, 153, 13, NULL, '22');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (154, 154, 13, NULL, '23');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (155, 155, 13, NULL, '24');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (156, 156, 14, 0, '13');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (157, 157, 14, 0, '14');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (158, 158, 14, 0, '15');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (159, 159, 14, 0, '16');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (160, 160, 14, 0, '17');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (161, 161, 14, 0, '18');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (162, 162, 14, 0, '19');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (163, 163, 14, 0, '20');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (164, 164, 14, 0, '21');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (165, 165, 14, 0, '22');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (166, 166, 14, 0, '23');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (167, 167, 14, 0, '24');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (168, 168, 15, 0, '13');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (169, 169, 15, 0, '14');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (170, 170, 15, 0, '15');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (171, 171, 15, 0, '16');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (172, 172, 15, 0, '17');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (173, 173, 15, 0, '18');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (174, 174, 15, 0, '19');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (175, 175, 15, 0, '20');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (176, 176, 15, 0, '21');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (177, 177, 15, 0, '22');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (178, 178, 15, 0, '23');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (179, 179, 15, 0, '24');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (180, 180, 16, 0, '25');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (181, 181, 16, 0, '26');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (182, 182, 16, 0, '27');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (183, 183, 16, 0, '28');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (184, 184, 16, 0, '29');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (185, 185, 16, 0, '30');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (186, 186, 16, 0, '31');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (187, 187, 16, 0, '32');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (188, 188, 16, 0, '33');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (189, 189, 16, 0, '34');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (190, 190, 16, 0, '35');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (191, 191, 16, 0, '36');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (192, 192, 17, 0, '25');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (193, 193, 17, 0, '26');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (194, 194, 17, 0, '27');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (195, 195, 17, 0, '28');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (196, 196, 17, 0, '29');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (197, 197, 17, 0, '30');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (198, 198, 17, 0, '31');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (199, 199, 17, 0, '32');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (200, 200, 17, 0, '33');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (201, 201, 17, 0, '34');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (202, 202, 17, 0, '35');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (203, 203, 17, 0, '36');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (204, 204, 18, 0, '25');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (205, 205, 18, 0, '26');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (206, 206, 18, 0, '27');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (207, 207, 18, 0, '28');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (208, 208, 18, 0, '29');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (209, 209, 18, 0, '30');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (210, 210, 18, 0, '31');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (211, 211, 18, 0, '32');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (212, 212, 18, 0, '33');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (213, 213, 18, 0, '34');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (214, 214, 18, 0, '35');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (215, 215, 18, 0, '36');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (216, 216, 19, 0, '25');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (217, 217, 19, 0, '26');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (218, 218, 19, 0, '27');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (219, 219, 19, 0, '28');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (220, 220, 19, 0, '29');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (221, 221, 19, 0, '30');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (222, 222, 19, 0, '31');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (223, 223, 19, 0, '32');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (224, 224, 19, 0, '33');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (225, 225, 19, 0, '34');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (226, 226, 19, 0, '35');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (227, 227, 19, 0, '36');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (228, 228, 20, NULL, '25');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (229, 229, 20, NULL, '26');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (230, 230, 20, NULL, '27');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (231, 231, 20, NULL, '28');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (232, 232, 20, NULL, '29');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (233, 233, 20, NULL, '30');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (234, 234, 20, NULL, '31');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (235, 235, 20, NULL, '32');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (236, 236, 20, NULL, '33');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (237, 237, 20, NULL, '34');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (238, 238, 20, NULL, '35');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (239, 239, 20, NULL, '36');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (240, 240, 21, 0, '25');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (241, 241, 21, 0, '26');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (242, 242, 21, 0, '27');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (243, 243, 21, 0, '28');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (244, 244, 21, 0, '29');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (245, 245, 21, 0, '30');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (246, 246, 21, 0, '31');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (247, 247, 21, 0, '32');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (248, 248, 21, 0, '33');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (249, 249, 21, 0, '34');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (250, 250, 21, 0, '35');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (251, 251, 21, 0, '36');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (252, 252, 22, 0, '25');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (253, 253, 22, 0, '26');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (254, 254, 22, 0, '27');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (255, 255, 22, 0, '28');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (256, 256, 22, 0, '29');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (257, 257, 22, 0, '30');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (258, 258, 22, 0, '31');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (259, 259, 22, 0, '32');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (260, 260, 22, 0, '33');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (261, 261, 22, 0, '34');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (262, 262, 22, 0, '35');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (263, 263, 22, 0, '36');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (264, 264, 23, 0, '37');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (265, 265, 23, 0, '38');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (266, 266, 23, 0, '39');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (267, 267, 23, 0, '40');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (268, 268, 23, 0, '41');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (269, 269, 23, 0, '42');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (270, 270, 23, 0, '43');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (271, 271, 23, 0, '44');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (272, 272, 23, 0, '45');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (273, 273, 23, 0, '46');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (274, 274, 23, 0, '47');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (275, 275, 23, 0, '48');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (276, 276, 24, 0, '37');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (277, 277, 24, 0, '38');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (278, 278, 24, 0, '39');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (279, 279, 24, 0, '40');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (280, 280, 24, 0, '41');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (281, 281, 24, 0, '42');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (282, 282, 24, 0, '43');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (283, 283, 24, 0, '44');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (284, 284, 24, 0, '45');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (285, 285, 24, 0, '46');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (286, 286, 24, 0, '47');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (287, 287, 24, 0, '48');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (288, 288, 25, 0, '37');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (289, 289, 25, 0, '38');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (290, 290, 25, 0, '39');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (291, 291, 25, 0, '40');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (292, 292, 25, 0, '41');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (293, 293, 25, 0, '42');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (294, 294, 25, 0, '43');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (295, 295, 25, 0, '44');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (296, 296, 25, 0, '45');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (297, 297, 25, 0, '46');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (298, 298, 25, 0, '47');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (299, 299, 25, 0, '48');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (300, 300, 26, 0, '37');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (301, 301, 26, 0, '38');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (302, 302, 26, 0, '39');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (303, 303, 26, 0, '40');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (304, 304, 26, 0, '41');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (305, 305, 26, 0, '42');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (306, 306, 26, 0, '43');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (307, 307, 26, 0, '44');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (308, 308, 26, 0, '45');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (309, 309, 26, 0, '46');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (310, 310, 26, 0, '47');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (311, 311, 26, 0, '48');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (312, 312, 27, NULL, '37');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (313, 313, 27, NULL, '38');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (314, 314, 27, NULL, '39');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (315, 315, 27, NULL, '40');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (316, 316, 27, NULL, '41');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (317, 317, 27, NULL, '42');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (318, 318, 27, NULL, '43');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (319, 319, 27, NULL, '44');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (320, 320, 27, NULL, '45');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (321, 321, 27, NULL, '46');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (322, 322, 27, NULL, '47');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (323, 323, 27, NULL, '48');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (324, 324, 28, 0, '37');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (325, 325, 28, 0, '38');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (326, 326, 28, 0, '39');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (327, 327, 28, 0, '40');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (328, 328, 28, 0, '41');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (329, 329, 28, 0, '42');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (330, 330, 28, 0, '43');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (331, 331, 28, 0, '44');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (332, 332, 28, 0, '45');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (333, 333, 28, 0, '46');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (334, 334, 28, 0, '47');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (335, 335, 28, 0, '48');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (336, 336, 29, 0, '37');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (337, 337, 29, 0, '38');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (338, 338, 29, 0, '39');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (339, 339, 29, 0, '40');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (340, 340, 29, 0, '41');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (341, 341, 29, 0, '42');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (342, 342, 29, 0, '43');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (343, 343, 29, 0, '44');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (344, 344, 29, 0, '45');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (345, 345, 29, 0, '46');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (346, 346, 29, 0, '47');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (347, 347, 29, 0, '48');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (348, 348, 30, 0, '49');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (349, 349, 30, 0, '50');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (350, 350, 30, 0, '51');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (351, 351, 30, 0, '52');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (352, 352, 30, 0, '53');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (353, 353, 30, 0, '54');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (354, 354, 30, 0, '55');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (355, 355, 30, 0, '56');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (356, 356, 30, 0, '57');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (357, 357, 30, 0, '58');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (358, 358, 30, 0, '59');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (359, 359, 30, 0, '60');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (360, 360, 31, 0, '49');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (361, 361, 31, 0, '50');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (362, 362, 31, 0, '51');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (363, 363, 31, 0, '52');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (364, 364, 31, 0, '53');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (365, 365, 31, 0, '54');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (366, 366, 31, 0, '55');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (367, 367, 31, 0, '56');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (368, 368, 31, 0, '57');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (369, 369, 31, 0, '58');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (370, 370, 31, 0, '59');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (371, 371, 31, 0, '60');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (372, 372, 32, 0, '49');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (373, 373, 32, 0, '50');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (374, 374, 32, 0, '51');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (375, 375, 32, 0, '52');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (376, 376, 32, 0, '53');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (377, 377, 32, 0, '54');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (378, 378, 32, 0, '55');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (379, 379, 32, 0, '56');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (380, 380, 32, 0, '57');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (381, 381, 32, 0, '58');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (382, 382, 32, 0, '59');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (383, 383, 32, 0, '60');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (384, 384, 33, 0, '49');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (385, 385, 33, 0, '50');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (386, 386, 33, 0, '51');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (387, 387, 33, 0, '52');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (388, 388, 33, 0, '53');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (389, 389, 33, 0, '54');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (390, 390, 33, 0, '55');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (391, 391, 33, 0, '56');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (392, 392, 33, 0, '57');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (393, 393, 33, 0, '58');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (394, 394, 33, 0, '59');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (395, 395, 33, 0, '60');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (396, 396, 34, NULL, '49');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (397, 397, 34, NULL, '50');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (398, 398, 34, NULL, '51');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (399, 399, 34, NULL, '52');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (400, 400, 34, NULL, '53');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (401, 401, 34, NULL, '54');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (402, 402, 34, NULL, '55');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (403, 403, 34, NULL, '56');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (404, 404, 34, NULL, '57');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (405, 405, 34, NULL, '58');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (406, 406, 34, NULL, '59');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (407, 407, 34, NULL, '60');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (408, 408, 35, 0, '49');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (409, 409, 35, 0, '50');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (410, 410, 35, 0, '51');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (411, 411, 35, 0, '52');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (412, 412, 35, 0, '53');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (413, 413, 35, 0, '54');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (414, 414, 35, 0, '55');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (415, 415, 35, 0, '56');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (416, 416, 35, 0, '57');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (417, 417, 35, 0, '58');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (418, 418, 35, 0, '59');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (419, 419, 35, 0, '60');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (420, 420, 36, 0, '49');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (421, 421, 36, 0, '50');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (422, 422, 36, 0, '51');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (423, 423, 36, 0, '52');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (424, 424, 36, 0, '53');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (425, 425, 36, 0, '54');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (426, 426, 36, 0, '55');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (427, 427, 36, 0, '56');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (428, 428, 36, 0, '57');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (429, 429, 36, 0, '58');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (430, 430, 36, 0, '59');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (431, 431, 36, 0, '60');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (432, 432, 37, 0, '61');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (433, 433, 37, 0, '62');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (434, 434, 37, 0, '63');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (435, 435, 37, 0, '64');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (436, 436, 37, 0, '65');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (437, 437, 37, 0, '66');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (438, 438, 37, 0, '67');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (439, 439, 37, 0, '68');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (440, 440, 37, 0, '69');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (441, 441, 37, 0, '70');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (442, 442, 37, 0, '71');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (443, 443, 37, 0, '72');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (444, 444, 38, 0, '61');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (445, 445, 38, 0, '62');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (446, 446, 38, 0, '63');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (447, 447, 38, 0, '64');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (448, 448, 38, 0, '65');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (449, 449, 38, 0, '66');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (450, 450, 38, 0, '67');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (451, 451, 38, 0, '68');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (452, 452, 38, 0, '69');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (453, 453, 38, 0, '70');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (454, 454, 38, 0, '71');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (455, 455, 38, 0, '72');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (456, 456, 39, 0, '61');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (457, 457, 39, 0, '62');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (458, 458, 39, 0, '63');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (459, 459, 39, 0, '64');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (460, 460, 39, 0, '65');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (461, 461, 39, 0, '66');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (462, 462, 39, 0, '67');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (463, 463, 39, 0, '68');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (464, 464, 39, 0, '69');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (465, 465, 39, 0, '70');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (466, 466, 39, 0, '71');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (467, 467, 39, 0, '72');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (468, 468, 40, 0, '61');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (469, 469, 40, 0, '62');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (470, 470, 40, 0, '63');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (471, 471, 40, 0, '64');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (472, 472, 40, 0, '65');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (473, 473, 40, 0, '66');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (474, 474, 40, 0, '67');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (475, 475, 40, 0, '68');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (476, 476, 40, 0, '69');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (477, 477, 40, 0, '70');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (478, 478, 40, 0, '71');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (479, 479, 40, 0, '72');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (480, 480, 41, NULL, '61');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (481, 481, 41, NULL, '62');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (482, 482, 41, NULL, '63');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (483, 483, 41, NULL, '64');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (484, 484, 41, NULL, '65');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (485, 485, 41, NULL, '66');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (486, 486, 41, NULL, '67');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (487, 487, 41, NULL, '68');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (488, 488, 41, NULL, '69');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (489, 489, 41, NULL, '70');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (490, 490, 41, NULL, '71');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (491, 491, 41, NULL, '72');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (492, 492, 42, 0, '61');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (493, 493, 42, 0, '62');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (494, 494, 42, 0, '63');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (495, 495, 42, 0, '64');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (496, 496, 42, 0, '65');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (497, 497, 42, 0, '66');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (498, 498, 42, 0, '67');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (499, 499, 42, 0, '68');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (500, 500, 42, 0, '69');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (501, 501, 42, 0, '70');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (502, 502, 42, 0, '71');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (503, 503, 42, 0, '72');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (504, 504, 43, 0, '61');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (505, 505, 43, 0, '62');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (506, 506, 43, 0, '63');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (507, 507, 43, 0, '64');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (508, 508, 43, 0, '65');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (509, 509, 43, 0, '66');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (510, 510, 43, 0, '67');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (511, 511, 43, 0, '68');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (512, 512, 43, 0, '69');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (513, 513, 43, 0, '70');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (514, 514, 43, 0, '71');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (515, 515, 43, 0, '72');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (516, 516, 44, 0, '73');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (517, 517, 44, 0, '74');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (518, 518, 44, 0, '75');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (519, 519, 44, 0, '76');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (520, 520, 44, 0, '77');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (521, 521, 44, 0, '78');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (522, 522, 44, 0, '79');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (523, 523, 44, 0, '80');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (524, 524, 44, 0, '81');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (525, 525, 44, 0, '82');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (526, 526, 44, 0, '83');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (527, 527, 44, 0, '84');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (528, 528, 45, 0, '73');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (529, 529, 45, 0, '74');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (530, 530, 45, 0, '75');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (531, 531, 45, 0, '76');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (532, 532, 45, 0, '77');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (533, 533, 45, 0, '78');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (534, 534, 45, 0, '79');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (535, 535, 45, 0, '80');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (536, 536, 45, 0, '81');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (537, 537, 45, 0, '82');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (538, 538, 45, 0, '83');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (539, 539, 45, 0, '84');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (540, 540, 46, 0, '73');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (541, 541, 46, 0, '74');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (542, 542, 46, 0, '75');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (543, 543, 46, 0, '76');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (544, 544, 46, 0, '77');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (545, 545, 46, 0, '78');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (546, 546, 46, 0, '79');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (547, 547, 46, 0, '80');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (548, 548, 46, 0, '81');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (549, 549, 46, 0, '82');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (550, 550, 46, 0, '83');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (551, 551, 46, 0, '84');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (552, 552, 47, 0, '73');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (553, 553, 47, 0, '74');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (554, 554, 47, 0, '75');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (555, 555, 47, 0, '76');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (556, 556, 47, 0, '77');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (557, 557, 47, 0, '78');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (558, 558, 47, 0, '79');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (559, 559, 47, 0, '80');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (560, 560, 47, 0, '81');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (561, 561, 47, 0, '82');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (562, 562, 47, 0, '83');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (563, 563, 47, 0, '84');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (564, 564, 48, 0, '74');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (566, 566, 48, 0, '76');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (568, 568, 48, 0, '78');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (570, 570, 48, 0, '80');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (572, 572, 48, 0, '82');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (574, 574, 48, 0, '84');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (575, 575, 49, NULL, '73');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (576, 576, 49, NULL, '74');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (577, 577, 49, NULL, '75');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (578, 578, 49, NULL, '76');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (579, 579, 49, NULL, '77');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (580, 580, 49, NULL, '78');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (581, 581, 49, NULL, '79');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (582, 582, 49, NULL, '80');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (583, 583, 49, NULL, '81');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (584, 584, 49, NULL, '82');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (585, 585, 49, NULL, '83');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (586, 586, 49, NULL, '84');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (587, 587, 50, 0, '73');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (588, 588, 50, 0, '74');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (589, 589, 50, 0, '75');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (590, 590, 50, 0, '76');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (591, 591, 50, 0, '77');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (592, 592, 50, 0, '78');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (593, 593, 51, 0, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (594, 594, 51, 0, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (595, 595, 51, 0, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (596, 596, 52, 0, '73');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (597, 597, 52, 0, '74');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (598, 598, 52, 0, '75');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (599, 599, 52, 0, '76');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (600, 600, 52, 0, '77');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (601, 601, 52, 0, '78');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (602, 602, 52, 0, '79');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (603, 603, 52, 0, '80');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (604, 604, 52, 0, '81');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (605, 605, 52, 0, '82');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (606, 606, 52, 0, '83');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (607, 607, 52, 0, '84');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (608, 608, 53, 0, '85');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (609, 609, 53, 0, '86');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (610, 610, 53, 0, '87');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (611, 611, 53, 0, '88');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (612, 612, 53, 0, '89');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (613, 613, 53, 0, '90');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (614, 614, 53, 0, '91');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (615, 615, 53, 0, '92');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (616, 616, 53, 0, '93');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (617, 617, 53, 0, '94');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (618, 618, 53, 0, '95');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (619, 619, 53, 0, '96');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (620, 620, 54, 0, '85');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (621, 621, 54, 0, '86');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (622, 622, 54, 0, '87');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (623, 623, 54, 0, '88');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (624, 624, 54, 0, '89');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (625, 625, 54, 0, '90');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (626, 626, 54, 0, '91');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (627, 627, 54, 0, '92');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (628, 628, 54, 0, '93');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (629, 629, 54, 0, '94');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (630, 630, 54, 0, '95');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (631, 631, 54, 0, '96');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (632, 632, 55, 0, '85');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (633, 633, 55, 0, '86');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (634, 634, 55, 0, '87');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (635, 635, 55, 0, '88');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (636, 636, 55, 0, '89');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (637, 637, 55, 0, '90');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (638, 638, 55, 0, '91');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (639, 639, 55, 0, '92');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (640, 640, 55, 0, '93');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (641, 641, 55, 0, '94');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (642, 642, 55, 0, '95');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (643, 643, 55, 0, '96');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (644, 644, 56, 0, '86');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (646, 646, 56, 0, '88');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (648, 648, 56, 0, '90');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (650, 650, 56, 0, '92');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (652, 652, 56, 0, '94');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (654, 654, 56, 0, '96');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (655, 655, 57, NULL, '85');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (656, 656, 57, NULL, '86');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (657, 657, 57, NULL, '87');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (658, 658, 57, NULL, '88');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (659, 659, 57, NULL, '89');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (660, 660, 57, NULL, '90');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (661, 661, 57, NULL, '91');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (662, 662, 57, NULL, '92');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (663, 663, 57, NULL, '93');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (664, 664, 57, NULL, '94');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (665, 665, 57, NULL, '95');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (666, 666, 57, NULL, '96');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (667, 667, 58, 0, '97');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (668, 668, 58, 0, '98');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (669, 669, 58, 0, '99');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (670, 670, 58, 0, '100');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (671, 671, 58, 0, '101');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (672, 672, 58, 0, '102');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (673, 673, 58, 0, '103');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (674, 674, 58, 0, '104');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (675, 675, 58, 0, '105');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (676, 676, 58, 0, '106');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (677, 677, 58, 0, '107');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (678, 678, 58, 0, '108');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (679, 679, 59, NULL, '97');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (680, 680, 59, NULL, '98');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (681, 681, 59, NULL, '99');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (682, 682, 59, NULL, '100');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (683, 683, 59, NULL, '101');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (684, 684, 59, NULL, '102');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (685, 685, 59, NULL, '103');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (686, 686, 59, NULL, '104');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (687, 687, 59, NULL, '105');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (688, 688, 59, NULL, '106');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (689, 689, 59, NULL, '107');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (690, 690, 59, NULL, '108');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (691, 691, 60, NULL, '97');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (692, 692, 60, NULL, '98');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (693, 693, 60, NULL, '99');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (694, 694, 60, NULL, '100');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (695, 695, 60, NULL, '101');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (696, 696, 60, NULL, '102');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (697, 697, 61, 0, '97');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (698, 698, 61, 0, '98');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (699, 699, 61, 0, '99');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (700, 700, 61, 0, '100');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (701, 701, 61, 0, '101');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (702, 702, 61, 0, '102');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (703, 703, 61, 0, '103');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (704, 704, 61, 0, '104');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (705, 705, 61, 0, '105');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (706, 706, 61, 0, '106');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (707, 707, 61, 0, '107');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (708, 708, 61, 0, '108');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (709, 709, 62, 0, '97');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (710, 710, 62, 0, '98');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (711, 711, 62, 0, '99');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (712, 712, 62, 0, '100');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (713, 713, 62, 0, '101');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (714, 714, 62, 0, '102');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (715, 715, 62, 0, '103');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (716, 716, 62, 0, '104');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (717, 717, 62, 0, '105');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (718, 718, 62, 0, '106');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (719, 719, 62, 0, '107');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (720, 720, 62, 0, '108');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (721, 721, 63, 0, '97');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (722, 722, 63, 0, '98');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (723, 723, 63, 0, '99');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (724, 724, 63, 0, '100');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (725, 725, 63, 0, '101');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (726, 726, 63, 0, '102');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (727, 727, 63, 0, '103');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (728, 728, 63, 0, '104');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (729, 729, 63, 0, '105');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (730, 730, 63, 0, '106');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (731, 731, 63, 0, '107');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (732, 732, 63, 0, '108');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (733, 733, 64, 0, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (734, 734, 64, 0, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (735, 735, 65, 0, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (736, 736, 65, 0, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (737, 737, 65, 0, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (738, 738, 65, 0, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (739, 739, 65, 0, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (740, 740, 65, 0, '6');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (741, 741, 65, 0, '7');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (742, 742, 65, 0, '8');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (743, 743, 65, 0, '9');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (744, 744, 65, 0, '10');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (745, 745, 65, 0, '11');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (746, 746, 65, 0, '12');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (747, 747, 66, 0, '97');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (748, 748, 66, 0, '98');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (749, 749, 66, 0, '99');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (750, 750, 66, 0, '100');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (751, 751, 66, 0, '101');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (752, 752, 66, 0, '102');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (753, 753, 66, 0, '103');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (754, 754, 66, 0, '104');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (755, 755, 66, 0, '105');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (756, 756, 66, 0, '106');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (757, 757, 66, 0, '107');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (758, 758, 66, 0, '108');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (759, 759, 67, 0, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (760, 760, 67, 0, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (761, 761, 67, 0, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (762, 762, 67, 0, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (763, 763, 67, 0, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (764, 764, 67, 0, '6');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (765, 765, 67, 0, '7');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (766, 766, 67, 0, '8');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (767, 767, 67, 0, '9');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (768, 768, 67, 0, '10');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (769, 769, 68, 0, '97');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (770, 770, 68, 0, '98');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (771, 771, 68, 0, '99');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (772, 772, 68, 0, '100');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (773, 773, 68, 0, '101');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (774, 774, 68, 0, '102');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (775, 775, 68, 0, '103');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (776, 776, 68, 0, '104');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (777, 777, 68, 0, '105');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (778, 778, 68, 0, '106');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (779, 779, 68, 0, '107');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (780, 780, 68, 0, '108');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (781, 781, 69, 0, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (782, 782, 69, 0, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (783, 783, 69, 0, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (784, 784, 69, 0, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (785, 785, 69, 0, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (786, 786, 69, 0, '6');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (787, 787, 70, 0, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (788, 788, 70, 0, '6');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (789, 789, 71, 0, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (790, 790, 71, 0, '6');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (791, 791, 72, 0, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (792, 792, 72, 0, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (793, 793, 72, 0, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (794, 794, 72, 0, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (795, 795, 72, 0, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (796, 796, 72, 0, '6');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (797, 797, 73, 0, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (798, 798, 73, 0, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (799, 799, 73, 0, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (800, 800, 73, 0, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (801, 801, 146, 0, '98');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (803, 803, 146, 0, '100');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (805, 805, 146, 0, '102');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (807, 807, 146, 0, '104');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (809, 809, 146, 0, '106');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (811, 811, 146, 0, '108');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (812, 812, 74, 0, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (813, 813, 74, 0, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (814, 814, 74, 0, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (815, 815, 74, 0, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (816, 816, 74, 0, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (817, 817, 75, NULL, '97');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (818, 818, 75, NULL, '98');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (819, 819, 75, NULL, '99');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (820, 820, 75, NULL, '100');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (821, 821, 75, NULL, '101');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (822, 822, 75, NULL, '102');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (823, 823, 75, NULL, '103');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (824, 824, 75, NULL, '104');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (825, 825, 75, NULL, '105');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (826, 826, 75, NULL, '106');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (827, 827, 75, NULL, '107');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (828, 828, 75, NULL, '108');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (829, 829, 76, 0, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (830, 830, 76, 0, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (831, 831, 76, 0, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (832, 832, 76, 0, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (833, 833, 76, 0, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (834, 834, 76, 0, '6');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (835, 835, 77, 0, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (836, 836, 77, 0, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (837, 837, 77, 0, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (838, 838, 77, 0, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (839, 839, 77, 0, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (840, 840, 77, 0, '6');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1298, 841, 78, 0, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1299, 842, 78, 0, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1300, 843, 78, 0, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1301, 844, 78, 0, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1302, 829, 78, 0, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1303, 830, 78, 0, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1304, 831, 78, 0, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1305, 832, 78, 0, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1306, 833, 78, 0, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1307, 834, 78, 0, '6');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (845, 845, 79, 0, '97');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (846, 846, 79, 0, '98');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (847, 847, 79, 0, '99');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (848, 848, 79, 0, '100');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (849, 849, 79, 0, '101');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (850, 850, 79, 0, '102');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (851, 851, 79, 0, '103');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (852, 852, 79, 0, '104');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (853, 853, 79, 0, '105');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (854, 854, 79, 0, '106');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (855, 855, 79, 0, '107');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (856, 856, 79, 0, '108');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (857, 857, 80, 0, '97');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (858, 858, 80, 0, '98');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (859, 859, 80, 0, '99');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (860, 860, 80, 0, '100');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (861, 861, 80, 0, '101');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (862, 862, 80, 0, '102');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (863, 863, 80, 0, '103');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (864, 864, 80, 0, '104');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (865, 865, 80, 0, '105');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (866, 866, 80, 0, '106');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (867, 867, 80, 0, '107');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (868, 868, 80, 0, '108');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (869, 869, 81, 0, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (877, 877, 82, 0, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (878, 878, 82, 0, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (879, 879, 82, 0, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (880, 880, 82, 0, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (881, 881, 82, 0, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (882, 882, 82, 0, '6');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (883, 883, 83, NULL, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (884, 884, 83, NULL, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (885, 885, 83, NULL, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (886, 886, 83, NULL, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (887, 887, 83, NULL, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (888, 888, 83, NULL, '6');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (870, 870, 81, 0, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (889, 889, 83, NULL, '7');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (890, 890, 83, NULL, '8');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (891, 891, 83, NULL, '9');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (892, 892, 83, NULL, '10');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (893, 893, 83, NULL, '11');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (894, 894, 83, NULL, '12');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (895, 895, 85, 0, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (896, 896, 85, 0, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (897, 897, 85, 0, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (898, 898, 85, 0, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (899, 899, 85, 0, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (900, 900, 85, 0, '6');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (901, 901, 85, 0, '7');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (902, 902, 85, 0, '8');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (903, 903, 86, 0, '109');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (904, 904, 86, 0, '110');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (905, 905, 86, 0, '111');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (906, 906, 86, 0, '112');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (907, 907, 86, 0, '113');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (908, 908, 86, 0, '114');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (909, 909, 86, 0, '115');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (910, 910, 86, 0, '116');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (911, 911, 86, 0, '117');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (912, 912, 86, 0, '118');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (913, 913, 86, 0, '119');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (914, 914, 86, 0, '120');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (915, 915, 87, 0, '109');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (916, 916, 87, 0, '110');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (917, 917, 87, 0, '111');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (918, 918, 87, 0, '112');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (919, 919, 87, 0, '113');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (920, 920, 87, 0, '114');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (921, 921, 87, 0, '115');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (922, 922, 87, 0, '116');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (923, 923, 87, 0, '117');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (924, 924, 87, 0, '118');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (925, 925, 87, 0, '119');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (926, 926, 87, 0, '120');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (927, 927, 88, 0, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (928, 928, 88, 0, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (929, 929, 88, 0, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (930, 930, 90, NULL, '109');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (931, 931, 90, NULL, '110');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (932, 932, 90, NULL, '111');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (933, 933, 90, NULL, '112');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (934, 934, 90, NULL, '113');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (935, 935, 90, NULL, '114');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (936, 936, 90, NULL, '115');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (937, 937, 90, NULL, '116');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (938, 938, 90, NULL, '117');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (939, 939, 90, NULL, '118');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (940, 940, 90, NULL, '119');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (941, 941, 90, NULL, '120');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (942, 942, 91, NULL, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (943, 943, 91, NULL, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (944, 944, 91, NULL, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (945, 945, 91, NULL, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (946, 946, 91, NULL, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (947, 947, 91, NULL, '6');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (948, 948, 91, NULL, '7');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (949, 949, 91, NULL, '8');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (950, 950, 91, NULL, '9');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (951, 951, 91, NULL, '10');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (952, 952, 92, 0, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (953, 953, 92, 0, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (954, 954, 93, 0, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (955, 955, 93, 0, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (956, 956, 93, 0, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (957, 957, 93, 0, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (958, 958, 93, 0, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (965, 965, 95, NULL, '109');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (966, 966, 95, NULL, '110');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (967, 967, 95, NULL, '111');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (968, 968, 95, NULL, '112');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (969, 969, 95, NULL, '113');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (970, 970, 95, NULL, '114');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (971, 971, 95, NULL, '115');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (972, 972, 95, NULL, '116');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (973, 973, 95, NULL, '117');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (974, 974, 95, NULL, '118');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (975, 975, 95, NULL, '119');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (976, 976, 95, NULL, '120');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (977, 977, 96, 0, '109');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (978, 978, 96, 0, '110');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (979, 979, 96, 0, '111');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (980, 980, 96, 0, '112');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (981, 981, 96, 0, '113');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (982, 982, 96, 0, '114');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (983, 983, 98, 0, '121');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (984, 984, 98, 0, '122');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (985, 985, 98, 0, '123');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (986, 986, 98, 0, '124');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (987, 987, 98, 0, '125');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (988, 988, 98, 0, '126');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (989, 989, 98, 0, '127');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (990, 990, 98, 0, '128');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (991, 991, 98, 0, '129');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (992, 992, 98, 0, '130');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (993, 993, 98, 0, '131');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (994, 994, 98, 0, '132');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (995, 995, 99, 0, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (996, 996, 99, 0, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (997, 997, 99, 0, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (998, 998, 99, 0, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (999, 999, 99, 0, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1000, 1000, 101, 0, '121');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1001, 1001, 101, 0, '122');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1002, 1002, 101, 0, '123');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1003, 1003, 101, 0, '124');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1004, 1004, 101, 0, '125');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1005, 1005, 101, 0, '126');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1006, 1006, 101, 0, '127');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1007, 1007, 101, 0, '128');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1008, 1008, 101, 0, '129');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1009, 1009, 101, 0, '130');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1010, 1010, 101, 0, '131');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1011, 1011, 101, 0, '132');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1012, 1012, 102, 0, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1013, 1013, 102, 0, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1014, 1014, 102, 0, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1015, 1015, 103, 0, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1016, 1016, 103, 0, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1017, 1017, 103, 0, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1018, 1018, 103, 0, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1019, 1019, 103, 0, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1020, 1020, 103, 0, '6');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1021, 1021, 104, 0, '121');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1022, 1022, 104, 0, '122');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1023, 1023, 104, 0, '123');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1024, 1024, 104, 0, '124');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1025, 1025, 104, 0, '125');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1026, 1026, 104, 0, '126');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1027, 1027, 104, 0, '127');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1028, 1028, 104, 0, '128');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1029, 1029, 104, 0, '129');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1030, 1030, 104, 0, '130');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1031, 1031, 104, 0, '131');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1032, 1032, 104, 0, '132');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1033, 1033, 105, NULL, '121');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1034, 1034, 105, NULL, '122');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1035, 1035, 105, NULL, '123');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1036, 1036, 105, NULL, '124');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1037, 1037, 105, NULL, '125');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1038, 1038, 105, NULL, '126');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1039, 1039, 105, NULL, '127');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1040, 1040, 105, NULL, '128');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1041, 1041, 105, NULL, '129');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1042, 1042, 105, NULL, '130');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1043, 1043, 105, NULL, '131');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1044, 1044, 105, NULL, '132');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1045, 1045, 106, NULL, '121');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1046, 1046, 106, NULL, '122');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1047, 1047, 106, NULL, '123');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1048, 1048, 106, NULL, '124');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1049, 1049, 106, NULL, '125');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1050, 1050, 106, NULL, '126');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1051, 1051, 106, NULL, '127');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1052, 1052, 106, NULL, '128');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1053, 1053, 106, NULL, '129');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1054, 1054, 106, NULL, '130');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1055, 1055, 106, NULL, '131');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1056, 1056, 106, NULL, '132');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1057, 1057, 107, 0, '121');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1058, 1058, 107, 0, '122');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1059, 1059, 107, 0, '123');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1060, 1060, 107, 0, '124');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1061, 1061, 107, 0, '125');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1062, 1062, 107, 0, '126');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1063, 1063, 107, 0, '127');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1064, 1064, 107, 0, '128');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1065, 1065, 107, 0, '129');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1066, 1066, 107, 0, '130');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1067, 1067, 107, 0, '131');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1068, 1068, 107, 0, '132');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1069, 1069, 108, NULL, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1070, 1070, 108, NULL, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1071, 1071, 108, NULL, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1072, 1072, 108, NULL, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1073, 1073, 108, NULL, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1074, 1074, 108, NULL, '6');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1075, 1075, 108, NULL, '7');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1076, 1076, 108, NULL, '8');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1077, 1077, 108, NULL, '9');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1078, 1078, 108, NULL, '10');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1079, 1079, 109, NULL, '11');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1080, 1080, 109, NULL, '12');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1081, 1081, 109, NULL, '13');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1082, 1082, 109, NULL, '14');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1083, 1083, 109, NULL, '15');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1084, 1084, 109, NULL, '16');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1085, 1085, 109, NULL, '17');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1086, 1086, 109, NULL, '18');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1087, 1087, 109, NULL, '19');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1088, 1088, 109, NULL, '20');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1089, 1089, 110, 0, '139');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1090, 1090, 110, 0, '140');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1091, 1091, 110, 0, '141');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1092, 1092, 110, 0, '142');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1093, 1093, 110, 0, '143');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1094, 1094, 110, 0, '144');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1095, 1095, 111, 0, '133');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1096, 1096, 111, 0, '134');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1097, 1097, 111, 0, '135');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1098, 1098, 111, 0, '136');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1099, 1099, 111, 0, '137');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1100, 1100, 111, 0, '138');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1101, 1101, 112, 0, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1102, 1102, 112, 0, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1103, 1103, 112, 0, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1104, 1104, 112, 0, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1105, 1105, 112, 0, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1106, 1106, 112, 0, '6');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1107, 1107, 112, 0, '7');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1108, 1108, 112, 0, '8');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1109, 1109, 112, 0, '9');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1110, 1110, 112, 0, '10');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1111, 1111, 113, 0, '133');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1112, 1112, 113, 0, '134');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1113, 1113, 113, 0, '135');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1114, 1114, 113, 0, '136');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1115, 1115, 113, 0, '137');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1116, 1116, 113, 0, '138');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1117, 1117, 113, 0, '139');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1118, 1118, 113, 0, '140');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1119, 1119, 113, 0, '141');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1120, 1120, 113, 0, '142');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1121, 1121, 113, 0, '143');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1122, 1122, 113, 0, '144');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1123, 1123, 114, 0, '11');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1124, 1124, 114, 0, '12');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1125, 1125, 114, 0, '13');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1126, 1126, 114, 0, '14');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1127, 1127, 114, 0, '15');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1128, 1128, 114, 0, '16');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1129, 1129, 114, 0, '17');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1130, 1130, 114, 0, '18');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1131, 1131, 114, 0, '19');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1132, 1132, 114, 0, '20');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1133, 1133, 115, 0, '7');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1134, 1134, 115, 0, '8');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1135, 1135, 116, NULL, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1136, 1136, 116, NULL, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1137, 1137, 116, NULL, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1138, 1138, 116, NULL, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1139, 1139, 116, NULL, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1140, 1140, 116, NULL, '6');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1141, 1141, 116, NULL, '7');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1142, 1142, 116, NULL, '8');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1143, 1143, 116, NULL, '9');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1144, 1144, 116, NULL, '10');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1145, 1145, 117, NULL, '133');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1146, 1146, 117, NULL, '134');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1147, 1147, 117, NULL, '135');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1148, 1148, 117, NULL, '136');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1149, 1149, 117, NULL, '137');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1150, 1150, 117, NULL, '138');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1151, 1151, 117, NULL, '139');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1152, 1152, 117, NULL, '140');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1153, 1153, 117, NULL, '141');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1154, 1154, 117, NULL, '142');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1155, 1155, 117, NULL, '143');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1156, 1156, 117, NULL, '144');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1157, 1157, 118, 0, '85');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1158, 1158, 118, 0, '86');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1159, 1159, 118, 0, '87');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1160, 1160, 118, 0, '88');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1161, 1161, 118, 0, '89');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1162, 1162, 118, 0, '90');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1163, 1163, 118, 0, '91');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1164, 1164, 118, 0, '92');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1165, 1165, 118, 0, '93');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1166, 1166, 118, 0, '94');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1167, 1167, 118, 0, '95');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1168, 1168, 118, 0, '96');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1169, 1169, 119, NULL, '133');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1170, 1170, 119, NULL, '134');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1171, 1171, 119, NULL, '135');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1172, 1172, 119, NULL, '136');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1173, 1173, 119, NULL, '137');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1174, 1174, 119, NULL, '138');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1175, 1175, 119, NULL, '139');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1176, 1176, 119, NULL, '140');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1177, 1177, 119, NULL, '141');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1178, 1178, 119, NULL, '142');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1179, 1179, 119, NULL, '143');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1180, 1180, 119, NULL, '144');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1181, 1181, 120, 0, '133');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1182, 1182, 120, 0, '134');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1183, 1183, 120, 0, '135');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1184, 1184, 120, 0, '136');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1185, 1185, 120, 0, '137');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1186, 1186, 120, 0, '138');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1187, 1187, 121, NULL, '11');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1188, 1188, 121, NULL, '12');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1189, 1189, 121, NULL, '13');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1190, 1190, 121, NULL, '14');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1191, 1191, 121, NULL, '15');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1192, 1192, 121, NULL, '16');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1193, 1193, 121, NULL, '17');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1194, 1194, 121, NULL, '18');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1195, 1195, 121, NULL, '19');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1196, 1196, 121, NULL, '20');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1197, 1197, 122, 0, '133');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1198, 1198, 122, 0, '134');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1199, 1199, 122, 0, '135');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1200, 1200, 122, 0, '136');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1201, 1201, 123, 0, '6');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1202, 1202, 123, 0, '7');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1203, 1203, 123, 0, '8');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1204, 1204, 123, 0, '9');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1205, 1205, 123, 0, '10');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1206, 1206, 124, NULL, '133');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1207, 1207, 124, NULL, '134');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1208, 1208, 124, NULL, '135');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1209, 1209, 124, NULL, '136');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1210, 1210, 124, NULL, '137');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1211, 1211, 124, NULL, '138');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1212, 1212, 125, 0, '139');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1213, 1213, 125, 0, '140');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1214, 1214, 125, 0, '141');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1215, 1215, 125, 0, '142');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1216, 1216, 125, 0, '143');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1217, 1217, 125, 0, '144');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1218, 1051, 126, NULL, '127');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1219, 1052, 126, NULL, '128');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1220, 1053, 126, NULL, '129');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1221, 1054, 126, NULL, '130');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1222, 1055, 126, NULL, '131');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1223, 1056, 126, NULL, '132');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1224, 1224, 127, 0, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1225, 1225, 127, 0, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1226, 1226, 127, 0, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1227, 1227, 127, 0, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1228, 1228, 127, 0, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1229, 1229, 127, 0, '6');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1230, 1230, 127, 0, '7');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1231, 1231, 127, 0, '8');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1232, 1232, 127, 0, '9');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1233, 1233, 127, 0, '10');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1240, 1212, 131, 0, '139');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1241, 1213, 131, 0, '140');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1242, 1214, 131, 0, '141');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1243, 1215, 131, 0, '142');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1244, 1216, 131, 0, '143');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1245, 1217, 131, 0, '144');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1246, 1234, 130, 0, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1247, 1235, 130, 0, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1248, 1236, 130, 0, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1249, 1237, 130, 0, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1250, 1238, 130, 0, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1251, 1239, 130, 0, '6');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1252, 1240, 130, 0, '7');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1253, 1241, 130, 0, '8');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1254, 1242, 130, 0, '9');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1255, 1243, 130, 0, '10');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1256, 1244, 130, 0, '11');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1257, 1245, 130, 0, '12');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1258, 1246, 130, 0, '13');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1259, 1247, 130, 0, '14');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1260, 1248, 130, 0, '15');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1261, 1249, 130, 0, '16');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1262, 1268, 147, 0, '49');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1263, 1269, 147, 0, '50');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1264, 1270, 147, 0, '51');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1265, 1271, 147, 0, '52');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1266, 1272, 147, 0, '53');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1267, 1273, 147, 0, '54');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1268, 1274, 147, 0, '55');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1269, 1275, 147, 0, '56');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1270, 1276, 147, 0, '57');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1271, 1277, 147, 0, '58');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1272, 1278, 147, 0, '59');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1273, 1279, 147, 0, '60');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1274, 1280, 148, 0, '109');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1275, 1281, 148, 0, '110');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1276, 1282, 148, 0, '111');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1277, 1283, 148, 0, '112');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1278, 1284, 148, 0, '113');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1279, 1285, 148, 0, '114');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1280, 1286, 148, 0, '115');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1281, 1287, 148, 0, '116');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1282, 1288, 148, 0, '117');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1283, 1289, 148, 0, '118');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1284, 1290, 148, 0, '119');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1285, 1291, 148, 0, '120');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1286, 1292, 149, 0, '13');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1287, 1293, 149, 0, '14');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1288, 1294, 149, 0, '15');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1289, 1295, 149, 0, '16');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1290, 1296, 149, 0, '17');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1291, 1297, 149, 0, '18');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1292, 1298, 149, 0, '19');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1293, 1299, 149, 0, '20');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1294, 1300, 149, 0, '21');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1295, 1301, 149, 0, '22');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1296, 1302, 149, 0, '23');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1297, 1303, 149, 0, '24');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1308, 1310, 159, NULL, '85');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1310, 1312, 159, NULL, '87');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1312, 1314, 160, NULL, '97');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1313, 1315, 160, NULL, '98');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1314, 1316, 160, NULL, '99');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1315, 1317, 160, NULL, '100');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1316, 871, 151, NULL, '97');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1317, 872, 151, NULL, '102');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1318, 873, 152, NULL, '98');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1319, 874, 152, NULL, '99');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1320, 875, 152, NULL, '100');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1321, 876, 152, NULL, '101');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1322, 697, 154, NULL, '97');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1323, 698, 154, NULL, '98');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1324, 699, 154, NULL, '99');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1325, 700, 154, NULL, '100');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1326, 701, 154, NULL, '101');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1327, 702, 154, NULL, '102');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1328, 903, 154, NULL, '109');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1329, 904, 154, NULL, '110');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1330, 905, 154, NULL, '111');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1331, 906, 154, NULL, '112');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1332, 907, 154, NULL, '113');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1333, 908, 154, NULL, '114');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1334, 703, 155, NULL, '104');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1335, 704, 155, NULL, '105');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1336, 705, 155, NULL, '106');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1337, 706, 155, NULL, '107');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1338, 707, 155, NULL, '108');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1339, 708, 155, NULL, '109');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1340, 909, 155, NULL, '115');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1341, 910, 155, NULL, '116');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1342, 911, 155, NULL, '117');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1343, 912, 155, NULL, '118');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1344, 913, 155, NULL, '119');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1345, 914, 155, NULL, '120');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1371, 1349, 146, NULL, '108');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1372, 1350, 146, NULL, '108');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1373, 1351, 146, NULL, '108');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1374, 1173, 164, NULL, '137');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1375, 1174, 164, NULL, '138');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1376, 1175, 165, NULL, '139');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1377, 1176, 165, NULL, '140');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1378, 1177, 165, NULL, '141');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1379, 1178, 165, NULL, '142');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1380, 1179, 165, NULL, '143');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1381, 1180, 165, NULL, '144');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1382, 679, 59, NULL, '97');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1383, 680, 59, NULL, '98');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1384, 681, 59, NULL, '99');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1385, 682, 59, NULL, '100');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1386, 683, 59, NULL, '101');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1387, 684, 59, NULL, '102');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1388, 685, 59, NULL, '103');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1389, 686, 59, NULL, '104');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1390, 687, 59, NULL, '105');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1391, 688, 59, NULL, '106');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1392, 689, 59, NULL, '107');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1393, 690, 59, NULL, '108');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1394, 1358, 166, NULL, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1395, 1359, 166, NULL, '2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1396, 1360, 166, NULL, '3');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1397, 1361, 166, NULL, '4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1398, 1362, 166, NULL, '5');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1399, 1363, 166, NULL, '6');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1400, 1364, 166, NULL, '7');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1401, 1365, 166, NULL, '8');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1402, 1366, 166, NULL, '9');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1403, 1367, 166, NULL, '10');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1404, 1368, 166, NULL, '11');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1405, 1369, 166, NULL, '12');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1349, 1321, 97, NULL, '3–4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1347, 1319, 97, NULL, '1–2');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1353, 1325, 97, NULL, '7–8');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1355, 1327, 97, NULL, '9–10');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1351, 1323, 97, NULL, '5–6');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1358, 1330, 97, NULL, '11–13');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1362, 1334, 97, NULL, '16–17');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1366, 1338, 97, NULL, '20–21');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1364, 1336, 97, NULL, '18–19');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1368, 1340, 97, NULL, '22–23');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1360, 1332, 97, NULL, '14–15');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1370, 1342, 97, NULL, '24–25');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1406, 1370, 1000, NULL, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1309, 1311, 159, NULL, '86');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1311, 1313, 159, NULL, '88');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1407, 1371, 132, NULL, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1408, 1374, 100, NULL, '1');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1409, 1375, 159, NULL, '97');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1411, 1377, 159, NULL, '99');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1413, 1379, 160, NULL, '85');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1414, 1380, 160, NULL, '86');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1415, 1381, 160, NULL, '87');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1416, 1382, 160, NULL, '88');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1410, 1376, 159, NULL, '98');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1412, 1378, 159, NULL, '100');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1417, 1383, 128, NULL, '1–4');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1418, 1384, 128, NULL, '5–8');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1419, 1385, 128, NULL, '9–12');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1420, 1386, 128, NULL, '13–16');
INSERT INTO public.pace_courses (id, pace_id, course_id, alias, number) VALUES (1421, 1387, 128, NULL, '17-20');


--
-- Data for Name: pace_versions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.pace_versions (id, year_revised, type, edition, pace_id) OVERRIDING SYSTEM VALUE VALUES (1, 2018, 'PACE', 1, 1);
INSERT INTO public.pace_versions (id, year_revised, type, edition, pace_id) OVERRIDING SYSTEM VALUE VALUES (2, 2019, 'Score Key', 2, 2);
INSERT INTO public.pace_versions (id, year_revised, type, edition, pace_id) OVERRIDING SYSTEM VALUE VALUES (3, 2020, 'Material', 3, 3);
INSERT INTO public.pace_versions (id, year_revised, type, edition, pace_id) OVERRIDING SYSTEM VALUE VALUES (4, 2021, 'PACE', 1, 4);
INSERT INTO public.pace_versions (id, year_revised, type, edition, pace_id) OVERRIDING SYSTEM VALUE VALUES (5, 2022, 'Score Key', 2, 5);
INSERT INTO public.pace_versions (id, year_revised, type, edition, pace_id) OVERRIDING SYSTEM VALUE VALUES (6, 2023, 'Material', 3, 6);
INSERT INTO public.pace_versions (id, year_revised, type, edition, pace_id) OVERRIDING SYSTEM VALUE VALUES (7, 2018, 'PACE', 1, 7);
INSERT INTO public.pace_versions (id, year_revised, type, edition, pace_id) OVERRIDING SYSTEM VALUE VALUES (8, 2019, 'Score Key', 2, 8);
INSERT INTO public.pace_versions (id, year_revised, type, edition, pace_id) OVERRIDING SYSTEM VALUE VALUES (9, 2020, 'Material', 3, 9);
INSERT INTO public.pace_versions (id, year_revised, type, edition, pace_id) OVERRIDING SYSTEM VALUE VALUES (10, 2021, 'PACE', 1, 10);
INSERT INTO public.pace_versions (id, year_revised, type, edition, pace_id) OVERRIDING SYSTEM VALUE VALUES (11, 2022, 'Score Key', 2, 11);
INSERT INTO public.pace_versions (id, year_revised, type, edition, pace_id) OVERRIDING SYSTEM VALUE VALUES (12, 2023, 'Material', 3, 12);


--
-- Data for Name: paces; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1370, 1, NULL, NULL, NULL, NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1375, 97, NULL, NULL, NULL, NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1377, 99, NULL, NULL, NULL, NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1311, 86, 3, 1, 'PT', NULL, 2);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1376, 98, NULL, NULL, NULL, NULL, 2);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1378, 100, NULL, NULL, NULL, NULL, 2);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1383, 1, NULL, NULL, NULL, NULL, 2);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1384, 2, NULL, NULL, NULL, NULL, 3);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1385, 3, NULL, NULL, NULL, NULL, 2);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1386, 4, NULL, NULL, NULL, NULL, 3);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1387, 5, NULL, NULL, NULL, NULL, 2);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (870, 2, 3, 1, 'PT', NULL, 2);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1371, 1, NULL, NULL, NULL, NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1379, 85, NULL, NULL, NULL, NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1380, 86, NULL, NULL, NULL, NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1381, 87, NULL, NULL, NULL, NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1382, 88, NULL, NULL, NULL, NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1372, 1, NULL, NULL, NULL, NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1373, 1, NULL, NULL, NULL, NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1374, 1, NULL, NULL, NULL, NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1, 2, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (2, 3, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (3, 4, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (4, 5, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (5, 6, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (6, 7, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (7, 8, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (8, 9, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (9, 10, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (10, 11, 3, 3, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (11, 12, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (12, 1, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (13, 2, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (14, 3, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (15, 4, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (16, 5, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (17, 6, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (18, 7, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (19, 8, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (20, 9, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (21, 10, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (22, 11, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (23, 12, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (24, 1, 3, 3, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (25, 2, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (26, 3, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (27, 4, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (28, 5, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (29, 6, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (30, 7, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (31, 8, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (32, 9, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (33, 10, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (34, 11, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (35, 12, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (36, 1, 3, 3, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (37, 2, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (38, 3, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (39, 4, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (40, 5, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (41, 6, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (42, 7, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (43, 8, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (44, 9, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (45, 10, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (46, 11, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (47, 12, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (48, 1, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (49, 2, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (50, 3, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (51, 4, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (52, 5, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (53, 6, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (54, 7, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (55, 8, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (56, 9, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (57, 10, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (58, 11, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (59, 12, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (60, 1, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (61, 2, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (62, 3, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (63, 4, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (64, 5, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (65, 6, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (66, 7, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (67, 8, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (68, 9, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (69, 10, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (70, 11, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (71, 12, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (72, 1, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (73, 2, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (74, 3, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (75, 4, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (76, 5, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (77, 6, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (78, 7, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (79, 8, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (80, 9, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (81, 10, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (82, 11, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (83, 12, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (84, 1, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (85, 2, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (86, 3, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (87, 4, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (88, 5, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (89, 6, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (90, 7, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (91, 8, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (92, 9, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (93, 10, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (94, 11, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (95, 12, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (96, 13, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (97, 14, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (98, 15, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (99, 16, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (100, 17, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (101, 18, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (102, 19, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (103, 20, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (104, 21, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (105, 22, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (106, 23, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (107, 24, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (108, 13, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (109, 14, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (110, 15, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (111, 16, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (112, 17, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (113, 18, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (114, 19, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (115, 20, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (116, 21, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (117, 22, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (118, 23, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (119, 24, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (120, 13, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (121, 14, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (122, 15, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (123, 16, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (124, 17, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (125, 18, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (126, 19, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (127, 20, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (128, 21, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (129, 22, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (130, 23, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (131, 24, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (132, 13, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (133, 14, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (134, 15, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (135, 16, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (136, 17, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (137, 18, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (138, 19, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (139, 20, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (140, 21, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (141, 22, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (142, 23, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (143, 24, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (144, 13, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (145, 14, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (146, 15, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (147, 16, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (148, 17, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (149, 18, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (150, 19, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (151, 20, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (152, 21, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (153, 22, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (154, 23, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (155, 24, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (156, 13, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (157, 14, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (158, 15, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (159, 16, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (160, 17, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (161, 18, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (162, 19, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (163, 20, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (164, 21, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (165, 22, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (166, 23, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (167, 24, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (168, 13, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (169, 14, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (170, 15, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (171, 16, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (172, 17, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (173, 18, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (174, 19, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (175, 20, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (176, 21, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (177, 22, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (178, 23, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (179, 24, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (180, 25, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (181, 26, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (182, 27, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (183, 28, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (184, 29, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (185, 30, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (186, 31, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (187, 32, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (188, 33, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (189, 34, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (190, 35, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (191, 36, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (192, 25, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (193, 26, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (194, 27, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (195, 28, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (196, 29, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (197, 30, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (198, 31, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (199, 32, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (200, 33, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (201, 34, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (202, 35, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (203, 36, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (204, 25, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (205, 26, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (206, 27, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (207, 28, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (208, 29, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (209, 30, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (210, 31, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (211, 32, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (212, 33, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (213, 34, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (214, 35, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (215, 36, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (216, 25, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (217, 26, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (218, 27, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (219, 28, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (220, 29, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (221, 30, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (222, 31, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (223, 32, 3, 2, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (224, 33, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (225, 34, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (226, 35, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (227, 36, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (228, 25, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (229, 26, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (230, 27, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (231, 28, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (232, 29, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (233, 30, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (234, 31, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (235, 32, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (236, 33, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (237, 34, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (238, 35, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (239, 36, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (240, 25, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (241, 26, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (242, 27, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (243, 28, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (244, 29, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (245, 30, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (246, 31, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (247, 32, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (248, 33, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (249, 34, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (250, 35, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (251, 36, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (252, 25, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (253, 26, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (254, 27, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (255, 28, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (256, 29, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (257, 30, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (258, 31, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (259, 32, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (260, 33, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (261, 34, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (262, 35, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (263, 36, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (264, 37, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (265, 38, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (266, 39, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (267, 40, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (268, 41, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (269, 42, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (270, 43, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (271, 44, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (272, 45, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (273, 46, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (274, 47, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (275, 48, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (276, 37, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (277, 38, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (278, 39, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (279, 40, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (280, 41, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (281, 42, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (282, 43, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (283, 44, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (284, 45, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (285, 46, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (286, 47, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (287, 48, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (288, 37, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (289, 38, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (290, 39, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (291, 40, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (292, 41, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (293, 42, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (294, 43, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (295, 44, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (296, 45, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (297, 46, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (298, 47, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (299, 48, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (300, 37, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (301, 38, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (302, 39, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (303, 40, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (304, 41, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (305, 42, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (306, 43, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (307, 44, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (308, 45, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (309, 46, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (310, 47, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (311, 48, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (312, 37, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (313, 38, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (314, 39, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (315, 40, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (316, 41, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (317, 42, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (318, 43, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (319, 44, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (320, 45, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (321, 46, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (322, 47, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (323, 48, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (324, 37, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (325, 38, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (326, 39, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (327, 40, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (328, 41, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (329, 42, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (330, 43, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (331, 44, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (332, 45, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (333, 46, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (334, 47, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (335, 48, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (336, 37, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (337, 38, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (338, 39, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (339, 40, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (340, 41, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (341, 42, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (342, 43, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (343, 44, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (344, 45, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (345, 46, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (346, 47, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (347, 48, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (348, 49, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (349, 50, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (350, 51, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (351, 52, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (352, 53, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (353, 54, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (354, 55, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (355, 56, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (356, 57, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (357, 58, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (358, 59, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (359, 60, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (360, 49, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (361, 50, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (362, 51, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (363, 52, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (364, 53, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (365, 54, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (366, 55, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (367, 56, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (368, 57, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (369, 58, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (370, 59, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (371, 60, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (372, 49, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (373, 50, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (374, 51, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (375, 52, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (376, 53, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (377, 54, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (378, 55, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (379, 56, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (380, 57, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (381, 58, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (382, 59, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (383, 60, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (384, 49, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (385, 50, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (386, 51, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (387, 52, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (388, 53, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (389, 54, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (390, 55, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (391, 56, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (392, 57, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (393, 58, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (394, 59, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (395, 60, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (396, 49, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (397, 50, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (398, 51, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (399, 52, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (400, 53, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (401, 54, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (402, 55, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (403, 56, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (404, 57, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (405, 58, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (406, 59, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (407, 60, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (408, 49, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (409, 50, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (410, 51, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (411, 52, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (412, 53, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (413, 54, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (414, 55, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (415, 56, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (416, 57, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (417, 58, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (418, 59, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (419, 60, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (420, 49, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (421, 50, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (422, 51, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (423, 52, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (424, 53, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (425, 54, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (426, 55, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (427, 56, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (428, 57, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (429, 58, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (430, 59, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (431, 60, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (432, 61, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (433, 62, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (434, 63, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (435, 64, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (436, 65, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (437, 66, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (438, 67, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (439, 68, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (440, 69, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (441, 70, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (442, 71, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (443, 72, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (444, 61, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (445, 62, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (446, 63, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (447, 64, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (448, 65, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (449, 66, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (450, 67, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (451, 68, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (452, 69, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (453, 70, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (454, 71, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (455, 72, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (456, 61, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (457, 62, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (458, 63, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (459, 64, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (460, 65, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (461, 66, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (462, 67, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (463, 68, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (464, 69, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (465, 70, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (466, 71, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (467, 72, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (468, 61, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (469, 62, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (470, 63, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (471, 64, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (472, 65, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (473, 66, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (474, 67, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (475, 68, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (476, 69, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (477, 70, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (478, 71, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (479, 72, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (480, 61, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (481, 62, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (482, 63, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (483, 64, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (484, 65, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (485, 66, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (486, 67, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (487, 68, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (488, 69, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (489, 70, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (490, 71, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (491, 72, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (492, 61, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (493, 62, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (494, 63, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (495, 64, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (496, 65, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (497, 66, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (498, 67, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (499, 68, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (500, 69, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (501, 70, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (502, 71, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (503, 72, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (504, 61, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (505, 62, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (506, 63, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (507, 64, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (508, 65, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (509, 66, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (510, 67, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (511, 68, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (512, 69, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (513, 70, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (514, 71, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (515, 72, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (516, 73, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (517, 74, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (518, 75, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (519, 76, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (520, 77, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (521, 78, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (522, 79, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (523, 80, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (524, 81, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (525, 82, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (526, 83, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (527, 84, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (528, 73, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (529, 74, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (530, 75, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (531, 76, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (532, 77, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (533, 78, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (534, 79, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (535, 80, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (536, 81, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (537, 82, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (538, 83, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (539, 84, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (540, 73, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (541, 74, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (542, 75, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (543, 76, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (544, 77, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (545, 78, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (546, 79, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (547, 80, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (548, 81, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (549, 82, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (550, 83, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (551, 84, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (552, 73, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (553, 74, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (554, 75, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (555, 76, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (556, 77, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (557, 78, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (558, 79, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (559, 80, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (560, 81, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (561, 82, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (562, 83, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (563, 84, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (564, 74, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (565, 75, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (566, 76, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (567, 77, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (568, 78, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (569, 79, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (570, 80, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (571, 81, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (572, 82, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (573, 83, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (574, 84, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (575, 73, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (576, 74, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (577, 75, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (578, 76, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (579, 77, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (580, 78, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (581, 79, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (582, 80, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (583, 81, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (584, 82, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (585, 83, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (586, 84, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (587, 73, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (588, 74, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (589, 75, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (590, 76, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (591, 77, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (592, 78, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (593, 1, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (594, 2, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (595, 3, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (596, 73, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (597, 74, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (598, 75, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (599, 76, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (600, 77, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (601, 78, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (602, 79, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (603, 80, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (604, 81, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (605, 82, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (606, 83, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (607, 84, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (608, 85, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (609, 86, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (610, 87, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (611, 88, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (612, 89, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (613, 90, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (614, 91, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (615, 92, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (616, 93, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (617, 94, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (618, 95, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (619, 96, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (620, 85, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (621, 86, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (622, 87, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (623, 88, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (624, 89, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (625, 90, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (626, 91, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (627, 92, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (628, 93, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (629, 94, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (630, 95, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (631, 96, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (632, 85, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (633, 86, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (634, 87, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (635, 88, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (636, 89, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (637, 90, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (638, 91, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (639, 92, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (640, 93, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (641, 94, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (642, 95, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (643, 96, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (644, 86, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (645, 87, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (646, 88, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (647, 89, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (648, 90, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (649, 91, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (650, 92, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (651, 93, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (652, 94, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (653, 95, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (654, 96, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (655, 85, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (656, 86, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (657, 87, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (658, 88, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (659, 89, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (660, 90, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (661, 91, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (662, 92, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (663, 93, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (664, 94, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (665, 95, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (666, 96, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (667, 85, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (668, 86, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (669, 87, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (670, 88, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (671, 89, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (672, 90, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (673, 91, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (674, 92, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (675, 93, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (676, 94, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (677, 95, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (678, 96, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (679, 85, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (680, 86, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (681, 87, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (682, 88, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (683, 89, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (684, 90, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (685, 91, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (686, 92, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (687, 93, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (688, 94, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (689, 95, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (690, 96, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (691, 97, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (692, 98, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (693, 99, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (694, 100, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (695, 101, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (696, 102, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (697, 97, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (698, 98, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (699, 99, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (700, 100, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (701, 101, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (702, 102, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (703, 103, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (704, 104, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (705, 105, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (706, 106, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (707, 107, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (708, 108, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (709, 97, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (710, 98, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (711, 99, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (712, 100, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (713, 101, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (714, 102, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (715, 103, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (716, 104, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (717, 105, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (718, 106, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (719, 107, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (720, 108, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (721, 97, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (722, 98, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (723, 99, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (724, 100, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (725, 101, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (726, 102, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (727, 103, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (728, 104, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (729, 105, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (730, 106, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (731, 107, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (732, 108, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (733, 1, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (734, 2, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (735, 1, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (736, 2, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (737, 3, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (738, 4, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (739, 5, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (740, 6, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (741, 7, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (742, 8, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (743, 9, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (744, 10, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (745, 11, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (746, 12, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (747, 97, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (748, 98, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (749, 99, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (750, 100, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (751, 101, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (752, 102, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (753, 103, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (754, 104, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (755, 105, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (756, 106, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (757, 107, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (758, 108, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (759, 1, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (760, 2, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (761, 3, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (762, 4, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (763, 5, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (764, 6, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (765, 7, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (766, 8, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (767, 9, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (768, 10, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (769, 97, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (770, 98, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (771, 99, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (772, 100, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (773, 101, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (774, 102, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (775, 103, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (776, 104, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (777, 105, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (778, 106, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (779, 107, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (780, 108, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (781, 1, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (782, 2, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (783, 3, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (784, 4, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (785, 5, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (786, 6, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (787, 5, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (788, 6, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (789, 5, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (790, 6, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (791, 1, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (792, 2, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (793, 3, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (794, 4, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (795, 5, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (796, 6, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (797, 1, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (798, 2, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (799, 3, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (800, 4, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (801, 98, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (802, 73, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (803, 100, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (805, 102, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (807, 104, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (809, 106, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (811, 108, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (812, 1, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (813, 2, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (814, 3, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (815, 4, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (816, 5, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (817, 97, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (818, 98, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (819, 99, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (820, 100, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (821, 101, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (822, 102, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (823, 103, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (824, 104, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (825, 105, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (826, 106, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (827, 107, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (828, 108, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (829, 1, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (830, 2, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (831, 3, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (832, 4, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (833, 5, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (834, 6, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (835, 1, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (836, 2, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (837, 3, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (838, 4, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (839, 5, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (840, 6, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (841, 1, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (842, 2, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (843, 3, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (844, 4, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (845, 97, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (846, 98, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (847, 99, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (848, 100, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (849, 101, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (850, 102, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (851, 103, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (852, 104, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (853, 105, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (854, 106, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (855, 107, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (856, 108, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (857, 97, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (858, 98, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (859, 99, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (860, 100, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (861, 101, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (862, 102, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (863, 103, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (864, 104, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (865, 105, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (866, 106, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (867, 107, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (868, 108, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (869, 1, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (871, 97, 0, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (872, 102, 0, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (873, 98, 0, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (874, 99, 0, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (875, 100, 0, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (876, 101, 0, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (877, 1, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (878, 2, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (879, 3, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (880, 4, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (881, 5, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (882, 6, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (883, 1, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (884, 2, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (885, 3, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (886, 4, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (887, 5, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (888, 6, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (889, 7, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (890, 8, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (891, 9, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (892, 10, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (893, 11, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (894, 12, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (895, 1, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (896, 2, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (897, 3, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (898, 4, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (899, 5, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (900, 6, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (901, 7, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (902, 8, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (903, 109, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (904, 110, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (905, 111, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (906, 112, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (907, 113, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (908, 114, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (909, 115, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (910, 116, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (911, 117, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (912, 118, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (913, 119, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (914, 120, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (915, 109, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (916, 110, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (917, 111, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (918, 112, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (919, 113, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (920, 114, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (921, 115, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (922, 116, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (923, 117, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (924, 118, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (925, 119, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (926, 120, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (927, 3, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (928, 4, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (929, 5, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (930, 109, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (931, 110, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (932, 111, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (933, 112, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (934, 113, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (935, 114, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (936, 115, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (937, 116, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (938, 117, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (939, 118, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (940, 119, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (941, 120, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (942, 1, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (943, 2, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (944, 3, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (945, 4, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (946, 5, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (947, 6, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (948, 7, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (949, 8, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (950, 9, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (951, 10, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (952, 7, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (953, 8, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (954, 1, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (955, 2, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (956, 3, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (957, 4, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (958, 5, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (965, 109, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (966, 110, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (967, 111, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (968, 112, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (969, 113, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (970, 114, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (971, 115, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (972, 116, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (973, 117, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (974, 118, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (975, 119, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (976, 120, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (977, 109, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (978, 110, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (979, 111, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (980, 112, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (981, 113, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (982, 114, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (983, 121, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (984, 122, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (985, 123, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (986, 124, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (987, 125, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (988, 126, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (989, 127, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (990, 128, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (991, 129, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (992, 130, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (993, 131, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (994, 132, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (995, 1, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (996, 2, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (997, 3, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (998, 4, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (999, 5, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1000, 121, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1001, 122, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1002, 123, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1003, 124, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1004, 125, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1005, 126, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1006, 127, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1007, 128, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1008, 129, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1009, 130, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1010, 131, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1011, 132, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1012, 1, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1013, 2, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1014, 3, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1015, 1, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1016, 2, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1017, 3, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1018, 4, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1019, 5, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1020, 6, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1021, 121, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1022, 122, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1023, 123, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1024, 124, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1025, 125, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1026, 126, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1027, 127, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1028, 128, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1029, 129, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1030, 130, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1031, 131, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1032, 132, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1033, 121, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1034, 122, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1035, 123, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1036, 124, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1037, 125, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1038, 126, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1039, 127, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1040, 128, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1041, 129, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1042, 130, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1043, 131, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1044, 132, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1045, 121, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1046, 122, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1047, 123, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1048, 124, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1049, 125, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1050, 126, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1051, 127, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1052, 128, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1053, 129, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1054, 130, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1055, 131, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1056, 132, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1057, 121, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1058, 122, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1059, 123, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1060, 124, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1061, 125, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1062, 126, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1063, 127, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1064, 128, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1065, 129, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1066, 130, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1067, 131, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1068, 132, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1069, 1, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1070, 2, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1071, 3, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1072, 4, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1073, 5, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1074, 6, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1075, 7, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1076, 8, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1077, 9, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1078, 10, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1079, 11, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1080, 12, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1081, 13, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1082, 14, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1083, 15, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1084, 16, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1085, 17, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1086, 18, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1087, 19, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1088, 20, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1089, 139, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1090, 140, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1091, 141, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1092, 142, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1093, 143, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1094, 144, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1095, 133, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1096, 134, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1097, 135, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1098, 136, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1099, 137, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1100, 138, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1101, 11, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1102, 12, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1103, 13, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1104, 14, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1105, 15, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1106, 16, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1107, 17, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1108, 18, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1109, 19, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1110, 20, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1111, 133, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1112, 134, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1113, 135, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1114, 136, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1115, 137, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1116, 138, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1117, 139, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1118, 140, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1119, 141, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1120, 142, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1121, 143, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1122, 144, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1123, 11, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1124, 12, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1125, 13, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1126, 14, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1127, 15, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1128, 16, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1129, 17, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1130, 18, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1131, 19, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1132, 20, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1133, 7, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1134, 8, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1135, 1, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1136, 2, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1137, 3, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1138, 4, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1139, 5, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1140, 6, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1141, 7, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1142, 8, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1143, 9, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1144, 10, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1145, 133, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1146, 134, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1147, 135, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1148, 136, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1149, 137, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1150, 138, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1151, 139, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1152, 140, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1153, 141, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1154, 142, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1155, 143, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1156, 144, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1157, 85, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1158, 86, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1159, 87, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1160, 88, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1161, 89, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1162, 90, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1163, 91, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1164, 92, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1165, 93, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1166, 94, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1167, 95, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1168, 96, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1169, 133, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1170, 134, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1171, 135, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1172, 136, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1173, 137, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1174, 138, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1175, 139, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1176, 140, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1177, 141, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1178, 142, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1179, 143, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1180, 144, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1181, 133, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1182, 134, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1183, 135, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1184, 136, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1185, 137, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1186, 138, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1187, 11, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1188, 12, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1189, 13, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1190, 14, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1191, 15, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1192, 16, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1193, 17, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1194, 18, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1195, 19, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1196, 20, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1197, 133, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1198, 134, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1199, 135, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1200, 136, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1201, 6, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1202, 7, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1203, 8, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1204, 9, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1205, 10, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1206, 133, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1207, 134, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1208, 135, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1209, 136, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1210, 137, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1211, 138, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1212, 1, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1213, 2, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1214, 3, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1215, 4, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1216, 5, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1217, 6, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1218, 7, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1219, 8, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1220, 9, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1221, 10, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1224, 1, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1225, 2, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1226, 3, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1227, 4, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1228, 5, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1229, 6, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1230, 7, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1231, 8, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1232, 9, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1233, 10, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1234, 1, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1235, 2, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1236, 3, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1237, 4, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1238, 5, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1239, 6, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1240, 7, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1241, 8, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1242, 9, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1243, 10, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1244, 11, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1245, 12, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1246, 13, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1247, 14, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1248, 15, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1249, 16, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1250, 133, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1251, 134, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1252, 135, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1253, 136, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1254, 137, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1255, 138, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1256, 139, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1257, 140, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1258, 141, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1259, 142, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1260, 143, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1261, 144, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1262, 1, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1263, 2, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1264, 3, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1265, 4, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1266, 5, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1267, 6, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1268, 49, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1269, 50, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1270, 51, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1271, 52, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1272, 53, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1273, 54, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1274, 55, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1275, 56, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1276, 57, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1277, 58, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1278, 59, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1279, 60, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1280, 109, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1281, 110, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1282, 111, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1283, 112, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1284, 113, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1285, 114, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1286, 115, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1287, 116, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1288, 117, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1289, 118, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1290, 119, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1291, 120, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1292, 13, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1293, 14, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1294, 15, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1295, 16, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1296, 17, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1297, 18, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1298, 19, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1299, 20, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1300, 21, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1301, 22, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1302, 23, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1303, 24, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1304, 98, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1305, 100, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1306, 102, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1307, 104, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1308, 106, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1309, 108, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1310, 85, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1312, 87, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1314, 97, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1313, 88, 3, 1, 'PT', NULL, 2);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1315, 98, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1316, 99, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1317, 100, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1318, NULL, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1319, NULL, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1320, NULL, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1321, 4, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1322, 5, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1323, 6, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1324, 7, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1325, 8, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1326, 9, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1327, 10, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1328, 11, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1329, 12, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1330, 13, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1331, 14, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1332, 15, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1333, 16, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1334, 17, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1335, 18, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1336, 19, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1337, 20, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1338, 21, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1339, 22, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1340, 23, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1341, 24, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1342, 25, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1343, 9, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1344, 10, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1345, NULL, 3, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1346, NULL, 0, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1347, 1, 0, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1348, 2, 0, 1, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1349, 108, NULL, NULL, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1350, 108, NULL, NULL, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1351, 108, NULL, NULL, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1352, 1, NULL, NULL, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1353, 2, NULL, NULL, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1354, 3, NULL, NULL, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1355, 4, NULL, NULL, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1356, 5, NULL, NULL, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1357, 6, NULL, NULL, 'PT', NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1358, 1, NULL, NULL, NULL, NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1359, 2, NULL, NULL, NULL, NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1360, 3, NULL, NULL, NULL, NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1361, 4, NULL, NULL, NULL, NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1362, 5, NULL, NULL, NULL, NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1363, 6, NULL, NULL, NULL, NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1364, 7, NULL, NULL, NULL, NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1365, 8, NULL, NULL, NULL, NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1366, 9, NULL, NULL, NULL, NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1367, 10, NULL, NULL, NULL, NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1368, 11, NULL, NULL, NULL, NULL, 1);
INSERT INTO public.paces (id, number, edition, edition_order, type, weight, star_value) VALUES (1369, 12, NULL, NULL, NULL, NULL, 1);


--
-- Data for Name: parents; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.parents (id, first_name, last_name, phone_number, family_id) OVERRIDING SYSTEM VALUE VALUES (1, 'Annemieke', 'Littel', NULL, 1);
INSERT INTO public.parents (id, first_name, last_name, phone_number, family_id) OVERRIDING SYSTEM VALUE VALUES (2, 'Sandra ', 'Mo', '0622077334', 2);


--
-- Data for Name: personnel; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.personnel (id, first_name, last_name, "group", type, rank, email, is_admin) OVERRIDING SYSTEM VALUE VALUES (2, 'Andrew', 'Yong', 'Seniors', 'Supervisor', 2, NULL, false);
INSERT INTO public.personnel (id, first_name, last_name, "group", type, rank, email, is_admin) OVERRIDING SYSTEM VALUE VALUES (3, 'Hanna', 'Visser', 'Juniors', 'Supervisor', 1, NULL, false);
INSERT INTO public.personnel (id, first_name, last_name, "group", type, rank, email, is_admin) OVERRIDING SYSTEM VALUE VALUES (1, 'Simon', 'Bezemer', 'Seniors', 'Principal', 1, NULL, false);
INSERT INTO public.personnel (id, first_name, last_name, "group", type, rank, email, is_admin) OVERRIDING SYSTEM VALUE VALUES (4, 'Johanna', 'van Kleef', 'Juniors', 'Supervisor', 1, NULL, false);
INSERT INTO public.personnel (id, first_name, last_name, "group", type, rank, email, is_admin) OVERRIDING SYSTEM VALUE VALUES (5, 'Annelies', 'Trimp', 'ABCs', 'Supervisor', 1, NULL, false);
INSERT INTO public.personnel (id, first_name, last_name, "group", type, rank, email, is_admin) OVERRIDING SYSTEM VALUE VALUES (6, 'Hannah', 'Onbekend', 'Seniors', 'Supervisor', 1, NULL, false);


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sessions (sid, sess, expire) VALUES ('ceder-doc-screenshot-001', '{"cookie": {"path": "/", "secure": false, "expires": "2026-04-15T20:35:43.073Z", "httpOnly": true, "originalMaxAge": 2592000000}, "passport": {"user": {"claims": {"exp": 2773693342, "sub": "doc-teacher-screenshot", "email": "docscreenshot@example.com", "last_name": "Teacher", "first_name": "Doc"}, "expires_at": 2773693342, "access_token": "test-access-token-screenshots", "refresh_token": null}}}', '2026-04-15 20:35:43.073');
INSERT INTO public.sessions (sid, sess, expire) VALUES ('abriox5kaBjS_q2uK_ui_Rt_AoQ5qY26', '{"cookie": {"path": "/", "secure": true, "expires": "2026-04-12T14:52:01.654Z", "httpOnly": true, "originalMaxAge": 2592000000}, "passport": {"user": {"claims": {"aud": "e2d76b83-015c-4760-a38e-9a3f7f25c165", "exp": 1773417121, "iat": 1773413521, "iss": "https://replit.com/oidc", "sub": "56013081", "email": "s.bezemer@ceder.nl", "at_hash": "Jyja4Vk7JUniKaWSp3MnzQ", "username": "sbezemer", "auth_time": 1773413521, "last_name": null, "first_name": null, "email_verified": true}, "expires_at": 1773417121, "access_token": "5GM3VaDRoFW8u9QYttk43RIIFJzdP2yt7HUNJiFUTZ-", "refresh_token": "nsb60VQf5jSKqAuprHp9yG-FNVeI03FqvdsV22ketPQ"}}}', '2026-04-12 15:19:18');
INSERT INTO public.sessions (sid, sess, expire) VALUES ('uvO67IVFrtEu9bUGEEhCrhIZfdn7xo0y', '{"cookie": {"path": "/", "secure": true, "expires": "2026-04-19T17:54:56.175Z", "httpOnly": true, "originalMaxAge": 2592000000}, "passport": {"user": {"claims": {"aud": "e2d76b83-015c-4760-a38e-9a3f7f25c165", "exp": 1774032896, "iat": 1774029296, "iss": "https://replit.com/oidc", "sub": "49604856", "email": "yartow@gmail.com", "at_hash": "z4hz_POBZSGQuYMmHdpMEg", "username": "yartow", "auth_time": 1773689520, "last_name": "Yong", "first_name": "Andrew", "email_verified": true}, "expires_at": 1774032896, "access_token": "4UdBfiFn5gKThhRMu6NyMfKi4Y7FQqUmnclkGFTvo1e", "refresh_token": "182I1dntqYVqGP_r0H3zYykwq9PIiwnXslMysYxArjY"}}}', '2026-04-19 17:55:08');


--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.students (id, surname, first_names, call_name, alias, is_dyslexic, active, reason_inactive, remarks, date_of_birth, family_id, "group") VALUES (5, 'Boulahdaraj', 'Zakariya', 'Zakariya', 'Zakariya Boulahdaraj', false, true, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.students (id, surname, first_names, call_name, alias, is_dyslexic, active, reason_inactive, remarks, date_of_birth, family_id, "group") VALUES (10, 'Gonzalez Rodriguez', 'Eleazar Leonardo', 'Eleazar', 'Eleazar Gonzalez Rodriguez', false, true, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.students (id, surname, first_names, call_name, alias, is_dyslexic, active, reason_inactive, remarks, date_of_birth, family_id, "group") VALUES (12, 'Harkes', 'Marinus Dirk Martijn', 'Stijn', 'Stijn Harkes', false, true, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.students (id, surname, first_names, call_name, alias, is_dyslexic, active, reason_inactive, remarks, date_of_birth, family_id, "group") VALUES (20, 'Lee ', 'Myung', 'Matthew', 'Matthew Lee ', false, true, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.students (id, surname, first_names, call_name, alias, is_dyslexic, active, reason_inactive, remarks, date_of_birth, family_id, "group") VALUES (21, 'Littel', 'Beline Elizabeth', 'Lina', 'Lina Littel', false, true, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.students (id, surname, first_names, call_name, alias, is_dyslexic, active, reason_inactive, remarks, date_of_birth, family_id, "group") VALUES (22, 'Littel', 'Simon Johannes', 'Sam', 'Sam Littel', false, true, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.students (id, surname, first_names, call_name, alias, is_dyslexic, active, reason_inactive, remarks, date_of_birth, family_id, "group") VALUES (23, 'Littel', 'Catharina Johanna', 'Noa', 'Noa Littel', false, true, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.students (id, surname, first_names, call_name, alias, is_dyslexic, active, reason_inactive, remarks, date_of_birth, family_id, "group") VALUES (24, 'Trimp', 'Elbert Daniël', 'Dani', 'Dani Trimp', false, true, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.students (id, surname, first_names, call_name, alias, is_dyslexic, active, reason_inactive, remarks, date_of_birth, family_id, "group") VALUES (25, 'Trimp', 'Aron Pieter', 'Aron', 'Aron Trimp', false, true, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.students (id, surname, first_names, call_name, alias, is_dyslexic, active, reason_inactive, remarks, date_of_birth, family_id, "group") VALUES (55, 'Steenbeek', 'Gabriël', 'Gabriël', 'Gabriël Steenbeek', false, true, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.students (id, surname, first_names, call_name, alias, is_dyslexic, active, reason_inactive, remarks, date_of_birth, family_id, "group") VALUES (54, 'Steenbeek', 'Refaja', 'Refaja', 'Refaja Steenbeek', false, true, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.students (id, surname, first_names, call_name, alias, is_dyslexic, active, reason_inactive, remarks, date_of_birth, family_id, "group") VALUES (7, 'Brand', 'Lois-Daan', 'Lois-Daan', 'Lois-Daan van den Brand', false, false, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.students (id, surname, first_names, call_name, alias, is_dyslexic, active, reason_inactive, remarks, date_of_birth, family_id, "group") VALUES (6, 'Brand', 'Ezra', 'Ezra', 'Ezra van den Brand', false, false, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.students (id, surname, first_names, call_name, alias, is_dyslexic, active, reason_inactive, remarks, date_of_birth, family_id, "group") VALUES (53, 'Hoogendoorn', 'Boaz', 'Boaz', 'Boaz Hoogendoorn', false, false, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.students (id, surname, first_names, call_name, alias, is_dyslexic, active, reason_inactive, remarks, date_of_birth, family_id, "group") VALUES (56, 'Chen', 'Sofia', 'Sofia', 'Sofia Chen', false, true, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.students (id, surname, first_names, call_name, alias, is_dyslexic, active, reason_inactive, remarks, date_of_birth, family_id, "group") VALUES (8, 'Bruijne', 'Matthias', 'Matthias', 'Matthias de Bruijne', false, false, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.students (id, surname, first_names, call_name, alias, is_dyslexic, active, reason_inactive, remarks, date_of_birth, family_id, "group") VALUES (19, 'Lee ', 'Kang Kevin', 'Kevin', 'Kevin Lee ', false, false, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.students (id, surname, first_names, call_name, alias, is_dyslexic, active, reason_inactive, remarks, date_of_birth, family_id, "group") VALUES (1, 'Adeleke', 'Deborah', 'Deborah', 'Deborah Adeleke', false, false, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.students (id, surname, first_names, call_name, alias, is_dyslexic, active, reason_inactive, remarks, date_of_birth, family_id, "group") VALUES (2, 'Adeleke', 'Oluwatobi Samuel', 'Oluwatobi', 'Oluwatobi Adeleke', false, false, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.students (id, surname, first_names, call_name, alias, is_dyslexic, active, reason_inactive, remarks, date_of_birth, family_id, "group") VALUES (3, 'Adeleke', 'Dorcas Mayowa Oluwatofarati Temitope Esther', 'Dorcas', 'Dorcas Adeleke', false, true, NULL, NULL, NULL, 3, 'Seniors');
INSERT INTO public.students (id, surname, first_names, call_name, alias, is_dyslexic, active, reason_inactive, remarks, date_of_birth, family_id, "group") VALUES (13, 'Harkes', 'Jonathan Anne Theodoor', 'Jona', 'Jona Harkes', true, true, NULL, NULL, NULL, 4, 'Seniors');
INSERT INTO public.students (id, surname, first_names, call_name, alias, is_dyslexic, active, reason_inactive, remarks, date_of_birth, family_id, "group") VALUES (29, 'Yong', 'Joseph Nathan Andrew Jun-Yin', 'Nathan', 'Nathan Yong', false, true, NULL, NULL, '2010-10-02', 2, 'Seniors');
INSERT INTO public.students (id, surname, first_names, call_name, alias, is_dyslexic, active, reason_inactive, remarks, date_of_birth, family_id, "group") VALUES (9996, 'Kindergarten', 'Inventory', 'Inventory', 'INV-KG', false, true, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.students (id, surname, first_names, call_name, alias, is_dyslexic, active, reason_inactive, remarks, date_of_birth, family_id, "group") VALUES (9997, 'ABCs', 'Inventory', 'Inventory', 'INV-ABC', false, true, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.students (id, surname, first_names, call_name, alias, is_dyslexic, active, reason_inactive, remarks, date_of_birth, family_id, "group") VALUES (9998, 'Juniors', 'Inventory', 'Inventory', 'INV-JNR', false, true, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.students (id, surname, first_names, call_name, alias, is_dyslexic, active, reason_inactive, remarks, date_of_birth, family_id, "group") VALUES (9999, 'Seniors', 'Inventory', 'Inventory', 'INV-SNR', false, true, NULL, NULL, NULL, NULL, NULL);


--
-- Data for Name: subject_groups; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.subject_groups (id, subject_group, remarks) VALUES (2, 'Core Academic Studies', NULL);
INSERT INTO public.subject_groups (id, subject_group, remarks) VALUES (1, 'Christian Studies', NULL);
INSERT INTO public.subject_groups (id, subject_group, remarks) VALUES (3, 'Core Expanded Studies', NULL);
INSERT INTO public.subject_groups (id, subject_group, remarks) VALUES (4, 'Applied Studies', NULL);
INSERT INTO public.subject_groups (id, subject_group, remarks) VALUES (7, 'Coursework', NULL);


--
-- Data for Name: subjects; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.subjects (id, subject, color_id, color, color_code, subject_group_id) VALUES (12, 'Technology Electives', 8, 'dark grey', '#404040', NULL);
INSERT INTO public.subjects (id, subject, color_id, color, color_code, subject_group_id) VALUES (1, 'Maths', 4, 'yellow', '#FFD700', 2);
INSERT INTO public.subjects (id, subject, color_id, color, color_code, subject_group_id) VALUES (2, 'Language', 2, 'red', '#FF0000', 2);
INSERT INTO public.subjects (id, subject, color_id, color, color_code, subject_group_id) VALUES (3, 'Word Building', 9, 'purple', '#800080', 2);
INSERT INTO public.subjects (id, subject, color_id, color, color_code, subject_group_id) VALUES (4, 'Literature', 3, 'dark red', '#8B0000', 2);
INSERT INTO public.subjects (id, subject, color_id, color, color_code, subject_group_id) VALUES (5, 'Science', 5, 'blue', '#0000FF', 2);
INSERT INTO public.subjects (id, subject, color_id, color, color_code, subject_group_id) VALUES (6, 'Social Studies', 6, 'green', '#008000', 2);
INSERT INTO public.subjects (id, subject, color_id, color, color_code, subject_group_id) VALUES (7, 'Biblical Studies', 1, 'sandy orange', '#F4A460', 1);
INSERT INTO public.subjects (id, subject, color_id, color, color_code, subject_group_id) VALUES (8, 'Electives', 7, 'grey', '#808080', 2);
INSERT INTO public.subjects (id, subject, color_id, color, color_code, subject_group_id) VALUES (10, 'Supplementary', 10, 'white', '#FFFFFF', 2);
INSERT INTO public.subjects (id, subject, color_id, color, color_code, subject_group_id) VALUES (11, 'Art Electives', 9, 'purple', '#800080', 3);


--
-- Data for Name: supplementary_activities; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.supplementary_activities (id, student_id, year_term, term, grade, activity) OVERRIDING SYSTEM VALUE VALUES (2, 29, NULL, NULL, NULL, 'Physical Education');
INSERT INTO public.supplementary_activities (id, student_id, year_term, term, grade, activity) OVERRIDING SYSTEM VALUE VALUES (1, 29, NULL, 3, 'G', 'Music');
INSERT INTO public.supplementary_activities (id, student_id, year_term, term, grade, activity) OVERRIDING SYSTEM VALUE VALUES (3, 29, NULL, 2, 'S', 'Music');


--
-- Data for Name: user_profiles; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.user_profiles (id, user_id, role, family_id, is_admin, first_name, last_name, email) OVERRIDING SYSTEM VALUE VALUES (1, '49604856', 'teacher', NULL, true, NULL, NULL, NULL);
INSERT INTO public.user_profiles (id, user_id, role, family_id, is_admin, first_name, last_name, email) OVERRIDING SYSTEM VALUE VALUES (2, '55888484', 'parent', 2, false, NULL, NULL, NULL);
INSERT INTO public.user_profiles (id, user_id, role, family_id, is_admin, first_name, last_name, email) OVERRIDING SYSTEM VALUE VALUES (3, '56013081', 'teacher', NULL, false, NULL, NULL, NULL);
INSERT INTO public.user_profiles (id, user_id, role, family_id, is_admin, first_name, last_name, email) OVERRIDING SYSTEM VALUE VALUES (4, 'doc-teacher-screenshot', 'teacher', NULL, false, NULL, NULL, NULL);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.users (id, email, first_name, last_name, profile_image_url, created_at, updated_at) VALUES ('55888484', 'sandra.mo@gmail.com', NULL, NULL, NULL, '2026-03-10 15:49:04.882051', '2026-03-10 15:49:04.882051');
INSERT INTO public.users (id, email, first_name, last_name, profile_image_url, created_at, updated_at) VALUES ('56013081', 's.bezemer@ceder.nl', NULL, NULL, NULL, '2026-03-13 14:52:01.469565', '2026-03-13 14:52:01.469565');
INSERT INTO public.users (id, email, first_name, last_name, profile_image_url, created_at, updated_at) VALUES ('49604856', 'yartow@gmail.com', 'Andrew', 'Yong', NULL, '2026-03-06 19:28:49.162105', '2026-03-16 19:32:00.743');
INSERT INTO public.users (id, email, first_name, last_name, profile_image_url, created_at, updated_at) VALUES ('doc-teacher-screenshot', 'docscreenshot@example.com', 'Doc', 'Teacher', NULL, '2026-03-16 20:35:43.130653', '2026-03-16 20:35:43.130653');


--
-- Name: enrollments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.enrollments_id_seq', 111, true);


--
-- Name: families_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.families_id_seq', 4, true);


--
-- Name: inventory_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.inventory_id_seq', 18, true);


--
-- Name: invitations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.invitations_id_seq', 2, true);


--
-- Name: order_list_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.order_list_items_id_seq', 14, true);


--
-- Name: order_lists_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.order_lists_id_seq', 1, true);


--
-- Name: pace_versions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.pace_versions_id_seq', 12, true);


--
-- Name: parents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.parents_id_seq', 2, true);


--
-- Name: personnel_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.personnel_id_seq', 6, true);


--
-- Name: students_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.students_id_seq', 57, false);


--
-- Name: supplementary_activities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.supplementary_activities_id_seq', 3, true);


--
-- Name: user_profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_profiles_id_seq', 4, true);


--
-- Name: courses courses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (id);


--
-- Name: dates dates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dates
    ADD CONSTRAINT dates_pkey PRIMARY KEY (id);


--
-- Name: enrollments enrollments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_pkey PRIMARY KEY (id);


--
-- Name: families families_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.families
    ADD CONSTRAINT families_pkey PRIMARY KEY (id);


--
-- Name: inventory inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT inventory_pkey PRIMARY KEY (id);


--
-- Name: invitations invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_pkey PRIMARY KEY (id);


--
-- Name: invitations invitations_token_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_token_unique UNIQUE (token);


--
-- Name: order_list_items order_list_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_list_items
    ADD CONSTRAINT order_list_items_pkey PRIMARY KEY (id);


--
-- Name: order_lists order_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_lists
    ADD CONSTRAINT order_lists_pkey PRIMARY KEY (id);


--
-- Name: pace_courses pace_courses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pace_courses
    ADD CONSTRAINT pace_courses_pkey PRIMARY KEY (id);


--
-- Name: pace_versions pace_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pace_versions
    ADD CONSTRAINT pace_versions_pkey PRIMARY KEY (id);


--
-- Name: paces paces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paces
    ADD CONSTRAINT paces_pkey PRIMARY KEY (id);


--
-- Name: parents parents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parents
    ADD CONSTRAINT parents_pkey PRIMARY KEY (id);


--
-- Name: personnel personnel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.personnel
    ADD CONSTRAINT personnel_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (sid);


--
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (id);


--
-- Name: subject_groups subject_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subject_groups
    ADD CONSTRAINT subject_groups_pkey PRIMARY KEY (id);


--
-- Name: subjects subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (id);


--
-- Name: supplementary_activities supplementary_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplementary_activities
    ADD CONSTRAINT supplementary_activities_pkey PRIMARY KEY (id);


--
-- Name: user_profiles user_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_pkey PRIMARY KEY (id);


--
-- Name: users users_email_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: IDX_session_expire; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_session_expire" ON public.sessions USING btree (expire);


--
-- Name: enrollments enrollments_course_id_courses_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_course_id_courses_id_fk FOREIGN KEY (course_id) REFERENCES public.courses(id);


--
-- Name: enrollments enrollments_student_id_students_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_student_id_students_id_fk FOREIGN KEY (student_id) REFERENCES public.students(id);


--
-- Name: inventory inventory_pace_versions_id_pace_versions_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT inventory_pace_versions_id_pace_versions_id_fk FOREIGN KEY (pace_versions_id) REFERENCES public.pace_versions(id);


--
-- Name: inventory inventory_student_id_students_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT inventory_student_id_students_id_fk FOREIGN KEY (student_id) REFERENCES public.students(id);


--
-- Name: order_list_items order_list_items_course_id_courses_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_list_items
    ADD CONSTRAINT order_list_items_course_id_courses_id_fk FOREIGN KEY (course_id) REFERENCES public.courses(id);


--
-- Name: order_list_items order_list_items_enrollment_id_enrollments_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_list_items
    ADD CONSTRAINT order_list_items_enrollment_id_enrollments_id_fk FOREIGN KEY (enrollment_id) REFERENCES public.enrollments(id);


--
-- Name: order_list_items order_list_items_order_list_id_order_lists_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_list_items
    ADD CONSTRAINT order_list_items_order_list_id_order_lists_id_fk FOREIGN KEY (order_list_id) REFERENCES public.order_lists(id);


--
-- Name: order_list_items order_list_items_pace_id_paces_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_list_items
    ADD CONSTRAINT order_list_items_pace_id_paces_id_fk FOREIGN KEY (pace_id) REFERENCES public.paces(id);


--
-- Name: order_list_items order_list_items_student_id_students_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_list_items
    ADD CONSTRAINT order_list_items_student_id_students_id_fk FOREIGN KEY (student_id) REFERENCES public.students(id);


--
-- Name: pace_courses pace_courses_course_id_courses_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pace_courses
    ADD CONSTRAINT pace_courses_course_id_courses_id_fk FOREIGN KEY (course_id) REFERENCES public.courses(id);


--
-- Name: pace_courses pace_courses_pace_id_paces_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pace_courses
    ADD CONSTRAINT pace_courses_pace_id_paces_id_fk FOREIGN KEY (pace_id) REFERENCES public.paces(id);


--
-- Name: pace_versions pace_versions_pace_id_paces_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pace_versions
    ADD CONSTRAINT pace_versions_pace_id_paces_id_fk FOREIGN KEY (pace_id) REFERENCES public.paces(id);


--
-- Name: parents parents_family_id_families_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parents
    ADD CONSTRAINT parents_family_id_families_id_fk FOREIGN KEY (family_id) REFERENCES public.families(id);


--
-- Name: students students_family_id_families_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_family_id_families_id_fk FOREIGN KEY (family_id) REFERENCES public.families(id);


--
-- Name: subjects subjects_subject_group_id_subject_groups_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_subject_group_id_subject_groups_id_fk FOREIGN KEY (subject_group_id) REFERENCES public.subject_groups(id);


--
-- Name: supplementary_activities supplementary_activities_student_id_students_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supplementary_activities
    ADD CONSTRAINT supplementary_activities_student_id_students_id_fk FOREIGN KEY (student_id) REFERENCES public.students(id);


--
-- Name: user_profiles user_profiles_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--



-- Local dev admin user (auto-login without Replit Auth)
INSERT INTO public.users (id, email, first_name, last_name) VALUES ('local-admin', 'admin@ceder.local', 'Local', 'Admin') ON CONFLICT (id) DO NOTHING;
INSERT INTO public.user_profiles (user_id, role, is_admin) VALUES ('local-admin', 'teacher', true) ON CONFLICT DO NOTHING;
