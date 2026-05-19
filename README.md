#   ΥΓΕΙΟΠΟΛΗΣ

This is a project for the Databases class in NTUA Electrical and Computer Engineering Department (2026).

## Contributors

1. Δημήτριος-Χρυσοβαλάντης Γαλανός 
1. Ελένη Στιβακτάκη ([ElenaStiv](https://github.com/ElenaStiv))
1. Μιχάλης Θρασυβουλίδης ([michaelthrasyvoulides-lgtm](https://github.com/michaelthrasyvoulides-lgtm))

#  INSTALATION

## 1. ΠΡΟΑΠΑΙΤΟΥΜΕΝΑ 
Βεβαιωθείτε ότι έχετε εγκατεστημένα:
- Python (έκδοση 3.x)
- Έναν τοπικό server MySQL (π.χ. XAMPP, WAMP, ή αυτόνομη MySQL)

## 2. ΡΥΘΜΙΣΗ ΤΗΣ ΒΑΣΗΣ ΔΕΔΟΜΕΝΩΝ (MySQL)
1. Ανοίξτε το phpMyAdmin (ή άλλο εργαλείο διαχείρισης MySQL).
2. Επιλέξτε νέα βάση και μεταβείτε στην καρτέλα "Εισαγωγή" (Import).
3. Επιλέξτε το αρχείο "install.sql" που περιλαμβάνεται σε αυτόν τον φάκελο και πατήστε "Εισαγωγή" (Import).
4. Μεταβείτε ξανά στην καρτέλα "Εισαγωγή" (Import) επιλέξτε τα αρχεία "load_part1.sql" και "load_part2.sql". 

## 3. ΡΥΘΜΙΣΗ ΚΩΔΙΚΩΝ ΠΡΟΣΒΑΣΗΣ ΣΤΟΝ ΚΩΔΙΚΑ 
Ανοίξτε το αρχείο της εφαρμογής που διαχειρίζεται τη σύνδεση με τη βάση (π.χ. το __init__.py ή το app.py) και βρείτε τις ρυθμίσεις της MySQL. 
Βεβαιωθείτε ότι τα στοιχεία (username, password) ταιριάζουν με τα δικά σας. 
Παράδειγμα:

- app.config['MYSQL_USER'] = 'root'
- app.config['MYSQL_PASSWORD'] = ''  

## 4. ΕΓΚΑΤΑΣΤΑΣΗ ΒΙΒΛΙΟΘΗΚΩΝ (DEPENDENCIES) 
Ανοίξτε ένα τερματικό (Command Prompt, PowerShell ή το τερματικό του VS Code), πλοηγηθείτε στον φάκελο της εφαρμογής και τρέξτε την παρακάτω εντολή:

    pip install -r requirements.txt

Αυτό θα εγκαταστήσει το Flask και τη βιβλιοθήκη επικοινωνίας με τη MySQL.

## 5. ΕΚΤΕΛΕΣΗ ΤΗΣ ΕΦΑΡΜΟΓΗΣ 
Στο ίδιο τερματικό, τρέξτε την εφαρμογή με την εντολή:

    python run.py

Μόλις ξεκινήσει ο server, ανοίξτε τον browser της επιλογής σας και επισκεφθείτε τη διεύθυνση:
http://127.0.0.1:5000/

Entity-Relationship Diagram:

![Entity-Relationship Diagram](/diagrams/er.png)

Relational Diagram:

![Relational Diagram](/diagrams/relational.png)

&copy; Galanos Dhmhtrios - Stivaktaki Eleni - Thrasivoulidis Mixalis
