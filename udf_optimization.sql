-- Вариант 1 (c WITH)
CREATE FUNCTION dbo.F_WORKS_LIST_NEW()
RETURNS TABLE
AS
RETURN
    WITH WorkItems AS (
        SELECT
            wi.Id_Work,
            SUM(CASE WHEN wi.Is_Complit = 0 AND a.Is_Group = 0 THEN 1 ELSE 0 END) AS WorkItemsNotComplit,
            SUM(CASE WHEN wi.Is_Complit = 1 AND a.Is_Group = 0 THEN 1 ELSE 0 END) AS WorkItemsComplit
        FROM WorkItem wi
        LEFT JOIN Analiz a ON wi.ID_ANALIZ = a.ID_ANALIZ
        GROUP BY wi.Id_Work
    )
    SELECT
        w.Id_Work,
        w.CREATE_Date,
        w.MaterialNumber,
        w.IS_Complit,
        w.FIO,
        CONVERT(varchar(10), w.CREATE_Date, 104) AS D_DATE,
        ISNULL(wi.WorkItemsNotComplit, 0) AS WorkItemsNotComplit,
        ISNULL(wi.WorkItemsComplit, 0) AS WorkItemsComplit,
        dbo.F_EMPLOYEE_FULLNAME(w.Id_Employee) as EmployeeFullName,
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
    LEFT JOIN WorkItems wi ON wi.Id_Work = w.Id_Work
    LEFT JOIN WorkStatus ws ON w.StatusId = ws.StatusID
    WHERE w.Is_Del = 0


-- Вариант 2 (cо встроенной TVF)
CREATE FUNCTION dbo.F_WORKITEM_COUNTS_BY_COMPLETION (
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

CREATE FUNCTION dbo.F_WORKS_LIST_NEW_2()
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
        dbo.F_EMPLOYEE_FULLNAME(w.Id_Employee) as EmployeeFullName,
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
    LEFT JOIN dbo.F_WORKITEM_COUNTS_BY_COMPLETION(0) wiNot ON wiNot.Id_Work = w.Id_Work
    LEFT JOIN dbo.F_WORKITEM_COUNTS_BY_COMPLETION(1) wiDone ON wiDone.Id_Work = w.Id_Work
    LEFT JOIN WorkStatus ws ON w.StatusId = ws.StatusID
    WHERE w.Is_Del = 0


-- Оптимизация dbo.F_EMPLOYEE_FULLNAME (cо встроенной TVF)
CREATE FUNCTION dbo.F_EMPLOYEE_FULLNAME_ITVF()
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


-- Фильтрованный индекс с нужными столбцами
CREATE NONCLUSTERED INDEX IDX_Works_IsDel0
ON dbo.Works (Id_Work, Id_Employee, StatusId)
INCLUDE (
    CREATE_Date,
    MaterialNumber,
    IS_Complit,
    FIO,
    Print_Date,
    SendToClientDate,
    SendToDoctorDate,
    SendToOrgDate, 
    SendToFax
)
WHERE Is_Del = 0;