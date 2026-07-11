# 💳 Payment Card Fraud Analytics

## 📌 Project Overview

This project was developed as part of the Ironhack Data Analytics Bootcamp.

The objective was to analyze payment card fraud using relational databases and SQL to identify the fraud patterns, account characteristics, transaction behaviours, and network relationships most strongly associated with fraudulent activity.

The project combines Python based data preparation, MySQL database design, SQL analysis, and data visualizations to transform multiple fraud datasets into actionable business insights.

## 🎯 Business Problem

Payment card fraud creates significant financial losses and operational risk for financial institutions.

Fraud detection requires understanding not only individual fraudulent transactions, but also the account characteristics, transaction behaviours, and network relationships associated with higher fraud risk.

This project uses structured fraud data to identify high risk patterns and support more targeted fraud monitoring and investigation.

## 💡 Business Hypothesis

Fraud risk is concentrated around identifiable transaction characteristics, higher risk account profiles, and connected account networks.

By analyzing these factors together, financial institutions can better identify the patterns associated with financial losses and coordinated fraud activity.

## ❓ Research Questions

The analysis focuses on four business questions:

1. Which fraud patterns generate the highest financial losses and should be prioritized for fraud prevention?

2. Which customer account characteristics are the strongest indicators of fraud risk?

3. Which transaction behaviours are most strongly associated with fraudulent activity?

4. Can network analysis identify coordinated fraud rings and high risk account clusters?

## 📊 Data Sources

The project uses five fraud analytics datasets obtained from Kaggle.

**Original Dataset:**

https://www.kaggle.com/datasets/sergionefedov/fraud-detection-1m-transactions-7-fraud-types

The project uses the following five datasets:

### Transactions

Transaction level data including transaction amount, merchant category, device type, foreign transaction indicators, IP risk score, transaction velocity, and fraud status.

### Account Profiles

Account level characteristics including account type, account age, risk score, two factor authentication status, and fraud history.

### Fraud Patterns

Aggregated fraud pattern information used to evaluate fraud frequency and financial impact.

### Network Edges

Relationships between connected accounts and identified fraud rings, supporting the analysis of coordinated fraud activity.

### Time Series Statistics

Fraud metrics across time periods used to analyze fraud activity and trends.

**Note:** The raw and cleaned transaction datasets are excluded from this repository because each file exceeds GitHub's 100 MB file size limit. Both files are listed in `.gitignore`. The original data can be accessed through the Kaggle dataset linked above.

## 🔧 Methodology

The project followed these main steps:

1. Dataset inspection and validation
2. Data cleaning and preparation in Python
3. Primary key validation
4. Foreign key and dataset relationship validation
5. Data type and column standardization
6. Clean dataset export for MySQL
7. Relational database creation
8. CSV data import and database validation
9. SQL based exploratory analysis
10. Business question analysis
11. Report notebook development and visualization
12. Fraud insight and recommendation development

## 🗄 Database Structure

The cleaned datasets were structured into five relational database tables:

`transactions`

`account_profiles`

`fraud_patterns`

`network_edges`

`time_series_stats`

Primary and foreign key relationships were reviewed to support data integrity and cross table analysis.

The database structure and table relationships are documented through an Entity Relationship Diagram included in the `assets` folder.

## 🔍 SQL Analysis

The SQL analysis was structured around four research areas.

### Financial Impact of Fraud Patterns

Identifies fraud patterns associated with the highest total financial losses and evaluates fraud frequency and financial severity.

Card Not Present and Account Takeover fraud represented the largest shares of total fraud loss in the dataset.

### Account Fraud Risk

Analyzes customer account characteristics including risk score, account age, account type, and two factor authentication status.

The analysis compares fraud rates across account characteristics to identify higher risk account groups.

### Transaction Fraud Behaviour

Evaluates transaction characteristics including merchant category, transaction amount, foreign transactions, IP risk score, and transaction velocity.

High transaction velocity showed the strongest association with fraudulent activity in the dataset.

### Network Fraud Analysis

Analyzes shared account connections and fraud ring structures to identify highly connected clusters and coordinated fraud activity.

The analysis identified 200 fraud rings and ranked the highest activity rings based on shared network connections.

## 📈 Key Findings

The analysis identified four main fraud risk areas:

1. **Fraud losses are highly concentrated.** Card Not Present and Account Takeover fraud generated the largest financial losses.

2. **Account security characteristics matter.** Accounts without two factor authentication and newer accounts showed higher fraud rates.

3. **Transaction velocity is a strong behavioural signal.** Transactions with six or more transactions within one hour showed a significantly higher fraud rate.

4. **Network relationships reveal coordinated activity.** Network analysis identified 200 fraud rings and several highly connected account clusters.

These findings support a layered fraud monitoring approach combining fraud pattern prioritization, account security controls, transaction behaviour monitoring, and network analysis.

## 📂 Repository Structure

    SQL_Mini_Project/
    │
    ├── assets/
    │   ├── EER Diagram - Fraud analytics.png
    │   └── ERD.mwb
    │
    ├── cleaned_data/
    │   ├── account_profiles_clean.csv
    │   ├── fraud_patterns_clean.csv
    │   ├── network_edges_clean.csv
    │   └── time_series_stats_clean.csv
    │
    ├── data/
    │   ├── account_profiles.csv
    │   ├── fraud_patterns.csv
    │   ├── network_edges.csv
    │   └── time_series_stats.csv
    │
    ├── notebooks/
    │   ├── Data_preparation.ipynb
    │   └── Report_Notebook.ipynb
    │
    ├── sql/
    │   └── SQL_Merged_Database&Analysis.sql
    │
    ├── .gitignore
    │
    └── README.md

## 📓 Notebooks

### Data Preparation Notebook

`01_Data_preparation.ipynb`

Contains dataset loading, inspection, data cleaning, data type corrections, primary key validation, foreign key validation, and cleaned CSV exports.

### Report Notebook

`02_Report_Notebook.ipynb`

Contains the complete analytical report, including research question analysis, summary outputs, visualizations, key findings, and overall conclusions.

The report notebook is kept separate from the data preparation workflow.

## 🛠 Technologies Used

Python

Pandas

Matplotlib

Jupyter Notebook

MySQL

MySQL Workbench

SQL

Visual Studio Code

Git

GitHub

## 👥 Team

**Team Winifred & Sevgi**

Winifred Paul

Sevgi Özdemir

Ironhack Data Analytics Bootcamp

## 📋 Project Management

The project was managed using an Agile workflow in Trello, including sprint planning, task assignment, progress tracking, and collaboration throughout the project.

**Trello Board:**

https://trello.com/b/Bx7wiGFC/winifred-sevgi

## 📽 Presentation

**Presentation Slides:**

https://docs.google.com/presentation/d/1MTfMAgBM3lrIVIBSZhMcR4cnA_AQtfl_KT99VeSZNgk/edit?slide=id.p1#slide=id.p1

## 📜 License

This project was created for educational purposes as part of the Ironhack Data Analytics Bootcamp.
