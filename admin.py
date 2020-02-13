#!/usr/bin/env python3

import os, sys, typing, json, datetime, re, operator, shlex, subprocess, tempfile
from markdown import markdown

ROOT_DIR: str    = os.path.dirname(os.path.abspath(__file__))
DATA_DIR: str    = os.path.join(ROOT_DIR, 'data')
API_DIR: str     = os.path.join(ROOT_DIR, 'static', 'api')
DATE_FORMAT: str = "%Y-%m-%d %H:%M"

MARKDOWN_CONFIG = dict(
    extensions=[
        # code highlighting extension
        'markdown.extensions.codehilite',
        # allow backticks for code highlighting (e.g. ```python\nprint(1)\n```)
        'markdown.extensions.fenced_code',
    ],
    extension_configs = {
        'markdown.extensions.codehilite': {
            # inline css so we don't need an external css file
            'noclasses': True,
        },
    }
)

DOCUMENT_TYPES = dict(
    ramble=dict(
        directory=os.path.join(DATA_DIR, 'rambling'),
        required_new=['title'],
        required_edit=['title', 'time', 'slug'],
        time_fields=['time'],
        markdown_fields=['__body__'],
    ),
    project=dict(
        directory=os.path.join(DATA_DIR, 'projects'),
        required_new=['title', 'summary', 'progress', 'proudness'],
        required_edit=['title', 'summary', 'progress', 'proudness', 'time', 'slug'],
        time_fields=['time'],
        markdown_fields=['__body__', 'summary'],
    ),
)


def verbose(*args, **kwargs):
    if '--verbose' in sys.argv:
        print(*args, **kwargs)


def warn(*args, **kwargs):
    if '--quiet' not in sys.argv:
        kwargs.setdefault('file', sys.stderr)
        print(*args, **kwargs)


def abort(reason: str, exitcode:int=1):
    print(reason, file=sys.stderr)
    sys.exit(exitcode)


def path_to_doc_type(path):
    for doc_type in DOCUMENT_TYPES.values():
        if path.startswith(doc_type['directory']):
            return doc_type
    raise ValueError('{} is not a valid document path'.format(path))


def read_file(filename: str):
    with open(filename, 'r') as f:
        lines = list(line.rstrip('\r\n') for line in f.readlines())
    doc = {}
    while lines and lines[0].startswith('* @'):
        line_orig = lines.pop(0)
        line = line_orig.strip('\r\n* @')
        pair = line.split(' ', 1)
        if len(pair) == 2:
            doc[pair[0]] = pair[1]
        else:
            warn('ignored {} from {}'.format(line_orig, filename))
    doc['__body__'] = '\n'.join(lines).strip()
    return doc


def read_dir(dirpath: str):
    for filename in os.listdir(dirpath):
        path = os.path.join(dirpath, filename)
        if os.path.isfile(path):
            yield read_file(path)


def write_text_file(filename: str, doc: dict):
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with open(filename, 'w') as f:
        for k, v in doc.items():
            if not k.startswith('__'):
                f.write('* @{} {}\n'.format(k, v))
        f.write('\n' + doc['__body__'] + '\n')


def write_json(filename: str, doc: dict):
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    verbose("writing {}".format(filename))
    with open(filename, 'w') as f:
        f.write(json.dumps(doc))


def to_json(doc: dict, doc_type: dict, ignore: list = []) -> dict:
    doc = doc.copy()
    for time_field in doc_type['time_fields']:
        date = datetime.datetime.strptime(doc[time_field], DATE_FORMAT)
        doc[time_field] = round(date.timestamp()) * 1000
    for md_field in doc_type['markdown_fields']:
        doc[md_field] = markdown(doc[md_field], **MARKDOWN_CONFIG)
    for k in ignore:
        doc.pop(k, None)
    return {k.strip('_'): v for k, v in doc.items()}


def shell(cmd: str, *subs):
    cmd = cmd.format(*[shlex.quote(s) for s in subs])
    process = subprocess.run(cmd, encoding='utf-8', shell=True, capture_output=True)
    process.check_returncode()
    return process.stdout


def slugify(s: str) -> str:
    s = shell('echo {} | iconv -t ascii//TRANSLIT', s)
    return re.sub('[^\w]', '-', s).strip('-').lower()


def editor(filename: str):
    editor = os.environ.get('EDITOR', 'vim')
    status = subprocess.call([editor, filename])
    if status > 0:
        abort('{} exited with status code {}. \nAborting...'.format(editor, status))


def edit_document(filename: str, required_fields: list):
    while True:
        editor(filename)
        doc = read_file(filename)
        for k in required_fields:
            if k not in meta:
                input('Your document must have an @{}. Lets try that again...'.format(k))
                break
        else:
            return doc


def new_document(doc_type: dict):
    with tempfile.NamedTemporaryFile(suffix='.md') as f:
        for k in doc_type['required_new']:
            f.write('* @{} \n'.format(k).encode())
        f.flush()
        doc = edit_document(f.name, doc_type['required_new'])
    doc.setdefault('slug', slugify(doc['title']))
    for time_field in doc_type['time_fields']:
        doc.setdefault(time_field, datetime.datetime.now().strftime(DATE_FORMAT))
    filename = os.path.join(doc_type['directory'], doc['slug'] + '.md')
    write_text_file(filename, doc)


def ramble():
    new_document(DOCUMENT_TYPES['ramble'])


def project():
    new_document(DOCUMENT_TYPES['project'])


def edit():
    f = shell('find -type file {} | fzf', DATA_DIR)
    for doc_type in DOCUMENT_TYPES.values():
        if os.path.dirname(f) == doc_type['dirname']:
            edit_document(f, doc_type['required_edit'])
            return
    abort('Could not detect document type of ' + f)


def build():
    shell('rm -rf {}', API_DIR)
    for path, dirs, files in os.walk(DATA_DIR):
        for filename in files:
            doc_file = os.path.join(path, filename)
            doc_type = path_to_doc_type(doc_file)
            doc = read_file(doc_file)
            json_file = os.path.join(path, doc['slug'] + '.json').replace(DATA_DIR, API_DIR)
            write_json(json_file, to_json(doc, doc_type))
        for dirname in dirs:
            doc_type = path_to_doc_type(os.path.join(path, dirname))
            index = [to_json(doc, doc_type, ignore=['__body__'])
                     for doc in read_dir(os.path.join(path, dirname))]
            index.sort(key=operator.itemgetter('time'), reverse=True)
            write_json(os.path.join(path, dirname + '.json').replace(DATA_DIR, API_DIR), index)


def preview():
    pass


def main():
    actions = {
        'ramble': ramble,
        'project': project,
        'edit': edit,
        'build': build,
        'preview': preview,
    }

    if len(sys.argv) > 1 and sys.argv[1] in actions:
        actions[sys.argv[1]]()
    else:
        print('Usage: {} COMMAND\nCOMMAND = {}'.format(sys.argv[0], ' | '.join(actions.keys())))


if __name__ == '__main__':
    main()
