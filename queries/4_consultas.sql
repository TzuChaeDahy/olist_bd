-- Total de vendas por vendedor
create procedure total_sales_per_seller()
begin
    select s.seller_id, sum(oi.price) as total_sales
    from seller s
        join order_item oi on s.seller_id = oi.seller_id
    group by
        s.seller_id
    order by total_sales desc;
end;

-- Clientes que mais compraram na plataforma (top 10), por período
create procedure top_clients_by_period(startDate date, endDate date)
begin
    select c.customer_id, sum(oi.price) as total_sales
    from
        customer c
        join olist.order on olist.order.customer_id = c.customer_id
        join order_item oi on olist.order.order_id = oi.order_id
    where
        olist.order.order_purchase_timestamp between startDate and endDate
    group by
        c.customer_id
    order by total_sales desc
    limit 10;
end;

-- Calcular a média das avaliações dos vendedores
create procedure average_review_score_of_seller()
begin
    select s.seller_id, avg(orv.review_score) as average_review_score
    from
        seller s
        join order_item oi on oi.seller_id = s.seller_id
        join olist.order o on o.order_id = oi.order_id
        join order_review orv on orv.order_id = o.order_id
    group by
        s.seller_id
    order by average_review_score desc;
end;

-- Consulta que retorna todos os pedidos realizados entre duas datas
create procedure orders_between_dates(startDate date, endDate date)
begin
    select o.order_id, o.customer_id, o.order_status, sum(oi.price) as total_price
    from olist.`order` o
        join order_item oi on o.order_id = oi.order_id
    where
        o.order_purchase_timestamp between startDate and endDate
    group by
        o.order_id,
        o.customer_id,
        o.order_status
    order by total_price desc;
end;

-- Produtos mais vendidos no período (Top 5)
create procedure top_products_by_period(startDate date, endDate date)
begin
    select oi.product_id, count(oi.product_id) as number_of_sales
    from order_item oi
        join olist.`order` o on o.order_id = oi.order_id
    where
        o.order_purchase_timestamp between startDate and endDate
    group by
       oi.product_id
    order by number_of_sales desc
    limit 5;
end;

-- Pedidos com mais atrasos por período (Top 10)
create procedure late_orders_by_period(startDate date, endDate date)
begin
    select o.order_id, datediff(
            o.order_delivered_customer_date, o.order_estimated_delivery_date
        ) as days_late
    from olist.`order` o
    where
        o.order_purchase_timestamp between startDate and endDate
        and o.order_delivered_customer_date IS NOT NULL
        and datediff(
            o.order_delivered_customer_date,
            o.order_estimated_delivery_date
        ) > 0
    order by days_late desc
    limit 10;
end;

-- Clientes com o maior valor de compra (Top 10)
create procedure top_clients_by_total_purchase()
begin
    select o.customer_id, sum(oi.price) as total_purchase
    from olist.`order` o
        join order_item oi on oi.order_id = o.order_id
    group by
        o.customer_id
    order by total_purchase desc
    limit 10;
end;

-- Tempo Médio de Entrega por Estado
create procedure average_delivery_time_by_state()
begin
    select c.customer_state, avg(
            datediff(
                o.order_delivered_customer_date, o.order_purchase_timestamp
            )
        ) as average_delivery_time
    from customer c
        join olist.`order` o on o.customer_id = c.customer_id
    where
        o.order_delivered_customer_date IS NOT NULL
    group by
        c.customer_state
    order by average_delivery_time desc;
end;

------------------------------------ COMO CHAMAR AS PROCEDURES ------------------------------------
call total_sales_per_seller ();

call top_clients_by_period ('2025-02-25', '2025-03-08');

call average_review_score_of_seller ();

call orders_between_dates ('2025-02-25', '2025-03-08');

call top_products_by_period ('2025-02-25', '2025-03-08');

call late_orders_by_period ('2025-02-25', '2025-03-17');

call top_clients_by_total_purchase ();

call average_delivery_time_by_state ();