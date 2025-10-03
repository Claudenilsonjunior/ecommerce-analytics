## 📊 Marketing Analytics Dashboard – E-commerce Campaign Insights

In this project, I step into the role of a Data Analyst at an e-commerce company struggling to understand the real impact of its marketing investments.

The company has been heavily spending on paid campaigns across multiple channels, but executives are questioning:

Are these campaigns actually bringing revenue?

Which channels and regions perform best?

What is the return on investment (ROI) of each campaign?

To answer these questions, I built a complete analytics solution powered by SQL, DAX, and Power BI, connecting raw marketing and sales data into a set of business-driven insights.
---

## 🛍️ Business Context

The fictional e-commerce sells multiple product categories online, running campaigns across digital channels.
However, the marketing team faced several challenges:

Campaign reports didn’t match sales data (inconsistent order IDs, invalid conversions).

Executives lacked a single source of truth for KPIs like ROI, Attributed Revenue, and Average Order Value.

Spending was increasing, but profitability was unclear.

This dashboard was created to provide executives with clarity and enable better marketing decisions.

🎯 Business Goals

Attribute sales revenue to marketing campaigns more accurately

Measure campaign ROI and compare investment vs return

Identify best-performing **regions, channels, and product categories**

Provide an executive view for decision makers and a detailed drilldown for analysts

---

## 🧩 Key Insights

From the analysis:

* ROI was negative in most campaigns → Marketing spend was higher than attributed revenue.

* Some campaigns had high clicks but very low conversions, suggesting poor targeting or landing page issues.

* The North region and Electronics category stood out as strong performers, driving most valid revenue.

* Several sales orders had invalid or zero quantities, revealing data quality issues that required cleaning before insights.

---

## 🛠️ How It Was Built

**SQL Server** → Data cleaning & preparation (fixing dates, unit prices, invalid orders, campaign attribution)

**DAX in Power BI** → Calculating business KPIs (AOV, Attributed Revenue, ROI)

**Power BI** → Dashboard storytelling for both executives and analysts

---

## 🏆 Takeaways

This project simulates a real e-commerce analytics workflow, where technical SQL/DAX work directly connects to business impact:

- Turning raw, inconsistent data into actionable KPIs

- Showing executives not just numbers, but decisions: where to cut spend, where to double down, and where to improve campaign efficiency

---

## 📸 Dashboard (Work in Progress)
Executive Overview

* KPIs: Total Revenue, Attributed Revenue, AOV, Total Spend, ROI, Valid Orders

* Attributed Revenue & Total Spend by Campaign

* Revenue by Product Category

* Revenue & Spend Trends by Month

## Drilldown Page

* Detailed campaign-level table

* Breakdown by product, region, and sales channel

* ROI distribution and customer-level insights
