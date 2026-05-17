-- QUERY 15

SELECT 
    t.priority_level AS 'Επίπεδο Επείγοντος',
    COUNT(t.triage_id) AS 'Συνολικά Περιστατικά',
    
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, t.triage_datetime, h.admission_date)), 1) AS 'Μέσος Χρόνος Αναμονής (Min)',
    
    ROUND((COUNT(h.admission_id) / COUNT(t.triage_id)) * 100, 1) AS '% Εισαγωγών',
    
    GROUP_CONCAT(DISTINCT d.name SEPARATOR ', ') AS 'Τμήματα Παραπομπής'

FROM Triage t
LEFT JOIN Hospitalization h ON t.patient_amka = h.patient_amka 
    AND h.admission_date > t.triage_datetime 
    AND h.admission_date < DATE_ADD(t.triage_datetime, INTERVAL 24 HOUR)
LEFT JOIN Department d ON h.department_id = d.department_id
GROUP BY t.priority_level
ORDER BY t.priority_level ASC;