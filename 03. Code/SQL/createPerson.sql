USE [Ceder]
GO

/****** Object:  Table [dbo].[courses3]    Script Date: 15-2-2023 17:50:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--drop table courses
create TABLE [dbo].[person](
	[ID] int,
	[Surname] [varchar](50),
	[SurnamePrefix] [varchar](10) NULL,
	[FirstNames] [varchar](20),
	[CallName] [varchar](20),
	[Email] [varchar](40) NULL,
	[DateOfBirth] [date] NULL,
	[AddressID] int NULL,
	[Status] [varchar](10),
	[ClassID] int,
	[FirstLanguageID] int NULL,
	[SecondLanguageID] int NULL,	
	[StateID] int,
	[SubjectID] int NULL,	
	[BaptizedID] int NULL,
	[DenominationID] int NULL, 
	[IsDislectic] bit NULL
) ON [PRIMARY]
GO
;
