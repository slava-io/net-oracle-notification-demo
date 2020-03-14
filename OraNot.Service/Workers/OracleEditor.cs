using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Oracle.ManagedDataAccess.Client;

namespace OraNot.Workers
{
    public class OracleEditor: BackgroundService
    {
        public IOracleSettings Configuration { get; }
        private readonly IConfiguration _configuration;
        private OracleConnection _connection;
        private void Select()
        {
            var sql = "Select * from VAN_SUBSIDIARY where rownum = 1";
            var cmd = new OracleCommand(sql, _connection);
            var result = cmd.ExecuteScalar();
            Console.WriteLine(result);
            
        }

        private void Update()
        {
            // var sql =
            //     @"INSERT INTO VAN_SUBSIDIARY (SUBSIDIARYID, SUBSIDIARY, EXTERNALADMINISTRATION, COMPANYID, SHAREDSTOCKBASESUBSIDIARYID, RETURNSTOCKLOCATIONID, SUPPLIERID, CUSTOMERID, EXPORTADMINISTRATION, TERMSOFUSECPC, VATCOUNTRYID, CPCTASKHANDLINGSTOCKLOCATIONID)
            // VALUES (105, 'Coolblue n.v.', 'SVIATOSLAV', 2, NULL, 101, 2618, 3, 'CBNV_2015', NULL, 2, 101)
            // ";
            var sql = "Update VAN_SUBSIDIARY ss SET ss.SUBSIDIARY = 'DtMffdfMY' where rownum = 1";
            var cmd = new OracleCommand(sql, _connection);
            try
            {
                var result = cmd.ExecuteNonQuery();
            
                Console.WriteLine(result);

            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                throw;    
            }
            
        }

        public OracleEditor(IOracleSettings configuration)
        {
            Configuration = configuration;
        }
        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            await Task.Yield();
            Console.WriteLine("Creating connection, press enter");
            Console.ReadLine();
            // var str = _configuration.GetSection("OracleSettings").Get<OracleSettings>().ConnectionString;
            _connection = new OracleConnection(Configuration.GetConnectionString());
            _connection.Open();
            Console.WriteLine("Connected");
            // while (!stoppingToken.IsCancellationRequested)
            // {
                Console.WriteLine("select ??");
                if (Console.ReadLine() == "y")
                    Select();
                Console.WriteLine("update");
                if (Console.ReadLine() == "y")
                    Update();
            // }
            
        }
    }
}