--QUERY 5

SELECT 
    d.amka AS 'ΑΜΚΑ Ιατρού',
    st.first_name AS 'Όνομα',
    st.last_name AS 'Επώνυμο',
    TIMESTAMPDIFF(YEAR, st.birth_date, CURDATE()) AS 'Ηλικία',
    COUNT(mp.procedure_id) AS 'Πλήθος Χειρουργείων'
FROM Doctors d
JOIN Staff st ON d.amka = st.amka
JOIN Medical_Procedure mp ON d.amka = mp.main_doctor_amka
WHERE TIMESTAMPDIFF(YEAR, st.birth_date, CURDATE()) < 35  -- Ηλικία κάτω των 35
  AND mp.category = 'Χειρουργική'                         -- Μόνο χειρουργικές επεμβάσεις
GROUP BY 
    d.amka, 
    st.first_name, 
    st.last_name, 
    st.birth_date
ORDER BY 
    COUNT(mp.procedure_id) DESC;
