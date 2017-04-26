import argparse
from glob import glob
import json
import os
import re
import subprocess
import traceback

from flask import Flask, request, render_template, redirect, url_for
from werkzeug import secure_filename, exceptions


parser = argparse.ArgumentParser(description='Serve Zim file uploader.')
parser.add_argument('--upload-path', dest='upload_path',
                    help='Where the zim file should go',
                    default='data/')
parser.add_argument('-d', dest='debug', action='store_true',
                    help='Run this flask app in debug mode')

args = parser.parse_args()

app = Flask(__name__, static_folder='upload_static')
app.config['DEBUG'] = args.debug
app.config['SECRET_KEY'] = open('/var/secret_key', 'r').read().strip()
app.config['MAX_CONTENT_LENGTH'] = 15 * 1024 * 1024

UPLOAD_FOLDER = args.upload_path
CHUNKING_FOLDER = 'data/chunking/'
MAX_FILE_LENGTH = 100 * 1024 * 1024 * 1024
COMPLETED_FILE_PATH = os.path.join(UPLOAD_FOLDER, "kiwix.zim")


def allowed_file(filename):
    return filename.endswith('.zim')


@app.route("/upload", methods=['GET', 'POST'])
def upload():
    try:
        return _upload()
    except Exception as e:
        print traceback.format_exc()
        return json.dumps(
            {"files": [{'error': 'Unexpected error uploading file: ' + e.message}]}
        ), 500

def _save_chunk(files, filename, mime_type, content_range, chunking_file_path, chunking_file_size_before):
    try:
        with open(
            chunking_file_path,
            'a' if os.path.exists(chunking_file_path) else 'w'
        ) as uploaded_file:
            # save file to disk
            files.save(uploaded_file)
    except IOError as e:
        if e.errno == 28:
            return {'error': 'Out of space on device. (Check your Sandstorm quota)'}, 409
        else:
            return {'error': 'File error: ' + e.message}, 409


    # get chunk size after saving
    size = os.path.getsize(chunking_file_path)

    if content_range['to'] + 1 >= content_range['total']:
        os.rename(chunking_file_path, COMPLETED_FILE_PATH)
        if app.config['DEBUG']:
            # useful for debugging file uploading
            print 'completed file md5', subprocess.check_output(
                ['md5sum', COMPLETED_FILE_PATH]
            )
        # Just in case of botched previous uploads
        for filename in glob(CHUNKING_FOLDER + '*'):
            print "removing", filename
            subprocess.call(['rm', filename])

    return {'size': size}, None


def _get_content_range(request):
    content_range_match = re.match(
        'bytes (?P<from>\d+)-(?P<to>\d+)/(?P<total>\d+)',
        request.form['contentRange']
    )
    if content_range_match:
        return {
            k: int(v)
            for (k, v) in content_range_match.groupdict().iteritems()
        }
    else:
        return {
            'from': 0,
            'to': int(request.headers['Content-Length']) - 1,
            'total': int(request.headers['Content-Length']),
        }


def _upload():
    # Note that this is written with a trusted web client in mind
    # The user of the upload client should be the owner of the grain
    # At least, this will be the case when this project is completed
    if request.method == 'POST':
        if 'uploader' not in request.headers['X-Sandstorm-Permissions']:
            raise exceptions.Forbidden()
        files = request.files['file']
        content_range = _get_content_range(request)

        if files:
            mime_type = files.content_type
            filename = secure_filename(files.filename)
            chunking_file_path = os.path.join(CHUNKING_FOLDER, filename)
            error_code = None

            if os.path.exists(chunking_file_path):
                if content_range['from'] == 0:
                    os.remove(chunking_file_path)
                    chunking_file_size_before = 0
                else:
                    chunking_file_size_before = os.path.getsize(chunking_file_path)
            else:
                chunking_file_size_before = 0

            result = {'name': filename, 'type': mime_type, 'size': 0}
            if os.path.exists(COMPLETED_FILE_PATH):
                # Just return success if this accidentally happens
                result['size'] = chunking_file_size_before
            elif not allowed_file(files.filename):
                result['error'] = 'File type not allowed'
            elif content_range['total'] > MAX_FILE_LENGTH:
                # Saves their time; stops them as soon as they claim a range with a
                # total that's too big.
                result['error'] = 'File too big'
            elif content_range['from'] != chunking_file_size_before:
                result['error'] = 'Error in uploading process (chunks out of order)'
            else:
                _result_update, error_code = _save_chunk(
                    files,
                    filename,
                    mime_type,
                    content_range,
                    chunking_file_path,
                    chunking_file_size_before,
                )
                result.update(_result_update)

            if 'error' in result:
                if os.path.exists(chunking_file_path):
                    os.remove(chunking_file_path)
                return json.dumps({"files": [result]}), error_code or 400
            else:
                return json.dumps({"files": [result]})

    return redirect(url_for('index'))


@app.route('/', methods=['GET', 'POST'])
def index():
    return render_template(
        'index.html',
        zim_file_exists=os.path.exists(COMPLETED_FILE_PATH),
        read_only='uploader' not in request.headers['X-Sandstorm-Permissions'],
    )

application = app.wsgi_app
