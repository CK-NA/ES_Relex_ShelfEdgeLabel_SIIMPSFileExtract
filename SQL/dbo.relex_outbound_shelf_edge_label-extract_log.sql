USE [CK_Reporting]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[relex_outbound_shelf_edge_label_extract_log](
	[source_file_name] [varchar](60) NOT NULL,
	[sys_inserted_dt] [varchar](50) NOT NULL,
	[extracted_tsp] [datetime] NULL,
 CONSTRAINT [PK_relex_outbound_shelf_edge_label_extract_log] PRIMARY KEY CLUSTERED 
(
	[source_file_name] ASC,
	[sys_inserted_dt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


