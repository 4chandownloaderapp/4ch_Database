


CREATE PROCEDURE [dbo].[process_data] 
@board_short VARCHAR(4)
AS
BEGIN
DECLARE @webpage VARCHAR(MAX)
DECLARE @webpage_len INT
DECLARE @thread_id BIGINT
DECLARE @post_id BIGINT
DECLARE @file_id BIGINT
DECLARE @file_link VARCHAR(255)
DECLARE @file_name VARCHAR(4000)
DECLARE @md5 VARCHAR(50)
DECLARE @post_message VARCHAR(4000)
DECLARE @thread_subject VARCHAR(4000)
DECLARE @quote VARCHAR(4000)
DECLARE @post_table TABLE ([post_id] BIGINT,[thread_id] BIGINT,[file_id] BIGINT,[board_short] VARCHAR(4),[post_message] VARCHAR(4000))
DECLARE @thread_table TABLE ([thread_id] BIGINT,[thread_subject] VARCHAR(4000))
DECLARE @file_table TABLE ([file_id] BIGINT,[file_link] VARCHAR(255),[file_name] VARCHAR(4000),[md5] VARCHAR(50))
SET @webpage = (SELECT [webpage]FROM [4ch].[dbo].[webpage])
SET @webpage_len = LEN (@webpage)
DECLARE @counter_1 INT

WHILE (CHARINDEX('div class="thread" id="t',@webpage) <> 0)
	BEGIN
		/*THREAD*/
		SET @webpage = SUBSTRING(@webpage,CHARINDEX('div class="thread" id="t',@webpage)+24,@webpage_len)
		SET @thread_id = REPLACE(SUBSTRING(@webpage,1,CHARINDEX('"',@webpage)),'"','') --THREAD_ID
		WHILE	(CHARINDEX('blockquote class="postMessage" id="m',@webpage) < CHARINDEX('div class="thread" id="t',@webpage) 
				AND CHARINDEX('blockquote class="postMessage" id="m',@webpage) <> 0)
				OR 
				(CHARINDEX('div class="thread" id="t',@webpage) = 0
				AND CHARINDEX('blockquote class="postMessage" id="m',@webpage)<>0)			
			BEGIN	
				/*THREAD SUBJECT*/
				IF	CHARINDEX('<span class="subject">',@webpage) <> 0
					AND (
						CHARINDEX('<span class="subject">',@webpage) < CHARINDEX('blockquote class="postMessage" id="m',@webpage)
						OR CHARINDEX('blockquote class="postMessage" id="m',@webpage) = 0
						)
					BEGIN
						SET @webpage = SUBSTRING (@webpage,CHARINDEX('<span class="subject">',@webpage),@webpage_len)
						SET @thread_subject = REPLACE(SUBSTRING(@webpage,23,CHARINDEX('</span>',SUBSTRING(@webpage,23,@webpage_len))),'<','')
						SET @webpage = SUBSTRING (@webpage,CHARINDEX('</span>',@webpage),@webpage_len)
					END
				/*FILE*/
				IF	CHARINDEX('div class="file" id="f',@webpage) <> 0
					AND (
						CHARINDEX('div class="file" id="f',@webpage) < CHARINDEX('blockquote class="postMessage" id="m',@webpage)
						OR CHARINDEX('blockquote class="postMessage" id="m',@webpage) = 0
						)
					BEGIN
					SET @webpage = SUBSTRING(@webpage,CHARINDEX('div class="file" id="f',@webpage)+22,@webpage_len)
					SET @file_id = REPLACE(SUBSTRING(@webpage,1,CHARINDEX('"',@webpage)),'"','')
					IF	@file_id <> 9112225
						BEGIN
							IF	CHARINDEX('class="fileDeletedRes retina"',@webpage) <> 0
								AND (
									CHARINDEX('class="fileDeletedRes retina"',@webpage) < CHARINDEX('<a title="',@webpage)
									OR CHARINDEX('<a title="',@webpage) = 0
									)
								BEGIN
									SET @webpage = SUBSTRING(@webpage,CHARINDEX('class="fileDeletedRes retina"',@webpage),@webpage_len)
								END
							ELSE IF	CHARINDEX('<a title="',@webpage) <> 0
									AND CHARINDEX('<a title="',@webpage) < CHARINDEX('href="//',@webpage)
								BEGIN
									SET @webpage = SUBSTRING(@webpage,CHARINDEX('<a title="',@webpage)+10,@webpage_len)
									SET @file_name = REPLACE(SUBSTRING(@webpage,1,CHARINDEX('"',@webpage)),'"','')
									SET @webpage = SUBSTRING(@webpage,CHARINDEX('href="//',@webpage)+8,@webpage_len)
									SET @file_link = REPLACE(SUBSTRING(@webpage,1,CHARINDEX('"',@webpage)),'"','')
									SET @webpage = SUBSTRING(@webpage,CHARINDEX('data-md5="',@webpage)+10,@webpage_len)
									SET @md5 = REPLACE(SUBSTRING(@webpage,1,CHARINDEX('"',@webpage)),'"','')
								END
							ELSE	
								BEGIN
									SET @webpage = SUBSTRING(@webpage,CHARINDEX('href="//',@webpage)+8,@webpage_len)
									SET @file_link = REPLACE(SUBSTRING(@webpage,1,CHARINDEX('"',@webpage)),'"','')
									SET @file_name = REPLACE(SUBSTRING(@webpage,CHARINDEX('>',@webpage),CHARINDEX('<',@webpage)-CHARINDEX('>',@webpage)),'>','')
									SET @webpage = SUBSTRING(@webpage,CHARINDEX('data-md5="',@webpage)+10,@webpage_len)
									SET @md5 = REPLACE(SUBSTRING(@webpage,1,CHARINDEX('"',@webpage)),'"','')
								END
						END
					END
				/*THREAD SUBJECT*/
				IF	CHARINDEX('<span class="subject">',@webpage) <> 0
					AND (
						CHARINDEX('<span class="subject">',@webpage) < CHARINDEX('blockquote class="postMessage" id="m',@webpage)
						OR CHARINDEX('blockquote class="postMessage" id="m',@webpage) = 0
						)
					BEGIN
						SET @webpage = SUBSTRING (@webpage,CHARINDEX('<span class="subject">',@webpage),@webpage_len)
						SET @thread_subject = REPLACE(SUBSTRING(@webpage,23,CHARINDEX('</span>',SUBSTRING(@webpage,23,@webpage_len))),'<','')
						SET @webpage = SUBSTRING (@webpage,CHARINDEX('</span>',@webpage),@webpage_len)
					END

				/*POST*/
				SET @webpage = SUBSTRING(@webpage,CHARINDEX('blockquote class="postMessage" id="m',@webpage)+36,@webpage_len)
				SET @post_id = REPLACE(SUBSTRING(@webpage,1,CHARINDEX('"',@webpage)),'"','')
				SET @post_message = SUBSTRING(@webpage,CHARINDEX('>',@webpage)+1,CHARINDEX('</blockquote>',@webpage)-CHARINDEX('>',@webpage)-1)

				SET @counter_1 = 0
				WHILE	(CHARINDEX('<a href="',@post_message) <> 0 AND CHARINDEX('</a>',@post_message) <> 0 AND (CHARINDEX('</a>',@post_message)-CHARINDEX('<a href="',@post_message)+4)>0)
						AND @counter_1 < 20
						BEGIN
							SET @quote = SUBSTRING(@post_message,CHARINDEX('<a href="',@post_message),CHARINDEX('</a>',@post_message)-CHARINDEX('<a href="',@post_message)+4)
							SET @post_message = REPLACE(@post_message,@quote,'')
							SET @counter_1 = @counter_1 + 1
						END
		
				SET @counter_1 = 0
				WHILE	(CHARINDEX('<span class="deadlink">',@post_message) <> 0 AND CHARINDEX('</span>',@post_message) <> 0 AND (CHARINDEX('</span>',@post_message)-CHARINDEX('<span class="deadlink">',@post_message)+7) > 0) 
						AND @counter_1 < 20
						BEGIN
							SET @quote = SUBSTRING(@post_message,CHARINDEX('<span class="deadlink">',@post_message),CHARINDEX('</span>',@post_message)-CHARINDEX('<span class="deadlink">',@post_message)+7)
							SET @post_message = REPLACE(@post_message,@quote,'')
							SET @counter_1 = @counter_1 + 1
						END

				SET @post_message = LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@post_message,'<span class="quote">&gt;',' '),'</span>',' '),'<span class="deadlink">>>',' '),'<br>',' '),'&gt;','>'),'&lt;','<'),'&#039;',''''),'<span class="abbr">Comment too long.',' '),'&quot;','"'),'&amp;','&'),'<wbr>',''),'  ',' ')))
				SET @post_message = CASE WHEN @post_message = '' THEN NULL ELSE @post_message END
			
				IF	@post_id = @thread_id AND (@thread_subject = '' OR @thread_subject IS NULL)
					BEGIN
						SET @thread_subject = @post_message
					END

				SET @thread_subject = LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@thread_subject,'<span class="quote">&gt;',' '),'</span>',' '),'<span class="deadlink">>>',' '),'<br>',' '),'&gt;','>'),'&lt;','<'),'&#039;',''''),'<span class="abbr">Comment too long.',' '),'&quot;','"'),'&amp;','&'),'<wbr>',''),'  ',' ')))
				SET @thread_subject = CASE WHEN @thread_subject = '' THEN NULL ELSE @thread_subject END

				INSERT INTO @post_table ([post_id],[thread_id],[file_id],[post_message])
				VALUES (@post_id,@thread_id,@file_id,@post_message)

				DELETE FROM @thread_table WHERE [thread_id] = @thread_id
				INSERT INTO @thread_table ([thread_id],[thread_subject])
				VALUES (@thread_id,@thread_subject)

				IF	@file_id IS NOT NULL
					BEGIN
						INSERT INTO @file_table ([file_id],[file_link],[file_name],[md5])
						VALUES (@file_id,@file_link,@file_name,@md5)
					END

				SET @post_id = NULL
				SET @file_id = NULL
				SET @file_link = NULL
				SET @file_name = NULL
				SET @md5 = NULL
			END
	END

	SET @counter_1 = 1
	DECLARE @max_counter INT
	DECLARE @sentence_current VARCHAR(4000)
	DECLARE @words_table TABLE ([post_message] VARCHAR(4000),[RN] INT,UNIQUE CLUSTERED ([RN]))
	INSERT INTO @words_table ([post_message],[RN])
	SELECT A.[post_message],ROW_NUMBER() OVER (ORDER BY A.[post_message]) AS [RN] FROM @post_table A LEFT JOIN [4ch].[dbo].[post] B ON A.[post_id] = B.[post_id] WHERE B.[post_id] IS NULL AND A.[post_message] <> ''
	SET @max_counter = (SELECT MAX([RN]) FROM @words_table)
	WHILE @counter_1 < @max_counter
		BEGIN
			SET @sentence_current = (SELECT [post_message] FROM @words_table WHERE [RN] = @counter_1)
			EXECUTE [dbo].[words_counter] @sentence = @sentence_current
			SET @counter_1 = @counter_1 + 1
		END 

	SET @counter_1 = 1
	DECLARE @words_table_2 TABLE ([thread_subject] VARCHAR(4000),[RN] INT,UNIQUE CLUSTERED ([RN]))
	INSERT INTO @words_table_2 ([thread_subject],[RN])
	SELECT A.[thread_subject],ROW_NUMBER() OVER (ORDER BY A.[thread_subject]) AS [RN] FROM @thread_table A LEFT JOIN [4ch].[dbo].[thread] B ON A.[thread_id] = B.[thread_id] WHERE B.[thread_id] IS NULL AND A.[thread_subject] <> ''
	SET @max_counter = (SELECT MAX([RN]) FROM @words_table_2)
	WHILE @counter_1 < @max_counter
		BEGIN
			SET @sentence_current = (SELECT [thread_subject] FROM @words_table_2 WHERE [RN] = @counter_1)
			EXECUTE [dbo].[words_counter] @sentence = @sentence_current
			SET @counter_1 = @counter_1 + 1
		END 

	INSERT INTO [4ch].[dbo].[post] ([post_id],[thread_id],[file_id],[post_message],[board_short])
	SELECT A.[post_id],A.[thread_id],A.[file_id],A.[post_message],@board_short FROM @post_table A LEFT JOIN [4ch].[dbo].[post] B ON A.[post_id] = B.[post_id] WHERE B.[post_id] IS NULL

	INSERT INTO [4ch].[dbo].[thread] ([thread_id],[thread_subject])
	SELECT A.[thread_id],A.[thread_subject] FROM @thread_table A LEFT JOIN [4ch].[dbo].[thread] B ON A.[thread_id] = B.[thread_id] WHERE B.[thread_id] IS NULL

	INSERT INTO [4ch].[dbo].[file] ([file_id],[file_link],[file_name],[md5])
	SELECT A.[file_id],A.[file_link],A.[file_name],A.[md5] FROM @file_table A LEFT JOIN [4ch].[dbo].[file] B ON A.[file_id] = B.[file_id] WHERE B.[file_id] IS NULL
END