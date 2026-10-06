using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace AcademyAdo
{
    public sealed class Product
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public decimal Price { get; set; }
    }

    public sealed class ProductRepository
    {
        private readonly string connectionString;
        public ProductRepository(string connectionString)
        {
            if (String.IsNullOrWhiteSpace(connectionString))
                throw new ArgumentException("Connection string is required.");
            this.connectionString = new SqlConnectionStringBuilder(connectionString).ConnectionString;
        }

        public void CheckConnection()
        {
            using (var connection = new SqlConnection(connectionString))
            {
                connection.Open();
                Console.WriteLine("Connected to " + connection.Database);
            }
        }

        public List<Product> GetAll()
        {
            var products = new List<Product>();
            using (var connection = new SqlConnection(connectionString))
            using (var command = new SqlCommand("SELECT Id, Name, Price FROM dbo.Products ORDER BY Id", connection))
            {
                connection.Open();
                using (var reader = command.ExecuteReader())
                    while (reader.Read())
                        products.Add(new Product { Id = reader.GetInt32(0), Name = reader.GetString(1), Price = reader.GetDecimal(2) });
            }
            return products;
        }

        public static SqlCommand CreateInsertCommand(SqlConnection connection, string name, decimal price)
        {
            Validate(name, price);
            var command = new SqlCommand("INSERT INTO dbo.Products(Name, Price) OUTPUT INSERTED.Id VALUES(@name, @price)", connection);
            command.Parameters.Add("@name", SqlDbType.NVarChar, 100).Value = name;
            var parameter = command.Parameters.Add("@price", SqlDbType.Decimal);
            parameter.Precision = 12;
            parameter.Scale = 2;
            parameter.Value = price;
            return command;
        }

        public int Add(string name, decimal price)
        {
            using (var connection = new SqlConnection(connectionString))
            using (var command = CreateInsertCommand(connection, name, price))
            {
                connection.Open();
                return Convert.ToInt32(command.ExecuteScalar());
            }
        }

        public bool Update(int id, string name, decimal price)
        {
            Validate(name, price);
            if (id <= 0) throw new ArgumentOutOfRangeException("id");
            using (var connection = new SqlConnection(connectionString))
            using (var command = new SqlCommand("UPDATE dbo.Products SET Name=@name, Price=@price WHERE Id=@id", connection))
            {
                command.Parameters.Add("@id", SqlDbType.Int).Value = id;
                command.Parameters.Add("@name", SqlDbType.NVarChar, 100).Value = name;
                var parameter = command.Parameters.Add("@price", SqlDbType.Decimal);
                parameter.Precision = 12;
                parameter.Scale = 2;
                parameter.Value = price;
                connection.Open();
                return command.ExecuteNonQuery() == 1;
            }
        }

        public bool Delete(int id)
        {
            if (id <= 0) throw new ArgumentOutOfRangeException("id");
            using (var connection = new SqlConnection(connectionString))
            using (var command = new SqlCommand("DELETE FROM dbo.Products WHERE Id=@id", connection))
            {
                command.Parameters.Add("@id", SqlDbType.Int).Value = id;
                connection.Open();
                return command.ExecuteNonQuery() == 1;
            }
        }

        private static void Validate(string name, decimal price)
        {
            if (String.IsNullOrWhiteSpace(name) || name.Length > 100)
                throw new ArgumentException("Name must contain 1-100 characters.");
            if (price <= 0 || price > 9999999999.99m || Decimal.Round(price, 2) != price)
                throw new ArgumentOutOfRangeException("price", "Price must be positive, fit decimal(12,2), and have at most two decimal places.");
        }
    }

    public static class Program
    {
        public static int Main(string[] args)
        {
            try
            {
                if (args.Length == 1 && args[0] == "--self-test")
                {
                    using (var connection = new SqlConnection())
                    using (var command = ProductRepository.CreateInsertCommand(connection, "O'Brien'; DROP TABLE Products;--", 12.34m))
                    {
                        if (command.CommandText.Contains("O'Brien") || command.Parameters.Count != 2 || command.Parameters["@price"].Scale != 2)
                            throw new Exception("Parameter isolation failed.");
                    }
                    bool rejected = false;
                    try { ProductRepository.CreateInsertCommand(null, "", -1); }
                    catch (ArgumentException) { rejected = true; }
                    if (!rejected) throw new Exception("Invalid input was accepted.");
                    Console.WriteLine("PASS: parameter isolation and input validation. No database connection attempted.");
                    return 0;
                }
                var cs = Environment.GetEnvironmentVariable("ACADEMY_SQL_CONNECTION");
                if (String.IsNullOrWhiteSpace(cs))
                {
                    Console.WriteLine("Set ACADEMY_SQL_CONNECTION. See README.md. Use --self-test for offline verification.");
                    return 2;
                }
                var repository = new ProductRepository(cs);
                repository.CheckConnection();
                // Safe default: only list records. CRUD methods are available in ProductRepository.
                foreach (var product in repository.GetAll())
                    Console.WriteLine("{0}: {1}, {2:F2}", product.Id, product.Name, product.Price);
                return 0;
            }
            catch (SqlException ex) { Console.Error.WriteLine("SQL connection/query failed, error " + ex.Number); return 1; }
            catch (ArgumentException ex) { Console.Error.WriteLine(ex.Message); return 1; }
        }
    }
}
