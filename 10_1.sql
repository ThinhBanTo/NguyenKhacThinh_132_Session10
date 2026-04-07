--tao table
create table products(
    id serial primary key ,
    name varchar(50),
    price numeric,
    last_modified timestamp default now()
);
--tao func update_last_modified
create or replace function update_last_modified()
returns trigger as $$
begin
    new.last_modified=now();
    return new;
end;
    $$ language plpgsql;
--tao trigger de goi function kia truoc khi update de sua last_modified
create or replace trigger trg_update_last_modified
before update on products
for each row
execute function update_last_modified();

--chen du lieu:
insert into products(name, price)
values ('Iphone 15 Pro Max',1200),
       ('Samsung Galaxy S24 Ultra',1150),
       ('Macbook Air M3',1099),
       ('Sony Headphones',350);
--xem
select * from products;
--update thu:
update products
set price=1250
where id=1;
--xem lai (ok)
select * from products;





