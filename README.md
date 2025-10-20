# Pagila-advanced
pagila-advanced-queries
Advanced SQL Data Analysis – Pagila Database
 --Project Overview

This project showcases advanced SQL querying techniques using the Pagila database — a PostgreSQL sample dataset derived from Sakila.
The goal was to simulate real-world data analyst tasks through 30 progressively challenging questions, from basic joins to complex pattern recognition and recursive queries.

--Key Concepts & Techniques Used

CTE (Common Table Expressions) – structured complex logic into readable blocks

Window Functions – used RANK(), ROW_NUMBER(), and STDDEV() for ranking and variability analysis

String Functions – applied STRING_AGG(), SPLIT_PART(), and pattern-based filtering

Aggregation & Grouping – SUM(), COUNT(), AVG(), and multi-level grouping

Self Join – explored actor-to-actor and recursive relationships (3-depth connectivity)

Recursive Queries – built multi-level relationship expansions within the film-actor network

Pattern Recognition – identified and aggregated film series (e.g., Alien 1, Alien 2, Alien 3)

Performance Considerations – used indexing awareness and LIMIT for heavy queries

--Example Analytical Questions

Find the most variable paying customers using standard deviation.

Identify multi-category films (films that appear under more than one genre).

Detect the highest-grossing film series using pattern recognition and string aggregation.

Explore actor connection networks up to 3 levels deep via recursive self-joins.

 Tools & Environment

Database: PostgreSQL (Pagila schema)

IDE: pgAdmin 4

--Language: SQL

Focus: Query logic, data exploration, analytical reasoning

 --Learning Outcomes:

This project enhanced my ability to:

Think like a data analyst, not just a query writer.

Recognize hidden relationships in complex datasets.

Write optimized, modular, and high-performing SQL code.

Apply pattern recognition to uncover trends and structured insights.


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

⚙️ Installing the Pagila Database (PostgreSQL)
🧩 1. Download the Pagila Database

Pagila is the official PostgreSQL sample database (a port of MySQL’s Sakila).

Official download:

Go to the PostgreSQL Sample Databases page

Click Code → Download ZIP, or clone via terminal:

git clone https://github.com/devrimgunduz/pagila.git


This will give you two important files:

pagila-schema.sql
pagila-data.sql

🧱 2. Open pgAdmin and Connect to PostgreSQL

Launch pgAdmin 4.

Connect to your PostgreSQL server (default host: localhost, port: 5432).

Right-click Databases → Create → Database...

Name it: pagila

Owner: postgres (or your username)

Click Save ✅

📥 3. Load the Pagila Schema

Now we’ll create all tables, relationships, and constraints.

In pgAdmin, open Query Tool for your pagila database.

Click Open File and select pagila-schema.sql.

Run the script (F5 or the ▶️ Run button).

You’ll see tables like film, actor, payment, rental, etc. created.

📦 4. Load the Pagila Data

Now we’ll fill the tables with sample data.

In the same Query Tool, open pagila-data.sql.

Run it (F5 again).

This inserts thousands of rows across all tables — perfect for real-world SQL practice.
