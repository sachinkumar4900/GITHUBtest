SELECT TOP 1
CASE
 WHEN :AndonGroupID = -1 THEN 'Team Lead'
 ELSE ag.[Name]
END AS [Name]
FROM  AndonGroup ag
WHERE  (ID = :AndonGroupID OR :AndonGroupID = -1)