from flask import Flask, render_template
import os
import random

app = Flask(__name__,static_folder="./contents")

images = [ 
    "./contents/401-logo.png", 
] 

@app.route("/")
def index():
    url = random.choice(images)
    return render_template("index.html", url=url)

@app.route("/home")
def home(): 
    return render_template("home.html")

@app.route("/info")
def info():
    return render_template("info.html")

@app.route("/login")
def login():
    return render_template("login.html")

@app.route("/Oak")
def Oak():
    return render_template("Oak.html")

@app.route("/submit")
def submit():
    return render_template("submit") 

@app.route("/project3")
def project3():
    return render_template("project3.html")    

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 5000)))