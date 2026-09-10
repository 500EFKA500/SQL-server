USE DB5
GO

CREATE TABLE products(
	[id] [int] Primary Key IDENTITY(1, 1) NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[coast] [real] NOT NULL,
	[id_user] [int] NOT NULL,
	[create_date] [datetime] NOT NULL,
	CONSTRAINT FK_idusres FOREIGN KEY (id_user)
		REFERENCES users(id) ON DELETE CASCADE
)
GO