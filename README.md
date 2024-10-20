# SQL-Case-Study-on-Formula-1-Seasons

## Table of Contents

- [Project Overview](project-overview)
- [Data Source](data-source)
- [Major steps followed](major-steps-followed)
- [Insights and Findings](insights-and-findings)
- [Recommendations and further scope](recommendations-and-further-scope)


### Project Overview

Formula One (more commonly known as Formula 1 or F1) is the highest class of international racing for open-wheel single-seater formula racing cars sanctioned by the Fédération Internationale de l'Automobile (FIA). 

![formula one car](https://github.com/user-attachments/assets/0498050a-1ad6-4de7-9297-4d504089b9ba)


In this project, I've dived deeper into the Formula One Seasons to analyze to performance of the F1 drivers, their performances, constructor performances, and so on using SQL. I have uncovered various insights like the youngest and oldest F1 drivers, the most successful F1 drivers, and F1 teams. I even tried building custom reports containing all the details like year, race id, circuit location, driver name and positions, constructor name and positions, fastest lap timings, and so on.


![SQL report preview](https://github.com/user-attachments/assets/5b3cf9a2-fa62-4494-9620-4163b2cd22b0)

Preview of one of the reports from this project


### Data Source

I've taken this dataset from Kaggle. If you want to follow along, I'm sharing the link to the dataset below:

https://www.kaggle.com/datasets/rohanrao/formula-1-world-championship-1950-2020?resource=download


### Major steps followed

1. Creating a database in PostgreSQL
2. Running the 'run.sql' file in Python code editor to create all the required tables and insert data into them.
3. Data cleaning and preprocessing.
4. Validating the data counts of all the tables and checking if there are any duplicates or redundancies.
5. Solving the basic insights like most successful drivers, youngest and oldest drivers etc.
6. Creating reports for an entire season with all the required columns for it.


### Insights and Findings

1. Britain has produced the most F1 drivers and USA has the most number of F1 circuits.
2. 'Ferrari' has been the most successful team in the F1 history winning 15 constructor championships and 234 race wins, followed by 'McLaren' with 165 wins and 'Mercedes' with 145 wins
3. 'Philippe Étancelin' was the oldest driver whereas 'Oscar Piastri' was the youngest.  
4. The 'Autodromo Nazionale di Monza' circuit at Monza in Italy has hosted the most F1 races, viz a total of 73 races
5. India has hosted the F1 race for 3 times at the 'Buddh International Circuit' in Noida.
6. 'Lewis Hamilton' has been the most successful F1 driver with 125 wins followed by the legendary 'Michael Schumacher' with 121 wins.

### Recommendations and further scope

- I've explored and analyzed a limited number of insights with this data. Since this is huge historical dataset, a lot of other insights can be drawn by diving deeper.
- More detailed custom reports can be built to analyze the data more categorically.
- These reports can also then be used for visualizations if connected to any of the bi tools like Power BI.
