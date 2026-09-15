/*
    Уроки 3–4. Создание базы и таблиц в SSMS.
    Скрипт можно запускать повторно: прежняя учебная база пересоздаётся.
*/

IF DB_ID(N'HomeworkLessons3_4') IS NOT NULL
BEGIN
    ALTER DATABASE HomeworkLessons3_4 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE HomeworkLessons3_4;
END;
GO

CREATE DATABASE HomeworkLessons3_4;
GO

USE HomeworkLessons3_4;
GO

CREATE TABLE dbo.Students
(
    StudentId INT IDENTITY(1, 1) CONSTRAINT PK_Students PRIMARY KEY,
    FullName NVARCHAR(150) NOT NULL,
    Email NVARCHAR(150) NULL,
    EnrollmentDate DATE NOT NULL CONSTRAINT DF_Students_EnrollmentDate DEFAULT CAST(GETDATE() AS DATE)
);

CREATE TABLE dbo.Subjects
(
    SubjectId INT IDENTITY(1, 1) CONSTRAINT PK_Subjects PRIMARY KEY,
    SubjectName NVARCHAR(100) NOT NULL CONSTRAINT UQ_Subjects_SubjectName UNIQUE,
    HoursCount INT NOT NULL CONSTRAINT CK_Subjects_HoursCount CHECK (HoursCount > 0)
);

CREATE TABLE dbo.StudentSubjects
(
    StudentId INT NOT NULL,
    SubjectId INT NOT NULL,
    EnrollmentStatus NVARCHAR(30) NOT NULL CONSTRAINT DF_StudentSubjects_Status DEFAULT N'Активен',
    CONSTRAINT PK_StudentSubjects PRIMARY KEY (StudentId, SubjectId),
    CONSTRAINT FK_StudentSubjects_Students FOREIGN KEY (StudentId) REFERENCES dbo.Students(StudentId),
    CONSTRAINT FK_StudentSubjects_Subjects FOREIGN KEY (SubjectId) REFERENCES dbo.Subjects(SubjectId)
);

INSERT INTO dbo.Students (FullName, Email)
VALUES
    (N'Иван Петров', N'ivan.petrov@example.com'),
    (N'Анна Смирнова', N'anna.smirnova@example.com');

INSERT INTO dbo.Subjects (SubjectName, HoursCount)
VALUES
    (N'MS SQL Server', 72),
    (N'Программирование', 108);

INSERT INTO dbo.StudentSubjects (StudentId, SubjectId)
VALUES
    (1, 1),
    (1, 2),
    (2, 1);

SELECT * FROM dbo.Students;
SELECT * FROM dbo.Subjects;
SELECT * FROM dbo.StudentSubjects;
