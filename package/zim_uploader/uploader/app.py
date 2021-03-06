import argparse
from glob import glob
import json
import os
import random
import re
import subprocess
import traceback

from flask import Flask, request, render_template, redirect, url_for
from werkzeug import secure_filename, exceptions

# Indicates that the upload should be aborted. If it's a 409 it's probably something
# that trying again won't help, so we signal to the javascript side of things to not
# retry. Perhaps later we could split the error code out from the recovery question.
CONFLICT_DONT_RECOVER = 409

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
        print (traceback.format_exc())
        return json.dumps(
            {"files": [{'error': 'Unexpected error uploading file: ' + str(e)}]}
        ), 500

def _save_chunk(files, filename, mime_type, content_range, chunking_file_path, chunking_file_size_before):
    try:
        mode = 'ab' if os.path.exists(chunking_file_path) else 'wb'
        with open(chunking_file_path, mode) as uploaded_file:
            # save file to disk
            files.save(uploaded_file)
    except IOError as e:
        if e.errno == 28:
            return {'error': 'Out of space on device. (Check your Sandstorm quota)'}, CONFLICT_DONT_RECOVER
        else:
            return {'error': 'File error: ' + str(e)}, CONFLICT_DONT_RECOVER


    # get chunk size after saving
    size = os.path.getsize(chunking_file_path)

    if content_range['to'] + 1 >= content_range['total']:
        os.rename(chunking_file_path, COMPLETED_FILE_PATH)
        if app.config['DEBUG']:
            # useful for debugging file uploading
            print ('completed file md5', subprocess.check_output(
                ['md5sum', COMPLETED_FILE_PATH]
            ))
        # Just in case of botched previous uploads
        for filename in glob(CHUNKING_FOLDER + '*'):
            print ('removing', filename)
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
            for (k, v) in content_range_match.groupdict().items()
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

            result = {
                'name': filename,
                'type': mime_type,
                'size': 0,
                'total_size': content_range['total']
            }

            if os.path.exists('/var/force_fail'):
                number = open('/var/force_fail', 'r').read().strip() or 400
                result['error'] = 'Testing forced upload failure: ' + str(result)
                return json.dumps({"files": [result]}), int(number)

            if os.path.exists('/var/random_fail'):
                random_failure = random.randint(0, 8)
                if random_failure == 0: # error message in 'error' field
                    result['error'] = 'Testing random upload failure 0: ' + str(result)
                    return json.dumps({"files": [result]}), 400
                elif random_failure == 1: # error message without json
                    return "Testing random upload failure 1", 400
                elif random_failure == 2: # no error message
                    return json.dumps({"files": [result]}), 400
                elif random_failure == 3: # 500
                    raise BaseException("Testing random upload failure 3")

            if os.path.exists(COMPLETED_FILE_PATH):
                result['error'] = 'File already uploaded'
                error_code = CONFLICT_DONT_RECOVER # Conflict is the closest one I can think of
            elif not allowed_file(files.filename):
                result['error'] = 'File type not allowed'
            elif content_range['total'] > MAX_FILE_LENGTH:
                # Saves their time; stops them as soon as they claim a range with a
                # total that's too big.
                result['error'] = 'File too big'
            elif content_range['from'] != chunking_file_size_before:
                result['error'] = ''.join([
                    'Error in uploading process. (Chunks out of order: size:%i ',
                    'content_range:%s chunking_file_path: %s)',
                ]) % (
                    chunking_file_size_before,
                    content_range,
                    chunking_file_path
                )
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
                # If we don't return a error response code, Jquery File
                # Uploader will ignore the 'error' field and continue to upload
                # the chunks like nothing happened, even though we're not
                # saving them.
                return json.dumps({"files": [result]}), error_code or 400
            else:
                return json.dumps({"files": [result]})

    return redirect(url_for('index'))

ZIM_FILE_LANGUAGES = {
  'en':  'English',
  'eng': 'English',
  'fr':  'French',
  'pt':  'Portuguese',
}
ZIM_FILE_VARIANTS = {
  None:          'Full Size',
  'all':         'Full Size',
  'all_maxi':    'Full Size',
  'all_nopic':   'No Images',
  'business':    'Business',
  'technology':  'Tech',
  'ray_charles': 'Articles Related to Ray Charles',
}
ZIM_FILE_LINK_TEMPLATE = 'http://download.kiwix.org/zim/{content_code}_{lang_code}{variant_opt}.zim{torrent_ext_opt}'

def gen_popular_download_links():
    # Only advertise approximate size because the size can change
    return [
        _download_link('wikipedia',         'Wikipedia',         'en',  [('all_maxi', '79GB'),  ('all_nopic',  '18GB')]),
        _download_link('wikivoyage',        'WikiVoyage',        'en',  [('all_maxi', '789MB'), ('all_nopic',  '193MB')]),
        _download_link('wikisource',        'WikiSource',        'en',  [('all_maxi', '15GB'),  ('all_nopic',  '7.2GB')]),
        _download_link('wiktionary',        'Wiktionary',        'en',  [('all_maxi', '4.2GB'), ('all_nopic',  '1.4GB')]),
        _download_link('ted',               'Ted Talks',         'en',  [('business', '8.3GB'), ('technology', '17GB')]),
        _download_link('gutenberg',         'Project Gutenberg', 'en',  [('all', '54GB')]),
        _download_link('stackoverflow.com', 'Stack Overflow',    'en',  [('all', '134GB')]),
        _download_link('phet',              'PhET',              'en',  [(None,  '47MB')]), # popular, but small enough for demo
    ]

def gen_demo_download_links():
    # Only advertise approximate size because the size can change
    return [
        _download_link('phet',                         'PhET',                       'en', [(None,          '47MB')]), # popular, but small enough for demo
        _download_link('literature.stackexchange.com', 'Stack Exchange: Literature', 'en', [('all',         '89MB')]),
        _download_link('gutenberg',                    'Project Gutenberg',          'pt', [('all',         '206MB')]),
        _download_link('wikipedia',                    'Wikipedia Subset',           'en', [('ray_charles', '5MB')]),
    ]

def _download_link(content_code, content_name, lang_code, variants):
    assert '_' not in content_code, (
      'we rely on replacing dots with underscores in content_code when'
      'making content_id, so we assume there are no underscores in there'
    )
    return {
        'display_name': content_name,
        'display_language': ZIM_FILE_LANGUAGES[lang_code],
        'variants': [{
            'direct_link': ZIM_FILE_LINK_TEMPLATE.format(
                content_code=content_code,
                lang_code=lang_code,
                variant_opt='_%s' % variant if variant else '',
                torrent_ext_opt=''),
            'torrent_link': ZIM_FILE_LINK_TEMPLATE.format(
                content_code=content_code,
                lang_code=lang_code,
                variant_opt='_%s' % variant if variant else '',
                torrent_ext_opt='.torrent'),
            'approx_size': approx_size,
            'display_name': ZIM_FILE_VARIANTS[variant],
        } for (variant, approx_size) in variants],
        'content_id': content_code.replace('.', '_'),
    }


@app.route('/', methods=['GET', 'POST'])
def index():
    # TODO split this into separate actual endpoints
    page = request.args.get('page')
    if page not in {'intro', 'download', 'upload', 'known-limitations', 'how-it-works'}:
        page = 'intro'

    return render_template(
        'index.html',
        zim_file_exists=os.path.exists(COMPLETED_FILE_PATH),
        read_only='uploader' not in request.headers['X-Sandstorm-Permissions'],
        page=page,
        popular_download_links=gen_popular_download_links(),
        demo_download_links=gen_demo_download_links(),
    )

application = app.wsgi_app
