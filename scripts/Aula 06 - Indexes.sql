-- INDEXES
-- Exibe esquema, índices e definições
select
    schemaname,
    tablename,
    indexname,
    indexdef
from
    pg_indexes
where
    tablename = 'customer' -- Nome da tabela
order by
    tablename,
    indexname;

select
    address_id,
    address,
    district,
    phone
from
    address
where
    phone = '223664661973';

explain analyze
select
    address_id,
    address,
    district,
    phone
from
    address
where
    phone = '223664661973';

drop index if exists idx_address_phone;

-- Seq Scan on address  (cost=0.00..15.54 rows=1 width=45) (actual time=0.029..0.134 rows=1 loops=1)
--    Filter: ((phone)::text = '223664661973'::text)
--    Rows Removed by Filter: 602
--  Planning Time: 0.095 ms
--  Execution Time: 0.150 ms
create index idx_address_phone on address (phone);

-- Index Scan using idx_address_phone on address  (cost=0.28..8.29 rows=1 width=45) (actual time=0.023..0.025 rows=1 loops=1)
--    Index Cond: ((phone)::text = '223664661973'::text)
--  Planning Time: 0.081 ms
--  Execution Time: 0.040 ms
explain analyze
select
    customer_id,
    first_name,
    last_name
from
    customer
where
    last_name = 'Purdy';

drop index if exists idx_customer_last_name;

create index idx_customer_last_name_lower on customer (lower(last_name));

explain analyze
select
    customer_id,
    first_name,
    last_name
from
    customer
where
    lower(last_name) = 'purdy';

-- ÍNDICES PARCIAIS
-- A partial index is an index built on a SUBSET OF DATA of the indexed columns.
-- To define a subset of data, you use a predicate, which is a conditional expression, of the partial index. PostgreSQL will build an index for rows that satisfy the predicate.
-- Indexando buscar por clientes inativos (active=0)
drop index if exists idx_customer_active;

create index idx_customer_active on customer (active)
where
    active = 0;

explain analyze
select
    customer_id,
    active
from
    customer
where
    active = 0;

-- Predicado!
-- ÍNDICES MULTICOLUNAS
-- where
--     column1 = v1
--     AND column2 = v2
--     AND column3 = v3;
-- where
--     column1 = v1
--     AND column2 = v2;
-- where
--     column1 = v1;
-- Executar script: \i utils/script_index_fts.sql

drop index if exists idx_people_names;
create index idx_people_names on people(last_name, first_name);

explain analyze
select
    id,
    first_name,
    last_name
from
    people
where
    last_name = 'Adams'
    and first_name = 'Lou';

-- O planejador opta por não utilizar o índice
explain analyze
select
    id,
    first_name,
    last_name
from
    people
where
    first_name = 'Lou';

/* 
    TO DO: CRIAÇÃO DE ÍNDICES - Esquema lista01

    - Baseado nas views (comando \dmv), quais índices poderiam ser criados?
    - Para forçar o uso dos índices em tabelas pequenas: SET enable_seqscan = off;
/*

