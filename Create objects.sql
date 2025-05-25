/****** Object:  UserDefinedFunction [dbo].[F_EMPLOYEE_FULLNAME_ITVF]    Script Date: 26.05.2025 01:17:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[F_EMPLOYEE_FULLNAME_ITVF]()
RETURNS TABLE
AS
RETURN
SELECT 
    e.ID_EMPLOYEE,
    CASE 
        WHEN e.ID_EMPLOYEE = -1 THEN ''
        WHEN RTRIM(REPLACE(e.SURNAME + ' ' + 
                           UPPER(LEFT(e.NAME, 1)) + '. ' +
                           UPPER(LEFT(e.PATRONYMIC, 1)) + '.', '. .', '')) <> '' 
             THEN RTRIM(REPLACE(e.SURNAME + ' ' + 
                           UPPER(LEFT(e.NAME, 1)) + '. ' +
                           UPPER(LEFT(e.PATRONYMIC, 1)) + '.', '. .', ''))
        ELSE e.LOGIN_NAME
    END AS FULL_NAME
FROM dbo.Employee e;
GO
/****** Object:  UserDefinedFunction [dbo].[F_EMPLOYEE_GET]    Script Date: 28.04.2024 19:21:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[F_EMPLOYEE_GET] ()
RETURNS
  INT
AS
BEGIN
-- Возвращает идентификатор текщего пользователя

  DECLARE
    @RESULT INT

  SELECT
    @RESULT = ID_EMPLOYEE
  FROM
    EMPLOYEE
  WHERE
    LOGIN_NAME = SYSTEM_USER

  RETURN
    @RESULT
END
GO
/****** Object:  UserDefinedFunction [dbo].[F_WORKITEM_COUNTS_BY_COMPLETION]    Script Date: 26.05.2025 01:17:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[F_WORKITEM_COUNTS_BY_COMPLETION] (
    @is_complit BIT
)
RETURNS TABLE
AS
RETURN
    SELECT
        wi.Id_Work,
        COUNT(*) AS ItemCount
    FROM dbo.WorkItem wi
    LEFT JOIN dbo.Analiz a ON wi.ID_ANALIZ = a.ID_ANALIZ
    WHERE wi.Is_Complit = @is_complit
        AND a.Is_Group = 0
    GROUP BY wi.Id_Work;
GO
/****** Object:  UserDefinedFunction [dbo].[F_WORKS_LIST]    Script Date: 28.04.2024 19:21:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION dbo.F_WORKS_LIST_NEW_3()
RETURNS TABLE
AS
RETURN
    SELECT
        w.Id_Work,
        w.CREATE_Date,
        w.MaterialNumber,
        w.IS_Complit,
        w.FIO,
        CONVERT(varchar(10), w.CREATE_Date, 104) AS D_DATE,
        ISNULL(wiNot.ItemCount, 0) AS WorkItemsNotComplit,
        ISNULL(wiDone.ItemCount, 0) AS WorkItemsComplit,
        fe.FULL_NAME AS EmployeeFullName,
        w.StatusId,
        ws.StatusName,
        CASE
            WHEN w.Print_Date IS NOT NULL
              OR w.SendToClientDate IS NOT NULL
              OR w.SendToDoctorDate IS NOT NULL
              OR w.SendToOrgDate IS NOT NULL
              OR w.SendToFax IS NOT NULL
            THEN 1 ELSE 0
        END AS Is_Print
    FROM dbo.Works w
    LEFT JOIN dbo.F_EMPLOYEE_FULLNAME_ITVF() fe ON fe.ID_EMPLOYEE = w.Id_Employee
    LEFT JOIN dbo.F_WORKITEM_COUNTS_BY_COMPLETION(0) wiNot ON wiNot.Id_Work = w.Id_Work
    LEFT JOIN dbo.F_WORKITEM_COUNTS_BY_COMPLETION(1) wiDone ON wiDone.Id_Work = w.Id_Work
    LEFT JOIN WorkStatus ws ON w.StatusId = ws.StatusID
    WHERE w.Is_Del = 0
GO
/****** Object:  Table [dbo].[Analiz]    Script Date: 28.04.2024 19:21:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Analiz](
	[ID_ANALIZ] [int] IDENTITY(1,1) NOT NULL,
	[IS_GROUP] [bit] NULL,
	[MATERIAL_TYPE] [int] NULL,
	[CODE_NAME] [varchar](50) NULL,
	[FULL_NAME] [varchar](255) NULL,
	[ID_ILL] [int] NULL,
	[Text_Norm] [varchar](255) NULL,
	[Price] [decimal](8, 2) NULL,
	[NormText] [varchar](2048) NULL,
	[UnNormText] [varchar](2048) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID_ANALIZ] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Employee]    Script Date: 28.04.2024 19:21:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Employee](
	[Id_Employee] [int] IDENTITY(1,1) NOT NULL,
	[Login_Name] [varchar](50) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Patronymic] [varchar](50) NOT NULL,
	[Surname] [varchar](50) NOT NULL,
	[Email] [varchar](50) NULL,
	[Post] [varchar](50) NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[EraseDate] [datetime] NULL,
	[Archived] [bit] NOT NULL,
	[IS_Role] [bit] NOT NULL,
	[Role] [int] NULL,
	[FULL_NAME]  AS (([SURNAME]+' ')+[NAME]),
PRIMARY KEY CLUSTERED 
(
	[Id_Employee] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Organization]    Script Date: 28.04.2024 19:21:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Organization](
	[ID_ORGANIZATION] [int] IDENTITY(1,1) NOT NULL,
	[ORG_NAME] [varchar](255) NULL,
	[TEMPLATE_FN] [varchar](255) NULL,
	[Id_PrintTemplate] [int] NULL,
	[Email] [varchar](255) NULL,
	[SecondEmail] [varchar](255) NULL,
	[Fax] [varchar](255) NULL,
	[SecondFax] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID_ORGANIZATION] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PrintTemplate]    Script Date: 28.04.2024 19:21:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PrintTemplate](
	[Id_PrintTemplate] [int] IDENTITY(1,1) NOT NULL,
	[TemplateName] [varchar](255) NULL,
	[CreateDate] [datetime] NULL,
	[Ext] [varchar](10) NULL,
	[Comment] [varchar](255) NULL,
	[TemplateBody] [image] NULL,
	[Id_TemplateType] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id_PrintTemplate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SelectType]    Script Date: 28.04.2024 19:21:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SelectType](
	[Id_SelectType] [int] IDENTITY(1,1) NOT NULL,
	[SelectType] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id_SelectType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TemplateType]    Script Date: 28.04.2024 19:21:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TemplateType](
	[Id_TemplateType] [int] IDENTITY(1,1) NOT NULL,
	[TemlateVal] [varchar](50) NULL,
	[Comment] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id_TemplateType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WorkItem]    Script Date: 28.04.2024 19:21:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkItem](
	[ID_WORKItem] [int] IDENTITY(1,1) NOT NULL,
	[CREATE_DATE] [datetime] NULL,
	[Is_Complit] [bit] NOT NULL,
	[Close_Date] [datetime] NULL,
	[Id_Employee] [int] NULL,
	[ID_ANALIZ] [int] NULL,
	[Id_Work] [int] NULL,
	[Is_Print] [bit] NOT NULL,
	[Is_Select] [bit] NOT NULL,
	[Is_NormTextPrint] [bit] NULL,
	[Price] [decimal](8, 2) NULL,
	[Id_SelectType] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID_WORKItem] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Works]    Script Date: 28.04.2024 19:21:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Works](
	[Id_Work] [int] IDENTITY(1,1) NOT NULL,
	[IS_Complit] [bit] NOT NULL,
	[CREATE_Date] [datetime] NULL,
	[Close_Date] [datetime] NULL,
	[Id_Employee] [int] NULL,
	[ID_ORGANIZATION] [int] NULL,
	[Comment] [varchar](255) NULL,
	[Print_Date] [datetime] NULL,
	[Org_Name] [varchar](50) NULL,
	[Part_Name] [varchar](50) NULL,
	[Org_RegN] [int] NULL,
	[Material_Type] [smallint] NULL,
	[Material_Get_Date] [datetime] NULL,
	[Material_Reg_Date] [datetime] NULL,
	[MaterialNumber] [decimal](8, 2) NULL,
	[Material_Comment] [varchar](255) NULL,
	[FIO] [varchar](255) NOT NULL,
	[PHONE] [varchar](50) NULL,
	[EMAIL] [varchar](255) NULL,
	[Is_Del] [bit] NOT NULL,
	[Id_Employee_Del] [int] NULL,
	[DelDate] [datetime] NULL,
	[Price] [decimal](8, 2) NULL,
	[ExtRegN] [varchar](255) NULL,
	[MedicalHistoryNumber] [varchar](255) NULL,
	[DoctorFIO] [varchar](255) NULL,
	[DoctorPhone] [varchar](255) NULL,
	[OrganizationFax] [varchar](255) NULL,
	[OrganizationEmail] [varchar](255) NULL,
	[DoctorEmail] [varchar](255) NULL,
	[StatusId] [smallint] NULL,
	[SendToOrgDate] [datetime] NULL,
	[SendToClientDate] [datetime] NULL,
	[SendToDoctorDate] [datetime] NULL,
	[SendToFax] [datetime] NULL,
	[SendToApp] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id_Work] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WorkStatus]    Script Date: 28.04.2024 19:21:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkStatus](
	[StatusID] [smallint] IDENTITY(1,1) NOT NULL,
	[StatusName] [varchar](255) NULL,
 CONSTRAINT [PK_WorkStatus] PRIMARY KEY CLUSTERED 
(
	[StatusID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [XAKLoginName]    Script Date: 28.04.2024 19:21:25 ******/
CREATE UNIQUE NONCLUSTERED INDEX [XAKLoginName] ON [dbo].[Employee]
(
	[Login_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [XIF1Organization]    Script Date: 28.04.2024 19:21:25 ******/
CREATE NONCLUSTERED INDEX [XIF1Organization] ON [dbo].[Organization]
(
	[Id_PrintTemplate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [XIF1PrintTemplate]    Script Date: 28.04.2024 19:21:25 ******/
CREATE NONCLUSTERED INDEX [XIF1PrintTemplate] ON [dbo].[PrintTemplate]
(
	[Id_TemplateType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [XIF3WorkItem]    Script Date: 28.04.2024 19:21:25 ******/
CREATE NONCLUSTERED INDEX [XIF3WorkItem] ON [dbo].[WorkItem]
(
	[Id_Employee] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [XIF4WorkItem]    Script Date: 28.04.2024 19:21:25 ******/
CREATE NONCLUSTERED INDEX [XIF4WorkItem] ON [dbo].[WorkItem]
(
	[ID_ANALIZ] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [XIF5WorkItem]    Script Date: 28.04.2024 19:21:25 ******/
CREATE NONCLUSTERED INDEX [XIF5WorkItem] ON [dbo].[WorkItem]
(
	[Id_Work] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [XIF6WorkItem]    Script Date: 28.04.2024 19:21:25 ******/
CREATE NONCLUSTERED INDEX [XIF6WorkItem] ON [dbo].[WorkItem]
(
	[Id_SelectType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [XIF1Works]    Script Date: 28.04.2024 19:21:25 ******/
CREATE NONCLUSTERED INDEX [XIF1Works] ON [dbo].[Works]
(
	[Id_Employee] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [XIF2Works]    Script Date: 28.04.2024 19:21:25 ******/
CREATE NONCLUSTERED INDEX [XIF2Works] ON [dbo].[Works]
(
	[ID_ORGANIZATION] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [XIF3Works]    Script Date: 28.04.2024 19:21:25 ******/
CREATE NONCLUSTERED INDEX [XIF3Works] ON [dbo].[Works]
(
	[Id_Employee_Del] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Employee] ADD  DEFAULT (suser_sname()) FOR [Login_Name]
GO
ALTER TABLE [dbo].[Employee] ADD  DEFAULT ('') FOR [Name]
GO
ALTER TABLE [dbo].[Employee] ADD  DEFAULT ('') FOR [Patronymic]
GO
ALTER TABLE [dbo].[Employee] ADD  DEFAULT ('') FOR [Surname]
GO
ALTER TABLE [dbo].[Employee] ADD  DEFAULT ((0)) FOR [Archived]
GO
ALTER TABLE [dbo].[Employee] ADD  DEFAULT ((0)) FOR [IS_Role]
GO
ALTER TABLE [dbo].[Employee] ADD  DEFAULT ((0)) FOR [Role]
GO
ALTER TABLE [dbo].[PrintTemplate] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[WorkItem] ADD  DEFAULT (getdate()) FOR [CREATE_DATE]
GO
ALTER TABLE [dbo].[WorkItem] ADD  DEFAULT ((0)) FOR [Is_Complit]
GO
ALTER TABLE [dbo].[WorkItem] ADD  DEFAULT ((1)) FOR [Is_Print]
GO
ALTER TABLE [dbo].[WorkItem] ADD  DEFAULT ((0)) FOR [Is_Select]
GO
ALTER TABLE [dbo].[WorkItem] ADD  DEFAULT ((1)) FOR [Is_NormTextPrint]
GO
ALTER TABLE [dbo].[Works] ADD  DEFAULT ((0)) FOR [IS_Complit]
GO
ALTER TABLE [dbo].[Works] ADD  DEFAULT (getdate()) FOR [CREATE_Date]
GO
ALTER TABLE [dbo].[Works] ADD  DEFAULT (getdate()) FOR [Material_Get_Date]
GO
ALTER TABLE [dbo].[Works] ADD  DEFAULT (getdate()) FOR [Material_Reg_Date]
GO
ALTER TABLE [dbo].[Works] ADD  DEFAULT ((0)) FOR [Is_Del]
GO
ALTER TABLE [dbo].[Organization]  WITH NOCHECK ADD  CONSTRAINT [FK__Organizat__Id_Pr__14270015] FOREIGN KEY([Id_PrintTemplate])
REFERENCES [dbo].[PrintTemplate] ([Id_PrintTemplate])
GO
ALTER TABLE [dbo].[Organization] CHECK CONSTRAINT [FK__Organizat__Id_Pr__14270015]
GO
ALTER TABLE [dbo].[PrintTemplate]  WITH NOCHECK ADD  CONSTRAINT [FK__PrintTemp__Id_Te__151B244E] FOREIGN KEY([Id_TemplateType])
REFERENCES [dbo].[TemplateType] ([Id_TemplateType])
GO
ALTER TABLE [dbo].[PrintTemplate] CHECK CONSTRAINT [FK__PrintTemp__Id_Te__151B244E]
GO
ALTER TABLE [dbo].[WorkItem]  WITH NOCHECK ADD  CONSTRAINT [FK__WorkItem__ID_ANA__1F98B2C1] FOREIGN KEY([ID_ANALIZ])
REFERENCES [dbo].[Analiz] ([ID_ANALIZ])
GO
ALTER TABLE [dbo].[WorkItem] CHECK CONSTRAINT [FK__WorkItem__ID_ANA__1F98B2C1]
GO
ALTER TABLE [dbo].[WorkItem]  WITH NOCHECK ADD  CONSTRAINT [FK__WorkItem__Id_Emp__208CD6FA] FOREIGN KEY([Id_Employee])
REFERENCES [dbo].[Employee] ([Id_Employee])
GO
ALTER TABLE [dbo].[WorkItem] CHECK CONSTRAINT [FK__WorkItem__Id_Emp__208CD6FA]
GO
ALTER TABLE [dbo].[WorkItem]  WITH NOCHECK ADD  CONSTRAINT [FK__WorkItem__Id_Sel__1DB06A4F] FOREIGN KEY([Id_SelectType])
REFERENCES [dbo].[SelectType] ([Id_SelectType])
GO
ALTER TABLE [dbo].[WorkItem] CHECK CONSTRAINT [FK__WorkItem__Id_Sel__1DB06A4F]
GO
ALTER TABLE [dbo].[WorkItem]  WITH NOCHECK ADD  CONSTRAINT [FK__WorkItem__Id_Wor__1EA48E88] FOREIGN KEY([Id_Work])
REFERENCES [dbo].[Works] ([Id_Work])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[WorkItem] CHECK CONSTRAINT [FK__WorkItem__Id_Wor__1EA48E88]
GO
ALTER TABLE [dbo].[Works]  WITH NOCHECK ADD  CONSTRAINT [FK__Works__Id_Employ__2180FB33] FOREIGN KEY([Id_Employee_Del])
REFERENCES [dbo].[Employee] ([Id_Employee])
GO
ALTER TABLE [dbo].[Works] CHECK CONSTRAINT [FK__Works__Id_Employ__2180FB33]
GO
ALTER TABLE [dbo].[Works]  WITH NOCHECK ADD  CONSTRAINT [FK__Works__Id_Employ__236943A5] FOREIGN KEY([Id_Employee])
REFERENCES [dbo].[Employee] ([Id_Employee])
GO
ALTER TABLE [dbo].[Works] CHECK CONSTRAINT [FK__Works__Id_Employ__236943A5]
GO
ALTER TABLE [dbo].[Works]  WITH NOCHECK ADD  CONSTRAINT [FK__Works__ID_ORGANI__22751F6C] FOREIGN KEY([ID_ORGANIZATION])
REFERENCES [dbo].[Organization] ([ID_ORGANIZATION])
GO
ALTER TABLE [dbo].[Works] CHECK CONSTRAINT [FK__Works__ID_ORGANI__22751F6C]
GO
