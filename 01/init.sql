-- 
-- depends: 

CREATE SCHEMA quiz;

-- ----------------
-- пользователи
-- ----------------

CREATE TABLE quiz.t_users (
    id integer GENERATED ALWAYS AS IDENTITY NOT NULL primary key,
    login character varying(255) NOT NULL,
    create_date timestamp with time zone DEFAULT now() NOT NULL,
    chat_id character varying(255)
);

ALTER TABLE quiz.t_users OWNER TO postgres;
COMMENT ON TABLE quiz.t_users IS 'Пользователи';
COMMENT ON COLUMN quiz.t_users.id IS 'УнНом пользователя';
COMMENT ON COLUMN quiz.t_users.login IS 'Имя пользователя в telegram (если не указано, то id чата + full_name)';
COMMENT ON COLUMN quiz.t_users.create_date IS 'Дата/время создания пользователя';
COMMENT ON COLUMN quiz.t_users.chat_id IS 'Идентификатор чата пользователя (для рассылки сообщений от БОТА)';

-- ----------------
-- журнал событий
-- ----------------

CREATE TABLE quiz.t_audit (
    id integer GENERATED ALWAYS AS IDENTITY NOT NULL primary key,
    date timestamp with time zone DEFAULT now() NOT NULL,
    user_id integer,
    message character varying(512) NOT NULL,
    type_id integer
);

ALTER TABLE quiz.t_audit OWNER TO postgres;
COMMENT ON TABLE quiz.t_audit IS 'аудит';
COMMENT ON COLUMN quiz.t_audit.id IS 'УнНом записи';
COMMENT ON COLUMN quiz.t_audit.date IS 'Дата/время';
COMMENT ON COLUMN quiz.t_audit.user_id IS 'Идентификатор пользователя';
COMMENT ON COLUMN quiz.t_audit.message IS 'Сообщение';
COMMENT ON COLUMN quiz.t_audit.type_id IS 'Идентификатор типа сообщения из Python ERROR/WARNING и т.п.';

-- ----------------
-- опросы (исходные)
-- ----------------

CREATE TABLE quiz.ts_quiz (
    id integer GENERATED ALWAYS AS IDENTITY NOT NULL primary key,
    quiz_index integer NOT NULL,
    caption character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    open_date timestamp with time zone NOT NULL,
    close_date timestamp with time zone NOT NULL,
    create_date timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE quiz.ts_quiz OWNER TO postgres;

COMMENT ON TABLE quiz.ts_quiz IS 'Опросы';

-- ----------------
-- вопросы (исходные)
-- ----------------

CREATE TABLE quiz.ts_questions (
    id integer GENERATED ALWAYS AS IDENTITY NOT NULL primary key,
    question_index integer NOT NULL,
    quiz_index integer NOT NULL,
    category integer NOT NULL,
    caption character varying(300) NOT NULL,
    option_1 character varying(100) NOT NULL,
    option_2 character varying(100) NOT NULL,
    option_3 character varying(100) NOT NULL,
    option_4 character varying(100) NOT NULL,
    scope_1 numeric(15,2) NOT NULL,
    scope_2 numeric(15,2) NOT NULL,
    scope_3 numeric(15,2) NOT NULL,
    scope_4 numeric(15,2) NOT NULL,
    create_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE quiz.ts_questions OWNER TO postgres;
COMMENT ON TABLE quiz.ts_questions IS 'Справочник вопросы к урокам';

-- ----------------
-- опросы (которые начали пользователи)
-- ----------------

CREATE TABLE quiz.t_user_quiz (
    id integer GENERATED ALWAYS AS IDENTITY NOT NULL primary key,
    quiz_index integer NOT NULL,
    user_id integer NOT NULL,
    scope numeric(15,2) NOT NULL,
    end_date timestamp with time zone,
    create_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE quiz.t_user_quiz OWNER TO postgres;
COMMENT ON TABLE quiz.t_user_quiz IS 'Опросы пользователей';

-- ----------------
-- ответы на вопросы
-- ----------------

CREATE TABLE quiz.t_user_answers (
    id integer GENERATED ALWAYS AS IDENTITY NOT NULL primary key,
    user_id integer NOT NULL,
    quiz_index integer NOT NULL,
    question_index integer NOT NULL,
    answers character varying(255) NOT NULL,
    scope_1 numeric(15,2) NOT NULL,
    scope_2 numeric(15,2) NOT NULL,
    scope_3 numeric(15,2) NOT NULL,
    scope_4 numeric(15,2) NOT NULL,
    create_date timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE quiz.t_user_answers OWNER TO postgres;

COMMENT ON TABLE quiz.t_user_answers IS 'Ответы пользователей';

-- ----------------
-- создание различных view
-- ----------------

-- статистика регистрации

CREATE VIEW quiz.v_users_registration AS
 SELECT to_char(t_users.create_date, 'YYYY-MM-DD'::text) AS create_date,
    count(*) AS count
   FROM quiz.t_users
  GROUP BY (to_char(t_users.create_date, 'YYYY-MM-DD'::text))
  ORDER BY (to_char(t_users.create_date, 'YYYY-MM-DD'::text)) DESC;

ALTER TABLE quiz.v_users_registration OWNER TO postgres;

COMMENT ON VIEW quiz.v_users_registration IS 'Статистика регистрации пользователей';

-- статистика использования

-- рейтинг пользователей

insert into quiz.ts_quiz (
quiz_index,
caption,
description,
open_date,
close_date

)
values (
1,
'Опрос 1',
'Опрос 1',
'2024-08-28',
'2025-01-01'
);

insert into quiz.ts_questions(
    quiz_index,
    question_index,
    category,
    caption,
    option_1,
    option_2,
    option_3,
    option_4,
    scope_1,
    scope_2,
    scope_3,
    scope_4
)
values (
1,
1,
1,
'Как вы планирует ответить на первый вопрос?',
'Ответ 1 - правильный',
'Ответ 2',
'Ответ 3',
'Ответ 4',
1,
0,
0,
0
);

insert into quiz.ts_questions(
    quiz_index,
    question_index,
    category,
    caption,
    option_1,
    option_2,
    option_3,
    option_4,
    scope_1,
    scope_2,
    scope_3,
    scope_4
)
values (
1,
2,
2,
'Как вы планирует ответить на второй вопрос?',
'Ответ 1',
'Ответ 2 - правильный',
'Ответ 3',
'Ответ 4',
0,
1,
0,
0
);

insert into quiz.ts_questions(
    quiz_index,
    question_index,
    category,
    caption,
    option_1,
    option_2,
    option_3,
    option_4,
    scope_1,
    scope_2,
    scope_3,
    scope_4
)
values (
1,
3,
3,
'Как вы планирует ответить на третий вопрос?',
'Ответ 1',
'Ответ 2',
'Ответ 3 - правильный',
'Ответ 4',
0,
0,
1,
0
);

