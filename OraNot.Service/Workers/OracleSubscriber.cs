using System;
using System.Data;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Oracle.ManagedDataAccess.Client;

namespace OraNot.Workers
{
    public class OracleSubscriber : BackgroundService
    {
        private readonly ILogger<OracleSubscriber> _logger;
        private readonly IOracleSettings _settings;
        private OracleConnection _connection;
        private OracleDependency _dependecy;

        public OracleSubscriber(ILogger<OracleSubscriber> logger, IOracleSettings settings)
        {
            _logger = logger;
            _settings = settings;
            _logger.LogInformation(_settings.GetConnectionString());
        }

        private void dependency_OnChange(object sender, OracleNotificationEventArgs eventArgs)
        {
            try
            {
                // ConsoleTable.From()
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("Table has been Changed");
                Console.WriteLine(eventArgs.Source.ToString());
                Console.WriteLine(eventArgs.Info.ToString());
                Console.WriteLine(eventArgs.Source.ToString());
                Console.WriteLine(eventArgs.Type.ToString());
                DataTable dt = eventArgs.Details;
                // PrintDataTable(dt); 
                Console.ForegroundColor = ConsoleColor.White;
            }
            catch (Exception exception)
            {
                Console.WriteLine(exception.Message);
            }
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            await Task.Yield();

            _connection = new OracleConnection(_settings.GetConnectionString());
            _connection.Open();
            Console.WriteLine("Connected to ORACLE");
            var sql = @$"select * from VAN_SUBSIDIARY";
            var cmd = new OracleCommand(sql, _connection);
            // OracleDependency.Port = 49161;
            // OracleDependency.Address = "adyensync-oracle";

            var dependency = new OracleDependency(cmd);
            // var orderId = 41851206;
            dependency.QueryBasedNotification = false;
            // dependency.AddCommandDependency(cmd);
            dependency.OnChange += dependency_OnChange;
            cmd.Notification.IsNotifiedOnce = false;
            // cmd.Notification.IsPersistent = true;
            // cmd.Notification.Timeout = 0;
            cmd.AddRowid = true;
            _dependecy = dependency;
            try
            {
                cmd.ExecuteNonQuery();
                Console.WriteLine("Subscribed");
                await Task.Delay(1000, stoppingToken);
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                throw;
            }
        }


        public override Task StopAsync(CancellationToken cancellationToken)
        {
            _dependecy.RemoveRegistration(_connection);
            _connection?.Dispose();
            return base.StopAsync(cancellationToken);
        }
    }
}