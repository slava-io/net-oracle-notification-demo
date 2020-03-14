namespace OraNot
{
    public class OracleSettings : IOracleSettings
    {
        public string Template { get; set; }
        public string Host { get; set; }
        public int Port { get; set; }
        public string Sid { get; set; }
        public string User { get; set; }
        public string Password { get; set; }

        public string GetConnectionString()
        {
            return string.Format(this.Template, Host, Port, Sid, User, Password);
        }
    }
}