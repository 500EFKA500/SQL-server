DECLARE @DT datetime = GetDate()
DECLARE @DT2 datetime = SysDateTime()

SELECT Cast(@DT2 AS varchar),
		Try_Convert(varchar, @DT2, 1)