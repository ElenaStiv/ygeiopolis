--QUERY 12


SELECT 
    dept.name AS 'Τμήμα',
    sh.shift_date AS 'Ημερομηνία',
    sh.shift_type AS 'Βάρδια',
    
    CASE 
        WHEN doc.amka IS NOT NULL THEN 'Ιατρός'
        WHEN n.amka IS NOT NULL THEN 'Νοσηλευτής'
        WHEN m.amka IS NOT NULL THEN 'Διοικητικό Προσωπικό'
        ELSE 'Άλλο'
    END AS 'Κατηγορία Προσωπικού',

    CASE 
        WHEN doc.amka IS NOT NULL THEN doc.specialty
        WHEN n.amka IS NOT NULL THEN n.rank  
        WHEN m.amka IS NOT NULL THEN m.role
        ELSE '-'
    END AS 'Υποκλάση (Ειδικότητα/Βαθμίδα/Ρόλος)',

    COUNT(ss.staff_amka) AS 'Αριθμός Ατόμων'

FROM Shift sh
JOIN Department dept ON sh.department_id = dept.department_id
JOIN Shift_Staff ss ON sh.shift_id = ss.shift_id

LEFT JOIN Doctors doc ON ss.staff_amka = doc.amka
LEFT JOIN Nurses n ON ss.staff_amka = n.amka
LEFT JOIN Management m ON ss.staff_amka = m.amka

WHERE sh.shift_date BETWEEN '2026-05-11' AND '2026-05-17'

GROUP BY 
    dept.name,
    sh.shift_date,
    sh.shift_type,
    CASE 
        WHEN doc.amka IS NOT NULL THEN 'Ιατρός'
        WHEN n.amka IS NOT NULL THEN 'Νοσηλευτής'
        WHEN m.amka IS NOT NULL THEN 'Διοικητικό Προσωπικό'
        ELSE 'Άλλο'
    END,
    CASE 
        WHEN doc.amka IS NOT NULL THEN doc.specialty
        WHEN n.amka IS NOT NULL THEN n.rank
        WHEN m.amka IS NOT NULL THEN m.role
        ELSE '-'
    END

ORDER BY 
    sh.shift_date ASC, 
    dept.name ASC, 
    'Κατηγορία Προσωπικού' ASC,
    'Υποκλάση (Ειδικότητα/Βαθμίδα/Ρόλος)' ASC;
