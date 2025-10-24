SELECT filedata AS Content, 'application/pdf' AS ContentType
FROM Documents
WHERE ID = :ID