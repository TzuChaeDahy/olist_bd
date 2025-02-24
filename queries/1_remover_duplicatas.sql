-- Active: 1740328147338@@127.0.0.1@3306@olist
-- active: 1739970650374@@127.0.0.1@3306@olist
-- product
create temporary table `temp_product` (
    `product_id` varchar(36) default null,
    `product_category_name` varchar(50) default null,
    `product_name_lenght` bigint default null,
    `product_description_lenght` bigint default null,
    `product_photos_qty` bigint default null,
    `product_weight_g` bigint default null,
    `product_length_cm` bigint default null,
    `product_height_cm` bigint default null,
    `product_width_cm` bigint default null
);

insert into
    temp_product (
        product_id,
        product_category_name,
        product_name_lenght,
        product_description_lenght,
        product_photos_qty,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm
    )
select
    product_id,
    product_category_name,
    product_name_lenght,
    product_description_lenght,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
from (
        select
            product_id, product_category_name, product_name_lenght, product_description_lenght, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm, row_number() over (
                partition by
                    product_id
                order by product_id asc
            ) as rn
        from product
    ) subquery
where
    rn = 1;

delete from product;

insert into product select * from temp_product;

-- customer
create temporary table `temp_customer` (
    `customer_id` varchar(36) default null,
    `customer_unique_id` varchar(36) default null,
    `customer_zip_code_prefix` bigint default null,
    `customer_city` varchar(32) default null,
    `customer_state` varchar(2) default null
);

insert into
    temp_customer (
        customer_id,
        customer_unique_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state
    )
select
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
from (
        select
            customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state, row_number() over (
                partition by
                    customer_id
                order by customer_id asc
            ) as rn
        from customer
    ) subquery
where
    rn = 1;

delete from customer;

insert into customer select * from temp_customer;

insert into
    geo_location (
        geolocation_zip_code_prefix,
        geolocation_city,
        geolocation_state
    )
select distinct
    c.customer_zip_code_prefix,
    c.customer_city,
    c.customer_state
from
    customer c
    left join geo_location g on c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
    and c.customer_city = g.geolocation_city
    and c.customer_state = g.geolocation_state
where
    g.geolocation_zip_code_prefix is null;

-- order
create temporary table `temp_order` (
    `order_id` varchar(32) default null,
    `customer_id` varchar(36) default null,
    `order_status` varchar(25) default null,
    `order_purchase_timestamp` datetime default null,
    `order_approved_at` datetime default null,
    `order_delivered_carrier_date` datetime default null,
    `order_delivered_customer_date` datetime default null,
    `order_estimated_delivery_date` datetime default null
);

insert into
    temp_order (
        order_id,
        customer_id,
        order_status,
        order_purchase_timestamp,
        order_approved_at,
        order_delivered_carrier_date,
        order_delivered_customer_date,
        order_estimated_delivery_date
    )
select
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
from (
        select
            order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date, row_number() over (
                partition by
                    order_id
                order by order_id asc
            ) as rn
        from `order`
    ) subquery
where
    rn = 1;

delete from `order`;

insert into `order` select * from temp_order;

-- seller
create temporary table `temp_seller` (
    `seller_id` varchar(36) default null,
    `seller_zip_code_prefix` bigint default null,
    `seller_city` varchar(50) default null,
    `seller_state` varchar(2) default null
);

insert into
    temp_seller (
        seller_id,
        seller_zip_code_prefix,
        seller_city,
        seller_state
    )
select
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
from (
        select
            seller_id, seller_zip_code_prefix, seller_city, seller_state, row_number() over (
                partition by
                    seller_id
                order by seller_id asc
            ) as rn
        from seller
    ) subquery
where
    rn = 1;

delete from seller;

insert into seller select * from temp_seller;

insert into
    geo_location (
        geolocation_zip_code_prefix,
        geolocation_city,
        geolocation_state
    )
select distinct
    s.seller_zip_code_prefix,
    s.seller_city,
    s.seller_state
from
    seller s
    left join geo_location g on s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
    and s.seller_city = g.geolocation_city
    and s.seller_state = g.geolocation_state
where
    g.geolocation_zip_code_prefix is null;

-- order_review
create temporary table `temp_order_review` (
    `review_id` varchar(36) default null,
    `order_id` varchar(36) default null,
    `review_score` bigint default null,
    `review_comment_title` varchar(90) default null,
    `review_comment_message` varchar(255) default null,
    `review_creation_date` datetime default null,
    `review_answer_timestamp` datetime default null
);

insert into
    temp_order_review (
        review_id,
        order_id,
        review_score,
        review_comment_title,
        review_comment_message,
        review_creation_date,
        review_answer_timestamp
    )
select
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
from (
        select
            review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp, row_number() over (
                partition by
                    review_id
                order by review_id asc
            ) as rn
        from order_review
    ) subquery
where
    rn = 1;

delete from order_review;

insert into order_review select * from temp_order_review;

-- order_payment
create temporary table `temp_order_payment` (
    `order_id` varchar(36) default null,
    `payment_sequential` bigint default null,
    `payment_type` varchar(11) default null,
    `payment_installments` bigint default null,
    `payment_value` bigint default null
);

insert into
    temp_order_payment (
        order_id,
        payment_sequential,
        payment_type,
        payment_installments,
        payment_value
    )
select
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
from (
        select
            order_id, payment_sequential, payment_type, payment_installments, payment_value, row_number() over (
                partition by
                    order_id, payment_sequential
                order by order_id, payment_sequential asc
            ) as rn
        from order_payment
    ) subquery
where
    rn = 1;

delete from order_payment;

insert into order_payment select * from temp_order_payment;

-- order_item
create temporary table `temp_order_item` (
    `order_id` varchar(36) default null,
    `order_item_id` bigint default null,
    `product_id` varchar(36) default null,
    `seller_id` varchar(36) default null,
    `shipping_limit_date` datetime default null,
    `price` bigint default null,
    `freight_value` bigint default null
);

insert into
    temp_order_item (
        order_id,
        order_item_id,
        product_id,
        seller_id,
        shipping_limit_date,
        price,
        freight_value
    )
select
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
from (
        select
            order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value, row_number() over (
                partition by
                    order_id, order_item_id, product_id
                order by
                    order_id, order_item_id, product_id asc
            ) as rn
        from order_item
    ) subquery
where
    rn = 1;

delete from order_item;

insert into order_item select * from temp_order_item;

-- geo_location
create temporary table `temp_geo_location` (
    `geolocation_zip_code_prefix` bigint default null,
    `geolocation_lat` bigint default null,
    `geolocation_lng` bigint default null,
    `geolocation_city` varchar(90) default null,
    `geolocation_state` varchar(2) default null
);

insert into
    temp_geo_location (
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng,
        geolocation_city,
        geolocation_state
    )
select
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
from (
        select
            geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state, row_number() over (
                partition by
                    geolocation_zip_code_prefix, geolocation_city, geolocation_state
                order by
                    geolocation_zip_code_prefix, geolocation_city, geolocation_state asc
            ) as rn
        from geo_location
    ) subquery
where
    rn = 1;

delete from geo_location;

insert into geo_location select * from temp_geo_location;

-- excluindo tabelas temporárias
drop table temp_customer;

drop table temp_product;

drop table temp_seller;

drop table temp_order;

drop table temp_order_review;

drop table temp_order_payment;

drop table temp_order_item;

drop table temp_geo_location;