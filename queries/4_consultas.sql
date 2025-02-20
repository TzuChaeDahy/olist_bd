-- Total de vendas por vendedor
select s.seller_id, sum(oi.price) as total_sales
from seller s
    join order_item oi on s.seller_id = oi.seller_id
group by
    s.seller_id
order by total_sales desc;

