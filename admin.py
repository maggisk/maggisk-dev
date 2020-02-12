#!/usr/bin/env python3

import os, sys, typing, json, datetime, re, operator, shlex, subprocess, tempfile
import markdown


ROOT_DIR: str    = os.path.dirname(os.path.abspath(__file__))
DATA_DIR: str    = os.path.join(ROOT_DIR, 'data')
API_DIR: str     = os.path.join(ROOT_DIR, 'static', 'api')
DATE_FORMAT: str = "%Y-%m-%d %H:%M"


def verbose(*args, **kwargs):
    if '--verbose' in sys.argv:
        print(*args, **kwargs)


def warn(*args, **kwargs):
    if '--quiet' not in sys.argv:
        print(*args, file=sys.stderr, **kwargs)


def abort(reason, exitcode=1):
    print(reason, file=sys.stderr)
    sys.exit(exitcode)


def read_file(filename):
    with open(filename, 'r') as f:
        lines = list(line.rstrip('\r\n') for line in f.readlines())
    meta = {}
    while lines and lines[0].startswith('* @'):
        line_orig = lines.pop(0)
        line = line_orig.strip('\r\n* @')
        pair = line.split(' ', 1)
        if len(pair) == 2:
            meta[pair[0]] = pair[1]
        else:
            warn('ignored {} from {}'.format(line_orig, filename))
    return meta, '\n'.join(lines).strip()


def read_dir(dirpath):
    for filename in os.listdir(dirpath):
        path = os.path.join(dirpath, filename)
        if os.path.isfile(path):
            yield read_file(path)


def write_text_file(filename, meta, content):
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with open(filename, 'w') as f:
        for k, v in meta.items():
            f.write('* @{} {}\n'.format(k, v))
        f.write('\n' + content + '\n')


def write_json(filename, data):
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    verbose("writing {}".format(filename))
    with open(filename, 'w') as f:
        f.write(json.dumps(data))


def to_json(data):
    if 'time' in data:
        dt = datetime.datetime.strptime(data['time'], DATE_FORMAT)
        js_time = round(dt.timestamp()) * 1000
        data = dict(data, time=js_time)
    return data


def bash(cmd, *subs):
    cmd = cmd.format(*[shlex.quote(s) for s in subs])
    process = subprocess.run(cmd, encoding='utf-8', shell=True, capture_output=True)
    process.check_returncode()
    return process.stdout


def slugify(s):
    s = bash('echo {} | iconv -t ascii//TRANSLIT', s)
    return re.sub('[^\w]', '-', s).strip('-').lower()


def editor(filename):
    editor = os.environ.get('EDITOR', 'vim')
    status = subprocess.call([editor, filename])
    if status > 0:
        abort('{} exited with status code {}. \nAborting...'.format(editor, status))


def edit_document(filename, required_meta = ()):
    while True:
        editor(filename)
        meta, content = read_file(filename)
        for k in required_meta:
            if k not in meta:
                input('Your document must have an @{}. Lets try that again...'.format(k))
                break
        else:
            return meta, content


def ramble():
    with tempfile.NamedTemporaryFile(suffix='.md') as f:
        f.write(b'@title \n')
        f.flush()
        meta, content = edit_document(f.name, ['title'])
    meta.setdefault('slug', slugify(meta['title']))
    meta.setdefault('time', datetime.datetime.now().strftime(DATE_FORMAT))
    filename = os.path.join(DATA_DIR, 'rambling', meta['slug'] + '.md')
    write_text_file(filename, meta, content)


def edit():
    f = bash('find -type file {} | fzf', DATA_DIR)
    edit_document(f, ['title', 'time', 'slug'])


def markdown_to_html(content):
    return markdown.markdown(
        content,
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


def build():
    bash('rm -rf {}', API_DIR)
    for path, dirs, files in os.walk(DATA_DIR):
        for filename in files:
            meta, content = read_file(os.path.join(path, filename))
            filename = os.path.join(path, meta['slug'] + '.json').replace(DATA_DIR, API_DIR)
            data = dict(to_json(meta), body=markdown_to_html(content))
            write_json(filename, data)
        for dirname in dirs:
            index = [to_json(meta) for meta, content in read_dir(os.path.join(path, dirname))]
            index.sort(key=operator.itemgetter('time'), reverse=True)
            write_json(os.path.join(path, dirname + '.json').replace(DATA_DIR, API_DIR), index)


def preview():
    pass


def main():
    actions = {
        'ramble': ramble,
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
