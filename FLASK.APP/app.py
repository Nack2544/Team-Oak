from flask import Flask, render_template
import os
import random

app = Flask(__name__)

images = [ 
    "https://media.tenor.com/fTTVgygGDh8AAAAC/kitty-cat-sandwich.gif", 
    "https://media.tenor.com/cXkAv2pdeeMAAAAd/french-bulldog-frenchie.gif", 
    "https://media.tenor.com/TMXYtDsPrrQAAAAC/hamster-peace.gif", 
    "https://media.tenor.com/h5-xPN0znpwAAAAM/normal-cat-cat-normal.gif", 
    "https://media.tenor.com/s2sfVSgN0ecAAAAC/rabbit-funny-animals.gif", 
    "https://media.tenor.com/mztrlrVJQG8AAAAC/funny-animals-dogs.gif", 
    "https://media.tenor.com/zAWayiOlk58AAAAC/dogs-cute-animals.gif", 
    "https://media.tenor.com/qZMCTn_dcisAAAAC/dog-fluffy.gif", 
] 

@app.route("/")
def index():
    url = random.choice(images)
    return render_template("index.html", url=url)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 5000)))