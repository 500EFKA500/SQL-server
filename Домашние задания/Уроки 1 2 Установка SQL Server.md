# Уроки 1–2. Подготовка среды MS SQL Server

## Используемые компоненты

- Microsoft SQL Server Database Engine;
- SQL Server Management Studio (SSMS).

## Проверка после подключения

В SSMS нужно подключиться к локальному экземпляру SQL Server и выполнить:

```sql
SELECT
    @@SERVERNAME AS ServerName,
    @@VERSION AS SqlServerVersion,
    DB_NAME() AS CurrentDatabase;
```

Запрос подтверждает доступ к экземпляру SQL Server и выводит его версию.

## Настройка подключения

1. Открыть SSMS.
2. В окне подключения выбрать `Database Engine`.
3. Указать имя локального экземпляра SQL Server.
4. Использовать Windows Authentication.
5. После подключения открыть New Query и выполнить проверочный запрос выше.
