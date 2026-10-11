# Каталог товаров: ADO.NET, Dapper, Repository, MVC

Продолжение ранее сданного `../ADO.NET`, подготовленное с помощью ИИ.
Пользователь разрешил выбрать расширение и развить приложение. Детального ТЗ
в шести карточках нет, поэтому выбран учебный консольный каталог товаров.

## Соответствие шести темам

1. **Создание приложения ADO.NET**: CLI с просмотром, поиском и CRUD.
2. **Расширение приложения**: экспорт CSV без перезаписи файлов, экранирование
   кавычек и защита от формул, постраничное чтение.
3. **Слоистая архитектура и MVC**: Product (Model), ConsoleView (View),
   CatalogController (Controller); CatalogService - прикладной слой,
   SqlProductRepository - слой доступа к данным. Это консольная трактовка MVC,
   не ASP.NET MVC и не полноценный веб-интерфейс.
4. **Repository и Model**: IProductRepository, SQL-реализация и тестовая реализация.
5. **Оптимизация с Dapper** (в журнале «Drapper»): маппинг вместо ручного чтения
   SqlDataReader, параметры, ограниченная страница 1-100 строк, детерминированный
   ORDER BY, using и тайм-аут запросов. Ускорение не измерялось; Dapper не объявляется
   автоматически быстрее любого другого решения.
6. **Методы Dapper**: Query, QuerySingle, QuerySingleOrDefault, Execute, ExecuteScalar.

## Запуск

Visual Studio с .NET Framework 4.8 Developer Pack: открыть csproj, восстановить
NuGet Dapper 2.1.66 и собрать. Схема базы прежняя: `../ADO.NET/setup.sql`.
Строка подключения задаётся только переменной `ACADEMY_SQL_CONNECTION`;
пароли не сохраняются в репозитории. Пример для локального тестового сервера:
`Server=localhost;Database=AcademyAdo;Integrated Security=True;Encrypt=True;TrustServerCertificate=True`.
TrustServerCertificate годится только для локальной учебной среды; для рабочей
среды нужен проверяемый сертификат. Сначала создать базу по setup.sql.

```
AcademyDapper.exe --self-test
AcademyDapper.exe --help
AcademyDapper.exe list 1 20
AcademyDapper.exe add "Monitor" 12000.00
AcademyDapper.exe find 1
AcademyDapper.exe update 1 "Monitor" 12500.00
AcademyDapper.exe count
AcademyDapper.exe export NEW-catalog.csv
AcademyDapper.exe delete 1 --confirm
```

Без команды выполняется только SELECT. DELETE требует `--confirm`.
Не запускайте изменяющие команды на чужой/рабочей базе. Экспорт при конкурентных
изменениях не гарантирует консистентный снимок; для него нужна отдельная транзакция.

## Проверка

Компиляция настоящей DLL Dapper и offline self-test выполнены локально.
Тесты проверяют CRUD, валидацию, страницы 205 строк, CSV, контроллер и параметры.
**Реальный SQL Server не подключался:** интеграционный CRUD и маппинг на живой
базе не подтверждены. In-memory тесты их не заменяют.
Исходники и инструкции предоставляются для изучения; авторство ИИ не скрывается.

Документация Dapper: https://github.com/DapperLib/Dapper
