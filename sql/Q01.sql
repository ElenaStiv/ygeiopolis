-- QUERY 1


WITH AdmissionCosts AS (
    -- ΒΗΜΑ 1: Υπολογισμός εξόδων ανά μία νοσηλεία
    SELECT 
        h.admission_id,
        YEAR(h.admission_date) AS admission_year,
        h.department_id,
        h.ken_id,
        h.patient_amka,
        k.base_cost,
        
        CASE 
            WHEN DATEDIFF(h.discharge_date, h.admission_date) > k.duration 
            THEN (DATEDIFF(h.discharge_date, h.admission_date) - k.duration) * 100
            ELSE 0 
        END AS extra_days_cost,
        
        (SELECT COALESCE(SUM(cost), 0) FROM Lab_Test WHERE admission_id = h.admission_id) AS lab_cost,
        (SELECT COALESCE(SUM(cost), 0) FROM Medical_Procedure WHERE admission_id = h.admission_id) AS procedure_cost
        
    FROM Hospitalization h
    JOIN KEN k ON h.ken_id = k.ken_id
    WHERE h.discharge_date IS NOT NULL
)

-- ==========================================
-- ΜΕΡΟΣ 1: Οι Αναλυτικές Γραμμές
-- ==========================================
SELECT 
    ac.admission_year AS 'Έτος',
    dept.name AS 'Τμήμα',
    CAST(k.ken_id AS CHAR) AS 'Κωδικός ΚΕΝ / Σύνολο', 
    p.insurance AS 'Ασφαλιστικός Φορέας',
    COUNT(ac.admission_id) AS 'Πλήθος Νοσηλειών',
    SUM(ac.base_cost) AS 'Βασικό Κόστος ΚΕΝ',
    SUM(ac.extra_days_cost) AS 'Πρόσθετη Χρέωση (Υπέρβαση)',
    SUM(ac.lab_cost) AS 'Κόστος Εξετάσεων',
    SUM(ac.procedure_cost) AS 'Κόστος Επεμβάσεων',
    SUM(ac.extra_days_cost + ac.lab_cost + ac.procedure_cost) AS 'Συνολικά Έσοδα'
FROM AdmissionCosts ac
JOIN Department dept ON ac.department_id = dept.department_id
JOIN Patient p ON ac.patient_amka = p.amka
JOIN KEN k ON ac.ken_id = k.ken_id
GROUP BY 
    ac.admission_year, dept.name, k.ken_id, p.insurance

UNION ALL

-- ==========================================
-- ΜΕΡΟΣ 2: Οι Γραμμές των Συνόλων (ανά τμήμα/έτος)
-- ==========================================
SELECT 
    ac.admission_year AS 'Έτος',
    dept.name AS 'Τμήμα',
    '--- ΣΥΝΟΛΟ ΤΜΗΜΑΤΟΣ ---' AS 'Κωδικός ΚΕΝ / Σύνολο', 
    '-' AS 'Ασφαλιστικός Φορέας',
    COUNT(ac.admission_id) AS 'Πλήθος Νοσηλειών',
    SUM(ac.base_cost) AS 'Βασικό Κόστος ΚΕΝ',
    SUM(ac.extra_days_cost) AS 'Πρόσθετη Χρέωση (Υπέρβαση)',
    SUM(ac.lab_cost) AS 'Κόστος Εξετάσεων',
    SUM(ac.procedure_cost) AS 'Κόστος Επεμβάσεων',
    SUM(ac.extra_days_cost + ac.lab_cost + ac.procedure_cost) AS 'Συνολικά Έσοδα'
FROM AdmissionCosts ac
JOIN Department dept ON ac.department_id = dept.department_id
-- Εδώ κάνουμε GROUP BY ΜΟΝΟ στο Έτος και το Τμήμα!
GROUP BY 
    ac.admission_year, dept.name

ORDER BY 
    `Έτος` DESC, 
    `Τμήμα` ASC, 
    `Κωδικός ΚΕΝ / Σύνολο` ASC;
