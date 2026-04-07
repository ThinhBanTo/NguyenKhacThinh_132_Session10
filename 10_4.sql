--tao table
create table products(
    id serial primary key ,
    name varchar,
    stock int
);

create table orders(
    id serial primary key ,
    product_id int ,
    quantity int
);
--INSERT du lieu:
INSERT into products(name, stock)
values ('Iphone 11',100),
       ('Iphone 12',200),
       ('Iphone 13',250);

select * from products;
-------------------------
--1+2:
--INSERT(BEFORE+AFTER)
create or replace function INSERT_order()
returns trigger as
$$
    declare
        v_stock int;
    begin
        if (tg_op='INSERT' and  tg_when='BEFORE')
            then
            select products.stock into v_stock
            from products
            where id=new.product_id;

            if v_stock<new.quantity then raise exception E'Khong du hang!\nKho con: %\nCan: %',v_stock,new.quantity;
            end if;
            return new;

        elseif (tg_op='INSERT' and tg_when='AFTER') then
            UPDATE products
            set stock=stock-new.quantity
            where id=new.product_id;

            return null;

        end if;
    end;
    $$ language plpgsql;

create or replace trigger trg_BEFORE_INSERT
BEFORE INSERT on orders
for each row
execute function INSERT_order();

create or replace trigger trg_AFTER_INSERT
AFTER INSERT on orders
for each row
execute function INSERT_order();

--UPDATE
create or replace function UPDATE_orders()
returns trigger as
    $$
    declare
        v_stock int;
    begin
        if (tg_op='UPDATE' and tg_when='BEFORE') then
            select stock into v_stock
            from products
            where id=new.product_id;

            if v_stock+new.quantity-old.quantity<0 then raise exception E'So luong trong kho khong the am!\nSo luong don hang chi co the <= %',old.quantity+v_stock;
            end if;
            return new;
        elseif (tg_op='UPDATE' and tg_when='AFTER') then
                UPDATE products
                set stock=stock+old.quantity-new.quantity
                where id=new.product_id;

                return null;
        end if;
    end;
    $$ language plpgsql;

create or replace trigger trg_BEFORE_UPDATE
BEFORE UPDATE on orders
for each row
execute function UPDATE_orders();

create or replace trigger trg_AFTER_UPDATE
    AFTER UPDATE on orders
    for each row
execute function UPDATE_orders();
--DELETE
create or replace function DELETE_orders()
returns trigger as
$$
    begin
        UPDATE products
        set stock=stock+old.quantity
        where id=old.product_id;

        return null;
    end;
    $$ language plpgsql;

create or replace trigger trg_DELETE
AFTER DELETE on orders
for each row
execute function DELETE_orders();

--3
--INSERT:
INSERT into orders(product_id, quantity)
values (1,200); --bao loi INSERT BEFORE

INSERT into orders(product_id, quantity)
values (1,50); --ok

select * from products;
--UPDATE:
UPDATE orders
SET quantity=200 --bao loi before update
where id=1;

UPDATE orders
SET quantity=100 --ok
where id=1;

select * from orders;
select * from products;

--delete:
delete
from orders
where id=4;

select * from products;


