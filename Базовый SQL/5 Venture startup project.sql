1.
Посчитайте, сколько компаний закрылось.

SELECT COUNT(name)
FROM company
WHERE status='closed';

2584
---

2.
Отобразите количество привлечённых средств для новостных компаний США.
Используйте данные из таблицы company.
Отсортируйте таблицу по убыванию значений в поле funding_total.

SELECT funding_total
FROM company
WHERE category_code = 'news' AND country_code = 'USA'
ORDER BY funding_total DESC;

funding_total
6.22553e+08
2.5e+08
1.605e+08...
---

3.
Найдите общую сумму сделок по покупке одних компаний другими в долларах.
Отберите сделки, которые осуществлялись только за наличные с 2011 по 2013 год включительно.

SELECT SUM(price_amount)
FROM acquisition
WHERE term_code = 'cash'
AND
EXTRACT (YEAR FROM acquired_at) BETWEEN 2011 AND 2013;

sum
1.37762e+11
---

4.
Отобразите имя, фамилию и названия аккаунтов людей в твиттере, у которых названия аккаунтов начинаются на 'Silver'.

SELECT first_name,
       last_name,
       twitter_username
FROM people
WHERE twitter_username LIKE 'Silver%';

first_name	   last_name	      twitter_username
Rebecca	       Silver	          SilverRebecca
Silver	       Teede	          SilverMatrixx
Mattias	      Guilotte	          Silverreven
---

5.
Выведите на экран всю информацию о людях, у которых названия аккаунтов в твиттере содержат подстроку 'money',
а фамилия начинается на 'K'.

SELECT *
FROM people
WHERE twitter_username LIKE '%money%'
AND last_name LIKE 'K%';

id	   first_name	last_name	company_id	twitter_username	  created_at	         updated_at
63081	Gregory	   Kim		               gmoney75	           2010-07-13 03:46:28	2011-12-12 22:01:34
---

6.
Для каждой страны отобразите общую сумму привлечённых инвестиций, которые получили компании, зарегистрированные в этой стране.
Страну, в которой зарегистрирована компания, можно определить по коду страны. Отсортируйте данные по убыванию суммы.

SELECT country_code,
       SUM(funding_total) total
FROM company
GROUP BY country_code
ORDER BY total DESC;

country_code	  total
USA	           3.10588e+11
GBR	           1.77056e+10...
---

7.
Составьте таблицу, в которую войдёт дата проведения раунда, а также минимальное и максимальное значения суммы инвестиций,
привлечённых в эту дату. Оставьте в итоговой таблице только те записи, в которых минимальное значение суммы инвестиций
не равно нулю и не равно максимальному значению.

SELECT funded_at,
       MIN(raised_amount) min,
       MAX(raised_amount) max
FROM funding_round
GROUP BY funded_at
HAVING MIN(raised_amount) != 0
AND
MIN(raised_amount) != MAX(raised_amount);

funded_at	min	      max
2012-08-22	40000	      7.5e+07
2010-07-25	3.27825e+06	9e+06
2002-03-01	2.84418e+06	8.95915e+06...
---

8.
Создайте поле с категориями:
Для фондов, которые инвестируют в 100 и более компаний, назначьте категорию high_activity.
Для фондов, которые инвестируют в 20 и более компаний до 100, назначьте категорию middle_activity.
Если количество инвестируемых компаний фонда не достигает 20, назначьте категорию low_activity.
Отобразите все поля таблицы fund и новое поле с категориями.

SELECT *,
       CASE 
           WHEN invested_companies >= 100 THEN 'high_activity'
           WHEN invested_companies >= 20 THEN 'middle_activity'
           WHEN invested_companies < 20 THEN 'low_activity'
       END
FROM fund;

id	name	founded_at	domain	twitter_username	country_code	investment_rounds	invested_companies	milestones	created_at	updated_at	case
13131						0	0	0	2013-08-19 18:46:55	2013-08-19 19:55:07	low_activity
1	Greylock Partners	1965-01-01	greylock.com	greylockvc	USA	307	196	0	2007-05-25 20:18:23	2012-12-27 00:42:24	high_activity...
---

9.
Для каждой из категорий, назначенных в предыдущем задании, посчитайте округлённое до ближайшего целого числа среднее количество инвестиционных раундов,
в которых фонд принимал участие. Выведите на экран категории и среднее число инвестиционных раундов. Отсортируйте таблицу по возрастанию среднего.

SELECT CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity'
       END AS activity,
       ROUND(AVG(investment_rounds)) avg
FROM fund
GROUP BY activity
ORDER BY avg;

activity	         avg
low_activity	   2
middle_activity	51
high_activity	   252
---

10.
Проанализируйте, в каких странах находятся фонды, которые чаще всего инвестируют в стартапы. 
Для каждой страны посчитайте минимальное, максимальное и среднее число компаний, в которые инвестировали фонды этой страны,
основанные с 2010 по 2012 год включительно.
Исключите страны с фондами, у которых минимальное число компаний, получивших инвестиции, равно нулю. 
Выгрузите десять самых активных стран-инвесторов: отсортируйте таблицу по среднему количеству компаний от большего к меньшему.
Затем добавьте сортировку по коду страны в лексикографическом порядке.

SELECT country_code,
       MIN(invested_companies),
       MAX(invested_companies),
       AVG(invested_companies)
FROM fund
WHERE founded_at BETWEEN '01-01-2010' AND '31-12-2012'
GROUP BY country_code
HAVING MIN(invested_companies) != 0
ORDER BY AVG(invested_companies) DESC, country_code
LIMIT 10;

country_code	min	max	avg
BGR	         25	   35	   30
CHL	         29	   29	   29...
---

11.
Отобразите имя и фамилию всех сотрудников стартапов. Добавьте поле с названием учебного заведения, которое окончил сотрудник,
если эта информация известна.

SELECT p.first_name,
       p.last_name,
       e.instituition
FROM people AS p
LEFT JOIN education AS e ON p.id = e.person_id;

first_name	last_name	instituition
John	      Green	      Washington University, St. Louis
John	      Green	      Boston University
David	      Peters	   Rice University...
---

12.
Для каждой компании найдите количество учебных заведений, которые окончили её сотрудники.
Выведите название компании и число уникальных названий учебных заведений.
Составьте топ-5 компаний по количеству университетов.

SELECT c.name,
COUNT(DISTINCT e.instituition) amount
FROM company c
JOIN people p ON c.id=p.company_id
JOIN education e ON e.person_id=p.id
GROUP BY c.name
ORDER BY amount DESC
LIMIT 5;

name	      amount
Google	   167
Yahoo!	   115
Microsoft	111...

---
13.
Составьте список с уникальными названиями закрытых компаний, для которых первый раунд финансирования оказался последним.

SELECT DISTINCT c.name
FROM company c
JOIN funding_round fr ON c.id=fr.company_id
WHERE c.status = 'closed'
AND fr.is_first_round = '1'
AND fr.is_last_round = '1';

name
10BestThings
11i Solutions...

---
14.
Составьте список уникальных номеров сотрудников, которые работают в компаниях, отобранных в предыдущем задании.

SELECT DISTINCT id
FROM people
WHERE company_id IN (
   SELECT DISTINCT c.id 
FROM company c
JOIN funding_round fr ON c.id=fr.company_id
WHERE c.status = 'closed'
AND fr.is_first_round = '1'
AND fr.is_last_round = '1');

id
62
97...
---

15.
Составьте таблицу, куда войдут уникальные пары с номерами сотрудников из предыдущей задачи и учебным заведением, которое окончил сотрудник.

SELECT DISTINCT e.person_id,
                e.instituition
FROM education e
JOIN (
   SELECT DISTINCT id
FROM people 
WHERE company_id IN (
   SELECT DISTINCT c.id 
FROM company c
JOIN funding_round fr ON c.id=fr.company_id
WHERE c.status = 'closed'
AND fr.is_first_round = '1'
AND fr.is_last_round = '1')) t
ON t.id=e.person_id;

person_id	instituition
349	      AKI
349	      ArtEZ Hogeschool voor de Kunsten...
---

16.
Посчитайте количество учебных заведений для каждого сотрудника из предыдущего задания.
При подсчёте учитывайте, что некоторые сотрудники могли окончить одно и то же заведение дважды.

SELECT e.person_id,
       COUNT(e.instituition)
FROM education e
JOIN (
   SELECT DISTINCT id
FROM people 
WHERE company_id IN (
   SELECT DISTINCT c.id 
FROM company c
JOIN funding_round fr ON c.id=fr.company_id
WHERE c.status = 'closed'
AND fr.is_first_round = '1'
AND fr.is_last_round = '1')
) t
ON t.id=e.person_id
GROUP BY e.person_id;

person_id	count
349	      3
699	      1...
---

17.
Дополните предыдущий запрос и выведите среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники разных компаний.
Нужно вывести только одну запись, группировка здесь не понадобится.

SELECT AVG(s.cnt)
FROM (
   SELECT COUNT(e.instituition) cnt
FROM education e
JOIN (
   SELECT DISTINCT id
FROM people 
WHERE company_id IN (
   SELECT DISTINCT c.id 
FROM company c
JOIN funding_round fr ON c.id=fr.company_id
WHERE c.status = 'closed'
AND fr.is_first_round = '1'
AND fr.is_last_round = '1')
) t
ON t.id=e.person_id
GROUP BY e.person_id) s;

avg
1.41509
---

18.
Напишите похожий запрос: выведите среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники Facebook.

SELECT AVG(s.cnt)
FROM (
   SELECT COUNT(e.instituition) cnt
FROM education e
JOIN (
   SELECT DISTINCT id
FROM people 
WHERE company_id IN (
   SELECT DISTINCT c.id 
FROM company c
JOIN funding_round fr ON c.id=fr.company_id
WHERE c.name = 'Facebook')
) t
ON t.id=e.person_id
GROUP BY e.person_id) s;

avg
1.51111
---

19.
Составьте таблицу из полей:
name_of_fund — название фонда;
name_of_company — название компании;
amount — сумма инвестиций, которую привлекла компания в раунде.
В таблицу войдут данные о компаниях, в истории которых было больше шести важных этапов, а раунды финансирования проходили с 2012 по 2013 год включительно.

SELECT f.name name_of_fund, 
       C.name name_of_company, 
       fr.raised_amount amount
FROM investment  i
JOIN company c ON i.company_id=c.id
JOIN fund f ON i.fund_id=f.id
JOIN funding_round fr ON i.funding_round_id = fr.id
WHERE EXTRACT(YEAR FROM fr.funded_at) BETWEEN 2012 AND 2013
   AND c.milestones > 6;

name_of_fund	   name_of_company	amount
SAP Ventures	   OpenX	            2.50112e+07
Samsung Ventures	OpenX	            2.50112e+07...
---

20.
Выгрузите таблицу, в которой будут такие поля:
название компании-покупателя;
сумма сделки;
название компании, которую купили;
сумма инвестиций, вложенных в купленную компанию;
доля, которая отображает, во сколько раз сумма покупки превысила сумму вложенных в компанию инвестиций, округлённая до ближайшего целого числа.
Не учитывайте те сделки, в которых сумма покупки равна нулю. Если сумма инвестиций в компанию равна нулю, исключите такую компанию из таблицы. 
Отсортируйте таблицу по сумме сделки от большей к меньшей, а затем по названию купленной компании в лексикографическом порядке.
Ограничьте таблицу первыми десятью записями.

WITH
t1 AS
(SELECT a.id a_id,
        c.name acquiring_company_name,
        a.price_amount price_amount
FROM acquisition a
LEFT JOIN company c ON c.id=a.acquiring_company_id
WHERE a.price_amount !=0),
t2 AS
(SELECT a.id a_id,
        c.name acquired_company_name,
        c.funding_total funding_total
FROM acquisition a
LEFT JOIN company c ON c.id=a.acquired_company_id
WHERE c.funding_total != 0)
SELECT acquiring_company_name,
       price_amount,
       acquired_company_name,
       funding_total,
       ROUND(price_amount/funding_total) rate
FROM t1
JOIN t2 using(a_id)
ORDER BY price_amount DESC, acquired_company_name
LIMIT 10;

acquiring_company_name	price_amount	acquired_company_name	funding_total	rate
Microsoft	            8.5e+09	      Skype	                  7.6805e+07	   111
Scout Labs	            4.9e+09	      VSEA	                  4.8e+06	      1021...
---

21.
Выгрузите таблицу, в которую войдут названия компаний из категории social, получившие финансирование с 2010 по 2013 год включительно.
Проверьте, что сумма инвестиций не равна нулю. Выведите также номер месяца, в котором проходил раунд финансирования.

SELECT c.name,
       EXTRACT(MONTH FROM (fr.funded_at)) AS month
FROM company c
RIGHT JOIN funding_round fr ON c.id=fr.company_id
WHERE EXTRACT(YEAR FROM (fr.funded_at)) BETWEEN 2010 AND 2013
AND c.category_code='social' 
AND fr.raised_amount != 0;

name	      month
Klout	      1
WorkSimple	3...
---

22.
Отберите данные по месяцам с 2010 по 2013 год, когда проходили инвестиционные раунды. 
Сгруппируйте данные по номеру месяца и получите таблицу, в которой будут поля:
номер месяца, в котором проходили раунды;
количество уникальных названий фондов из США, которые инвестировали в этом месяце;
количество компаний, купленных за этот месяц;
общая сумма сделок по покупкам в этом месяце.

WITH
t1 AS (
SELECT EXTRACT(MONTH FROM(fr.funded_at)) AS month,
       COUNT(DISTINCT f.name) AS fund_count
FROM funding_round fr
LEFT JOIN investment i ON fr.id=i.funding_round_id
LEFT JOIN fund f ON f.id=i.fund_id
WHERE EXTRACT(YEAR FROM(funded_at)) BETWEEN 2010 AND 2013
AND country_code = 'USA'
GROUP BY month),
t2 AS (
SELECT EXTRACT(MONTH FROM(a.acquired_at)) AS month,
       COUNT(a.acquired_company_id) AS company_count,
       SUM(a.price_amount) AS total_sum
FROM acquisition a
WHERE EXTRACT(YEAR FROM(a.acquired_at)) BETWEEN 2010 AND 2013
GROUP BY month)
SELECT month,
       fund_count,
       company_count,
       total_sum
FROM t1
LEFT JOIN t2 using(month);

month	fund_count	company_count	total_sum
1	   815	      600	         2.71083e+10
2	   637	      418	         4.13903e+10...
---

23.
Составьте сводную таблицу и выведите среднюю сумму инвестиций для стран, в которых есть стартапы, зарегистрированные в 2011, 2012 и 2013 годах.
Данные за каждый год должны быть в отдельном поле. Отсортируйте таблицу по среднему значению инвестиций за 2011 год от большего к меньшему.

WITH
a AS
(SELECT country_code,
        AVG(funding_total) AS inv_2011
       FROM company
       WHERE EXTRACT(YEAR FROM founded_at) = 2011
       GROUP BY country_code),
b AS
(SELECT country_code,
        AVG(funding_total) AS inv_2012
       FROM company
       WHERE EXTRACT(YEAR FROM founded_at) = 2012
       GROUP BY country_code),
c AS
(SELECT country_code,
        AVG(funding_total) AS inv_2013
       FROM company
       WHERE EXTRACT(YEAR FROM founded_at) = 2013
       GROUP BY country_code)
SELECT country_code,
a.inv_2011,
b.inv_2012,
c.inv_2013
FROM a 
JOIN b using(country_code)
JOIN c using(country_code)
ORDER BY a.inv_2011 DESC;

country_code	 inv_2011	   inv_2012	     inv_2013
PER	          4e+06	      41000	        25000
USA	          2.24396e+06	1.20671e+06	  1.09336e+06...
---