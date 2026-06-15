create  database  employee_managment_system;
use  employee_managment_system;

-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);
-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);
select * from employee;
select * from jobdepartment;
select * from salarybonus;
select * from payroll;
select * from leaves;
select * from qualification;
-- -------------------------------- EMPLOYEE INSIGHTS -------------------------------------
-- 1
 -- How many unique employees are currently in the system? 
 
SELECT COUNT(DISTINCT FIRSTNAME,LASTNAME) as total_emp FROM EMPLOYEE;

-- 2
-- Which departments have the highest number of employees? 

select d.jobdept,count(e.emp_id) as total_emp from jobdepartment as d
join employee e 
on d.job_id = e.job_id
group by d.jobdept order by total_emp desc limit 1;

-- 3
--  What is the average salary per department? 
select d.jobdept ,avg(s.amount) as avg_sal from salarybonus as s
join jobdepartment as d on d.job_id=s.job_id
group by d.jobdept;

-- 4
--  Who are the top 5 highest-paid employees?

select e.firstname,e.lastname,s.amount from salarybonus as s
join employee as e on e.job_id = s.job_id
 order by amount desc limit 5;
 
 -- 5
 -- What is the total salary expenditure across the company?
 
 select sum(annual+bonus) as total_sal_exp from salarybonus;
 
 -- -------------------------2. JOB ROLE AND DEPARTMENT ANALYSIS------------------
 
 -- 6
 
 -- How many different job roles exist in each department?
 select * from jobdepartment;
 select jobdept, count( name)as dif_roles from jobdepartment 
 group by jobdept order by dif_roles desc;

-- 7

-- What is the average salary range per department?
select * from jobdepartment;
select * from salarybonus;
SELECT AVG(s.annual) AS avg_salary,d.jobdept FROM salarybonus s
JOIN jobdepartment d
ON d.job_id = s.job_id GROUP BY d.jobdept;
-- 8

-- Which job roles offer the highest salary? 
select d.name,max(s.annual) as high_sal  from salarybonus as s
join jobdepartment as d on d.job_id = s.job_id
group by d.name order by high_sal desc limit 1;
select * from jobdepartment;

-- 9
-- Which departments have the highest total salary allocation? 

select d.jobdept ,sum(s.amount) as high_sal  from salarybonus as s
join jobdepartment as d on d.job_id = s.job_id
group by d.jobdept order by high_sal desc limit 1;

-- -------------------------- 3. QUALIFICATION AND SKILLS ANALYSIS -------------------------
-- 10
-- How many employees have at least one qualification listed?
select * from qualification;
select count(distinct e.emp_id) as qualified_employees from employee as e
join
qualification as q on e.emp_id= q.emp_id;


-- 11
-- Which positions require the most qualifications?

select position,count(requirements) as total_qual from qualification group by position;

-- 12
-- Which employees have the highest number of qualifications?

select e.Emp_ID,e.firstname,e.lastname,count(q.requirements) as total_qual from qualification as q
join
employee as e on e.Emp_ID = q.Emp_ID group by e.Emp_ID,e.firstname,e.lastname;


-- ------------------------------------------4. LEAVE AND ABSENCE PATTERNS ---------------------------

-- 13

-- Which year had the most employees taking leaves?
select year(date) as year, 
count(*) as tot_leave from leaves 
group by year(date);

-- 14

-- What is the average number of leave days taken by its employees per department?
select * from jobdepartment;
select * from leaves;
SELECT
    d.jobdept,
    COUNT(*) / COUNT(DISTINCT e.emp_id) AS avg_leave_days
FROM leaves l
JOIN employee e
    ON e.emp_id = l.emp_id
JOIN jobdepartment d
    ON d.job_id = e.job_id
GROUP BY d.jobdept;


 -- 15
 -- Which employees have taken the most leaves? 
 
 select e.emp_id ,e.firstname,e.lastname, count(*) as tot_leaves from leaves as l
 join employee as e
 on e.emp_id = l.emp_id
 group by e.firstname,e.LastName,e.Emp_ID order by tot_leaves desc;
 
 -- 16
 -- What is the total number of leave days taken company-wide? 
 
 select count(*) as total_leaves from leaves;
 
 -- 17
 -- How do leave days correlate with payroll amounts? 
 SELECT e.emp_id,
       e.firstname,
       e.lastname,
       COUNT(l.leave_id) AS total_leaves,
       p.total_amount
FROM employee e
JOIN leaves l
ON e.emp_id = l.emp_id
JOIN payroll p
ON e.emp_id = p.emp_id
GROUP BY e.emp_id,e.firstname,e.lastname,p.total_amount
ORDER BY total_leaves DESC;
 
 
--  ----------------------------------5. PAYROLL AND COMPENSATION ANALYSIS -------------------------

-- 18

-- What is the total monthly payroll processed? 
 
 SELECT YEAR(date) AS year,
       MONTH(date) AS month,
       SUM(total_amount) AS total_monthly_payroll
FROM Payroll
GROUP BY YEAR(date), MONTH(date)
ORDER BY year, month; 
  
 -- 19
 -- What is the average bonus given per department?
 
 select avg(s.bonus) as avg_bonus,d.jobdept from salarybonus as s
 join jobdepartment as d
 on d.Job_ID = s.job_id
 group by d.JobDept;
 
 -- 20
 -- Which department receives the highest total bonuses? 
 
 select d.jobdept,max(s.bonus) as highest_bonus  from salarybonus as s
 join jobdepartment as d
 on d.Job_ID  = s.Job_ID
 group by d.jobdept
 order by highest_bonus desc limit 1;
-- 21
-- What is the average value of total_amount after considering leave deductions?

SELECT AVG(total_amount) AS avg_payroll_amount
FROM payroll;


 

