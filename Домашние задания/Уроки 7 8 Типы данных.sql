-- Уроки 7-8. Дополнительные типы данных и параметры.
-- Выполнять в SQL Server Management Studio.

DECLARE @CurrentTime TIME(0) = CAST(SYSDATETIME() AS TIME(0));
DECLARE @BirthDate DATE = '2000-10-04';
DECLARE @CreatedAt DATETIME = GETDATE();
DECLARE @PreciseCreatedAt DATETIME2(7) = SYSDATETIME();
DECLARE @LocalCreatedAt DATETIMEOFFSET(7) = SYSDATETIMEOFFSET();

SELECT
    @CurrentTime AS CurrentTime,
    @BirthDate AS BirthDate,
    @CreatedAt AS CreatedAt,
    @PreciseCreatedAt AS PreciseCreatedAt,
    @LocalCreatedAt AS LocalCreatedAt;

-- CAST и CONVERT с разными стилями отображения даты.
SELECT
    CAST(@CreatedAt AS DATE) AS DateViaCast,
    CAST(@CreatedAt AS TIME(0)) AS TimeViaCast,
    CONVERT(VARCHAR(10), @CreatedAt, 104) AS RussianDate,
    CONVERT(VARCHAR(19), @CreatedAt, 120) AS IsoDateTime,
    CONVERT(VARCHAR(30), @LocalCreatedAt, 127) AS IsoDateTimeOffset;
