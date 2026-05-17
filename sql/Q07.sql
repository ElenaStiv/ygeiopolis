--QUERY 7


SELECT 
    s.ingredient_name AS 'Δραστική Ουσία',
    COUNT(DISTINCT a.patient_amka) AS 'Αριθμός Αλλεργικών Ασθενών',
    COUNT(DISTINCT ds.ema_code) AS 'Αριθμός Φαρμάκων που την περιέχουν'
FROM active_ingredient s
-- Χρησιμοποιούμε LEFT JOIN ώστε να εμφανιστούν και οι ουσίες 
-- που ίσως δεν έχουν αλλεργικούς ασθενείς ή δεν υπάρχουν σε φάρμακα
LEFT JOIN patient_allergy a ON s.ingredient_id = a.ingredient_id
LEFT JOIN drug_ingredient ds ON s.ingredient_id = ds.ingredient_id
GROUP BY 
    s.ingredient_id, 
    s.ingredient_name
ORDER BY 
    COUNT(DISTINCT a.patient_amka) DESC, 
    s.ingredient_name ASC;
