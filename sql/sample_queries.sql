-- sql/sample_queries.sql

-- 1. Top 5 most-rented vehicles (by count)
SELECT v.reg_number, v.make_model, COUNT(r.rental_id) AS rentals_count
FROM vehicles v
LEFT JOIN rentals r ON v.vehicle_id = r.vehicle_id
GROUP BY v.reg_number, v.make_model
ORDER BY rentals_count DESC
FETCH FIRST 5 ROWS ONLY;

-- 2. Monthly revenue (payments)
SELECT TO_CHAR(pay_date,'YYYY-MM') AS month, SUM(amount) AS revenue
FROM payments
GROUP BY TO_CHAR(pay_date,'YYYY-MM')
ORDER BY month;

-- 3. Current availability by category
SELECT category, COUNT(*) AS total, SUM(CASE WHEN status='AVAILABLE' THEN 1 ELSE 0 END) AS available
FROM vehicles
GROUP BY category;

-- 4. Active rentals with days elapsed
SELECT r.rental_id, v.reg_number, c.full_name, r.start_date, TRUNC(SYSDATE)-TRUNC(r.start_date)+1 AS days_elapsed
FROM rentals r
JOIN vehicles v ON r.vehicle_id = v.vehicle_id
JOIN customers c ON r.customer_id = c.customer_id
WHERE r.status='ACTIVE';
