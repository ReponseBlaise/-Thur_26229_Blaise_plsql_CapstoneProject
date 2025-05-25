CREATE PLUGGABLE DATABASE Thur_26229_blaise_eshop_db
ADMIN USER eshop_admin IDENTIFIED BY Blaise
ROLES = (dba)
CREATE_FILE_DEST = 'C:\APP\MUSHI\ORADATA\AUCA\Thur_eshop\';

-- 1. CUSTOMERS table
CREATE TABLE CUSTOMERS (
    CustomerID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Name VARCHAR2(100) NOT NULL,
    Email VARCHAR2(100) UNIQUE NOT NULL,
    Address VARCHAR2(200) NOT NULL,
    Phone VARCHAR2(15) CHECK (REGEXP_LIKE(Phone, '^[0-9]{10,15}$')),
    RegistrationDate DATE DEFAULT SYSDATE
);

-- 2. SUPPLIERS table
CREATE TABLE SUPPLIERS (
    SupplierID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Name VARCHAR2(100) NOT NULL,
    ContactEmail VARCHAR2(100) UNIQUE NOT NULL,
    Phone VARCHAR2(15),
    ContractStartDate DATE NOT NULL,
    ReliabilityRating NUMBER(2,1) CHECK (ReliabilityRating BETWEEN 1 AND 5)
);

-- 3. PRODUCTS table
CREATE TABLE PRODUCTS (
    ProductID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Name VARCHAR2(100) NOT NULL,
    Description VARCHAR2(500),
    Price NUMBER(10,2) CHECK (Price > 0),
    Category VARCHAR2(50),
    SupplierID NUMBER,
    FOREIGN KEY (SupplierID) REFERENCES SUPPLIERS(SupplierID)
);

-- 4. WAREHOUSES table
CREATE TABLE WAREHOUSES (
    WarehouseID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Location VARCHAR2(100) NOT NULL,
    Capacity NUMBER NOT NULL CHECK (Capacity > 0),
    Manager VARCHAR2(100),
    OperationalHours VARCHAR2(50)
);

-- 5. INVENTORY table (junction between PRODUCTS & WAREHOUSES)
CREATE TABLE INVENTORY (
    InventoryID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ProductID NUMBER NOT NULL,
    WarehouseID NUMBER NOT NULL,
    Quantity NUMBER DEFAULT 0 CHECK (Quantity >= 0),
    LastStockedDate DATE,
    FOREIGN KEY (ProductID) REFERENCES PRODUCTS(ProductID) ON DELETE CASCADE,
    FOREIGN KEY (WarehouseID) REFERENCES WAREHOUSES(WarehouseID),
    CONSTRAINT UC_Inventory UNIQUE (ProductID, WarehouseID)
);

-- 6. ORDERS table
CREATE TABLE ORDERS (
    OrderID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    CustomerID NUMBER NOT NULL,
    OrderDate TIMESTAMP DEFAULT SYSTIMESTAMP,
    Status VARCHAR2(20) DEFAULT 'Pending' 
        CHECK (Status IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled')),
    TotalAmount NUMBER(12,2) CHECK (TotalAmount >= 0),
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMERS(CustomerID)
);

-- 7. ORDER_ITEMS table (junction between ORDERS & PRODUCTS)
CREATE TABLE ORDER_ITEMS (
    OrderItemID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    OrderID NUMBER NOT NULL,
    ProductID NUMBER NOT NULL,
    Quantity NUMBER NOT NULL CHECK (Quantity > 0),
    UnitPrice NUMBER(10,2) NOT NULL CHECK (UnitPrice > 0),
    FOREIGN KEY (OrderID) REFERENCES ORDERS(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES PRODUCTS(ProductID),
    CONSTRAINT UC_OrderProduct UNIQUE (OrderID, ProductID)
);

-- 8. SHIPMENTS table
CREATE TABLE SHIPMENTS (
    ShipmentID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    OrderID NUMBER NOT NULL,
    WarehouseID NUMBER NOT NULL,
    TrackingNumber VARCHAR2(50) UNIQUE,
    ShipDate DATE,
    EstimatedDelivery DATE,
    ActualDelivery DATE,
    Carrier VARCHAR2(50),
    FOREIGN KEY (OrderID) REFERENCES ORDERS(OrderID),
    FOREIGN KEY (WarehouseID) REFERENCES WAREHOUSES(WarehouseID),
    CONSTRAINT DeliveryCheck CHECK (ActualDelivery IS NULL OR ActualDelivery >= ShipDate)
);

-- Insert SUPPLIERS
INSERT INTO SUPPLIERS (Name, ContactEmail, Phone, ContractStartDate, ReliabilityRating)
VALUES ('TechSupplies Inc', 'contact@techsupplies.com', '1234567890', TO_DATE('2023-01-15', 'YYYY-MM-DD'), 4.5);

-- Insert PRODUCTS
INSERT INTO PRODUCTS (Name, Description, Price, Category, SupplierID)
VALUES ('Wireless Mouse', 'Ergonomic wireless mouse', 24.99, 'Electronics', 1);

-- Insert WAREHOUSES
INSERT INTO WAREHOUSES (Location, Capacity, Manager, OperationalHours)
VALUES ('Kigali', 5000, 'Blaise Rusirare', '9AM-5PM');

-- Insert INVENTORY
INSERT INTO INVENTORY (ProductID, WarehouseID, Quantity, LastStockedDate)
VALUES (1, 1, 100, SYSDATE);

-- Insert CUSTOMERS
INSERT INTO CUSTOMERS (Name, Email, Address, Phone)
VALUES ('Alice Mushimiyumukiza', 'alice@gmail.com', '123 Main St', '5551234567');

-- Insert ORDERS
INSERT INTO ORDERS (CustomerID, Status, TotalAmount)
VALUES (1, 'Processing', 24.99);

-- Insert ORDER_ITEMS
INSERT INTO ORDER_ITEMS (OrderID, ProductID, Quantity, UnitPrice)
VALUES (1, 1, 1, 24.99);

-- Insert SHIPMENTS
INSERT INTO SHIPMENTS (OrderID, WarehouseID, TrackingNumber, ShipDate, EstimatedDelivery, Carrier)
VALUES (1, 1, 'TRK123456', SYSDATE, SYSDATE + 3, 'FedEx');


-- First create the sequence if it doesn't exist
CREATE SEQUENCE ORDERS_SEQ
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Then modify the procedure to use the sequence
CREATE OR REPLACE PROCEDURE place_order(
    p_customer_id IN NUMBER,
    p_product_id IN NUMBER,
    p_quantity IN NUMBER
) AS
    v_inventory NUMBER;
    v_price NUMBER;
    v_order_id NUMBER;
BEGIN
    -- Check inventory
    SELECT Quantity INTO v_inventory
    FROM INVENTORY
    WHERE ProductID = p_product_id AND ROWNUM = 1;
    
    -- Get product price
    SELECT Price INTO v_price
    FROM PRODUCTS
    WHERE ProductID = p_product_id;
    
    -- If stock available
    IF v_inventory >= p_quantity THEN
        -- Get next order ID from sequence
        SELECT ORDERS_SEQ.NEXTVAL INTO v_order_id FROM DUAL;
        
        -- Insert order
        INSERT INTO ORDERS (OrderID, CustomerID, Status)
        VALUES (v_order_id, p_customer_id, 'Processing');
        
        -- Add order item
        INSERT INTO ORDER_ITEMS (OrderID, ProductID, Quantity, UnitPrice)
        VALUES (v_order_id, p_product_id, p_quantity, v_price);
        
        -- Update inventory
        UPDATE INVENTORY
        SET Quantity = Quantity - p_quantity
        WHERE ProductID = p_product_id;
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Order ' || v_order_id || ' placed successfully!');
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Insufficient stock!');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Product not found!');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/






CREATE OR REPLACE PROCEDURE update_product_price(
    p_product_id IN NUMBER,
    p_new_price IN NUMBER
) AS
BEGIN
    IF p_new_price <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Price must be positive!');
    END IF;
    
    UPDATE PRODUCTS
    SET Price = p_new_price
    WHERE ProductID = p_product_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Price updated successfully!');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/


ALTER TABLE CUSTOMERS
ADD LoyaltyPoints NUMBER DEFAULT 0;

DROP TABLE TEMP_CART;


SELECT 
    p.Name AS Product,
    SUM(oi.Quantity) AS TotalSold,
    RANK() OVER (ORDER BY SUM(oi.Quantity) DESC) AS SalesRank
FROM 
    ORDER_ITEMS oi
JOIN 
    PRODUCTS p ON oi.ProductID = p.ProductID
GROUP BY 
    p.Name;

SELECT 
    c.Name,
    COUNT(o.OrderID) AS TotalOrders,
    AVG(COUNT(o.OrderID)) OVER () AS AvgOrders
FROM 
    CUSTOMERS c
JOIN 
    ORDERS o ON c.CustomerID = o.CustomerID
GROUP BY 
    c.Name;

CREATE TABLE HOLIDAYS (
    HolidayDate DATE PRIMARY KEY,
    HolidayName VARCHAR2(100) NOT NULL
);

-- Insert upcoming month's holidays
INSERT INTO HOLIDAYS VALUES (TO_DATE('15-08-2023', 'DD-MM-YYYY'), 'Independence Day');
INSERT INTO HOLIDAYS VALUES (TO_DATE('02-09-2023', 'DD-MM-YYYY'), 'Labor Day');


CREATE TABLE AUDIT_LOGS (
    LogID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    UserID VARCHAR2(30) NOT NULL,
    ActionDate TIMESTAMP DEFAULT SYSTIMESTAMP,
    TableName VARCHAR2(30) NOT NULL,
    Operation VARCHAR2(10) NOT NULL,
    Status VARCHAR2(10) NOT NULL,
    Details VARCHAR2(200)
);

CREATE OR REPLACE TRIGGER restrict_dml_operations
FOR INSERT OR UPDATE OR DELETE ON ORDERS
COMPOUND TRIGGER
    v_day_of_week VARCHAR2(10);
    v_is_holiday BOOLEAN := FALSE;
    
    -- Check restrictions before each statement
    BEFORE STATEMENT IS
    BEGIN
        v_day_of_week := TO_CHAR(SYSDATE, 'DY');
        
        -- Check if today is a weekday (Mon-Fri)
        IF v_day_of_week IN ('MON', 'TUE', 'WED', 'THU', 'FRI') THEN
            -- Check if today is a holiday
            SELECT COUNT(*) INTO v_is_holiday
            FROM HOLIDAYS
            WHERE HolidayDate = TRUNC(SYSDATE);
            
            IF v_is_holiday > 0 THEN
                RAISE_APPLICATION_ERROR(-20001, 
                    'Modifications prohibited on holidays: ' || 
                    (SELECT HolidayName FROM HOLIDAYS WHERE HolidayDate = TRUNC(SYSDATE)));
            ELSE
                RAISE_APPLICATION_ERROR(-20002, 
                    'Modifications allowed only on weekends! Today is ' || v_day_of_week);
            END IF;
        END IF;
    END BEFORE STATEMENT;
    
    -- Log allowed operations (for weekends)
    AFTER EACH ROW IS
    BEGIN
        INSERT INTO AUDIT_LOGS (UserID, TableName, Operation, Status)
        VALUES (USER, 'ORDERS', 
               CASE WHEN INSERTING THEN 'INSERT'
                    WHEN UPDATING THEN 'UPDATE'
                    ELSE 'DELETE' END,
               'ALLOWED');
    END AFTER EACH ROW;
END;
/

CREATE OR REPLACE TRIGGER audit_product_changes
AFTER INSERT OR UPDATE OR DELETE ON PRODUCTS
FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
BEGIN
    v_operation := CASE 
        WHEN INSERTING THEN 'INSERT'
        WHEN UPDATING THEN 'UPDATE'
        ELSE 'DELETE' END;
    
    INSERT INTO AUDIT_LOGS 
        (UserID, TableName, Operation, Status, Details)
    VALUES (
        USER, 
        'PRODUCTS', 
        v_operation,
        'ALLOWED',
        'ProductID=' || NVL(TO_CHAR(:NEW.ProductID), TO_CHAR(:OLD.ProductID)) || 
        CASE WHEN UPDATING THEN 
             ', Price:' || :OLD.Price || '->' || :NEW.Price 
        ELSE '' END
    );
END;
/

CREATE OR REPLACE PACKAGE audit_utilities AS
    -- Generate audit report
    PROCEDURE generate_audit_report(
        p_start_date IN DATE DEFAULT SYSDATE-30,
        p_end_date IN DATE DEFAULT SYSDATE
    );
    
    -- Purge old audit records
    PROCEDURE purge_audit_logs(
        p_retention_days IN NUMBER DEFAULT 365
    );
END audit_utilities;
/

CREATE OR REPLACE PACKAGE BODY audit_utilities AS
    PROCEDURE generate_audit_report(
        p_start_date IN DATE,
        p_end_date IN DATE
    ) IS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
            SELECT UserID, TableName, Operation, ActionDate, Details
            FROM AUDIT_LOGS
            WHERE ActionDate BETWEEN p_start_date AND p_end_date
            ORDER BY ActionDate DESC;
            
        -- Would typically return cursor to application
        DBMS_OUTPUT.PUT_LINE('Audit report generated for ' || 
                             p_start_date || ' to ' || p_end_date);
    END;
    
    PROCEDURE purge_audit_logs(p_retention_days IN NUMBER) IS
    BEGIN
        DELETE FROM AUDIT_LOGS
        WHERE ActionDate < SYSDATE - p_retention_days;
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Purged ' || SQL%ROWCOUNT || ' audit records');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Purge failed: ' || SQLERRM);
    END;
END audit_utilities;
/
-- Attempt to update an order on Tuesday
UPDATE ORDERS SET Status = 'Shipped' WHERE OrderID = 1;
-- Expected: Error "Modifications allowed only on weekends!"

-- Simulate holiday (assuming today is 15-AUG-2023)
UPDATE ORDERS SET Status = 'Shipped' WHERE OrderID = 1;
-- Expected: Error "Modifications prohibited on holidays: Independence Day"

-- Simulate weekend (change server date or use conditional testing)
INSERT INTO ORDERS (CustomerID) VALUES (1);
-- Verify audit log:
SELECT * FROM AUDIT_LOGS WHERE TableName = 'ORDERS';






