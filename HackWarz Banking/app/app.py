from flask import Flask, request, redirect, render_template, make_response, jsonify
import base64
import os

app = Flask(__name__, static_url_path='/static', static_folder='static')

users = {
    'BobSmith': 'ILOVEMICKEY!',
    'admin': 'supersecret879273548723975'
}

# XOR + base64 for CTF session token obfuscation
SECRET_KEY = "ctfkey"

def xor_encrypt_decrypt(text, key):
    return ''.join(chr(ord(c) ^ ord(key[i % len(key)])) for i, c in enumerate(text))

def encrypt_token(username):
    raw = xor_encrypt_decrypt(username, SECRET_KEY)
    return base64.urlsafe_b64encode(raw.encode()).decode()

def decrypt_token(token):
    try:
        decoded = base64.urlsafe_b64decode(token).decode()
        return xor_encrypt_decrypt(decoded, SECRET_KEY)
    except Exception:
        return None

def generate_transaction_log():
    lines = [
        "Transfer: $100 to Alice",
        "Transfer: $200 to Bob",
        "Transaction: Persian Cat #8491       ",
        "Withdrawal: $75",
        "Deposit: $420",
        "# Hint: The password for the bonus access is in this file"
    ]
    os.makedirs("static", exist_ok=True)
    with open("static/transactions.log", "w") as f:
        for line in lines:
            f.write(line + "\n")

@app.route('/', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        if username in users and users[username] == password:
            token = encrypt_token(username)
            resp = make_response(redirect('/dashboard'))
            resp.set_cookie('session', token)
            return resp
        return "Invalid credentials", 403
    return render_template('login.html')

@app.route('/dashboard')
def dashboard():
    if not os.path.exists('static/transactions.log'):
        generate_transaction_log()

    token = request.cookies.get('session')
    session_token = decrypt_token(token) if token else None
    if session_token and session_token in users:
        if session_token == 'admin':
            with open('flag.txt') as f:
                flag = f.read()
        elif session_token == 'BobSmith':
            flag = 'FLAG: 9F3C7A2B6D81E4F0'
        else:
            flag = 'Welcome!'
        return render_template('dashboard.html', user=session_token, flag=flag)
    return redirect('/')

# ✅ Moved this route ABOVE the __main__ block
@app.route('/check_code', methods=['POST'])
def check_code():
    token = request.cookies.get('session')
    session_token = decrypt_token(token) if token else None

    if session_token != 'Bob Smith':
        return jsonify({"error": "Unauthorized"}), 403

    data = request.get_json()
    code = data.get('code', '').strip()

    if code == "8491":
        return jsonify({"flag": "FLAG{9F4C1A7D3E6B8F20}"})
    else:
        return jsonify({"error": "Incorrect code"}), 400

# ✅ Now this will see all the routes above it
if __name__ == '__main__':
    app.run(host='0.0.0.0')
