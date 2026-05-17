--QUERY 8


-- Βρίσκει τους Γιατρούς χωρίς βάρδια στις 2026-01-05 στο Τμήμα 1
SELECT amka, 'Ιατρός' AS Ιδιότητα FROM Doctors 
WHERE amka NOT IN (
    SELECT staff_amka FROM Shift_Staff ss JOIN Shift sh ON ss.shift_id = sh.shift_id 
    WHERE sh.shift_date = '2026-01-05' AND sh.department_id = 1
)
UNION
-- Βρίσκει τους Νοσηλευτές χωρίς βάρδια την ίδια μέρα στο ίδιο τμήμα
SELECT amka, 'Νοσηλευτής' AS Ιδιότητα FROM Nurses 
WHERE amka NOT IN (
    SELECT staff_amka FROM Shift_Staff ss JOIN Shift sh ON ss.shift_id = sh.shift_id 
    WHERE sh.shift_date = '2026-01-05' AND sh.department_id = 1
);
