# run the app at localhost:5000

from __init__ import app

if __name__ == '__main__':
    # Το debug=True σημαίνει ότι αν αλλάζεις τον κώδικα, ο server θα κάνει refresh μόνος του!
    app.run(debug=True, port=5000)