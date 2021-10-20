CREATE TABLE [dbo].[file] (
    [file_id]               BIGINT         NOT NULL,
    [file_name]             VARCHAR (4000) NULL,
    [md5]                   VARCHAR (50)   NULL,
    [file_link]             VARCHAR (255)  NULL,
    [date_loaded]           DATETIME       CONSTRAINT [DF_file_date_loaded] DEFAULT (getdate()) NULL,
    [file_body]             IMAGE          NULL,
    [download_lock]         BIT            NULL,
    [download_error]        BIT            NULL,
    [download_error_second] BIT            NULL,
    [thumbnail]             IMAGE          NULL,
    [downloaded]            BIT            NULL,
    CONSTRAINT [PK_file] PRIMARY KEY NONCLUSTERED ([file_id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20210301-072944]
    ON [dbo].[file]([file_id] ASC) WHERE ([file_body] IS NULL AND [download_lock] IS NULL AND [download_error] IS NULL);


GO
CREATE NONCLUSTERED INDEX [idx_2_file]
    ON [dbo].[file]([download_error] ASC)
    INCLUDE([file_id], [file_name], [file_link]) WHERE ([download_error]=(1));


GO
CREATE NONCLUSTERED INDEX [idx_1_file]
    ON [dbo].[file]([download_error] ASC, [download_lock] ASC)
    INCLUDE([file_id], [file_name], [file_link]) WHERE ([file_body] IS NULL AND [download_lock] IS NULL AND [download_error] IS NULL);


GO
CREATE CLUSTERED INDEX [idx_0_file]
    ON [dbo].[file]([file_id] ASC);


GO
CREATE COLUMNSTORE INDEX [NonClusteredColumnStoreIndex-20210301-143620]
    ON [dbo].[file]([download_lock], [download_error], [file_id], [file_name], [file_link]);

