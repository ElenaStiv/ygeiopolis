from flask import Flask
from flask_mysqldb import MySQL

app = Flask(__name__)

# Ρυθμίσεις για τη σύνδεση με τη MySQL
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'      # Το default username είναι συνήθως root
app.config['MYSQL_PASSWORD'] = ''      # Άσ' το κενό αν δεν έχεις βάλει κωδικό
app.config['MYSQL_DB'] = 'ygeiopolis'  # ΑΛΛΑΞΕ ΤΟ στο όνομα της δικής σου βάσης!
app.config['MYSQL_CURSORCLASS'] = 'DictCursor' # Μας βολεύει για να παίρνουμε τα δεδομένα με τα ονόματα των στηλών

mysql = MySQL(app)

# Εισαγωγή των routes (πρέπει να μπει στο τέλος)
from routes import *