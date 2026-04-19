#Задача 1
#клиенты у которых есть операции в каждом месяце 

SELECT 
    ID_client,
    COUNT(DISTINCT EXTRACT(YEAR_MONTH FROM date_new)) AS months_cnt
FROM transactions
WHERE date_new >= '2015-06-01'
  AND date_new < '2016-06-01'
GROUP BY ID_client
ORDER BY months_cnt DESC;

#поситать по этим клиентам средний чек, среднюю сумму покупок за месяц, количество операции и разбивка по месяцам 

SELECT 
    ID_client,
    AVG(Sum_payment) AS avg_check_period,
    SUM(Sum_payment) / 12 AS avg_monthly_spend,
    COUNT(*) AS operations_count,
    EXTRACT(YEAR_MONTH FROM date_new) AS ym,
    SUM(Sum_payment) AS month_sum,
    COUNT(*) AS month_operations

FROM transactions
WHERE date_new >= '2015-06-01'
  AND date_new < '2016-06-01'
  AND ID_client IN (
        SELECT ID_client
        FROM transactions
        GROUP BY ID_client
        HAVING COUNT(DISTINCT EXTRACT(YEAR_MONTH FROM date_new)) = 12
  )
GROUP BY ID_client, EXTRACT(YEAR_MONTH FROM date_new)
ORDER BY ID_client; 

#Задача 2 
#средняя сумма чека в месяц;
#среднее количество операций в месяц;
#среднее количество клиентов, которые совершали операции;


SELECT 
    EXTRACT(YEAR_MONTH FROM date_new) AS y_m,

    AVG(Sum_payment) AS avg_check_month,
    COUNT(*) AS operations_month,
    COUNT(DISTINCT ID_client) AS clients_month,

    SUM(Sum_payment) AS total_amount

FROM transactions
WHERE date_new >= '2015-06-01'
  AND date_new < '2016-06-01'
GROUP BY EXTRACT(YEAR_MONTH FROM date_new)
ORDER BY ym;

#долю от общего количества операций за год и долю в месяц от общей суммы операций;
#вывести % соотношение M/F/NA в каждом месяце с их долей затрат;

SELECT 
    EXTRACT(YEAR_MONTH FROM t.date_new) AS ym,
    COALESCE(c.Gender, 'NA') AS gender,

    SUM(t.Sum_payment) AS total_spend,
    COUNT(*) AS operations

FROM transactions t
LEFT JOIN customers c 
    ON t.ID_client = c.Id_client

WHERE t.date_new >= '2015-06-01'
  AND t.date_new < '2016-06-01'

GROUP BY ym, gender;

#3 возрастные группы клиентов с шагом 10 лет и отдельно клиентов,
 #у которых нет данной информации, 
 #с параметрами сумма и количество операций за весь период, 
 #и поквартально - средние показатели и %.
 
SELECT 
    CONCAT(YEAR(t.date_new), '-Q', QUARTER(t.date_new)) AS quarter,

    CASE 
        WHEN c.Age IS NULL THEN 'NA'
        ELSE FLOOR(c.Age / 10) * 10
    END AS age_group,

    SUM(t.Sum_payment) AS total_amount,
    COUNT(*) AS operations_count,
    COUNT(DISTINCT t.ID_client) AS clients_count,

    -- 📌 средний чек
    AVG(t.Sum_payment) AS avg_check,

    -- 📌 среднее число операций на клиента в квартале
    COUNT(*) / COUNT(DISTINCT t.ID_client) AS avg_ops_per_client

FROM transactions t
LEFT JOIN customers c 
    ON t.ID_client = c.Id_client

WHERE t.date_new >= '2015-06-01'
  AND t.date_new < '2016-06-01'

GROUP BY quarter, age_group
ORDER BY quarter, age_group;