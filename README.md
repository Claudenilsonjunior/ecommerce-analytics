# 📊 Marketing Analytics Dashboard – E-commerce Campaign Insights

In this project, I step into the role of a **Data Analyst** at an e-commerce company struggling to understand the real impact of its marketing investments.

The company has been heavily spending on paid campaigns across multiple channels, but executives are questioning:

- Are these campaigns actually bringing revenue?  
- Which channels and regions perform best?  
- What is the return on investment (ROI) of each campaign?  

To answer these questions, I built a **complete analytics solution powered by SQL, DAX, and Power BI**, connecting raw marketing and sales data into a set of business-driven insights.

---

## 🛍️ Business Context

The fictional e-commerce sells multiple product categories online, running campaigns across digital channels. However, the marketing team faced several challenges:

- Campaign reports didn’t match sales data (inconsistent order IDs, invalid conversions).  
- Executives lacked a single source of truth for KPIs like **ROI, Attributed Revenue, and Average Order Value (AOV)**.  
- Spending was increasing, but profitability was unclear.  

This dashboard was created to provide **executives with clarity** and enable **better marketing decisions**.

---

## 🎯 Business Goals

- Attribute sales revenue to marketing campaigns more accurately  
- Measure campaign ROI and compare investment vs return  
- Identify best-performing regions, channels, and product categories  
- Provide both an **executive overview** and a **drilldown for analysts**

---

## 🔍 Data Quality Issues Found

Before analysis, several problems were identified:

- **3,373** incoherent dates (delivery before order date)  
- **2,518** invalid unit prices (≤ 0)  
- **1,048** zero-quantity orders  
- **41** campaigns with suspicious conversions (> clicks)  
- Marketing campaigns referencing **nonexistent sales orders**  

👉 Each issue was documented, its **business impact explained**, and **SQL solutions applied**.

---

## 🛠️ How It Was Built

### 1. SQL Server → Data Cleaning & Preparation
Files in [`/sql`](./sql):
- [`data_quality_checks.sql`](./sql/data_quality_checks.sql) → detected incoherent dates, invalid prices, fake orders, invalid conversions.  
- [`data_cleaning.sql`](./sql/data_cleaning.sql) → fixed dates, normalized IDs, excluded invalid rows, validated campaign attribution.  
- [`views.sql`](./sql/views.sql) → created **analysis-ready views** (`vw_sales_final`, `vw_marketing_orders`).  
- [`queries.sql`](./sql/queries.sql) → business queries for KPIs (Revenue, ROI, Conversion Rate, Top Products, etc.).  

### 2. DAX in Power BI
- Custom measures for **Attributed Revenue, AOV, ROI, Valid Orders**.  

### 3. Power BI
- Executive dashboard for C-levels  
- Drilldown page for analysts  

---

## 📸 Dashboard (Work in Progress)

### Executive Overview
- KPIs: **Total Revenue, Attributed Revenue, AOV, Total Spend, ROI, Valid Orders**  
- Attributed Revenue vs Spend by Campaign  
- Revenue by Product Category  
- Revenue & Spend Trends by Month  

### Drilldown Page
- Campaign-level table  
- Breakdown by product, region, and sales channel  
- ROI distribution and customer-level insights  


---

## 🧩 Key Insights

From the analysis:

- **ROI was negative** in most campaigns → spend was higher than attributed revenue.  
- Some campaigns had **high clicks but low conversions**, pointing to poor targeting/landing page issues.  
- **North region** and **Electronics category** were strong performers.  
- Multiple invalid/zero-quantity orders showed the **importance of cleaning before analysis**.  

---

## 🧠 Business Impact

This project demonstrates how **technical SQL + DAX work directly connects to business outcomes**:

- Turning messy raw data into **trusted KPIs**  
- Giving executives **clarity** on where money is being wasted  
- Highlighting where to cut spend, double down, or fix inefficiencies  

---

## ⚙️ Tech Stack

- **SQL Server** – data validation, cleaning, transformations  
- **Power BI (DAX)** – KPIs, dashboard storytelling  
- **Excel/CSV** – raw data  

---

👤 Author: [Claudenilson Junior](https://github.com/Claudenilsonjunior)  
