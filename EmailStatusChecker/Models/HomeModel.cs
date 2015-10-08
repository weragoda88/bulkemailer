using DataLayer;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace EmailStatusChecker.Models
{
    public class HomeModel
    {
        public void FillSettings()
        {
            dbHelper helper = new dbHelper();
            settings = helper.GetAllSetting();
        }
        public void FillStatus()
        {
            dbHelper helper = new dbHelper();
            summary = helper.GetEmailSummary();
        }
        public void FillPenndingEmails()
        {
            dbHelper helper = new dbHelper();
            penddingEmails = helper.GetEmailsByStatus(0,DateTime.Now);
        }
        public emailSummary summary; 

        public List<tbl_setting> settings;
        public List<tbl_email_awaiting> penddingEmails;
    }
}