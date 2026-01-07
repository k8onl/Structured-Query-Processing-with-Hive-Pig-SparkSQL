departments = LOAD '/user/cloudera/dept/Departments.txt'
    USING PigStorage(',')
    AS (dept_id:int, dept_name:chararray);

employees = LOAD '/user/cloudera/emp/Employees.txt'
    USING PigStorage(',')
    AS (emp_id:int, first:chararray, last:chararray, salary:int, dept_id:int);

emp_with_dept = JOIN employees BY dept_id, departments BY dept_id;

cleaned = FOREACH emp_with_dept GENERATE
    employees::emp_id,
    employees::first,
    employees::last,
    employees::salary,
    departments::dept_name;

grouped = GROUP cleaned BY dept_name;

analytics = FOREACH grouped GENERATE
    group AS dept_name,
    COUNT(cleaned) AS num_employees,
    AVG(cleaned.salary) AS avg_salary;

STORE analytics INTO '/user/cloudera/output/analytics' USING PigStorage(',');

dept_group = GROUP cleaned BY dept_name;

ranked = FOREACH dept_group {
    sorted_emps = ORDER cleaned BY salary DESC;
    GENERATE group AS dept_name, sorted_emps;
};

top3 = FOREACH ranked {
    top_salaries = LIMIT sorted_emps 3;
    GENERATE FLATTEN(top_salaries);
};

STORE top3 INTO '/user/cloudera/output/top3_salaries' USING PigStorage(',');