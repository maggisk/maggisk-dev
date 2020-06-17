import os
import json
from collections import defaultdict
from itertools import groupby
from operator import itemgetter
from dateutil.parser import isoparse
from markdown import markdown as md
from flask import Flask, request, render_template

app = Flask(__name__)
app.config['FREEZER_DESTINATION_IGNORE'] = ['.git*']
app.config['FREEZER_DESTINATION'] = 'dist'


def read_documents(root, date_field_map):
    for path, dirs, files in os.walk(root):
        for filename in files:
            with open(os.path.join(path, filename), 'r') as f:
                item = json.load(f)
            item['slug'] = os.path.splitext(filename)[0]
            for field in date_field_map[item['type']]:
                item[k] = isoparse(item[field])
            yield item


DB = list(read_documents('./data/', {'blog': ['date'], 'project': ['date']}))


def query(**kwargs):
    is_match = lambda item: all(item.get(k) == v for k, v in kwargs.items())
    return filter(is_match, DB)


def nth_suffix(n):
    m = {11: 'th', 12: 'th', 13: 'th', 1: 'st', 2: 'nd', 3: 'rd'}
    return m.get(n % 100) or m.get(n % 10) or 'th'


def markdown(s):
    return md(s, extensions=[
        # code highlighting extension
        'markdown.extensions.codehilite',
        # allow backticks for code highlighting (e.g. ```python\nprint(1)\n```)
        'markdown.extensions.fenced_code',
    ])


@app.context_processor
def load_base_template_requirements():
    return {
        'nth_suffix': nth_suffix,
        'nth': lambda n: '{}{}'.format(n, nth_suffix(n)),
        'markdown': markdown,
    }


@app.route('/')
def ramblings():
    ramblings = sorted(query(type='blog'), key=itemgetter('date'), reverse=True)
    by_year = groupby(ramblings, lambda r: r['date'].year)
    return render_template('ramblings.html',
        by_year=by_year,
        tab='blog'
    )


@app.route('/projects/')
def projects():
    return render_template('projects.html',
        projects=sorted(query(type='project'), key=itemgetter('position')),
        tab='project'
    )


@app.route('/<slug>/')
def page(slug):
    print(slug)
    item = next(query(slug=slug))
    return render_template(item['type'] + '.html', **{
        item['type']: item,
        'tab': item['type'],
    })


if __name__ == '__main__':
    app.run(debug=True)
