from flask_frozen import Freezer
from app import DB, app

freezer = Freezer(app)


@freezer.register_generator
def generator():
    for item in DB:
        if item.get('type') in ('blog', 'project'):
            yield 'page', {'slug': item['slug']}


freezer.freeze()
