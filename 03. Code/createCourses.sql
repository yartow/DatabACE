USE [Ceder]
GO

/****** Object:  Table [dbo].[courses3]    Script Date: 15-2-2023 17:50:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--drop table courses
create TABLE [dbo].[courses](
	[ID] int,
	[Alias] [varchar](50) NULL,
	[Level] int NULL,
	[PaceNrStart] int NULL,
	[PaceNrEnd] int NULL,	
	[StarValue] decimal(5,3) NULL,
	[SubjectID] int NULL,	
	[Remarks] [varchar](255) NULL,
	[SubjectGroupID] int NULL,
	[CourseType] [varchar](50) NULL
) ON [PRIMARY]
GO
;


