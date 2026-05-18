# StoreDB - PL/SQL Demo

This repository contains a **mock database** demonstrating basic Oracle PL/SQL skills, including:

- Creating tables with relationships
- Inserting sample data
- Writing simple stored procedures
- Using triggers to enforce business rules

This is **not a production database**, just a learning/demo project.
It is **not a full production project**, but a showcase of what can be done in PL/SQL.

---

## 1. Tables

The database contains the following tables:

| Table Name      | Description |
|-----------------|-------------|
| `positions`     | Employee positions (Salesman, Support, etc.) |
| `employee`      | Employees with phone numbers and positions |
| `GROUP`         | Product groups (Electronics, Books, etc.) |
| `product`       | Products belonging to groups |
| `inventory`     | Inventory records with quantity and price |
| `klient`        | Customers |
| `sale`          | Sales transactions |
| `sale_product`  | Products sold in each sale |

---

## 2. Sample Data

Some example records are inserted to allow testing of procedures and triggers:

- Employees: Ivan Petrov, Maria Georgieva  
- Product Groups: Electronics, Books  
- Products: Laptop, Books  
- Inventory: 50 Laptops, 30 Books  
- Sales: Two example sales  
- Sale Products: Linking inventory to sales
- Triggers: Inventory always reflects actual stock and prevent selling more products than available

---

## 3. Stored Procedures

The repository includes simple procedures to **query sales and products**:

1. **`getProductByPrice(price_min, price_max)`**  
   Returns products within a price range along with customer and employee info.

2. **`getProductByName(pname)`**  
   Returns a specific product's sales information.

*Usage Example:*

```sql
EXEC getProductByPrice(10, 2000);
EXEC getProductByName('Laptop');
