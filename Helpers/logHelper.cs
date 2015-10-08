using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Helpers
{
    public class logHelper
    {
        public static void LogException(Exception exc, string mainPath)
        {
            try
            {
                // Include logic for logging exceptions
                // Get the absolute path to the log file//
                //C:\ExpertentialSystem\Expertential_live\AppAccount\ErrorPages
                //C:\ExpertentialSystem\Expertential_live\AppAccount\secure\ErrorPages\ErrorLog.txt
                string logFile = @"ErrorLog\ErrorLog-" + DateTime.Now.Year + "-" + DateTime.Now.Month + "-" + DateTime.Now.Day + ".txt";
                // string mainPath = AppDomain.CurrentDomain.BaseDirectory;
                logFile = Path.Combine(mainPath, logFile);
                if (!Directory.Exists(Path.Combine(mainPath, "ErrorLog")))
                {
                    Directory.CreateDirectory(Path.Combine(mainPath, "ErrorLog"));
                }
                if (!File.Exists(logFile))
                {
                    using (StreamWriter sw = File.CreateText(logFile))
                    {

                        sw.WriteLine(" {0} ", DateTime.Now);
                        if (exc.InnerException != null)
                        {
                            sw.Write("Inner Exception Type: ");
                            sw.WriteLine(exc.InnerException.GetType().ToString());
                            sw.Write("Inner Exception: ");
                            sw.WriteLine(exc.InnerException.Message);
                            sw.Write("Inner Source: ");
                            sw.WriteLine(exc.InnerException.Source);
                            if (exc.InnerException.StackTrace != null)
                            {
                                sw.WriteLine("Inner Stack Trace: ");
                                sw.WriteLine(exc.InnerException.StackTrace);
                            }
                        }
                        sw.Write("Exception Type: ");
                        sw.WriteLine(exc.GetType().ToString());
                        sw.WriteLine("Exception: " + exc.Message);

                        sw.WriteLine("Stack Trace: ");
                        if (exc.StackTrace != null)
                        {
                            sw.WriteLine(exc.StackTrace);
                            sw.WriteLine();
                        }
                        sw.Close();

                    }
                }
                else
                {
                    using (StreamWriter sw = File.AppendText(logFile))
                    {

                        sw.WriteLine(" {0} ", DateTime.Now);
                        if (exc.InnerException != null)
                        {
                            sw.Write("Inner Exception Type: ");
                            sw.WriteLine(exc.InnerException.GetType().ToString());
                            sw.Write("Inner Exception: ");
                            sw.WriteLine(exc.InnerException.Message);
                            sw.Write("Inner Source: ");
                            sw.WriteLine(exc.InnerException.Source);
                            if (exc.InnerException.StackTrace != null)
                            {
                                sw.WriteLine("Inner Stack Trace: ");
                                sw.WriteLine(exc.InnerException.StackTrace);
                            }
                        }
                        sw.Write("Exception Type: ");
                        sw.WriteLine(exc.GetType().ToString());
                        sw.WriteLine("Exception: " + exc.Message);

                        sw.WriteLine("Stack Trace: ");
                        if (exc.StackTrace != null)
                        {
                            sw.WriteLine(exc.StackTrace);
                            sw.WriteLine();
                        }
                        sw.Close();
                    }
                }
                // Open the log file for append and write the log
            }
            catch { }
        }
    }
}
