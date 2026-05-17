-- QUERY 2


SELECT 
    d.amka AS 'ΑΜΚΑ Ιατρού',
    d.specialty AS 'Ειδικότητα',
    
    -- Έλεγχος αν ο ιατρός είχε έστω και μία εφημερία το τρέχον έτος
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM Shift_Staff ss 
            JOIN Shift s ON ss.shift_id = s.shift_id 
            WHERE ss.staff_amka = d.amka AND YEAR(s.shift_date) = YEAR(CURDATE())
        ) THEN 'ΝΑΙ'
        ELSE 'ΟΧΙ'
    END AS 'Εφημερία Φέτος',
    
    -- Καταμέτρηση των επεμβάσεων που έχει κάνει ως Κύριος Ιατρός
    (
        SELECT COUNT(procedure_id) 
        FROM Medical_Procedure mp 
        WHERE mp.main_doctor_amka = d.amka
    ) AS 'Σύνολο Επεμβάσεων (ως Κύριος)'

FROM Doctors d
WHERE d.specialty = 'Χειρουργός';