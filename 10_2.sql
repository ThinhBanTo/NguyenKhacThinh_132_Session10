--tao bang
create table customers(
    id serial primary key,
    name varchar(50),
    credit_limit numeric
);

create table orders(
    id serial primary key ,
    customer_id int references customers(id),
    order_amount numeric
);

--tao index cho customer_id
create index idx_customer_id on orders(customer_id);
--tao func check_credit_limit
create or replace function check_credit_limit()
returns trigger as $$
declare
    v_current_amount numeric;
    v_limit numeric;
begin
    select credit_limit into v_limit
    from customers
    where id=new.customer_id;   --insert o bang orders

    select sum(order_amount) into v_current_amount
    from orders
    where orders.customer_id=new.customer_id;

    if v_current_amount+new.order_amount>v_limit
    then raise exception E'Khach hang co id % khong du the tin dung:\nGioi han: %\nHien tai: %\nTien don: %',new.customer_id,v_limit,v_current_amount,new.order_amount;
    end if;
    return new;

end;
    $$ language plpgsql;

--tao trigger
create or replace trigger trg_check_credit
before insert on orders
for each row
execute function check_credit_limit();

--insert du lieu:
insert into customers (name, credit_limit) values
       ('Nguyễn Văn A (VIP)', 50000.00),
       ('Trần Thị B (Thường)', 10000.00),
       ('Lê Văn C (Mới)', 5000.00);
--xem:
select * from customers;
--insert va xem loi
insert into orders(customer_id, order_amount)
values (1,45000); --ok

insert into orders(customer_id, order_amount)
values (1,45000); --bao loi







