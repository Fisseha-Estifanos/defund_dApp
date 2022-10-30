from flask import Flask, render_template

app = Flask(__name__)


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/employer')
def employer():
    return render_template('employer.html')


@app.route('/employee')
def employee():
    return render_template('employee.html')


@app.route('/details')
def details():
    return render_template('details.html')


@app.route('/locations')
def locations():
    return render_template('locations.html')
