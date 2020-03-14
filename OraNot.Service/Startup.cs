using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;
using OraNot.Workers;

namespace OraNot
{
    public class Startup
    {
        public static void ConfigureServices(IConfiguration configuration, IServiceCollection services)
        {
            services.AddOptions();
            // services.AddOptions<OracleSettings>();
            services.AddHostedService<OracleSubscriber>();
            services.AddHostedService<OracleEditor>();
            services.Configure<OracleSettings>(configuration.GetSection("OracleSettings"));
            services.AddSingleton<IOracleSettings>(sp => sp.GetRequiredService<IOptions<OracleSettings>>().Value);
            // services.ConfigureOptions<>()<OracleSettings>() AddOptions();
            // services.ConfigureOptions();
            // services.AddOptions<IOracleSettings>();
        }
    }
    
}