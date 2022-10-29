from flask import Flask, render_template

app = Flask(__name__)


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/employee')
def employee():
    return render_template('employee.html')


@app.route('/history')
def history():
    return render_template('history.html')
