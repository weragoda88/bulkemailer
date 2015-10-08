using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(EmailStatusChecker.Startup))]
namespace EmailStatusChecker
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}
