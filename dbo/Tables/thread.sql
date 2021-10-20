CREATE TABLE [dbo].[thread] (
    [thread_id]      BIGINT         NULL,
    [thread_subject] VARCHAR (4000) NULL,
    [date_loaded]    DATETIME       CONSTRAINT [DF_thread_date_loaded] DEFAULT (getdate()) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_1_thread]
    ON [dbo].[thread]([thread_id] ASC)
    INCLUDE([thread_subject]);


GO
CREATE CLUSTERED INDEX [idx_0_thread]
    ON [dbo].[thread]([thread_id] ASC);

