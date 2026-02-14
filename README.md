# Banking Analytics Dashboard | SQL + Power BI

## Project Overview

This project presents an **end-to-end banking analytics solution** built using **SQL and Power BI**, designed to analyze loan portfolios, customer risk, repayment behavior, and exposure concentration.

The dashboard is structured to support **executive-level decision-making**, **risk monitoring**, and **credit portfolio analysis**, similar to what is used in real-world banking and NBFC environments.

---

## Business Objectives

- Analyze **loan portfolio health and performance**
- Identify **high-risk and delinquent customers**
- Monitor **repayment behavior and default trends**
- Detect **exposure concentration risks**
- Understand **customer lifecycle and value**

---

## Tech Stack

- **SQL (MySQL / PostgreSQL compatible)**  
  - Data modeling  
  - Joins, aggregations, CASE logic  
  - Views for analytics-ready datasets  

- **Power BI**
  - Interactive dashboards
  - DAX measures for KPIs
  - Drill-down analysis
  - Slicers and filters

---

## Dataset Structure (High Level)

The project uses relational banking data including:

- Customers
- Bank Accounts
- Loans
- Loan Repayments (EMIs)
- Branches
- Transactions

SQL views are created to transform raw data into **analytics-ready tables** used directly in Power BI.

---

## Dashboard Pages & Insights

### Executive Overview
- Total Customers
- Total Accounts
- Total Loans
- Total Loan Exposure
- Account status and account type distribution

*Purpose:* Quick high-level snapshot for leadership.

---

### Loan Portfolio & Risk Analysis
- Total Outstanding Amount
- Loan Default Rate
- Loan Closure Rate
- Loan Status Distribution
- Outstanding Loan Amount by Region
- Income vs Average EMI analysis

*Purpose:* Portfolio strength, regional exposure, and risk indicators.

---

### Repayment Behavior & Delinquency Analysis
- Delayed Loans (%)
- Fully Paid Loans (%)
- High Risk Loans (%)
- Loan Health Distribution
- Delayed vs Missed EMIs by Risk Category

*Purpose:* Identify repayment issues and early warning signals.

---

### Customer Exposure Concentration & Risk Signals
- Customer Outstanding Exposure
- Multi-loan Customer Share
- Repeat Delinquent Customer Rate
- Customer Distribution by Exposure Range
- Outstanding Exposure by Risk Category

*Purpose:* Detect concentration risk and risky customer segments.

---

### Customer Lifecycle & Value
- Customer Tenure vs Lifetime Transaction Value
- Customer Count by Risk Category

*Purpose:* Understand long-term customer value and risk patterns.

---

## Key KPIs Used

- Loan Default Rate
- Loan Recovery Rate
- Delinquency Rate
- High-Risk Loan Percentage
- Multi-Loan Customer Share
- Outstanding Exposure

All KPIs are calculated using **DAX measures** to ensure accuracy and performance.

---

## Key Learnings

- Exposure concentration can be more dangerous than loan count
- A small % of high-risk customers can hold a large % of outstanding amount
- Repayment behavior is a strong early indicator of default
- Executive dashboards must prioritize clarity over volume

---

## How to Use This Project

1. Review SQL files to understand data modeling and transformations
2. Open the Power BI file to explore interactive dashboards
3. Use slicers to filter by risk category, loan health, and repayment status
4. Follow the dashboard flow from **overview → risk → behavior → customers**

---

## Ideal Use Cases

- Data Analyst / Business Analyst portfolio
- Banking / Finance analytics case study
- Interview demonstration project
- SQL + Power BI skill showcase
