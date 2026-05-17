--QUERY 3

--SELECT 
--    p.amka AS 'ΑΜΚΑ Ασθενούς',
--    p.first_name AS 'Όνομα',
--    p.last_name AS 'Επώνυμο',
--    dept.name AS 'Τμήμα',
--    COUNT(h.admission_id) AS 'Αριθμός Νοσηλειών',
--    SUM(h.total_cost) AS 'Συνολικό Κόστος Νοσηλείας'
--FROM Hospitalization h
--JOIN Patient p ON h.patient_amka = p.amka
--JOIN Department dept ON h.department_id = dept.department_id
--GROUP BY h.patient_amka, h.department_id
--HAVING COUNT(h.admission_id) > 3
--ORDER BY SUM(h.total_cost) DESC;

-- αιτιολόγηση της παραδοχής βρίσκεται στη τεχνική αναφορά


SELECT 
    p.amka AS 'ΑΜΚΑ Ασθενούς',
    p.first_name AS 'Όνομα',
    p.last_name AS 'Επώνυμο',
    dept.name AS 'Τμήμα',
    COUNT(h.admission_id) AS 'Αριθμός Νοσηλειών',
    -- Άθροισμα του total_cost που υπολογίσαμε προηγουμένως (ΚΕΝ + υπέρβαση)
    SUM(h.total_cost) AS 'Συνολικό Κόστος Νοσηλείας'
FROM Hospitalization h
JOIN Patient p ON h.patient_amka = p.amka
JOIN Department dept ON h.department_id = dept.department_id
GROUP BY h.patient_amka, h.department_id
HAVING COUNT(h.admission_id) >= 2
ORDER BY SUM(h.total_cost) DESC;
