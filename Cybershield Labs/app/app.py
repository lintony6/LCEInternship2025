from flask import Flask, request, redirect, render_template_string, send_from_directory, jsonify 
from docker.errors import NotFound
from flask_sqlalchemy import SQLAlchemy
import docker
import os
import time
import requests
import threading
import subprocess

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
client = docker.from_env()
db = SQLAlchemy(app)

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80))
    password = db.Column(db.String(80))

comments = []

API_KEY = "CTF{hardcoded_secret_key}"

@app.before_first_request
def setup():
    db.create_all()
    if not User.query.filter_by(username='admin').first():
        db.session.add(User(username='admin', password='secureadmin123'))
        db.session.commit()

@app.route('/')
def index():
    html = '''
    {% extends "layout.html" %}
    {% block content %}
    <h2>Welcome to Cybershield Labs</h2>
    <p>We are a leading provider of security research, risk assessments, and cutting-edge digital defense tools for enterprise networks.</p>

    <div style="margin-top: 30px;">
        <h3>Services:</h3>
        <ul>
            <li><a class="button" href="/tools/diagnostics">Server Diagnostics</a></li>
            <li><a class="button" href="/tools/calc">Calculator</a></li>
            <li><a class="button" href="/login">Customer Portal</a></li>
            <li><a class="button" href="/contact">Contact</a></li>
        </ul>
    </div>
    {% endblock %}
    '''
    return render_template_string(html)

@app.route('/tools/diagnostics', methods=['GET'])
def diagnostics():
    cmd = request.args.get('cmd', '')
    result = ''
    if cmd:
        try:
            completed = subprocess.run(
                cmd,  # let the shell parse it
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                shell=True  # important: needed for piped/compound commands
            )
            result = completed.stdout
        except Exception as e:
            result = f"Error: {str(e)}"

    return render_template_string(f'''
        {{% extends "layout.html" %}}
        {{% block content %}}
        <h2>Server Diagnostics Tool</h2>
        <form method="get">
            <label>Run Diagnostics Command:</label>
            <input name="cmd" placeholder="e.g. whoami">
            <input type="submit" value="Execute">
        </form>
        <pre>{result}</pre>
        {{% endblock %}}
    ''')

@app.route('/tools/calc')
def calc():
    code = request.args.get('code', '')
    result = ''
    if code:
        try:
            result = str(eval(code))
        except Exception as e:
            result = f"Error: {str(e)}"
    return render_template_string(f'''
        {{% extends "layout.html" %}}
        {{% block content %}}
        <h2>Internal Calculator API</h2>
        <form method="get">
            <label>Expression:</label>
            <input name="code" placeholder="e.g. 2+2">
            <input type="submit" value="Calculate">
        </form>
        <pre>{result}</pre>
        {{% endblock %}}
    ''')

@app.route('/login', methods=['GET', 'POST'])
def login():
    msg = ''
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']

        if username == 'admin' and password == 'secureadmin123':
            # Legit admin check uses SQLAlchemy safely
            user = User.query.filter_by(username='admin', password='secureadmin123').first()
            if user:
                return send_from_directory('.', 'secret.pdf', as_attachment=False)
        elif password == 'secureadmin123':
            # Vulnerable SQL path — user can inject in username
            query = f"SELECT * FROM user WHERE username = '{username}' AND password = '{password}'"
            result = db.session.execute(query).fetchall()
            if result:
                return send_from_directory('.', 'secret.pdf', as_attachment=False)

        msg = "Login failed"

    return render_template_string(f'''
        {{% extends "layout.html" %}}
        {{% block content %}}
        <h2>Client Access Portal</h2>
        <form method="post">
            <label>Username:</label>
            <input name="username" type="text" required><br>
            <label>Password:</label>
            <input name="password" type="password" required><br>
            <input type="submit" value="Login">
        </form>
        <p style="color: red;">{msg}</p>
        {{% endblock %}}
    ''')

@app.route('/contact', methods=['GET', 'POST'])
def contact():
    if request.method == 'POST':
        text = request.form['text']
        comments.append(text)
        return redirect('/messages')
    return render_template_string('''
        {% extends "layout.html" %}
        {% block content %}
        <h2>Contact Support</h2>
        <form method="post">
            <label>Your Message:</label><br>
            <input name="text" placeholder="Leave a message...">
            <input type="submit" value="Send">
        </form>
        <a href="/messages">View Previous</a>
        {% endblock %}
    ''')

@app.route('/messages')
def messages():
    output = '''
        {% extends "layout.html" %}
        {% block content %}
        <h2>User Messages</h2>
    '''
    for c in comments:
        output += f"<p>{c}</p>"
    output += '<a href="/contact">Back to Contact</a>{% endblock %}'
    return render_template_string(output)

@app.route('/comments')
def view_comments():
    output = "<h2>All Comments</h2>"
    for c in comments:
        output += f"<p>{c}</p>"
    return output + '<a href="/comment">Back</a>'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)

