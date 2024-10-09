# schemas_of_coffee-analysis
---monday_coffee_analysis 
---schemas 
drop table if exists city;--- parent_table
drop table if exists customers; --- parent_table
drop table if exists products; --- child_table
drop table if exists sales; --- child_table

create table city(city_id int primary key,
	city_name varchar(30),
	population bigint,
	estimated_rent int,
	city_rank int
);

create table customers(customer_id int primary key,
	customer_name varchar(20),
	city_id int, --- foreign_key 
	constraint fk_city foreign key(city_id) references city(city_id)
); 

create table products(product_id int primary key,
	product_name varchar(50),
	price int 
); 

create table sales(sale_id int,
	sale_date date,
	product_id int,--- foreign_key
	customer_id	int, --- foreign_key
	total int,	
	rating int, 
constraint fk_products foreign key(product_id) references products(product_id),
constraint fk_sales foreign key(customer_id) references customers(customer_id)
);
--- end of schemas
