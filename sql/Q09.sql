--QUERY 9


WITH PatientYearlyStats AS (
    -- Υπολογίζουμε συνολικές ημέρες ανά ασθενή και ανά έτος
    SELECT 
        h.patient_amka, 
        p.first_name, 
        p.last_name, 
        YEAR(h.admission_date) AS admission_year, 
        SUM(DATEDIFF(h.discharge_date, h.admission_date)) AS total_days
    FROM Hospitalization h
    JOIN Patient p ON h.patient_amka = p.amka
    WHERE h.discharge_date IS NOT NULL
    GROUP BY h.patient_amka, p.first_name, p.last_name, YEAR(h.admission_date)
    -- μόνο όσοι έχουν συνολικά πάνω από 15 ημέρες το χρόνο
    HAVING SUM(DATEDIFF(h.discharge_date, h.admission_date)) > 15
)
SELECT 
    t1.admission_year AS 'Έτος',
    t1.total_days AS 'Συνολικές Ημέρες',
    t1.first_name AS 'Όνομα',
    t1.last_name AS 'Επώνυμο',
    t1.patient_amka AS 'ΑΜΚΑ'
FROM PatientYearlyStats t1
-- Φιλτράρουμε για να βρούμε όσους έχουν τον ίδιο αριθμό ημερών στο ίδιο έτος
WHERE EXISTS (
    SELECT 1 
    FROM PatientYearlyStats t2 
    WHERE t1.admission_year = t2.admission_year 
      AND t1.total_days = t2.total_days 
      AND t1.patient_amka <> t2.patient_amka 
)
ORDER BY t1.admission_year DESC, t1.total_days DESC;
