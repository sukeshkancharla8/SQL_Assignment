create database restaurant;
use restaurant;
#customer
drop table if exists customer;
create table customer (
id int auto_increment primary key,
name varchar(30) 
);

#order
drop table if exists order_customer;
create table order_customer (
id int auto_increment, 
customer_id int, 
time_ordered datetime,
isServed boolean,
primary key(id),
foreign key(customer_id) references customer(id)
);


#order_items
drop table if exists order_items;
create table order_items (
order_id int,
item_id int,
quantity int,
primary key(order_id,item_id),
foreign key(order_id) references order_customer(id)
);

#menu
drop table if exists menu;
create table menu (
item_id int auto_increment,
name varchar(30) unique,
price decimal(5,2),
primary key(item_id)	
);


#customer_insertion
insert into customer (name) values ('sachin');
insert into customer (name) values ('rohit');
insert into customer (name) values ('sehwag');
insert into customer (name) values ('dravid');

select * from customer;
#order_insertion
insert into order_customer (customer_id,time_ordered,isServed) values (2,NOW(),false);
insert into order_customer (customer_id,time_ordered,isServed) values (3,NOW(),false);
insert into order_customer (customer_id,time_ordered,isServed) values (4,NOW(),false);
insert into order_customer (customer_id,time_ordered,isServed) values (2,NOW(),false);
insert into order_customer (customer_id,time_ordered,isServed) values (1,NOW(),false);
insert into order_customer (customer_id,time_ordered,isServed) values (1,NOW(),false);
insert into order_customer (customer_id,time_ordered,isServed) values (4,NOW(),false);
insert into order_customer (customer_id,time_ordered,isServed) values (2,NOW(),false);
insert into order_customer (customer_id,time_ordered,isServed) values (2,NOW(),false);

select * from order_customer;

#menu_insertion
insert into menu (name,price) values ('idly',20);
insert into menu (name,price) values ('dosa',30);
insert into menu (name,price) values ('roti',10);
insert into menu (name,price) values ('rice',40);
insert into menu (name,price) values ('Dal',30);
insert into menu (name,price) values ('biryani',100);

select * from menu;
#order_items insertion
insert into order_items (order_id,item_id,quantity) values (1,1,2);
insert into order_items (order_id,item_id,quantity) values (1,5,3);
insert into order_items (order_id,item_id,quantity) values (1,6,1);
insert into order_items (order_id,item_id,quantity) values (2,4,2);
insert into order_items (order_id,item_id,quantity) values (2,3,4);
insert into order_items (order_id,item_id,quantity) values (3,2,2);
insert into order_items (order_id,item_id,quantity) values (4,4,4);
insert into order_items (order_id,item_id,quantity) values (5,6,5);
insert into order_items (order_id,item_id,quantity) values (6,3,7);
insert into order_items (order_id,item_id,quantity) values (7,2,2);
insert into order_items (order_id,item_id,quantity) values (8,4,3);
insert into order_items (order_id,item_id,quantity) values (9,1,4);


select * from order_items;


#select * from customer where id = (select id from order_customer group by id having 


create view vw_customersnapshot as select * from customer where id = (SELECT customer_id FROM order_customer
GROUP BY customer_id
ORDER BY COUNT(customer_id) DESC LIMIT 1);

select * from vw_customersnapshot;

create view vw_ordersnapshot as select * from menu where item_id = (SELECT item_id FROM order_items
GROUP BY item_id
ORDER BY COUNT(item_id) DESC LIMIT 1);

select * from vw_ordersnapshot;

DROP FUNCTION IF EXISTS FUNC_getordertimeelapsed;
DELIMITER $$
CREATE FUNCTION FUNC_getordertimeelapsed(order_id int) RETURNS int
BEGIN
	DECLARE time_elapsed int;
    set time_elapsed = (select timestampdiff(second,(select time_ordered from order_customer where id = order_id order by time_ordered desc limit 1),now()));
    RETURN time_elapsed;
END$$
DELIMITER ;
SELECT FUNC_getordertimeelapsed(3) AS time_elapsed;
select timestampdiff(day,(select time_ordered from order_customer where id = 3 limit 1),now()) as time_elapsed;
use restaurant;



#getting order details
DROP PROCEDURE IF EXISTS SP_getorder;
DELIMITER $$
CREATE PROCEDURE SP_getorder(in customer int)
BEGIN
	select o_i.order_id,m.name,o_i.quantity from order_items as o_i inner join menu as m on o_i.item_id = m.item_id where o_i.order_id = (select id from order_customer where customer_id = customer order by time_ordered desc limit 1);
	#select * from order_items where order_id = (select id from order_customer where customer_id = customer order by time_ordered desc limit 1);
END$$
DELIMITER ;
CALL SP_getorder(2);

#bill_amnt
DROP PROCEDURE IF EXISTS SP_getbill;
DELIMITER $$
CREATE PROCEDURE SP_getbill(in order_id int,out bill_amount int)
BEGIN
	set bill_amount = (select sum(o_i.quantity * m.price) from order_items as o_i join menu as m on o_i.item_id = m.item_id where o_i.order_id = order_id);
	#select * from order_items as o_i inner join menu as m on o_i.order_id = m.item_id where o_i.order_id = (select id from order_customer where customer_id = customer order by time_ordered desc limit 1);
END$$
DELIMITER ;
CALL SP_getbill(4,@bill);
select @bill;