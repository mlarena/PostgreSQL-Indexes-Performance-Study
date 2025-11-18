SELECT count(*)
FROM btree.orders;
--200000

SELECT count(*)
FROM btree.users;
--100000

SELECT count(*)
FROM hash.config;
--15

SELECT count(*)
FROM hash.products;
--50000

SELECT count(*)
FROM hash.user_sessions;
--100000


SELECT pg_size_pretty(pg_database_size('indexes_study'));
--67 MB