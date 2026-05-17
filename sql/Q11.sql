--QUERY 11


WITH YearlyStats AS (
    SELECT 
        main_doctor_amka, 
        COUNT(procedure_id) AS proc_count
    FROM Medical_Procedure
    WHERE YEAR(start_time) = YEAR(CURDATE()) 
    GROUP BY main_doctor_amka
)
SELECT 
    main_doctor_amka AS 'ΑΜΚΑ Κύριου Ιατρού', 
    proc_count AS 'Πλήθος Επεμβάσεων στο Τρέχον Έτος'
FROM YearlyStats
WHERE proc_count <= (SELECT MAX(proc_count) FROM YearlyStats) - 5
ORDER BY proc_count DESC;

