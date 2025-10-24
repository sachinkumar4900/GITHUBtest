SELECT [ScrapCode]
		,[Reason]
  FROM [dbo].[ScrapReasonTrees]
  WHERE [Name] = :ValueStream
  AND ScrapCode IS NOT NULL;