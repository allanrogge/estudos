-- Selects Gerais para análise exploratória

SELECT FYPer_Key, * FROM [BRdw].[Fact_ProjectIncludedExpensesCosts] WHERE FYPer_Key = '202403';

SELECT COUNT( DISTINCT ProjectJob_Key) FROM [BRdw].[Dim_ProjectJob];

SELECT DISTINCT FYPer_Key FROM [BRdw].[Fact_ProjectIncludedExpensesCosts] ORDER BY FYPer_Key ASC;

SELECT * FROM [BRdw].[Dim_ProjectJob] WHERE COD_Project = '98000009' AND COD_Job IN ('0432');

SELECT * FROM [BRdw].[Fact_ProjectIncludedExpensesCosts];

SELECT BRdw.fProjectHistoryExpensesFull.PROJECT, BRdw_STG.fProjectHistoryExpensesFull.JOB, BRdw_STG.fProjectHistoryExpensesFull.SUB_ENTITY, BRdw_STG.fProjectHistoryExpensesFull.ACCTG_DATE, BRdw_STG.fProjectHistoryExpensesFull.AMT, BRdw_STG.fProjectHistoryExpensesFull.JOB_TYPE_CODE, BRdw_STG.fProjectHistoryExpensesFull.ACCOUNT_NUMBER from BRdw_STG.fProjectHistoryExpensesFull where BRdw_STG.fProjectHistoryExpensesFull.JOB_TYPE_CODE = 'INCLUDED' and BRdw_STG.fProjectHistoryExpensesFull.ACCOUNT_NUMBER in ('4215010084', '4215010085', '4215010086', '4903010108');

SELECT C.EntityId, B.COD_ProfitCenter, A.COD_Project, A.COD_Job, A.FLAG_InternalBilling from BRdw.Dim_ProjectJob as A left outer join BRdw.Dim_ProfitCenter as B on A.ProfitCenter_Key = B.ProfitCenter_Key left outer join BRdw.Dim_Entity as C on A.Entity_Key = C.Entity_Key where A.COD_Project = '98000009';

SELECT DISTINCT A.COD_Project, A.COD_Job from BRdw.Dim_ProjectJob as A left outer join BRdw.Dim_ProfitCenter as B on A.ProfitCenter_Key = B.ProfitCenter_Key left outer join BRdw.Dim_Entity as C on A.Entity_Key = C.Entity_Key where A.COD_Project = '98000009';

SELECT * from [dbo].[Fact_logsGalleryRunning] WHERE UPPER(filename) LIKE '%GLDETAIL%' ORDER BY createDate DESC;


-- Fact_IncludedExpensesCosts_202403_new
SELECT fact.*, dim.COD_Project
FROM [BRdw].[Fact_ProjectIncludedExpensesCosts] fact
 INNER JOIN [BRdw].[Dim_ProjectJob] dim ON fact.ProjectJob_Key = dim.ProjectJob_Key
WHERE fact.FYPer_Key = '202403' ORDER BY VAL_IncludedExpensesCosts DESC;

-- Fact_IncludedExpensesCosts_202403_98_new
SELECT fact.*, dim.COD_Project
FROM [BRdw].[Fact_ProjectIncludedExpensesCosts] fact
 INNER JOIN [BRdw].[Dim_ProjectJob] dim ON fact.ProjectJob_Key = dim.ProjectJob_Key
WHERE dim.COD_Project = '98000009' AND fact.FYPer_Key = '202403' ORDER BY VAL_IncludedExpensesCosts DESC;

-- Fact_IncludedExpensesCosts_2024_98_new
SELECT fact.*, dim.COD_Project
FROM [BRdw].[Fact_ProjectIncludedExpensesCosts] fact
 INNER JOIN [BRdw].[Dim_ProjectJob] dim ON fact.ProjectJob_Key = dim.ProjectJob_Key
WHERE dim.COD_Project = '98000009' 
  AND fact.FYPer_Key LIKE '2024%'
--AND fact.FYPer_Key IN ('202401', '202402', '202403')
ORDER BY VAL_IncludedExpensesCosts DESC;

-- IncludedExpensesCosts_202403_98_ProjectJob_ProfitCenter
SELECT
	--CONCAT(COD_Project, '-', COD_Job) AS Project_Job,
	SUM(VAL_IncludedExpensesCosts) AS Soma_Val_IncludedExpensesCosts,
	fact.FYPer_Key,
	COD_Project
	--profit.COD_ProfitCenter 
FROM [BRdw].[Fact_ProjectIncludedExpensesCosts] fact
INNER JOIN [BRdw].[Dim_ProjectJob] dim ON fact.ProjectJob_Key = dim.ProjectJob_Key
INNER JOIN [BRdw].[Dim_ProfitCenter] profit ON dim.ProfitCenter_Key = profit.ProfitCenter_Key
WHERE dim.COD_Project = '98000009' AND fact.FYPer_Key = '202403' 
GROUP BY COD_Project, fact.FYPer_Key
ORDER BY Soma_Val_IncludedExpensesCosts ASC;

-- Análises extras das 10 últimas linhas (Trocar a ordenação para resultado diferente)
WITH SortedRows AS (
	SELECT fact.FYPer_Key, fact.VAL_IncludedExpensesCosts, fact.ProjectJob_Key, dim.COD_Project
	FROM [BRdw].[Fact_ProjectIncludedExpensesCosts] fact
	 INNER JOIN [BRdw].[Dim_ProjectJob] dim ON fact.ProjectJob_Key = dim.ProjectJob_Key
	WHERE dim.COD_Project = '98000009' AND fact.FYPer_Key = '202403' 
	ORDER BY VAL_IncludedExpensesCosts ASC
	OFFSET 0 ROWS
	FETCH NEXT 10 ROWS ONLY
)
SELECT SUM(VAL_IncludedExpensesCosts) AS Soma -- -3361231,98168153 / -3365412,1875
FROM SortedRows;

-- Análises extra de um Código que existe no confronto da Sheila, mas não existe no AS IS
SELECT CONCAT(COD_Project, '-', COD_Job) AS Project_Job, fact.FYPer_Key, profit.COD_ProfitCenter, *
FROM [BRdw].[Fact_ProjectIncludedExpensesCosts] fact
INNER JOIN [BRdw].[Dim_ProjectJob] dim ON fact.ProjectJob_Key = dim.ProjectJob_Key
INNER JOIN [BRdw].[Dim_ProfitCenter] profit ON dim.ProfitCenter_Key = profit.ProfitCenter_Key
WHERE dim.COD_Project = '98000009' AND fact.FYPer_Key = '202403' AND COD_Job = '0001';

------------------------ QUERIES EM 322_STG ------------------------------------ 

-- Extrações solicitadas pelo Rafael Sousa --
SELECT DB_NAME() AS Database_Name, 'BRdw_STG.fProjectHistoryExpensesFull' AS Table_Name, * FROM BRdw_STG.fProjectHistoryExpensesFull WHERE ACCTG_DATE >= '2023-07-01' ORDER BY ACCTG_DATE ASC;
SELECT DB_NAME() AS Database_Name, 'BRdw_STG.fGLDetail', * FROM BRdw_STG.fGLDetail WHERE ACCTG_DATE >= '2023-07-01' ORDER BY ACCTG_DATE ASC;

-- Extração solicitada pelo Rapahel OCosta
SELECT * FROM [BRdw].[Dim_ProjectJob];




SELECT COUNT(*) as qtdRegistrosReprocessada
FROM [BRdw].[Fact_ProjectIncludedExpensesCosts] fact

SELECT COUNT(*) as qtdRegistrosBackup
FROM [BRdw].[Fact_ProjectIncludedExpensesCosts_bkp_INC19756053]




Select
	ProjectJob_Key,
	Entity_Key,
	ProfitCenter_Key,
	ResultCenter_Key,
	Office_Key,
	Region_Key,
	LoS_Key,
	Customers_Key,
	Service_Key,
	ProjectOwner_Key,
	ProjectManager_Key,
	JobOwner_Key,
	JobManager_Key,
	JobSecondOwner_Key,
	COD_Project,
	COD_Job
From BRdw.Dim_ProjectJob
WHERE
	COD_Project = '98000009'



WITH CTE AS (
SELECT
	COD_JOB,
	C.ENTITYID,
	Right([COD_ProfitCenter], 8) AS BUSINESSUNITY,
	A.COD_PROJECT,
	A.FLAG_INTERNALBILLING,
	A.COD_PROJECT+ENTITYID+Right([COD_ProfitCenter], 8) AS CHAVE
FROM BRDW.DIM_PROJECTJOB AS A
LEFT OUTER JOIN BRDW.DIM_PROFITCENTER AS B
ON A.PROFITCENTER_KEY = B.PROFITCENTER_KEY
LEFT OUTER JOIN BRDW.DIM_ENTITY AS C
ON A.ENTITY_KEY = C.ENTITY_KEY
WHERE
	A.COD_PROJECT = '98000009'
GROUP BY COD_JOB,
	C.ENTITYID,
	Right([COD_ProfitCenter], 8),
	A.COD_PROJECT,
	A.FLAG_INTERNALBILLING
HAVING COUNT(*) > 1
)

SELECT DISTINCT
	A.COD_PROJECT,
	--COD_JOB,
	ENTITYID,
	BUSINESSUNITY
FROM CTE A
WHERE CHAVE IN (
	SELECT DISTINCT
		CHAVE
	FROM CTE AS A
) 
AND COD_JOB NOT IN ( SELECT DISTINCT COD_JOB FROM CTE)



-- Criação de backup
-- Produção
select
	*
into [BRdw].[Fact_ProjectIncludedExpensesCosts_bkp_INC19756053]
from [BRdw].[Fact_ProjectIncludedExpensesCosts];

-- Adicionar a restrição de chave primária à tabela
ALTER TABLE [BRdw].[Fact_ProjectIncludedExpensesCosts_bkp_INC19756053]
ADD CONSTRAINT PK_ProjectIncludedExpensesCosts_Key_INC
PRIMARY KEY (ProjectIncludedExpensesCosts_Key);

select * from sys.tables where create_date > '2023-11-01'
-- Produção
drop table if exists BRDW.View_TimeCapture_PolarisSeptember
drop table if exists BRDW.View_TimeCapture_PolarisFY23
-- Stage
drop table if exists BRDW_STG.Fact_ProjectHoursClosing
drop table if exists BRDW_STG.fProjectHoursClosingAnalisys
drop table if exists BRDW_STG.View_TimeCapture_Polaris
