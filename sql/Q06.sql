--QUERY 6

WITH PatientEvaluations AS (
    SELECT 
        h.admission_id,
        
        CASE 
            WHEN e.evaluation_id IS NOT NULL 
            THEN (e.nursing_care + e.cleanliness + e.food + e.overall_experience) 
            ELSE 0 
        END AS general_score_sum,
        CASE 
            WHEN e.evaluation_id IS NOT NULL THEN 4 
            ELSE 0 
        END AS general_score_count,
        
        COALESCE(de.doc_score_sum, 0) AS doctor_score_sum,
        COALESCE(de.doc_score_count, 0) AS doctor_score_count

    FROM Hospitalization h
    LEFT JOIN Evaluation e ON h.admission_id = e.admission_id
    LEFT JOIN (
        SELECT admission_id, SUM(medical_care) AS doc_score_sum, COUNT(medical_care) AS doc_score_count
        FROM Doctor_Evaluation
        GROUP BY admission_id
    ) de ON h.admission_id = de.admission_id
    WHERE h.patient_amka = '10000000009' 
)

SELECT 
    h.admission_id AS 'ID Νοσηλείας',
    h.admission_date AS 'Ημερομηνία Εισαγωγής',
    h.discharge_date AS 'Ημερομηνία Εξιτηρίου',
    h.admission_diagnosis_code AS 'Διάγνωση (ICD-10)',
    h.total_cost AS 'Συνολικό Κόστος (€)',
    ROUND(
        (pe.general_score_sum + pe.doctor_score_sum) / 
        NULLIF(pe.general_score_count + pe.doctor_score_count, 0)
    , 2) AS 'Συνολικός Μ.Ο. Αξιολόγησης'

FROM Hospitalization h
JOIN PatientEvaluations pe ON h.admission_id = pe.admission_id
ORDER BY h.admission_date DESC;




-- (α) το καλο σεναριο

EXPLAIN
WITH PatientEvaluations AS (
    SELECT 
        h.admission_id,
        CASE 
            WHEN e.evaluation_id IS NOT NULL 
            THEN (e.nursing_care + e.cleanliness + e.food + e.overall_experience) 
            ELSE 0 
        END AS general_score_sum,
        CASE 
            WHEN e.evaluation_id IS NOT NULL THEN 4 
            ELSE 0 
        END AS general_score_count,
        COALESCE(de.doc_score_sum, 0) AS doctor_score_sum,
        COALESCE(de.doc_score_count, 0) AS doctor_score_count
    FROM Hospitalization h
    LEFT JOIN Evaluation e ON h.admission_id = e.admission_id
    LEFT JOIN (
        SELECT admission_id, SUM(medical_care) AS doc_score_sum, COUNT(medical_care) AS doc_score_count
        FROM Doctor_Evaluation
        GROUP BY admission_id
    ) de ON h.admission_id = de.admission_id
    WHERE h.patient_amka = '10000000009'
)
SELECT 
    h.admission_id AS 'ID Νοσηλείας',
    h.admission_date AS 'Ημερομηνία Εισαγωγής',
    h.discharge_date AS 'Ημερομηνία Εξιτηρίου',
    h.admission_diagnosis_code AS 'Διάγνωση (ICD-10)',
    h.total_cost AS 'Συνολικό Κόστος (€)',
    ROUND(
        (pe.general_score_sum + pe.doctor_score_sum) / 
        NULLIF(pe.general_score_count + pe.doctor_score_count, 0)
    , 2) AS 'Συνολικός Μ.Ο. Αξιολόγησης'
FROM Hospitalization h
JOIN PatientEvaluations pe ON h.admission_id = pe.admission_id
ORDER BY h.admission_date DESC;



-- (β) το κακο σεναριο

EXPLAIN
SELECT 
    h.admission_id AS 'ID Νοσηλείας',
    h.admission_date AS 'Ημερομηνία Εισαγωγής',
    h.discharge_date AS 'Ημερομηνία Εξιτηρίου',
    h.admission_diagnosis_code AS 'Διάγνωση (ICD-10)',
    h.total_cost AS 'Συνολικό Κόστος (€)',
    ROUND(
        (
            COALESCE(e.nursing_care + e.cleanliness + e.food + e.overall_experience, 0) 
            + COALESCE(de.doc_score_sum, 0)
        ) / 
        NULLIF(
            (CASE WHEN e.evaluation_id IS NOT NULL THEN 4 ELSE 0 END) 
            + COALESCE(de.doc_score_count, 0)
        , 0)
    , 2) AS 'Συνολικός Μ.Ο. Αξιολόγησης'
FROM Hospitalization h
LEFT JOIN Evaluation e ON h.admission_id = e.admission_id
LEFT JOIN (
    SELECT admission_id, SUM(medical_care) AS doc_score_sum, COUNT(medical_care) AS doc_score_count
    FROM Doctor_Evaluation
    GROUP BY admission_id
) de ON h.admission_id = de.admission_id

-- ΕΔΩ ΤΥΦΛΩΝΟΥΜΕ ΤΗ ΒΑΣΗ ΜΕ ΤΟ CONCAT ΚΑΙ ΤΗΝ ΑΝΑΓΚΑΖΟΥΜΕ ΣΕ FULL TABLE SCAN
WHERE CONCAT(h.patient_amka, '') = '10000000009';


