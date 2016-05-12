import sys

from flask import Flask, request, render_template

app = Flask(__name__)
if 'debug' in sys.argv:
    app.debug = True

@app.route("/", methods=["GET", "POST"])
def hello():
    if request.method == 'GET':
        return render_template('form.html')
    else:
        raise NotImplementedError

if __name__ == "__main__":
    app.run()
