drop index if exists orders_id_index;
drop index if exists order_product_index;
drop index if exists product_id;

CREATE INDEX orders_id_index ON orders (id);
CREATE INDEX order_product_index ON order_product (order_id, product_id);
CREATE INDEX product_id ON product (id);
