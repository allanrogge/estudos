SELECT DISTINCT
    REPLACE(CONCAT(LTRIM(RTRIM(COD_Project)), '/', LTRIM(RTRIM(COD_JOB))), '"', '') AS PROJETO_ID,
    REPLACE(CONCAT(LTRIM(RTRIM(COD_Project)), '/', LTRIM(RTRIM(COD_JOB))), '"', '') AS PROJETO_FILHO_FORMATADO,
    COD_Project,
    COD_JOB,
    IIF(FLAG_Billable = 'N', 0, 1) AS YN_PROJ_COBRAVEL,
    UPPER(RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        DES_Project, 
        'Á', 'A'),
		'À', 'A'),
		'Â', 'A'),
		'Ã', 'A'),
		'Ä', 'A'),
        'É', 'E'),
		'Ê', 'E'),
		'È', 'E'),
		'Ë', 'E'),
        'Í', 'I'),
        'Ì', 'I'),
        'Ï', 'I'),
        'Ó', 'O'),
		'Ô', 'O'),
		'Õ', 'O'),
		'Ö', 'O'),
		'Ø', 'O'),
        'Ú', 'U'),
		'Ù', 'U'),
		'Ü', 'U'),
        'Ç', 'C'),
		'Ñ', 'N'),
		'DF`S', 'DF(S)'),
		'DF´S', 'DF(S)'),
		'DF''S', 'DF(S)'),
		'D.F''S', 'DF(S)'),
		'D/F', 'DF(S)'),
		'DFS', 'DF(S)'),
		'DFS''', 'DF(S)'),
		'D.F.''S', 'DF(S)'),
		'''S', '(S)'),
		' / ', ' - '),
		' | ', ' - '),
		'"', ''),
		CHAR(10), ''),
		CHAR(13), ''),
		'                             ', ' '),
		'                            ', ' '),
		'                           ', ' '),
		'                          ', ' '),
		'                         ', ' '),
		'                        ', ' '),
		'                       ', ' '),
		'                      ', ' '),
		'                     ', ' '),
		'                    ', ' '),
		'                   ', ' '),
		'                  ', ' '),
		'                 ', ' '),
		'                ', ' '),
		'               ', ' '),
		'              ', ' '),
		'             ', ' '),
		'            ', ' '),
		'           ', ' '),
		'          ', ' '),
		'         ', ' '),
		'        ', ' '),
		'       ', ' '),
		'      ', ' '),
		'     ', ' '),
		'    ', ' '),
		'   ', ' '),
		'  ', ' '),
		'	', '')
	))) AS NOME_PROJETO,
	IIF(ISNUMERIC(RIGHT(LTRIM(RTRIM(COD_JobManager)), 1)) = 0, LEFT(LTRIM(RTRIM(COD_JobManager)), LEN(LTRIM(RTRIM(COD_JobManager))) - 1), LTRIM(RTRIM(COD_JobManager))) AS COD_GERENTE_PEP,
    DES_JobManager AS GERENTE_PEP,
	IIF(ISNUMERIC(RIGHT(LTRIM(RTRIM(COD_JobOwner)), 1)) = 0, LEFT(LTRIM(RTRIM(COD_JobOwner)), LEN(LTRIM(RTRIM(COD_JobOwner))) - 1), LTRIM(RTRIM(COD_JobOwner))) AS COD_SOCIO_PEP,
    DES_JobOwner AS SOCIO_PEP,
	IIF(ISNUMERIC(RIGHT(LTRIM(RTRIM(COD_ProjectOwner)), 1)) = 0, LEFT(LTRIM(RTRIM(COD_ProjectOwner)), LEN(LTRIM(RTRIM(COD_ProjectOwner))) - 1), LTRIM(RTRIM(COD_ProjectOwner))) AS COD_DIRETOR_PEP,
    DES_ProjectOwner AS NOME_DIRETOR,
    RIGHT(COD_ProfitCenter, 8) AS CL_PROJ,
    REPLACE(CONCAT(LTRIM(RTRIM(COD_Project)), '/', LTRIM(RTRIM(COD_JOB))), '"', '') AS SQL_ID,
    DATE_ActualStart AS DT_ABERTURA,
    DATE_JobClosed AS DT_ENCERRAMENTO_TECNICO,
    EntityId,
	COD_Entity,
	DES_BusinessUnit,
	DES_BusinessUnitSolution,
	COD_ProjectManager,
	DES_ProjectManager,
	COD_JobSecondOwner,
	DES_JobSecondOwner,
	COD_ProjectType,
	COD_TypeJob,
	COD_JobType,
	DES_JobType,
	COD_Opportunity,
	COD_ProjectMainJob,
    UPPER(RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        COD_JobReference, 
        'Á', 'A'),
		'À', 'A'),
		'Â', 'A'),
		'Ã', 'A'),
		'Ä', 'A'),
        'É', 'E'),
		'Ê', 'E'),
		'È', 'E'),
		'Ë', 'E'),
        'Í', 'I'),
        'Ì', 'I'),
        'Ï', 'I'),
        'Ó', 'O'),
		'Ô', 'O'),
		'Õ', 'O'),
		'Ö', 'O'),
		'Ø', 'O'),
        'Ú', 'U'),
		'Ù', 'U'),
		'Ü', 'U'),
        'Ç', 'C'),
		'Ñ', 'N'),
		'DF`S', 'DF(S)'),
		'DF´S', 'DF(S)'),
		'DF''S', 'DF(S)'),
		'D.F''S', 'DF(S)'),
		'D/F', 'DF(S)'),
		'DFS', 'DF(S)'),
		'DFS''', 'DF(S)'),
		'D.F.''S', 'DF(S)'),
		'''S', '(S)'),
		' / ', ' - '),
		' | ', ' - '),
		'"', ''),
		CHAR(10), ''),
		CHAR(13), ''),
		'                             ', ' '),
		'                            ', ' '),
		'                           ', ' '),
		'                          ', ' '),
		'                         ', ' '),
		'                        ', ' '),
		'                       ', ' '),
		'                      ', ' '),
		'                     ', ' '),
		'                    ', ' '),
		'                   ', ' '),
		'                  ', ' '),
		'                 ', ' '),
		'                ', ' '),
		'               ', ' '),
		'              ', ' '),
		'             ', ' '),
		'            ', ' '),
		'           ', ' '),
		'          ', ' '),
		'         ', ' '),
		'        ', ' '),
		'       ', ' '),
		'      ', ' '),
		'     ', ' '),
		'    ', ' '),
		'   ', ' '),
		'  ', ' '),
		'	', '')
	))) AS COD_JobReference,
	FLAG_Cyber,
	FLAG_OverRun,
	FLAG_InternalBilling,
	FLAG_AcceptProposal,
	FLAG_AFS,
	FLAG_Status,
	FLAG_Recurrent,
	FLAG_CPI,
	FLAG_Secret,
	FLAG_SharedAccountingTax,
	FLAG_StatusCustomer,
	FLAG_PCS,
	FLAG_PriorityClient,
	FLAG_Inbound
FROM [BRdw].[Dim_ProjectJobFull]