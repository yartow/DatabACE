USE [Ceder]
GO

/****** Object:  Table [dbo].[courses3]    Script Date: 15-2-2023 17:50:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--drop table courses
create TABLE [dbo].[denomination](
	[ID] int,
	[Denomination] int,
	[Remarks] [varchar](255)
) ON [PRIMARY]
GO
;
