# Первая часть
---
1.
Найдите количество вопросов, которые набрали больше 300 очков или как минимум 100 раз были добавлены в «Закладки».

SELECT COUNT(title)
FROM stackoverflow.posts
WHERE score > 300 OR favorites_count >= 100;

1355
---
2.
Сколько в среднем в день задавали вопросов с 1 по 18 ноября 2008 включительно? Результат округлите до целого числа.

WITH avg_post_cnt AS
(SELECT COUNT(p.id) AS post_cnt,
       CAST(DATE_TRUNC('day', p.creation_date) AS date)
FROM stackoverflow.posts AS p
JOIN stackoverflow.post_types AS pt ON pt.id=p.post_type_id
WHERE CAST(DATE_TRUNC('day', p.creation_date) AS date) BETWEEN '2008-11-01' AND '2008-11-18'
AND pt.type LIKE 'Question'
GROUP BY CAST(DATE_TRUNC('day', p.creation_date) AS date)
)
SELECT ROUND(AVG(post_cnt))
FROM avg_post_cnt;

383

---
3.
Сколько пользователей получили значки сразу в день регистрации? Выведите количество уникальных пользователей.

SELECT COUNT(DISTINCT u.id)
FROM stackoverflow.users AS u
JOIN stackoverflow.badges AS b ON u.id=b.user_id
WHERE CAST(u.creation_date AS date) = CAST(b.creation_date AS date);

7047

---
4.
Сколько уникальных постов пользователя с именем Joel Coehoorn получили хотя бы один голос?

SELECT COUNT(DISTINCT p.id)
FROM stackoverflow.posts AS p
JOIN stackoverflow.votes AS v ON v.post_id=p.id
JOIN stackoverflow.users AS u ON u.id=p.user_id
WHERE u.display_name LIKE '%Joel Coehoorn%';

 12

---
5.
Выгрузите все поля таблицы vote_types. Добавьте к таблице поле rank, в которое войдут номера записей в обратном порядке.\
Таблица должна быть отсортирована по полю id.

SELECT *,
       ROW_NUMBER() OVER(ORDER BY id DESC) AS rank
FROM stackoverflow.vote_types
ORDER BY id;

id	name	rank\
1	AcceptedByOriginator	15\
2	UpMod	14\
3	DownMod	13
...

---
6.
Отберите 10 пользователей, которые поставили больше всего голосов типа Close.\
Отобразите таблицу из двух полей: идентификатором пользователя и количеством голосов.\
Отсортируйте данные сначала по убыванию количества голосов, потом по убыванию значения идентификатора пользователя.

SELECT u.id,
       COUNT(v.id) AS cnt
FROM stackoverflow.users AS u
JOIN stackoverflow.votes AS v ON u.id=v.user_id
JOIN stackoverflow.vote_types AS vt ON v.vote_type_id=vt.id
WHERE vt.name = 'Close'
GROUP BY u.id
ORDER BY cnt DESC,
         u.id DESC
LIMIT 10;

id	cnt\
20646	36\
14728	36\
27163	29
...

---
7.
Отберите 10 пользователей по количеству значков, полученных в период с 15 ноября по 15 декабря 2008 года включительно.\
Отобразите несколько полей:\
идентификатор пользователя;\
число значков;\
место в рейтинге — чем больше значков, тем выше рейтинг.\
Пользователям, которые набрали одинаковое количество значков, присвойте одно и то же место в рейтинге.\
Отсортируйте записи по количеству значков по убыванию, а затем по возрастанию значения идентификатора пользователя.

WITH rank AS
    (SELECT u.id AS user,
            COUNT(b.id) AS cnt_badges
     FROM stackoverflow.users AS u
     JOIN stackoverflow.badges AS b ON u.id=b.user_id
     WHERE b.creation_date::date BETWEEN '2008-11-15' AND '2008-12-15'
     GROUP BY u.id
     ORDER BY cnt_badges DESC
 )
SELECT *,
        DENSE_RANK() OVER (ORDER BY cnt_badges DESC)
FROM rank
ORDER BY cnt_badges DESC, user
LIMIT 10;

user	cnt_badges	dense_rank\
22656	149	1\
34509	45	2\
1288	40	3
...      

---
8.
Сколько в среднем очков получает пост каждого пользователя?\
Сформируйте таблицу из следующих полей:\
заголовок поста;\
идентификатор пользователя;\
число очков поста;\
среднее число очков пользователя за пост, округлённое до целого числа.\
Не учитывайте посты без заголовка, а также те, что набрали ноль очков.

SELECT p.title,
       u.id,
       score  cnt_score_post,
       ROUND(AVG(score) OVER (PARTITION BY u.id)) avg_score_id_post
FROM stackoverflow.posts p
JOIN stackoverflow.users u ON p.user_id=u.id
WHERE score != 0 AND title IS NOT NULL;

title	id	cnt_score_post	avg_score_id_post\
Diagnosing Deadlocks in SQL Server 2005	1	82	573\
How do I calculate someone's age in C#?	1	1743	573
...

---
9.
Отобразите заголовки постов, которые были написаны пользователями, получившими более 1000 значков.\
Посты без заголовков не должны попасть в список.

SELECT title
FROM
(SELECT user_id,
        cnt
FROM
(SELECT DISTINCT b.user_id,
        COUNT(id) cnt       
FROM stackoverflow.badges b
GROUP BY 1) s
WHERE cnt > 1000
) a
JOIN stackoverflow.users u ON a.user_id=u.id
JOIN stackoverflow.posts p  ON u.id=p.user_id
WHERE title IS NOT NULL;

title
What's the strangest corner case you've seen in C# or .NET?
What's the hardest or most misunderstood aspect of LINQ?
What are the correct version numbers for C#?
Project management to go with GitHub

---
10.
Напишите запрос, который выгрузит данные о пользователях из США (англ. United States).\
Разделите пользователей на три группы в зависимости от количества просмотров их профилей:\
пользователям с числом просмотров больше либо равным 350 присвойте группу 1;\
пользователям с числом просмотров меньше 350, но больше либо равно 100 — группу 2;\
пользователям с числом просмотров меньше 100 — группу 3.\
Отобразите в итоговой таблице идентификатор пользователя, количество просмотров профиля и группу.\
Пользователи с нулевым количеством просмотров не должны войти в итоговую таблицу.

SELECT id,
       views,
       CASE 
            WHEN views >= 350 THEN 1
            WHEN views < 350 AND views >=100 THEN 2
            WHEN views < 100 THEN 3
        END
FROM  stackoverflow.users
WHERE location LIKE '%United States%' AND views != 0;

id	views	case\
3	24396	1\
13	35414	1\
23	757	1
...

---
11.
Дополните предыдущий запрос. Отобразите лидеров каждой группы — пользователей, которые набрали максимальное число просмотров в своей группе.\
Выведите поля с идентификатором пользователя, группой и количеством просмотров.\
Отсортируйте таблицу по убыванию просмотров, а затем по возрастанию значения идентификатора.

WITH tab AS 
(SELECT t.id, 
t.views, 
t.group, 
MAX(t.views) OVER (PARTITION BY t.group) AS max 
FROM 
(SELECT id, 
views, 
CASE 
WHEN views>=350 THEN 1 
WHEN views<100 THEN 3 
ELSE 2 
END AS group 
FROM stackoverflow.users 
WHERE location LIKE '%United States%' 
AND views != 0) as t) 
 
SELECT tab.id, 
tab.views, 
tab.group 
FROM tab 
WHERE tab.views = tab.max 
ORDER BY tab.views DESC, tab.id;

id	views	group\
16587	62813	1\
9094	349	2\
9585	349	2
...

---
12.
Посчитайте ежедневный прирост новых пользователей в ноябре 2008 года.\
Сформируйте таблицу с полями:\
номер дня;\
число пользователей, зарегистрированных в этот день;\
сумму пользователей с накоплением.

SELECT EXTRACT(DAY FROM creation_date) AS day,
       COUNT(id) AS cnt_id,
       SUM(COUNT(id)) OVER (ORDER BY EXTRACT(DAY FROM creation_date)  ) AS sum_id
FROM stackoverflow.users 
WHERE creation_date::date BETWEEN '2008-11-01' AND '2008-11-30'
GROUP BY day;

day	cnt_id	sum_id\
1	34	34\
2	48	82\
3	75	157
...

---
13.
Для каждого пользователя, который написал хотя бы один пост, найдите интервал между регистрацией и временем создания первого поста.\
Отобразите:\
идентификатор пользователя;\
разницу во времени между регистрацией и первым постом.

SELECT DISTINCT u.id,
       MIN(p.creation_date) OVER (PARTITION BY u.id) - u.creation_date AS diff
FROM stackoverflow.posts AS p
JOIN stackoverflow.users AS u ON p.user_id = u.id;

id	diff\
1	9:18:29\
2	14:37:03\
3	3 days, 16:17:09
...


# Вторая часть

---
1.
Выведите общую сумму просмотров постов за каждый месяц 2008 года. Если данных за какой-либо месяц в базе нет, такой месяц можно пропустить.\
Результат отсортируйте по убыванию общего количества просмотров.

SELECT CAST(DATE_TRUNC('month', creation_date) AS date) AS month,
       SUM(views_count) AS total_views
FROM stackoverflow.posts
WHERE creation_date BETWEEN '2008-01-01' AND '2008-12-31'
GROUP BY 1
ORDER BY 2 DESC;

month	total_views\
2008-09-01	452928568\
2008-10-01	365400138\
2008-11-01	221759651
...

---
2.
Выведите имена самых активных пользователей, которые в первый месяц после регистрации (включая день регистрации) дали больше 100 ответов.\
Вопросы, которые задавали пользователи, не учитывайте. Для каждого имени пользователя выведите количество уникальных значений user_id.\
Отсортируйте результат по полю с именами в лексикографическом порядке.

WITH s1 AS 
(SELECT  p.creation_date AS date_post,
         t.type,
         u.creation_date AS date_user,
         p.user_id,
         display_name
FROM stackoverflow.posts p
JOIN stackoverflow.users u ON u.id = p.user_id
JOIN stackoverflow.post_types t ON t.id = p.post_type_id
WHERE (DATE_TRUNC('day', p.creation_date) <= (DATE_TRUNC('day', u.creation_date) + INTERVAL '1 month')) AND type = 'Answer'
), s2 AS 
(SELECT COUNT(DISTINCT(user_id)) AS sum_id,
        display_name,
        COUNT(type) AS sum_answers
        FROM s1
        GROUP BY display_name
)
SELECT sum_id, display_name
FROM s2
WHERE sum_answers > 100;

sum_id	display_name\
1	1800 INFORMATION\
1	Adam Bellaire\
1	Adam Davis
...

---
3.
Выведите количество постов за 2008 год по месяцам.\
Отберите посты от пользователей, которые зарегистрировались в сентябре 2008 года и сделали хотя бы один пост в декабре того же года.\
Отсортируйте таблицу по значению месяца по убыванию.

WITH tt AS 
(SELECT u.id
FROM stackoverflow.users u
JOIN stackoverflow.posts p ON u.id = p.user_id
WHERE DATE_TRUNC('MONTH', u.creation_date)::date = '2008-09-01'
      AND DATE_TRUNC('MONTH', p.creation_date)::date = '2008-12-01'
GROUP BY 1
)
SELECT DATE_TRUNC('MONTH', p.creation_date)::date,
       COUNT(p.id)
FROM stackoverflow.posts p
JOIN tt ON p.user_id = tt.id
GROUP BY 1
ORDER BY 1 DESC;

date_trunc	count\
2008-12-01	17641\
2008-11-01	18294\
2008-10-01	27171
...

---
4.
Используя данные о постах, выведите несколько полей:\
идентификатор пользователя, который написал пост;\
дата создания поста;\
количество просмотров у текущего поста;\
сумму просмотров постов автора с накоплением.
Данные в таблице должны быть отсортированы по возрастанию идентификаторов пользователей,\
а данные об одном и том же пользователе — по возрастанию даты создания поста.

SELECT user_id,
       creation_date,
       views_count,
       SUM(views_count) OVER (PARTITION BY user_id ORDER BY creation_date) total_views
from stackoverflow.posts;

user_id	creation_date	views_count	total_views\
1	2008-07-31 23:41:00	480476	480476\
1	2008-07-31 23:55:38	136033	616509\
1	2008-07-31 23:56:41	0	616509
...

---
5.
Сколько в среднем дней в период с 1 по 7 декабря 2008 года включительно пользователи взаимодействовали с платформой?\
Для каждого пользователя отберите дни, в которые он или она опубликовали хотя бы один пост.\
Нужно получить одно целое число — не забудьте округлить результат.

WITH tt AS
(SELECT user_id,
        COUNT(DISTINCT creation_date::date) AS cnt_day
FROM stackoverflow.posts
WHERE creation_date BETWEEN '2008-12-01' AND '2008-12-07'
GROUP BY user_id
)
SELECT ROUND(AVG(cnt_day))
FROM tt;

round\
2

---
6.
На сколько процентов менялось количество постов ежемесячно с 1 сентября по 31 декабря 2008 года? Отобразите таблицу со следующими полями:\
номер месяца;\
количество постов за месяц;\
процент, который показывает, насколько изменилось количество постов в текущем месяце по сравнению с предыдущим.\
Если постов стало меньше, значение процента должно быть отрицательным, если больше — положительным.\
Округлите значение процента до двух знаков после запятой.\
Напомним, что при делении одного целого числа на другое в PostgreSQL в результате получится целое число,\
округлённое до ближайшего целого вниз.\
Чтобы этого избежать, переведите делимое в тип numeric.

SELECT i.month,
       cnt_post,
       ROUND((i.cnt_post::numeric /i.cnt_lag - 1)*100, 2)
FROM 
    (SELECT *,
            LAG(cnt_post) OVER() AS cnt_lag
    FROM 
        (SELECT EXTRACT(MONTH FROM creation_date) AS month,
                COUNT(DISTINCT id) AS cnt_post
        FROM stackoverflow.posts
        WHERE creation_date::date BETWEEN '2008-09-01' AND  '2008-12-31'
        GROUP BY EXTRACT(MONTH FROM creation_date)) i
     ) i
WHERE i.month >= 9;

month	cnt_post	round\
9	70371	\
10	63102	-10.33\
11	46975	-25.56
...

---
7.
Выгрузите данные активности пользователя, который опубликовал больше всего постов за всё время.
Выведите данные за октябрь 2008 года в таком виде:\
номер недели;\
дата и время последнего поста, опубликованного на этой неделе.

WITH a AS
(SELECT user_id,
        creation_date
 FROM stackoverflow.posts
 WHERE EXTRACT(MONTH FROM creation_date) = 10 AND user_id =
 (
 SELECT u.id
 FROM stackoverflow.users u
 JOIN stackoverflow.posts p ON u.id=p.user_id
 GROUP BY u.id
 ORDER BY COUNT(p.id) DESC
 LIMIT 1)),
b AS
(SELECT *,
        EXTRACT(WEEK FROM creation_date)
FROM a)
SELECT DISTINCT(date_part),
       MAX(b.creation_date) OVER (PARTITION BY date_part)
FROM b;

date_part	max\
43	2008-10-26 21:44:36\
40	2008-10-05 09:00:58\
44	2008-10-31 22:16:01
...
---




