from __init__ import app, mysql
from flask import render_template

@app.route('/')
def index():
    # Φτιάχνουμε έναν "κέρσορα" για να εκτελέσουμε SQL
    cursor = mysql.connection.cursor()
    try:
        # Το raw SQL query μας!
        cursor.execute("SELECT * FROM Department")
        departments = cursor.fetchall()
        cursor.close()
        
        # Στέλνουμε τα αποτελέσματα στο index.html
        return render_template('index.html', depts=departments)
    except Exception as e:
        return f"Ωχ, κάτι πήγε στραβά με τη βάση: {str(e)}"
    
@app.route('/doctors')
def doctors():
    cursor = mysql.connection.cursor()
    try:
        # 1. Βρίσκουμε όλες τις διαθέσιμες ειδικότητες για να γεμίσουμε το μενού επιλογής
        cursor.execute("SELECT DISTINCT specialty FROM Doctors ORDER BY specialty")
        # Επειδή χρησιμοποιούμε DictCursor, το αποτέλεσμα είναι λίστα από λεξικά
        specialties = [row['specialty'] for row in cursor.fetchall()]

        # 2. Διαβάζουμε τι επέλεξε ο χρήστης από το μενού (αν επέλεξε)
        selected_specialty = request.args.get('specialty')

        # 3. Το βασικό Query για τους ιατρούς
        query = """
            SELECT s.first_name, s.last_name, d.specialty, d.rank 
            FROM Staff s 
            JOIN Doctors d ON s.amka = d.amka
        """
        
        # 4. Αν ο χρήστης διάλεξε ειδικότητα, προσθέτουμε φίλτρο!
        if selected_specialty:
            query += " WHERE d.specialty = %s"
            cursor.execute(query, (selected_specialty,))
        else:
            # Αλλιώς τους φέρνουμε όλους
            cursor.execute(query)
            
        docs = cursor.fetchall()
        cursor.close()
        
        # Στέλνουμε στο HTML και τους γιατρούς, και τη λίστα ειδικοτήτων, και την τρέχουσα επιλογή
        return render_template('doctors.html', doctors=docs, specialties=specialties, selected_specialty=selected_specialty)
    except Exception as e:
        return f"Σφάλμα στη φόρτωση ιατρών: {str(e)}"
    
@app.route('/ratings')
def ratings():
    cursor = mysql.connection.cursor()
    try:
        # Εκτελούμε το query πάνω στο View σου!
        cursor.execute("SELECT * FROM vw_doctor_ratings")
        ratings_data = cursor.fetchall()
        cursor.close()
        
        return render_template('ratings.html', ratings=ratings_data)
    except Exception as e:
        # Αν η βάση είναι άδεια ή το View δεν υπάρχει, θα δούμε το σφάλμα
        return f"Σφάλμα στη φόρτωση αξιολογήσεων: {str(e)}"
    
from datetime import date

from datetime import date

@app.route('/shifts')
def shifts():
    cursor = mysql.connection.cursor()
    try:
        # Παίρνουμε την ημερομηνία από το ημερολόγιο (αν επιλέχθηκε), αλλιώς τη σημερινή
        selected_date = request.args.get('date')
        if not selected_date:
            selected_date = date.today().strftime('%Y-%m-%d')

        # Χρησιμοποιούμε DATE(s.shift_date) για να είμαστε σίγουροι ότι συγκρίνουμε μόνο μέρες
        # ΑΛΛΑΓΗ ΕΔΩ: Προσθέσαμε LEFT JOIN για να φαίνονται και οι άδειες βάρδιες!
        query = """
            SELECT d.name AS dept_name, s.shift_type, st.first_name, st.last_name, st.staff_type
            FROM Shift s
            JOIN Department d ON s.department_id = d.department_id
            LEFT JOIN Shift_Staff ss ON s.shift_id = ss.shift_id
            LEFT JOIN Staff st ON ss.staff_amka = st.amka
            WHERE DATE(s.shift_date) = %s
            ORDER BY d.name, s.shift_type
        """
        cursor.execute(query, (selected_date,))
        current_shifts = cursor.fetchall()
        cursor.close()
        
        # Μετατροπή ημερομηνίας για εμφάνιση (π.χ. 2024-05-15 -> 15/05/2024)
        display_date = "/".join(selected_date.split("-")[::-1])
        
        return render_template('shifts.html', shifts=current_shifts, today=display_date, raw_date=selected_date)
    except Exception as e:
        return f"Σφάλμα στις εφημερίες: {str(e)}"

@app.route('/status')
def department_status():
    cursor = mysql.connection.cursor()
    try:
        selected_date = request.args.get('date')
        if not selected_date:
            selected_date = date.today().strftime('%Y-%m-%d')

        # Query που βρίσκει όλα τα τμήματα και ελέγχει αν έχουν βάρδια εκείνη τη μέρα
        query = """
            SELECT d.name, d.building_floor, 
            (SELECT COUNT(*) FROM Shift s WHERE s.department_id = d.department_id AND s.shift_date = %s) as shift_count
            FROM Department d
        """
        cursor.execute(query, (selected_date,))
        depts = cursor.fetchall()
        cursor.close()
        
        display_date = "/".join(selected_date.split("-")[::-1])
        return render_template('status.html', departments=depts, today=display_date, raw_date=selected_date)
    except Exception as e:
        return f"Σφάλμα στην κατάσταση τμημάτων: {str(e)}"
    
from flask import render_template, request

@app.route('/department/<int:id>')
def department(id):
    cursor = mysql.connection.cursor()
    try:
        # 1. Φέρνουμε τα στοιχεία ΜΟΝΟ αυτού του τμήματος
        cursor.execute("SELECT * FROM Department WHERE department_id = %s", (id,))
        dept = cursor.fetchone()
        
        # 2. ΝΕΟ QUERY: Ενώνουμε τον Staff, τους Doctors ΚΑΙ τον πίνακα Doctor_Department
        # Προσοχή: Υποθέτω ότι οι στήλες στον Doctor_Department λέγονται amka και department_id. 
        # Αν η στήλη λέγεται π.χ. doctor_amka, απλά άλλαξε το dd.amka παρακάτω!
        query = """
            SELECT s.first_name, s.last_name, d.specialty, d.rank
            FROM Staff s 
            JOIN Doctors d ON s.amka = d.amka 
            JOIN Doctor_Department dd ON d.amka = dd.doctor_amka
            WHERE dd.department_id = %s
        """
        cursor.execute(query, (id,))
        dept_doctors = cursor.fetchall()
        
        cursor.close()
        
        if not dept:
            return "Το τμήμα δεν βρέθηκε!", 404
            
        return render_template('department.html', dept=dept, doctors=dept_doctors)
    except Exception as e:
        return f"Σφάλμα στη φόρτωση του τμήματος: {str(e)}"
    
@app.route('/equipment')
def equipment():
    # Λίστα με τον εξοπλισμό
    hospital_equipment = [
        {
            "name": "Μαγνητικός Τομογράφος (MRI) 3.0T",
            "desc": "Κορυφαία απεικονιστική τεχνολογία για λεπτομερή εξέταση μαλακών μορίων, εγκεφάλου και σπονδυλικής στήλης με απόλυτη ακρίβεια.",
            "img": "/static/images/mri.jpg"
        },
        {
            "name": "Αξονικός Τομογράφος (CT) 128 Τομών",
            "desc": "Υπερσύγχρονος τομογράφος χαμηλής δόσης ακτινοβολίας για ταχύτατες και τρισδιάστατες διαγνωστικές λήψεις.",
            "img": "/static/images/ct.jpg"
        },
        {
            "name": "Σύστημα Υπερήχων 4D",
            "desc": "Ψηφιακός υπέρηχος υψηλής ευκρίνειας με κεφαλές για καρδιολογικές, γυναικολογικές και παθολογικές εξετάσεις.",
            "img": "/static/images/4d.jpg"
        },
        {
            "name": "Σύστημα Εργοσπιρομετρίας & Τεστ Κοπώσεως",
            "desc": "Πλήρες σύστημα με τάπητα κοπώσεως για τον έλεγχο της καρδιοαναπνευστικής επάρκειας και τον μεταβολισμό.",
            "img": "/static/images/tapita.jpg"
        },
        {
            "name": "Holter Ρυθμού & Πίεσης",
            "desc": "Φορητές συσκευές 24ωρης ή 48ωρης καταγραφής για τη διάγνωση αρρυθμιών και υπέρτασης.",
            "img": "/static/images/holter.jpg"
        },
        {
            "name": "Διαφανοσκόπιο LED Slim",
            "desc": "Υπερλεπτο διαφανοσκόπιο LED για την υψηλής αντίθεσης προβολή ακτινογραφιών και φιλμ.",
            "img": "/static/images/w.jpg"
        },
        {
            "name": "Ηλεκτρικές Εξεταστικές Πολυθρόνες",
            "desc": "Πολυθρόνες πολλαπλών θέσεων για επεμβατικές πράξεις, εξασφαλίζοντας μέγιστη άνεση στον ασθενή.",
            "img": "/static/images/chair.jpg"
        },
        {
            "name": "Ιατρικά Κρεβάτια Εξέτασης",
            "desc": "Υδραυλικά κρεβάτια με ρυθμιζόμενο ύψος και κλίση, κατάλληλα για κάθε τμήμα του νοσοκομείου.",
            "img": "https://images.unsplash.com/photo-1516549655169-df83a0774514?q=80&w=800&auto=format&fit=crop"
        },
        {
            "name": "Αναπηρικά Αμαξίδια Ενισχυμένα",
            "desc": "Εργονομικά αμαξίδια αλουμινίου για την ασφαλή και εύκολη μετακίνηση ασθενών εντός του κέντρου.",
            "img": "/static/images/amea.jpg"        
        },
        {
            "name": "Ψηφιακές Ζυγαριές με Λιπομετρητή",
            "desc": "Ιατρικοί σταθμοί μέτρησης βάρους, ύψους και ανάλυσης σύστασης σώματος (BMI).",
            "img": "/static/images/weight.jpg"
        }
    ]
    return render_template('equipment.html', equipment_list=hospital_equipment)


@app.route('/evaluation', methods=['GET', 'POST'])
def evaluation():
    cursor = mysql.connection.cursor()
    message = None
    message_type = None

    if request.method == 'POST':
        patient_amka = request.form.get('patient_amka')
        nursing = request.form.get('nursing')
        cleanliness = request.form.get('cleanliness')
        food = request.form.get('food')
        overall = request.form.get('overall')

        # ΕΛΕΓΧΟΣ: Ψάχνουμε αν ο ασθενής έχει ολοκληρωμένη νοσηλεία (discharge_date IS NOT NULL)
        # και δεν έχει υποβάλει ήδη αξιολόγηση για αυτήν.
        cursor.execute("""
            SELECT h.admission_id 
            FROM Hospitalization h
            LEFT JOIN Evaluation e ON h.admission_id = e.admission_id
            WHERE h.patient_amka = %s 
              AND h.discharge_date IS NOT NULL 
              AND e.evaluation_id IS NULL
            ORDER BY h.discharge_date DESC
            LIMIT 1
        """, (patient_amka,))
        
        result = cursor.fetchone()

        if result:
            admission_id = result[0]
            try:
                # Υποβολή της αξιολόγησης
                cursor.execute("""
                    INSERT INTO Evaluation (admission_id, nursing_care, cleanliness, food, overall_experience)
                    VALUES (%s, %s, %s, %s, %s)
                """, (admission_id, nursing, cleanliness, food, overall))
                mysql.connection.commit()
                message = "Η αξιολόγησή σας υποβλήθηκε επιτυχώς! Σας ευχαριστούμε που μας βοηθάτε να γίνουμε καλύτεροι."
                message_type = "success"
            except Exception as e:
                mysql.connection.rollback()
                message = f"Σφάλμα κατά την υποβολή: {str(e)}"
                message_type = "danger"
        else:
            # Το μήνυμα αν ο ασθενής νοσηλεύεται ακόμα ή έχει ήδη αξιολογήσει
            message = "Δεν βρέθηκε πρόσφατη ολοκληρωμένη νοσηλεία για αυτό το ΑΜΚΑ (ή έχετε ήδη υποβάλει αξιολόγηση)."
            message_type = "warning"
            
    cursor.close()
    return render_template('evaluation.html', message=message, message_type=message_type)


@app.route('/contact')
def contact():
    # Μια απλή στατική σελίδα δεν χρειάζεται σύνδεση με τη βάση!
    return render_template('contact.html')