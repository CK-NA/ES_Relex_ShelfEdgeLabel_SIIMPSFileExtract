USE [CK_Reporting]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[relex_outbound_shelf_edge_labels](
	[planogram_name] [varchar](60) NULL,
	[planogram_code] [varchar](50) NULL,
	[location_code] [varchar](50) NULL,
	[location_name] [varchar](50) NULL,
	[live_date] [varchar](50) NULL,
	[end_date] [varchar](50) NULL,
	[product_code] [varchar](50) NULL,
	[bay_sequence] [varchar](50) NULL,
	[custom_bay_width] [varchar](50) NULL,
	[component_sequence] [varchar](50) NULL,
	[position_sequence] [varchar](50) NULL,
	[units_wide] [varchar](50) NULL,
	[units_high] [varchar](50) NULL,
	[total_units] [varchar](50) NULL,
	[custom_position_width] [varchar](50) NULL,
	[code] [varchar](50) NULL,
	[name] [varchar](60) NULL,
	[custom_pdi_item_number] [varchar](50) NULL,
	[ean] [varchar](50) NULL,
	[implementation_feedback_status] [varchar](50) NULL,
	[implementation_date] [varchar](50) NULL,
	[implementation_count] [varchar](50) NULL,
	[created_at] [varchar](50) NULL,
	[updated_at] [varchar](50) NULL,
	[assignment_last_modified_date] [varchar](50) NULL,
	[component_name] [varchar](50) NULL,
	[component_type] [varchar](50) NULL,
	[component_width] [varchar](50) NULL,
	[component_height] [varchar](50) NULL,
	[component_depth] [varchar](50) NULL,
	[pck_qty] [varchar](10) NULL,
	[Scan_Modifier] [varchar](20) NULL,
	[source_file_name] [varchar](250) NULL,
	[sys_inserted_dt] [varchar](50) NULL,
	[sys_inserted_by] [varchar](50) NULL,
	[sys_updated_dt] [varchar](50) NULL
) ON [PRIMARY]
GO


