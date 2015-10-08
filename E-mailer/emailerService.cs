using DataLayer;
using Helpers;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Data;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Net.Mime;
using System.ServiceProcess;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace E_mailer
{
    /// <summary>
    ///   int_status => 0= new , -1 =failed and tried once ...., 255=send,2=send to smtp
    /// 
    /// </summary>
    /// 

    public partial class emailerService : ServiceBase
    {
        string main_path = AppDomain.CurrentDomain.BaseDirectory;
        int thread_count = 1;
        int current_thread_count = 1;
        Dictionary<string, string> settings;
        System.Timers.Timer emailerTimer;
        List<mailDetails> collection;

        public emailerService()
        {
            InitializeComponent();


        }

        protected override void OnStart(string[] args)
        {
            Process();
        }
        internal void Process()
        {

            dbHelper helper = new dbHelper();
            helper.UpdateMissedData();
            FillSettings();
            if (settings != null)
            {
                double timerInterval = 10;
                double.TryParse(settings["EmailSendInterval"], out timerInterval);
                int.TryParse(settings["ThreadCount"], out thread_count);

                if (timerInterval == 0)
                    timerInterval = 0.1;
                collection = new List<mailDetails>();

                emailerTimer = new System.Timers.Timer();
                emailerTimer.Elapsed += new System.Timers.ElapsedEventHandler(GetMail);

                emailerTimer.Interval = 60000 * timerInterval;
                emailerTimer.Enabled = true;
                emailerTimer.AutoReset = true;
                emailerTimer.Start();

            }
        }
        void FillSettings()
        {

            dbHelper helper = new dbHelper();
            var EmailSendInterval = helper.GetSettingFromKey("EmailSendInterval", "10");
            var EmailForBulk = helper.GetSettingFromKey("EmailForBulk", "50");
            var SMTPUserName = helper.GetSettingFromKey("SMTPUserName", "");
            var SMTPPassword = helper.GetSettingFromKey("SMTPPassword", "");
            var SMTPHostName = helper.GetSettingFromKey("SMTPHostName", "");
            var SMTPHostPort = helper.GetSettingFromKey("SMTPHostPort", "");
            var EnableSSL = helper.GetSettingFromKey("EnableSSL", "true");
            var LastRunTime = helper.GetSettingFromKey("LastRunTime", "");
            var ReTryTime = helper.GetSettingFromKey("ReTryTime", "5");
            var UseDefaultCredentials = helper.GetSettingFromKey("UseDefaultCredentials", "false");
            var ThreadCount = helper.GetSettingFromKey("ThreadCount", "1");
            if (ReTryTime != "" && EmailSendInterval != "" && EmailForBulk != "" && SMTPUserName != "" && SMTPPassword != "" && SMTPHostName != ""
                && SMTPHostPort != "" && EnableSSL != "" && UseDefaultCredentials != "" && ThreadCount != "")
            {
                settings = new Dictionary<string, string>();
                settings.Add("EmailSendInterval", EmailSendInterval);
                settings.Add("EmailForBulk", EmailForBulk);
                settings.Add("SMTPUserName", SMTPUserName);
                settings.Add("SMTPPassword", SMTPPassword);
                settings.Add("SMTPHostName", SMTPHostName);
                settings.Add("SMTPHostPort", SMTPHostPort);
                settings.Add("EnableSSL", EnableSSL);
                settings.Add("LastRunTime", LastRunTime);
                settings.Add("ReTryTime", ReTryTime);
                settings.Add("ThreadCount", ThreadCount);
                settings.Add("UseDefaultCredentials", UseDefaultCredentials);


            }
            else { logHelper.LogException(new Exception("Settings are invalid"), main_path); }

        }
        protected override void OnStop()
        {

        }
        private void WorkerThreadFunc()
        {

            if (settings != null && true)
            {
                dbHelper helper = new dbHelper();

                string smtpEmailAddress = settings["SMTPUserName"];
                string smtpPassword = settings["SMTPPassword"];
                // string fromEmail = settings["FromEmail"];
                // string fromDisplayName = settings["FromDisplayName"];
                string smtpClientHost = settings["SMTPHostName"];
                int smtoClientPort = int.Parse(settings["SMTPHostPort"]);
                bool enableSsl = bool.Parse(settings["EnableSSL"]);
                bool useDefaultCredentials = bool.Parse(settings["UseDefaultCredentials"]);
                int emailForBulk = 50, reTryTime = 5;
                int.TryParse(settings["EmailForBulk"], out emailForBulk);
                int.TryParse(settings["ReTryTime"], out reTryTime);
                var databundle = helper.GetmailBulk(DateTime.Now, emailForBulk);

                var notsendbundle = helper.GetFailedBulk(reTryTime);
                if (databundle != null)
                {
                    databundle.AddRange(notsendbundle);
                }
                else
                    databundle = notsendbundle;
                if (databundle != null)
                {
                    helper.SetSettingFromKey("LastRunTime", DateTime.Now.ToString());
                    Parallel.ForEach(databundle, item =>
                    {
                        string newGuid = Guid.NewGuid().ToString();
                        var mail = new mailDetails() { guid = newGuid, mail = item };
                        collection.Add(mail);

                        sendEmail(mail, smtpEmailAddress, smtpPassword, smtpClientHost, smtoClientPort, enableSsl, useDefaultCredentials);
                    });
                }
            }

            current_thread_count--;
            if (!emailerTimer.Enabled)
                emailerTimer.Start();
        }
        public void GetMail(object sender, System.Timers.ElapsedEventArgs args)
        {


            if (thread_count >= current_thread_count)
            {
                current_thread_count++;
                Thread myThread = new Thread(WorkerThreadFunc);
                myThread.Start();


            }
            else { emailerTimer.Stop(); }

        }

        private void sendEmail(mailDetails mail, string smtpEmailAddress, string smtpPassword, string smtpClientHost, int smtoClientPort, bool enableSsl, bool useDefaultCredentials)
        {
            string guid = mail.guid;
            try
            {


                NetworkCredential cred = new NetworkCredential(smtpEmailAddress, smtpPassword);
                MailMessage msg = new MailMessage();

                foreach (var email in mail.mail.tbl_email_to_address)
                {
                    if (email.int_type == 1)
                    {
                        msg.To.Add(new MailAddress(email.str_email_address, email.str_email_name));
                    }
                    else if (email.int_type == 2)
                    {
                        msg.CC.Add(new MailAddress(email.str_email_address, email.str_email_name));
                    }
                    else if (email.int_type == 3)
                    {
                        msg.Bcc.Add(new MailAddress(email.str_email_address, email.str_email_name));
                    }
                }

                msg.Subject = mail.mail.tbl_email_awaiting_details.str_subject;
                msg.IsBodyHtml = true;
                msg.Body = mail.mail.tbl_email_awaiting_details.str_body;
                msg.From = new MailAddress(mail.mail.tbl_email_awaiting_details.str_from_address, mail.mail.tbl_email_awaiting_details.str_from_name);
                foreach (var attac in mail.mail.tbl_email_awaiting_details.tbl_email_attachment)
                {
                    var attachmentFilename = attac.str_file_path;

                    if (File.Exists(attachmentFilename))
                    {
                        Attachment attachment = new Attachment(attachmentFilename, MediaTypeNames.Application.Octet);
                        ContentDisposition disposition = attachment.ContentDisposition;
                        disposition.CreationDate = File.GetCreationTime(attachmentFilename);
                        disposition.ModificationDate = File.GetLastWriteTime(attachmentFilename);
                        disposition.ReadDate = File.GetLastAccessTime(attachmentFilename);
                        disposition.FileName = Path.GetFileName(attachmentFilename);
                        disposition.Size = new FileInfo(attachmentFilename).Length;
                        disposition.DispositionType = DispositionTypeNames.Attachment;
                        msg.Attachments.Add(attachment);
                        attac.bit_attached = true;
                    }
                    else
                    {
                        attac.bit_attached = false;
                        attac.str_error = "File not found.";
                    }
                }

                SmtpClient client = new SmtpClient(smtpClientHost, smtoClientPort);

                client.SendCompleted += (s, e) =>
                {
                    client_SendCompleted(s, e);
                    client.Dispose();
                    msg.Dispose();
                }; ;

                client.Credentials = cred;

                client.UseDefaultCredentials = useDefaultCredentials;
                client.DeliveryMethod = SmtpDeliveryMethod.Network;

                client.EnableSsl = enableSsl;
                client.SendAsync(msg, guid);

            }
            catch (Exception e)
            {
                updateDetails(mail, true, e);

            }

        }

        void client_SendCompleted(object sender, AsyncCompletedEventArgs e)
        {
            try
            {
                var guid = e.UserState;

                var mail = collection.Single(a => a.guid.Equals(guid));
                updateDetails(mail, e.Cancelled, e.Error);
            }
            catch (Exception er)
            {
                logHelper.LogException(er, main_path);

            }


        }
        void updateDetails(mailDetails mail, bool Cancelled, Exception Error)
        {
            try
            {


                string error = null;
                var updateData = mail.mail;
                int int_failed_count = 0;
                if (updateData.int_failed_count != null)
                    int_failed_count = updateData.int_failed_count.Value;
                int int_satues = 0;
                if (!Cancelled && Error == null)
                {
                    updateData.dt_send_date = DateTime.Now;

                    int_satues = 255;
                }
                else
                {
                    int_satues = -1;

                    logHelper.LogException(Error, main_path);
                    if (Error != null)
                    {
                        if (Error.InnerException != null)
                            error = Error.InnerException.Message;
                        else
                            error = Error.Message;
                    }
                    int_failed_count++;
                }

                updateData.str_error = error;
                updateData.int_status = int_satues;
                updateData.int_failed_count = int_failed_count;

                dbHelper helper = new dbHelper();
                if (helper.UpdateData(updateData))
                    collection.Remove(mail);
            }

            catch (Exception er)
            {
                logHelper.LogException(er, main_path);

            }
        }
    }
    [Serializable]
    class mailDetails
    {
        public string guid { get; set; }

        public tbl_email_awaiting mail { get; set; }

    }
}
