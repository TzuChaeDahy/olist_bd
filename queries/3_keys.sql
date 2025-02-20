-- Active: 1739970650374@@127.0.0.1@3306@olist

-- Remove duplicate keys (product)
WITH
    CTE AS (
        SELECT product_id, ROW_NUMBER() OVER (
                PARTITION BY
                    product_id
                ORDER BY product_id
            ) AS row_num
        FROM product
    )
DELETE FROM product
WHERE
    product_id IN (
        SELECT product_id
        FROM CTE
        WHERE
            row_num > 1
    );

-- Create product primary key
alter table olist.product
add constraint pk_product primary key (product_id);

-- Remove duplicate keys (customer)
WITH
    CTE AS (
        SELECT customer_id, ROW_NUMBER() OVER (
                PARTITION BY
                    customer_id
                ORDER BY customer_id
            ) AS row_num
        FROM customer
    )
DELETE FROM customer
WHERE
    customer_id IN (
        SELECT customer_id
        FROM CTE
        WHERE
            row_num > 1
    );

-- Create customer primary key
alter table customer
add constraint pk_customer primary key (customer_id);

-- Remove duplicate keys (order)
WITH
    CTE AS (
        SELECT order_id, ROW_NUMBER() OVER (
                PARTITION BY
                    order_id
                ORDER BY order_id
            ) AS row_num
        FROM olist.order
    )
DELETE FROM olist.order
WHERE
    order_id IN (
        SELECT order_id
        FROM CTE
        WHERE
            row_num > 1
    );

-- Create order primary key
alter table olist.order
add constraint pk_order primary key (order_id);

-- Remove duplicate keys (seller)
WITH
    CTE AS (
        SELECT seller_id, ROW_NUMBER() OVER (
                PARTITION BY
                    seller_id
                ORDER BY seller_id
            ) AS row_num
        FROM seller
    )
DELETE FROM seller
WHERE
    seller_id IN (
        SELECT seller_id
        FROM CTE
        WHERE
            row_num > 1
    );

-- Create seller primary key
alter table seller add constraint pk_seller primary key (seller_id);

-- Remove duplicate keys (order_review)
WITH
    CTE AS (
        SELECT review_id, ROW_NUMBER() OVER (
                PARTITION BY
                    review_id
                ORDER BY review_id
            ) AS row_num
        FROM order_review
    )
DELETE FROM order_review
WHERE
    review_id IN (
        SELECT review_id
        FROM CTE
        WHERE
            row_num > 1
    );

-- Create order_review primary key
alter table order_review
add constraint pk_order_review primary key (review_id);

-- Remove duplicate keys (order_payment)
WITH
    CTE AS (
        SELECT
            order_id,
            payment_sequential,
            ROW_NUMBER() OVER (
                PARTITION BY
                    order_id,
                    payment_sequential
                ORDER BY order_id, payment_sequential
            ) AS row_num
        FROM order_payment
    )
DELETE FROM order_payment
WHERE (order_id, payment_sequential) IN (
        SELECT order_id, payment_sequential
        FROM CTE
        WHERE
            row_num > 1
    );

-- Create order_payment primary key
alter table order_payment
add constraint pk_order_payment primary key (order_id, payment_sequential);

-- Remove duplicate keys (order_item)
WITH
    CTE AS (
        SELECT
            order_id,
            order_item_id,
            product_id,
            ROW_NUMBER() OVER (
                PARTITION BY
                    order_id,
                    order_item_id,
                    product_id
                ORDER BY
                    order_id,
                    order_item_id,
                    product_id
            ) AS row_num
        FROM order_item
    )
DELETE FROM order_item
WHERE (
        order_id,
        order_item_id,
        product_id
    ) IN (
        SELECT
            order_id,
            order_item_id,
            product_id
        FROM CTE
        WHERE
            row_num > 1
    );

-- Create order_item primary key
alter table order_item
add constraint pk_order_item primary key (
    order_id,
    order_item_id,
    product_id
);

-- Remove duplicate keys (geo_location)
WITH
    CTE AS (
        SELECT
            geolocation_zip_code_prefix,
            geolocation_city,
            geolocation_state,
            ROW_NUMBER() OVER (
                PARTITION BY
                    geolocation_zip_code_prefix,
                    geolocation_city,
                    geolocation_state
                ORDER BY
                    geolocation_zip_code_prefix,
                    geolocation_city,
                    geolocation_state
            ) AS row_num
        FROM geo_location
    )
DELETE FROM geo_location
WHERE (
        geolocation_zip_code_prefix,
        geolocation_city,
        geolocation_state
    ) IN (
        SELECT
            geolocation_zip_code_prefix,
            geolocation_city,
            geolocation_state
        FROM CTE
        WHERE
            row_num > 1
    );

-- Create geo_location primary key
alter table geo_location
add constraint pk_geo_location primary key (
    geolocation_zip_code_prefix,
    geolocation_city,
    geolocation_state
);

-- Create customer foreign keys
alter table customer
add constraint fk_customer_geolocation_zip_code foreign key (
    customer_zip_code_prefix,
    customer_city,
    customer_state
) references geo_location (
    geolocation_zip_code_prefix,
    geolocation_city,
    geolocation_state
),
add constraint un_customer_unique_id unique (customer_unique_id);

-- Create seller foreign keys
alter table seller
add constraint fk_seller_geolocation_zip_code foreign key (
    seller_zip_code_prefix,
    seller_city,
    seller_state
) references geo_location (
    geolocation_zip_code_prefix,
    geolocation_city,
    geolocation_state
);

-- Create order_review foreign keys
alter table order_review
add constraint fk_order_review_order_id foreign key (order_id) references olist.order (order_id);

-- Create order_payment foreign keys
alter table order_payment
add constraint fk_order_payment_order_id foreign key (order_id) references olist.order (order_id);

-- Create order foreign keys
alter table olist.order
add constraint fk_order_customer_id foreign key (customer_id) references customer (customer_id);

-- Create order_item foreign keys
alter table order_item
add constraint fk_order_item_order_id foreign key (order_id) references olist.order (order_id),
add constraint fk_order_item_product_id foreign key (product_id) references product (product_id),
add constraint fk_order_item_seller_id foreign key (seller_id) references seller (seller_id);