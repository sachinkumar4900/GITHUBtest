SELECT TOP 1
CASE
 WHEN :AndonGroup = '' THEN -1
 ELSE ag.ID
END AS ID
FROM  AndonGroup ag
WHERE  (ag.[Name] = :AndonGroup OR :AndonGroup = '')