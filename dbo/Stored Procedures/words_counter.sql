CREATE PROCEDURE [dbo].[words_counter] 
@sentence VARCHAR(4000)
AS 
BEGIN
	DECLARE @word VARCHAR(255)
	DECLARE @sentence_len INT
	DECLARE @space_index INT
	DECLARE @words_table TABLE ([word] VARCHAR(255),[counter] INT,UNIQUE CLUSTERED ([word],[counter]))
	SET @sentence = LTRIM(RTRIM(@sentence))
	SET @sentence_len = LEN(@sentence)
	SET @space_index = CHARINDEX(' ',@sentence)
	WHILE	@space_index <> 0
			BEGIN
				SET @word = RTRIM(LEFT(SUBSTRING(@sentence,1,@space_index),255))
				WHILE @word NOT LIKE '%[0-9A-Ż]' AND @word <> ''
					BEGIN
						SET @word = REVERSE(SUBSTRING(REVERSE(@word),2,@sentence_len))
					END
				WHILE @word NOT LIKE '[0-9A-Ż]%' AND @word <> ''
					BEGIN
						SET @word = SUBSTRING(@word,2,@sentence_len)
					END
				SET @sentence = LTRIM(SUBSTRING(@sentence,@space_index,@sentence_len))
				IF	@word IN (SELECT [word] FROM @words_table WHERE [word] IS NOT NULL) AND @word <> ''
					BEGIN
						UPDATE A
						SET [counter] = [counter] + 1
						FROM @words_table A 
						WHERE [word] = @word
					END
				ELSE IF @word <> ''
					BEGIN
						INSERT INTO @words_table ([word],[counter])
						VALUES (@word,1)
					END
				SET @space_index = CHARINDEX(' ',@sentence)
			END
	
	IF	@space_index = 0
		BEGIN
			SET @word = LTRIM(@sentence)
			WHILE @word NOT LIKE '%[0-9A-Ż]' AND @word <> ''
				BEGIN
					SET @word = REVERSE(SUBSTRING(REVERSE(@word),2,@sentence_len))
				END
			WHILE @word NOT LIKE '[0-9A-Ż]%' AND @word <> ''
				BEGIN
					SET @word = SUBSTRING(@word,2,@sentence_len)
				END
			IF	@word IN (SELECT [word] FROM @words_table WHERE [word] IS NOT NULL) AND @word <> ''
				BEGIN
					UPDATE A
					SET [counter] = [counter] + 1
					FROM @words_table A 
					WHERE [word] = @word
				END
			ELSE IF @word <> ''
				BEGIN
					INSERT INTO @words_table ([word],[counter])
					VALUES (@word,1)
				END
		END

	UPDATE A
	SET [counter] = A.[counter] + B.[counter]
	FROM [4ch].[dbo].[word] A JOIN @words_table B ON A.word = B.word

	INSERT INTO [4ch].[dbo].[word] ([word],[counter])
	SELECT 
	A.[word]
	,A.[counter] 
	FROM @words_table A LEFT JOIN [4ch].[dbo].[word] B ON A.[word] = B.[word]
	WHERE 
	B.[word] IS NULL
END