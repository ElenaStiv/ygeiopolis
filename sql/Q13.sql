--QUERY 13

WITH RECURSIVE DoctorHierarchy AS (
    SELECT 
        d.amka AS original_doctor_amka,
        d.supervisor_amka AS current_supervisor_amka,
        1 AS hierarchy_level
    FROM Doctors d
    WHERE d.supervisor_amka IS NOT NULL

    UNION ALL

    SELECT 
        dh.original_doctor_amka,
        dsup.supervisor_amka,
        dh.hierarchy_level + 1
    FROM DoctorHierarchy dh
    JOIN Doctors dsup ON dh.current_supervisor_amka = dsup.amka
    WHERE dsup.supervisor_amka IS NOT NULL
)
SELECT 
    dh.original_doctor_amka AS 'ΑΜΚΑ Ιατρού',
    st1.last_name AS 'Επώνυμο Ιατρού',
    dh.hierarchy_level AS 'Βαθμίδα Εποπτείας',
    dh.current_supervisor_amka AS 'ΑΜΚΑ Επόπτη',
    st2.last_name AS 'Επώνυμο Επόπτη',
    CASE 
        WHEN dh.hierarchy_level = 1 THEN 'Άμεσος Επόπτης'
        ELSE CONCAT('Επόπτης ', dh.hierarchy_level, 'ου Επιπέδου')
    END AS 'Ένδειξη Επιπέδου'
FROM DoctorHierarchy dh
JOIN Staff st1 ON dh.original_doctor_amka = st1.amka
JOIN Staff st2 ON dh.current_supervisor_amka = st2.amka
ORDER BY 
    st1.last_name ASC, 
    dh.hierarchy_level ASC;