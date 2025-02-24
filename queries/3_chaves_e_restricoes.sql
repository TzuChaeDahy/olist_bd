-- Active: 1740328147338@@127.0.0.1@3306@olist
------------------------------------ PRIMARY KEYS ------------------------------------
-- Create product primary key
alter table olist.product
add constraint pk_product primary key (product_id);

-- Create customer primary key
alter table customer
add constraint pk_customer primary key (customer_id);

-- Create order primary key
alter table olist.order
add constraint pk_order primary key (order_id);

-- Create seller primary key
alter table seller add constraint pk_seller primary key (seller_id);

-- Create order_review primary key
alter table order_review
add constraint pk_order_review primary key (review_id);

-- Create order_payment primary key
alter table order_payment
add constraint pk_order_payment primary key (order_id, payment_sequential);

-- Create order_item primary key
alter table order_item
add constraint pk_order_item primary key (
    order_id,
    order_item_id,
    product_id
);

-- Create geo_location primary key
alter table geo_location
add constraint pk_geo_location primary key (
    geolocation_zip_code_prefix,
    geolocation_city,
    geolocation_state
);

------------------------------------ FOREIGN KEYS ------------------------------------
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
);

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