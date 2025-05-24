-- Вставляем 1000 сотрудникков
WITH Numbers AS (
    SELECT TOP (1000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM master.dbo.spt_values
)
INSERT INTO [dbo].[Employee] ([LOGIN_NAME], [SURNAME], [NAME], [PATRONYMIC])
SELECT 
    CONCAT('user', n),
    CONCAT('Surname', n),
    CONCAT('Name', n),
    CONCAT('Patronymic', n)
FROM Numbers;


-- Вставляем 5 статусов заказа
INSERT INTO [dbo].[WorkStatus] ([StatusName])
VALUES 
('New'),
('In Progress'),
('Completed'),
('On Hold'),
('Cancelled');


-- Вставляем 50000 заказов
WITH Numbers AS (
    SELECT TOP (50000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM master.dbo.spt_values a
    CROSS JOIN master.dbo.spt_values b
)
INSERT INTO [dbo].[Works] (
    [CREATE_Date], 
    [MaterialNumber], 
    [IS_Complit], 
    [FIO], 
    [Id_Employee], 
    [StatusId], 
    [Print_Date], 
    [SendToClientDate], 
    [SendToDoctorDate], 
    [SendToOrgDate], 
    [SendToFax]
)
SELECT 
    DATEADD(DAY, (ABS(CHECKSUM(NEWID())) % 3650), '2010-01-01'),  -- случайная CREATE_Date между 2010-м и 2020-м
    CAST(ROUND((ABS(CHECKSUM(NEWID())) % 100000) / 100.0, 2) AS DECIMAL(8, 2)),  -- случайный MaterialNumber
    CASE WHEN (ABS(CHECKSUM(NEWID())) % 2) = 0 THEN 1 ELSE 0 END,  -- случайный статус IS_Complit (0 или 1)
    CONCAT('Employee ', (ABS(CHECKSUM(NEWID())) % 1000) + 1),  -- случайное FIO
    (ABS(CHECKSUM(NEWID())) % 1000) + 1,  -- случайный Id_Employee (ссылается на Employee)
    (ABS(CHECKSUM(NEWID())) % 5) + 1,  -- случайный StatusId (от 1 до 5-ти, ссылается на WorkStatus)
    CASE WHEN (ABS(CHECKSUM(NEWID())) % 2) = 0 THEN DATEADD(DAY, (ABS(CHECKSUM(NEWID())) % 30), GETDATE()) ELSE NULL END,  -- случайная Print_Date или NULL
    CASE WHEN (ABS(CHECKSUM(NEWID())) % 2) = 0 THEN DATEADD(DAY, (ABS(CHECKSUM(NEWID())) % 30), GETDATE()) ELSE NULL END,  -- случайная SendToClientDate или NULL
    CASE WHEN (ABS(CHECKSUM(NEWID())) % 2) = 0 THEN DATEADD(DAY, (ABS(CHECKSUM(NEWID())) % 30), GETDATE()) ELSE NULL END,  -- случайная SendToDoctorDate или NULL
    CASE WHEN (ABS(CHECKSUM(NEWID())) % 2) = 0 THEN DATEADD(DAY, (ABS(CHECKSUM(NEWID())) % 30), GETDATE()) ELSE NULL END,  -- случайная SendToOrgDate или NULL
    CASE WHEN (ABS(CHECKSUM(NEWID())) % 2) = 0 THEN DATEADD(DAY, (ABS(CHECKSUM(NEWID())) % 30), GETDATE()) ELSE NULL END   -- случайная SendToFax или NULL
FROM Numbers;


-- Вставляем виды анализов
INSERT INTO [dbo].[Analiz] ([IS_GROUP], [MATERIAL_TYPE], [CODE_NAME], [FULL_NAME], [ID_ILL], [Text_Norm], [Price])
VALUES 
(0, 1, 'A123', 'Basic Analysis', NULL, 'Standard analysis description', 50.00),
(0, 2, 'B234', 'Advanced Analysis', NULL, 'Detailed analysis for advanced diagnostics', 120.00),
(1, 1, 'C345', 'Group Analysis 1', NULL, 'Group analysis for batch processing', 200.00),
(0, 3, 'D456', 'Preliminary Analysis', NULL, 'Initial analysis with simple testing', 40.00),
(1, 2, 'E567', 'Group Analysis 2', NULL, 'Group analysis for multiple diagnostics', 150.00);


-- Вставляем виды SelectType
INSERT INTO [dbo].[SelectType] ([SelectType])
VALUES 
('Type1'),
('Type2'),
('Type3'),
('Type4'),
('Type5');


-- Вставляем 50000 WorkItem'ов
WITH WorkPool AS (
    SELECT Id_Work
    FROM dbo.Works
),
RandomCounts AS (
    SELECT 
        wp.Id_Work,
        ABS(CHECKSUM(NEWID())) % 5 + 1 AS ItemCount  -- случайное число от 1 до 5
    FROM WorkPool wp
),
Expanded AS (
    SELECT 
        rc.Id_Work,
        ROW_NUMBER() OVER (PARTITION BY rc.Id_Work ORDER BY (SELECT NULL)) AS rn
    FROM RandomCounts rc
    CROSS APPLY (
        SELECT TOP (rc.ItemCount) 1 AS some_column FROM master.dbo.spt_values WHERE type = 'P'
    ) filler
),
Limited AS (
    SELECT TOP (50000)
        Id_Work,
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM Expanded
)
INSERT INTO dbo.WorkItem (
    CREATE_DATE, 
    Is_Complit, 
    Close_Date, 
    Id_Employee, 
    ID_ANALIZ, 
    Id_Work, 
    Is_Print, 
    Is_Select, 
    Is_NormTextPrint, 
    Price, 
    Id_SelectType
)
SELECT 
    DATEADD(DAY, (ABS(CHECKSUM(NEWID())) % 3650), '2010-01-01'),  -- CREATE_DATE
    n % 2,  -- Is_Complit
    CASE WHEN n % 2 = 0 THEN DATEADD(DAY, n % 365, GETDATE()) ELSE NULL END,  -- Close_Date
    (n % 1000) + 1,  -- Id_Employee
    (n % 5) + 1,     -- ID_ANALIZ
    Id_Work,
    n % 2,  -- Is_Print
    (n / 2) % 2,  -- Is_Select
    (n / 3) % 2,  -- Is_NormTextPrint
    CAST(ROUND((n % 1000) / 10.0, 2) AS DECIMAL(8, 2)),  -- Price
    (n % 5) + 1  -- Id_SelectType
FROM Limited;


-- Случайные 7% заказов отменяем
WITH ToDelete AS (
    SELECT TOP (7) PERCENT *
    FROM dbo.Works
    ORDER BY NEWID()
)
UPDATE ToDelete
SET Is_Del = 1;