CREATE INDEX IF NOT EXISTS orders_id_index ON orders (id);
CREATE INDEX IF NOT EXISTS order_product_index ON order_product (order_id, product_id);
CREATE INDEX IF NOT EXISTS product_id ON product (id);
