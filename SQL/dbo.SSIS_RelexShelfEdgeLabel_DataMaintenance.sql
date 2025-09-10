USE [CK_Reporting]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ==============================================================
-- Author:		Enterprise_Build_Team - Eric Scott
-- Date:		2025-09-09
-- Description: Deletes all Shelf Edge Label records more than 7 days old
-- ==============================================================
CREATE PROCEDURE [dbo].[SSIS_RelexShelfEdgeLabel_DataMaintenance]
	@sourceFileName varchar(250),
	@sysInsertedDt varchar(50)
AS
BEGIN

	SET NOCOUNT OFF;

	DECLARE @trimDate DATE = DATEADD(d,-7,GETDATE());


	-- First we remove the source rows that are over 7 days old
	DELETE FROM dbo.relex_outbound_shelf_edge_labels
	where CONVERT(date,LEFT([sys_inserted_dt],10)) < @trimDate;

	-- Now we remove the log rows so we don't have log rows that reference nothing
	DELETE l
	FROM dbo.relex_outbound_shelf_edge_label_extract_log l
	WHERE NOT EXISTS
	(
		SELECT 1 FROM dbo.relex_outbound_shelf_edge_labels r 
		WHERE r.source_file_name = l.source_file_name 
		AND r.sys_inserted_dt = l.sys_inserted_dt
	)

END

GO


