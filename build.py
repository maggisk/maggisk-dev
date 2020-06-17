import warnings
from flask_frozen import Freezer, MissingURLGeneratorWarning
from app import DB, app

# ignore error from flask_frozen when there are no pages to generate
warnings.filterwarnings("ignore", category=MissingURLGeneratorWarning)


def generator():
    for item in DB:
        if item.get('type') in ('blog', 'project'):
            yield 'page', {'slug': item['slug']}


freezer = Freezer(app)
freezer.register_generator(generator)
freezer.freeze()
