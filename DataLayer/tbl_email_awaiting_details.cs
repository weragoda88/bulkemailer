//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace DataLayer
{
    using System;
    using System.Collections.Generic;
    
    public partial class tbl_email_awaiting_details
    {
        public tbl_email_awaiting_details()
        {
            this.tbl_email_attachment = new List<tbl_email_attachment>();
            this.tbl_email_awaiting = new List<tbl_email_awaiting>();
            this.tbl_email_sent = new List<tbl_email_sent>();
        }

        public string guid { get; set; }
        public string str_subject { get; set; }
        public string str_body { get; set; }
        public string str_from_address { get; set; }
        public string str_from_name { get; set; }
        public Nullable<System.DateTime> dt_inserted_date { get; set; }
    
        public virtual ICollection<tbl_email_attachment> tbl_email_attachment { get; set; }
        public virtual ICollection<tbl_email_awaiting> tbl_email_awaiting { get; set; }
        public virtual ICollection<tbl_email_sent> tbl_email_sent { get; set; }
    }
}
