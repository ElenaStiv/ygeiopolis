create database ygeiopolis;
use ygeiopolis;

DROP TABLE IF EXISTS Staff;
DROP TABLE IF EXISTS Doctor_Department;
DROP TABLE IF EXISTS Department;
DROP TABLE IF EXISTS Doctor;
DROP TABLE IF EXISTS Nurses;
DROP TABLE IF EXISTS Management;
DROP TABLE IF EXISTS Patient;
DROP TABLE IF EXISTS Emergency_Contact;
DROP TABLE IF EXISTS Bed;
DROP TABLE IF EXISTS Shift;
DROP TABLE IF EXISTS Shift_Staff;
DROP TABLE IF EXISTS Triage;
DROP TABLE IF EXISTS Drug_Ingredient;
DROP TABLE IF EXISTS Active_Ingredient;
DROP TABLE IF EXISTS KEN;
DROP TABLE IF EXISTS Diagnosis;
DROP TABLE IF EXISTS Hospitalization;
DROP TABLE IF EXISTS Evaluation;
DROP TABLE IF EXISTS Doctor_Evaluation;
DROP TABLE IF EXISTS Medical_Procedure;
DROP TABLE IF EXISTS Procedure_Assistant;
DROP TABLE IF EXISTS Room;
DROP TABLE IF EXISTS Lab_Test;
DROP TABLE IF EXISTS DRUG;
DROP TABLE IF EXISTS Patient_Allergy;
DROP TABLE IF EXISTS Prescription;


CREATE TABLE Staff (
    amka VARCHAR(20) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    age INT NOT NULL CHECK (age >= 18 AND age <= 75),
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    hire_date DATE NOT NULL,
    staff_type VARCHAR(20) NOT NULL CHECK (staff_type IN ('Doctor', 'Nurse', 'Management')),
    image_url VARCHAR(255),
    image_desc TEXT
);


CREATE TABLE Department (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    num_of_beds INT NOT NULL CHECK (num_of_beds >= 0),
    building_floor VARCHAR(50) NOT NULL,
    director_amka VARCHAR(20) NOT NULL,
    image_url VARCHAR(255),
    image_desc TEXT,
    FOREIGN KEY (director_amka) REFERENCES Staff(amka)
);


CREATE TABLE Doctors (
    amka VARCHAR(20) PRIMARY KEY,
    licence_number VARCHAR(50) NOT NULL,
    specialty VARCHAR(100) NOT NULL,
    rank VARCHAR(50) NOT NULL,
    supervisor_amka VARCHAR(20), 
    FOREIGN KEY (amka) REFERENCES Staff(amka),
    FOREIGN KEY (supervisor_amka) REFERENCES Doctors(amka)
);

CREATE TABLE Nurses (
    amka VARCHAR(20) PRIMARY KEY,
    rank VARCHAR(50) NOT NULL,
    department_id INT NOT NULL,
    FOREIGN KEY (amka) REFERENCES Staff(amka),
    FOREIGN KEY (department_id) REFERENCES Department(department_id)
);

CREATE TABLE Management (
    amka VARCHAR(20) PRIMARY KEY,
    role VARCHAR(100) NOT NULL,
    office VARCHAR(50) NOT NULL,
    department_id INT NOT NULL,
    FOREIGN KEY (amka) REFERENCES Staff(amka),
    FOREIGN KEY (department_id) REFERENCES Department(department_id)
);

-- 6. Πίνακας Ασθενών
CREATE TABLE Patient (
    amka VARCHAR(20) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    father_name VARCHAR(50),
    sex VARCHAR(10) NOT NULL CHECK (sex IN ('Male', 'Female', 'Other')),
    birth_date DATE NOT NULL,
    address VARCHAR(150),
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) UNIQUE,
    weight FLOAT CHECK (weight > 0),
    height FLOAT CHECK (height > 0),
    job VARCHAR(100),
    citizenship VARCHAR(50),
    insurance VARCHAR(100)
);

-- 7. Πίνακας Επαφής Έκτακτης Ανάγκης (Εξαρτάται από τον Patient)
CREATE TABLE Emergency_Contact (
    contact_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_amka VARCHAR(20) NOT NULL,
    contact_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    FOREIGN KEY (patient_amka) REFERENCES Patient(amka)
);

-- 8. Πίνακας Κλινών (Beds)
CREATE TABLE Bed (
    bed_id INT AUTO_INCREMENT PRIMARY KEY,
    department_id INT NOT NULL,
    bed_number VARCHAR(20) NOT NULL,
    bed_type VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    
    -- Προσθέτουμε τις εικόνες επειδή είναι "χειροπιαστή" οντότητα/εξοπλισμός
    image_url VARCHAR(255),
    image_desc TEXT,
    
    FOREIGN KEY (department_id) REFERENCES Department(department_id)
);

-- 9. Πίνακας Βαρδιών (Shift)
CREATE TABLE Shift (
    shift_id INT AUTO_INCREMENT PRIMARY KEY,
    department_id INT NOT NULL,
    shift_date DATE NOT NULL,
    shift_type VARCHAR(15) NOT NULL CHECK (shift_type IN ('morning', 'afternoon', 'night')),
    FOREIGN KEY (department_id) REFERENCES Department(department_id),
    
    -- Περιορισμός: Το ίδιο τμήμα δεν μπορεί να έχει 2 "πρωινές" βάρδιες την ίδια μέρα
    UNIQUE (department_id, shift_date, shift_type)
);

-- 10. Πίνακας Σύνδεσης: Προσωπικό - Βάρδια (Shift_Staff)
-- Εδώ το Πρωτεύον Κλειδί είναι σύνθετο (shift_id + staff_amka)
CREATE TABLE Shift_Staff (
    shift_id INT NOT NULL,
    staff_amka VARCHAR(20) NOT NULL,
    
    PRIMARY KEY (shift_id, staff_amka),
    FOREIGN KEY (shift_id) REFERENCES Shift(shift_id),
    FOREIGN KEY (staff_amka) REFERENCES Staff(amka)
);

-- 11. Πίνακας Σύνδεσης: Ιατρός - Τμήμα (Doctor_Department)
-- Η εκφώνηση λέει "Κάθε ιατρός μπορεί να ανήκει σε ένα ή περισσότερα τμήματα"
CREATE TABLE Doctor_Department (
    doctor_amka VARCHAR(20) NOT NULL,
    department_id INT NOT NULL,
    
    PRIMARY KEY (doctor_amka, department_id),
    FOREIGN KEY (doctor_amka) REFERENCES Doctors(amka),
    FOREIGN KEY (department_id) REFERENCES Department(department_id)
);

-- 12. Πίνακας Διαλογής (Triage) - Γίνεται στα Επείγοντα από Νοσηλευτή
CREATE TABLE Triage (
    triage_id INT AUTO_INCREMENT PRIMARY KEY,
    triage_datetime DATETIME NOT NULL,
    symptoms_desc TEXT NOT NULL,
    priority_level INT NOT NULL CHECK (priority_level BETWEEN 1 AND 5),
    nurse_amka VARCHAR(20) NOT NULL,
    patient_amka VARCHAR(20) NOT NULL,
    
    FOREIGN KEY (nurse_amka) REFERENCES Nurses(amka),
    FOREIGN KEY (patient_amka) REFERENCES Patient(amka)
);

-- 13. Πίνακας ΚΕΝ (Κλειστά Ενοποιημένα Νοσήλια) - Βάση για την κοστολόγηση
CREATE TABLE KEN (
    ken_id INT AUTO_INCREMENT PRIMARY KEY,
    description TEXT NOT NULL,
    base_cost FLOAT NOT NULL CHECK (base_cost >= 0),
    duration INT NOT NULL CHECK (duration > 0)
);

-- 14. Πίνακας Διαγνώσεων (ICD-10)
CREATE TABLE Diagnosis (
    icd10_code VARCHAR(20) PRIMARY KEY,
    description TEXT NOT NULL
);

SET FOREING_KEY_CHECKS = 0;
-- 15. Πίνακας Νοσηλείας (Hospitalization)
CREATE TABLE Hospitalization (
    admission_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_amka VARCHAR(20) NOT NULL,
    bed_id INT NOT NULL,
    department_id INT NOT NULL,
    ken_id INT NOT NULL,
    admission_date DATE NOT NULL,
    discharge_date DATE, -- Μπορεί να είναι NULL αν ο ασθενής νοσηλεύεται ακόμα
    admission_diagnosis_code VARCHAR(20) NOT NULL,
    discharge_diagnosis_code VARCHAR(20), -- Μπορεί να είναι NULL μέχρι το εξιτήριο
    test_id INT,
    total_cost INT,
    
    FOREIGN KEY (patient_amka) REFERENCES Patient(amka),
    FOREIGN KEY (bed_id) REFERENCES Bed(bed_id),
    FOREIGN KEY (department_id) REFERENCES Department(department_id),
    FOREIGN KEY (ken_id) REFERENCES KEN(ken_id),
    FOREIGN KEY (admission_diagnosis_code) REFERENCES Diagnosis(icd10_code),
    FOREIGN KEY (discharge_diagnosis_code) REFERENCES Diagnosis(icd10_code),
    FOREIGN KEY (test_id) REFERENCES Lab_Test(test_id)
);
SET FOREIGN_KEY_CHECKS=1;

-- 16. Πίνακας Αξιολόγησης (Evaluation) - Συσχετίζεται 1-προς-1 με τη Νοσηλεία
CREATE TABLE Evaluation (
    evaluation_id INT AUTO_INCREMENT PRIMARY KEY,
    admission_id INT NOT NULL UNIQUE, -- UNIQUE γιατί 1 νοσηλεία = 1 αξιολόγηση
    nursing_care INT NOT NULL CHECK (nursing_care BETWEEN 1 AND 5),
    cleanliness INT NOT NULL CHECK (cleanliness BETWEEN 1 AND 5),
    food INT NOT NULL CHECK (food BETWEEN 1 AND 5),
    overall_experience INT NOT NULL CHECK (overall_experience BETWEEN 1 AND 5),
    
    FOREIGN KEY (admission_id) REFERENCES Hospitalization(admission_id)
);

SET FOREIGN_KEY_CHECKS = 0;


-- Φτιάχνουμε τον πίνακα αξιολόγησης Ιατρών
CREATE TABLE Doctor_Evaluation (
    doc_eval_id INT AUTO_INCREMENT PRIMARY KEY,
    admission_id INT NOT NULL,
    doctor_amka VARCHAR(20) NOT NULL,
    medical_care INT NOT NULL CHECK (medical_care BETWEEN 1 AND 5),
    UNIQUE (admission_id, doctor_amka), -- 1 αξιολόγηση ανά γιατρό για κάθε νοσηλεία
    FOREIGN KEY (admission_id) REFERENCES Hospitalization(admission_id),
    FOREIGN KEY (doctor_amka) REFERENCES Doctors(amka)
);


CREATE TABLE Room (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(50) NOT NULL CHECK (type IN ('Operating Theater', 'Procedure Room', 'Lab')),
    description TEXT,
    image_url VARCHAR(255),
    image_desc TEXT
);

CREATE TABLE Medical_Procedure (
    procedure_id INT AUTO_INCREMENT PRIMARY KEY,
    admission_id INT NOT NULL,
    room_id INT NOT NULL,
    main_doctor_amka VARCHAR(20) NOT NULL,
    ken_id INT,
    category VARCHAR(50),
    name VARCHAR(100) NOT NULL,
    start_time DATETIME NOT NULL, 
    duration INT NOT NULL CHECK (duration > 0),
    cost FLOAT NOT NULL CHECK (cost >= 0),
    FOREIGN KEY (admission_id) REFERENCES Hospitalization(admission_id),
    FOREIGN KEY (room_id) REFERENCES Room(room_id),
    FOREIGN KEY (main_doctor_amka) REFERENCES Doctors(amka),
    FOREIGN KEY (ken_id) REFERENCES KEN(ken_id)
);

CREATE TABLE Procedure_Assistant (
    procedure_id INT NOT NULL,
    staff_amka VARCHAR(20) NOT NULL,
    PRIMARY KEY (procedure_id, staff_amka),
    FOREIGN KEY (procedure_id) REFERENCES Medical_Procedure(procedure_id),
    FOREIGN KEY (staff_amka) REFERENCES Staff(amka)
);

CREATE TABLE Lab_Test (
    test_id INT AUTO_INCREMENT PRIMARY KEY,
    admission_id INT NOT NULL,
    ordering_doctor_amka VARCHAR(20) NOT NULL,
    code VARCHAR(20) NOT NULL,
    type VARCHAR(50) NOT NULL,
    test_date DATE NOT NULL,
    result TEXT,
    cost FLOAT NOT NULL CHECK (cost >= 0),
    FOREIGN KEY (admission_id) REFERENCES Hospitalization(admission_id),
    FOREIGN KEY (ordering_doctor_amka) REFERENCES Doctors(amka)
);
CREATE TABLE DRUG (
    ema_code VARCHAR(50) PRIMARY KEY,
    commercial_name VARCHAR(100) NOT NULL,
    image_url VARCHAR(255),
    image_desc TEXT
);

CREATE TABLE Active_Ingredient (
    ingredient_id INT AUTO_INCREMENT PRIMARY KEY,
    ingredient_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Drug_Ingredient (
    ema_code VARCHAR(50) NOT NULL,
    ingredient_id INT NOT NULL,
    PRIMARY KEY (ema_code, ingredient_id),
    FOREIGN KEY (ema_code) REFERENCES DRUG(ema_code),
    FOREIGN KEY (ingredient_id) REFERENCES Active_Ingredient(ingredient_id)
);
CREATE TABLE Patient_Allergy (
    patient_amka VARCHAR(20) NOT NULL,
    ingredient_id INT NOT NULL,
    PRIMARY KEY (patient_amka, ingredient_id),
    FOREIGN KEY (patient_amka) REFERENCES Patient(amka),
    FOREIGN KEY (ingredient_id) REFERENCES Active_Ingredient(ingredient_id)
);

CREATE TABLE Prescription (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    admission_id INT NOT NULL,
    patient_amka VARCHAR(20) NOT NULL,
    doctor_amka VARCHAR(20) NOT NULL,
    drug_ema_code VARCHAR(50) NOT NULL,
    dosage_instruction TEXT NOT NULL,
    frequency VARCHAR(50),
    start_date DATE NOT NULL,
    end_date DATE,
    UNIQUE (doctor_amka, patient_amka, drug_ema_code, start_date),
    FOREIGN KEY (admission_id) REFERENCES Hospitalization(admission_id),
    FOREIGN KEY (patient_amka) REFERENCES Patient(amka),
    FOREIGN KEY (doctor_amka) REFERENCES Doctors(amka),
    FOREIGN KEY (drug_ema_code) REFERENCES DRUG(ema_code)
);


DELIMITER //

CREATE TRIGGER trg_check_assistant_shift
BEFORE INSERT ON Procedure_Assistant
FOR EACH ROW
BEGIN
    DECLARE valid_shifts INT;
    DECLARE proc_date DATE;
    DECLARE proc_start_time TIME;
    DECLARE proc_end_time TIME;

    -- Βρίσκουμε την ημερομηνία και ώρα της επέμβασης που αντιστοιχεί σε αυτό το procedure_id
    SELECT DATE(start_time), TIME(start_time), ADDTIME(TIME(start_time), SEC_TO_TIME(duration * 60))
    INTO proc_date, proc_start_time, proc_end_time
    FROM Medical_Procedure
    WHERE procedure_id = NEW.procedure_id;

    -- Έλεγχος αν ο βοηθός (ιατρός ή νοσηλευτής) έχει βάρδια
    SELECT COUNT(*) INTO valid_shifts
    FROM Shift_Staff ss
    JOIN Shift s ON ss.shift_id = s.shift_id
    WHERE ss.staff_amka = NEW.staff_amka
      AND s.shift_date = proc_date
      AND (
          (s.shift_type = 'morning'   AND proc_start_time >= '08:00:00' AND proc_end_time <= '16:00:00') OR
          (s.shift_type = 'afternoon' AND proc_start_time >= '16:00:00' AND proc_end_time <= '23:59:59') OR
          (s.shift_type = 'night'     AND proc_start_time >= '00:00:00' AND proc_end_time <= '08:00:00')
      );

    -- Αν δεν βρέθηκε καμία βάρδια
    IF valid_shifts = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ΣΦΑΛΜΑ: Ο βοηθός/νοσηλευτής δεν έχει βάρδια την ώρα που γίνεται η επέμβαση!';
    END IF;
END;
//

DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_check_main_doctor_shift
BEFORE INSERT ON Medical_Procedure
FOR EACH ROW
BEGIN
    DECLARE valid_shifts INT;
    DECLARE proc_date DATE;
    DECLARE proc_start_time TIME;
    DECLARE proc_end_time TIME;

    SET proc_date      = DATE(NEW.start_time);
    SET proc_start_time = TIME(NEW.start_time);
    SET proc_end_time  = ADDTIME(proc_start_time, SEC_TO_TIME(NEW.duration * 60));

    SELECT COUNT(*) INTO valid_shifts
    FROM Shift_Staff ss
    JOIN Shift s ON ss.shift_id = s.shift_id
    WHERE ss.staff_amka = NEW.main_doctor_amka
      AND (
          -- Πρωινή 07:00-15:00: η βάρδια είναι την ίδια μέρα
          (s.shift_type = 'morning'
           AND s.shift_date = proc_date
           AND proc_start_time >= '07:00:00'
           AND proc_end_time   <= '15:00:00')
          OR
          -- Απογευματινή 15:00-23:00: η βάρδια είναι την ίδια μέρα
          (s.shift_type = 'afternoon'
           AND s.shift_date = proc_date
           AND proc_start_time >= '15:00:00'
           AND proc_end_time   <= '23:00:00')
          OR
          -- Νυχτερινή 23:00-07:00: η βάρδια είναι ΧΘΕΣ (περνά μεσάνυχτα)
          (s.shift_type = 'night'
           AND s.shift_date = DATE_SUB(proc_date, INTERVAL 1 DAY)
           AND proc_start_time >= '23:00:00')
          OR
          -- Νυχτερινή 23:00-07:00: ώρες μετά τα μεσάνυχτα (ίδια μέρα)
          (s.shift_type = 'night'
           AND s.shift_date = proc_date
           AND proc_end_time <= '07:00:00')
      );

    IF valid_shifts = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ΣΦΑΛΜΑ: Ο κύριος ιατρός δεν έχει βάρδια εκείνη την ώρα!';
    END IF;
END;
//

DELIMITER ;
DELIMITER //

CREATE TRIGGER trg_calculate_final_cost
BEFORE UPDATE ON Hospitalization
FOR EACH ROW
BEGIN
    DECLARE v_base_cost FLOAT;
    DECLARE v_duration INT;
    DECLARE extra_daily_cost FLOAT;
    DECLARE actual_days INT;
    DECLARE extra_days INT;

    -- Αν τώρα μπαίνει το εξιτήριο
    IF NEW.discharge_date IS NOT NULL AND OLD.discharge_date IS NULL THEN
        
        -- Διαβάζουμε τα δεδομένα του ΚΕΝ
        SELECT base_cost, duration 
        INTO v_base_cost, v_duration
        FROM KEN 
        WHERE ken_id = NEW.ken_id;

        -- Υπολογισμός αναλογικού ημερήσιου κόστους
        SET extra_daily_cost = v_base_cost / v_duration;

        -- Υπολογίζουμε τις πραγματικές μέρες νοσηλείας
        SET actual_days = DATEDIFF(NEW.discharge_date, NEW.admission_date);

        -- Ελέγχουμε αν υπάρχει υπέρβαση
        IF actual_days > v_duration THEN
            SET extra_days = actual_days - v_duration;
            SET NEW.total_cost = v_base_cost + (extra_days * extra_daily_cost);
        ELSE
            -- Αν έφυγε στην ώρα του, πληρώνει μόνο το βασικό
            SET NEW.total_cost = v_base_cost;
        END IF;

    END IF;
END;
//

DELIMITER ;

CREATE VIEW vw_active_patients AS
SELECT 
    h.admission_id AS 'Κωδικός Νοσηλείας',
    p.last_name AS 'Επώνυμο Ασθενούς',
    p.first_name AS 'Όνομα Ασθενούς',
    d.name AS 'Τμήμα',
    h.admission_date AS 'Ημερομηνία Εισαγωγής'
FROM Hospitalization h
JOIN Patient p ON h.patient_amka = p.amka
JOIN Department d ON h.department_id = d.department_id
-- Το μυστικό: Αν δεν έχει ημερομηνία εξιτηρίου, σημαίνει ότι νοσηλεύεται ακόμα!
WHERE h.discharge_date IS NULL;

CREATE VIEW vw_doctor_ratings AS
SELECT 
    s.last_name AS 'Επώνυμο Ιατρού',
    s.first_name AS 'Όνομα Ιατρού',
    doc.specialty AS 'Ειδικότητα',
    COUNT(de.doc_eval_id) AS 'Πλήθος Αξιολογήσεων',
    ROUND(AVG(de.medical_care), 2) AS 'Μέσος Όρος (Άριστα το 5)'
FROM Doctors doc
JOIN Staff s ON doc.amka = s.amka            -- Η ΠΡΟΣΘΗΚΗ: Ενώνουμε με το Staff για τα ονόματα
JOIN Doctor_Evaluation de ON doc.amka = de.doctor_amka
GROUP BY 
    doc.amka, 
    s.last_name, 
    s.first_name, 
    doc.specialty;

    
