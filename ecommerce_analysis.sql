select * from sales;

ALTER TABLE sales 
ALTER COLUMN order_id TYPE TEXT; --змінює тип даних 

TRUNCATE TABLE sales; -- Видалити дані залишаючи колонки

/* Завдання 1 Завдання 1: Класифікація клієнтів
Бізнесу важливо знати, хто приносить гроші.
Що зробити: Порахуй для кожного клієнта: загальну суму витрат, кількість замовлень та середній чек.
Додай логіку: Хто витратив більше $5000 як 'Top Spender', від $1000 до $5000 — 'Medium', і решту — 'Small'.
Сортування: Вивести спочатку найбагатших.*/

with table_1 as (
	select 
		customer_id, order_id,
		sum(quantity * price) as over_sum
from sales
group by customer_id, order_id
)
select customer_id, over_sum, 
		count(order_id)over(partition by customer_id) as count_orders,
		round(avg(over_sum)over(partition by customer_id), 2) as avg_check, 
	case
		when over_sum > 5000 then 'Top Spender'
		when over_sum between 1000 and 5000 then 'Medium'
		else 'Small'
	end as status_cost
from table_1
order by over_sum desc;


/* Завдання 2 Завдання 2: Аналіз улюблених категорій (The Best Seller)
Що зробити: Знайди, яка категорія товарів принесла найбільший прибуток.
Деталізація: Для кожної категорії покажи загальну кількість проданих одиниць товару та кількість унікальних клієнтів, які її купували.
*/
Select category, sum(quantity * price) as total_amount, sum(quantity) as total_quantity, count(distinct customer_id) as unique_customer
from sales
group by category
order by sum(quantity * price) desc;

/*Завдання 3 Аналіз "Повернень" та Лояльності
Що зробити: Для кожного клієнта вивести список його замовлень, відсортованих за датою.
Додати колонку days_since_last_order, яка рахує, скільки днів пройшло між поточним та попереднім замовленням клієнта.
*/
with table1 as(
select 
	customer_id, 
	order_id, order_date, 
	lag(order_date)over(partition by customer_id order by order_date) as previous_order
from sales
group by order_date,customer_id, order_id
)
select 
	customer_id, 
	order_id, 
	order_date, 
	previous_order,
	order_date - previous_order as days_since_last_order
from table1
group by customer_id, order_id, order_date, previous_order
order by customer_id, order_date;

/* Завдання 4 Ефективність каналів продажу та пристроїв
Що зробити: Порахуй середній чек залежно від пристрою та каналу.
Питання: Чи правда, що замовлення з Desktop дорожчі, ніж з Mobile?
*/
WITH base_metrics AS (
    SELECT 
        channel,
        device_type,
        price * quantity AS line_total,
        AVG(price * quantity) OVER(PARTITION BY channel) AS avg_channel,
        AVG(price * quantity) OVER(PARTITION BY device_type) AS avg_device
    FROM sales
)
SELECT 
    channel, 
    device_type,
    ROUND(AVG(line_total), 2) AS current_segment_avg,
    ROUND(AVG(avg_channel), 2) AS general_channel_avg,
    ROUND(AVG(avg_device), 2) AS general_device_avg
FROM base_metrics
GROUP BY channel, device_type
ORDER BY channel, current_segment_avg DESC;