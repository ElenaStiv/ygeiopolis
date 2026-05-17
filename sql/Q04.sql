--QUERY 4


SELECT 
    d.amka, 
    AVG(de.medical_care) AS avg_medical_quality, 
    AVG(e.overall_experience) AS avg_hospital_experience
FROM Doctors d
JOIN Doctor_Evaluation de ON d.amka = de.doctor_amka
JOIN Evaluation e ON de.admission_id = e.admission_id
WHERE d.amka = '80000000001'  
GROUP BY d.amka;



-- (α) το καλο σεναριο

EXPLAIN
SELECT 
    d.amka, 
    AVG(de.medical_care) AS avg_medical_quality, 
    AVG(e.overall_experience) AS avg_hospital_experience
FROM Doctors d
JOIN Doctor_Evaluation de ON d.amka = de.doctor_amka
JOIN Evaluation e ON de.admission_id = e.admission_id
WHERE d.amka = '80000000001' 
GROUP BY d.amka;


-- (β) το κακο σεναριο

EXPLAIN
SELECT 
    d.amka, 
    AVG(de.medical_care) AS avg_medical_quality, 
    AVG(e.overall_experience) AS avg_hospital_experience
FROM Doctors d
JOIN Doctor_Evaluation de ON d.amka = CONCAT(de.doctor_amka, '')
JOIN Evaluation e ON de.admission_id = e.admission_id
WHERE d.amka = '80000000001' 
GROUP BY d.amka;



