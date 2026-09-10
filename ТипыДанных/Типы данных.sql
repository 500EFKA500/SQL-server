DECLARE @DT datetime = GetDate()
DECLARE @D date = '2000-10-04'
DECLARE @T time(0) = GetDate()
DECLARE @DT2 datetime2 = SysDateTime()
DECLARE @DTO datetime = 

SET DATEFORMAT mdy;
SELECT @DTO

SET DATEFORMAT 