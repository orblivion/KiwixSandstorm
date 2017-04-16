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
app.config['MAX_CONTENT_LENGTH'] = 6 * 1024 * 1024

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
    except Exception:
        print traceback.format_exc()
        raise


def _save_chunk(files, filename, mime_type, content_range, chunking_file_path, chunking_file_size_before):
    # save file to disk
    uploaded_file = open(
        chunking_file_path,
        'a' if os.path.exists(chunking_file_path) else 'w'
    )
    files.save(uploaded_file)
    uploaded_file.close()

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

    return True


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

            chunking_file_size_before = (
                os.path.getsize(chunking_file_path) if os.path.exists(chunking_file_path)
                else 0
            )
            result = {'name': filename, 'type': mime_type, 'size': 0}
            if os.path.exists(COMPLETED_FILE_PATH):
                result['error'] = 'File with this name already exists'
            elif not allowed_file(files.filename):
                result['error'] = 'File type not allowed'
            elif content_range['total'] > MAX_FILE_LENGTH:
                # Saves their time; stops them as soon as they claim a range with a
                # total that's too big.
                result['error'] = 'File too big'
            elif content_range['from'] != chunking_file_size_before:
                result['error'] = 'Content range out of order'
            else:
                _save_chunk(files, filename, mime_type, content_range, chunking_file_path, chunking_file_size_before)

            if 'error' in result and os.path.exists(chunking_file_path):
                os.remove(chunking_file_path)

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
