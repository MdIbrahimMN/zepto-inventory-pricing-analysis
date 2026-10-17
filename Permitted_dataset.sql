SELECT user, host, plugin
FROM mysql.user
WHERE user = 'powerbi_user';

ALTER USER 'powerbi_user'@'localhost'
IDENTIFIED BY 'PowerBI_Test_2026!';

GRANT SELECT ON zepto_analytics.*
TO 'powerbi_user'@'localhost';