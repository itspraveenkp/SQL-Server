SELECT CURRENT_TIMESTAMP -- THE CURRENT_TIMESTAMP FUNCTION RETURN THE CURRENT DATE AND TIME FORMATE YYYY-MM-DD HH:MM:SS.MMM

SELECT DATEADD(YEAR,1,'2020/02/15') -- THIS FUNCTION ADD ONE YEAR TO A DATE THEN RETURN THE DATE

SELECT DATEDIFF(YEAR,'2019/02/26','2025/02/26') -- RETURN THE DIFFRENCE BETWEEN TWO DATE VALUES











use UAT
CREATE TABLE [tblDateTime]
(
 [c_time] [time](7) NULL,
 [c_date] [date] NULL,
 [c_smalldatetime] [smalldatetime] NULL,
 [c_datetime] [datetime] NULL,
 [c_datetime2] [datetime2](7) NULL,
 [c_datetimeoffset] [datetimeoffset](7) NULL
)

INSERT INTO tblDateTime VALUES (GETDATE(),GETDATE(),GETDATE(),GETDATE(),GETDATE(),GETDATE())

SELECT * FROM tblDateTime
