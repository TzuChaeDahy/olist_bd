create user 'user_bi' @'%' identified by 'bipassword'

grant select on olist.order to 'user_bi' @'%';

grant select on olist.product to 'user_bi' @'%';

grant select on olist.customer to 'user_bi' @'%';

grant select on olist.order_payment to 'user_bi' @'%';

grant select on olist.seller to 'user_bi' @'%';

grant select on olist.geo_location to 'user_bi' @'%';

flush privileges;