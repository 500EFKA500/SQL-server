USE DB3

INSERT INTO users2(first_name, email, age, balance)
VALUES (N'Oleg', 'pedgro@google.gmail', 19, 0),
		(N'Alice', 'ahlice@google.gmail', 18, 0),
		(N'Petr', 'petdr@google.gmail', 20, 0),
		(N'Issac', 'isshac@google.gmail', 49, 0),
		(N'Geogre', 'gveogre@google.gmail', 18, 0),
		(N'Ivan', 'ivanx@google.gmail', 18, 0)
SELECT *
FROM users2