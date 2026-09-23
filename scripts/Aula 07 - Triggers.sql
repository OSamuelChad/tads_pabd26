/*
    Aula 07 - TRIGGERS
*/

-- ==================================================
-- Exemplo 1 - AFTER INSERT
-- ==================================================

-- Sincronizando total gasto por cliente (customer) a cada novo pagamento (payment)

drop table if exists customer_spending;
create table customer_spending (
    customer_id int primary key references customer(customer_id),
    total numeric not null default 0
);

insert into customer_spending (customer_id, total)
select customer_id, sum(amount)
from payment
group by customer_id;

create or replace function update_customer_spending()
    returns trigger
    language plpgsql
as $$
begin
    update customer_spending
    set total = total + NEW.amount
    where customer_id = NEW.customer_id;

    return NEW;
end
$$;

drop trigger if exists trg_update_customer_spending on payment;
create trigger trg_update_customer_spending
after insert on payment
for each row
execute function update_customer_spending();

-- Teste
select * from customer_spending where customer_id = 1;

insert into payment (customer_id, staff_id, rental_id, amount, payment_date)
values (1, 1, 1, 10, now());

select * from customer_spending where customer_id = 1;

-- ==================================================
-- Exemplo 2 - BEFORE INSERT
-- ==================================================

-- Validação de regra de negócio (rental_date não pode ser no futuro)

create or replace function check_rental_date()
    returns trigger
    language plpgsql
as $$
begin
    if NEW.rental_date > now() then
        raise exception 'rental_date no futuro!? (valor recebido: %)', NEW.rental_date;
    end if;

    return NEW;
end;
$$;

drop trigger if exists trg_check_rental_date on rental;
create trigger trg_check_rental_date
before insert on rental
for each row
execute function check_rental_date();

-- Teste
insert into rental (rental_date, inventory_id, customer_id, staff_id)
values (now() + interval '1 day', 1, 1, 1);

select count(*) from rental;