using Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace E_mailer
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        static void Main()
        {

            AppDomain.CurrentDomain.UnhandledException += CurrentDomain_UnhandledException;

#if(!DEBUG)
                        ServiceBase[] ServicesToRun;
                        ServicesToRun = new ServiceBase[] 
                        { 
                            new emailerService() 
                        };
                        ServiceBase.Run(ServicesToRun);
#else
            emailerService myServ = new emailerService();
            myServ.Process();

            Thread.Sleep(999999999);
            // here Process is my Service function
            // that will run when my service onstart is call
            // you need to call your own method or function name here instead of Process();

#endif


        }

        static void CurrentDomain_UnhandledException(object sender, UnhandledExceptionEventArgs e)
        {
            logHelper.LogException((Exception)e.ExceptionObject, AppDomain.CurrentDomain.BaseDirectory);
        }

    }
}
