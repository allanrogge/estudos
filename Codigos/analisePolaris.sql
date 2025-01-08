-- Análise Polaris

/*
Descrição técnica do problema: Os dados que não constam na tabela fato de consumo do processo Polaris, constam na tabela de insumo que a gera.
O problema ocorreu em algum momento passado entre a execução do primeiro e o segundo processo, que não é possível determinar, visto que existem os dados solicitados nesta Stage, porém não estão na fato.

Descrição do processo: 
A tabela View_TimeCapture_Polaris é criada com base nos seguintes passos: 

Step 1
Processo Alteryx: \BR R2R Arquivos\Fluxos Alteryx\Produção\11 - Fact_ProjectHoursClosing_Final_V2.yxmd
Tabela Destino: [GXZU2ADBP322].[BRdw].[Fact_ProjectHoursClosing]

Steps: 
 - Busca dados da veiw TAB_PROJHISTORY na origem Oracle com o filtro: ACCTG_DATE >= To_Date('22-07-01', 'YY-MM-DD')
 - Insere os dados na tabela [BRdw_STG].[fProjectHoursClosing]
 - Com estes dados anteriores, faz-se um union com a tabela [BRdw_STG].[fProjectHoursClosingHistory]
 - Filtra-se o que não for [PROJECT_NO] = 'NPTIME' e [JOB_NO] = 'CMRJ'
 - Enriquece com dados das dimensões
 - Criado coluna de timestamp
 - Selecionado colunas específicas.
 - Insere dados na tabela final

Step 2
Processo Alteryx: \BR R2R Arquivos\Fluxos Alteryx\Produção\45 - views_PolarisTimeCapture_Final_V2.yxmd
Tabela Destino: [GXZU2ADBP322].[BRdw].[View_TimeCapture_Polaris]

Steps: 
 - Busca dados da tabela [GXZU2ADBP322].[BRdw].[Fact_ProjectHoursClosing], buscando apenas algumas colunas.
 - Busca dados de dimensões do schema BRdw , como [Dim_ProjectJob], [Dim_Customer] e afins, para fins de cruzamento.
 - Criado coluna de timestamp
 - Selecionado colunas específicas.
 - Insere dados na tabela final

Monta-se a tabela final [GXZU2ADBP322].[BRdw].[View_TimeCapture_Polaris]

O processo da fProjectHoursClosingHistory se dá da seguinte forma, como ele está hoje, com a última alteração no arquivo em sexta-feira, 15 de setembro de 2023, 14:09:34: 
Processo Alteryx: \BR R2R Arquivos\Fluxos Alteryx\Produção\Fact_ProjectHoursClosingHistory.yxmd
Tabela Destino: [GXZU2ADBP322].[BRdw].[Fact_ProjectHoursClosingHistory]

Steps:
 - Busca dados da veiw TAB_PROJHISTORY na origem Oracle com o filtro: ACCTG_DATE >= To_Date('22-07-01', 'YY-MM-DD')
 - Insere os dados na tabela [BRdw_STG].[fProjectHoursClosingHistory]
 - Busca os dados dessa tabela anterior
 - Seleciona colunas específicas
 - Enriquece com dados das dimensões
 - Criado coluna de timestamp
 - Selecionado colunas específicas.
 - Insere dados na tabela final

Conclusão: 
Apesar de as informações estarem com os mesmos volumes para este caso, o mesmo não ocorre no geral, não sendo possível rodar o processo novamente por este bloqueio: 
Além do evidente impacto nos dados já homologados e congelados do banco de produção, ainda temos outro bloqueio no processo que é a tabela de histórico, usada no union do início do segundo processamento de geração da fato em produção que é insumo do Polaris, arquivo 11 - Fact_ProjectHoursClosing_Final_2.yxmd.
As duas tabelas não têm estruturas sequer semelhantes para validar, e a history não se comporta como uma tabela histórica, visto que ela possui informações do mesmo período que a completa com volume muito menor.
Este bloqueio impede que o fluxo seja re executado da forma que está, sendo necessárias alterações. Alterações estas que podem alterar ainda mais a tabela de destino do processo do Polaris.

*/

SELECT 
	count(*) as QTD_Registros
FROM [BRdw_STG].[fProjectHoursClosing] -- 1.102.770 Volumetria total
where
	RECTYPE in ('bl', 'ubl') -- 648.081 Filtro realizado na query do processo.


SELECT 
	date_worked,
	count(*) as QTD_Registros
FROM [BRdw_STG].[fProjectHoursClosing] -- 1.102.770
where
	RECTYPE in ('bl', 'ubl')
group by date_worked
order by 1 desc

/*
DATE_Worked	QTD_Registros
2023-09-30	33770
2023-09-29	239
2023-09-28	458
2023-09-27	258
2023-09-26	647
2023-09-25	1845
2023-09-24	98
2023-09-22	3896
*/

select
	DATE_Worked,
	count(*) as QTD_Registros
From BRdw_STG.Fact_ProjectHoursClosing -- 648.080
group by DATE_Worked
order by 1 desc;

/*
DATE_Worked	QTD_Registros
2023-09-30	29972
2023-09-24	19
2023-08-24	32619
2023-07-24	26284
2023-06-30	37749
2023-05-24	37267
2023-04-23	36363
2023-03-26	40530
*/

select year, count(*) as qtd_history from [BRdw_STG].[fProjectHoursClosinghistory] group by year order by 1 desc;
select year(date_worked) as year, count(*) as qtd_closing from [BRdw_STG].[fProjectHoursClosing] group by year(date_worked) order by 1 desc;

/*
year	qtd_history
2023	3933
2022	26845
2021	24989
NULL	1

year	qtd_closing
2023	637230
2022	443818
2021	15726
2020	3586
2019	1300
2018	672
2017	312
2016	34
2015	52
2014	40
*/

exec sp_help 'BRdw_STG.fProjectHoursClosingHistory'
exec sp_help 'BRdw_STG.fProjectHoursClosing'

select * from [gxzu2adbp322].[BRdw].[Dim_Employee]
where des_name like '%Tropeia%'
/*
Employee_Key  EmployeeMaster_Key  Entity_Key  EmployeeCategory_Key	ProfitCenter_Key  COD_SQL	DES_Name					   COD_Type		COD_Global	DES_Email				FLAG_Status	RowInsertdateTime
988			  19013				  1			  91					1				  305642A 	CAMILA TROPEIA SANTOS STEFANE  TEC   		100572272	camila.tropeia@pwc.com	A			2023-10-04 07:23:44.000
29956		  19013				  25		  4071					2496			  305642  	CAMILA TROPEIA SANTOS STEFANE  TEC   		100572272	camila.tropeia@pwc.com	T			2023-10-04 07:23:46.000
*/

select distinct b.*
from [BRdw].[View_TimeCapture_Polaris] a
inner join [BRdw].[Dim_Employee] b
on a.cod_pw = b.COD_SQL
where des_name like '%Tropeia%'
/*
Employee_Key	EmployeeMaster_Key	Entity_Key	EmployeeCategory_Key	ProfitCenter_Key	COD_SQL  DES_Name						COD_Type	COD_Global	DES_Email				FLAG_Status	RowInsertdateTime
29956			19013				25			4071					2496				305642   CAMILA TROPEIA SANTOS STEFANE	TEC   		100572272	camila.tropeia@pwc.com	T			2023-10-04 07:23:46.000
*/

select distinct top 8
	a.cod_pw,
	des_sqlName,
	Date_Worked, 
	sum(val_regularHours) as RegularHours,
	sum(val_overtimeHours) as OvertimeHours
from [BRdw].[View_TimeCapture_Polaris] a
inner join [BRdw].[Dim_Employee] b
on a.cod_pw = b.COD_SQL
where des_name like '%Tropeia%'
group by 
	a.cod_pw,
	des_sqlName,
	Date_Worked
order by 3 desc
/*
cod_pw		des_sqlName		date_worked	RegularHours	OvertimeHours
305642    	CAMILA TROPEIA	2023-08-24	184				0
305642    	CAMILA TROPEIA	2023-07-24	128				0
305642    	CAMILA TROPEIA	2023-06-30	200				0
305642    	CAMILA TROPEIA	2023-05-24	176				0
305642    	CAMILA TROPEIA	2023-04-23	144				0
305642    	CAMILA TROPEIA	2023-03-26	177				0
305642    	CAMILA TROPEIA	2023-02-23	198				0
305642    	CAMILA TROPEIA	2023-01-23	193				0
*/

select distinct top 8
	a.Employee_Key,
	des_name,
	format(Date_Worked, 'yyyy-MM') as Date_Worked, 
	sum(val_regularHours) as RegularHours,
	sum(val_overtimeHours) as OvertimeHours
from [BRdw].[Fact_ProjectHoursClosing] a
inner join [BRdw].[Dim_Employee] b
on a.Employee_Key = b.Employee_Key
where b.des_name like '%Tropeia%'
group by 
	a.Employee_Key,
	des_name,
	format(Date_Worked, 'yyyy-MM')
order by 3 desc
/*
Employee_Key	des_name						Date_Worked	RegularHours	OvertimeHours
988				CAMILA TROPEIA SANTOS STEFANE	2023-08-24	184				0
988				CAMILA TROPEIA SANTOS STEFANE	2023-07-24	128				0
988				CAMILA TROPEIA SANTOS STEFANE	2023-06-30	200				0
988				CAMILA TROPEIA SANTOS STEFANE	2023-05-24	176				0
988				CAMILA TROPEIA SANTOS STEFANE	2023-04-23	144				0
988				CAMILA TROPEIA SANTOS STEFANE	2023-03-26	177				0
988				CAMILA TROPEIA SANTOS STEFANE	2023-02-23	198				0
988				CAMILA TROPEIA SANTOS STEFANE	2023-01-23	193				0
*/

select top 9
	emp_vend_key,
	'CAMILA TROPEIA' as des_sqlName,
	format(Date_Worked, 'yyyy-MM') as Date_Worked,
	sum(reg_hours) as RegularHours,
	sum(ovt_hours) as OvertimeHours
from [BRdw_STG].[fProjectHoursClosing]
where emp_vend_key in ('305642A', '305642')
group by 
	emp_vend_key,
	format(Date_Worked, 'yyyy-MM')
order by 3 desc
/*
emp_vend_key	des_sqlName		Date_Worked	RegularHours	OvertimeHours
305642A 		CAMILA TROPEIA	2023-09-30	192				0
305642A 		CAMILA TROPEIA	2023-08-24	184				0
305642A 		CAMILA TROPEIA	2023-07-24	128				0
305642A 		CAMILA TROPEIA	2023-06-30	200				0
305642A 		CAMILA TROPEIA	2023-05-24	176				0
305642A 		CAMILA TROPEIA	2023-04-23	144				0
305642A 		CAMILA TROPEIA	2023-03-26	177				0
305642A 		CAMILA TROPEIA	2023-02-23	198				0
305642A 		CAMILA TROPEIA	2023-01-23	193				0
*/


select distinct top 8
	format(Date_Worked, 'yyyy-MM') as Date_Worked, 
	format(sum(val_regularHours), 'N2') as RegularHours,
	format(sum(val_overtimeHours), 'N2') as OvertimeHours
from [BRdw].[Fact_ProjectHoursClosing] a
inner join [BRdw].[Dim_Employee] b
on a.Employee_Key = b.Employee_Key
group by
	format(Date_Worked, 'yyyy-MM')
order by 1 desc
/*
Date_Worked	RegularHours	OvertimeHours
2023-08		747,213.97		17,957.33
2023-07		524,268.02		9,713.39
2023-06		844,142.90		13,325.07
2023-05		747,737.38		20,989.96
2023-04		609,499.27		25,211.14
2023-03		728,621.81		49,886.59
2023-02		819,532.67		49,829.44
2023-01		834,002.31		27,838.64
*/

select top 9
	format(ACCTG_DATE, 'yyyy-MM') as ACCTG_DATE,
	format(sum(reg_hours), 'N2') as RegularHours,
	format(sum(ovt_hours), 'N2') as OvertimeHours
from [BRdw_STG].[fProjectHoursClosing]
group by
	format(ACCTG_DATE, 'yyyy-MM')
order by 1 desc
/*
Date_Worked	RegularHours	OvertimeHours
2023-09		833,913.95		9,140.54
2023-08		755,207.60		17,967.33
2023-07		531,773.29		9,713.39
2023-06		854,802.55		13,325.07
2023-05		758,838.60		20,989.96
2023-04		619,389.07		25,211.14
2023-03		740,728.02		49,886.59
2023-02		830,467.32		49,829.44
2023-01		845,369.59		27,838.64
*/

select *
from BRdw_STG.fProjectHoursClosing 
where
	RECTYPE in ('bl', 'ubl')
	and DATE_WORKED >= '2023-08-31' -- 29.991


select * from BRdw_STG.Fact_ProjectHoursClosing
where  DATE_WORKED >= '2023-08-31' -- 29.991



select
	format(date_worked, 'yyyy-MM') as date_worked,
	format(sum(val_regularHours), 'N2') as RegularHours,
	format(sum(val_overtimeHours), 'N2') as OvertimeHours
from BRdw.View_TimeCapture_Polaris
group by
	format(date_worked, 'yyyy-MM')
order by 1 desc


select
	--ACCTG_DATE,
	format(date_worked, 'yyyy-MM') as date_worked,
	count(*)
from BRdw_STG.fProjectHoursClosing
group by
	--ACCTG_DATE,
	format(date_worked, 'yyyy-MM')
order by 1 desc

select count(*)
From BRdw_STG.fprojecthoursclosingAnalisys -- 5.781.084
where  RECTYPE in ('bl', 'ubl') -- 2.828.948

select count(*) from BRdw_STG.Fact_ProjectHoursClosing -- 648.080
select * From BRdw_STG.Fact_ProjectHoursClosing

select
	format(date_worked, 'yyyy-MM') as date_worked,
	format(sum(val_regularHours), 'N2') as RegularHours,
	format(sum(val_overtimeHours), 'N2') as OvertimeHours
from BRdw_STG.Fact_ProjectHoursClosing
group by
	format(date_worked, 'yyyy-MM')
order by 1 desc

/*
date_worked	RegularHours	OvertimeHours
2023-09		825,365.55		9,140.54
2023-08		747,213.97		17,967.33
2023-07		524,268.02		9,713.39
2023-06		844,142.90		13,325.07
2023-05		747,737.38		20,989.96
2023-04		609,499.27		25,211.14
2023-03		728,621.81		49,886.59
2023-02		819,532.67		49,829.44
2023-01		834,002.31		27,838.64
2022-12		647,166.50		11,294.58
2022-11		650,832.10		12,707.78
2022-10		669,553.98		8,608.77
2022-09		666,143.86		9,195.53
2022-08		708,748.95		16,417.21
2022-07		486,454.80		7,723.66
*/

select
	format(date_worked, 'yyyy-MM') as date_worked,
	format(sum(val_regularHours), 'N2') as RegularHours,
	format(sum(val_overtimeHours), 'N2') as OvertimeHours
from BRdw_STG.View_TimeCapture_Polaris
group by
	format(date_worked, 'yyyy-MM')
order by 1 desc

select
	cast(COD_Customer as int) as COD_Customer,
	count(*)
from [BRdw].[View_TimeCapture_Polaris] -- 2.331.294
group by cast(COD_Customer as int)
order by 1 desc

/*
TimeCapture_Key	COD_Customer	COD_PridEntity	COD_PridParent	COD_PridUltimate	COD_Global	COD_PW	COD_PwcGuid	COD_UniversalIdentifier	DES_SQLName	COD_Entity	COD_Project	COD_Job	DES_LoS	COD_Office	DES_Office	VAL_RegularHours	VAL_OverTimeHours	DATE_Worked	RowInsertDateTime
1	5822	NULL	NULL	NULL	100578906	000094    	NULL	8e928157-2a2d-40e0-b5bf-9a87641f2d94	VIRGINIA MONETA	01	01024394	P001	BR-ASSURANCE	CA	RECIFE	100	0	2018-06-30	2023-10-04 10:06:55.000
2	5822	NULL	NULL	NULL	100578906	000094    	NULL	8e928157-2a2d-40e0-b5bf-9a87641f2d94	VIRGINIA MONETA	01	01024394	P001	BR-ASSURANCE	CA	RECIFE	64	0	2018-07-24	2023-10-04 10:06:55.000
3	5822	NULL	NULL	NULL	100578906	000094    	NULL	8e928157-2a2d-40e0-b5bf-9a87641f2d94	VIRGINIA MONETA	01	01024394	P001	BR-ASSURANCE	CA	RECIFE	92	0	2018-08-24	2023-10-04 10:06:55.000
4	5822	NULL	NULL	NULL	100578906	000094    	NULL	8e928157-2a2d-40e0-b5bf-9a87641f2d94	VIRGINIA MONETA	01	01024394	P001	BR-ASSURANCE	CA	RECIFE	68	0	2018-09-23	2023-10-04 10:06:55.000
5	5822	NULL	NULL	NULL	100578906	000094    	NULL	8e928157-2a2d-40e0-b5bf-9a87641f2d94	VIRGINIA MONETA	01	01024394	P001	BR-ASSURANCE	CA	RECIFE	84	0	2018-10-24	2023-10-04 10:06:55.000
6	5822	NULL	NULL	NULL	100578906	000094    	NULL	8e928157-2a2d-40e0-b5bf-9a87641f2d94	VIRGINIA MONETA	01	01024394	P001	BR-ASSURANCE	CA	RECIFE	72	0	2018-11-25	2023-10-04 10:06:55.000
7	5822	NULL	NULL	NULL	100578906	000094    	NULL	8e928157-2a2d-40e0-b5bf-9a87641f2d94	VIRGINIA MONETA	01	01024394	P001	BR-ASSURANCE	CA	RECIFE	72	0,05	2019-03-21	2023-10-04 10:06:55.000
8	5822	NULL	NULL	NULL	100578906	000094    	NULL	8e928157-2a2d-40e0-b5bf-9a87641f2d94	VIRGINIA MONETA	01	01024394	P001	BR-ASSURANCE	CA	RECIFE	84	0,02	2019-04-23	2023-10-04 10:06:55.000
9	5822	NULL	NULL	NULL	100578906	000094    	NULL	8e928157-2a2d-40e0-b5bf-9a87641f2d94	VIRGINIA MONETA	01	01024394	P001	BR-ASSURANCE	CA	RECIFE	84	0,29	2019-05-26	2023-10-04 10:06:55.000
10	5822	NULL	NULL	NULL	100578906	000094    	NULL	8e928157-2a2d-40e0-b5bf-9a87641f2d94	VIRGINIA MONETA	01	01024394	P001	BR-ASSURANCE	CA	RECIFE	80	0	2019-06-30	2023-10-04 10:06:55.000
*/
select
	DATE_Worked,
	count(*)
from [BRdw_STG].[View_TimeCapture_Polaris] -- 2.820.140
group by DATE_Worked
order by 1 desc
/*
COD_Customer	COD_PridEntity	COD_PridParent	COD_PridUltimate	COD_Global	COD_PW	COD_PwcGuid	COD_UniversalIdentifier	DES_SQLName	COD_Entity	COD_Project	COD_Job	DES_LoS	COD_Office	DES_Office	VAL_RegularHours	VAL_OverTimeHours	DATE_Worked	RowInsertDateTime
99999999	117883306	NULL	NULL	100578906	000094    	NULL	8e928157-2a2d-40e0-b5bf-9a87641f2d94	VIRGINIA MONETA	01	BREC0001	A001	BR-ASSURANCE	CA	RECIFE	40	13,92	2017-07-24	2024-01-26 17:30:23.000
99999999	117883306	NULL	NULL	100578906	000094    	NULL	8e928157-2a2d-40e0-b5bf-9a87641f2d94	VIRGINIA MONETA	01	BREC0001	A001	BR-ASSURANCE	CA	RECIFE	120	10	2017-08-24	2024-01-26 17:30:25.000
99999999	117883306	NULL	NULL	100578906	000094    	NULL	8e928157-2a2d-40e0-b5bf-9a87641f2d94	VIRGINIA MONETA	01	BREC0001	A001	BR-ASSURANCE	CA	RECIFE	152	2,5	2017-09-24	2024-01-26 17:30:25.000
99999999	117883306	NULL	NULL	100578906	000094    	NULL	8e928157-2a2d-40e0-b5bf-9a87641f2d94	VIRGINIA MONETA	01	BREC0001	A001	BR-ASSURANCE	CA	RECIFE	136	0	2017-10-24	2024-01-26 17:30:25.000
99999999	117883306	NULL	NULL	100578906	000094    	NULL	8e928157-2a2d-40e0-b5bf-9a87641f2d94	VIRGINIA MONETA	01	BREC0001	A001	BR-ASSURANCE	CA	RECIFE	152	0	2017-11-23	2024-01-26 17:30:25.000
99999999	117883306	NULL	NULL	100578906	000094    	NULL	8e928157-2a2d-40e0-b5bf-9a87641f2d94	VIRGINIA MONETA	01	BREC0001	A001	BR-ASSURANCE	CA	RECIFE	120	0	2017-12-19	2024-01-26 17:30:25.000
99999999	117883306	NULL	NULL	100578906	000094    	NULL	8e928157-2a2d-40e0-b5bf-9a87641f2d94	VIRGINIA MONETA	01	BREC0001	A001	BR-ASSURANCE	CA	RECIFE	196	0	2018-01-23	2024-01-26 17:30:25.000
99999999	117883306	NULL	NULL	100578906	000094    	NULL	8e928157-2a2d-40e0-b5bf-9a87641f2d94	VIRGINIA MONETA	01	BREC0001	A001	BR-ASSURANCE	CA	RECIFE	144	0	2018-02-21	2024-01-26 17:30:25.000
99999999	117883306	NULL	NULL	100578906	000094    	NULL	8e928157-2a2d-40e0-b5bf-9a87641f2d94	VIRGINIA MONETA	01	BREC0001	A001	BR-ASSURANCE	CA	RECIFE	178	5	2018-03-22	2024-01-26 17:30:25.000
99999999	117883306	NULL	NULL	100578906	000094    	NULL	8e928157-2a2d-40e0-b5bf-9a87641f2d94	VIRGINIA MONETA	01	BREC0001	A001	BR-ASSURANCE	CA	RECIFE	162	0	2018-04-23	2024-01-26 17:30:25.000
*/

/*
drop table if exists BRdw_STG.fprojecthoursclosingAnalisys
drop table if exists BRdw_STG.View_TimeCapture_Polaris
drop table if exists BRdw_STG.Fact_ProjectHoursClosing
*/


select
	date_worked,
	count(*)
from [BRdw].[View_TimeCapture_Polaris_BKP] -- 2.331.294
where DES_SQLName like '%Tropeia%'
group by date_worked
order by 1 desc

select
	date_worked,
	count(*)
from [BRdw].[View_TimeCapture_PolarisSeptember] -- 2.331.294
--where DES_SQLName like '%Tropeia%'
group by date_worked
order by 1 desc


update [BRdw].[View_TimeCapture_Polaris_BKP]
set
    COD_Customer = COD_Customer,
    COD_PridEntity = COD_PridEntity,
    COD_PridParent = COD_PridParent,
    COD_PridUltimate = COD_PridUltimate,
    COD_Global = COD_Global,
    COD_PW = COD_PW,
    COD_PwcGuid = COD_PwcGuid,
    COD_UniversalIdentifier = COD_UniversalIdentifier,
    DES_SQLName = DES_SQLName,
    COD_Entity = COD_Entity,
    COD_Project = COD_Project,
    COD_Job = COD_Job,
    DES_LoS = DES_LoS,
    COD_Office = COD_Office,
    DES_Office = DES_Office,
    VAL_RegularHours = VAL_RegularHours,
    VAL_OverTimeHours = VAL_OverTimeHours,
    DATE_Worked = DATE_Worked,
    RowInsertDateTime = RowInsertDateTime
from [BRdw].[View_TimeCapture_PolarisSeptember]

select
	*
into [BRdw].[View_TimeCapture_PolarisFY23]
from [BRdw].[View_TimeCapture_Polaris] -- 2.331.294
where date_worked >= '2022-07-01' -- 564.826

select
	*
from [BRdw].[View_TimeCapture_PolarisSeptember] -- 598.816



select
	'ORIGNAL' AS VERSAOTABELA,
	*
from [BRdw].[View_TimeCapture_PolarisFY23]
UNION
select * from brdw.dim_employee
where des_name like '%Tropeia%'


select
	COD_PW,
	DES_SQLNAME,
	format(Date_Worked, 'yyyy-MM') as DATE_WORKED,
	COD_PROJECT,
	sum(VAL_REGULARHOURS) as RegularHours,
	sum(VAL_OVERTIMEHOURS) as OvertimeHours
from [BRdw].[View_TimeCapture_Polaris]
where
	des_sqlname  in ('CAMILA TROPEIA', 'RAQUEL POPADIUK')
	--AND DATE_WORKED >= '2022-07-01'
GROUP BY
	COD_PW,
	DES_SQLNAME,
	format(Date_Worked, 'yyyy-MM'),
	COD_PROJECT
order by 3 desc, 2
SELECT
	A.EMPLOYEE_KEY,
	DES_NAME,
	FORMAT(DATE_WORKED, 'yyyy-MM') AS DATE_WORKED,
	COD_PROJECT,
	SUM(VAL_REGULARHOURS) AS REGULARHOURS,
	SUM(VAL_OVERTIMEHOURS) AS OVERTIMEHOURS
FROM [BRDW].[FACT_PROJECTHOURSCLOSINGEMPLOYEE] A
LEFT JOIN BRDW.DIM_PROJECTJOB B
ON A.PROJECTJOB_KEY = B.PROJECTJOB_KEY
LEFT JOIN BRDW.DIM_EMPLOYEE C
ON A.EMPLOYEE_KEY = C.EMPLOYEE_KEY
WHERE
	DATE_WORKED >= '2022-07-01'
	AND A.EMPLOYEE_KEY = '988'
GROUP BY
	A.EMPLOYEE_KEY,
	DES_NAME,
	DATE_WORKED,
	COD_PROJECT
ORDER BY 3


SELECT distinct
	C.COD_SQL AS COD_PW,
	DES_Name,
	COD_Office,
	DES_Office,
	DES_LoS,
	COD_Global,
	G.COD_Entity,
	COD_Project,
	COD_Job,
	COD_Customer,
	VAL_RegularHours,
	VAL_OverTimeHours,
	DATE_Worked,
	A.RowInsertDateTime
FROM [BRDW].[FACT_PROJECTHOURSCLOSINGEMPLOYEE] A
INNER JOIN BRDW.DIM_PROJECTJOB B
ON A.PROJECTJOB_KEY = B.PROJECTJOB_KEY
INNER JOIN BRDW.DIM_EMPLOYEE C
ON A.EMPLOYEE_KEY = C.EMPLOYEE_KEY
INNER JOIN BRDW.DIM_CUSTOMERS E
ON A.Customers_Key = E.Customers_Key
INNER JOIN BRDW.DIM_OFFICE F
ON A.OFFICE_KEY = F.OFFICE_KEY
INNER JOIN BRDW.DIM_LOS G
ON A.LoS_Key = G.LoS_Key
WHERE
	A.DATE_WORKED >= '2022-07-01'
	AND A.EMPLOYEE_KEY = '988'
ORDER BY DATE_Worked, VAL_RegularHours

SELECT
	A.EMPLOYEE_KEY,
	DES_NAME,
	FORMAT(DATE_WORKED, 'yyyy-MM') AS DATE_WORKED,
	COD_PROJECT,
	SUM(VAL_REGULARHOURS) AS REGULARHOURS,
	SUM(VAL_OVERTIMEHOURS) AS OVERTIMEHOURS
FROM [BRDW].[FACT_PROJECTHOURSCLOSINGEMPLOYEE] A
LEFT JOIN BRDW.DIM_PROJECTJOB B
ON A.PROJECTJOB_KEY = B.PROJECTJOB_KEY
LEFT JOIN BRDW.DIM_EMPLOYEE C
ON A.EMPLOYEE_KEY = C.EMPLOYEE_KEY
LEFT JOIN BRDW.DIM_CUSTOMERS E
ON A.Customers_Key = E.Customers_Key
LEFT JOIN BRDW.DIM_OFFICE F
ON A.OFFICE_KEY = F.OFFICE_KEY
LEFT JOIN BRDW.DIM_LOS G
ON A.LoS_Key = G.LoS_Key
WHERE
	A.DATE_WORKED >= '2022-07-01'
	AND A.EMPLOYEE_KEY = '988'
GROUP BY
	A.EMPLOYEE_KEY,
	DES_NAME,
	DATE_WORKED,
	COD_PROJECT
ORDER BY 3

select
	FORMAT(DATE_WORKED, 'yyyy-MM') AS DATE_WORKED,
	count(*)
from [BRdw].[View_TimeCapture_Polaris] -- 2.331.294
group by FORMAT(DATE_WORKED, 'yyyy-MM')
order by 1 desc
select * from sys.tables where name = 'View_TimeCapture_Polaris'

select top 10
	FORMAT(DATE_WORKED, 'yyyy-MM') AS DATE_WORKED,
	count(*) countAnalisys
from BRDW_STG.fProjectHoursClosingAnalisys -- 2.331.294
where FORMAT(DATE_WORKED, 'yyyy-MM') >= '2014-08'
group by FORMAT(DATE_WORKED, 'yyyy-MM')
order by 1;

select
	FORMAT(DATE_WORKED, 'yyyy-MM') AS DATE_WORKED,
	count(*) countOriginal
from [BRdw_STG].[fProjectHoursClosing] -- 2.331.294
group by FORMAT(DATE_WORKED, 'yyyy-MM')
order by 1;

-- Criação de backup
-- Produção
select
	*
into [BRdw].[View_TimeCapture_Polaris_bkp_INC19895628]
from [BRdw].[View_TimeCapture_Polaris];

select top 50 * from  [BRdw].[View_TimeCapture_Polaris_bkp_INC19895628];
select top 50 * from [BRdw].[View_TimeCapture_Polaris];

-- Adicionar a restrição de chave primária à tabela
ALTER TABLE [BRdw].[View_TimeCapture_Polaris_bkp_INC19895628]
ADD CONSTRAINT PK_TimeCapture_INC
PRIMARY KEY (TimeCapture_Key);

-- Stage
select *
into [BRdw_STG].[fProjectHoursClosing_bkp_INC19895628]
from [BRdw_STG].[fProjectHoursClosing]

-- Drop de tabelas criadas no processo de análise
select * from sys.tables where create_date > '2023-11-01'
-- Produção
drop table if exists BRDW.View_TimeCapture_PolarisSeptember
drop table if exists BRDW.View_TimeCapture_PolarisFY23
-- Stage
drop table if exists BRDW_STG.Fact_ProjectHoursClosing
drop table if exists BRDW_STG.fProjectHoursClosingAnalisys
drop table if exists BRDW_STG.View_TimeCapture_Polaris



select top 10 * from BRDW_STG.fProjectHoursClosing
where CHARGE_TYPE_CODE is not null

select * from sys.tables where name = 'Fact_ProjectHoursClosing'


select distinct
	cod_entity+cod_project+cod_job as CHAVE,
	*
from brdw.View_ChargeCode_Polaris
where cod_entity+cod_project+cod_job in ('01010592360001')


select distinct cod_project from brdw.View_ChargeCode_Polaris


select distinct
	cod_entity+cod_project+cod_job as CHAVE,
	*
from brdw.View_CustomerDebtor_Polaris
where cod_entity+cod_project+cod_job in ('01010592360001')


with chargecode as (
    select
        p.*,
        GETDATE() DATA_CARGA
    from [BRdw].[View_ChargeCode_Polaris] p
    where
        (DATE_JobClosed is null or DATE_JobClosed >= '2022-04-01')
        and FLAG_Billable = 'Y'
)

select 'SourceSystemInstance|ChargeCode|ChargeCodeName|ChargeCodeDescription|ChargeCodeTypeName|NativeChargeCodeTypeName|ChargeCodeStartdate|ChargeCodeEnddate|ChargeCodeCreationDate|CostCentreCode|CostCentreName|LocalCostCentreCode|NativeCostCentreCode|OwningPwCNetworkNodeName|GlobalProductCode|LocalProductCode|NativeProductCode|NativeProductName|ContractCode|ContractDescription|ContractingClientPartyId|NativeContractingClientId|NativeContractingClientName|DebtorPartyId|DebtorPartyName|NativeDebtorPartyId|NativeDebtorPartyName|OpportunityId|SourcePwCTerritoryName|SourcePwCCountryFirmName|ExtractDateTime'

UNION ALL

select
    replace(
        replace(
            concat(
                '', 'SqlTime - Brazil', '|', replace(concat(d.cod_entity, replace(d.Cod_Project, '', ''), d.cod_job), char(9), ''), '|',
                replace(replace(replace(replace(replace(d.DES_Project, char(9), ''), char(13), ''), char(10), ''), '|', ' '), '"', '') , '|',
                replace(replace(replace(replace(trim(d.des_Job), char(9),''), char(13), ''), char(10), ''), '|', ' ') , '|',
                case
                    when [COD_ProjectType] = 'CLIENT' then 'External Engagement Project'
                    when d.[COD_ProjectType] = 'EXPENS' then 'Internal Project without Credit'
                    when d.[COD_ProjectType] = 'MANAG' then 'Statistical'
                    when d.[COD_ProjectType] = 'NPTIME' then 'Statistical'
                    when d.[COD_ProjectType] = 'PEREDU' then 'Internal Project without Credit'
                    when d.[COD_ProjectType] = 'SPECIA' then 'Internal Project without Credit'
                    when d.[COD_ProjectType] = 'BUDGET' then 'Internal Project without Credit'
                    ELSE d.[COD_ProjectType] END, '|', replace(trim(d.cod_projecttype), char(9),''), '|',
                case when d.DATE_ActualStart is null then format(convert(datetime,'2022-04-01 00:00:00'),'yyyy-MM-dd hh:mm:ss') else format(convert(datetime, d.date_actualstart), 'yyyy-MM-dd hh:mm:ss') end, '|',
                case when d.date_jobclosed is null then 'NULL' else format(convert(datetime,d.date_jobclosed), 'yyyy-MM-dd hh:mm:ss') end,'|',
                case when d.date_activation is null and d.DATE_ActualStart is null then format(convert(datetime, '2022-04-01 00:00:00'), 'yyyy-MM-dd hh:mm:ss')
                when d.DATE_Activation is null then format(convert(datetime,d.date_actualstart),'yyyy-MM-dd hh:mm:ss')
                else format(convert(datetime, d.date_activation), 'yyyy-MM-dd hh:mm:ss') end,
                '|',
                replace(trim(d.cod_profitcenter), char(9), '') , '|',
                replace(trim(d.des_profitcenter), char(9), '') , '|',
                replace(trim(d.COD_ProfitCenter), char(9), ''), '|',
                replace(trim(d.cod_ProfitCenter), char(9), '') , '|', 'PWC Brazil', '|', 'BRA', '|',
                replace(trim(d.COD_Service), char(9), ''), '|',
                replace(trim(d.cod_GlobalService), char(9), ''), '|',
                replace(replace(replace(replace(replace(d.DES_Project,char(9),''),char(13),''),char(10),''),'|',' '),'"','') ,'|',
                replace(trim(d.cod_customer),char(9),'') ,'|',
                replace(replace(replace(replace(trim(d.des_Job),char(9),''),char(13),''),char(10),''),'|',' ') ,'|',
                replace(trim(deb.COD_NativePartyID),char(9),''),'|',
                replace(trim(d.cod_customer),char(9),'')  ,'|',
                replace(replace(replace(replace(replace(d.DES_Project,char(9),''),char(13),''),char(10),''),'|',' '),'"','')  ,'|',
                replace(trim(deb.COD_DebtorParty),char(9),'') ,'|',
                replace(trim(deb.DES_DebtorPartyName),char(9),''),'|',
                replace(trim(deb.DES_NativeDebtorPartyId),char(9),''),'|',
                replace(trim(deb.DES_NativeDebtorPartyName),char(9),''),'|',
                replace(trim(d.COD_Opportunity),char(9),'')  ,'|',
                'PWC Brazil', '|', 'PWC Brazil', '|', format(getdate(), 'yyyy-MM-dd hh:mm:ss')  ,''
            ),
            'NULL','NULL'
        ),
        'NULL',''
    ) AS COLUNA
from chargecode d
left join brdw.View_CustomerDebtor_Polaris deb
on (
    d.COD_Project = deb.COD_PROJECT
    and d.COD_Job = deb.COD_JOB
    and d.cod_entity = deb.cod_entity
)
where
	  deb.CustomerDebtor_Key = (
        select max(customerdebtor_key)
        from brdw.View_CustomerDebtor_Polaris deb2
        where
            deb.COD_ENTITY = deb2.COD_ENTITY
            and deb.COD_PROJECT = deb2.COD_PROJECT
            and deb2.cod_job = deb.cod_job
    )
    and d.cod_entity+d.cod_project+d.cod_job in ('01010592360001')


SELECT * FROM BRDW.Dim_Customers

Select distinct b.des_customer, a.* from [BRdw].View_ChargeCode_Polaris A
LEFT JOIN BRDW.Dim_CustomersFull B
ON A.COD_CUSTOMER = B.COD_CUSTOMER
WHERE DES_CUSTOMER IN (
'CÁLCULO DE LAT - JUN/2012',
'BRADESCO - BAC - VALUATION E PPA',
'CODESA - DEALS SP',
'AVALIAÇÃO ATUARIAL CPC-33 2020',
'BK BRASIL OPERACAO E ASSESSORIA A RESTAURANTES S.A.',
'PROJETO LER',
'OUTSOURCING - LIDER',
'AA 2021 - ZURICH SANTANDER',
'SUPPLIER DEVELOPMENT & PERFORMANCE PROGRAM IN BRAZIL',
'ASSESSMENT DE FORNECEDORES',
'Bradesco - Auditoria VCMH',
'Outsourcing 2022 - SeguradoraLider',
'IRB - REVISÃO DO PLA',
'ALFA - IFRS 9 E 17',
'RECONCILIAÇÃO FATURAMENTO 2013',
'INOVAÇÃO TECNOLÓGICA NESTLÉ',
'CIA SEGUROS DA BAHIA-ICMS',
'AIRE',
'TRABALHOS GMRS',
'VERYCOM - PROPOSTA 2005',
'SARBOX ATTESTATION - 2006',
'CARBOCLORO S.A.',
'PMO- DESENVOLVIMENTO SUSTENTÁVEL',
'PMO_IFRS',
'BLABLA',
'SOFT 5',
'MERLUZA',
'FONTE',
'SANTOS',
'ASSESSORIA',
'DISAL-CORR MONETARIA - PROCESSOS CONTENCIOSOS - FI',
'COFINS - PROCESSOS CONTENCIOSOS - OUTROS',
'WELLA/BELFAM',
'IMUNIDADE EXPORTAÇÃO',
'AÇÃO - ISS - COLETORES DE DADOS',
'ICMS (EXECUÇÕES FISCAIS-MACAÉ)',
'AÇÃO JUDICIAL KF',
'ASSESSORIA SOCIETÁRIA',
'PARCELAMENTO LEI 11.941/2009',
'ISS - SÃO PAULO',
'FAP',
'LEI Nº 11.941',
'LEI Nº 11.941/09',
'CONTRIBUIÇÃO AO SAT',
'ESPÓLIO DE ARTHUR LESLIE DOLLOND',
'NOVOS PROCESSOS TRIBUTÁRIOS EPREVIDENCIÁRIOS',
'FAP 2011',
'MANDADO DE SEGURANÇA - Nº 0008571-85.2011.403.6100',
'PROCESSO ADMINISTRATIVO Nº 12157.000087/2009-67',
'IRPF - INCORPORAÇÃO DE AÇÕES',
'MANIFESTACAO DE INCONFORMIDADE - DESPACHO DECISORIO 00561550',
'CMB - AÇÃO JUDICIAL PIS E COFINS - SELIC',
'CMB AÇÃO DE REPETIÇÃO DO INDÉBITO SESC E SENAC',
'ABBVIE   APOIO REGULATÓRIO',
'ZURICH LIVEWELL - CDC - APOIO CÍVEL',
'SAP - AÇÃO ANULATÓRIA - HIT',
'COFINS 0805268-75.2016.4.05.8500',
'IMPUGNAÇÕES MULTA ISOLADA',
'II / IPI ADMISSÃO TEMPORÁRIA',
'ESAB AUMENTO DE CAPITAL POR ESTRANGEIRO',
'FAMILIA KISS   TESTAMENTO E INVENTÁRIO',
'ASSAI PROJETO C',
'DATWYLER ANÁLISE CT VCP E REGISTRO INPI E BACEN',
'ACOMPANHAMENTO DE PROCESSOS',
'CTI BRAZILIAN LEGAL ASSISTANCE',
'ASSESSORIA JURÍDICA',
'DEFESAS ADMINISTRATIVAS - AURORA',
'ESAB ASSESSORIA SOCIETÁRIA BR',
'APTIV - JUROS SOBRE CAPITAL PRÓPRIO 2023',
'BANESE AIIM 02/2023 - CAPELA',
'ENEL APOIO CONSULTIVO (CTO GERAL)',
'KORN/FERRY INTERNATIONAL LTDA. - CONTÁBIL',
'CA - PWCO',
'BTO - IMPLANTAÇÃO',
'VITRO OUTSOURCING TECNOLOGIA',
'FLAGSTONE',
'BANCO FATOR - HRO',
'BUMI ARMADA',
'TAX COMPLIANCE_HYPERTHERM',
'SEED',
'CITROPAR_REDPAR_TRC_TAX COMPLIANCE_JAN23_DEC23',
'Medison Tax 2023',
'PROJETO SÓCRATES',
'PROJETO MONOPOLY',
'PROJETO PIPA',
'PROJETO ENDURO',
'PROJETO SENNA',
'METLIFE - LEI DO BEM 2017 E 2018',
'ICATU - AUDITORIA INTERNA',
'RENNER - REFAZ RS',
'CONSULTORIA TAX',
'METLIFE - LEI DO BEM 19-20',
'TAX CONSULTING SERVICES',
'REINTEGRA ZFM',
'RECUPERAÇÃO JUDICIAL PRINTBILIND. GRÁFICA',
'CALF - APOIO RJ',
'AÇÃO JUDICIAL CSL FONTE 2008 E 2009',
'SALDO NEGATIVO IRPJ 2009',
'AUTO DE INFRAÇÃO - INSS',
'ASSESSORIA CONTRATUAL E SOCIETÁRIA',
'AUTO DE INFRAÇÃO - INCORPORACAO ECOPOLO',
'COBRANÇA - PAJUVI',
'IMPUG AUTOS INFRAÇÃO - EXP SERV - ABRIL 2010 A JAN 2012',
'COMPENSAÇÃO DE OFICIO II',
'EXCEÇÕES PRE-EXECUTIVIDADE - EXEC FISCAIS ISS-SP 2010 A 2012',
'CRÉDITOS ICMS - DIESEL',
'COBRANÇA - GRUPO EDSON QUEIROZ',
'EXECUÇÕES FISCAIS - PWC ASS EM PROCESSOS E NEGÓCIOS',
'ICMS NA BASE DE CÁLCULO DO PIS E COFINS',
'ENTCORP UK LTD.',
'AÇÃO DE COBRANÇA - BOVIEL KYOWA X CCO',
'MANDADO DE SEGURANÇA',
'ASSESSORIA PERMANENTE',
'EMBARGOS DE TERCEIROS',
'PROJECT CARLTON - ASSESSORIA SOCIETÁRIA',
'AVISO PRÉVIO INDENIZADO',
'CONTENCIOSO TRIBUTÁRIO',
'CAUTELAR - DOLLOND - BANCO PAULISTA',
'IMPUGNAÇÕES A AUTO DE INFRAÇÃO',
'MANIFEST DE INCONFORMIDADE DESPACHO DECISÓRIO Nº 017674355',
'MANIFEST. DE INCONFORMIDADE -DESP. DECISÓRIO 019157274',
'EMPLOYEE RELATIONS PWC',
'AUTO DE INFRACAO 4.024.150-6 MULTA INIDONEA COMBRAZEM',
'ASSESSORIA IMIGRATÓRIA PERMANENTE - JAGUAR LAND ROVER',
'ASSESSORIA JURÍDICA - LGPD - WINE',
'TRIBUTAÇÃO SELIC - INDÉBITO TRIBUTÁRIO',
'EXCLUSÃO DO PIS E COFINS DAS PRÓPRIAS BASES DE CÁLCULO',
'AVANOS - CORPORATE SECRETARIAL SERVICES',
'ASPECTOS LEGAIS E REGULATÓRIOS - GUNDERSON',
'DELTA - ELTEK AND DELTA BRASIL CORPORATE ASSISTANCE',
'BP BUNGE - ASSESSORIA PERMANENTE',
'AÇÃO JUDICIAL SISTEMA S',
'PROJETO TOKYO - ASSESSORIA LEGAL',
'WEENER - POAS',
'SIMPRESS COMERCIO LOCACAO E SERVICOS LTDA.',
'LONZA AMERICA, INC',
'PROJETO FONTE - AUTOS DE INFRAÇÃO - SÓCIOS',
'HONDA - LGPD CONNECTED PROJECT',
'IHI BACEN ASSISTANCE',
'MANDADO DE SEGURANÇA - SESI, SENAI, SESC, OUTROS',
'MS - EXCL. DO ICMS DA BASE DE CÁLC. DO PIS/COFINS',
'AÇÃO REPETIÇÃO DO INDÉBITO SESC E SENAC',
'STARBOARD ATUALIZAÇÃO',
'SAINT-GOBAIN - PROJETO CEBRACE',
'IBM - ROYALTIES WHT MEMO 2023',
'UBER - BR WHT ANALYSIS',
'CURIMBABA - CONSULTORIA TRIBUTÁRIA',
'PROJECT PLASTIC',
'Projeto Spring',
'COMPLIANCE  TP',
'MOHAWK - PILLAR 2 BR ASSISTANCE',
'CP KELCO TP E ECF 2023',
'PROJECT ATLANTIC',
'BYTEDANCE 2023',
'PLEITO SUDAM',
'REVISÃO DE ECF 2023_2022',
'MICHELIN - APOIO AUTUAÇÃO',
'PROJETO DUBAI - ATUALIZACAO',
'MEGLOBAL_TRC_TAX_FY23',
'PROJETO ATLAS (SEB)',
'CLEARSALE - DIAGNÓSTICO DA ESTRUTURA INTERNACIONAL',
'PROJETO EVEREST',
'PROJECT DINO',
'Monitoramento Contínuo CBO',
'Controles internos de Compliance',
'GMB - AUDITORIA DE GAP 2023',
'PROJETO DOIS CÓRREGOS',
'Preenchimento ECF 2022',
'PROJECT ATENA',
'Projeto Mosqueteiros Fase 1',
'Project Unicorn',
'FY24 - FITESA NT - CONSULTORIA PERMANENTE',
'CERNER- REVISÃO BASE E ECF AC 2022',
'REVISÃO GOVERNANÇA 2023',
'Projeto River',
'Projeto Rare',
'PROJETO ROBSON',
'PROJECT HOCKEY.',
'Projeto Axé',
'Project Rocket',
'Consultoria Tributária 2023',
'AFTON - REVISÃO ECF AC 2022',
'FEDEX   TP OCDE',
'SIERENTZ - TP E APOIO EXPORTAÇÃO',
'FedEx   Scenario B FY23',
'Valeo TP 2011 - Apoio ao Assistente de perícia Ju',
'ANFAVEA DEZ/2022 AUDIT',
'CORURIPE COMPLIANCE 2022',
'HYDRO - TP CY 2018, 2019 E 2020',
'BLUE HEALTH 2022',
'Monitoramento Contínuo Frooty',
'Adicional do LEX',
'REESTRUTURAÇÃO SOCIETÁRIA - NEOENERGIA - PROJETO UNIQUE',
'COMPLIANCE 22.23',
'EPIC GAMES - ITS BR 2022',
'Palmyra - Siscomex 2022',
'TITANX   PROJECT BRAZIL',
'AVL SOUTH AMERICA LTDA DEZ/202',
'E-CREDAC CUSTEIO',
'Project Helius',
'ORGUEL REVISÃO DIFERIDO ÚLTIMOS 5 ANOS',
'TORRA TORRA FASE 2',
'PROJETO JOULE',
'PROJETO EMS',
'ORIGEM- REVISÃO IRPJ/CSLL E ECF',
'RECUPERAÇÃO TAXA SISCOMEX 2023',
'ORIGEM- REVISÃO TRIMESTRAL IRPJ/CSLL 2023',
'LIBBS CONSULTORIA FISCAL 2023',
'META - TAX BR CONSULTING',
'BEMOL 2023 - AC 2022',
'Project Vessel BR',
'DISNEY - FTC/ITS BR',
'INDRA   CY 2022 TP COMPLIANCE',
'PROJETO DIVERSEY TP 2020/2021',
'ICATU IFRS17',
'ANÁLISE PIS E COFINS',
'PALMYRA - EXTRAÇÃO SISCOMEX 2020',
'FY21 - PWC GERMANY FLIXBUS - BUSINESS MODEL',
'BHP - CONSULTORIA PERMANENTE',
'FY22 - PWC ALEMANHA FLIXBUS',
'PROSPECÇÃO DE LAUDO IPI - UL',
'PREPARO DE CÁLCULO TP - THERMO FISHER AC 2020',
'TP ASSESSMENT & REVIEW   HENGST BRASIL   FY 2020',
'MINERAÇÃO CARAÍBA - JSCP',
'GRID SOLUTIONS',
'PWC CHINA  CNOOC',
'PREÇOS DE TRANSFERÊNCIA',
'REINTEGRA AND REINTEGRA ADDITIONAL TAX RESIDUE',
'LAUDO DE CONSTATAÇÃO',
'ASA RENT A CAR - PLANEJAMENTOTRIBUTÁRIO',
'PWC US - OSISOFT   AVEVA   PWC US   CAPITAL GAIN ANALYSIS',
'TP REVIEW   CAP',
'FLEXNGATE - DIAGNÓSTICO CONTÁBIL E FISCAL - INDENIZAÇÃO',
'TAX 2021',
'FY22 - PWC HOLANDA TUPY',
'CORURIPE ICMS BC PIS COFINS',
'FY22- PWC SPAIN LABORATORIOS LESVI',
'RENOVAÇÃO CYTIVA_2022',
'PWC CHINA CNIC - BRAZILIAN TAX ADVICE',
'MSJ   ICMS nas bases do PIS e da COFINS',
'F. BRADESCO - GOVERNANÇA E CONTROLES',
'CARTA CONSULTA - ERP PARA CUSTO - TF',
'CUSTOMS SUPPORT - FY23 BR',
'MONITORAMENTO CONTÍNUO - ENTREVIAS',
'COMPLIANCE 2023',
'UMICORE 2023 ECF E TP',
'RETIFICAÇÃO E PREENCHIMENTO ECD E ECF 2021 E 2022',
'PERMIAN BRAZIL - PWC UK',
'TP Compliance AC 2021   Eventbrite Brazil',
'MSA   PREÇOS DE TRANSFERÊNCIA 2021',
'Goemil TAX Revisão obrigaçõesacessórias 2021',
'Zilor projetos expansão',
'VW - MATERIAIS INTERMEDIÁRIOS E DIFAL',
'ANÁLISE NCM',
'GUARANÁ',
'MIGNON',
'PROJETO TUNA',
'PROJETO SANTA MARIA 2013 - APOIO CF',
'APOIO HOPI HARI 2013',
'SEAC - REESTRUTURAÇÃO',
'ASSESSORIA SEAC',
'PROJECT ICHIBAN- VALUATION',
'JOB DE APOIO A AUDITORIA',
'PROJETO ASTECA 2',
'PROJECT GOLD',
'PROJETO JUPITER',
'PROJECT SALTA',
'PROJECT ART',
'PROJECT PARK',
'PROJETO EUROPA - VIENNA',
'PROJETO CANELA',
'PROJETO SALAR',
'PROJETO STARSHIP',
'PROJETO KAIMARA',
'PROJETO GRANFLOR',
'PROJETO SUNSHINE',
'PROJETO TERRA BOA',
'PROJETO PELE',
'PROJETO JARDIM',
'PROJETO GRAMADO',
'POWER OF DATA',
'PROJECT AUTOMATUS',
'PROJETO VERTEX',
'AÇÃO DE COBRANÇA SENAI - PRINCIPAL',
'INQUÉRITO CIVIL',
'CLOUDHQ - DIRECTORS GUIDELINES',
'ANALYSIS ON RESTRUCTURING - ERAMET',
'ASSESSORIA LGPD - EDITORA PLANETA',
'NOVUS - TP CY 2022',
'BOEING',
'CMAAS',
'BOMBONERA',
'HBL CONSULTORIA - SPF',
'TP 2015',
'ATUALIZAÇÃO DO BIA',
'CLIMATE RISK ASSESSMENT TOOL FOR FINANCIAL INSTITUTIONS',
'WEATHERFORD - ASSESSORIA TRIBUTÁRIA',
'SUBSEA',
'BODYCOTE BRASIMET',
'CONSULTORIA EM GESTAO DE CRISES & CONTINUIDADE DE NEGÓCIOS',
'ULYSSES',
'VER O PESO',
'COPERSUCAR RAO',
'CONSULTA DECOLAR PWC US',
'FY18-STAFF LOAN',
'SERVITECH 2018',
'CENTRAL IT 2018',
'CMOC_VENDA DE CRÉDITOS DE ICMS',
'DIAGNOSTICO IFRS 9 E 16',
'MACHU PICCHU',
'PROJETO NAVIO',
'DIPJ 2013',
'PROJETO PICUÍ',
'DIPJ2013/CONSULTORIA PERMANENTE/FIN48',
'MANULI - MAXIMIZAÇÃO REINTEGRA',
'WPR SAO LUIS GESTAO DE PORTOSE TERMINAIS AUD 2019',
'FY 19 - PWC US - LIME - INTL TAX CONSULTING - BUSINESS MODEL',
'JTEKT - DIAGNOSTICO ROTA 2030',
'TAX - LABOR, SOCIAL SECURITY AND HR CONSULTING SERVICES',
'PWC ALEMANHA - MELITTA GROUP MANAGEMENT GMBH & CO. KG',
'FY20 - PWC US/DOLBY -ALIGNMENT',
'VOPAK BRASIL S.A.',
'NISSAN DO BRASIL_PIS E COFINS',
'AFP 2020',
'ECF E TP - SEOYON_2019_2020',
'SUPORTE À MIGRAÇÃO PARA AGROINDÚSTRIA',
'FY21 - PWC US - BRIDGESTONE -STRUCTURING',
'ATC   PROJECT PROSPER',
'DAS - ECF 2020 + OPORTUNIDADES',
'INDUSTRIAS ROSSI 2021',
'FY21 PWC US EASTMAN ITS',
'CIMENTO ITAMBÉ - REVISÃO RISCOS E CONTROLES 2021',
'AUDITORIA INTERNA 2021',
'ALUPAR - AUDITORIA INTERNA 2021',
'MECAPLAST DO BRASIL, IND, COMERCIO, IMP. E EXPORTAÇÃO 2013',
'MALLINCKRODT DO BRASIL LTDA.',
'REMESSAS PARA O EXTERIOR',
'OPORTUNIDADES ADVISORY',
'AB ENERGY DO BRASIL LTDA - SPF',
'HELLMANN - CERTIFICADO DE RESIDÊNCIA',
'BERGAMO DIAGNOSTICO',
'REVISÃO FISCAL 2020',
'EXCLUSÃO ICMS BC PIS COFINS - FY 2021',
'PROJETO MEMORANDO DE REESTRUTURAÇÃO DE OPERAÇÃO',
'LINX S.A. - SOX INTERNAL CONTROLS',
'CMAAS ACCOUNTING ADVISORY',
'FY21 - CITROSUCO - REESTRUTURAÇÃO',
'REVISÃO DO CÁLCULO DO ICMS NA BASE DO PIS/COFINS',
'PAYSAFE GROUP - GLOBAL TAX HEALTH CHECK - BRAZIL',
'EXCLUSÃO DO ICMS DA BC DO PIS E COFINS',
'REVISÃO LUCRO DA EXPLORAÇÃO - ADICIONAL',
'VALORES ADUANEIROS',
'BLASER   PREPARO TP 2021',
'FY22 - PWC ESPANHA FINI - ITS',
'PWC ITÁLIA - CONSULTORIA ENEL',
'MOFFAT & NICHOL - SPF',
'TAX PACKAGE - REVIEW OF YEAR-END TAX PACKAGE',
'PROJECT DURAN CLOSING',
'HSI - AUXILIO FATCA',
'PROJETO HISTORY',
'RESTAURANT BRANDS INTERNATIONAL (RBI)',
'INVIVO NUTRIÇÃO E SAUDE ANIMAL LTDA',
'GRUPO ELFA - GB MEDCOM (PART.1)',
'GOEMIL TAX',
'RD - AUDITORIA INTERNA 2021',
'AVALIAÇÃO DO DEEMED COST',
'RENEWABLES P&W - POS SCH',
'ALSTOM TERMICA',
'GE CELMA',
'CAT 17',
'NATULAB AUDITORIA INTERNA 2021',
'EXPENSE REPORT REVIEW',
'LINKEDIN (ESPELHO 08002080/0001)',
'HOTELBEDS',
'UNILEVER - LAUDO DE CONSTATAÇÃO',
'EMERSON PROCESS',
'[S&] SERASA - ASSESSMENT ID&FRAUD MARKET',
'BUNGE PLANT-PROTEIN LATAM',
'VFS REVISÕES TRIBUTÁRIAS 2021',
'RHODIA - OTIMIZAÇÃO TRIBUTÁRIA',
'AMEROPA AG',
'DIFERIDO 2017 A 2021',
'PARECER TÉCNICO - LC192/22 - CIAPETRO',
'LEVAPAN ACQUISITION - LESAFFRE',
'PWC NORUEGA - CONSULTA PROSAFE',
'PWC UK PROJECT FLORA',
'Pro Forma Atacadão S.A.',
'AES Brasil   Recuperação incentivo Sudene - MS',
'UPL - Lei do Bem 2021',
'White Paper Consolidção',
'FY22 - PWC US DREXEL UNIVERSITY',
'PWC MALASIA AET SHUTTLE TANKERS SDN BHD',
'PWC DK (NOVO NORDISK TPR AUDIT)',
'Consultoria IAS 21 - Política Contábil e Análise',
'STAFF LOAN',
'Davita 2022/2023 - PPA adquiridas',
'GRUPO ELFA - COMPLIANCE',
'SUZANO - REVISÃO DE ALTERNATIVAS - TP E DIRETRIZES OCDE',
'GRUPO BAKER_ECF E REV. IR/CS',
'Prática - Valuation e Análise IPO',
'Ivoclar - TP 2022',
'Projeto Kappa - ITDD',
'Banese',
'PWC CH DATWYLER',
'Preenchimento ECD Evento Especial',
'Darling - Consulting - Loan/Interest Analysis (Br',
'MYLAN TAX 2023',
'NORS - TP',
'PROMEDON   PREÇOS DE TRANSFERÊNCIA',
'Valuation Metalkraft 2023',
'ULTRAGENYX   TP 2022',
'PPA UHE Mascarenhas',
'Canva - ITS Consulting- V2',
' LVMH - TP Documentation (Brazil)',
'PALANTIR   TP 2022',
'Micro Focus - TP 2022 (Brazil)',
'CYTIVA_RENOVAÇÃO 2023',
'AVALIAÇÃO DAS OPORTUNIDADES DE SINERGIA E MODELO DE ALOCAÇÃO',
'DIACO & METALDOM - MARKET ASSESSMENT',
'ASSAI - DISCUSSAO ESTRATEGICA CA',
'Softys   TP 2022',
'CbCR notification 2022 (Brazil)',
'CPFL - Benchmarking de Capital Humano 2023',
'PPA MQ Solutions',
'BENCHMARK - CORPORATE ASSISTANCE',
'EXCLUSÃO DO ICMS NA BC DO PIS E COFINS',
'SMR AUDITORIA INTERNA 2021',
'IMPACTOS TRIBUTÁRIOS PARA CONSTRUÇÃO DE NOVA SEDE',
'MILLENIUM_PE_PWC US',
'CONSULTA - JCP',
'FY22 - SANTA CRUZ',
'GAVILON CONSULTA HEDGE',
'WOLPAC 2021',
'VOLVO - TP',
'PWC US BRIDGESTONE - ADDITIONAL HOURS',
'PWC SUÉCIA - EPIROC SWEDEN',
'LUMEN III - FR ENEVA 3T21',
'COLGATE - REVISÃO SELIC - IRPJ/CSLL',
'ASHCROFT IA 2021',
'FY22 - PWC ALEMANHA ADIDAS AG',
'FY22 - PWC US COLFAX CORPORATION',
'ITAÚ - ASSEGURAÇÃO INR 2020',
'BOTICARIO - ITS - AVALIAÇÃO US E ÁSIA',
'FAZENDA SANTA FÉ 2021 AUDIT',
'FY22 - PWC DINAMARCA NOVOZYMES',
'PROJETO CUSTOMS CONSULTANCY',
'ATENTO - REVISÃO 20-F',
'DIAGNÓSTICO METODOLOGIA E CONCEITO CALCULO IFRS16',
'FY22 - PWC US CINEMARK',
'PROJETO DE ASSESSORIA NO PROCESSO DE TRANSPORTATION',
'GOVERNANÇA DE TI - COBIT 5',
'CAF CYBER',
'DOW - MAPEAMENTO DE PROCESSOS',
'ARGO INTERNATIONAL - BRAZIL TAX ASSISTANCE',
'WINDACRE PARTNERSHIP - PETROBRAS - ADR',
'SECURITY OPERATIONS CENTER',
'BRAZIL DATA LAKE TECHNOLOGY PROJECT',
'GREEN DARNER',
'SERVICO DE DETECCAO E RESPOSTA ESTRUTURADA A INCIDENTES DE C',
'FRTB - IMPLEMENTAÇÃO',
'GOVERNANÇA DE TI E DIMENSIONAMENTO DE EQUIPE',
'IMPLANTAÇÃO DE SOLUÇÃO DE AUTOMAÇÃO DE TESTES IQA',
'COLGATE PALM COMERCIAL 2010',
'PRYSMIAN ENERGIA CABOS E SIS.DO BRASIL S.A. 2014',
'MORLAN 2014',
'CIA DO TERNO   AUDITORIA 2014',
'MASTERFOODS',
'BRASKEM 2014 - AUDITORIA',
'AUDITORIA DAS DFS GRUPO BANIF 2014',
'TUPY - ACCOUNTING ADVISORY - PROJETO OCHOA',
'PROGRAMA ARRANJO ALELO GRC',
'Programa de Cyber OT',
'TESTE',
'DIAGNÓSTICO DE SOD',
'Comgás   Avaliação de controles de TI',
'APACHE',
'EXTENSÃO MONITORAÇÃO CORTEX - NDI',
'ELETROPAR - AUDITORIA 2010',
'OPTOTAL HOYA',
'AUDITORIA 2010 - AF',
'VALE FERTILIZANTES 2011',
'REDTREE PARTICIPAÇÕES S.A.',
'BORLAND LATIN AMERICA LTDA. 2011',
'SITEL DO BRASIL LTDA. 2011',
--'EXAME DAS DF'S - OFFICE NET DO BRASIL S.A',
'INTERCÂMBIO - DESPESAS',
'ASSURANT SEGURADORA',
'COMGÁS AUDITORIA IFRS 2006',
'CPM',
'LABORATÓRIO AMERICANO DE FARMACOTERAPIA S.A. 2008',
'ATLÂNTICA EXPORTAÇÃO E IMPORTAÇÃO LTDA.',
'INSTITUTO SOU DA PAZ 2018',
'JCPM 2018',
'CAFÉ DO BRASIL 2018',
'IBIRITERMO 2018',
'B&C SPEAKERS 2018',
'FABIO DORIA',
'REVISÃO PROVISÃO FAP',
'KORN FERRY BRASIL',
'TETRA',
'99 TECNOLOGIA',
'SICOOB AUDITORIA',
'OA   PROJETO OCEAN',
'FARNELL NEWARK BRASIL DIST. DEPROD. ELETRÔNICOS',
'ANION ASSURANCE 2014',
'ADISSEO BRASIL NUTRIÇÃO ANIMAL LTDA. 2015',
'ITAU 2015-DEMONSTR FINANCEIRAS EXERCICIO',
'PROSPERITAS INVESTIMENTOS S.A.2015',
'SOC. DE ENSINO SUPERIOR ESTÁCIO DE SÁ',
'AUDITORIA MONTESANTO   ATLANTICA IMPORTAÇÃO E EXPORTAÇÃO',
'AUDITORIA MONTESANTO   MONTESANTO LOGÍSTICA',
'ASK   PROCEDIMENTOS PRÉ-ACORDADOS',
'SOBRAL INVICTA 2012',
'ACCIONA INFRAESTRUCTURAS S.A.2013',
'OJI PAPEIS ESPECIAIS LTDA 2013',
'ALUMINA LIMITED DO BRASIL S.A2015',
'IAPP - 2015',
'2015_PROCEDIMENTOS PREVIAMENTE ACORDADOS (PPA)',
'SAMSUNG SDS LATIN AMERICA SOLUÇÕES EM TEC. LTDA. 2015',
'INGERSOLL RAND DO BRASILLTDA. 2015',
'TIM 2015',
'POLO PRECATÓRIO FIDC NP - AUDITORIA 2015',
'PSS - SEGURIDADE SOCIAL 2019',
'ENDRESS AUTOMAÇÃO 2018',
'ENDRESS AUTOMAÇÃO 2019',
'CONCESSIONÁRIA RIO TERESÓPOLIS - CRT 2019',
'PIRAQUE 2019',
'FUNDOS BB GESTÃO DE RECURSOS DTVM  2021',
'SANTA CLARA AGROCIENCIA INDUSTRIAL LTDA. 2020/2021',
'CONCESSIONÁRIA AEROPORTO RIO DE JANEIRO 2020',
'ASSOCIAÇÃO PASSOS MÁGICOS  2018',
'PSS - SEGURIDADE SOCIAL 2018',
'BB PREVIDÊNCIA 2018',
'COMPANHIA GERAÇÃO DE ENERGIA PILÃO 2018',
'NACIONAL CLUBE 2018',
'FUNDOS CREDIT AGRICOLE 2018',
'SINDITÊXTIL - AUDITORIA 2014',
'GRENDENE 2015',
'KODAK - AUDITORIA 2015',
'BRHC - AUDITORIA 2015',
'FARMOQUÍMICA 2015',
'LABORATÓRIO PADRÃO S.A. 2015',
'RHI 2018',
'ITAIPU BINACIONAL 2018',
'INSTITUTO AKATU 2018',
'TOSHIBA 2018',
'MAXIMIDIA 2018',
'CLUBE MAXIVIDA 2018',
'CROWN 2018',
'RESERVA PATAMARES II EMPREENDIMENTOS IMOBILIÁRIO S.A',
'KALUNGA COM. E IND. GRAFICATESTE',
'CONGREGAÇÃO SANTA CRUZ 2016',
'FARNELL NEWARK BRASIL DIST. DEPROD. ELETRÔNICOS 2016',
'ITAU 2018',
'CAIXA SEGURIDADE 2018',
'LIBRA HOLDING S.A. 2018',
'DYNAMO ADMINISTRAÇÃO DE RECURSOS - 2018',
'WHITE MARTINS PECEM GASES 2018',
'MONASHEES 2018',
'SANRIO DO BRASIL COM. E REPRES LTDA.  2019',
'OPP GRMS',
'NOVO NORDISK 2013',
'DESPESAS',
'PROJETO SIERRA UPDATE',
'ABRIL S.A 2013',
'SUPORTE AO ESCRITÓRIO DA PWC DE LONDRES - ARCELORMITTAL - 20',
'BANCO MODAL 2021',
'DART - TUPPERWARE 2021',
'PRUDENTIAL DO BRASIL SEGUROS 2',
'B.BRAUN 2021',
'ASPEN PHARMA  2021',
'VALE 2021',
'AMAZON EMPLOYMENT TAXES',
'CDB AVIATION',
'ELECTRONIC ARTS',
'JCN - JOSE IZIDORO',
'ORICA',
'SKY - CYBERSECURITY SOC - PARTE 1 - 2023-2024',
'Ultra   Avaliação de Controles de Seg. ERP',
'PROJETO APRESENTAÇÃO INSTITUCIONAL DA TI',
'MATRIZ SOD CVC CORP',
'EMBRACO INDU DE COMPRESSORES E',
'EMBRAER 2021',
'EXXONMOBIL BUSINESS SUPP. CENT',
'NORDEX ENERGY BRASIL 2021',
'IFF ESSENCIAS E FRAGRANCIAS LTDA 2021',
'OUTBACK STEACKHOUSE REST.BRASI',
'GEFRAN 2021',
'FUND. ABRINQ PELOS DIREITOS DA',
'IOB 2008',
'ELEVADORES OTIS LTDA.',
'MUELLER PARTICIPACOES 2021',
'SERRA VERDE PESQUISA E MINERAC',
'USAÇUCAR 2022',
'USINA SÃO JOSÉ -  2021',
'VIVENSIS 2021',
'CAFÉ BRASIL 12/2021 AUDIT',
'FQM AUDIT 2021',
'SCHWING 2016',
'VITACON 2016',
'UNIVERSO ONLINE S.A 2016',
'IAPP 2016',
'FUNDOS ADMINISTRADOS PELA GRADUAL CCTVM 2016',
'ALUMINA LIMITED DO BRASIL S.A2016',
'ITAU 2016-DEMONSTR FINANCEIRAS EXERCICIO',
'BANK OF AMERICA MERRIL LYNCH 2',
'UNICHARM  2021',
'EULER HERMES  2021',
'XP INVESTIMENTOS 2021',
'DOMO VENTURES FUND - FIP 2021',
'COPAGAZ 2021',
'DIGITAL HOUSE 2021',
'BOM NEGOCIO ATIVIDADES DE INTE',
'BHG 2021',
'HDI SEGUROS S.A. 2021',
'HERCULES DO BRASIL PRODUTOSQUI',
'AUTOMETAL S.A. 2021',
'INTERTEK  2021',
'AVON COSMÉTICOS LTDA. 2021',
'MOTOR PRESS BRASIL EDITORA LTDA 2016',
'CONSELHO EXECUTIVO DAS NORMAS PADRÃO CENP 2016',
'GP IFRS/USGAAP 2016',
'GÁS BRASILIANO 2016',
'LIQUIGAS - SUPORTE RADA 2015',
'FRANGOS PIONEIRO 2021',
'FUNDAÇÃO RENOVA 2021',
'GCB 2021',
'GENESISPAR 2021',
'GFP AUDI 2021',
'GL EMPREENDIMENTOS LTDA 2021',
'DANAPREV 2021',
'HSBC BI E HOLDING 2021',
'AGROCREDI 2021',
'APM TERMINALS ITAJAI  2021',
'COMPANHIA INDUSTRIAL DE CIMENTO APODI 2021',
'GRUPO ARAUCO 2021',
'VERISURE BRASIL MONIT. DE ALAR',
'DUPONT DO BRASIL S/A. 2021',
'NOVA ENERGIA 2021',
'PREVICAT SOC PREVIDENCIÁRIA 20',
'BASF SOCIEDADE DE PREVIDENCIAP',
'DHL EXPRESS (BRAZIL) LTDA. 2021',
'GL INDÚSTRIA 2021',
'GRÃO DE OURO  2021',
'GRUPO AMO 2021 AUDIT',
'VIA SUL VEICULOS S.A. 2021',
'HOTMART 2021',
'BANCO SANTANDER 2021',
'BANCO J.P. MORGAN 2021',
'TRAVEL ACE 2021',
'OMNILIFE BRASIL COMERCIO DE PRLTDA 2021',
'BEVAP 2022',
'HOSPITAL MATER DEI S.A.2021',
'ALLTECH DO BRASIL AGROINDUSTRI',
'CBMM SEGURIDADE 2019',
'TOKIO MARINE SEGURADORA S.A2019',
'BANCO TOYOTA 2019',
'FIBRIA CELULOSE S/A 2019',
'FUNDOS PEDRA AGROINDUSTRIAL 2019',
'REHAU INDÚSTRIA LTDA. 2019',
'SIMPAR 2021',
'FUNDOS HEDGE_2018',
'AUDITORIA CIPLAN E PLANALTO 2019',
'BMW 2019',
'VALE 2020',
'MCCAIN DO BRASIL ALIMENTOS LTDA. 2019',
'RECH AGRICOLA 2019',
'DARBY SERVTEC ENERGIA ESTRUTURA 2019',
'FBSS 2021',
'BTG PACTUAL G7 HOLDING 2021',
'CÂMARA DE COMERCIALIZAÇÃO DE ENERGIA ELÉTRICA - CCEE',
'FERRARI ZAGATTO - AUDITORIA 2021',
'BOA VISTA - REVISÃO 2021',
'TS AGRO EXAME 2021',
'BARTOFIL 2021',
'BIOMM 2021',
'BROCHMANN POLLIS 2021',
'CENECT - CENTRO INTEGRADO DE E',
'CGEP 2021',
'CONTAAZUL 2021',
'FTPI - EXAME 2021',
'REVISÃO CRÍTICA ESTUDO DE SUSTENTABILIDADE E ACV',
'BANCO DA CHINA - AUDITORIA 2021',
'ESTEE LAUDER JUNE 2021',
'EMBARÉ 2021',
'SGS BRASIL 2021',
'IAS 2021',
'KOERBER 2021',
'LACTOJARA  2021',
'MAXXIMA ENERGIA 2021',
'RAIA DROGASIL - SUPORTE RADA 2015',
'2016_PETROBRAS_DEMONSTRAÇÕES_FINANCEIRAS',
'RIO SOLIDÁRIO 2016',
'WHITE MARTINS GASES INDUSTRIAIS LTDA 2016',
'BETUNEL - AUDITORIA 2015',
'APOIO REVISÃO US GAAP',
'M. DIAS BRANCO 2017',
'COOP CENTRAL DE CRED RURAL COM1',
'CRISTAL PIGMENTOS DO BRASIL S.A. 2021',
'CUBICO 2021',
'CARBETO DE SILICIO SIKA BRASIL LTDA 2021',
'BCG 2019',
'STELLA IMPORTACAO E EXPORTACAO DE LUMINARIAS LTDA.2021',
'DRIL QUIP 2021',
'ARLANXEO BRASIL S.A. 2021',
'DYNAMO ADMINISTRAÇÃO 2021',
'HEINZ BRASIL S.A. 2019',
'GRUPO VOTORANTIM 2019',
'FLINTEC BRASIL 2019',
'ASSURANT SEGURADORA S.A 2019',
'RHI 2019',
'FLEXITECH 2019',
'ITAU 2019',
'FIIS E FIPS BTG 2021',
'CRÉDITO Y CAUCION SEGURADORA CRÉDITO E GARANTIAS 2021',
'BUNZL PLC 2021',
'KYOCERA DOCUMENT SOLUTIONS2021',
'BANCO INDUSVAL S.A. 2021',
'SONY BRASIL LTDA 2021',
'GYPSUM S.A. MINERACAO, INDUSTR',
'CARGOLIFT 2021',
'CODEMGE DEZ/2021 AUDIT',
'COMERCIAL DE SECOS E MOLHADOS',
'GAUSS 2021',
'LANDIS+GYR EQUIPAMENTOS DE MED',
'TSK DO BRASIL 2021',
'FUNDOS VISION BRAZIL INVESTMENTS - V9 FIDC NP 2019',
'BRL TRUST FUNDOS DE INVESTIMENTOS',
'BRITISH COLEGIO 2019',
'COLAB TECNOLOGIA E SERVIÇOS DE INTERNET 2018',
'CIRCUITO SP  2022',
'VOLKSWAGEN DO BRASIL IND. DE VEIC. AUTO LTDA 2017',
'WOW INDUSTRIA E COMERCIO LTDA2017',
'ASTIC TIC AUDITORIA 2016',
'PISANI PLÁSTICOS - EXAME 2017',
'VITACON 2017',
'UNIVERSO ONLINE S.A 2017',
'CDA 2017',
'AMBEV S.A 2022',
'ITAU 2022',
'BMG 2022',
'DLOCAL BRASIL 2021 AUDIT',
'CONDUCTOR 2022',
'DOCTORALIA BRASIL  2022',
'PHIBRO ANIMAL SAÚDE INTERNACIO 2022',
'TOYOTA BOSHOKU MAR 2023',
'UPSTREAM BRASIL PROMOCOES COMERCIAIS LTDA 2020',
'PROJETO WISER',
'CIPLAN E PLANALTO 2021',
'REFRESCOS BANDEIRANTES INDUSTRIA E COMERCIO LTDA 2021',
'AGRO GALAXY 21',
'GRUPO RBS 2021',
'DELL 2022',
'EBANX - AUDITORIA 2020 E 2019',
'WALTERSCHEID - EXAME 2020',
'TAM S.A - AUDITORIA 31/12/2021',
'VAN HESSEN - AUDIT 2021',
'SONY BRASIL 2021',
'PROFIGEN 2021',
'ANCAR IVANHOE SHOPPING CENTERS',
'CERÂMICA ELIZABETH LTDA 2021',
'PROGRESSRAIL LOCOMOTIVAS DO BR',
'E. M. COLLI EIRELI 2021',
'TOLEDO - AUDITORIA LI 2020',
'FLEURY S.A 2021',
'BOMBRIL S.A. 2021',
'NATURA COSMETICOS S.A 2021',
'NATURA &CO HOLDING S.A. 2021',
'NEXA RESOURCES S.A. 2021',
'ORISOL DO BRASIL INDUSTRIA 2019',
'PMU BRASIL 2019',
'PRO VEÍCULO - DRAGON',
'CAIXA ECONOMICA FEDERAL 2020',
'AGRO TRENDS PARTICIPAÇÕES S.A 2020',
'NEUGEBAUER 2020',
'UNIMED CAMPINAS 2020',
'ACUMENT 2019',
'I. SYSTEMS 2019',
'SAURER 2019',
'JUNIOR ACHIEVEMENT DO BRASIL2019',
'PETROGAL 2019',
'MAXIMIDIA 2019',
'CLUBE MAXIVIDA 2019',
'COMPANHIA MINERADORA DO PIROCLORO DE ARAXA COMIPA 2021',
'ASSOCIAÇÃO DAVID ROCKEFELLER HARVARD 2021 AUDIT',
'MINERAÇÃO APOENA DEZ/2021 AUDI',
'APS DEZ/2021 AUDIT',
'HEDGE FUNDOS  2021',
'CUMMINS BRASIL 2021',
'PARCEIROS VOLUNTÁRIOS 2021',
'LANGUIRU 2021',
'ARAUPEL 2021',
'CHINA BRASIL TABACOS (CBT) 202',
'MARELLI 2021',
'UNIFERTIL 2021',
'GENOA GLOBAL FUND SPC ALPHA AUDITORIA 2021',
'CONSTRUTORA BARBOSA MELLO S.A. - AUDITORIA 2021',
'[JOHN DEERE] PPA DO ROTA 2030 (2019 E 2020)',
'PRÉ-PROJETO CMAAS',
'7BRAV - 2021',
'VINCI GGN GESTAO DE RECURSOS',
'MINASA TRADING 2020',
'RT 001 EMPREENDIMENTOS E PARTICIPACOES LTDA.2018',
'SYMBIOSIS INVESTIMENTOS E PARTICIPAÇÕES LTDA. 2020',
'TAP MANUTENÇÃO E ENGENHARIABRA',
'VINCI PARTNERS 2020',
'4 BIO MEDICAMENTOS S.A. 2020',
'LA RONDINE 2019',
'CONFAB INDUSTRIAL SA 2022',
'CRISTAL PIGMENTOS DO BRASIL S.A. 2022',
'IAS 2022',
'JOHNSON & JOHNSON 2022',
'CABESP 2022',
'LABORATORIO DE PATOLOGIA CLINICA DR. FRANCESCHI LTDA 2022',
'CTEEP - 2022',
'SX NEGOCIOS 2022',
'PRODESENHO PARTICIPACOES SOCIETARIAS HUA LTDA 2020',
'TV CULTURA DEZ/2022',
'REHAU INDÚSTRIA LTDA. 2020',
'HEINZ BRASIL S.A. 2020',
'ALOG 02 SOLUÇÕES DE TECNOLOGIA2020',
'FLINTEC BRASIL 2020',
'NORDEX ENERGY BRASIL 2020',
'PAYU BRASIL INTERMEDIACAO DE NEGOCIOS LTDA 2021',
'ALFMA ALIMENTOS 2020',
'XP INVESTIMENTOS 2022',
'CONSORCIO DE ALUMINIO DO MARAN',
'RELOGIO ROLEX LTDA. 2021',
'VERDE ASSET 2021',
'BANCO FORD 2021',
'PAGSEGURO DIGITAL LTD 2021',
'QUIMISA S.A. 2021',
'CRUZEIRO DO SUL EDUCACIONAL S.A. 2021',
'RIO ENERGY PROJETOS DE ENERGIA',
'MOVILE INTERNATIONAL HOLDINGS B.V. 2022',
'BIONERGETICA AROEIRA LTDA. 2022',
'COMPANHIA BRASILEIRA DE TECNOL 2021',
'PROMETEON TYRE GROUP INDUSTRIA',
'SONAE SIERRA BRASIL 2021',
'PERSONAL CARE PARTICIPAÇÕES S.A. 2021',
'AMERICAN EXPRESS BRASIL ASSESSORIA EMPRESARIAL LTDA. 2021',
'CEF SUSTENTABILIDADE 2021',
'ASSEGURAÇÕES SUSTENTABILIDADE 2021',
'ZOBELE DO BRASIL 2022',
'S-8 VINCI PARTNERS INVESTMENT LTD. - ABRIL/22',
'LGT IMPACT INVESTMENT ASSESSORIA BRASIL 2021',
'HG EMPREENDIMENTOS EPARTICIPAÇ',
'BMG 2020',
'CIA DO TERNO 2020',
'DIREITO DE OUVIR  2020',
'FADEL TRANSPORTES E LOGISTICA',
'GL EMPREENDIMENTOS LTDA 2020',
'GRUPO BOM JESUS 2020',
'HAPVIDA 2022',
'BIOGEN 2021',
'SCALA DATACENTER DEZ/2022 AUDI',
'20-F 2021 MESA',
'ITAU 2020',
'JTEKT AUTOMOTIVA BRASIL LTDA.2',
'MONTANA 2020',
'OLIST 2020',
'SERRA VERDE PESQUISA E MINERACAO LTDA. 2020',
'GRUPO TENCO 2020',
'TERRA DOS VALES 2020',
'GL ELETRO 2021',
'ATMOSFERA 2017',
'INSTITUTO SOU DA PAZ 2017',
'MRS LOGÍSTICA_EXAME 2017',
'JOHNSON CONTROLS DO BRASIL AUTOMOTIVE LTDA 2017',
'ITAU 2017-DEMONSTR FINANCEIRAS EXERCICIO',
'ITAIPU - AUDITORIA 2017',
'TECHINT ENGENHARIA E CONSTRUÇÕES S.A. 2017',
'LEVANTINO FY17',
'GRAHAM PACKAGING 2017',
'CEG 2017',
'WHITE MARTINS GASES INDUSTRIAIS LTDA 2017',
'TRELLEBORG BRASIL 2017',
'PINESSO 2017',
'TODIMO MATERIAIS PARA CONSTRUÇÃO S.A 2017',
'FATURAMENTO DE DESPESAS - INTERCAMBIO',
'AG DE VAPORES GRIEG SA 2020',
'ANDEF 2020',
'SILTOTAL HOLDING S.A 2020',
'KUMON 2020',
'VINCI DISTR DE TITULOS E VALOR2020',
'KLL EQUIPAMENTOS PARA TRANSPOR',
'HMV  2021',
'KMW DO BRASIL 2021',
'GLOBAL DISTRIBUICAO DE BENS DE',
'IRMANDADE DA SANTA CASA DE MIS',
'HS FINANCEIRA S.A. CREDITO, FI',
'BORGWARNER 2021',
'FUNDOS MERCANTIL DO BRASIL CTVM 2021',
'MISSISSIPI PARTICIPAÇÕES 2021',
'MONDELEZ 2021',
'SVRE HOLDINGS - AUDITORIA 2020',
'NCR SÃO PAULO - AUDITORIA 2021',
'MAQUIRA - AUDITORIA 2021 - AUDIT',
'GENESYS 2021',
'FMS 2021',
'COMBIO ENERGIA 2021',
'GRUPO AMARANTES 2021',
'SX NEGOCIOS 2021',
'KERRY 2021',
'KSB 2021',
'SISTEMA SEBRAE 2021',
'CENTRAIS ELETRICAS BRASILEIRAS',
'YPIÓCA INDUSTRIAL E AGRÍCOLA A',
'PARATI INDUSTRIA E COMERCIO DE ALIMENTOS LTDA. 2022',
'CIA BRASILEIRA DE METALURGICAE MINERACAO 2022',
'INSTITUTO DIAGEO 2021',
'ALCON BRASIL CUIDADOS COM A SA',
'UNILEVERPREV 2022',
'BIOGEN 2022',
'CAR10 AUDITORIA 2021',
'BRW SUPRIMENTOS ESCOLARES DIAGNÓSTICO',
'ECORI ENERGIA SOLAR - AUDITORIA 2022',
'Copa Energia - Incorporação Liquigás 2022',
'CARITAS - AUDITORIA BID 2021',
'3M DEZ/2023 AUDIT',
'DOW AGROSCIENCES INDUSTRIAL LT',
'IQUINE 2022',
'AUXILIADORA PREDIAL LTDA 2022',
'MULTINER S.A. 2022',
'PRATT DEZ/2022 AUDIT',
'MADAL -  2022',
'RED HAT - 2022',
'NSAL - BDRS',
'ECORODOVIAS INFRAESTRUTURA E LOGISTICA S.A 2020',
'NAAE - DEZ/19 - GS',
'COMPANHIA DE DESENVOLVIMENTO DE MINAS GERAIS CODEMGE 2020',
'AERIS IND. E COM. DE EQUIP. PARA GERACAO DE ENERGIA S.A.2020',
'CIA BRASILEIRA DE METALURGICAE MINERACAO 2020',
'KORA DEZ/2023 AUDIT',
'CATHO ONLINE JUN/2023 PEDRO',
'DEXXOS PAR DEZ/2023 AUDIT',
'ITAIPU DEZ/2023 AUDIT',
'EXAME ANCORA 2023',
'NORSKAN OFFSHORE 2021',
'Cateno - AI Profit Sharing 2023',
'DIEBOLD - AUDITORIA LI 2022',
'CREDICITRUS 2022',
'GRUPO SANTA ISABEL - 2023',
'A. SCHULMAN BRASIL AUDITORIA - 2022',
'ANGLOGOLD ASHANTI - AUDITORIA2023',
'SABIC BRASIL - AUDITORIA 2022',
'TOTALENERGIES - AUDIT 2022',
'BANCO BV DEZ/2023 AUDIT',
'FISCHER DEZ/2023 AUDIT',
'CRESOL SC RS DEZ/2023 AUDIT',
'INFRAMERICA DEZ/2023 AUDIT',
'CIPLAN DEZ/2023 AUDIT',
'AGROGALAXY DEZ/2023 AUDIT',
'TERRA BRASIS RESSEGUROS S.A.',
'GRUPO SONORA 2017',
'PLAN AUDITORIA 2018',
'JALLES MACHADO S.A. 2018',
'NOVARTIS BIOCIÊNCIAS S.A. 2018',
'BANCO MODAL 2018',
'I. SYSTEMS 2018',
'BANCO FIDIS - AI 2022',
'BLACKHAWK - PAIVA',
'Stark Bank - AI 2023',
'DSI UNDERGROUND 2023',
'GEARBULK AUDIT DEZ/2023',
'WATERS TECHNOLOGIES DO BRASIL LTDA. 2022',
'WALTERSCHEID - EXAME 2021',
'FUNDAÇÃO LIBERTAS 2022',
'GIRA_REV JUNHO 2023 E EXAME DE AUDITORIA JUNHO 2023',
'SEMANTIX SPAC',
'NCR SÃO PAULO -  2022',
'ITER PARTICIPACOES 2022',
'GENESYS 2022',
'RENTCARS EIRELI - AUDIT 2021',
'CCEE - DIAGNÓSTICO AMBIENTE CONTROLES + QA',
'ACOMPANHAMENTO INVENTÁRIO BR - APOIO PWC PORTUGAL 2021',
'SANTO ANDRE PLANOS DE ASSISTENCIA MEDICA LTDA.',
'HMV  2022',
'MATA DE SANTA GENEBRA 2022',
'IFOOD.COM AGENCIA DE RESTAURANTES ONLINE S.A. 2021',
'FLEXTRONICS INTERNATIONAL TECNOLOGIA 2022 AUDIT NAAE',
'EDP RENOVÁVEIS BRASIL SA DEZ/2023 AUDIT',
'FIPS CRV DTVM 2018',
'MAN DIESEL 2018',
'COVESTRO 2018',
'WOW INDUSTRIA E COMERCIO LTDA2018',
'LUXOTTICA 2018',
'DORMA 2019 AUDIT',
'SAURER 2018',
'LE CORDON BLEU DEZ/2022 AUDIT',
'ANBIMA 2022',
'ANBIMA 2023',
'EMBARÃ¿ IND ALIMENTÃ¿CIAS DEZ/2023 AUDIT',
'LGD PACKEM INDUSTRIA E COMERCI',
'USIMECA IND MECANICA S.A DEZ/2023 AUDIT',
'FIPS ORIA DEZ/2023 AUDIT',
'TV CULTURA DEZ/2023 AUDIT',
'GCB HOLDINGS FAMILIARES DEZ/2023 AUDIT',
'GEOLAB DEZ/2023 AUDIT',
'MENDUBIM DEZ/2023 AUDIT',
'VIA - WHITEPAPER CONTÁBIL (ESPELHO 25048563)',
'AURA MINERALS - APOENA DEZ/2023 AUDIT',
'CICLUS REAUD DEZ/2023 AUDIT',
'FUNDAÇÃO FIBRA ITAIPU DEZ/2023 AUDIT',
'SIGURA WATERS IWC DEZ/2023 AUDIT',
'INTEGRADO DEZ/2023 AUDIT',
'WESTERN ASSET 2022',
'KYOCERA DOCUMENT SOLUTIONS 2022',
'ALOG 02 SOLUÇÕES DE TECNOLOGIA 2022',
'BANCO PINE 2022',
'PRIME SISTEMAS 2022',
'BANCO FORD 2022',
'NORDEX ENERGY BRASIL 2022',
'FUNDOS OFFSHORE XP ADVISORY 2021',
'BANCO SANTANDER 2023',
'EDP ENERGIA 2023',
'TELEFONICA SUBSIDIÁRIAS DEZ/2023 AUDIT',
'MONTES CLAROS - NOVO NORDISK PRODUÇÃO  2021',
'YESSINERGY DEZ/2023 AUDIT',
'AGRO EFFICIENCY DEZ/2023 AUDIT',
'TECHNIP DEZ/2023 AUDIT',
'CORSAN DEZ/2023 AUDIT',
'J. MACEDO S.A DEZ/2023 AUDIT',
'GRUPO CANTU STORE 2023',
'USINA ACUCAREIRA ESTER MAR/2024 AUDIT',
'THE WALT DISNEY COMPANY 2022',
'BRENNTAG DEZ/2023 AUDIT',
'TIMAC DEZ/2023 AUDIT',
'GETNET DEZ/2023 AUDIT',
'HMV DEZ/2023 AUDIT',
'KMW DO BRASIL DEZ/2023 AUDIT',
'SANTA CASA DEZ/2023 AUDIT',
'INOVAR PREVIDÊNCIA DEZ/2023 AUDIT',
'CANEX DEZ/2023 AUDIT',
'AMBEV DEZ/2023 AUDIT',
'VIVENSIS DEZ/2023 AUDIT',
'NATURA COSMÉTICOS DEZ/2023 AUDIT',
'NEXA RESOURCES DEZ/2023 AUDIT',
'REAG INVESTIMENTOS DEZ/2023 AUDIT',
'MAUA CAPITAL MAR/2023 AUDIT',
'BEMOBI DEZ/2023 AUDIT',
'FIBERCO DEZ/2023 AUDIT',
'PHIBRO SAÚDE ANIMAL SOCIETARIO 2022',
'DIRECIONAL DEZ/2023',
'NAAE CÓDIGO ANBIMA 2022',
'BAUMINAS DEZ/2023',
'CODEMGE DEZ/2023 AUDIT',
'VTEX - CIA DE TECNOLOGIA DEZ/2023 AUDIT',
'IHS DEZ/2023 AUDIT',
'BELLTECH DEZ/2023 AUDIT',
'BRILIA DEZ/2023 AUDIT',
'AUDITORIA VIDEOLAR-INNOVA 2023',
'ALLIANZ ADIANTAMENTO 2023',
'AEROPORTO RIO GALEÃO DEZ/2023 AUDIT',
'FUNDOS BB 555 DEZ/2023 AUDIT',
'ZAMP 2023',
'TAP MANUTENÇÃO E ENG. DEZ/2023 AUDIT',
'SONAE DEZ/2023 AUDIT',
'CRESCERA DEZ/2022 AUDIT',
'PROMONLOGICALIS FEV/2024 AUDIT',
'TELEFONICA BRASIL DEZ/2023 AUDIT',
'BRADESPAR DEZ/2023 AUDIT',
'MTU DO BRASIL DEZ/2023 AUDIT',
'DECOLAR DEZ/2023 AUDIT',
'FORM F-4 - VITRU',
'GLOVIS - AUDITORIA 2023',
'NOVA AGRI MAR/2024',
'SEL DEZ/2023',
'Asseguração Termo de Compromisso BCB 2023',
'MACQUARIE ENERGIA DEZ/2023',
'CRI 2º TRI 2023',
'VITAL BRAZIL DEZ/2023 AUDIT',
'GRENDENE S.A DEZ/2023 AUDIT',
'STATKRAFT DEZ/2023 AUDIT',
'REFINARIA RIO GRANDENSE DEZ/2023 AUDIT',
'SCALA DATACENTER DEZ/2023 AUDIT',
'RIZOBACTER JUN/2024 AUDIT',
'FQM DEZ/2023 AUDIT',
'ASA INDUSTRIA DEZ/2023 AUDIT',
'MACLEAN DEZ/2023 AUDIT',
'GYPSUM DEZ/2023 AUDIT CL',
'VENTANA DEZ/2023 AUDIT',
'AMCOR 2023',
'BANCO HSBC S.A. DEZ/2023 AUDIT',
'BANCO BS2 DEZ/2023 AUDIT',
'BARTOFIL DEZ/2023 AUDIT',
'BEM BRASIL DEZ/2023 AUDIT',
'BMG DEZ/2023 AUDIT',
'APS DEZ/2023 AUDIT',
'SEFAZ PI DEZ/2023 AUDIT',
'BMW DO BRASIL DEZ/2023 AUDIT',
'CENCOSUD DEZ/2023 AUDIT',
'COCAPEC DEZ/2023 AUDIT',
'COCRED DEZ/2023 AUDIT',
'CSD DEZ/2023 AUDIT',
'EXPORTADORA GUAXUPÉ DEZ/2023 AUDIT',
'GAZIN DEZ/2023 AUDIT',
'JOHNSON & JOHNSON DEZ/2023 AUDIT',
'MASCARELLO DEZ/2023 AUDIT',
'MONDELEZ DEZ/2023 AUDIT',
'RECH AGRICOLA DEZ/2023 AUDIT',
'SÃO MARTINHO MAR/2024 AUDIT',
'SYMPLA MAR/2024 AUDIT',
'HAPVIDA DEZ/2023 AUDIT',
'GRUPO SBF S.A DEZ/2023 AUDIT',
'CPFL DEZ/2023 AUDIT',
'COOP SING SICOOB GOIÁS DEZ/2023 AUDIT',
'VETBR DEZ/2023 AUDIT',
'VIDEPLAST DEZ/2023 AUDIT',
'BTG PACTUAL REINSURANCE DEZ/2022 AUDIT',
'CLÍNICA DA GÁVEA DEZ/2023 AUDIT',
'FJC DEZ/2023 AUDIT',
'RJR - DEZ/2023 AUDIT',
'MSD DEZ/2023 AUDIT',
'SACYR CONSTRUÇÕES DEZ/2023 AUDIT',
'CORURIPE MAR/2024 AUDIT',
'DISAM DISTRIBUIDORA DEZ/2023 AUDIT',
'AKER SOLUTIONS DEZ/2023 AUDIT',
'PEDREIRA DEZ/2023 AUDIT',
'FLORIPA SHOPPING DEZ/2023 AUDIT',
'WAYNE DEZ/2023 AUDIT',
'KERRY DEZ/2023 AUDIT',
'MINASA TRADING DEZ/2023 AUDIT',
'AVERY DENNISON DEZ/2023 AUDIT',
'FUCHS DEZ/2023 AUDIT',
'MAFP DEZ/2023 AUDIT',
'CEB DEZ/2023 AUDIT',
'WEBEDIA DEZ/2023 AUDIT',
'VALE DEZ/2023 AUDIT',
'AVON DEZ/2023 AUDIT',
'BANCO CCB DEZ/2023 AUDIT',
'CORTEVA AGRISCIENCE DEZ/2023 AUDIT',
'SUMUP DEZ/2023 AUDIT',
'MESA DEZ/2023 AUDIT',
'ALIGN TECHNOLOGY DEZ/2023 AUDIT',
'INSTITUTO CREDICITRUS DEZ/2023 AUDIT',
'REVISTA AMANHÃ DEZ/2023 AUDIT',
'LWART DEZ/2023 AUDIT',
'GEBSA-PREV DEZ/2023 AUDIT',
'VICUNHA DEZ/2023 AUDIT',
'WESTERN ASSET DEZ/2023 AUDIT',
'SANTA CRUZ DEZ/2023 AUDIT',
'BIOLAB FARMACEUTICA DEZ/2023 AUDIT',
'ANGLOGOLD - DEZ/2024 AUDIT',
'VIRTUE BRASIL DEZ/2023 AUDIT',
'SABIC BRASIL DEZ/2023 AUDIT',
'APEX CAPITAL DEZ/2022 AUDIT',
'SANTA PLURAL DEZ/2023 AUDIT',
'COLGATE PALMOLIVE DEZ/2023 AUDIT',
'PHIBRO SAÚDE ANIMAL JUN/2023 AUDIT',
'CISCO DO BRASIL DEZ/2023 AUDIT',
'NORDEX ENERGY BRASIL DEZ/2023 AUDIT',
'DRAGER INDUSTRIA DEZ/2023 AUDIT',
'GRUPO ALLIANZ SEG&SAÚDE DEZ/2023 AUDIT')








select * from brdw.view_customerdebtor_polaris





SELECT
	[CustomerDebtor_Key]
    ,[COD_ENTITY]
    ,[COD_PROJECT]
    ,[COD_JOB]
    ,[DES_NativeDebtorPartyName]
    ,[COD_NativePwc]
    ,[COD_DebtorPartyID]
    ,[COD_NativePartyID]
    ,[DES_DebtorPartyName]
    ,[DES_NativeDebtorPartyId]
    ,[COD_DebtorParty]
	--count(*),
	--case when COD_DebtorParty is null then 'NULO' else 'NÃO NULO' end
FROM [BRdw].[View_CustomerDebtor_Polaris]
where COD_DebtorParty is null

where DES_NativeDebtorPartyName like '%ZURICH%'
	DES_NativeDebtorPartyName IN (
'CÁLCULO DE LAT - JUN/2012',
'BRADESCO - BAC - VALUATION E PPA',
'CODESA - DEALS SP',
'AVALIAÇÃO ATUARIAL CPC-33 2020',
'BK BRASIL OPERACAO E ASSESSORIA A RESTAURANTES S.A.',
'PROJETO LER',
'OUTSOURCING - LIDER',
'AA 2021 - ZURICH SANTANDER',
'SUPPLIER DEVELOPMENT & PERFORMANCE PROGRAM IN BRAZIL',
'ASSESSMENT DE FORNECEDORES',
'Bradesco - Auditoria VCMH',
'Outsourcing 2022 - SeguradoraLider',
'IRB - REVISÃO DO PLA',
'ALFA - IFRS 9 E 17',
'RECONCILIAÇÃO FATURAMENTO 2013',
'INOVAÇÃO TECNOLÓGICA NESTLÉ',
'CIA SEGUROS DA BAHIA-ICMS',
'AIRE',
'TRABALHOS GMRS',
'VERYCOM - PROPOSTA 2005',
'SARBOX ATTESTATION - 2006',
'CARBOCLORO S.A.',
'PMO- DESENVOLVIMENTO SUSTENTÁVEL',
'PMO_IFRS',
'BLABLA',
'SOFT 5',
'MERLUZA',
'FONTE',
'SANTOS',
'ASSESSORIA',
'DISAL-CORR MONETARIA - PROCESSOS CONTENCIOSOS - FI',
'COFINS - PROCESSOS CONTENCIOSOS - OUTROS',
'WELLA/BELFAM',
'IMUNIDADE EXPORTAÇÃO',
'AÇÃO - ISS - COLETORES DE DADOS',
'ICMS (EXECUÇÕES FISCAIS-MACAÉ)',
'AÇÃO JUDICIAL KF',
'ASSESSORIA SOCIETÁRIA',
'PARCELAMENTO LEI 11.941/2009',
'ISS - SÃO PAULO',
'FAP',
'LEI Nº 11.941',
'LEI Nº 11.941/09',
'CONTRIBUIÇÃO AO SAT',
'ESPÓLIO DE ARTHUR LESLIE DOLLOND',
'NOVOS PROCESSOS TRIBUTÁRIOS EPREVIDENCIÁRIOS',
'FAP 2011',
'MANDADO DE SEGURANÇA - Nº 0008571-85.2011.403.6100',
'PROCESSO ADMINISTRATIVO Nº 12157.000087/2009-67',
'IRPF - INCORPORAÇÃO DE AÇÕES',
'MANIFESTACAO DE INCONFORMIDADE - DESPACHO DECISORIO 00561550',
'CMB - AÇÃO JUDICIAL PIS E COFINS - SELIC',
'CMB AÇÃO DE REPETIÇÃO DO INDÉBITO SESC E SENAC',
'ABBVIE   APOIO REGULATÓRIO',
'ZURICH LIVEWELL - CDC - APOIO CÍVEL',
'SAP - AÇÃO ANULATÓRIA - HIT',
'COFINS 0805268-75.2016.4.05.8500',
'IMPUGNAÇÕES MULTA ISOLADA',
'II / IPI ADMISSÃO TEMPORÁRIA',
'ESAB AUMENTO DE CAPITAL POR ESTRANGEIRO',
'FAMILIA KISS   TESTAMENTO E INVENTÁRIO',
'ASSAI PROJETO C',
'DATWYLER ANÁLISE CT VCP E REGISTRO INPI E BACEN',
'ACOMPANHAMENTO DE PROCESSOS',
'CTI BRAZILIAN LEGAL ASSISTANCE',
'ASSESSORIA JURÍDICA',
'DEFESAS ADMINISTRATIVAS - AURORA',
'ESAB ASSESSORIA SOCIETÁRIA BR',
'APTIV - JUROS SOBRE CAPITAL PRÓPRIO 2023',
'BANESE AIIM 02/2023 - CAPELA',
'ENEL APOIO CONSULTIVO (CTO GERAL)',
'KORN/FERRY INTERNATIONAL LTDA. - CONTÁBIL',
'CA - PWCO',
'BTO - IMPLANTAÇÃO',
'VITRO OUTSOURCING TECNOLOGIA',
'FLAGSTONE',
'BANCO FATOR - HRO',
'BUMI ARMADA',
'TAX COMPLIANCE_HYPERTHERM',
'SEED',
'CITROPAR_REDPAR_TRC_TAX COMPLIANCE_JAN23_DEC23',
'Medison Tax 2023',
'PROJETO SÓCRATES',
'PROJETO MONOPOLY',
'PROJETO PIPA',
'PROJETO ENDURO',
'PROJETO SENNA',
'METLIFE - LEI DO BEM 2017 E 2018',
'ICATU - AUDITORIA INTERNA',
'RENNER - REFAZ RS',
'CONSULTORIA TAX',
'METLIFE - LEI DO BEM 19-20',
'TAX CONSULTING SERVICES',
'REINTEGRA ZFM',
'RECUPERAÇÃO JUDICIAL PRINTBILIND. GRÁFICA',
'CALF - APOIO RJ',
'AÇÃO JUDICIAL CSL FONTE 2008 E 2009',
'SALDO NEGATIVO IRPJ 2009',
'AUTO DE INFRAÇÃO - INSS',
'ASSESSORIA CONTRATUAL E SOCIETÁRIA',
'AUTO DE INFRAÇÃO - INCORPORACAO ECOPOLO',
'COBRANÇA - PAJUVI',
'IMPUG AUTOS INFRAÇÃO - EXP SERV - ABRIL 2010 A JAN 2012',
'COMPENSAÇÃO DE OFICIO II',
'EXCEÇÕES PRE-EXECUTIVIDADE - EXEC FISCAIS ISS-SP 2010 A 2012',
'CRÉDITOS ICMS - DIESEL',
'COBRANÇA - GRUPO EDSON QUEIROZ',
'EXECUÇÕES FISCAIS - PWC ASS EM PROCESSOS E NEGÓCIOS',
'ICMS NA BASE DE CÁLCULO DO PIS E COFINS',
'ENTCORP UK LTD.',
'AÇÃO DE COBRANÇA - BOVIEL KYOWA X CCO',
'MANDADO DE SEGURANÇA',
'ASSESSORIA PERMANENTE',
'EMBARGOS DE TERCEIROS',
'PROJECT CARLTON - ASSESSORIA SOCIETÁRIA',
'AVISO PRÉVIO INDENIZADO',
'CONTENCIOSO TRIBUTÁRIO',
'CAUTELAR - DOLLOND - BANCO PAULISTA',
'IMPUGNAÇÕES A AUTO DE INFRAÇÃO',
'MANIFEST DE INCONFORMIDADE DESPACHO DECISÓRIO Nº 017674355',
'MANIFEST. DE INCONFORMIDADE -DESP. DECISÓRIO 019157274',
'EMPLOYEE RELATIONS PWC',
'AUTO DE INFRACAO 4.024.150-6 MULTA INIDONEA COMBRAZEM',
'ASSESSORIA IMIGRATÓRIA PERMANENTE - JAGUAR LAND ROVER',
'ASSESSORIA JURÍDICA - LGPD - WINE',
'TRIBUTAÇÃO SELIC - INDÉBITO TRIBUTÁRIO',
'EXCLUSÃO DO PIS E COFINS DAS PRÓPRIAS BASES DE CÁLCULO',
'AVANOS - CORPORATE SECRETARIAL SERVICES',
'ASPECTOS LEGAIS E REGULATÓRIOS - GUNDERSON',
'DELTA - ELTEK AND DELTA BRASIL CORPORATE ASSISTANCE',
'BP BUNGE - ASSESSORIA PERMANENTE',
'AÇÃO JUDICIAL SISTEMA S',
'PROJETO TOKYO - ASSESSORIA LEGAL',
'WEENER - POAS',
'SIMPRESS COMERCIO LOCACAO E SERVICOS LTDA.',
'LONZA AMERICA, INC',
'PROJETO FONTE - AUTOS DE INFRAÇÃO - SÓCIOS',
'HONDA - LGPD CONNECTED PROJECT',
'IHI BACEN ASSISTANCE',
'MANDADO DE SEGURANÇA - SESI, SENAI, SESC, OUTROS',
'MS - EXCL. DO ICMS DA BASE DE CÁLC. DO PIS/COFINS',
'AÇÃO REPETIÇÃO DO INDÉBITO SESC E SENAC',
'STARBOARD ATUALIZAÇÃO',
'SAINT-GOBAIN - PROJETO CEBRACE',
'IBM - ROYALTIES WHT MEMO 2023',
'UBER - BR WHT ANALYSIS',
'CURIMBABA - CONSULTORIA TRIBUTÁRIA',
'PROJECT PLASTIC',
'Projeto Spring',
'COMPLIANCE  TP',
'MOHAWK - PILLAR 2 BR ASSISTANCE',
'CP KELCO TP E ECF 2023',
'PROJECT ATLANTIC',
'BYTEDANCE 2023',
'PLEITO SUDAM',
'REVISÃO DE ECF 2023_2022',
'MICHELIN - APOIO AUTUAÇÃO',
'PROJETO DUBAI - ATUALIZACAO',
'MEGLOBAL_TRC_TAX_FY23',
'PROJETO ATLAS (SEB)',
'CLEARSALE - DIAGNÓSTICO DA ESTRUTURA INTERNACIONAL',
'PROJETO EVEREST',
'PROJECT DINO',
'Monitoramento Contínuo CBO',
'Controles internos de Compliance',
'GMB - AUDITORIA DE GAP 2023',
'PROJETO DOIS CÓRREGOS',
'Preenchimento ECF 2022',
'PROJECT ATENA',
'Projeto Mosqueteiros Fase 1',
'Project Unicorn',
'FY24 - FITESA NT - CONSULTORIA PERMANENTE',
'CERNER- REVISÃO BASE E ECF AC 2022',
'REVISÃO GOVERNANÇA 2023',
'Projeto River',
'Projeto Rare',
'PROJETO ROBSON',
'PROJECT HOCKEY.',
'Projeto Axé',
'Project Rocket',
'Consultoria Tributária 2023',
'AFTON - REVISÃO ECF AC 2022',
'FEDEX   TP OCDE',
'SIERENTZ - TP E APOIO EXPORTAÇÃO',
'FedEx   Scenario B FY23',
'Valeo TP 2011 - Apoio ao Assistente de perícia Ju',
'ANFAVEA DEZ/2022 AUDIT',
'CORURIPE COMPLIANCE 2022',
'HYDRO - TP CY 2018, 2019 E 2020',
'BLUE HEALTH 2022',
'Monitoramento Contínuo Frooty',
'Adicional do LEX',
'REESTRUTURAÇÃO SOCIETÁRIA - NEOENERGIA - PROJETO UNIQUE',
'COMPLIANCE 22.23',
'EPIC GAMES - ITS BR 2022',
'Palmyra - Siscomex 2022',
'TITANX   PROJECT BRAZIL',
'AVL SOUTH AMERICA LTDA DEZ/202',
'E-CREDAC CUSTEIO',
'Project Helius',
'ORGUEL REVISÃO DIFERIDO ÚLTIMOS 5 ANOS',
'TORRA TORRA FASE 2',
'PROJETO JOULE',
'PROJETO EMS',
'ORIGEM- REVISÃO IRPJ/CSLL E ECF',
'RECUPERAÇÃO TAXA SISCOMEX 2023',
'ORIGEM- REVISÃO TRIMESTRAL IRPJ/CSLL 2023',
'LIBBS CONSULTORIA FISCAL 2023',
'META - TAX BR CONSULTING',
'BEMOL 2023 - AC 2022',
'Project Vessel BR',
'DISNEY - FTC/ITS BR',
'INDRA   CY 2022 TP COMPLIANCE',
'PROJETO DIVERSEY TP 2020/2021',
'ICATU IFRS17',
'ANÁLISE PIS E COFINS',
'PALMYRA - EXTRAÇÃO SISCOMEX 2020',
'FY21 - PWC GERMANY FLIXBUS - BUSINESS MODEL',
'BHP - CONSULTORIA PERMANENTE',
'FY22 - PWC ALEMANHA FLIXBUS',
'PROSPECÇÃO DE LAUDO IPI - UL',
'PREPARO DE CÁLCULO TP - THERMO FISHER AC 2020',
'TP ASSESSMENT & REVIEW   HENGST BRASIL   FY 2020',
'MINERAÇÃO CARAÍBA - JSCP',
'GRID SOLUTIONS',
'PWC CHINA  CNOOC',
'PREÇOS DE TRANSFERÊNCIA',
'REINTEGRA AND REINTEGRA ADDITIONAL TAX RESIDUE',
'LAUDO DE CONSTATAÇÃO',
'ASA RENT A CAR - PLANEJAMENTOTRIBUTÁRIO',
'PWC US - OSISOFT   AVEVA   PWC US   CAPITAL GAIN ANALYSIS',
'TP REVIEW   CAP',
'FLEXNGATE - DIAGNÓSTICO CONTÁBIL E FISCAL - INDENIZAÇÃO',
'TAX 2021',
'FY22 - PWC HOLANDA TUPY',
'CORURIPE ICMS BC PIS COFINS',
'FY22- PWC SPAIN LABORATORIOS LESVI',
'RENOVAÇÃO CYTIVA_2022',
'PWC CHINA CNIC - BRAZILIAN TAX ADVICE',
'MSJ   ICMS nas bases do PIS e da COFINS',
'F. BRADESCO - GOVERNANÇA E CONTROLES',
'CARTA CONSULTA - ERP PARA CUSTO - TF',
'CUSTOMS SUPPORT - FY23 BR',
'MONITORAMENTO CONTÍNUO - ENTREVIAS',
'COMPLIANCE 2023',
'UMICORE 2023 ECF E TP',
'RETIFICAÇÃO E PREENCHIMENTO ECD E ECF 2021 E 2022',
'PERMIAN BRAZIL - PWC UK',
'TP Compliance AC 2021   Eventbrite Brazil',
'MSA   PREÇOS DE TRANSFERÊNCIA 2021',
'Goemil TAX Revisão obrigaçõesacessórias 2021',
'Zilor projetos expansão',
'VW - MATERIAIS INTERMEDIÁRIOS E DIFAL',
'ANÁLISE NCM',
'GUARANÁ',
'MIGNON',
'PROJETO TUNA',
'PROJETO SANTA MARIA 2013 - APOIO CF',
'APOIO HOPI HARI 2013',
'SEAC - REESTRUTURAÇÃO',
'ASSESSORIA SEAC',
'PROJECT ICHIBAN- VALUATION',
'JOB DE APOIO A AUDITORIA',
'PROJETO ASTECA 2',
'PROJECT GOLD',
'PROJETO JUPITER',
'PROJECT SALTA',
'PROJECT ART',
'PROJECT PARK',
'PROJETO EUROPA - VIENNA',
'PROJETO CANELA',
'PROJETO SALAR',
'PROJETO STARSHIP',
'PROJETO KAIMARA',
'PROJETO GRANFLOR',
'PROJETO SUNSHINE',
'PROJETO TERRA BOA',
'PROJETO PELE',
'PROJETO JARDIM',
'PROJETO GRAMADO',
'POWER OF DATA',
'PROJECT AUTOMATUS',
'PROJETO VERTEX',
'AÇÃO DE COBRANÇA SENAI - PRINCIPAL',
'INQUÉRITO CIVIL',
'CLOUDHQ - DIRECTORS GUIDELINES',
'ANALYSIS ON RESTRUCTURING - ERAMET',
'ASSESSORIA LGPD - EDITORA PLANETA',
'NOVUS - TP CY 2022',
'BOEING',
'CMAAS',
'BOMBONERA',
'HBL CONSULTORIA - SPF',
'TP 2015',
'ATUALIZAÇÃO DO BIA',
'CLIMATE RISK ASSESSMENT TOOL FOR FINANCIAL INSTITUTIONS',
'WEATHERFORD - ASSESSORIA TRIBUTÁRIA',
'SUBSEA',
'BODYCOTE BRASIMET',
'CONSULTORIA EM GESTAO DE CRISES & CONTINUIDADE DE NEGÓCIOS',
'ULYSSES',
'VER O PESO',
'COPERSUCAR RAO',
'CONSULTA DECOLAR PWC US',
'FY18-STAFF LOAN',
'SERVITECH 2018',
'CENTRAL IT 2018',
'CMOC_VENDA DE CRÉDITOS DE ICMS',
'DIAGNOSTICO IFRS 9 E 16',
'MACHU PICCHU',
'PROJETO NAVIO',
'DIPJ 2013',
'PROJETO PICUÍ',
'DIPJ2013/CONSULTORIA PERMANENTE/FIN48',
'MANULI - MAXIMIZAÇÃO REINTEGRA',
'WPR SAO LUIS GESTAO DE PORTOSE TERMINAIS AUD 2019',
'FY 19 - PWC US - LIME - INTL TAX CONSULTING - BUSINESS MODEL',
'JTEKT - DIAGNOSTICO ROTA 2030',
'TAX - LABOR, SOCIAL SECURITY AND HR CONSULTING SERVICES',
'PWC ALEMANHA - MELITTA GROUP MANAGEMENT GMBH & CO. KG',
'FY20 - PWC US/DOLBY -ALIGNMENT',
'VOPAK BRASIL S.A.',
'NISSAN DO BRASIL_PIS E COFINS',
'AFP 2020',
'ECF E TP - SEOYON_2019_2020',
'SUPORTE À MIGRAÇÃO PARA AGROINDÚSTRIA',
'FY21 - PWC US - BRIDGESTONE -STRUCTURING',
'ATC   PROJECT PROSPER',
'DAS - ECF 2020 + OPORTUNIDADES',
'INDUSTRIAS ROSSI 2021',
'FY21 PWC US EASTMAN ITS',
'CIMENTO ITAMBÉ - REVISÃO RISCOS E CONTROLES 2021',
'AUDITORIA INTERNA 2021',
'ALUPAR - AUDITORIA INTERNA 2021',
'MECAPLAST DO BRASIL, IND, COMERCIO, IMP. E EXPORTAÇÃO 2013',
'MALLINCKRODT DO BRASIL LTDA.',
'REMESSAS PARA O EXTERIOR',
'OPORTUNIDADES ADVISORY',
'AB ENERGY DO BRASIL LTDA - SPF',
'HELLMANN - CERTIFICADO DE RESIDÊNCIA',
'BERGAMO DIAGNOSTICO',
'REVISÃO FISCAL 2020',
'EXCLUSÃO ICMS BC PIS COFINS - FY 2021',
'PROJETO MEMORANDO DE REESTRUTURAÇÃO DE OPERAÇÃO',
'LINX S.A. - SOX INTERNAL CONTROLS',
'CMAAS ACCOUNTING ADVISORY',
'FY21 - CITROSUCO - REESTRUTURAÇÃO',
'REVISÃO DO CÁLCULO DO ICMS NA BASE DO PIS/COFINS',
'PAYSAFE GROUP - GLOBAL TAX HEALTH CHECK - BRAZIL',
'EXCLUSÃO DO ICMS DA BC DO PIS E COFINS',
'REVISÃO LUCRO DA EXPLORAÇÃO - ADICIONAL',
'VALORES ADUANEIROS',
'BLASER   PREPARO TP 2021',
'FY22 - PWC ESPANHA FINI - ITS',
'PWC ITÁLIA - CONSULTORIA ENEL',
'MOFFAT & NICHOL - SPF',
'TAX PACKAGE - REVIEW OF YEAR-END TAX PACKAGE',
'PROJECT DURAN CLOSING',
'HSI - AUXILIO FATCA',
'PROJETO HISTORY',
'RESTAURANT BRANDS INTERNATIONAL (RBI)',
'INVIVO NUTRIÇÃO E SAUDE ANIMAL LTDA',
'GRUPO ELFA - GB MEDCOM (PART.1)',
'GOEMIL TAX',
'RD - AUDITORIA INTERNA 2021',
'AVALIAÇÃO DO DEEMED COST',
'RENEWABLES P&W - POS SCH',
'ALSTOM TERMICA',
'GE CELMA',
'CAT 17',
'NATULAB AUDITORIA INTERNA 2021',
'EXPENSE REPORT REVIEW',
'LINKEDIN (ESPELHO 08002080/0001)',
'HOTELBEDS',
'UNILEVER - LAUDO DE CONSTATAÇÃO',
'EMERSON PROCESS',
'[S&] SERASA - ASSESSMENT ID&FRAUD MARKET',
'BUNGE PLANT-PROTEIN LATAM',
'VFS REVISÕES TRIBUTÁRIAS 2021',
'RHODIA - OTIMIZAÇÃO TRIBUTÁRIA',
'AMEROPA AG',
'DIFERIDO 2017 A 2021',
'PARECER TÉCNICO - LC192/22 - CIAPETRO',
'LEVAPAN ACQUISITION - LESAFFRE',
'PWC NORUEGA - CONSULTA PROSAFE',
'PWC UK PROJECT FLORA',
'Pro Forma Atacadão S.A.',
'AES Brasil   Recuperação incentivo Sudene - MS',
'UPL - Lei do Bem 2021',
'White Paper Consolidção',
'FY22 - PWC US DREXEL UNIVERSITY',
'PWC MALASIA AET SHUTTLE TANKERS SDN BHD',
'PWC DK (NOVO NORDISK TPR AUDIT)',
'Consultoria IAS 21 - Política Contábil e Análise',
'STAFF LOAN',
'Davita 2022/2023 - PPA adquiridas',
'GRUPO ELFA - COMPLIANCE',
'SUZANO - REVISÃO DE ALTERNATIVAS - TP E DIRETRIZES OCDE',
'GRUPO BAKER_ECF E REV. IR/CS',
'Prática - Valuation e Análise IPO',
'Ivoclar - TP 2022',
'Projeto Kappa - ITDD',
'Banese',
'PWC CH DATWYLER',
'Preenchimento ECD Evento Especial',
'Darling - Consulting - Loan/Interest Analysis (Br',
'MYLAN TAX 2023',
'NORS - TP',
'PROMEDON   PREÇOS DE TRANSFERÊNCIA',
'Valuation Metalkraft 2023',
'ULTRAGENYX   TP 2022',
'PPA UHE Mascarenhas',
'Canva - ITS Consulting- V2',
' LVMH - TP Documentation (Brazil)',
'PALANTIR   TP 2022',
'Micro Focus - TP 2022 (Brazil)',
'CYTIVA_RENOVAÇÃO 2023',
'AVALIAÇÃO DAS OPORTUNIDADES DE SINERGIA E MODELO DE ALOCAÇÃO',
'DIACO & METALDOM - MARKET ASSESSMENT',
'ASSAI - DISCUSSAO ESTRATEGICA CA',
'Softys   TP 2022',
'CbCR notification 2022 (Brazil)',
'CPFL - Benchmarking de Capital Humano 2023',
'PPA MQ Solutions',
'BENCHMARK - CORPORATE ASSISTANCE',
'EXCLUSÃO DO ICMS NA BC DO PIS E COFINS',
'SMR AUDITORIA INTERNA 2021',
'IMPACTOS TRIBUTÁRIOS PARA CONSTRUÇÃO DE NOVA SEDE',
'MILLENIUM_PE_PWC US',
'CONSULTA - JCP',
'FY22 - SANTA CRUZ',
'GAVILON CONSULTA HEDGE',
'WOLPAC 2021',
'VOLVO - TP',
'PWC US BRIDGESTONE - ADDITIONAL HOURS',
'PWC SUÉCIA - EPIROC SWEDEN',
'LUMEN III - FR ENEVA 3T21',
'COLGATE - REVISÃO SELIC - IRPJ/CSLL',
'ASHCROFT IA 2021',
'FY22 - PWC ALEMANHA ADIDAS AG',
'FY22 - PWC US COLFAX CORPORATION',
'ITAÚ - ASSEGURAÇÃO INR 2020',
'BOTICARIO - ITS - AVALIAÇÃO US E ÁSIA',
'FAZENDA SANTA FÉ 2021 AUDIT',
'FY22 - PWC DINAMARCA NOVOZYMES',
'PROJETO CUSTOMS CONSULTANCY',
'ATENTO - REVISÃO 20-F',
'DIAGNÓSTICO METODOLOGIA E CONCEITO CALCULO IFRS16',
'FY22 - PWC US CINEMARK',
'PROJETO DE ASSESSORIA NO PROCESSO DE TRANSPORTATION',
'GOVERNANÇA DE TI - COBIT 5',
'CAF CYBER',
'DOW - MAPEAMENTO DE PROCESSOS',
'ARGO INTERNATIONAL - BRAZIL TAX ASSISTANCE',
'WINDACRE PARTNERSHIP - PETROBRAS - ADR',
'SECURITY OPERATIONS CENTER',
'BRAZIL DATA LAKE TECHNOLOGY PROJECT',
'GREEN DARNER',
'SERVICO DE DETECCAO E RESPOSTA ESTRUTURADA A INCIDENTES DE C',
'FRTB - IMPLEMENTAÇÃO',
'GOVERNANÇA DE TI E DIMENSIONAMENTO DE EQUIPE',
'IMPLANTAÇÃO DE SOLUÇÃO DE AUTOMAÇÃO DE TESTES IQA',
'COLGATE PALM COMERCIAL 2010',
'PRYSMIAN ENERGIA CABOS E SIS.DO BRASIL S.A. 2014',
'MORLAN 2014',
'CIA DO TERNO   AUDITORIA 2014',
'MASTERFOODS',
'BRASKEM 2014 - AUDITORIA',
'AUDITORIA DAS DFS GRUPO BANIF 2014',
'TUPY - ACCOUNTING ADVISORY - PROJETO OCHOA',
'PROGRAMA ARRANJO ALELO GRC',
'Programa de Cyber OT',
'TESTE',
'DIAGNÓSTICO DE SOD',
'Comgás   Avaliação de controles de TI',
'APACHE',
'EXTENSÃO MONITORAÇÃO CORTEX - NDI',
'ELETROPAR - AUDITORIA 2010',
'OPTOTAL HOYA',
'AUDITORIA 2010 - AF',
'VALE FERTILIZANTES 2011',
'REDTREE PARTICIPAÇÕES S.A.',
'BORLAND LATIN AMERICA LTDA. 2011',
'SITEL DO BRASIL LTDA. 2011',
--'EXAME DAS DF'S - OFFICE NET DO BRASIL S.A',
'INTERCÂMBIO - DESPESAS',
'ASSURANT SEGURADORA',
'COMGÁS AUDITORIA IFRS 2006',
'CPM',
'LABORATÓRIO AMERICANO DE FARMACOTERAPIA S.A. 2008',
'ATLÂNTICA EXPORTAÇÃO E IMPORTAÇÃO LTDA.',
'INSTITUTO SOU DA PAZ 2018',
'JCPM 2018',
'CAFÉ DO BRASIL 2018',
'IBIRITERMO 2018',
'B&C SPEAKERS 2018',
'FABIO DORIA',
'REVISÃO PROVISÃO FAP',
'KORN FERRY BRASIL',
'TETRA',
'99 TECNOLOGIA',
'SICOOB AUDITORIA',
'OA   PROJETO OCEAN',
'FARNELL NEWARK BRASIL DIST. DEPROD. ELETRÔNICOS',
'ANION ASSURANCE 2014',
'ADISSEO BRASIL NUTRIÇÃO ANIMAL LTDA. 2015',
'ITAU 2015-DEMONSTR FINANCEIRAS EXERCICIO',
'PROSPERITAS INVESTIMENTOS S.A.2015',
'SOC. DE ENSINO SUPERIOR ESTÁCIO DE SÁ',
'AUDITORIA MONTESANTO   ATLANTICA IMPORTAÇÃO E EXPORTAÇÃO',
'AUDITORIA MONTESANTO   MONTESANTO LOGÍSTICA',
'ASK   PROCEDIMENTOS PRÉ-ACORDADOS',
'SOBRAL INVICTA 2012',
'ACCIONA INFRAESTRUCTURAS S.A.2013',
'OJI PAPEIS ESPECIAIS LTDA 2013',
'ALUMINA LIMITED DO BRASIL S.A2015',
'IAPP - 2015',
'2015_PROCEDIMENTOS PREVIAMENTE ACORDADOS (PPA)',
'SAMSUNG SDS LATIN AMERICA SOLUÇÕES EM TEC. LTDA. 2015',
'INGERSOLL RAND DO BRASILLTDA. 2015',
'TIM 2015',
'POLO PRECATÓRIO FIDC NP - AUDITORIA 2015',
'PSS - SEGURIDADE SOCIAL 2019',
'ENDRESS AUTOMAÇÃO 2018',
'ENDRESS AUTOMAÇÃO 2019',
'CONCESSIONÁRIA RIO TERESÓPOLIS - CRT 2019',
'PIRAQUE 2019',
'FUNDOS BB GESTÃO DE RECURSOS DTVM  2021',
'SANTA CLARA AGROCIENCIA INDUSTRIAL LTDA. 2020/2021',
'CONCESSIONÁRIA AEROPORTO RIO DE JANEIRO 2020',
'ASSOCIAÇÃO PASSOS MÁGICOS  2018',
'PSS - SEGURIDADE SOCIAL 2018',
'BB PREVIDÊNCIA 2018',
'COMPANHIA GERAÇÃO DE ENERGIA PILÃO 2018',
'NACIONAL CLUBE 2018',
'FUNDOS CREDIT AGRICOLE 2018',
'SINDITÊXTIL - AUDITORIA 2014',
'GRENDENE 2015',
'KODAK - AUDITORIA 2015',
'BRHC - AUDITORIA 2015',
'FARMOQUÍMICA 2015',
'LABORATÓRIO PADRÃO S.A. 2015',
'RHI 2018',
'ITAIPU BINACIONAL 2018',
'INSTITUTO AKATU 2018',
'TOSHIBA 2018',
'MAXIMIDIA 2018',
'CLUBE MAXIVIDA 2018',
'CROWN 2018',
'RESERVA PATAMARES II EMPREENDIMENTOS IMOBILIÁRIO S.A',
'KALUNGA COM. E IND. GRAFICATESTE',
'CONGREGAÇÃO SANTA CRUZ 2016',
'FARNELL NEWARK BRASIL DIST. DEPROD. ELETRÔNICOS 2016',
'ITAU 2018',
'CAIXA SEGURIDADE 2018',
'LIBRA HOLDING S.A. 2018',
'DYNAMO ADMINISTRAÇÃO DE RECURSOS - 2018',
'WHITE MARTINS PECEM GASES 2018',
'MONASHEES 2018',
'SANRIO DO BRASIL COM. E REPRES LTDA.  2019',
'OPP GRMS',
'NOVO NORDISK 2013',
'DESPESAS',
'PROJETO SIERRA UPDATE',
'ABRIL S.A 2013',
'SUPORTE AO ESCRITÓRIO DA PWC DE LONDRES - ARCELORMITTAL - 20',
'BANCO MODAL 2021',
'DART - TUPPERWARE 2021',
'PRUDENTIAL DO BRASIL SEGUROS 2',
'B.BRAUN 2021',
'ASPEN PHARMA  2021',
'VALE 2021',
'AMAZON EMPLOYMENT TAXES',
'CDB AVIATION',
'ELECTRONIC ARTS',
'JCN - JOSE IZIDORO',
'ORICA',
'SKY - CYBERSECURITY SOC - PARTE 1 - 2023-2024',
'Ultra   Avaliação de Controles de Seg. ERP',
'PROJETO APRESENTAÇÃO INSTITUCIONAL DA TI',
'MATRIZ SOD CVC CORP',
'EMBRACO INDU DE COMPRESSORES E',
'EMBRAER 2021',
'EXXONMOBIL BUSINESS SUPP. CENT',
'NORDEX ENERGY BRASIL 2021',
'IFF ESSENCIAS E FRAGRANCIAS LTDA 2021',
'OUTBACK STEACKHOUSE REST.BRASI',
'GEFRAN 2021',
'FUND. ABRINQ PELOS DIREITOS DA',
'IOB 2008',
'ELEVADORES OTIS LTDA.',
'MUELLER PARTICIPACOES 2021',
'SERRA VERDE PESQUISA E MINERAC',
'USAÇUCAR 2022',
'USINA SÃO JOSÉ -  2021',
'VIVENSIS 2021',
'CAFÉ BRASIL 12/2021 AUDIT',
'FQM AUDIT 2021',
'SCHWING 2016',
'VITACON 2016',
'UNIVERSO ONLINE S.A 2016',
'IAPP 2016',
'FUNDOS ADMINISTRADOS PELA GRADUAL CCTVM 2016',
'ALUMINA LIMITED DO BRASIL S.A2016',
'ITAU 2016-DEMONSTR FINANCEIRAS EXERCICIO',
'BANK OF AMERICA MERRIL LYNCH 2',
'UNICHARM  2021',
'EULER HERMES  2021',
'XP INVESTIMENTOS 2021',
'DOMO VENTURES FUND - FIP 2021',
'COPAGAZ 2021',
'DIGITAL HOUSE 2021',
'BOM NEGOCIO ATIVIDADES DE INTE',
'BHG 2021',
'HDI SEGUROS S.A. 2021',
'HERCULES DO BRASIL PRODUTOSQUI',
'AUTOMETAL S.A. 2021',
'INTERTEK  2021',
'AVON COSMÉTICOS LTDA. 2021',
'MOTOR PRESS BRASIL EDITORA LTDA 2016',
'CONSELHO EXECUTIVO DAS NORMAS PADRÃO CENP 2016',
'GP IFRS/USGAAP 2016',
'GÁS BRASILIANO 2016',
'LIQUIGAS - SUPORTE RADA 2015',
'FRANGOS PIONEIRO 2021',
'FUNDAÇÃO RENOVA 2021',
'GCB 2021',
'GENESISPAR 2021',
'GFP AUDI 2021',
'GL EMPREENDIMENTOS LTDA 2021',
'DANAPREV 2021',
'HSBC BI E HOLDING 2021',
'AGROCREDI 2021',
'APM TERMINALS ITAJAI  2021',
'COMPANHIA INDUSTRIAL DE CIMENTO APODI 2021',
'GRUPO ARAUCO 2021',
'VERISURE BRASIL MONIT. DE ALAR',
'DUPONT DO BRASIL S/A. 2021',
'NOVA ENERGIA 2021',
'PREVICAT SOC PREVIDENCIÁRIA 20',
'BASF SOCIEDADE DE PREVIDENCIAP',
'DHL EXPRESS (BRAZIL) LTDA. 2021',
'GL INDÚSTRIA 2021',
'GRÃO DE OURO  2021',
'GRUPO AMO 2021 AUDIT',
'VIA SUL VEICULOS S.A. 2021',
'HOTMART 2021',
'BANCO SANTANDER 2021',
'BANCO J.P. MORGAN 2021',
'TRAVEL ACE 2021',
'OMNILIFE BRASIL COMERCIO DE PRLTDA 2021',
'BEVAP 2022',
'HOSPITAL MATER DEI S.A.2021',
'ALLTECH DO BRASIL AGROINDUSTRI',
'CBMM SEGURIDADE 2019',
'TOKIO MARINE SEGURADORA S.A2019',
'BANCO TOYOTA 2019',
'FIBRIA CELULOSE S/A 2019',
'FUNDOS PEDRA AGROINDUSTRIAL 2019',
'REHAU INDÚSTRIA LTDA. 2019',
'SIMPAR 2021',
'FUNDOS HEDGE_2018',
'AUDITORIA CIPLAN E PLANALTO 2019',
'BMW 2019',
'VALE 2020',
'MCCAIN DO BRASIL ALIMENTOS LTDA. 2019',
'RECH AGRICOLA 2019',
'DARBY SERVTEC ENERGIA ESTRUTURA 2019',
'FBSS 2021',
'BTG PACTUAL G7 HOLDING 2021',
'CÂMARA DE COMERCIALIZAÇÃO DE ENERGIA ELÉTRICA - CCEE',
'FERRARI ZAGATTO - AUDITORIA 2021',
'BOA VISTA - REVISÃO 2021',
'TS AGRO EXAME 2021',
'BARTOFIL 2021',
'BIOMM 2021',
'BROCHMANN POLLIS 2021',
'CENECT - CENTRO INTEGRADO DE E',
'CGEP 2021',
'CONTAAZUL 2021',
'FTPI - EXAME 2021',
'REVISÃO CRÍTICA ESTUDO DE SUSTENTABILIDADE E ACV',
'BANCO DA CHINA - AUDITORIA 2021',
'ESTEE LAUDER JUNE 2021',
'EMBARÉ 2021',
'SGS BRASIL 2021',
'IAS 2021',
'KOERBER 2021',
'LACTOJARA  2021',
'MAXXIMA ENERGIA 2021',
'RAIA DROGASIL - SUPORTE RADA 2015',
'2016_PETROBRAS_DEMONSTRAÇÕES_FINANCEIRAS',
'RIO SOLIDÁRIO 2016',
'WHITE MARTINS GASES INDUSTRIAIS LTDA 2016',
'BETUNEL - AUDITORIA 2015',
'APOIO REVISÃO US GAAP',
'M. DIAS BRANCO 2017',
'COOP CENTRAL DE CRED RURAL COM1',
'CRISTAL PIGMENTOS DO BRASIL S.A. 2021',
'CUBICO 2021',
'CARBETO DE SILICIO SIKA BRASIL LTDA 2021',
'BCG 2019',
'STELLA IMPORTACAO E EXPORTACAO DE LUMINARIAS LTDA.2021',
'DRIL QUIP 2021',
'ARLANXEO BRASIL S.A. 2021',
'DYNAMO ADMINISTRAÇÃO 2021',
'HEINZ BRASIL S.A. 2019',
'GRUPO VOTORANTIM 2019',
'FLINTEC BRASIL 2019',
'ASSURANT SEGURADORA S.A 2019',
'RHI 2019',
'FLEXITECH 2019',
'ITAU 2019',
'FIIS E FIPS BTG 2021',
'CRÉDITO Y CAUCION SEGURADORA CRÉDITO E GARANTIAS 2021',
'BUNZL PLC 2021',
'KYOCERA DOCUMENT SOLUTIONS2021',
'BANCO INDUSVAL S.A. 2021',
'SONY BRASIL LTDA 2021',
'GYPSUM S.A. MINERACAO, INDUSTR',
'CARGOLIFT 2021',
'CODEMGE DEZ/2021 AUDIT',
'COMERCIAL DE SECOS E MOLHADOS',
'GAUSS 2021',
'LANDIS+GYR EQUIPAMENTOS DE MED',
'TSK DO BRASIL 2021',
'FUNDOS VISION BRAZIL INVESTMENTS - V9 FIDC NP 2019',
'BRL TRUST FUNDOS DE INVESTIMENTOS',
'BRITISH COLEGIO 2019',
'COLAB TECNOLOGIA E SERVIÇOS DE INTERNET 2018',
'CIRCUITO SP  2022',
'VOLKSWAGEN DO BRASIL IND. DE VEIC. AUTO LTDA 2017',
'WOW INDUSTRIA E COMERCIO LTDA2017',
'ASTIC TIC AUDITORIA 2016',
'PISANI PLÁSTICOS - EXAME 2017',
'VITACON 2017',
'UNIVERSO ONLINE S.A 2017',
'CDA 2017',
'AMBEV S.A 2022',
'ITAU 2022',
'BMG 2022',
'DLOCAL BRASIL 2021 AUDIT',
'CONDUCTOR 2022',
'DOCTORALIA BRASIL  2022',
'PHIBRO ANIMAL SAÚDE INTERNACIO 2022',
'TOYOTA BOSHOKU MAR 2023',
'UPSTREAM BRASIL PROMOCOES COMERCIAIS LTDA 2020',
'PROJETO WISER',
'CIPLAN E PLANALTO 2021',
'REFRESCOS BANDEIRANTES INDUSTRIA E COMERCIO LTDA 2021',
'AGRO GALAXY 21',
'GRUPO RBS 2021',
'DELL 2022',
'EBANX - AUDITORIA 2020 E 2019',
'WALTERSCHEID - EXAME 2020',
'TAM S.A - AUDITORIA 31/12/2021',
'VAN HESSEN - AUDIT 2021',
'SONY BRASIL 2021',
'PROFIGEN 2021',
'ANCAR IVANHOE SHOPPING CENTERS',
'CERÂMICA ELIZABETH LTDA 2021',
'PROGRESSRAIL LOCOMOTIVAS DO BR',
'E. M. COLLI EIRELI 2021',
'TOLEDO - AUDITORIA LI 2020',
'FLEURY S.A 2021',
'BOMBRIL S.A. 2021',
'NATURA COSMETICOS S.A 2021',
'NATURA &CO HOLDING S.A. 2021',
'NEXA RESOURCES S.A. 2021',
'ORISOL DO BRASIL INDUSTRIA 2019',
'PMU BRASIL 2019',
'PRO VEÍCULO - DRAGON',
'CAIXA ECONOMICA FEDERAL 2020',
'AGRO TRENDS PARTICIPAÇÕES S.A 2020',
'NEUGEBAUER 2020',
'UNIMED CAMPINAS 2020',
'ACUMENT 2019',
'I. SYSTEMS 2019',
'SAURER 2019',
'JUNIOR ACHIEVEMENT DO BRASIL2019',
'PETROGAL 2019',
'MAXIMIDIA 2019',
'CLUBE MAXIVIDA 2019',
'COMPANHIA MINERADORA DO PIROCLORO DE ARAXA COMIPA 2021',
'ASSOCIAÇÃO DAVID ROCKEFELLER HARVARD 2021 AUDIT',
'MINERAÇÃO APOENA DEZ/2021 AUDI',
'APS DEZ/2021 AUDIT',
'HEDGE FUNDOS  2021',
'CUMMINS BRASIL 2021',
'PARCEIROS VOLUNTÁRIOS 2021',
'LANGUIRU 2021',
'ARAUPEL 2021',
'CHINA BRASIL TABACOS (CBT) 202',
'MARELLI 2021',
'UNIFERTIL 2021',
'GENOA GLOBAL FUND SPC ALPHA AUDITORIA 2021',
'CONSTRUTORA BARBOSA MELLO S.A. - AUDITORIA 2021',
'[JOHN DEERE] PPA DO ROTA 2030 (2019 E 2020)',
'PRÉ-PROJETO CMAAS',
'7BRAV - 2021',
'VINCI GGN GESTAO DE RECURSOS',
'MINASA TRADING 2020',
'RT 001 EMPREENDIMENTOS E PARTICIPACOES LTDA.2018',
'SYMBIOSIS INVESTIMENTOS E PARTICIPAÇÕES LTDA. 2020',
'TAP MANUTENÇÃO E ENGENHARIABRA',
'VINCI PARTNERS 2020',
'4 BIO MEDICAMENTOS S.A. 2020',
'LA RONDINE 2019',
'CONFAB INDUSTRIAL SA 2022',
'CRISTAL PIGMENTOS DO BRASIL S.A. 2022',
'IAS 2022',
'JOHNSON & JOHNSON 2022',
'CABESP 2022',
'LABORATORIO DE PATOLOGIA CLINICA DR. FRANCESCHI LTDA 2022',
'CTEEP - 2022',
'SX NEGOCIOS 2022',
'PRODESENHO PARTICIPACOES SOCIETARIAS HUA LTDA 2020',
'TV CULTURA DEZ/2022',
'REHAU INDÚSTRIA LTDA. 2020',
'HEINZ BRASIL S.A. 2020',
'ALOG 02 SOLUÇÕES DE TECNOLOGIA2020',
'FLINTEC BRASIL 2020',
'NORDEX ENERGY BRASIL 2020',
'PAYU BRASIL INTERMEDIACAO DE NEGOCIOS LTDA 2021',
'ALFMA ALIMENTOS 2020',
'XP INVESTIMENTOS 2022',
'CONSORCIO DE ALUMINIO DO MARAN',
'RELOGIO ROLEX LTDA. 2021',
'VERDE ASSET 2021',
'BANCO FORD 2021',
'PAGSEGURO DIGITAL LTD 2021',
'QUIMISA S.A. 2021',
'CRUZEIRO DO SUL EDUCACIONAL S.A. 2021',
'RIO ENERGY PROJETOS DE ENERGIA',
'MOVILE INTERNATIONAL HOLDINGS B.V. 2022',
'BIONERGETICA AROEIRA LTDA. 2022',
'COMPANHIA BRASILEIRA DE TECNOL 2021',
'PROMETEON TYRE GROUP INDUSTRIA',
'SONAE SIERRA BRASIL 2021',
'PERSONAL CARE PARTICIPAÇÕES S.A. 2021',
'AMERICAN EXPRESS BRASIL ASSESSORIA EMPRESARIAL LTDA. 2021',
'CEF SUSTENTABILIDADE 2021',
'ASSEGURAÇÕES SUSTENTABILIDADE 2021',
'ZOBELE DO BRASIL 2022',
'S-8 VINCI PARTNERS INVESTMENT LTD. - ABRIL/22',
'LGT IMPACT INVESTMENT ASSESSORIA BRASIL 2021',
'HG EMPREENDIMENTOS EPARTICIPAÇ',
'BMG 2020',
'CIA DO TERNO 2020',
'DIREITO DE OUVIR  2020',
'FADEL TRANSPORTES E LOGISTICA',
'GL EMPREENDIMENTOS LTDA 2020',
'GRUPO BOM JESUS 2020',
'HAPVIDA 2022',
'BIOGEN 2021',
'SCALA DATACENTER DEZ/2022 AUDI',
'20-F 2021 MESA',
'ITAU 2020',
'JTEKT AUTOMOTIVA BRASIL LTDA.2',
'MONTANA 2020',
'OLIST 2020',
'SERRA VERDE PESQUISA E MINERACAO LTDA. 2020',
'GRUPO TENCO 2020',
'TERRA DOS VALES 2020',
'GL ELETRO 2021',
'ATMOSFERA 2017',
'INSTITUTO SOU DA PAZ 2017',
'MRS LOGÍSTICA_EXAME 2017',
'JOHNSON CONTROLS DO BRASIL AUTOMOTIVE LTDA 2017',
'ITAU 2017-DEMONSTR FINANCEIRAS EXERCICIO',
'ITAIPU - AUDITORIA 2017',
'TECHINT ENGENHARIA E CONSTRUÇÕES S.A. 2017',
'LEVANTINO FY17',
'GRAHAM PACKAGING 2017',
'CEG 2017',
'WHITE MARTINS GASES INDUSTRIAIS LTDA 2017',
'TRELLEBORG BRASIL 2017',
'PINESSO 2017',
'TODIMO MATERIAIS PARA CONSTRUÇÃO S.A 2017',
'FATURAMENTO DE DESPESAS - INTERCAMBIO',
'AG DE VAPORES GRIEG SA 2020',
'ANDEF 2020',
'SILTOTAL HOLDING S.A 2020',
'KUMON 2020',
'VINCI DISTR DE TITULOS E VALOR2020',
'KLL EQUIPAMENTOS PARA TRANSPOR',
'HMV  2021',
'KMW DO BRASIL 2021',
'GLOBAL DISTRIBUICAO DE BENS DE',
'IRMANDADE DA SANTA CASA DE MIS',
'HS FINANCEIRA S.A. CREDITO, FI',
'BORGWARNER 2021',
'FUNDOS MERCANTIL DO BRASIL CTVM 2021',
'MISSISSIPI PARTICIPAÇÕES 2021',
'MONDELEZ 2021',
'SVRE HOLDINGS - AUDITORIA 2020',
'NCR SÃO PAULO - AUDITORIA 2021',
'MAQUIRA - AUDITORIA 2021 - AUDIT',
'GENESYS 2021',
'FMS 2021',
'COMBIO ENERGIA 2021',
'GRUPO AMARANTES 2021',
'SX NEGOCIOS 2021',
'KERRY 2021',
'KSB 2021',
'SISTEMA SEBRAE 2021',
'CENTRAIS ELETRICAS BRASILEIRAS',
'YPIÓCA INDUSTRIAL E AGRÍCOLA A',
'PARATI INDUSTRIA E COMERCIO DE ALIMENTOS LTDA. 2022',
'CIA BRASILEIRA DE METALURGICAE MINERACAO 2022',
'INSTITUTO DIAGEO 2021',
'ALCON BRASIL CUIDADOS COM A SA',
'UNILEVERPREV 2022',
'BIOGEN 2022',
'CAR10 AUDITORIA 2021',
'BRW SUPRIMENTOS ESCOLARES DIAGNÓSTICO',
'ECORI ENERGIA SOLAR - AUDITORIA 2022',
'Copa Energia - Incorporação Liquigás 2022',
'CARITAS - AUDITORIA BID 2021',
'3M DEZ/2023 AUDIT',
'DOW AGROSCIENCES INDUSTRIAL LT',
'IQUINE 2022',
'AUXILIADORA PREDIAL LTDA 2022',
'MULTINER S.A. 2022',
'PRATT DEZ/2022 AUDIT',
'MADAL -  2022',
'RED HAT - 2022',
'NSAL - BDRS',
'ECORODOVIAS INFRAESTRUTURA E LOGISTICA S.A 2020',
'NAAE - DEZ/19 - GS',
'COMPANHIA DE DESENVOLVIMENTO DE MINAS GERAIS CODEMGE 2020',
'AERIS IND. E COM. DE EQUIP. PARA GERACAO DE ENERGIA S.A.2020',
'CIA BRASILEIRA DE METALURGICAE MINERACAO 2020',
'KORA DEZ/2023 AUDIT',
'CATHO ONLINE JUN/2023 PEDRO',
'DEXXOS PAR DEZ/2023 AUDIT',
'ITAIPU DEZ/2023 AUDIT',
'EXAME ANCORA 2023',
'NORSKAN OFFSHORE 2021',
'Cateno - AI Profit Sharing 2023',
'DIEBOLD - AUDITORIA LI 2022',
'CREDICITRUS 2022',
'GRUPO SANTA ISABEL - 2023',
'A. SCHULMAN BRASIL AUDITORIA - 2022',
'ANGLOGOLD ASHANTI - AUDITORIA2023',
'SABIC BRASIL - AUDITORIA 2022',
'TOTALENERGIES - AUDIT 2022',
'BANCO BV DEZ/2023 AUDIT',
'FISCHER DEZ/2023 AUDIT',
'CRESOL SC RS DEZ/2023 AUDIT',
'INFRAMERICA DEZ/2023 AUDIT',
'CIPLAN DEZ/2023 AUDIT',
'AGROGALAXY DEZ/2023 AUDIT',
'TERRA BRASIS RESSEGUROS S.A.',
'GRUPO SONORA 2017',
'PLAN AUDITORIA 2018',
'JALLES MACHADO S.A. 2018',
'NOVARTIS BIOCIÊNCIAS S.A. 2018',
'BANCO MODAL 2018',
'I. SYSTEMS 2018',
'BANCO FIDIS - AI 2022',
'BLACKHAWK - PAIVA',
'Stark Bank - AI 2023',
'DSI UNDERGROUND 2023',
'GEARBULK AUDIT DEZ/2023',
'WATERS TECHNOLOGIES DO BRASIL LTDA. 2022',
'WALTERSCHEID - EXAME 2021',
'FUNDAÇÃO LIBERTAS 2022',
'GIRA_REV JUNHO 2023 E EXAME DE AUDITORIA JUNHO 2023',
'SEMANTIX SPAC',
'NCR SÃO PAULO -  2022',
'ITER PARTICIPACOES 2022',
'GENESYS 2022',
'RENTCARS EIRELI - AUDIT 2021',
'CCEE - DIAGNÓSTICO AMBIENTE CONTROLES + QA',
'ACOMPANHAMENTO INVENTÁRIO BR - APOIO PWC PORTUGAL 2021',
'SANTO ANDRE PLANOS DE ASSISTENCIA MEDICA LTDA.',
'HMV  2022',
'MATA DE SANTA GENEBRA 2022',
'IFOOD.COM AGENCIA DE RESTAURANTES ONLINE S.A. 2021',
'FLEXTRONICS INTERNATIONAL TECNOLOGIA 2022 AUDIT NAAE',
'EDP RENOVÁVEIS BRASIL SA DEZ/2023 AUDIT',
'FIPS CRV DTVM 2018',
'MAN DIESEL 2018',
'COVESTRO 2018',
'WOW INDUSTRIA E COMERCIO LTDA2018',
'LUXOTTICA 2018',
'DORMA 2019 AUDIT',
'SAURER 2018',
'LE CORDON BLEU DEZ/2022 AUDIT',
'ANBIMA 2022',
'ANBIMA 2023',
'EMBARÃ¿ IND ALIMENTÃ¿CIAS DEZ/2023 AUDIT',
'LGD PACKEM INDUSTRIA E COMERCI',
'USIMECA IND MECANICA S.A DEZ/2023 AUDIT',
'FIPS ORIA DEZ/2023 AUDIT',
'TV CULTURA DEZ/2023 AUDIT',
'GCB HOLDINGS FAMILIARES DEZ/2023 AUDIT',
'GEOLAB DEZ/2023 AUDIT',
'MENDUBIM DEZ/2023 AUDIT',
'VIA - WHITEPAPER CONTÁBIL (ESPELHO 25048563)',
'AURA MINERALS - APOENA DEZ/2023 AUDIT',
'CICLUS REAUD DEZ/2023 AUDIT',
'FUNDAÇÃO FIBRA ITAIPU DEZ/2023 AUDIT',
'SIGURA WATERS IWC DEZ/2023 AUDIT',
'INTEGRADO DEZ/2023 AUDIT',
'WESTERN ASSET 2022',
'KYOCERA DOCUMENT SOLUTIONS 2022',
'ALOG 02 SOLUÇÕES DE TECNOLOGIA 2022',
'BANCO PINE 2022',
'PRIME SISTEMAS 2022',
'BANCO FORD 2022',
'NORDEX ENERGY BRASIL 2022',
'FUNDOS OFFSHORE XP ADVISORY 2021',
'BANCO SANTANDER 2023',
'EDP ENERGIA 2023',
'TELEFONICA SUBSIDIÁRIAS DEZ/2023 AUDIT',
'MONTES CLAROS - NOVO NORDISK PRODUÇÃO  2021',
'YESSINERGY DEZ/2023 AUDIT',
'AGRO EFFICIENCY DEZ/2023 AUDIT',
'TECHNIP DEZ/2023 AUDIT',
'CORSAN DEZ/2023 AUDIT',
'J. MACEDO S.A DEZ/2023 AUDIT',
'GRUPO CANTU STORE 2023',
'USINA ACUCAREIRA ESTER MAR/2024 AUDIT',
'THE WALT DISNEY COMPANY 2022',
'BRENNTAG DEZ/2023 AUDIT',
'TIMAC DEZ/2023 AUDIT',
'GETNET DEZ/2023 AUDIT',
'HMV DEZ/2023 AUDIT',
'KMW DO BRASIL DEZ/2023 AUDIT',
'SANTA CASA DEZ/2023 AUDIT',
'INOVAR PREVIDÊNCIA DEZ/2023 AUDIT',
'CANEX DEZ/2023 AUDIT',
'AMBEV DEZ/2023 AUDIT',
'VIVENSIS DEZ/2023 AUDIT',
'NATURA COSMÉTICOS DEZ/2023 AUDIT',
'NEXA RESOURCES DEZ/2023 AUDIT',
'REAG INVESTIMENTOS DEZ/2023 AUDIT',
'MAUA CAPITAL MAR/2023 AUDIT',
'BEMOBI DEZ/2023 AUDIT',
'FIBERCO DEZ/2023 AUDIT',
'PHIBRO SAÚDE ANIMAL SOCIETARIO 2022',
'DIRECIONAL DEZ/2023',
'NAAE CÓDIGO ANBIMA 2022',
'BAUMINAS DEZ/2023',
'CODEMGE DEZ/2023 AUDIT',
'VTEX - CIA DE TECNOLOGIA DEZ/2023 AUDIT',
'IHS DEZ/2023 AUDIT',
'BELLTECH DEZ/2023 AUDIT',
'BRILIA DEZ/2023 AUDIT',
'AUDITORIA VIDEOLAR-INNOVA 2023',
'ALLIANZ ADIANTAMENTO 2023',
'AEROPORTO RIO GALEÃO DEZ/2023 AUDIT',
'FUNDOS BB 555 DEZ/2023 AUDIT',
'ZAMP 2023',
'TAP MANUTENÇÃO E ENG. DEZ/2023 AUDIT',
'SONAE DEZ/2023 AUDIT',
'CRESCERA DEZ/2022 AUDIT',
'PROMONLOGICALIS FEV/2024 AUDIT',
'TELEFONICA BRASIL DEZ/2023 AUDIT',
'BRADESPAR DEZ/2023 AUDIT',
'MTU DO BRASIL DEZ/2023 AUDIT',
'DECOLAR DEZ/2023 AUDIT',
'FORM F-4 - VITRU',
'GLOVIS - AUDITORIA 2023',
'NOVA AGRI MAR/2024',
'SEL DEZ/2023',
'Asseguração Termo de Compromisso BCB 2023',
'MACQUARIE ENERGIA DEZ/2023',
'CRI 2º TRI 2023',
'VITAL BRAZIL DEZ/2023 AUDIT',
'GRENDENE S.A DEZ/2023 AUDIT',
'STATKRAFT DEZ/2023 AUDIT',
'REFINARIA RIO GRANDENSE DEZ/2023 AUDIT',
'SCALA DATACENTER DEZ/2023 AUDIT',
'RIZOBACTER JUN/2024 AUDIT',
'FQM DEZ/2023 AUDIT',
'ASA INDUSTRIA DEZ/2023 AUDIT',
'MACLEAN DEZ/2023 AUDIT',
'GYPSUM DEZ/2023 AUDIT CL',
'VENTANA DEZ/2023 AUDIT',
'AMCOR 2023',
'BANCO HSBC S.A. DEZ/2023 AUDIT',
'BANCO BS2 DEZ/2023 AUDIT',
'BARTOFIL DEZ/2023 AUDIT',
'BEM BRASIL DEZ/2023 AUDIT',
'BMG DEZ/2023 AUDIT',
'APS DEZ/2023 AUDIT',
'SEFAZ PI DEZ/2023 AUDIT',
'BMW DO BRASIL DEZ/2023 AUDIT',
'CENCOSUD DEZ/2023 AUDIT',
'COCAPEC DEZ/2023 AUDIT',
'COCRED DEZ/2023 AUDIT',
'CSD DEZ/2023 AUDIT',
'EXPORTADORA GUAXUPÉ DEZ/2023 AUDIT',
'GAZIN DEZ/2023 AUDIT',
'JOHNSON & JOHNSON DEZ/2023 AUDIT',
'MASCARELLO DEZ/2023 AUDIT',
'MONDELEZ DEZ/2023 AUDIT',
'RECH AGRICOLA DEZ/2023 AUDIT',
'SÃO MARTINHO MAR/2024 AUDIT',
'SYMPLA MAR/2024 AUDIT',
'HAPVIDA DEZ/2023 AUDIT',
'GRUPO SBF S.A DEZ/2023 AUDIT',
'CPFL DEZ/2023 AUDIT',
'COOP SING SICOOB GOIÁS DEZ/2023 AUDIT',
'VETBR DEZ/2023 AUDIT',
'VIDEPLAST DEZ/2023 AUDIT',
'BTG PACTUAL REINSURANCE DEZ/2022 AUDIT',
'CLÍNICA DA GÁVEA DEZ/2023 AUDIT',
'FJC DEZ/2023 AUDIT',
'RJR - DEZ/2023 AUDIT',
'MSD DEZ/2023 AUDIT',
'SACYR CONSTRUÇÕES DEZ/2023 AUDIT',
'CORURIPE MAR/2024 AUDIT',
'DISAM DISTRIBUIDORA DEZ/2023 AUDIT',
'AKER SOLUTIONS DEZ/2023 AUDIT',
'PEDREIRA DEZ/2023 AUDIT',
'FLORIPA SHOPPING DEZ/2023 AUDIT',
'WAYNE DEZ/2023 AUDIT',
'KERRY DEZ/2023 AUDIT',
'MINASA TRADING DEZ/2023 AUDIT',
'AVERY DENNISON DEZ/2023 AUDIT',
'FUCHS DEZ/2023 AUDIT',
'MAFP DEZ/2023 AUDIT',
'CEB DEZ/2023 AUDIT',
'WEBEDIA DEZ/2023 AUDIT',
'VALE DEZ/2023 AUDIT',
'AVON DEZ/2023 AUDIT',
'BANCO CCB DEZ/2023 AUDIT',
'CORTEVA AGRISCIENCE DEZ/2023 AUDIT',
'SUMUP DEZ/2023 AUDIT',
'MESA DEZ/2023 AUDIT',
'ALIGN TECHNOLOGY DEZ/2023 AUDIT',
'INSTITUTO CREDICITRUS DEZ/2023 AUDIT',
'REVISTA AMANHÃ DEZ/2023 AUDIT',
'LWART DEZ/2023 AUDIT',
'GEBSA-PREV DEZ/2023 AUDIT',
'VICUNHA DEZ/2023 AUDIT',
'WESTERN ASSET DEZ/2023 AUDIT',
'SANTA CRUZ DEZ/2023 AUDIT',
'BIOLAB FARMACEUTICA DEZ/2023 AUDIT',
'ANGLOGOLD - DEZ/2024 AUDIT',
'VIRTUE BRASIL DEZ/2023 AUDIT',
'SABIC BRASIL DEZ/2023 AUDIT',
'APEX CAPITAL DEZ/2022 AUDIT',
'SANTA PLURAL DEZ/2023 AUDIT',
'COLGATE PALMOLIVE DEZ/2023 AUDIT',
'PHIBRO SAÚDE ANIMAL JUN/2023 AUDIT',
'CISCO DO BRASIL DEZ/2023 AUDIT',
'NORDEX ENERGY BRASIL DEZ/2023 AUDIT',
'DRAGER INDUSTRIA DEZ/2023 AUDIT',
'GRUPO ALLIANZ SEG&SAÚDE DEZ/2023 AUDIT')
