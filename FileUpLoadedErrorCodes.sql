USE [LAKSHYA]
GO


CREATE TABLE [cdgmaster].[FileUpLoadedErrorCodes](
	[FileUpLoadedErrorCode] [numeric](18, 0) NOT NULL,
	[FileType] [varchar](50) NOT NULL,
	[UploadErrorCode] [varchar](10) NOT NULL,
	[error_description] [varchar](250) NOT NULL
) ON [PRIMARY]
GO


