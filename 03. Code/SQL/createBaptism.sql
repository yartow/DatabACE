USE [Ceder]
GO

/****** Object:  Table [dbo].[courses3]    Script Date: 15-2-2023 17:50:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create TABLE [dbo].[baptism](
	[ID] int,
	[baptism] [varchar](50),
	[Type] [varchar](15),
	[Age] [varchar](15),
	[Group] [varchar](20),
	[Remarks] [varchar](50) NULL	
) ON [PRIMARY]
GO
;
