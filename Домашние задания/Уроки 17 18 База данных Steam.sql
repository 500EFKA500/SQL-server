-- Уроки 17-18. Модель базы данных Steam: 10 сущностей и связи 1:1, 1:M, M:N.
CREATE DATABASE Homework17_18_Steam;
GO
USE Homework17_18_Steam;
GO

CREATE TABLE dbo.Users (UserId INT IDENTITY PRIMARY KEY, Login NVARCHAR(50) NOT NULL UNIQUE, Email NVARCHAR(120) NOT NULL UNIQUE, RegisteredAt DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE));
CREATE TABLE dbo.Profiles (UserId INT PRIMARY KEY, DisplayName NVARCHAR(80) NOT NULL, Country NVARCHAR(60) NOT NULL, CONSTRAINT FK_Profiles_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId));
CREATE TABLE dbo.Developers (DeveloperId INT IDENTITY PRIMARY KEY, Name NVARCHAR(100) NOT NULL UNIQUE, FoundedYear SMALLINT CHECK (FoundedYear BETWEEN 1970 AND 2026));
CREATE TABLE dbo.Publishers (PublisherId INT IDENTITY PRIMARY KEY, Name NVARCHAR(100) NOT NULL UNIQUE, Country NVARCHAR(60) NOT NULL);
CREATE TABLE dbo.Genres (GenreId INT IDENTITY PRIMARY KEY, Name NVARCHAR(60) NOT NULL UNIQUE);
CREATE TABLE dbo.Games (GameId INT IDENTITY PRIMARY KEY, DeveloperId INT NOT NULL, PublisherId INT NOT NULL, Title NVARCHAR(120) NOT NULL, Price DECIMAL(10,2) NOT NULL CHECK (Price >= 0), ReleaseDate DATE NOT NULL, CONSTRAINT FK_Games_Developers FOREIGN KEY (DeveloperId) REFERENCES dbo.Developers(DeveloperId), CONSTRAINT FK_Games_Publishers FOREIGN KEY (PublisherId) REFERENCES dbo.Publishers(PublisherId));
CREATE TABLE dbo.GameGenres (GameId INT NOT NULL, GenreId INT NOT NULL, PRIMARY KEY(GameId, GenreId), CONSTRAINT FK_GameGenres_Games FOREIGN KEY(GameId) REFERENCES dbo.Games(GameId), CONSTRAINT FK_GameGenres_Genres FOREIGN KEY(GenreId) REFERENCES dbo.Genres(GenreId));
CREATE TABLE dbo.Libraries (LibraryId INT IDENTITY PRIMARY KEY, UserId INT NOT NULL, GameId INT NOT NULL, PurchasedAt DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE), PlayHours DECIMAL(8,1) NOT NULL DEFAULT 0 CHECK (PlayHours >= 0), CONSTRAINT UQ_Libraries_User_Game UNIQUE(UserId, GameId), CONSTRAINT FK_Libraries_Users FOREIGN KEY(UserId) REFERENCES dbo.Users(UserId), CONSTRAINT FK_Libraries_Games FOREIGN KEY(GameId) REFERENCES dbo.Games(GameId));
CREATE TABLE dbo.Achievements (AchievementId INT IDENTITY PRIMARY KEY, GameId INT NOT NULL, Title NVARCHAR(100) NOT NULL, Points SMALLINT NOT NULL DEFAULT 10 CHECK (Points BETWEEN 1 AND 100), CONSTRAINT FK_Achievements_Games FOREIGN KEY(GameId) REFERENCES dbo.Games(GameId));
CREATE TABLE dbo.UserAchievements (UserId INT NOT NULL, AchievementId INT NOT NULL, UnlockedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(), PRIMARY KEY(UserId, AchievementId), CONSTRAINT FK_UserAchievements_Users FOREIGN KEY(UserId) REFERENCES dbo.Users(UserId), CONSTRAINT FK_UserAchievements_Achievements FOREIGN KEY(AchievementId) REFERENCES dbo.Achievements(AchievementId));
GO

INSERT dbo.Users(Login,Email) VALUES (N'vlad',N'vlad@steam.local'),(N'anna',N'anna@steam.local'),(N'max',N'max@steam.local'),(N'kate',N'kate@steam.local'),(N'igor',N'igor@steam.local');
INSERT dbo.Profiles(UserId,DisplayName,Country) VALUES (1,N'Vlad',N'Россия'),(2,N'Anna',N'Россия'),(3,N'Max',N'Казахстан'),(4,N'Kate',N'Беларусь'),(5,N'Igor',N'Россия');
INSERT dbo.Developers(Name,FoundedYear) VALUES (N'Valve',1996),(N'CD Projekt',1994),(N'Larian',1996),(N'Klei',2005),(N'Supergiant',2009);
INSERT dbo.Publishers(Name,Country) VALUES (N'Valve',N'США'),(N'CD Projekt',N'Польша'),(N'Larian Studios',N'Бельгия'),(N'Klei Entertainment',N'Канада'),(N'Supergiant Games',N'США');
INSERT dbo.Genres(Name) VALUES (N'RPG'),(N'Шутер'),(N'Стратегия'),(N'Приключение'),(N'Инди');
INSERT dbo.Games(DeveloperId,PublisherId,Title,Price,ReleaseDate) VALUES (1,1,N'Portal 2',699,'2011-04-19'),(2,2,N'Witcher 3',1299,'2015-05-19'),(3,3,N'Baldurs Gate 3',1999,'2023-08-03'),(4,4,N'Dont Starve',499,'2013-04-23'),(5,5,N'Hades',880,'2020-09-17');
INSERT dbo.GameGenres VALUES (1,4),(1,2),(2,1),(3,1),(4,3),(4,5),(5,1),(5,5);
INSERT dbo.Libraries(UserId,GameId,PlayHours) VALUES (1,1,25),(2,2,100),(3,3,80),(4,4,42),(5,5,56);
INSERT dbo.Achievements(GameId,Title,Points) VALUES (1,N'Первый портал',10),(2,N'Охотник на чудовищ',20),(3,N'Победа в бою',15),(4,N'Первая зима',10),(5,N'Побег из Аида',30);
INSERT dbo.UserAchievements(UserId,AchievementId) VALUES (1,1),(2,2),(3,3),(4,4),(5,5);
GO

SELECT g.Title, d.Name AS Developer, p.Name AS Publisher, g.Price FROM dbo.Games g JOIN dbo.Developers d ON d.DeveloperId=g.DeveloperId JOIN dbo.Publishers p ON p.PublisherId=g.PublisherId;
SELECT u.Login, g.Title, l.PlayHours FROM dbo.Libraries l JOIN dbo.Users u ON u.UserId=l.UserId JOIN dbo.Games g ON g.GameId=l.GameId;
SELECT g.Title, STRING_AGG(ge.Name, N', ') AS Genres FROM dbo.Games g JOIN dbo.GameGenres gg ON gg.GameId=g.GameId JOIN dbo.Genres ge ON ge.GenreId=gg.GenreId GROUP BY g.Title;
GO
