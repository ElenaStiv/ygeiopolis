-- QUERY 14

WITH YearlyDiagnosisStats AS (
    SELECT 
        admission_diagnosis_code AS icd10_code,
        YEAR(admission_date) AS admission_year,
        COUNT(admission_id) AS total_admissions
    FROM Hospitalization
    WHERE admission_diagnosis_code IS NOT NULL
    GROUP BY admission_diagnosis_code, YEAR(admission_date)
    -- Φίλτρο: Κρατάμε μόνο όσα έχουν τουλάχιστον 5 περιστατικά σε αυτό το έτος
    HAVING COUNT(admission_id) >= 5
)
SELECT 
    y1.icd10_code AS 'Κωδικός ICD-10',
    y1.admission_year AS 'Έτος 1',
    y2.admission_year AS 'Έτος 2 (Συνεχόμενο)',
    y1.total_admissions AS 'Αριθμός Εισαγωγών (Κοινός)'
FROM YearlyDiagnosisStats y1
JOIN YearlyDiagnosisStats y2 
    ON y1.icd10_code = y2.icd10_code             
   AND y2.admission_year = y1.admission_year + 1 
   AND y1.total_admissions = y2.total_admissions 
ORDER BY 
    y1.icd10_code ASC, 
    y1.admission_year ASC;