#!/usr/bin/env bash

mkdir -p dist
rm -rf dist/*

python3 admin.py build
cp -r static/* dist/

npm install --only=prod
export PATH="./node_modules/.bin:$PATH"

tempfile=$(mktemp --suffix=.js)
elm make src/Main.elm --output "$tempfile" --optimize
uglifyjs "$tempfile" --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe' | uglifyjs --mangle --output=dist/app.js
rm "$tempfile"
