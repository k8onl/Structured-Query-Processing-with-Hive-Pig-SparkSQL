CREATE DATABASE IF NOT EXISTS Emp_Dep;
use Emp_Dep;

CREATE EXTERNAL TABLE IF NOT EXISTS employees (employee_id INT, first_name STRING, last_name STRING, salary DECIMAL(10, 2), department_id INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/cloudera/emp';

CREATE EXTERNAL TABLE IF NOT EXISTS departments (department_id INT, department_name STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/cloudera/dept';


--INNER JOIN 'retrive first and last name of an employee work in a department'
SELECT e.first_name, e.last_name, d.department_name FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id;


-- average salary for each department (Grouped by department_name)
SELECT d.department_name , AVG(e.salary) AS avg_salary , COUNT(*) AS emp_num
FROM departments d
JOIN employees e
    ON e.department_id = d.department_id
GROUP BY d.department_name;


-- retrieve employees ranked by salary for each department
SELECT 
    first_name,
    department_name,
    salary,
    rank_in_dept
FROM (
    SELECT
        e.first_name,
        d.department_name,
        e.salary,
        DENSE_RANK() OVER (PARTITION BY d.department_name ORDER BY e.salary DESC) AS rank_in_dept
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
) t
WHERE rank_in_dept <= 3;