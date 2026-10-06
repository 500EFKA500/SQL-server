# ADO.NET: подключение к MS SQL Server и методы запросов

Учебный проект подготовлен с помощью ИИ по четырём темам карточек от 01.10.2026.
В карточках нет отдельных условий или вложений, поэтому здесь показана практика по указанным темам.

| Тема | Реализация |
| --- | --- |
| Введение в работу на стороне сервера | setup.sql: отдельная БД AcademyAdo, таблица и ограничения |
| Создание подключения к MS SQL Server | CheckConnection: SqlConnection, Open, освобождение через using |
| Подключение в Visual Studio | AcademyAdo.csproj, инструкция запуска ниже |
| Методы с запросами | ProductRepository: GetAll, Add, Update, Delete |

## Запуск в Visual Studio

1. Установить workload «Разработка классических приложений .NET» и targeting pack .NET Framework 4.8.
2. Открыть AcademyAdo.csproj и выполнить setup.sql в SSMS на своём SQL Server.
3. Задать переменную среды ACADEMY_SQL_CONNECTION с адресом своего сервера, например:
   `Server=localhost;Database=AcademyAdo;Integrated Security=True;Encrypt=True;TrustServerCertificate=False;Connect Timeout=5;`
   SQL Server должен иметь доверенный сертификат. Для локального учебного сервера можно явно выбрать
   `TrustServerCertificate=True`, если сертификат самоподписанный. Это не настройка для удалённого production-сервера.
4. Перезапустить Visual Studio после изменения переменной среды, собрать и запустить проект.
5. Программа проверит подключение и выведет товары. По умолчанию она ничего не изменяет.

Все значения для записей передаются SqlParameter с явными типами. Строка подключения и пароли
не записываются в репозиторий. ExecuteReader читает строки, ExecuteScalar возвращает новый Id,
ExecuteNonQuery используется для обновления и удаления. Проверяется ввод и освобождаются соединения.

## Проверка

Исходник компилируется штатным C#-компилятором .NET Framework.
`AcademyAdo.exe --self-test` проверяет изоляцию параметров и отклонение недопустимого ввода без SQL Server.
На компьютере не подтверждено наличие работающего SQL Server: реальные CRUD-запросы требуется
выполнить после настройки подключения. Результаты выполнения SQL не выдумывались.

Документация: https://learn.microsoft.com/en-us/dotnet/api/system.data.sqlclient.sqlconnection
и https://learn.microsoft.com/en-us/dotnet/api/system.data.sqlclient.sqlcommand.parameters
