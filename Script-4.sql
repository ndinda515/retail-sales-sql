select 
    (select COUNT(*) from customers) as total_customers,
    (select COUNT(*) from  orders) as total_orders;

select * from customers limit 5; 
select * from orders limit 5;

--Business Questions
--1. Retrieve all customer records.
select * from customers;

--2. Display customer names, cities, and segments.
select customer_name, city, customer_segment
from customers;

--3. Find customers living in Nairobi.
select customer_id,customer_name
from customers
where city = 'Nairobi';

--4. Find customers registered after January 1, 2025.
select customer_name, registration_date
from customers
where registration_date > '2025-01-01';--the greater sign shows the customer registered after January 1, 2025.

--5. Display all unique customer cities.
select distinct city--distinct removes the duplicates
from customers;

--6. Retrieve the 10 most recent orders.
select order_id,order_date
from orders
order by order_date desc--desc from newest to ordest
limit 10;--show only 10

--7. Find orders with unit prices above KSh 10,000.
select order_id, product_name,quantity,  unit_price
from orders
where unit_price > 10000;

--8. Find customers whose names start with A.
select customer_id, customer_name
from customers
where customer_name like 'A%';

--9. Retrieve orders with quantities between 2 and 5.
select order_id,customer_id, quantity
from orders
where quantity between 2 and 5;--between to include 2 and 5

--10. Find orders paid through M-Pesa.
select order_id
from orders
where payment_method = 'M-Pesa';

-- Section B — Aggregation and grouping (Q11–Q20)
--11. Count all customers.
select count (*) AS total_customers
from customers;

--12. Count all orders.
select count (*) AS total_orders
from orders;

--13. Calculate completed-order revenue.
select
  Round(
        sum(quantity * unit_price * (1 - discount / 100)),
        2
    ) AS completed_revenue
from orders
where order_status = 'Completed';

--14. Calculate the average completed-order value.
select
  Round(
        avg(quantity * unit_price * (1 - discount / 100)),
        2
    ) AS completed_average_revenue
from orders
where order_status = 'Completed';

--15. Find the highest and lowest product prices.
select 
    max(unit_price) as highest_price,
    min (unit_price) as lowest_price
from orders;

--16. Calculate revenue by product category.
select
    product_category,
    round(
        sum(quantity * unit_price * (1 - discount / 100)),
        2
    ) as total_revenue
from orders
where order_status = 'Completed'
group by product_category
order by total_revenue desc;

--17. Count customers by city.
select
    city,
    customer_name,
    count(*) as total_customers
from customers
group by city
order by total_customers desc;

--18. Calculate quantity sold by product.
select 
    product_name,
    count (quantity) as quantity_sold
    from orders
    group by product_name;

--19. Find categories generating more than KSh 100,000 in revenue.
select
    product_category,
    round(
        sum(quantity * unit_price * (1 - discount / 100)),
        2
    ) as total_revenue
from orders
where order_status = 'Completed'
group by product_category
having sum(quantity * unit_price * (1 - discount / 100)) > 100000
order by total_revenue desc;

--20. Calculate the percentage of cancelled orders.
--Tip for Q20:* `COUNT(*) / COUNT(*)` between whole numbers gives 0 in PostgreSQL. Multiply by `100.0`
--first. `COUNT(*) FILTER (WHERE …)` counts only some rows.
select
    round(
        count(*) filter (where order_status = 'Cancelled') * 100.0
        / count(*),
        2
    ) as cancelled_order_percentage
from orders;


--Section C — Joins and customer analytics (Q21–Q28)

--21. Display orders with customer names and cities.
select
    o.order_id,
    o.customer_id,
    c.customer_name,
    c.city
from orders o
inner join customers c
on o.customer_id = c.customer_id;

--22. Calculate total spending by customer.
select
    c.customer_id,
    c.customer_name,
    round(
        sum(o.quantity * o.unit_price * (1 - o.discount / 100)),
        2
    ) as total_spending
from customers c
inner join orders o
on c.customer_id = o.customer_id
where o.order_status = 'Completed'
group by c.customer_id, c.customer_name
order by total_spending desc;

--23. Identify customers who have never ordered.
select c.customer_id, c.customer_name
from customers c
left join orders o
on c.customer_id=o.customer_id
where o.order_id is null;

--24. Find the 10 highest-spending customers.
select
    c.customer_id,
    c.customer_name,
    round(
        sum(o.quantity * o.unit_price * (1 - o.discount / 100)),
        2
    ) as total_spending
from customers c
inner join orders o
on c.customer_id = o.customer_id
where o.order_status = 'Completed'
group by c.customer_id, c.customer_name
order by total_spending desc
limit 10;

--25. Calculate revenue by customer city.
select
    c.city,
    round(
        sum(o.quantity * o.unit_price * (1 - o.discount / 100)),
        2
    ) as total_revenue_by_city
from customers c
inner join orders o
on c.customer_id = o.customer_id
where o.order_status = 'Completed'
group by city
order by total_revenue_by_city desc;

--26. Identify customers with more than five orders.
select c.customer_id, 
       c.customer_name,
       count(*) as total_orders
from customers c
join orders o
on c.customer_id=o.customer_id
group by c.customer_id, c.customer_name
having count(*) >5;

--27. Calculate average customer spending by segment.
select
    customer_id,
    sum(quantity * unit_price * (1 - discount / 100)) as total_spending
from orders
where order_status = 'Completed'
group by customer_id;--it gives total for each customer spending

select
    c.customer_segment,
    round(avg(s.total_spending), 2) as average_spending
from customers c
join (
    select
        customer_id,
        sum(quantity * unit_price * (1 - discount / 100)) as total_spending
    from orders
    where order_status = 'Completed'
    group by customer_id
) s
on c.customer_id = s.customer_id
group by c.customer_segment;

--28. Identify the most popular category among VIP customers.
select
    o.product_category,
    count(*) as total_orders
from orders o
join customers c
on o.customer_id = c.customer_id
where c.customer_segment = 'VIP'
group by o.product_category
order by total_orders desc
limit 1;
--popular by orders


--Section D — Subqueries and CTEs (Q29–Q34)

--29. Find customers spending above the average total spending per purchasing customer.
with customer_spending as (
    select
        customer_id,
        sum(quantity * unit_price) as total_spending
    from orders
    where order_status = 'Completed'
    group by customer_id
)
select *
from customer_spending
where total_spending > (
    select avg(total_spending)
    from customer_spending
);

--30. Find products priced above the overall average unit price.
select
    product_name,
    unit_price
from orders
where unit_price > (
    select avg(unit_price)
    from orders
)
group by product_name, unit_price
order by unit_price desc;

--31. Use a CTE to identify the three highest-revenue months.
with monthly_revenue as (
    select
        date_trunc('month', order_date) as month,            ---group orders
        sum(quantity * unit_price * (1 - discount / 100)) as revenue
    from orders
    where order_status = 'Completed'
    group by date_trunc('month', order_date)
)
select
    month,
    round(revenue, 2) as total_revenue
from monthly_revenue
order by revenue desc
limit 3;

--32. Find customers purchasing from at least three categories.
with customer_categories as (
    select
        customer_id,
        count(distinct product_category) as total_categories---used distinct to count different categories
    from orders
    where order_status='Completed'
    group by customer_id
)
select *
from customer_categories
where total_categories >= 3;


--33. Use a CTE to calculate category revenue, cost, profit, and profit margin.
with category_summary as (
    select
        product_category,
        sum(quantity * unit_price * (1 - discount / 100)) as revenue,
        sum(quantity * cost_price) as cost
    from orders
    where order_status = 'Completed'
    group by product_category
)
select
    product_category,
    round(revenue, 2) as revenue,
    round(cost, 2) as cost,
    round(revenue - cost, 2) as profit,
    round((revenue - cost) * 100.0 / nullif(revenue, 0), 2) as profit_margin
from category_summary;

--34. Find customers whose latest completed order is more than 90 days before the latest order date in
  --the dataset.subtracting dates gives a number of days:
--`DATE '2026-09-30' - DATE '2026-09-01'` is `29`.
   select
    c.customer_id,
    c.customer_name,
    max(o.order_date) as last_purchase_date,
    (select max(order_date) from orders) -
    max(o.order_date) as days_since_purchase
from customers c
join orders o
    on c.customer_id = o.customer_id
where o.order_status = 'Completed'
group by c.customer_id, c.customer_name
having (select max(order_date) from orders) -
       max(o.order_date) > 90
order by days_since_purchase desc;

--35. Rank customers by spending using `RANK()`.
select
    customer_id,
    sum(quantity * unit_price * (1 - discount / 100)) as spending,
    rank() over (order by sum(quantity * unit_price * (1 - discount / 100)) desc) as customer_rank
from orders
where order_status = 'Completed'
group by customer_id;

--36. Number each customer's orders by recency using `ROW_NUMBER()`.
select
    customer_id,
    order_id,
    order_date,
    row_number() over (
        partition by customer_id
        order by order_date desc
    ) as order_number
from orders;

--37. Rank products within categories using `DENSE_RANK()`.
select
    product_category,
    product_name,
    dense_rank() over (
        partition by product_category
        order by sum(quantity * unit_price) desc
    ) as product_rank
from orders
group by product_category, product_name;

--39. Compare monthly revenue using `LAG()`.
select
    date_trunc('month', order_date) as month,
    sum(quantity * unit_price) as revenue,
    lag(sum(quantity * unit_price)) over (order by date_trunc('month', order_date)) as previous_revenue --lag to retrieve
from orders
where order_status = 'Completed'
group by month
order by month;

--40. Calculate month-over-month revenue growth (%).
with monthly_revenue as (
    select
        date_trunc('month', order_date) as month,
        sum(quantity * unit_price) as revenue
    from orders
    where order_status = 'Completed'
    group by month
)
select
    month,
    revenue,
    round((revenue - lag(revenue) over (order by month))
    * 100.0 / lag(revenue) over (order by month), 2) as growth_percentage
from monthly_revenue;

--41. Divide customers into four spending groups using `NTILE(4)`.
select
    customer_id,
    sum(quantity * unit_price) as total_spending,
    ntile(4) over (order by sum(quantity * unit_price) desc) as spending_group
from orders
where order_status = 'Completed'
group by customer_id;

--42. Calculate each category's share of total revenue using window functions.
select
    product_category,
    sum(quantity * unit_price) as revenue,
    round(sum(quantity * unit_price) * 100.0 /
    sum(sum(quantity * unit_price)) over (), 2) as revenue_percentage
from orders
where order_status = 'Completed'
group by product_category;

-- Section F — Advanced business intelligence (Q43–Q46)
--Concepts:* views, PL/pgSQL functions, `CASE`, reporting queries

--43. Create a `monthly_sales_summary` view (month, orders, revenue, cost, profit). Then `SELECT` from it.
create or replace view monthly_sales_summary as
select
    date_trunc('month', order_date) as month,
    count(*) as orders,
    sum(quantity * unit_price) as revenue,
    sum(quantity * cost_price) as cost,
    sum(quantity * (unit_price - cost_price)) as profit
from orders
where order_status = 'Completed'
group by month;

select * from monthly_sales_summary;

--44. Create a PostgreSQL function that returns completed-order revenue for a supplied customer ID. Show
--it working for one customer **and** for an ID that does not exist (it should return 0, not NULL).

create or replace function customer_revenue(p_id integer)
returns numeric
language plpgsql
as $$
declare
    v_result numeric;
begin
    select coalesce(sum(quantity * unit_price), 0)
    into v_result
    from orders
    where customer_id = p_id
    and order_status = 'Completed';

    return v_result;
end;
$$;

select customer_revenue(1);

--45. Segment customers into High, Medium and Low Value. **Explain why you chose your thresholds** — for
--example percentiles, or round KSh amounts based on what the data looks like.
select
    c.customer_id,
    c.customer_name,
    sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)) as total_spent
from customers c
join orders o
    on c.customer_id = o.customer_id
where o.order_status = 'Completed'
group by c.customer_id, c.customer_name
order by total_spent desc;

--46. Produce a management report: the top five customers, top five products, the most profitable
--category, and the lowest-revenue month.

--Top five customers
select customer_id, sum(quantity * unit_price) as spending
from orders
where order_status = 'Completed'
group by customer_id
order by spending desc
limit 5;

--Top five products
select product_name, sum(quantity) as units_sold
from orders
where order_status = 'Completed'
group by product_name
order by units_sold desc
limit 5;

--Most profitable category
select product_category,
       sum(quantity * (unit_price - cost_price)) as profit
from orders
where order_status = 'Completed'
group by product_category
order by profit desc
limit 1;

--Lowest-revenue month
select date_trunc('month', order_date) as month,
       sum(quantity * unit_price) as revenue
from orders
where order_status = 'Completed'
group by month
order by revenue
limit 1;

select
    customer_id,
    customer_name,
    total_spent,
    case
        when total_spent >= 300000 then 'High Value'
        when total_spent >= 100000 then 'Medium Value'
        else 'Low Value'
    end as customer_segment
from (
    select
        c.customer_id,
        c.customer_name,
        sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)) as total_spent
    from customers c
    join orders o
        on c.customer_id = o.customer_id
    where o.order_status = 'Completed'
    group by c.customer_id, c.customer_name
) as customer_spending
order by total_spent desc;




















