-- StoreDB - PL/SQL Demo
-- Demonstrating creating tables, insterts, procedures, triggers

-- 1. Creating tables

CREATE TABLE positions (
    position_id     INTEGER PRIMARY KEY,
    position_name   VARCHAR2(20)
);

CREATE TABLE employee (
    employee_id     INTEGER PRIMARY KEY,
    employee_name   VARCHAR2(20),
    employee_phone  VARCHAR2(15),
    position_id     INTEGER REFERENCES positions(position_id)
);

CREATE TABLE "GROUP" (
    group_id     INTEGER PRIMARY KEY,
    group_name   VARCHAR2(20)
);

CREATE TABLE product (
    product_id       INTEGER PRIMARY KEY,
    product_name     VARCHAR2(20),
    product_group_id INTEGER REFERENCES "GROUP"(group_id)
);

CREATE TABLE inventory (
    inventory_id       INTEGER PRIMARY KEY,
    product_id         INTEGER REFERENCES product(product_id),
    available_quantity INTEGER,
    unit_price         NUMBER(10,2)
);

CREATE TABLE klient (
    klient_id      INTEGER PRIMARY KEY,
    klient_name    VARCHAR2(20),
    klient_phone   VARCHAR2(15)
);

CREATE TABLE sale (
    sale_id      INTEGER PRIMARY KEY,
    klient_id    INTEGER REFERENCES klient(klient_id),
    employee_id  INTEGER REFERENCES employee(employee_id),
    sale_date    DATE
);

CREATE TABLE sale_product (
    sale_product_id      INTEGER PRIMARY KEY,
    sale_id              INTEGER REFERENCES sale(sale_id),
    product_inventory_id INTEGER REFERENCES inventory(inventory_id),
    quantity_products    INTEGER,
    price_per_unit       NUMBER(10,2)
);


-- 2. Inserts

INSERT INTO positions VALUES (1, 'Salesman');
INSERT INTO positions VALUES (2, 'Support');

INSERT INTO employee VALUES (1, 'Ivan Petrov', '1234567890', 1);
INSERT INTO employee VALUES (2, 'Maria Georgieva', '0987654321', 2);

INSERT INTO "GROUP" VALUES (1, 'Electronics');
INSERT INTO "GROUP" VALUES (2, 'Books');

INSERT INTO product VALUES (101, 'Laptop', 1);
INSERT INTO product VALUES (102, 'Book A', 2);

INSERT INTO inventory VALUES (1, 101, 50, 1200);
INSERT INTO inventory VALUES (2, 102, 30, 20);

INSERT INTO klient VALUES (1, 'Georgi Ivanov', '0891234567');
INSERT INTO klient VALUES (2, 'Maria Petrova', '0889876543');

INSERT INTO sale VALUES (1, 1, 1, TO_DATE('2024-11-01','YYYY-MM-DD'));
INSERT INTO sale VALUES (2, 2, 2, TO_DATE('2024-11-02','YYYY-MM-DD'));

INSERT INTO sale_product VALUES (1, 1, 1, 2, 1200);
INSERT INTO sale_product VALUES (2, 2, 2, 1, 20);


-- 3. Procedures


CREATE OR REPLACE PROCEDURE getProductByPrice(
    price_min IN NUMBER, 
    price_max IN NUMBER
) IS
    CURSOR cur IS
        SELECT p.product_name, g.group_name, i.unit_price, k.klient_name, e.employee_name, sp.price_per_unit
        FROM product p
        JOIN inventory i ON p.product_id = i.product_id
        JOIN "GROUP" g ON p.product_group_id = g.group_id
        JOIN sale_product sp ON i.inventory_id = sp.product_inventory_id
        JOIN sale s ON sp.sale_id = s.sale_id
        JOIN klient k ON s.klient_id = k.klient_id
        JOIN employee e ON s.employee_id = e.employee_id
        WHERE i.unit_price BETWEEN price_min AND price_max;
BEGIN
    FOR r IN cur LOOP
        DBMS_OUTPUT.PUT_LINE('Product: ' || r.product_name || ', Group: ' || r.group_name || ', Price: ' || r.unit_price || 
                             ', Customer: ' || r.klient_name || ', Employee: ' || r.employee_name);
    END LOOP;
END;


CREATE OR REPLACE PROCEDURE getProductByName(
    pname IN VARCHAR2
) IS
    CURSOR cur IS
        SELECT p.product_name, g.group_name, i.unit_price, k.klient_name, e.employee_name, sp.price_per_unit
        FROM product p
        JOIN inventory i ON p.product_id = i.product_id
        JOIN "GROUP" g ON p.product_group_id = g.group_id
        JOIN sale_product sp ON i.inventory_id = sp.product_inventory_id
        JOIN sale s ON sp.sale_id = s.sale_id
        JOIN klient k ON s.klient_id = k.klient_id
        JOIN employee e ON s.employee_id = e.employee_id
        WHERE LOWER(p.product_name) = LOWER(pname);
BEGIN
    FOR r IN cur LOOP
        DBMS_OUTPUT.PUT_LINE('Product: ' || r.product_name || ', Group: ' || r.group_name || ', Price: ' || r.unit_price || 
                             ', Customer: ' || r.klient_name || ', Employee: ' || r.employee_name);
    END LOOP;
END;

--4. Triggers

create or replace TRIGGER trg_create_sale
AFTER INSERT ON sale_product
FOR EACH ROW
DECLARE
    available INT;
BEGIN
    SELECT available_quantity INTO available 
    FROM inventory 
    WHERE inventory_id = :NEW.product_inventory_id;

    IF :NEW.quantity_products > available THEN
        DBMS_OUTPUT.PUT_LINE('Insufficient quantity.');
        RAISE_APPLICATION_ERROR(-20001, 'Insufficient quantity');

    END IF;

    UPDATE inventory 
    SET available_quantity = available_quantity - :NEW.quantity_products
    WHERE inventory_id = :NEW.product_inventory_id;
END;


create or replace TRIGGER trg_delete_sale
AFTER DELETE ON sale_product
FOR EACH ROW
DECLARE
    inv_id INT;
BEGIN
    SELECT inventory_id INTO inv_id FROM inventory WHERE inventory_id = :OLD.product_inventory_id;

    UPDATE inventory
    SET available_quantity = available_quantity + :OLD.quantity_products
    WHERE inventory_id = inv_id;
END;
