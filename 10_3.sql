--1: tao bang
create table employees(
    id serial primary key ,
    name varchar(50),
    position varchar(50),
    salary numeric(10,2)
);

create table employees_log(
    employee_id int,
    operation varchar(6),
    old_date jsonb,
    new_data jsonb,
    change_time timestamp default now()
);

--2+3:
--insert
create or replace function insert_log()
returns trigger as $$
   begin
       insert into employees_log(employee_id, operation, old_date, new_data)
       values (new.id,'INSERT',null,to_json(new));
       return null;
   end;
    $$ language plpgsql;

create or replace trigger trg_insert_log
after insert on employees
for each row
execute function insert_log();

--update:
create or replace function update_log()
returns trigger as $$
begin
    insert into employees_log(employee_id, operation, old_date, new_data)
    values (new.id,'UPDATE',to_json(old),to_json(new));
    return null;
end;
    $$ language plpgsql;

create or replace trigger trg_update_log
after update on employees
for each row
execute function update_log();

--delete:
create or replace function delete_log()
returns trigger as $$
begin
    insert into employees_log(employee_id, operation, old_date, new_data)
    values (old.id,'DELETE',to_json(old),null);
    return null;
end;
    $$ language plpgsql;

create or replace trigger trg_delete_log
after delete on employees
for each row
execute function delete_log();

--4
--insert
insert into employees(name, position, salary)
values ('Thinh1','Giam doc',10000);

select * from employees_log;
--update:
update employees
set position='Nhan vien IT'
where id=2;

select * from employees_log;
--delete
delete
from employees
where id=2;

select * from employees_log;



