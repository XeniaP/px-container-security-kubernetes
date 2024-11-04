from flask import Flask, render_template, request, redirect, url_for
import psycopg2

app = Flask(__name__)

def get_db_connection():
    conn = psycopg2.connect(
        host="postgres-service",
        database="usersdb",
        user="myuser",
        password="AdminSecurePassword"
    )
    return conn

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("INSERT INTO users (username, password) VALUES (%s, %s)",
                       (username, password))
        conn.commit()
        cursor.close()
        conn.close()
        
        return redirect(url_for('success', username=username))
    return render_template('register.html')

@app.route('/success/<username>')
def success(username):
    return f"Usuario {username} registrado exitosamente"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
