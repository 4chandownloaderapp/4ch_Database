CREATE TABLE [dbo].[board_last_update] (
    [board_link]  VARCHAR (50) NULL,
    [board_short] VARCHAR (4)  NULL,
    [last_update] DATETIME     NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_1_board_last_update]
    ON [dbo].[board_last_update]([last_update] DESC)
    INCLUDE([board_link], [board_short]);


GO
CREATE CLUSTERED INDEX [idx_0_board_last_update]
    ON [dbo].[board_last_update]([board_link] ASC);

