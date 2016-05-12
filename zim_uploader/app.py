import sys

from flask import Flask, request

app = Flask(__name__)
if 'debug' in sys.argv:
    app.debug = True

@app.route("/", methods=["GET", "POST"])
def hello():
    if request.method == 'GET':
        return open('static/form.html').read()
    else:
        raise NotImplementedError

if __name__ == "__main__":
    app.run()
