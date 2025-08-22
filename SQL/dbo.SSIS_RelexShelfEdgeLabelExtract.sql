USE [CK_Reporting]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ==============================================================
-- Author:		Enterprise_Build_Team - Eric Scott
-- Date:		2025-08-20
-- Description: Extracts Relex Shelf Edge Label data in PDI SIIMPS format
-- ==============================================================
CREATE PROCEDURE [dbo].[SSIS_RelexShelfEdgeLabelExtract]
	@sourceFileName varchar(250),
	@sysInsertedDt varchar(50)
AS
BEGIN

	SET NOCOUNT OFF;

	DECLARE @livedate DATE = GETDATE();

	DECLARE @pogRecords TABLE 
						( ID INT IDENTITY, record_type char(3), planogram_name varchar(60), planogram_code varchar(50), 
						  location_code varchar(50), location_name varchar(50), live_date varchar(50), end_date varchar(50), 
						  product_code varchar(50), bay_sequence varchar(50), custom_bay_width varchar(50), 
						  component_sequence varchar(50), position_sequence varchar(50), units_wide varchar(50), 
						  units_high varchar(50), total_units varchar(50), custom_position_width varchar(50), 
						  code varchar(50), [name] varchar(50), custom_pdi_item_number varchar(50), ean varchar(50), 
						  implementation_feedback_status varchar(50), implementation_date varchar(50), 
						  implementation_count varchar(50), created_at varchar(50), updated_at varchar(50), 
						  assignment_last_modified_date varchar(50), component_name varchar(50), component_type varchar(50), 
						  component_width varchar(50), component_height varchar(50), component_depth varchar(50),
						  pck_qty varchar(10), Scan_Modifier varchar(20) 
						);
	DECLARE @pogaRecords TABLE 
						 ( ID INT IDENTITY, record_type char(4), planogram_name varchar(60), planogram_code char(1), 
						   location_code varchar(50), location_name varchar(50), live_date varchar(50) 
						 );
	DECLARE @output TABLE (ID INT IDENTITY, outputCSV varchar(max));

	INSERT INTO @output
	SELECT 'record_type,planogram_name,planogram_code,location_code,location_name,live_date,end_date,product_code,bay_sequence,custom_bay_width,component_sequence,position_sequence,units_wide,units_high,total_units,custom_position_width,code,name,custom_pdi_item_number,ean,implementation_feedback_status,implementation_date,implementation_count,created_at,updated_at,assignment_last_modified_date,component_name,component_type,component_width,component_height,component_depth,pck_qty,Scan_Modifier';

	INSERT INTO @pogRecords
	SELECT DISTINCT
		'POG', -- AS record_type,
		planogram_name,
		planogram_code,
		'', -- AS location_code,
		'', -- AS location_name,
		live_date, 
		end_date, 
		LEFT(product_code,11), -- AS product_code,
		bay_sequence, -- AS bay_sequence,
		custom_bay_width,
		component_sequence,
		position_sequence,
		units_wide,
		units_high,
		total_units,
		custom_position_width,
		code,
		[name],
		custom_pdi_item_number,
		ean,
		implementation_feedback_status,
		COALESCE(implementation_date,''), -- AS implementation_date,
		COALESCE(implementation_count,0), -- AS implementation_count,
		created_at,
		updated_at, -- AS updated_at,
		assignment_last_modified_date, -- AS ' ',
		component_name, -- AS component_name,
		component_type, -- AS component_type,
		component_width,
		component_height, -- AS component_height,
		component_depth, -- AS component_depth,
		pck_qty, -- AS pck_qty,
		Scan_Modifier--,
		--'' -- AS ' '
	FROM dbo.relex_outbound_shelf_edge_labels l
	WHERE l.source_file_name = @sourceFileName AND l.sys_inserted_dt = @sysInsertedDt
	AND live_date > @livedate
	ORDER BY
		live_date DESC,
		planogram_name,
		ean;

	-- Find our records that are not unique as far as PDI is concerned
	DECLARE @uniqueDuplicates TABLE (ID INT IDENTITY, planogram_name varchar(60), live_date varchar(50), product_code varchar(50), ean varchar(50), pck_qty varchar(50) );
	INSERT INTO @uniqueDuplicates
	SELECT planogram_name, live_date, product_code, ean, pck_qty
	FROM @pogRecords
	GROUP BY planogram_name, live_date, product_code, ean, pck_qty
	HAVING COUNT(*) > 1;

	DECLARE @dupIterator int = 0;
	DECLARE	@dupCount int, @deletedRecordId int;
	SELECT @dupCount = COUNT(ID) FROM @uniqueDuplicates;

	WHILE @dupIterator < @dupCount
	BEGIN
		-- Set to the next iterator value
		SET @dupIterator = @dupIterator + 1;

		-- Get our record to delete from our POG set
		SELECT @deletedRecordId = MAX(pog.ID)
		FROM @pogRecords pog
		INNER JOIN @uniqueDuplicates dup ON pog.planogram_name = dup.planogram_name AND pog.live_date = dup.live_date AND pog.product_code = dup.product_code AND pog.ean = dup.ean AND pog.pck_qty = dup.pck_qty
		WHERE dup.ID = @dupIterator;

		DELETE FROM @pogRecords
		WHERE ID = @deletedRecordId;

	END -- End of duplicate record purge
			
	;WITH planogram_assignments (location_code, live_date) AS
	(
		SELECT
			location_code,
			MAX(live_date)
			FROM dbo.relex_outbound_shelf_edge_labels
			where live_date > @liveDate
			AND source_file_name = @sourceFileName
			AND sys_inserted_dt = @sysInsertedDt
			GROUP BY
			location_code,
			live_date
	)
	INSERT INTO @pogaRecords
	SELECT DISTINCT
		'POGA',
		l.planogram_name,
		'',
		l.location_code,
		l.location_name,
		a.live_date
	FROM dbo.relex_outbound_shelf_edge_labels l
	INNER JOIN planogram_assignments a ON l.location_code = a.location_code --AND l.live_date = a.live_date
	WHERE l.source_file_name = @sourceFileName AND l.sys_inserted_dt = @sysInsertedDt
	ORDER BY
		l.location_code,
		l.location_name,
		l.planogram_name,
		a.live_date;
	
	INSERT INTO @output
	SELECT
		record_type + ',' +
		planogram_name + ',' +
		planogram_code + ',' +
		location_code + ',' +
		location_name + ',' +
		live_date + ',' +
		end_date + ',' +
		product_code + ',' +
		bay_sequence + ',' +
		custom_bay_width + ',' +
		component_sequence + ',' +
		position_sequence + ',' +
		units_wide + ',' +
		units_high + ',' +
		total_units + ',' +
		custom_position_width + ',' +
		code + ',' +
		[name] + ',' +
		custom_pdi_item_number + ',' +
		ean + ',' +
		implementation_feedback_status + ',' +
		implementation_date + ',' +
		implementation_count + ',' +
		created_at + ',' +
		updated_at + ',' +
		assignment_last_modified_date + ',' +
		component_name + ',' +
		component_type + ',' +
		component_width + ',' +
		component_height + ',' +
		component_depth + ',' +
		pck_qty + ',' +
		COALESCE(Scan_Modifier,'') + ',' +
		'' 
	FROM @pogRecords
	ORDER BY ID;

	INSERT INTO @output
	SELECT
		record_type + ',' +
		planogram_name + ',' +
		planogram_code + ',' +
		location_code + ',' +
		location_name + ',' +
		live_date
	FROM @pogaRecords;

	-- Get our output
	SELECT outputCSV from @output
	ORDER BY ID;

	SET NOCOUNT ON;

END

GO