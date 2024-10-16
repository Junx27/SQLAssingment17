--membuat tabel employees
CREATE TABLE employees (
	employee_id int primary key,
	first_name varchar(20),
	last_name varchar(20),
	salary decimal(10),
	hire_date date,
	department_id int,
	foreign key (department_id) references departments(department_id)
);


--menambahkan data ke dalam tabel employees
INSERT INTO employees (employee_id, first_name, last_name, salary, hire_date, department_id) VALUES
(1, 'John', 'Doe', 5000.00, '2020-01-15', 1),
(2, 'Jane', 'Smith', 6000.00, '2021-05-12', 2),
(3, 'Mark', 'Brown', 7000.00, '2019-10-30', 1),
(4, 'Bob', 'Johnson', 5500.00, '2019-11-30', 3),
(5, 'Alice', 'Williams', 4000.00, '2022-07-19', 2),
(6, 'Charlie', 'Wilson', 4500.00, '2024-10-30', NULL);

--menampilkan data pada tabel employees
SELECT * FROM employees e ;



--membuat tabel departments
CREATE TABLE departments (
	department_id int primary key,
	department_name varchar(20)
);


--menambahkan data pada tabel departments
INSERT INTO departments (department_id, department_name) VALUES
(1, 'IT'),
(2, 'HR'),
(3, 'Finance');


--menampilkan data pada tabel departments
SELECT * FROM departments;


--membuat tabel projects
CREATE TABLE projects (
	project_id int primary key,
	project_name varchar(20),
	start_date date,
	department_id int,
	foreign key (department_id) references departements(department_id)
);



--menambahkan data pada tabel projects
INSERT INTO projects (project_id, project_name, start_date, department_id) VALUES
(1, 'Project Alpha', '2022-01-01', 1),
(2, 'Project Beta', '2021-11-15', 1),
(3, 'Project Gamma', '2020-06-10', 2),
(4, 'Project Delta', '2023-03-20', 3),
(5, 'Project Epsilon', '2024-08-01', NULL);


--melihat data pada tabel projects
SELECT * FROM  projects;


--membuat tabel employee_projects
CREATE TABLE employee_projects (
	employee_id int,
	project_id int,
	hours_worked decimal(20),
	foreign key (employee_id) references employees(employee_id),
	foreign key (project_id) references projects(project_id)
);


--memasukan data pada tabel employee_projects
INSERT INTO employee_projects (employee_id, project_id, hours_worked) VALUES
(1, 1, 45.5),  
(1, 2, 20.0),  
(2, 3, 30.0),  
(3, 1, 50.0),  
(4, 4, 40.0),  
(5, 3, 25.0);


--menampilkan data pada employee_projects
SELECT  * FROM employee_projects;





--menampilkan informasi employee_id, first_name, last_name 
--dan salary dari gaji diatas rata-rata di dalam departemenya

SELECT employee_id, first_name, last_name, salary 
FROM employees e
WHERE salary > (SELECT AVG(salary) from employees e2 WHERE department_id = e.department_id);


--menampilkan jumlah total kerja dengan parameter department tertentu
SELECT p.project_id, p.project_name, SUM(ep.hours_worked) AS total_hours
FROM projects p
JOIN employee_projects ep ON p.project_id = ep.project_id
WHERE p.department_id = 1
GROUP BY p.project_id, p.project_name;


--membuat CTE untuk memnampilkan ranking masing-masing departments
WITH RankedEmployees AS (
    SELECT 
        employee_id,
        first_name,
        last_name,
        salary,
        department_id,
        DENSE_RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS salary_rank
    FROM employees
)
SELECT *
FROM RankedEmployees;


--menampilkan nama department denga jumlah karyawan beserta rata-rata gaji
SELECT 
    d.department_name,
    COUNT(e.employee_id) AS total_employees,
    AVG(e.salary) AS average_salary
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name;


--menampilkan peringkat berdasarkan gaji tertinggi sampai terendah
SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    DENSE_RANK() OVER (ORDER BY salary DESC) AS rank
FROM employees;


--membuat index untuk mempercepat pencarian
CREATE INDEX idx_employee_id ON employee_projects(employee_id);
CREATE INDEX idx_project_id ON employee_projects(project_id);
CREATE INDEX idx_department_id_projects ON projects(department_id);
CREATE INDEX idx_department_id_employees ON employees(department_id);


--menampilkan nama lengkap dengan project
SELECT CONCAT(e.first_name, ' ', e.last_name) AS full_name, p.project_name
FROM employees e
JOIN employee_projects ep ON e.employee_id = ep.employee_id
JOIN projects p ON ep.project_id = p.project_id
ORDER BY full_name ASC;


--menampilkan nama lengkap dengan departement
SELECT CONCAT(e.first_name, ' ', e.last_name) AS full_name, d.department_name 
FROM employees e
JOIN departments d ON e.department_id = d.department_id
ORDER BY full_name ASC;

--menampilkan depatement dengan gaji
SELECT  d.department_name, e.salary
FROM departments d 
JOIN employees e ON d.department_id = e.employee_id
ORDER BY e.salary DESC;

--menampilkan departement dengan project dengan gaji
SELECT d.department_name, p.project_name, e.salary
FROM departments d 
INNER JOIN projects p ON d.department_id = p.department_id
INNER JOIN employees e ON d.department_id = e.department_id
ORDER BY e.salary DESC;


--menggabungkan data employees, depatements, dan projects
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    d.department_name,
    p.project_name,
    e.salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
LEFT JOIN employee_projects ep ON e.employee_id = ep.employee_id
LEFT JOIN projects p ON ep.project_id = p.project_id
ORDER BY e.salary DESC, full_name ASC;
