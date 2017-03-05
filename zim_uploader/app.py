import argparse
import os
import sys

from flask import Flask, request, render_template

parser = argparse.ArgumentParser(description='Serve Zim file uploader.')
parser.add_argument('--upload-path', dest='upload_path',
                    help='Where the zim file should go',
                    default='/var')
parser.add_argument('-d', dest='debug', action='store_true',
                    help='Run this flask app in debug mode')

args = parser.parse_args()

app = Flask(__name__)
app.debug = args.debug


@app.route("/", methods=["GET", "POST"])
def hello():
    if request.method == 'GET':
        return render_template('form.html')
    elif request.method == 'POST':
        f = request.files['file_to_upload']
        if not f.filename:
            return render_template('form.html', unspecified=True)
        f.save(os.path.join(args.upload_path, 'kiwix.zim'))
        return render_template('form.html', success=True)

application = app.wsgi_app
