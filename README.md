# CAPSTONE PROJECT
### NAMES: MUSHIMIYUMUKIZA BLAISE
### ID:26228
### Course: DATABASE DEVELOPMENT WITH PL/SQL
### LECTURER: MANIRAGUHA ERIC<br><br>
# Inventory Management and Order Fulfillment System for a Retail Business

## 📌 Project Overview
This system is designed to automate and manage inventory tracking, order processing, and supplier restocking for a medium to large-scale retail business using Oracle PL/SQL.
<P>The problem involves managing inventory, processing customer orders, and ensuring timely fulfillment 
for a retail business with multiple warehouses and an online store. The system must handle complex 
business logic, such as inventory allocation across warehouses, backorder management, and real-time 
stock updates. The current manual process is error-prone, 
leading to stockouts, delayed shipments, and customer dissatisfaction.
</P>


### ✅ Objective:
To build a centralized Oracle database with PL/SQL that:
- Automates order placement and fulfillment
- Tracks inventory in real time
- Maintains supplier restocking logic
- Enforces business constraints via triggers and procedures
  

---

## 🧩 Key Features
- Inventory allocation and real-time updates
- Multi-warehouse tracking
- Order and shipment management
- Supplier integration
- Auditing and data restriction triggers

---

## 🧱 Database Structure
### Tables
- `CUSTOMERS`: Customer info
- `PRODUCTS`: Product catalog
- `SUPPLIERS`: Supplier details
- `INVENTORY`: Product quantity in warehouses
- `WAREHOUSES`: Warehouse metadata
- `ORDERS`: Order metadata
- `ORDER_ITEMS`: Products per order
- `SHIPMENTS`: Delivery and tracking

---

## 🔄 Business Logic
- Triggers: To restrict DML on weekdays & holidays
- Procedures: Place order, update inventory
- Packages: Order & Inventory Management
- Window Functions: Product sales ranking

---

## 🧪 Testing
Included sample data for:
- Inventory
- Customers
- Products
- Orders and shipments

Test queries validate:
- Inventory decrements
- Shipment tracking
- Order creation integrity

---

## 📊 Tools Used
- Oracle SQL Developer
- SQL*Plus
- draw.io\BPMN.IO for ERD & BPMN
- GitHub for versioning
- OEM for monitoring

---

## 🔐 Security & Compliance
- Enforced modification restrictions
- Full audit trail via AUDIT_LOGS
- Secure exception handling
- Holiday-based access blocking

---

## 👨‍💻 Author & Deployment
**Author:** Blaise Mushimiyumukiza  
**Database:** `Thur_26229_blaise_eshop_db`  
**Password:** ``  
**Admin User:** `eshop_admin`  

---

## 📜 License
Open-source for educational use. Feel free to customize and reuse with credit.

