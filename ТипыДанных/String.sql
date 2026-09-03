DECLARE @char char(5) = 'Олег'                                                                                                                                        D0) = N'M??ritetty? IPv6-osoitetta ei tueta. Kuuntelussa tuetaan vain osoitteita, jotka ovat numeerisessa, kanonisessa muodossa.'
DECLARE @nchar nchar(10) = 'M??ritetty? IPv6-osoitetta ei tueta. Kuuntelussa tuetaan vain osoitteita, jotka ovat numeerisessa, kanonisessa muodossa.'
DECLARE @varchar varchar(5000) = 'большой Олег'

DECLARE @vmax varchar(MAX) = 'ddd1'

SELECT @vmax
