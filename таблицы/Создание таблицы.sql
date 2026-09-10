USE DB3

CREATE TABLE users2(
	id int primary key identity(1, 1),
	first_name varchar(100) not null,
	email varchar(100) unique,
	age tinyint,
	balance real
)