USE [E_MailerMainDB]
GO
/****** Object:  StoredProcedure [dbo].[get_email_attachments_email_detail_id]    Script Date: 8/4/2015 1:50:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE  PROCEDURE [dbo].[get_email_attachments_email_detail_id](@guid uniqueidentifier) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
   SELECT [guid], str_file_path, bit_attached, str_error FROM [dbo].[tbl_email_attachment] WHERE [email_detail_guid]=@guid
               
END

GO
/****** Object:  StoredProcedure [dbo].[get_email_awaiting_details_by_id]    Script Date: 8/4/2015 1:50:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE  PROCEDURE [dbo].[get_email_awaiting_details_by_id](@guid uniqueidentifier) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT [guid], str_subject, str_body, str_from_address, str_from_name, dt_inserted_date
	FROM [dbo].[tbl_email_awaiting_details]
	WHERE [guid]=@guid
               
END

GO
/****** Object:  StoredProcedure [dbo].[get_email_bulk]    Script Date: 8/4/2015 1:50:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE  PROCEDURE [dbo].[get_email_bulk](@filterDate datetime,@numberofmail int) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @awaiting_Table TABLE ([guid] uniqueidentifier)
	DECLARE @awaiting_detail_Table TABLE ([guid] uniqueidentifier)


	
    UPDATE TOP (@numberofmail) TEA set TEA.int_status=2
	OUTPUT  INSERTED.[guid] INTO @awaiting_Table([guid]) 
	FROM [tbl_email_awaiting] TEA
	WHERE  dt_due_date  <= @filterDate   AND  dt_expire_date > GETDATE() AND int_status=0
	
	INSERT INTO @awaiting_detail_Table([guid]) SELECT [email_detail_guid] FROM  [dbo].[tbl_email_awaiting] WHERE [guid] IN (SELECT [guid] FROM @awaiting_Table)


	SELECT [guid], int_status, str_error, dt_due_date, dt_inserted_date, dt_send_date, dt_expire_date, int_failed_count, email_detail_guid
	FROM [dbo].[tbl_email_awaiting] WHERE [guid] IN (SELECT [guid] FROM @awaiting_Table)


	SELECT [guid], str_subject, str_body, str_from_address, str_from_name, dt_inserted_date FROM [dbo].[tbl_email_awaiting_details]
	WHERE [guid] IN (SELECT [guid] FROM @awaiting_detail_Table)

	SELECT [guid], str_email_address, str_email_name, int_type, email_guid FROM [dbo].[tbl_email_to_address]
	WHERE email_guid IN (SELECT [guid] FROM @awaiting_Table)

	SELECT [guid], str_file_path, bit_attached, str_error, email_detail_guid FROM [dbo].[tbl_email_attachment]
	WHERE [email_detail_guid] IN (SELECT [guid] FROM @awaiting_detail_Table)
	

               
END

GO
/****** Object:  StoredProcedure [dbo].[get_email_summary]    Script Date: 8/4/2015 1:50:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE  PROCEDURE [dbo].[get_email_summary]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @AwaitingToSent int,@AwaitingToSentfaild int,@SendFail int,@SuccessfullySent int,@InProcessOfSending int,@failedCount INT
	
	SET @failedCount=ISNULL((SELECT [VALUE] FROM [dbo].[tbl_setting] WHERE [KEY]='ReTryTime'),5)

	SET @AwaitingToSent =ISNULL((SELECT COUNT(*) FROM [dbo].[tbl_email_awaiting] WHERE int_status=0),0)
	SET @AwaitingToSentfaild =ISNULL((SELECT COUNT(*) FROM [dbo].[tbl_email_awaiting] WHERE int_status=-1 AND int_status<@failedCount),0)
	SET @SendFail =ISNULL((SELECT COUNT(*) FROM [dbo].[tbl_email_awaiting] WHERE int_status=-1 AND int_status=@failedCount),0)
	SET @SuccessfullySent =ISNULL((SELECT COUNT(*) FROM [dbo].[tbl_email_awaiting] WHERE int_status=255 UNION SELECT COUNT(*) FROM [dbo].[tbl_sent_email] WHERE int_status=255),0)
	SET @InProcessOfSending =ISNULL((SELECT COUNT(*) FROM [dbo].[tbl_email_awaiting] WHERE int_status=2),0)	
             
	SELECT   @AwaitingToSent AS AwaitingToSent,@AwaitingToSentfaild AS AwaitingToSentfaild,@SendFail AS SendFail,@SuccessfullySent AS SuccessfullySent,@InProcessOfSending AS InProcessOfSending
END

GO
/****** Object:  StoredProcedure [dbo].[get_email_to_address__email_id]    Script Date: 8/4/2015 1:50:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE  PROCEDURE [dbo].[get_email_to_address__email_id](@guid uniqueidentifier) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	

	SELECT [guid], str_email_address, str_email_name, int_type, email_guid
	FROM [dbo].[tbl_email_to_address]
	WHERE [email_guid]=@guid
               
END

GO
/****** Object:  StoredProcedure [dbo].[get_emails_by_status]    Script Date: 8/4/2015 1:50:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE  PROCEDURE [dbo].[get_emails_by_status](@filterDate datetime,@status int) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @awaiting_Table TABLE ([guid] uniqueidentifier)
	DECLARE @awaiting_detail_Table TABLE ([guid] uniqueidentifier)


	
    INSERT INTO @awaiting_Table([guid]) SELECT [guid]
	FROM [tbl_email_awaiting] 
	WHERE  dt_due_date  <= @filterDate   AND int_status=@status
	
	INSERT INTO @awaiting_detail_Table([guid]) SELECT [email_detail_guid] FROM  [dbo].[tbl_email_awaiting] WHERE [guid] IN (SELECT [guid] FROM @awaiting_Table)


	SELECT [guid], int_status, str_error, dt_due_date, dt_inserted_date, dt_send_date, dt_expire_date, int_failed_count, email_detail_guid
	FROM [dbo].[tbl_email_awaiting] WHERE [guid] IN (SELECT [guid] FROM @awaiting_Table)


	SELECT [guid], str_subject, str_body, str_from_address, str_from_name, dt_inserted_date FROM [dbo].[tbl_email_awaiting_details]
	WHERE [guid] IN (SELECT [guid] FROM @awaiting_detail_Table)

	SELECT [guid], str_email_address, str_email_name, int_type, email_guid FROM [dbo].[tbl_email_to_address]
	WHERE email_guid IN (SELECT [guid] FROM @awaiting_Table)

	SELECT [guid], str_file_path, bit_attached, str_error, email_detail_guid FROM [dbo].[tbl_email_attachment]
	WHERE [email_detail_guid] IN (SELECT [guid] FROM @awaiting_detail_Table)
	

               
END

GO
/****** Object:  StoredProcedure [dbo].[get_faild_email_bulk]    Script Date: 8/4/2015 1:50:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE  PROCEDURE [dbo].[get_faild_email_bulk](@re_try_times int) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @awaiting_Table TABLE ([guid] uniqueidentifier)
	DECLARE @awaiting_detail_Table TABLE ([guid] uniqueidentifier)



	UPDATE  TEA set TEA.int_status=2
	OUTPUT  INSERTED.[guid] INTO @awaiting_Table([guid])  
	FROM [tbl_email_awaiting] TEA
	WHERE [int_status]=-1 AND [int_failed_count] < @re_try_times

	INSERT INTO @awaiting_detail_Table([guid]) SELECT [email_detail_guid] FROM  [dbo].[tbl_email_awaiting] WHERE [guid] IN (SELECT [guid] FROM @awaiting_Table)


	SELECT [guid], int_status, str_error, dt_due_date, dt_inserted_date, dt_send_date, dt_expire_date, int_failed_count, email_detail_guid
	FROM [dbo].[tbl_email_awaiting] WHERE [guid] IN (SELECT [guid] FROM @awaiting_Table)


	SELECT [guid], str_subject, str_body, str_from_address, str_from_name, dt_inserted_date FROM [dbo].[tbl_email_awaiting_details]
	WHERE [guid] IN (SELECT [guid] FROM @awaiting_detail_Table)

	SELECT [guid], str_email_address, str_email_name, int_type, email_guid FROM [dbo].[tbl_email_to_address]
	WHERE email_guid IN (SELECT [guid] FROM @awaiting_Table)

	SELECT [guid], str_file_path, bit_attached, str_error, email_detail_guid FROM [dbo].[tbl_email_attachment]
	WHERE [email_detail_guid] IN (SELECT [guid] FROM @awaiting_detail_Table)
	
END

GO
/****** Object:  StoredProcedure [dbo].[get_setting]    Script Date: 8/4/2015 1:50:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE  PROCEDURE [dbo].[get_setting]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	

	SELECT id, [key], value FROM [dbo].[tbl_setting] 
               
END

GO
/****** Object:  StoredProcedure [dbo].[get_setting_from_key]    Script Date: 8/4/2015 1:50:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE  PROCEDURE [dbo].[get_setting_from_key](@key varchar(100),@defaultVal varchar(100)) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	IF((SELECT [id] FROM [dbo].[tbl_setting] WHERE [key]=@key) IS NULL)
	BEGIN
		INSERT INTO [dbo].[tbl_setting]([key], value) VALUES(@key,@defaultVal)
	END

	SELECT id, [key], value FROM [dbo].[tbl_setting] WHERE [key]=@key
               
END

GO
/****** Object:  StoredProcedure [dbo].[set_email_status]    Script Date: 8/4/2015 1:50:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE  PROCEDURE [dbo].[set_email_status](@guid uniqueidentifier,@int_status int,@int_failed_count int,@str_error varchar(250),@dt_send_date datetime)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	
	UPDATE [dbo].[tbl_email_awaiting] SET [int_status]=@int_status,int_failed_count=@int_failed_count,str_error=@str_error,dt_send_date=@dt_send_date  WHERE [guid]=@guid
	
               
END

GO
/****** Object:  StoredProcedure [dbo].[set_missed_data]    Script Date: 8/4/2015 1:50:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE  PROCEDURE [dbo].[set_missed_data]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	
	UPDATE [dbo].[tbl_email_awaiting] SET [int_status]=0  WHERE [int_status]=2
	
               
END

GO
/****** Object:  StoredProcedure [dbo].[set_setting_for_key]    Script Date: 8/4/2015 1:50:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE  PROCEDURE [dbo].[set_setting_for_key](@key varchar(100),@val varchar(100)) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	IF((SELECT [id] FROM [dbo].[tbl_setting] WHERE [key]=@key) IS NULL)
	BEGIN
		INSERT INTO [dbo].[tbl_setting]([key], value) VALUES(@key,@val)
	END
	ELSE
		UPDATE [dbo].[tbl_setting] SET value=@val  WHERE [key]=@key
	
               
END

GO
/****** Object:  Table [dbo].[tbl_email_attachment]    Script Date: 8/4/2015 1:50:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_email_attachment](
	[guid] [uniqueidentifier] NOT NULL,
	[str_file_path] [varchar](max) NULL,
	[bit_attached] [bit] NULL,
	[str_error] [nvarchar](555) NULL,
	[email_detail_guid] [uniqueidentifier] NULL,
 CONSTRAINT [PK_tbl_email_attachment_1] PRIMARY KEY CLUSTERED 
(
	[guid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_email_awaiting]    Script Date: 8/4/2015 1:50:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_email_awaiting](
	[guid] [uniqueidentifier] NOT NULL,
	[int_status] [int] NULL,
	[str_error] [nvarchar](555) NULL,
	[dt_due_date] [datetime] NULL,
	[dt_inserted_date] [datetime] NULL,
	[dt_send_date] [datetime] NULL,
	[dt_expire_date] [datetime] NULL,
	[int_failed_count] [int] NULL,
	[email_detail_guid] [uniqueidentifier] NULL,
 CONSTRAINT [PK_tbl_email_awaiting_1] PRIMARY KEY CLUSTERED 
(
	[guid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tbl_email_awaiting_details]    Script Date: 8/4/2015 1:50:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_email_awaiting_details](
	[guid] [uniqueidentifier] NOT NULL,
	[str_subject] [nvarchar](255) NULL,
	[str_body] [text] NULL,
	[str_from_address] [varchar](255) NULL,
	[str_from_name] [nvarchar](255) NULL,
	[dt_inserted_date] [datetime] NULL,
 CONSTRAINT [PK_tbl_email_awaiting_details] PRIMARY KEY CLUSTERED 
(
	[guid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_email_to_address]    Script Date: 8/4/2015 1:50:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_email_to_address](
	[guid] [uniqueidentifier] NOT NULL,
	[str_email_address] [varchar](255) NULL,
	[str_email_name] [varchar](255) NULL,
	[int_type] [int] NULL,
	[email_guid] [uniqueidentifier] NULL,
 CONSTRAINT [PK_tbl_email_to_address_1] PRIMARY KEY CLUSTERED 
(
	[guid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_sent_email]    Script Date: 8/4/2015 1:50:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_sent_email](
	[guid] [uniqueidentifier] NOT NULL,
	[int_status] [int] NULL,
	[str_error] [nvarchar](555) NULL,
	[dt_due_date] [datetime] NULL,
	[dt_inserted_date] [datetime] NULL,
	[dt_send_date] [datetime] NULL,
	[dt_expire_date] [datetime] NULL,
	[int_failed_count] [int] NULL,
	[email_detail_guid] [uniqueidentifier] NULL,
 CONSTRAINT [PK_tbl_email_sent] PRIMARY KEY CLUSTERED 
(
	[guid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tbl_sent_email_address]    Script Date: 8/4/2015 1:50:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_sent_email_address](
	[guid] [uniqueidentifier] NOT NULL,
	[str_email_address] [varchar](255) NULL,
	[str_email_name] [varchar](255) NULL,
	[int_type] [int] NULL,
	[email_guid] [uniqueidentifier] NULL,
 CONSTRAINT [PK_tbl_email_sent_adress] PRIMARY KEY CLUSTERED 
(
	[guid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_setting]    Script Date: 8/4/2015 1:50:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_setting](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[key] [varchar](255) NULL,
	[value] [varchar](255) NULL,
 CONSTRAINT [PK_tbl_setting] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
INSERT [dbo].[tbl_email_awaiting] ([guid], [int_status], [str_error], [dt_due_date], [dt_inserted_date], [dt_send_date], [dt_expire_date], [int_failed_count], [email_detail_guid]) VALUES (N'012cd8d3-3972-41d6-ab28-8c052bd08711', 255, NULL, CAST(0x0000A4E400000000 AS DateTime), CAST(0x0000A4E400000000 AS DateTime), CAST(0x0000A4EA00E30647 AS DateTime), CAST(0x0000A50500000000 AS DateTime), 0, N'809d24bb-8f9f-4309-bf07-b7d6b9fbf099')
GO
INSERT [dbo].[tbl_email_awaiting] ([guid], [int_status], [str_error], [dt_due_date], [dt_inserted_date], [dt_send_date], [dt_expire_date], [int_failed_count], [email_detail_guid]) VALUES (N'c4eca045-a725-48dc-85f4-f1c0e7309084', -1, N'A recipient must be specified.', CAST(0x0000A4E400000000 AS DateTime), CAST(0x0000A4E400000000 AS DateTime), CAST(0x0000A4E500EA724C AS DateTime), CAST(0x0000A50500000000 AS DateTime), 5, N'809d24bb-8f9f-4309-bf07-b7d6b9fbf099')
GO
INSERT [dbo].[tbl_email_awaiting_details] ([guid], [str_subject], [str_body], [str_from_address], [str_from_name], [dt_inserted_date]) VALUES (N'809d24bb-8f9f-4309-bf07-b7d6b9fbf099', N'Test', N'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!-- saved from url=(0105)http://ebm.i.wix.com/c/tag/hBVuP12B7vd$iB9D2JVNt0jdcFW/doc.html?t_params=EMAIL%3Dweilunkwan%2540gmail.com -->
<html xmlns="http://www.w3.org/1999/xhtml"><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"><meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0">
	
	<meta name="format-detection" content="telephone=no">
	<!-- rpcampaign: BigstockEN20150727-->
	<script type="application/ld+json">
{
  "@context": "http://schema.org",
  "@type": "Offer",
  "image": "http://f.i.wix.com/i/11/2076041122/promotion_tab_BS.jpg"
}

</script><title>Wix.com</title><style type="text/css">
		.ReadMsgBody {width:100%;background-color:#ffffff}.ExternalClass {width:100%;background-color:#ffffff}.ExternalClass, .ExternalClass p, .ExternalClass span, .ExternalClass font, .ExternalClass td, .ExternalClass div {line-height:90%}
		body {-webkit-text-size-adjust:none;-ms-text-size-adjust:none;font-family:Helvetica,arial,sans-serif}
		body {margin:0;padding:0}
		table {border-spacing:0}
		table td {border-collapse:collapse}
		.yshortcuts a {border-bottom:none!important}
		a {text-decoration:none}
		.center {text-align:center}
		.corners-small {-webkit-border-radius:30px;-moz-border-radius:30px;border-radius:30px}
		div.desktop-header {color:#ffffff}
		.header-wrapper {padding-bottom:0!important}
		.btn {text-align:center;padding-top:6px;padding-bottom:6px}
		.cta-btn {padding-top:12px;padding-bottom:12px}
		.btn-color {background-color:#faa33a;color:#ffffff}
		table.container {width:600px!important}
		@media only screen and (max-width:600px) {
			body[yahoo] .text-block-2 {font-size: 20px!important;line-height: 26px!important;}
			body[yahoo] .light-blue {background-color: #f4f9ff!important;}
			body[yahoo] span[class=unclick] a{pointer-events:none!important;color: #ffffff!important}
			body[yahoo] .mobile-br {display: block!important}
			body[yahoo] .samsung-br {display: block!important}
			body[yahoo] .header-wrapper {padding-bottom:0!important}
			body[yahoo] .btn {display:inline-block;text-align:center;width:100%;margin:auto}
			body[yahoo] .cta-btn {padding-top:10px;padding-bottom:10px;display:block;width:70%!important;font-size:22px}
			body[yahoo] div, span{text-size-adjust:none}
			body[yahoo] .invisible-text, body[yahoo] .invisible-text a{color:#f2f2f2!important}
			body[yahoo] .container-padding {-webkit-border-radius:0!important;padding-left:6.5%!important;padding-right:6.5%!important}
			body[yahoo] .header-wrapper {padding-bottom:0}
			body[yahoo] img.divider-img {width:100%;max-width:570px}
			body[yahoo] .desktop-header {display:none}
			body[yahoo] div {-webkit-text-size-adjust:none}
			body[yahoo] .mobile-header {display:block!important;width:100%}
			body[yahoo] table.container {width:100%!important;padding-left:0!important;padding-right:0!important}
			body[yahoo] .hidden {width:1px!important}
			body[yahoo] .logo-space {width:20px}
			body[yahoo] .center {text-align:center!important}
			body[yahoo] .invisible {display:none!important}
			body[yahoo] .desktop-block {display:none!important}
			body[yahoo] .mobile-header-image {width:100%}
			body[yahoo] .mobile-block-holder {width:100%!important;height:auto!important;max-width:none!important;max-height:none!important;display:block!important}
			body[yahoo] .mobile-block {display:block!important}
			body[yahoo] .mobile-centered {text-align:center!important;vertical-align:middle!important}
			body[yahoo] .mobile-centered img {display:inline}
			body[yahoo] .social-icons img { width:8%}
			body[yahoo] .fcs { min-width:0!important}
			body[yahoo] .mobile-disclaimer{background-color:#f2f2f2}
			body[yahoo] .mobile-br{display: block!important;}

		}
		@media only screen and (min-width:560px) and (max-width:600px) {body[yahoo] .text-block {font-size:100%!important;line-height:18%}
		}
		@media only screen and (min-width:540px) and (max-width:600px) {
			body[yahoo] .text-block {font-size:160%!important;line-height:140%!important}
			/*body[yahoo] span.text-block {font-size:160%!important;line-height:140%!important}*/
			body[yahoo] .text-block-2 {font-size:120%!important;line-height:140%!important}
			body[yahoo] .extra-padding{padding-top:10px!important}
			body[yahoo] .padding-bottom-SD-150 {padding-bottom:130px!important;padding-top:15px!important}
			body[yahoo] .padding-bottom-SD-130 {padding-bottom:100px!important;padding-top:15px!important}
			body[yahoo] .padding-bottom-SD-extra {padding-bottom:490px!important;padding-top:15px!important}
			body[yahoo] .padding-top-SD {padding-top:8px!important;width: 17%!important}

		}
		@media only screen and (min-device-width: 322px) and (max-width: 539px) {
			body[yahoo] .text-block {font-size: 85% !important;line-height: 140% !important;}
			body[yahoo] .text-block-title {font-size: 100% !important;line-height: 115% !important;}
			body[yahoo] .mobile-bullet-padding {padding-bottom: 110px !important;}
			body[yahoo] .SND-align{padding-top: 2px!important;}
			body[yahoo] .mobile-br-sg{display: block!important;}
			body[yahoo] .mobile-styling{font-size: 125%!important;padding: 15px 0!important;}
		}
		@media only screen and (min-width: 320px) and (max-width: 320px) {
			body[yahoo] .mobile-bullet-padding {padding-bottom: 90px!important;}
			body[yahoo] .text-block {font-size: 95% !important;line-height: 130% !important;}
			body[yahoo] .text-block-title {font-size: 18% !important;line-height: 130% !important;}
			body[yahoo] .mobile-styling{font-size: 120%!important;padding: 15px 0!important;}
		}
		.mobile-block-holder {width:0;height:0;max-width:0;max-height:0;overflow:hidden}
		.mobile-block-holder, .mobile-block, .mobile-header {display:none}
		.desktop-block, .desktop-header, .desktop-image{
			display:block;
		}
		.disclaimer {font-size:9px!important}
	</style></head><body onload="" yahoo="fix" style="margin:0;padding:0;background-color:#ffffff" bgcolor="#ffffff;font-family:Arial, &#39;Helvetica&#39;, sans-serif" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">

	

	
	


<div class="invisible-text desktop-block" style="overflow:hidden;max-height:0;max-width:0;height:0;width:0;display:none">Choose from hundreds of thousands of new high-quality images taken by professional photographers from around the world.</div><table border="0" width="100%" cellpadding="0" cellspacing="0" bgcolor="#f2f2f2" class="fcs" style="min-width:600px;width:100%;background-color:#f2f2f2"><tbody><tr><td align="center" style="text-align: center;"><div class="desktop-block" style="font-size: 10px;"><br></div></td></tr><tr><td align="center" valign="top" bgcolor="#f2f2f2" style="background-color:#f2f2f2;width:1440px"><table border="0" width="600" cellpadding="0" cellspacing="0" class="container fcs" bgcolor="#ffffff" style="min-width:600px;width:600px;table-layout:fixed"><tbody><tr><td class="fcs" style="min-width:600px;background-color: #ffffff" bgcolor="#ffffff"><table width="100%" style="width:100%"><tbody><tr valign="bottom"><td><div class="desktop-block"><table cellpadding="0" cellspacing="0" width="100%" style="width:100%;vertical-align:bottom"><tbody><tr><td style="width:600px;padding-left:25px;padding-bottom:10px;padding-top:15px" align="left"><img src="./sample-email_files/wix_logo_publish.png" style="width:115px" width="115"></td></tr></tbody></table></div></td></tr><tr><td><table border="0" cellpadding="0" cellspacing="0" class="" width="100%"><tbody><tr><td width="100%"><div class="mobile-block-holder" style="overflow:hidden;max-height:0;max-width:0;height:0;width:0"><div class="mobile-block center" style="text-align:center;padding-bottom:20px; padding-top:10px; width:100%"><div style="padding-top:10px; text-align:center;"><img src="./sample-email_files/logo_publish_resp.png" class="mobile-logo" style="width:33%"></div></div></div></td></tr></tbody></table></td></tr></tbody></table></td></tr><tr><td class="header-wrapper"><div class="desktop-block"><div class="desktop-header corners-large center"><table cellpadding="0" cellspacing="0" border="0" width="600" style="background-color: #ffffff;color: #ffffff;text-align: center;"> <tbody><tr> <td style="text-align: center;background-color: #FFFFFF;padding-bottom: 15px; width: 530px;" align="center"> <a href="http://i.wix.com/a/hBVuP12B7vd$iB9D2JVNt0jdcFW/land8"> <img style="display: inline-block; " src="./sample-email_files/desktop_header_BS.jpg" alt="Find out more"></a> </td> </tr> <tr> <td class="container-padding" style="padding:10px 35px;width:530px"> <table style="width:530px"> <tbody><tr> <td style="font-size:16px;line-height:20px;font-weight:bold;color:#363636;padding-top:10px;padding-bottom: 10px" class="desktop-block" align="left"> <span style="line-height:20px;font-size:16px">Choose from hundreds of thousands of new high-quality images taken by professional photographers from around the world.</span> </td> </tr> <tr> <td style="font-size:16px;line-height:20px;font-weight:normal;color:#363636;" class="desktop-block" align="left"> <span style="line-height:20px;font-size:16px">Each Bigstock image costs only $2.99, so you can make your site look beautiful for less than a cup of coffee.</span> </td> </tr> <tr> <td style="font-size:16px;line-height:20px;font-weight:normal;color:#363636;padding-bottom: 30px; padding-top: 10px" class="desktop-block" align="left"> <span style="line-height:20px;font-size:16px">Whatever your site, whatever your style, find the image that''s right for you.</span> </td> </tr> <tr> <td class="desktop-block" style="padding: 0 0 5px 0;text-align: center"> <!--Desktop button--> <table cellspacing="0" cellpadding="0" style="display: inline-block"> <tbody><tr> <td align="center" bgcolor="#3999ed" style=" background-color: #3999ed; -webkit-border-radius: 30px; -moz-border-radius: 30px; border-radius: 30px; display: block; text-align: center; margin: 0 auto; color: #ffffff; padding: 12px 25px"> <a href="http://i.wix.com/a/hBVuP12B7vd$iB9D2JVNt0jdcFW/land8" style=" color: #ffffff; font-size: 16px; font-weight: normal; font-family: Helvetica, Arial, sans-serif; text-decoration: none; width:100%; display:inline-block">Find Out More</a> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr></tbody></table></div></div></td></tr><tr><td><table border="0" cellpadding="0" cellspacing="0" width="100%" class="mobile-block" style="display: table"><tbody><tr><td width="100%"><div class="mobile-block-holder" style="overflow:hidden;max-height:0px;max-width:0px;height:0px;width:0px;"><div class="mobile-block"> <div class="mobile-block" style="text-align: center;padding: 0 0 20px 0"> <a href="http://i.wix.com/a/hBVuP12B7vd$iB9D2JVNt0jdcFW/land8"> <img style="width: 100%" src="./sample-email_files/responsive_header_BS.jpg"></a> </div> <div class="container-padding mobile-block" style="font-size: 16px;background-color: #ffffff; border: 0; font-weight: bold;text-align: left; padding: 10px"><span class="text-block">Choose from hundreds of thousands of new high-quality images taken by professional photographers from around the world.</span> </div> <div class="container-padding mobile-block" style="font-size: 16px;background-color: #ffffff; border: 0; font-weight: normal;text-align: left; padding: 10px"> <span class="text-block">Each Bigstock image costs only $2.99, so you can make your site look beautiful for less than a cup of coffee.</span> </div> <div class="container-padding mobile-block" style="font-size: 16px;background-color: #ffffff; border: 0; font-weight: normal;text-align: left; padding-top: 10px"> <span class="text-block">Whatever your site, whatever your style, find the image that''s right for you.</span> </div> <div class="mobile-block" style="padding: 30px 0 20px"> <a href="http://i.wix.com/a/hBVuP12B7vd$iB9D2JVNt0jdcFW/land8" class="btn cta-btn corners-small" style="background-color: #3897E9; color: #ffffff!important; ;font-size: 22px; padding-bottom: 12px;padding-top: 12px;"> <span class="text-block"> Find Out More </span> </a> </div></div></div></td></tr></tbody></table></td></tr><tr><td class="header-wrapper" bgcolor="#ffffff"><div class="desktop-block"><div class="desktop-header corners-large center"><table cellpadding="0" cellspacing="0" border="0" width="600" style="background-color: #ffffff;color: #363636;text-align: center;"><tbody><tr><td style="line-height: 5px;padding-top: 20px;padding-bottom: 10px"> <img src="./sample-email_files/SpotTeaser1_desktop_06.jpg"></td></tr><tr><td class="desktop-block" style="padding-bottom: 30px; padding-top: 10px;padding-right: 50px;padding-left: 50px"><table cellpadding="0" cellspacing="0" style="text-align: center; margin: 0 auto;" align="center"><tbody><tr><td colspan="6" style=" padding-bottom: 15px; padding-top: 15px;"><span align="center" style="font-size: 14px; font-weight: normal; color: #363636; text-align:center; ">Stay up to date with our latest news &amp; features</span></td></tr></tbody></table><table cellpadding="0" cellspacing="0" style="text-align: center;margin: 0 auto" align="center"><tbody><tr><td style="height: 32px; padding-right: 10px" width="32px"><a href="http://i.wix.com/a/hBVuP12B7vd$iB9D2JVNt0jdcFW/land11" style="vertical-align: top"><img alt="" src="./sample-email_files/Facebook_Icon_desk.jpeg" style="text-decoration: none; border: 0; width: 32px" width="32"></a></td><td style="height: 32px; padding-right: 10px" width="32px"><a href="http://i.wix.com/a/hBVuP12B7vd$iB9D2JVNt0jdcFW/land5" style="text-decoration: none;vertical-align: top" target="_blank" shape="rect"><img alt="" src="./sample-email_files/Twitter_Icon_desk.jpeg" style="text-decoration: none; border: 0; width: 32px" width="32"></a></td><td style="height: 32px; padding-right: 10px" width="32px"><a href="http://i.wix.com/a/hBVuP12B7vd$iB9D2JVNt0jdcFW/land9" target="_blank" shape="rect" style="vertical-align: top"><img alt="" src="./sample-email_files/GooglePlus_icon_desk.jpeg" style="text-decoration: none; border: 0; width: 32px" width="32"></a></td><td width="32px;" style="width: 32px; padding-right: 10px"><a href="http://i.wix.com/a/hBVuP12B7vd$iB9D2JVNt0jdcFW/land4" target="_blank" shape="rect" style="vertical-align: top"><img alt="" src="./sample-email_files/linkedin_icon_desk.jpeg" style="text-decoration: none; border: 0; width: 32px" width="32"></a></td><td style="height: 32px;padding-right: 10px" width="32px"><a href="http://i.wix.com/a/hBVuP12B7vd$iB9D2JVNt0jdcFW/land3" target="_blank" shape="rect" style="vertical-align: top"><img alt="" src="./sample-email_files/Instagram_Icon_desk.jpeg" style="text-decoration: none; border: 0; width: 32px" width="32"></a></td><td style="height: 32px; " width="32px"><a href="http://i.wix.com/a/hBVuP12B7vd$iB9D2JVNt0jdcFW/land7" target="_blank" shape="rect" style="vertical-align: top"><img src="./sample-email_files/RSS_icon_desk.jpeg" alt="" style="text-decoration: none; border: 0; width: 32px" width="32"></a></td></tr></tbody></table></td></tr></tbody></table></div></div></td></tr><tr><td bgcolor="#ffffff"><table border="0" cellpadding="0" cellspacing="0" width="100%" class="mobile-block"><tbody><tr><td width="100%"><div class="mobile-block-holder" style="width: 0px; height: 0px; max-width: 0px; max-height: 0px; overflow: hidden;"> <div style="text-align: center; padding-top: 10px"> <img src="./sample-email_files/SpotTeaser1_mobile_07.jpg" style="width: 100%" alt=""> </div><div align="center" style="font-size: 14px; color: #363636; text-align:center; padding-top: 25px"><span class="text-block">Stay up to date with our latest<br> news &amp; features</span></div><div class="mobile-centered mobile-block" style="padding: 20px 0"><a href="http://i.wix.com/a/hBVuP12B7vd$iB9D2JVNt0jdcFW/land11" target="_blank" shape="rect"><img alt="" src="./sample-email_files/SO_premium_facebook_resp.jpg" style="padding-right: 10px; text-decoration: none; border: 0;width: 8%"></a><a href="http://i.wix.com/a/hBVuP12B7vd$iB9D2JVNt0jdcFW/land5" target="_blank" shape="rect"><img alt="" src="./sample-email_files/SO_premium_twitter_resp.jpg" style="padding-right: 10px; text-decoration: none; border: 0;width: 8%"></a><a href="http://i.wix.com/a/hBVuP12B7vd$iB9D2JVNt0jdcFW/land9" target="_blank" shape="rect"><img alt="" src="./sample-email_files/SO_premium_google_resp.jpg" style="padding-right: 10px; text-decoration: none; border: 0;width: 8%"></a><a href="http://i.wix.com/a/hBVuP12B7vd$iB9D2JVNt0jdcFW/land4" target="_blank" shape="rect"><img alt="" src="./sample-email_files/SO_premium_linkedin_resp.jpg" style="padding-right: 10px; text-decoration: none; border: 0;width: 8%"></a><a href="http://i.wix.com/a/hBVuP12B7vd$iB9D2JVNt0jdcFW/land3" target="_blank" shape="rect"><img alt="" src="./sample-email_files/SO_premium_instagram_resp.jpg" style="padding-right: 10px; text-decoration: none; border: 0;width: 8%"></a><a href="http://i.wix.com/a/hBVuP12B7vd$iB9D2JVNt0jdcFW/land7" target="_blank" shape="rect"><img alt="" src="./sample-email_files/SO_premium_blog_resp.jpg" style="text-decoration: none; border: 0;width: 8%"></a></div></div></td></tr></tbody></table></td></tr><tr><td align="center" style="text-align: center; font-size:9px; background-color: #f2f2f2" class="disclaimer mobile-disclaimer"><br><!--Disclaimer 
text-->Please do not reply to this email <br>If you wish to unsubscribe <a href="http://i.wix.com/a/hBVuP12B7vd$iB9D2JVNt0jdcFW/land1?email=weilunkwan@gmail.com" target="_blank" shape="rect" style="color:#3899ec;text-decoration: none">click here </a><br>500 Terry A Francois Blvd San Francisco,<img width="0" height="0" style="display: inline" class="mobile-br"> CA 94158<br>View our <a href="http://i.wix.com/a/hBVuP12B7vd$iB9D2JVNt0jdcFW/land6" target="_blank" shape="rect" style="color:#3899ec;text-decoration: none">privacy policy</a><br><br></td></tr></tbody></table></td></tr></tbody></table><div style="display:none; white-space:nowrap; font:15px courier; color:#f2f2f2;">- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -</div><img src="./sample-email_files/spacer.gif">
</body></html>', N'hr@hsbc.lk', N'HSBC', CAST(0x0000A4E400000000 AS DateTime))
GO
INSERT [dbo].[tbl_email_to_address] ([guid], [str_email_address], [str_email_name], [int_type], [email_guid]) VALUES (N'f6b4932b-7b8b-40bf-8935-589ad1f66786', N'weragoda88@gmail.com', N'weragoda', 1, N'012cd8d3-3972-41d6-ab28-8c052bd08711')
GO
SET IDENTITY_INSERT [dbo].[tbl_setting] ON 

GO
INSERT [dbo].[tbl_setting] ([id], [key], [value]) VALUES (1, N'EmailSendInterval', N'0')
GO
INSERT [dbo].[tbl_setting] ([id], [key], [value]) VALUES (2, N'EmailForBulk', N'10')
GO
INSERT [dbo].[tbl_setting] ([id], [key], [value]) VALUES (3, N'SMTPUserName', N'w')
GO
INSERT [dbo].[tbl_setting] ([id], [key], [value]) VALUES (4, N'SMTPPassword', N'1')
GO
INSERT [dbo].[tbl_setting] ([id], [key], [value]) VALUES (5, N'SMTPHostName', N'216.55.99.240')
GO
INSERT [dbo].[tbl_setting] ([id], [key], [value]) VALUES (6, N'SMTPHostPort', N'25')
GO
INSERT [dbo].[tbl_setting] ([id], [key], [value]) VALUES (9, N'EnableSSL', N'false')
GO
INSERT [dbo].[tbl_setting] ([id], [key], [value]) VALUES (10, N'LastRunTime', N'8/4/2015 1:48:20 PM')
GO
INSERT [dbo].[tbl_setting] ([id], [key], [value]) VALUES (11, N'ReTryTime', N'5')
GO
INSERT [dbo].[tbl_setting] ([id], [key], [value]) VALUES (12, N'UseDefaultCredentials', N'false')
GO
INSERT [dbo].[tbl_setting] ([id], [key], [value]) VALUES (13, N'ThreadCount', N'2')
GO
SET IDENTITY_INSERT [dbo].[tbl_setting] OFF
GO
ALTER TABLE [dbo].[tbl_email_attachment] ADD  CONSTRAINT [DF_tbl_email_attachment_guid]  DEFAULT (newid()) FOR [guid]
GO
ALTER TABLE [dbo].[tbl_email_awaiting] ADD  CONSTRAINT [DF_tbl_email_awaiting_guid]  DEFAULT (newid()) FOR [guid]
GO
ALTER TABLE [dbo].[tbl_email_awaiting_details] ADD  CONSTRAINT [DF_tbl_email_awaiting_details_guid]  DEFAULT (newid()) FOR [guid]
GO
ALTER TABLE [dbo].[tbl_email_to_address] ADD  CONSTRAINT [DF_tbl_email_to_address_guid]  DEFAULT (newid()) FOR [guid]
GO
ALTER TABLE [dbo].[tbl_email_attachment]  WITH CHECK ADD  CONSTRAINT [FK_tbl_email_attachment_tbl_email_awaiting_details] FOREIGN KEY([email_detail_guid])
REFERENCES [dbo].[tbl_email_awaiting_details] ([guid])
GO
ALTER TABLE [dbo].[tbl_email_attachment] CHECK CONSTRAINT [FK_tbl_email_attachment_tbl_email_awaiting_details]
GO
ALTER TABLE [dbo].[tbl_email_awaiting]  WITH CHECK ADD  CONSTRAINT [FK_tbl_email_awaiting_tbl_email_awaiting_details] FOREIGN KEY([email_detail_guid])
REFERENCES [dbo].[tbl_email_awaiting_details] ([guid])
GO
ALTER TABLE [dbo].[tbl_email_awaiting] CHECK CONSTRAINT [FK_tbl_email_awaiting_tbl_email_awaiting_details]
GO
ALTER TABLE [dbo].[tbl_email_to_address]  WITH CHECK ADD  CONSTRAINT [FK_tbl_email_to_address_tbl_email_awaiting] FOREIGN KEY([email_guid])
REFERENCES [dbo].[tbl_email_awaiting] ([guid])
GO
ALTER TABLE [dbo].[tbl_email_to_address] CHECK CONSTRAINT [FK_tbl_email_to_address_tbl_email_awaiting]
GO
ALTER TABLE [dbo].[tbl_sent_email]  WITH CHECK ADD  CONSTRAINT [FK_tbl_email_sent_tbl_email_awaiting_details] FOREIGN KEY([email_detail_guid])
REFERENCES [dbo].[tbl_email_awaiting_details] ([guid])
GO
ALTER TABLE [dbo].[tbl_sent_email] CHECK CONSTRAINT [FK_tbl_email_sent_tbl_email_awaiting_details]
GO
ALTER TABLE [dbo].[tbl_sent_email_address]  WITH CHECK ADD  CONSTRAINT [FK_tbl_email_sent_adress_tbl_email_sent] FOREIGN KEY([email_guid])
REFERENCES [dbo].[tbl_sent_email] ([guid])
GO
ALTER TABLE [dbo].[tbl_sent_email_address] CHECK CONSTRAINT [FK_tbl_email_sent_adress_tbl_email_sent]
GO
