CREATE TABLE [dbo].[word] (
    [word]          VARCHAR (255) NULL,
    [counter]       INT           NULL,
    [word_excluded] BIT           NULL
);


GO
CREATE CLUSTERED INDEX [idx_0_word]
    ON [dbo].[word]([word] ASC);

