/* Listing 4-4 */

CREATE TABLE table1 (
id_pk INTEGER NOT NULL PRIMARY KEY,
color VARCHAR(10) NOT NULL);

CREATE TABLE table2 (
id_pk INTEGER NOT NULL PRIMARY KEY,
color VARCHAR(10) NOT NULL);

CREATE TABLE table3 (
color VARCHAR(10) NOT NULL);
INSERT INTO table1 VALUES (1, 'RED');
INSERT INTO table1 VALUES (2, 'RED');
INSERT INTO table1 VALUES (3, 'ORANGE');
INSERT INTO table1 VALUES (4, 'ORANGE');
INSERT INTO table1 VALUES (5, 'ORANGE');
INSERT INTO table1 VALUES (6, 'YELLOW');
INSERT INTO table1 VALUES (7, 'GREEN');
INSERT INTO table1 VALUES (8, 'BLUE');
INSERT INTO table1 VALUES (9, 'BLUE');
INSERT INTO table1 VALUES (10, 'VIOLET');
INSERT INTO table2 VALUES (1, 'RED');
INSERT INTO table2 VALUES (2, 'RED');
INSERT INTO table2 VALUES (3, 'BLUE');
INSERT INTO table2 VALUES (4, 'BLUE');
INSERT INTO table2 VALUES (5, 'BLUE');
INSERT INTO table2 VALUES (6, 'GREEN');
COMMIT;

select color from table1
union
select color from table2;

select color from table1
union all
select color from table2;

select color from table1;

select color from table3;

select color from table1
union
select color from table3;

select * from table1
union
select color from table2;


