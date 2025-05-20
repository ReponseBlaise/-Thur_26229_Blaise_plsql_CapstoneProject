# CAPSTONE PROJECT
### NAMES: MUSHIMIYUMUKIZA BLAISE
### ID:26228
### Course: DATABASE DEVELOPMENT WITH PL/SQL
### LECTURER: MANIRAGUHA ERIC<br><br>
# Inventory Management and Order Fulfillment System for a Retail Business
<P>The problem involves managing inventory, processing customer orders, and ensuring timely fulfillment 
for a retail business with multiple warehouses and an online store. The system must handle complex 
business logic, such as inventory allocation across warehouses, backorder management, and real-time 
stock updates. The current manual process is error-prone, 
leading to stockouts, delayed shipments, and customer dissatisfaction.
</P>
# 🛒 E-Commerce Order Management System
**Oracle PL/SQL Database Implementation**

## 📜 Table of Contents
1. [Project Overview](#-project-overview)
2. [Database Schema](#-database-schema)
3. [Setup Instructions](#-setup-instructions)
4. [Key Features](#-key-features)
5. [Usage Examples](#-usage-examples)
6. [Advanced Functionality](#-advanced-functionality)
7. [License](#-license)

## 🌟 Project Overview
This system automates order processing while enforcing business rules:
- Real-time inventory tracking
- Time-based DML restrictions (weekends/holidays only)
- Comprehensive audit logging
- Sales analytics

**Problem Solved**: Manual processes caused stock discrepancies and lacked security controls.

## 🗃️ Database Schema
### Core Tables
```sql
-- Customers
CREATE TABLE CUSTOMERS (
    CustomerID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Email VARCHAR2(100) UNIQUE NOT NULL,
    Name VARCHAR2(100) NOT NULL
);

-- Products
CREATE TABLE PRODUCTS (
    ProductID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Name VARCHAR2(100) NOT NULL,
    Price NUMBER(10,2) CHECK (Price > 0)
);

-- Orders (with time-based restrictions)
CREATE TABLE ORDERS (
    OrderID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    CustomerID NUMBER NOT NULL,
    OrderDate TIMESTAMP DEFAULT SYSTIMESTAMP,
    Status VARCHAR2(20) DEFAULT 'Pending',
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMERS(CustomerID)
);


