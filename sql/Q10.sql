--QUERY 10 

WITH AdmissionIngredients AS (
    -- Το DISTINCT διασφαλίζει ότι αν δοθούν 2 φάρμακα με την ΙΔΙΑ ουσία, θα μετρηθεί ως 1 για τη νοσηλεία.
    SELECT DISTINCT 
        p.admission_id, 
        ai.ingredient_id, 
        ai.ingredient_name
    FROM Prescription p
    JOIN Drug_Ingredient di ON p.drug_ema_code = di.ema_code
    JOIN Active_Ingredient ai ON di.ingredient_id = ai.ingredient_id
)
-- Self-Join για να βρούμε τα ζεύγη που δόθηκαν μαζί στην ίδια νοσηλεία
SELECT 
    a1.ingredient_name AS 'Δραστική Ουσία 1',
    a2.ingredient_name AS 'Δραστική Ουσία 2',
    COUNT(*) AS 'Συχνότητα Εμφάνισης (Ζεύγος)'
FROM AdmissionIngredients a1
JOIN AdmissionIngredients a2 
    ON a1.admission_id = a2.admission_id    -- Στην ίδια νοσηλεία
   AND a1.ingredient_id < a2.ingredient_id  -- Κόλπο για να μην έχουμε διπλοεγγραφές π.χ. (A,B) και (B,A)
GROUP BY 
    a1.ingredient_id, 
    a1.ingredient_name, 
    a2.ingredient_id, 
    a2.ingredient_name
ORDER BY 
    `Συχνότητα Εμφάνισης (Ζεύγος)` DESC
LIMIT 3;
