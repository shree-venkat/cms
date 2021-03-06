CREATE FUNCTION [dbo].[fnSplit]
(
	@string NVARCHAR(MAX),
	@delim VARCHAR(50) = ','
)
RETURNS	TABLE
AS
	RETURN ( SELECT [Item] FROM
		(SELECT Item = LTRIM(RTRIM(y.i.value('(./text())[1]', 'nvarchar(4000)')))
		FROM (SELECT a = CONVERT(XML, '<i>' + REPLACE(@string, @delim, '</i><i>') + '</i>').query('.')) AS x
		CROSS APPLY a.nodes('i') AS y(i)) z
		WHERE Item IS NOT NULL -- remove empty entries
	);
GO

CREATE PROCEDURE [dbo].[CreateBlogPost]
	@Title nvarchar(max), @ShortDescription nvarchar(max), @Content nvarchar(max), 
	@UrlSlug nvarchar(250), @PostedOn datetime, @Category_Id int, @Tags nvarchar(1000)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Id INT = 0

	/*IF EXISTS (SELECT t2.[Name] 
				FROM [dbo].[fnSplit](@Tags, ',') t1 
				LEFT JOIN [dbo].[Tags] t2 ON t2.Name = t1.[Item]
				WHERE t2.Name IS NULL)
	BEGIN
		RAISERROR('Invalid tag(s) used.', 16, 1);
		RETURN
	END*/

	INSERT INTO [dbo].[Posts] ([Title], [ShortDescription], [Content], [UrlSlug], [Published], [PostedOn], [ModifiedOn], [Category_Id])
	VALUES (@Title, @ShortDescription, @Content, @UrlSlug, 1, @PostedOn, NULL, @Category_Id)

	SET @Id = SCOPE_IDENTITY()

	INSERT INTO [dbo].[Tags] ([Name], [UrlSlug], [Description], [Class], [Post_Id])
	SELECT t2.[Name]
		  ,t2.[UrlSlug]
		  ,t2.[Description]
		  ,t2.[Class]
		  ,@Id
	FROM [dbo].[fnSplit](@Tags, ',') t1
	INNER JOIN [dbo].[Tags] t2 ON t2.Name = t1.[Item]
	WHERE t2.Post_Id IS NULL

END
GO
