using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DataLayer
{
    public class emailSummary
    {
        public int AwaitingToSent { get; set; }
        public int AwaitingToSentfaild { get; set; }
        public int InProcessOfSending { get; set; }
        public int SuccessfullySent { get; set; }
        public int SendFail { get; set; }
    }
    public class dbHelper
    {
        string connectionString = ConfigurationManager.ConnectionStrings["E_MailerMainDBEntities"].ConnectionString;
        public string GetSettingFromKey(string key, string defaultVal)
        {

            using (SqlConnection DBCon = new SqlConnection(connectionString))
            {

                SqlCommand CmdSelect = new SqlCommand("get_setting_from_key", DBCon);
                CmdSelect.CommandType = CommandType.StoredProcedure;
                CmdSelect.Connection = DBCon;

                CmdSelect.Parameters.AddWithValue("@key", SqlDbType.VarChar).Value = key;
                CmdSelect.Parameters.AddWithValue("@defaultVal", SqlDbType.VarChar).Value = defaultVal;

                DBCon.Open();
                SqlDataReader rd = CmdSelect.ExecuteReader();
                if (rd.HasRows)
                {
                    while (rd.Read())
                    {
                        tbl_setting email_awaiting = new tbl_setting();

                        email_awaiting.id = Convert.ToInt32((!DBNull.Value.Equals(rd["id"])) ? rd["id"].ToString() : "0");
                        email_awaiting.key = ((!DBNull.Value.Equals(rd["key"])) ? rd["key"] : string.Empty).ToString();
                        email_awaiting.value = ((!DBNull.Value.Equals(rd["value"])) ? rd["value"] : string.Empty).ToString();

                        return email_awaiting.value;
                    }
                }


            }

            return "";
        }
        public void SetSettingFromKey(string key, string Val)
        {
            using (SqlConnection DBCon = new SqlConnection(connectionString))
            {

                SqlCommand CmdSelect = new SqlCommand("set_setting_for_key", DBCon);
                CmdSelect.CommandType = CommandType.StoredProcedure;
                CmdSelect.Connection = DBCon;

                CmdSelect.Parameters.AddWithValue("@key", SqlDbType.VarChar).Value = key;
                CmdSelect.Parameters.AddWithValue("@val", SqlDbType.VarChar).Value = Val;

                DBCon.Open();
                CmdSelect.ExecuteNonQuery();



            }

        }
        public List<tbl_setting> GetAllSetting()
        {
            using (SqlConnection DBCon = new SqlConnection(connectionString))
            {
                List<tbl_setting> email_awaiting_list = new List<tbl_setting>();
                SqlCommand CmdSelect = new SqlCommand("get_setting", DBCon);
                CmdSelect.CommandType = CommandType.StoredProcedure;
                CmdSelect.Connection = DBCon;
                DBCon.Open();
                SqlDataReader rd = CmdSelect.ExecuteReader();
                if (rd.HasRows)
                {
                    while (rd.Read())
                    {
                        tbl_setting email_awaiting = new tbl_setting();

                        email_awaiting.id = Convert.ToInt32((!DBNull.Value.Equals(rd["id"])) ? rd["id"].ToString() : "0");
                        email_awaiting.key = ((!DBNull.Value.Equals(rd["key"])) ? rd["key"] : string.Empty).ToString();
                        email_awaiting.value = ((!DBNull.Value.Equals(rd["value"])) ? rd["value"] : string.Empty).ToString();

                        email_awaiting_list.Add(email_awaiting);
                    }
                }

                return email_awaiting_list;
            }
        }
        public emailSummary GetEmailSummary()
        {
            emailSummary summary = new emailSummary();
            using (SqlConnection DBCon = new SqlConnection(connectionString))
            {

                SqlCommand CmdSelect = new SqlCommand("get_email_summary", DBCon);
                CmdSelect.CommandType = CommandType.StoredProcedure;
                CmdSelect.Connection = DBCon;
                DBCon.Open();
                SqlDataReader rd = CmdSelect.ExecuteReader();
                if (rd.HasRows)
                {
                    while (rd.Read())
                    {
                        summary.AwaitingToSent = Convert.ToInt32((!DBNull.Value.Equals(rd["AwaitingToSent"])) ? rd["AwaitingToSent"].ToString() : "0");
                        //entity.tbl_email_awaiting.Where(a => a.int_status == 0).Count();
                        summary.AwaitingToSentfaild = Convert.ToInt32((!DBNull.Value.Equals(rd["AwaitingToSentfaild"])) ? rd["AwaitingToSentfaild"].ToString() : "0");
                        //entity.tbl_email_awaiting.Where(a => a.int_status == -1 && a.int_failed_count < faildCount).Count();
                        summary.SendFail = Convert.ToInt32((!DBNull.Value.Equals(rd["SendFail"])) ? rd["SendFail"].ToString() : "0");
                        //entity.tbl_email_awaiting.Where(a => a.int_status == -1 && a.int_failed_count == faildCount).Count();
                        summary.SuccessfullySent = Convert.ToInt32((!DBNull.Value.Equals(rd["SuccessfullySent"])) ? rd["SuccessfullySent"].ToString() : "0");
                        //entity.tbl_email_awaiting.Where(a => a.int_status == 255).Count();
                        summary.InProcessOfSending = Convert.ToInt32((!DBNull.Value.Equals(rd["InProcessOfSending"])) ? rd["InProcessOfSending"].ToString() : "0");
                        //entity.tbl_email_awaiting.Where(a => a.int_status == 2).Count();


                    }
                }
            }


            return summary;

        }
        public List<tbl_email_awaiting> GetmailBulk(DateTime filterDate, int numberofmail)
        {
            using (SqlConnection DBCon = new SqlConnection(connectionString))
            {
                List<tbl_email_awaiting> email_awaitingList = new List<tbl_email_awaiting>();
                SqlCommand CmdSelect = new SqlCommand("get_email_bulk", DBCon);
                CmdSelect.CommandType = CommandType.StoredProcedure;
                CmdSelect.Connection = DBCon;

                CmdSelect.Parameters.AddWithValue("@filterDate", SqlDbType.DateTime).Value = filterDate;
                CmdSelect.Parameters.AddWithValue("@numberofmail", SqlDbType.Int).Value = numberofmail;

                DBCon.Open();
                SqlDataReader rd = CmdSelect.ExecuteReader();
                if (rd.HasRows)
                {
                    while (rd.Read())
                    {
                        tbl_email_awaiting email_awaiting = new tbl_email_awaiting();
                        email_awaiting.guid = (!DBNull.Value.Equals(rd["guid"])) ? rd["guid"].ToString() : string.Empty;
                        email_awaiting.int_status = Convert.ToInt32((!DBNull.Value.Equals(rd["int_status"])) ? rd["int_status"].ToString() : "0");
                        email_awaiting.str_error = ((!DBNull.Value.Equals(rd["str_error"])) ? rd["str_error"] : string.Empty).ToString();
                        email_awaiting.dt_due_date = Convert.ToDateTime((!DBNull.Value.Equals(rd["dt_due_date"])) ? rd["dt_due_date"] : DateTime.Now);
                        email_awaiting.dt_inserted_date = Convert.ToDateTime((!DBNull.Value.Equals(rd["dt_inserted_date"])) ? rd["dt_inserted_date"] : DateTime.MinValue);
                        email_awaiting.dt_send_date = Convert.ToDateTime((!DBNull.Value.Equals(rd["dt_send_date"])) ? rd["dt_send_date"] : DateTime.MinValue);
                        email_awaiting.dt_expire_date = Convert.ToDateTime((!DBNull.Value.Equals(rd["dt_expire_date"])) ? rd["dt_expire_date"] : DateTime.MinValue);
                        email_awaiting.int_failed_count = Convert.ToInt32((!DBNull.Value.Equals(rd["int_failed_count"])) ? rd["int_failed_count"].ToString() : "0");
                        email_awaiting.email_detail_guid = (!DBNull.Value.Equals(rd["email_detail_guid"])) ? rd["email_detail_guid"].ToString() : string.Empty;

                        email_awaitingList.Add(email_awaiting);
                    }
                    rd.NextResult();
                    while (rd.Read())
                    {
                        tbl_email_awaiting_details tbl_email_awaiting_detail = new tbl_email_awaiting_details();
                        tbl_email_awaiting_detail.guid = (!DBNull.Value.Equals(rd["guid"])) ? rd["guid"].ToString() : string.Empty;
                        tbl_email_awaiting_detail.str_subject = (!DBNull.Value.Equals(rd["str_subject"])) ? rd["str_subject"].ToString() : "";
                        tbl_email_awaiting_detail.str_body = ((!DBNull.Value.Equals(rd["str_body"])) ? rd["str_body"] : string.Empty).ToString();
                        tbl_email_awaiting_detail.str_from_address = ((!DBNull.Value.Equals(rd["str_from_address"])) ? rd["str_from_address"] : string.Empty).ToString();
                        tbl_email_awaiting_detail.str_from_name = ((!DBNull.Value.Equals(rd["str_from_name"])) ? rd["str_from_address"] : string.Empty).ToString();
                        tbl_email_awaiting_detail.dt_inserted_date = Convert.ToDateTime((!DBNull.Value.Equals(rd["dt_inserted_date"])) ? rd["dt_inserted_date"] : DateTime.Now);
                        tbl_email_awaiting_detail.dt_inserted_date = Convert.ToDateTime((!DBNull.Value.Equals(rd["dt_inserted_date"])) ? rd["dt_inserted_date"] : DateTime.MinValue);

                        var email_awaitings = email_awaitingList.Where(a => a.email_detail_guid == tbl_email_awaiting_detail.guid);
                        foreach (var email_awaiting in email_awaitings)
                        {
                            email_awaiting.tbl_email_awaiting_details = tbl_email_awaiting_detail;
                        }
                    }
                    rd.NextResult();

                    while (rd.Read())
                    {
                        tbl_email_to_address tbl_email_to_addr = new tbl_email_to_address();
                        tbl_email_to_addr.guid = (!DBNull.Value.Equals(rd["guid"]) ? rd["guid"].ToString() : string.Empty);
                        tbl_email_to_addr.str_email_address = (!DBNull.Value.Equals(rd["str_email_address"])) ? rd["str_email_address"].ToString() : "";
                        tbl_email_to_addr.str_email_name = ((!DBNull.Value.Equals(rd["str_email_name"])) ? rd["str_email_name"] : string.Empty).ToString();
                        tbl_email_to_addr.int_type = Convert.ToInt32((!DBNull.Value.Equals(rd["int_type"])) ? rd["int_type"] : "0");
                        tbl_email_to_addr.email_guid = ((!DBNull.Value.Equals(rd["email_guid"])) ? rd["email_guid"] : string.Empty).ToString();


                        var email_awaiting = email_awaitingList.SingleOrDefault(a => a.guid == tbl_email_to_addr.email_guid);
                        if (email_awaiting.tbl_email_to_address == null)
                            email_awaiting.tbl_email_to_address = new List<tbl_email_to_address>();
                        email_awaiting.tbl_email_to_address.Add(tbl_email_to_addr);
                    }

                    rd.NextResult();

                    while (rd.Read())
                    {
                        tbl_email_attachment tbl_email_attach = new tbl_email_attachment();
                        tbl_email_attach.guid = (!DBNull.Value.Equals(rd["guid"]) ? rd["guid"].ToString() : string.Empty);
                        tbl_email_attach.str_file_path = (!DBNull.Value.Equals(rd["str_file_path"])) ? rd["str_file_path"].ToString() : "";
                        tbl_email_attach.bit_attached = Convert.ToBoolean((!DBNull.Value.Equals(rd["bit_attached"])) ? rd["bit_attached"] : "false");
                        tbl_email_attach.str_file_path = (!DBNull.Value.Equals(rd["str_file_path"])) ? rd["str_file_path"].ToString() : "";
                        tbl_email_attach.str_error = ((!DBNull.Value.Equals(rd["str_error"])) ? rd["str_error"] : "").ToString();
                        tbl_email_attach.email_detail_guid = ((!DBNull.Value.Equals(rd["email_detail_guid"])) ? rd["email_detail_guid"] : "").ToString();

                        var email_awaiting = email_awaitingList.SingleOrDefault(p => p.tbl_email_awaiting_details.guid == tbl_email_attach.email_detail_guid);


                        if (email_awaiting.tbl_email_awaiting_details.tbl_email_attachment == null)
                            email_awaiting.tbl_email_awaiting_details.tbl_email_attachment = new List<tbl_email_attachment>();
                        email_awaiting.tbl_email_awaiting_details.tbl_email_attachment.Add(tbl_email_attach);
                    }
                }
                return email_awaitingList;


            }
        }
        public List<tbl_email_awaiting> GetEmailsByStatus(int status, DateTime filterDate)
        {

            using (SqlConnection DBCon = new SqlConnection(connectionString))
            {
                List<tbl_email_awaiting> email_awaitingList = new List<tbl_email_awaiting>();
                SqlCommand CmdSelect = new SqlCommand("get_emails_by_status", DBCon);
                CmdSelect.CommandType = CommandType.StoredProcedure;
                CmdSelect.Connection = DBCon;

                CmdSelect.Parameters.AddWithValue("@filterDate", SqlDbType.DateTime).Value = filterDate;
                CmdSelect.Parameters.AddWithValue("@status", SqlDbType.Int).Value = status;

                DBCon.Open();
                SqlDataReader rd = CmdSelect.ExecuteReader();
                if (rd.HasRows)
                {
                    while (rd.Read())
                    {
                        tbl_email_awaiting email_awaiting = new tbl_email_awaiting();
                        email_awaiting.guid = (!DBNull.Value.Equals(rd["guid"])) ? rd["guid"].ToString() : string.Empty;
                        email_awaiting.int_status = Convert.ToInt32((!DBNull.Value.Equals(rd["int_status"])) ? rd["int_status"].ToString() : "0");
                        email_awaiting.str_error = ((!DBNull.Value.Equals(rd["str_error"])) ? rd["str_error"] : string.Empty).ToString();
                        email_awaiting.dt_due_date = Convert.ToDateTime((!DBNull.Value.Equals(rd["dt_due_date"])) ? rd["dt_due_date"] : DateTime.Now);
                        email_awaiting.dt_inserted_date = Convert.ToDateTime((!DBNull.Value.Equals(rd["dt_inserted_date"])) ? rd["dt_inserted_date"] : DateTime.MinValue);
                        email_awaiting.dt_send_date = Convert.ToDateTime((!DBNull.Value.Equals(rd["dt_send_date"])) ? rd["dt_send_date"] : DateTime.MinValue);
                        email_awaiting.dt_expire_date = Convert.ToDateTime((!DBNull.Value.Equals(rd["dt_expire_date"])) ? rd["dt_expire_date"] : DateTime.MinValue);
                        email_awaiting.int_failed_count = Convert.ToInt32((!DBNull.Value.Equals(rd["int_failed_count"])) ? rd["int_failed_count"].ToString() : "0");
                        email_awaiting.email_detail_guid = (!DBNull.Value.Equals(rd["email_detail_guid"])) ? rd["email_detail_guid"].ToString() : string.Empty;

                        email_awaitingList.Add(email_awaiting);
                    }
                    rd.NextResult();
                    while (rd.Read())
                    {
                        tbl_email_awaiting_details tbl_email_awaiting_detail = new tbl_email_awaiting_details();
                        tbl_email_awaiting_detail.guid = (!DBNull.Value.Equals(rd["guid"])) ? rd["guid"].ToString() : string.Empty;
                        tbl_email_awaiting_detail.str_subject = (!DBNull.Value.Equals(rd["str_subject"])) ? rd["str_subject"].ToString() : "";
                        tbl_email_awaiting_detail.str_body = ((!DBNull.Value.Equals(rd["str_body"])) ? rd["str_body"] : string.Empty).ToString();
                        tbl_email_awaiting_detail.str_from_address = ((!DBNull.Value.Equals(rd["str_from_address"])) ? rd["str_from_address"] : string.Empty).ToString();
                        tbl_email_awaiting_detail.str_from_name = ((!DBNull.Value.Equals(rd["str_from_name"])) ? rd["str_from_address"] : string.Empty).ToString();
                        tbl_email_awaiting_detail.dt_inserted_date = Convert.ToDateTime((!DBNull.Value.Equals(rd["dt_inserted_date"])) ? rd["dt_inserted_date"] : DateTime.Now);
                        tbl_email_awaiting_detail.dt_inserted_date = Convert.ToDateTime((!DBNull.Value.Equals(rd["dt_inserted_date"])) ? rd["dt_inserted_date"] : DateTime.MinValue);

                        var email_awaitings = email_awaitingList.Where(a => a.email_detail_guid == tbl_email_awaiting_detail.guid);
                        foreach (var email_awaiting in email_awaitings)
                        {
                            email_awaiting.tbl_email_awaiting_details = tbl_email_awaiting_detail;
                        }

                    }
                    rd.NextResult();

                    while (rd.Read())
                    {
                        tbl_email_to_address tbl_email_to_addr = new tbl_email_to_address();
                        tbl_email_to_addr.guid = (!DBNull.Value.Equals(rd["guid"]) ? rd["guid"].ToString() : string.Empty);
                        tbl_email_to_addr.str_email_address = (!DBNull.Value.Equals(rd["str_email_address"])) ? rd["str_email_address"].ToString() : "";
                        tbl_email_to_addr.str_email_name = ((!DBNull.Value.Equals(rd["str_email_name"])) ? rd["str_email_name"] : string.Empty).ToString();
                        tbl_email_to_addr.int_type = Convert.ToInt32((!DBNull.Value.Equals(rd["int_type"])) ? rd["int_type"] : "0");
                        tbl_email_to_addr.email_guid = ((!DBNull.Value.Equals(rd["email_guid"])) ? rd["email_guid"] : string.Empty).ToString();


                        var email_awaiting = email_awaitingList.SingleOrDefault(a => a.guid == tbl_email_to_addr.email_guid);
                        if (email_awaiting.tbl_email_to_address == null)
                            email_awaiting.tbl_email_to_address = new List<tbl_email_to_address>();
                        email_awaiting.tbl_email_to_address.Add(tbl_email_to_addr);
                    }

                    rd.NextResult();

                    while (rd.Read())
                    {
                        tbl_email_attachment tbl_email_attach = new tbl_email_attachment();
                        tbl_email_attach.guid = (!DBNull.Value.Equals(rd["guid"]) ? rd["guid"].ToString() : string.Empty);
                        tbl_email_attach.str_file_path = (!DBNull.Value.Equals(rd["str_file_path"])) ? rd["str_file_path"].ToString() : "";
                        tbl_email_attach.bit_attached = Convert.ToBoolean((!DBNull.Value.Equals(rd["bit_attached"])) ? rd["bit_attached"] : "false");
                        tbl_email_attach.str_file_path = (!DBNull.Value.Equals(rd["str_file_path"])) ? rd["str_file_path"].ToString() : "";
                        tbl_email_attach.str_error = ((!DBNull.Value.Equals(rd["str_error"])) ? rd["str_error"] : "").ToString();
                        tbl_email_attach.email_detail_guid = ((!DBNull.Value.Equals(rd["email_detail_guid"])) ? rd["email_detail_guid"] : "").ToString();

                        var email_awaiting = email_awaitingList.SingleOrDefault(p => p.tbl_email_awaiting_details.guid == tbl_email_attach.email_detail_guid);


                        if (email_awaiting.tbl_email_awaiting_details.tbl_email_attachment == null)
                            email_awaiting.tbl_email_awaiting_details.tbl_email_attachment = new List<tbl_email_attachment>();
                        email_awaiting.tbl_email_awaiting_details.tbl_email_attachment.Add(tbl_email_attach);
                    }
                }
                return email_awaitingList;

            }
        }
        public List<tbl_email_awaiting> GetFailedBulk(int reTryTimes)
        {

            using (SqlConnection DBCon = new SqlConnection(connectionString))
            {
                List<tbl_email_awaiting> email_awaitingList = new List<tbl_email_awaiting>();
                SqlCommand CmdSelect = new SqlCommand("get_faild_email_bulk", DBCon);
                CmdSelect.CommandType = CommandType.StoredProcedure;
                CmdSelect.Connection = DBCon;

                CmdSelect.Parameters.AddWithValue("@re_try_times", SqlDbType.Int).Value = reTryTimes;


                DBCon.Open();

                SqlDataReader rd = CmdSelect.ExecuteReader();
                if (rd.HasRows)
                {
                    while (rd.Read())
                    {
                        tbl_email_awaiting email_awaiting = new tbl_email_awaiting();
                        email_awaiting.guid = (!DBNull.Value.Equals(rd["guid"])) ? rd["guid"].ToString() : string.Empty;
                        email_awaiting.int_status = Convert.ToInt32((!DBNull.Value.Equals(rd["int_status"])) ? rd["int_status"].ToString() : "0");
                        email_awaiting.str_error = ((!DBNull.Value.Equals(rd["str_error"])) ? rd["str_error"] : string.Empty).ToString();
                        email_awaiting.dt_due_date = Convert.ToDateTime((!DBNull.Value.Equals(rd["dt_due_date"])) ? rd["dt_due_date"] : DateTime.Now);
                        email_awaiting.dt_inserted_date = Convert.ToDateTime((!DBNull.Value.Equals(rd["dt_inserted_date"])) ? rd["dt_inserted_date"] : DateTime.MinValue);
                        email_awaiting.dt_send_date = Convert.ToDateTime((!DBNull.Value.Equals(rd["dt_send_date"])) ? rd["dt_send_date"] : DateTime.MinValue);
                        email_awaiting.dt_expire_date = Convert.ToDateTime((!DBNull.Value.Equals(rd["dt_expire_date"])) ? rd["dt_expire_date"] : DateTime.MinValue);
                        email_awaiting.int_failed_count = Convert.ToInt32((!DBNull.Value.Equals(rd["int_failed_count"])) ? rd["int_failed_count"].ToString() : "0");
                        email_awaiting.email_detail_guid = (!DBNull.Value.Equals(rd["email_detail_guid"])) ? rd["email_detail_guid"].ToString() : string.Empty;

                        email_awaitingList.Add(email_awaiting);
                    }
                    rd.NextResult();
                    while (rd.Read())
                    {
                        tbl_email_awaiting_details tbl_email_awaiting_detail = new tbl_email_awaiting_details();
                        tbl_email_awaiting_detail.guid = (!DBNull.Value.Equals(rd["guid"])) ? rd["guid"].ToString() : string.Empty;
                        tbl_email_awaiting_detail.str_subject = (!DBNull.Value.Equals(rd["str_subject"])) ? rd["str_subject"].ToString() : "";
                        tbl_email_awaiting_detail.str_body = ((!DBNull.Value.Equals(rd["str_body"])) ? rd["str_body"] : string.Empty).ToString();
                        tbl_email_awaiting_detail.str_from_address = ((!DBNull.Value.Equals(rd["str_from_address"])) ? rd["str_from_address"] : string.Empty).ToString();
                        tbl_email_awaiting_detail.str_from_name = ((!DBNull.Value.Equals(rd["str_from_name"])) ? rd["str_from_address"] : string.Empty).ToString();
                        tbl_email_awaiting_detail.dt_inserted_date = Convert.ToDateTime((!DBNull.Value.Equals(rd["dt_inserted_date"])) ? rd["dt_inserted_date"] : DateTime.Now);
                        tbl_email_awaiting_detail.dt_inserted_date = Convert.ToDateTime((!DBNull.Value.Equals(rd["dt_inserted_date"])) ? rd["dt_inserted_date"] : DateTime.MinValue);

                        var email_awaitings = email_awaitingList.Where(a => a.email_detail_guid == tbl_email_awaiting_detail.guid);
                        foreach (var email_awaiting in email_awaitings)
                        {
                            email_awaiting.tbl_email_awaiting_details = tbl_email_awaiting_detail;
                        }
                    }
                    rd.NextResult();

                    while (rd.Read())
                    {
                        tbl_email_to_address tbl_email_to_addr = new tbl_email_to_address();
                        tbl_email_to_addr.guid = (!DBNull.Value.Equals(rd["guid"]) ? rd["guid"].ToString() : string.Empty);
                        tbl_email_to_addr.str_email_address = (!DBNull.Value.Equals(rd["str_email_address"])) ? rd["str_email_address"].ToString() : "";
                        tbl_email_to_addr.str_email_name = ((!DBNull.Value.Equals(rd["str_email_name"])) ? rd["str_email_name"] : string.Empty).ToString();
                        tbl_email_to_addr.int_type = Convert.ToInt32((!DBNull.Value.Equals(rd["int_type"])) ? rd["int_type"] : "0");
                        tbl_email_to_addr.email_guid = ((!DBNull.Value.Equals(rd["email_guid"])) ? rd["email_guid"] : string.Empty).ToString();


                        var email_awaiting = email_awaitingList.SingleOrDefault(a => a.guid == tbl_email_to_addr.email_guid);
                        if (email_awaiting.tbl_email_to_address == null)
                            email_awaiting.tbl_email_to_address = new List<tbl_email_to_address>();
                        email_awaiting.tbl_email_to_address.Add(tbl_email_to_addr);
                    }

                    rd.NextResult();

                    while (rd.Read())
                    {
                        tbl_email_attachment tbl_email_attach = new tbl_email_attachment();
                        tbl_email_attach.guid = (!DBNull.Value.Equals(rd["guid"]) ? rd["guid"].ToString() : string.Empty);
                        tbl_email_attach.str_file_path = (!DBNull.Value.Equals(rd["str_file_path"])) ? rd["str_file_path"].ToString() : "";
                        tbl_email_attach.bit_attached = Convert.ToBoolean((!DBNull.Value.Equals(rd["bit_attached"])) ? rd["bit_attached"] : "false");
                        tbl_email_attach.str_file_path = (!DBNull.Value.Equals(rd["str_file_path"])) ? rd["str_file_path"].ToString() : "";
                        tbl_email_attach.str_error = ((!DBNull.Value.Equals(rd["str_error"])) ? rd["str_error"] : "").ToString();
                        tbl_email_attach.email_detail_guid = ((!DBNull.Value.Equals(rd["email_detail_guid"])) ? rd["email_detail_guid"] : "").ToString();

                        var email_awaiting = email_awaitingList.SingleOrDefault(p => p.tbl_email_awaiting_details.guid == tbl_email_attach.email_detail_guid);


                        if (email_awaiting.tbl_email_awaiting_details.tbl_email_attachment == null)
                            email_awaiting.tbl_email_awaiting_details.tbl_email_attachment = new List<tbl_email_attachment>();
                        email_awaiting.tbl_email_awaiting_details.tbl_email_attachment.Add(tbl_email_attach);
                    }
                }
                return email_awaitingList;
            }
        }
        public void UpdateMissedData()
        {
            using (SqlConnection DBCon = new SqlConnection(connectionString))
            {

                SqlCommand CmdSelect = new SqlCommand("set_missed_data", DBCon);
                CmdSelect.CommandType = CommandType.StoredProcedure;
                CmdSelect.Connection = DBCon;



                DBCon.Open();
                CmdSelect.ExecuteNonQuery();



            }

        }
        public bool UpdateData(tbl_email_awaiting email_awaiting)
        {
            bool returnData = false;
            using (SqlConnection DBCon = new SqlConnection(connectionString))
            {

                SqlCommand CmdSelect = new SqlCommand("set_email_status", DBCon);
                CmdSelect.CommandType = CommandType.StoredProcedure;
                CmdSelect.Connection = DBCon;

                CmdSelect.Parameters.AddWithValue("@guid", SqlDbType.UniqueIdentifier).Value = email_awaiting.guid;
                CmdSelect.Parameters.AddWithValue("@int_status", SqlDbType.Int).Value = email_awaiting.int_status;
                CmdSelect.Parameters.AddWithValue("@int_failed_count", SqlDbType.Int).Value = email_awaiting.int_failed_count;
                if (email_awaiting.str_error == null)
                    CmdSelect.Parameters.AddWithValue("@str_error", SqlDbType.VarChar).Value = DBNull.Value;
                else
                    CmdSelect.Parameters.AddWithValue("@str_error", SqlDbType.VarChar).Value = email_awaiting.str_error;
                CmdSelect.Parameters.AddWithValue("@dt_send_date", SqlDbType.DateTime).Value = email_awaiting.dt_send_date;
                DBCon.Open();
                CmdSelect.ExecuteNonQuery();

                returnData = true;

            }

            //using (E_MailerMainDBEntities entity = new E_MailerMainDBEntities())
            //{
            //    for (int a = 0; a < email_awaiting.tbl_email_awaiting_details.tbl_email_attachment.Count; a++)
            //    {
            //        var email_attachment = email_awaiting.tbl_email_awaiting_details.tbl_email_attachment.ElementAt(a);
            //        entity.tbl_email_attachment.Attach(email_attachment);
            //        var entry = entity.Entry(email_attachment);
            //        entry.State = EntityState.Modified;
            //    }

            //    entity.tbl_email_awaiting.Attach(email_awaiting);

            //    var email_awaiting_entry = entity.Entry(email_awaiting);
            //    email_awaiting_entry.State = EntityState.Modified;

            //    entity.SaveChanges();
            //    returnData = true;

            //}

            return returnData;

        }
    }
}
