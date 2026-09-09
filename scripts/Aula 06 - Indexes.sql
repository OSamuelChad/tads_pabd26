-- INDEXES

-- Exibe esquema, índices e definições
select 
    schemaname,
    tablename,
    indexname,
    indexdef
from pg_indexes
where tablename = 'address' -- Nome da tabela
order by tablename, indexname;

select 
    address_id,
    address,
    district,
    phone
from address
where phone = '223664661973';

explain analyze
select 
    address_id,
    address,
    district,
    phone
from address
where phone = '223664661973';

drop index if exists idx_address_phone;

-- Seq Scan on address  (cost=0.00..15.54 rows=1 width=45) (actual time=0.029..0.134 rows=1 loops=1)
--    Filter: ((phone)::text = '223664661973'::text)
--    Rows Removed by Filter: 602
--  Planning Time: 0.095 ms
--  Execution Time: 0.150 ms

create index idx_address_phone on address(phone);

-- Index Scan using idx_address_phone on address  (cost=0.28..8.29 rows=1 width=45) (actual time=0.023..0.025 rows=1 loops=1)
--    Index Cond: ((phone)::text = '223664661973'::text)
--  Planning Time: 0.081 ms
--  Execution Time: 0.040 ms