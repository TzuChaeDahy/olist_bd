# ADMINISTRAÇÃO E PROJETO DE BANCO DE DADOS

**DISCENTE:** VINICIUS ALVES PACHECO  
**TURMA:** 4º PERÍODO

## Restauração do Banco

Para restaurar o banco, eu subi ele em um container Docker (MySQL), copiei o arquivo `olist.sql` para o docker com o seguinte comando:

```bash
docker cp .\olist.sql olist_mysql:/backup.sql
```

Depois, rodei o seguinte código dentro do terminal do MySQL:

```sql
mysql -u root -p olist < ./backup.sql
```

## Perfil de B.I. e suas Permissões

Para criar o perfil de Business Intelligence, eu rodei o seguinte código:

```sql
create user 'user_bi' @'%' identified by 'bipassword'
```

E para dar as suas devidas permissões, foi necessário executar os seguintes comandos:

```sql
grant select on olist.order to 'user_bi' @'%';

grant select on olist.product to 'user_bi' @'%';

grant select on olist.customer to 'user_bi' @'%';

grant select on olist.order_payment to 'user_bi' @'%';

grant select on olist.seller to 'user_bi' @'%';

grant select on olist.geo_location to 'user_bi' @'%';

flush privileges;
```

## Remoção de duplicatas

Antes de criar as chaves e as restrições, é necessário realizar uma limpeza nos dados do banco para remover duplicações.
Essas alterações serão feitas rodando os seguintes códigos:

```sql

```

## Chaves e Restrições

### Primary Keys

Para criar as primary keys, rodei o seguinte código:

```sql
-- product
alter table olist.product
add constraint pk_product primary key (product_id);

-- customer
alter table customer
add constraint pk_customer primary key (customer_id);

-- order
alter table olist.order
add constraint pk_order primary key (order_id);

-- seller
alter table seller add constraint pk_seller primary key (seller_id);

-- order_review
alter table order_review
add constraint pk_order_review primary key (review_id);

-- order_payment
alter table order_payment
add constraint pk_order_payment primary key (order_id, payment_sequential);

-- order_item
alter table order_item
add constraint pk_order_item primary key (
    order_id,
    order_item_id,
    product_id
);

-- geo_location
alter table geo_location
add constraint pk_geo_location primary key (
    geolocation_zip_code_prefix,
    geolocation_city,
    geolocation_state
);
```

### Foreign Keys

Já, para criar as foreign keys, executeio código a seguir:

```sql
-- customer
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

-- seller
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

-- order_review
alter table order_review
add constraint fk_order_review_order_id foreign key (order_id) references olist.order (order_id);

-- order_payment
alter table order_payment
add constraint fk_order_payment_order_id foreign key (order_id) references olist.order (order_id);

-- order
alter table olist.order
add constraint fk_order_customer_id foreign key (customer_id) references customer (customer_id);

-- order_item
alter table order_item
add constraint fk_order_item_order_id foreign key (order_id) references olist.order (order_id),
add constraint fk_order_item_product_id foreign key (product_id) references product (product_id),
add constraint fk_order_item_seller_id foreign key (seller_id) references seller (seller_id);
```

### Outras Restrições

Por fim, adicionei mais algumas últimas restrições:

```sql
-- customer
alter table customer
add constraint un_customer_unique_id unique (customer_unique_id);
```

## Consultas Avançadas

### Exibir o Total de Vendas por Vendedor

```sql
create procedure total_sales_per_seller()
begin
    select s.seller_id, sum(oi.price) as total_sales
    from seller s
        join order_item oi on s.seller_id = oi.seller_id
    group by
        s.seller_id
    order by total_sales desc;
end;
```

### Top 10 Clientes que Mais Compraram na Plataforma por Período

```sql
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
```

### Média das Avaliações por Vendedor

```sql
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
```

### Pedidos Realizados entre Duas Datas

```sql
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
```

### Top 5 Produtos Mais Vendidos no Período

```sql
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
```

### Top 10 Pedidos com Mais Atrasos por Período

```sql
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
```

### Top 10 Clientes com Maior Valor em Compras

```sql
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
```

### Tempo Médio de Entrega por Estado

```sql
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
```

## Otimização de Consultas

### Exibir o Total de Vendas por Vendedor

A query precisou sim de otimização, para evitar um **Nested Loop Join**, e ficou assim:

```sql
SELECT oi.seller_id, SUM(oi.price) AS total_sales
FROM order_item oi
GROUP BY oi.seller_id
ORDER BY total_sales DESC;
```

### Top 10 Clientes que Mais Compraram na Plataforma por Período

Também precisou de otimização para evitar um **Nested Loop Join**:

```sql
SELECT o.customer_id, SUM(oi.price) AS total_sales
FROM olist.order o
JOIN order_item oi ON o.order_id = oi.order_id
WHERE o.order_purchase_timestamp BETWEEN startDate AND endDate
GROUP BY o.customer_id
ORDER BY total_sales DESC
LIMIT 10;
```

### Média das Avaliações por Vendedor

Essa também precisa de otimização devido ao uso de Nested Loops e Table Scan nas tabelas, o que gera um custo alto.

```sql
SELECT s.seller_id, AVG(orv.review_score) AS average_review_score
FROM seller s
JOIN order_item oi ON oi.seller_id = s.seller_id
JOIN olist.order o ON o.order_id = oi.order_id
JOIN order_review orv ON orv.order_id = o.order_id
GROUP BY s.seller_id
ORDER BY average_review_score DESC;
```

Também são recomendadas as aplicações de alguns índices, como:

```sql
CREATE INDEX idx_order_item_seller ON order_item (seller_id, order_id);
CREATE INDEX idx_order_order_id ON olist.order (order_id);
CREATE INDEX idx_order_review_order_id ON order_review (order_id);
```

### Pedidos Realizados entre Duas Datas

Essa query precisa de otimização. O Table Scan na tabela order e o uso de Nested Loops estão causando um alto custo de execução.

```sql
SELECT o.order_id, o.customer_id, o.order_status, SUM(oi.price) AS total_price
FROM olist.`order` o
JOIN order_item oi ON o.order_id = oi.order_id
WHERE o.order_purchase_timestamp BETWEEN startDate AND endDate
GROUP BY o.order_id, o.customer_id, o.order_status
ORDER BY total_price DESC;
```

Também são recomendadas as aplicações de alguns índices, como:

```sql
CREATE INDEX idx_order_purchase_timestamp ON olist.`order` (order_purchase_timestamp, order_id);
CREATE INDEX idx_order_item_order_id ON order_item (order_id);
```

### Top 5 Produtos Mais Vendidos no Período

Essa query não necessitou de otimizações!

### Top 10 Pedidos com Mais Atrasos por Período

Para otimizar, seria possível adicionar índices, como:

```sql
CREATE INDEX idx_order_purchase_delivered_estimated ON olist.`order` (order_purchase_timestamp, order_delivered_customer_date, order_estimated_delivery_date);
```

### Top 10 Clientes com Maior Valor em Compras

Essa query não necessitou de otimizações!

### Tempo Médio de Entrega por Estado

Para otimizar, seria possível adicionar índices, como:

```sql
CREATE INDEX idx_customer_id_state ON customer (customer_id, customer_state);
CREATE INDEX idx_order_delivered_customer_date ON olist.`order` (order_delivered_customer_date, customer_id, order_purchase_timestamp);

```

## Auditoria

### Abordagem

A melhor forma de rastrear alterações no banco de dados é utilizando triggers para capturar eventos DML (INSERT, UPDATE, DELETE) e armazenar essas informações em tabelas de auditoria.

**Além disso, podemos incluir:**

- Colunas de versionamento (exemplo: created_at, updated_at, deleted_at).
- Uso de logs de auditoria (audit_log) para capturar ações dos usuários.
- Soft delete (mantendo registros em vez de removê-los fisicamente).

### Exemplos

**Criação de uma Tabela de Auditoria**

```sql
CREATE TABLE product_audit (
    audit_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id VARCHAR(36),
    user_action VARCHAR(10), -- INSERT, UPDATE, DELETE
    modified_by VARCHAR(50), -- usuário que fez a mudança
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_product_name VARCHAR(50),
    new_product_name VARCHAR(50),
    old_price BIGINT,
    new_price BIGINT
);
```

**Triggers de Auditoria**

Esse TRIGGER capturará atualizações na tabela product.

```sql
CREATE TRIGGER product_update_audit
AFTER UPDATE ON product
FOR EACH ROW
BEGIN
    INSERT INTO product_audit (
        product_id,
        user_action,
        modified_by,
        modified_at,
        old_product_name,
        new_product_name,
        old_price,
        new_price
    )
    VALUES (
        OLD.product_id,
        'UPDATE',
        CURRENT_USER(),
        NOW(),
        OLD.product_category_name,
        NEW.product_category_name,
        OLD.product_weight_g,
        NEW.product_weight_g
    );
END$$
```

**Soft Delete**
Para evitar perda de dados, podemos adicionar uma coluna `deleted_at`:

```sql
ALTER TABLE product ADD COLUMN deleted_at TIMESTAMP NULL;

```

Em vez de deletar, apenas marcamos o registro como excluído:

```sql
UPDATE product SET deleted_at = NOW() WHERE product_id = '123';

```

**Por quê?**

- Auditoria: O product_audit armazena um histórico detalhado de cada alteração.
- Rastreabilidade: Podemos saber quem alterou um dado e quando.
- Integridade: O soft delete impede remoção acidental de dados.
- Segurança: Os registros de auditoria garantem conformidade com boas práticas de governança de dados.

## Bônus - Consultas e informações extras

Pra verificar a duplicidade de alguns dados, usei uma expressão genérica pra cada umas das tabelas, parecida com a seguinte:

```sql
select col1, col2, col3, COUNT(*) AS total
from minha_tabela
group by col1, col2, col3
having count(*) > 1;
```

Também foi necessário aplicar algumas regras a alguns dados que não possuiam correspondência, como no seguinte caso, onde alguns registros de `customer` não tinham dados em `geo_location`:

```sql
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
```
