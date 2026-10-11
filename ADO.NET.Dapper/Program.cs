using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Linq;
using Dapper;

// AI-assisted educational continuation of ADO.NET/Program.cs.
namespace AcademyDapper
{
    public sealed class Product
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public decimal Price { get; set; }
    }
    public interface IProductRepository
    {
        IReadOnlyList<Product> List(int page, int size);
        Product Find(int id);
        int Add(string name, decimal price);
        bool Update(int id, string name, decimal price);
        bool Delete(int id);
        int Count();
    }
    public static class Rules
    {
        public static void Product(string name, decimal price)
        {
            if (String.IsNullOrWhiteSpace(name) || name.Trim().Length > 100)
                throw new ArgumentException("Name must contain 1-100 characters.");
            if (price <= 0 || price > 9999999999.99m || Decimal.Round(price, 2) != price)
                throw new ArgumentException("Price must fit decimal(12,2), be positive, and have at most 2 decimal places.");
        }
        public static void Page(int page, int size)
        {
            if (page < 1 || page > 1000000 || size < 1 || size > 100)
                throw new ArgumentException("Page: 1-1000000; size: 1-100.");
        }
        public static void Id(int id) { if (id < 1) throw new ArgumentException("Positive id required."); }
    }
    // Infrastructure layer: connection-per-operation, parameterized Dapper queries.
    public sealed class SqlProductRepository : IProductRepository
    {
        private readonly string connectionString;
        public SqlProductRepository(string connectionString)
        {
            if (String.IsNullOrWhiteSpace(connectionString)) throw new ArgumentException("Connection string required.");
            this.connectionString = new SqlConnectionStringBuilder(connectionString).ConnectionString;
        }
        private SqlConnection Open() { var c = new SqlConnection(connectionString); try { c.Open(); return c; } catch { c.Dispose(); throw; } }
        public IReadOnlyList<Product> List(int page, int size)
        {
            Rules.Page(page, size);
            using (var c = Open())
                return c.Query<Product>("SELECT Id,Name,Price FROM dbo.Products ORDER BY Id OFFSET @Offset ROWS FETCH NEXT @Size ROWS ONLY", new { Offset = (page - 1) * size, Size = size }, commandTimeout: 30).ToList();
        }
        public Product Find(int id)
        {
            Rules.Id(id);
            using (var c = Open()) return c.QuerySingleOrDefault<Product>("SELECT Id,Name,Price FROM dbo.Products WHERE Id=@Id", new { Id = id }, commandTimeout: 30);
        }
        public int Add(string name, decimal price)
        {
            Rules.Product(name, price);
            using (var c = Open()) return c.QuerySingle<int>("INSERT dbo.Products(Name,Price) OUTPUT INSERTED.Id VALUES(@Name,@Price)", new { Name = name.Trim(), Price = price }, commandTimeout: 30);
        }
        public bool Update(int id, string name, decimal price)
        {
            Rules.Id(id); Rules.Product(name, price);
            using (var c = Open()) return c.Execute("UPDATE dbo.Products SET Name=@Name,Price=@Price WHERE Id=@Id", new { Id = id, Name = name.Trim(), Price = price }, commandTimeout: 30) == 1;
        }
        public bool Delete(int id)
        {
            Rules.Id(id);
            using (var c = Open()) return c.Execute("DELETE dbo.Products WHERE Id=@Id", new { Id = id }, commandTimeout: 30) == 1;
        }
        public int Count() { using (var c = Open()) return c.ExecuteScalar<int>("SELECT COUNT(*) FROM dbo.Products", commandTimeout: 30); }
    }
    // Application layer. Extension: paginated CSV export, without loading entire DB.
    public sealed class CatalogService
    {
        private readonly IProductRepository repo;
        public CatalogService(IProductRepository repo) { this.repo = repo; }
        public IReadOnlyList<Product> List(int page, int size) { return repo.List(page, size); }
        public Product Find(int id) { Rules.Id(id); return repo.Find(id); }
        public int Add(string name, decimal price) { Rules.Product(name, price); return repo.Add(name.Trim(), price); }
        public bool Update(int id, string name, decimal price) { Rules.Id(id); Rules.Product(name, price); return repo.Update(id, name.Trim(), price); }
        public bool Delete(int id) { Rules.Id(id); return repo.Delete(id); }
        public int Count() { return repo.Count(); }
        public static string CsvCell(string value)
        {
            value = value ?? "";
            if (value.Length > 0 && "=+-@\t\r\n".Contains(value[0])) value = "'" + value;
            return "\"" + value.Replace("\"", "\"\"") + "\"";
        }
        public void Export(TextWriter writer)
        {
            writer.WriteLine("Id,Name,Price");
            for (int page = 1; ; page++)
            {
                var batch = repo.List(page, 100);
                foreach (var p in batch) writer.WriteLine(p.Id + "," + CsvCell(p.Name) + "," + p.Price.ToString("0.00", CultureInfo.InvariantCulture));
                if (batch.Count < 100) break;
            }
        }
    }
    // View has no SQL; controller interprets commands; Product is the Model.
    public sealed class ConsoleView
    {
        private readonly TextWriter output;
        public ConsoleView(TextWriter output) { this.output = output; }
        public void Text(string value) { output.WriteLine(value); }
        public void Products(IEnumerable<Product> products)
        {
            foreach (var p in products) Text(p.Id + " | " + p.Name + " | " + p.Price.ToString("0.00", CultureInfo.InvariantCulture));
        }
    }
    public sealed class CatalogController
    {
        private readonly CatalogService service;
        private readonly ConsoleView view;
        public CatalogController(CatalogService service, ConsoleView view) { this.service = service; this.view = view; }
        private static int Int(string value) { return Int32.Parse(value, CultureInfo.InvariantCulture); }
        private static decimal Money(string value) { return Decimal.Parse(value, NumberStyles.AllowDecimalPoint, CultureInfo.InvariantCulture); }
        public void Run(string[] args)
        {
            if (args.Length == 0 || args[0] == "list")
            {
                if (args.Length > 3) throw new ArgumentException("list [page] [size]");
                view.Products(service.List(args.Length > 1 ? Int(args[1]) : 1, args.Length > 2 ? Int(args[2]) : 20));
            }
            else if (args[0] == "find" && args.Length == 2)
            {
                var p = service.Find(Int(args[1])); if (p == null) view.Text("Not found"); else view.Products(new[] { p });
            }
            else if (args[0] == "add" && args.Length == 3) view.Text("Created " + service.Add(args[1], Money(args[2])));
            else if (args[0] == "update" && args.Length == 4) view.Text(service.Update(Int(args[1]), args[2], Money(args[3])) ? "Updated" : "Not found");
            else if (args[0] == "delete" && args.Length == 3 && args[2] == "--confirm") view.Text(service.Delete(Int(args[1])) ? "Deleted" : "Not found");
            else if (args[0] == "count" && args.Length == 1) view.Text("Count: " + service.Count());
            else if (args[0] == "export" && args.Length == 2)
            {
                // CreateNew prevents overwriting an existing user file.
                using (var stream = new FileStream(args[1], FileMode.CreateNew, FileAccess.Write))
                using (var writer = new StreamWriter(stream, new System.Text.UTF8Encoding(true))) service.Export(writer);
                view.Text("Export created");
            }
            else throw new ArgumentException("Commands: list [page] [size], find id, add name price, update id name price, delete id --confirm, count, export NEW.csv");
        }
    }
    public sealed class MemoryRepository : IProductRepository
    {
        private readonly List<Product> data = new List<Product>();
        private int nextId = 1;
        public IReadOnlyList<Product> List(int page, int size) { Rules.Page(page, size); return data.OrderBy(p => p.Id).Skip((page - 1) * size).Take(size).Select(Clone).ToList(); }
        private static Product Clone(Product p) { return p == null ? null : new Product { Id = p.Id, Name = p.Name, Price = p.Price }; }
        public Product Find(int id) { return Clone(data.Find(p => p.Id == id)); }
        public int Add(string name, decimal price) { Rules.Product(name, price); int id = nextId++; data.Add(new Product { Id = id, Name = name, Price = price }); return id; }
        public bool Update(int id, string name, decimal price) { Rules.Product(name, price); var p = data.Find(x => x.Id == id); if (p == null) return false; p.Name = name; p.Price = price; return true; }
        public bool Delete(int id) { return data.RemoveAll(p => p.Id == id) == 1; }
        public int Count() { return data.Count; }
    }
    public static class Program
    {
        private static void Check(bool condition) { if (!condition) throw new Exception("Self-test failed."); }
        private static void SelfTest()
        {
            var s = new CatalogService(new MemoryRepository());
            int id = s.Add(" Mouse ", 12.34m);
            Check(s.Find(id).Name == "Mouse"); Check(s.Update(id, "Keyboard", 50m)); Check(s.Find(id).Price == 50m);
            bool rejected = false; try { s.Add("", 1); } catch (ArgumentException) { rejected = true; } Check(rejected);
            rejected = false; try { s.Add("X", 1.001m); } catch (ArgumentException) { rejected = true; } Check(rejected);
            Check(s.Delete(id)); Check(!s.Delete(id)); Check(s.Find(id) == null);
            for (int i = 0; i < 205; i++) s.Add("P" + i, i + 1);
            Check(s.List(3, 100).Count == 5);
            using (var w = new StringWriter()) { s.Export(w); Check(w.ToString().Split(new[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries).Length == 206); }
            Check(CatalogService.CsvCell("=SUM(1)") == "\"'=SUM(1)\"");
            using (var w = new StringWriter()) { new CatalogController(s, new ConsoleView(w)).Run(new[] { "count" }); Check(w.ToString().Contains("205")); }
            var parameters = new DynamicParameters(); parameters.Add("Name", "O'Brien'; DROP TABLE Products;--"); Check(parameters.ParameterNames.Single() == "Name");
            Console.WriteLine("PASS: CRUD, validation, isolation, pagination, CSV escaping, controller and Dapper parameters. In-memory tests only; SQL Server not contacted.");
        }
        public static int Main(string[] args)
        {
            try
            {
                if (args.Length == 1 && args[0] == "--self-test") { SelfTest(); return 0; }
                if (args.Length == 1 && args[0] == "--help") { Console.WriteLine("Set ACADEMY_SQL_CONNECTION; commands: list, find, add, update, delete --confirm, count, export. Use --self-test offline."); return 0; }
                var repo = new SqlProductRepository(Environment.GetEnvironmentVariable("ACADEMY_SQL_CONNECTION"));
                new CatalogController(new CatalogService(repo), new ConsoleView(Console.Out)).Run(args); return 0;
            }
            catch (SqlException e) { Console.Error.WriteLine("SQL error " + e.Number + ". Check server and schema."); return 1; }
            catch (Exception e) { Console.Error.WriteLine(e.Message); return 1; }
        }
    }
}
