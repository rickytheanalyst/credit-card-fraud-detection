# 💳 Credit Card Fraud Detection using SQL

## 📌 Project Overview

Credit card fraud causes financial institutions billions of dollars in losses every year. Before applying Machine Learning models, analysts use SQL to explore the data, identify suspicious patterns, and build rule-based fraud detection systems.

In this project, I performed end-to-end exploratory data analysis and fraud pattern detection using SQL Server on the Kaggle Credit Card Fraud Detection dataset.

---

## 🎯 Objectives

- Perform data validation and cleaning
- Analyze fraud vs legitimate transactions
- Explore transaction amount and time patterns
- Detect anomalies using statistical techniques
- Build rule-based fraud detection logic
- Measure fraud rate and evaluate fraud detection rules

---

## 🛠️ Tools & Technologies

- SQL Server
- SQL Server Management Studio (SSMS)
- T-SQL
- Window Functions
- Common Table Expressions (CTEs)

---

## 📂 Dataset

- **Source:** Kaggle – Credit Card Fraud Detection
- **Total Transactions:** 284,807
- **Features:** 31
- **Fraud Transactions:** 492
- **Fraud Rate:** ~0.17%

Dataset contains:

- Time
- V1 – V28 (PCA transformed features)
- Amount
- Class
  - 0 = Legitimate
  - 1 = Fraud

---

# 📊 Project Workflow

### 1️⃣ Data Validation

- Verified row count
- Checked data types
- Identified NULL values
- Detected duplicate records
- Validated data quality before analysis

---

### 2️⃣ Exploratory Data Analysis (EDA)

Performed analysis on:

- Total transactions
- Fraud vs legitimate transactions
- Fraud rate
- Transaction amount statistics
- Mean vs Median comparison
- Hourly transaction distribution
- Transaction amount distribution
- Outlier detection

---

### 3️⃣ Fraud Analysis

Analyzed:

- Fraud percentage
- Fraud by amount range
- Fraud by hour of day
- Median transaction amount
- Z-score based anomaly detection
- High-value transaction analysis

---

### 4️⃣ Rule-Based Fraud Detection

Built a fraud detection rule using:

- Transaction Amount > $200
- Transaction Time between 12 AM – 5 AM

Measured:

- Flagged Transactions
- Fraud Transactions
- Segment Fraud Rate
- Global Fraud Rate

Compared the effectiveness of the rule against the overall dataset.

---

## 🚀 Advanced SQL Concepts Demonstrated

### Window Functions
- ROW_NUMBER()
- COUNT() OVER()
- Partitioning using PARTITION BY
- Ranking transactions within groups

### Common Table Expressions (CTEs)
- Single-stage CTEs
- Multi-stage CTE pipelines
- Modular query design
- Layered analytical workflows

### Advanced Aggregations
- Conditional Aggregation
- GROUP BY
- HAVING
- Nested Aggregations

### Statistical Analysis
- Mean
- Median (Manual Implementation)
- Standard Deviation
- Z-Score Calculation
- Feature Distribution Analysis

### Conditional Logic
- CASE WHEN
- Multi-level Risk Scoring
- Rule-Based Fraud Classification

### Time-Series Analysis
- Hour-of-Day Extraction
- Transaction Velocity Detection
- Rolling Time Window Analysis
- Time Bucket Analysis

### Self Joins
- Transaction Velocity Detection
- Sliding 600-second Window Analysis

### Feature Engineering
- Fraud Risk Score (0–100)
- Time-based Features
- Amount Bucketing
- PCA Feature Analysis (V1–V28)

### Fraud Detection Techniques
- Rule-Based Fraud Detection
- Multi-Signal Risk Scoring
- Fraud Flagging Pipeline
- Fraud Capture Analysis

### Model Evaluation Metrics (SQL Implementation)
- Confusion Matrix
- True Positives (TP)
- False Positives (FP)
- True Negatives (TN)
- False Negatives (FN)
- Precision
- Recall
- F1 Score
- Accuracy

### SQL Techniques
- CASE WHEN
- COALESCE()
- NULLIF()
- CAST()
- ROUND()
- UNION ALL
- LEFT JOIN
- Self JOIN
- ORDER BY
- Aggregate Functions

### Business Analytics
- Exploratory Data Analysis (EDA)
- Data Validation
- Duplicate Detection
- Fraud Pattern Discovery
- Business Rule Evaluation
- Risk Analytics

---

# 📈 Key Business Insights

- Fraud transactions represent only **0.17%** of the dataset, indicating severe class imbalance.
- Average transaction amount for fraud is higher than legitimate transactions.
- Median transaction analysis revealed that typical fraud transactions are actually small, while a few high-value frauds increase the average.
- Transactions occurring during midnight with high transaction amounts showed significantly higher fraud probability.
- Rule-based fraud detection increased the fraud detection rate compared to the global baseline.

---

# 📚 SQL Concepts Demonstrated

- Data Cleaning
- Exploratory Data Analysis
- Fraud Analytics
- Statistical Analysis
- Conditional Aggregation
- Window Functions
- CTEs
- Business-Oriented SQL Reporting

---

# 📷 Sample Analysis

Examples included in this project:

- Fraud Rate Calculation
- Hourly Fraud Analysis
- Transaction Amount Distribution
- Median vs Mean Comparison
- Z-score Based Outlier Detection
- Rule-Based Fraud Flagging

---

# 🚀 Learning Outcomes

Through this project I learned:

- How SQL is used in fraud analytics
- How to clean and validate financial datasets
- How to build business-oriented SQL queries
- How to detect suspicious transaction patterns
- How to use window functions in real-world scenarios
- How to convert business requirements into SQL solutions

---

## ⭐ Future Improvements

- Build Machine Learning fraud prediction model
- Create interactive Power BI dashboard
- Deploy fraud detection pipeline
- Compare rule-based detection with ML models

---

## 👨‍💻 Author

**BETHI RICKY**

Aspiring Data Analyst | Data Scientist
