-- Active: 1739934751226@@127.0.0.1@3306@olist

-- Remove duplicate keys (product)
alter table product
add constraint pk_product primary key (product_id);

-- Remove duplicate keys (customer)
alter table customer
add constraint pk_customer primary key (customer_id);

-- Remove duplicate keys (order)
alter table order
add constraint pk_order primary key (order_id);

-- Remove duplicate keys (seller)
alter table seller
add constraint pk_seller primary key (seller_id);

-- Remove duplicate keys (order_review)
alter table order_review
add constraint pk_order_review primary key (review_id);

-- Remove duplicate keys (order_payment)
alter table order_payment
add constraint pk_order_payment primary key (order_id);

-- Remove duplicate keys (order_item)
alter table order_item
add constraint pk_order_item primary key (order_id, order_item_id, product_id);

-- Remove duplicate keys (geo_location)
alter table geo_location
add constraint pk_geo_location primary key (geo_location_zip_code_prefix);