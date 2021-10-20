CREATE TABLE [dbo].[post] (
    [post_id]      BIGINT         NULL,
    [thread_id]    BIGINT         NULL,
    [file_id]      BIGINT         NULL,
    [board_short]  VARCHAR (4)    NULL,
    [post_message] VARCHAR (4000) NULL,
    [date_loaded]  DATETIME       CONSTRAINT [DF_post_DATE] DEFAULT (getdate()) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_3_post]
    ON [dbo].[post]([date_loaded] ASC, [file_id] ASC, [thread_id] ASC)
    INCLUDE([post_id], [board_short], [post_message]);


GO
CREATE NONCLUSTERED INDEX [idx_2_post]
    ON [dbo].[post]([file_id] ASC, [date_loaded] ASC);


GO
CREATE CLUSTERED INDEX [idx_0_post]
    ON [dbo].[post]([post_id] ASC);

