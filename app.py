from flask import Flask, render_template
from flask_frozen import Freezer

app = Flask(__name__)
freezer = Freezer(app)


app.config['FREEZER_DESTINATION_IGNORE'] = ['.git*']
app.config['FREEZER_DESTINATION'] = 'dist'


@app.route('/')
def ramblings():
    return render_template('ramblings.html')


@app.route('/projects/')
def projects():
    return render_template('projects.html')


@freezer.register_generator
def page_generator():
    if False:
        yield


if __name__ == '__main__':
    freezer.run(debug=True)
