* @title thoughts on javascript build tools
* @slug thoughts-on-javascript-build-tools
* @time 2020-02-13 14:45

Does anyone like javascript build tools? They are so complex and frustrating to deal with.

[Parcel](https://parceljs.org/) is a fantastic idea and in theory you should be able to create an amazing build tool like that. But unfortunately, in practice, parcel sucks. It is so full of bugs it is barely usable for a serious project. [Version 2](https://medium.com/@devongovett/parcel-2-0-0-alpha-1-is-here-8b160c6e3f7e) is on the way, but I've never been able to get it to work, and I believe I'm not the only one.

Why are javascript build tools so complex? Isn't most of the complexity coming from importing non-javascript files from javascript. Is that complexity worth it? What if we stop the abomination that is importing images, css files etc. from javascript. Couldn't we hugely simplify our build process?

As long as we stick to importing javascript from javascript we can simply call `sass --watch` for our css, `babel app.js` for our javascript, `elm make` if using elm, `dev-server ./static` for live-reloading, `uglifyjs app.js --compress --mangle` for javascript minification. No complex abstractions. No extra packages for each of your dependencies like sass + sass-loader, elm + elm-webpack-loader, babel + babel-loader etc. when using webpack. No build tool messing up the error messages from your tools/libraries like parcel does.
 
What I want from my build tool is:

* call multiple arbitrary shell commands in parallel and combine the output in a single terminal window
* offer the ability to watch files for changes and re-run commands when they change
* development webserver with support for live reloading of at least css changes

You can get a decent setup like that using a few different npm packages.
 
* [chokidar](https://github.com/paulmillr/chokidar) for watching files.
* [npm-run-all](https://www.npmjs.com/package/npm-run-all) for running multiple commands in parallel in the same terminal window.
* [live-server](https://www.npmjs.com/package/live-server) for live-reloading
* All the other tools you're using (sass, babel etc)

Your package.json scripts field will look something like this

```json
{
    "scripts": {
        "start": "npm-run-all --parallel --print-label watch:**",
        "watch:css": "sass --watch css/app.scss dist/css/app.css",
        "watch:elm": "chokidar 'src/**/*.elm' -c 'elm make src/Main.elm --output dist/js/elm.js' --initial",
        "watch:js": "babel app/app.js --watch --out-file dist/js/app.js",
        "watch:server": "live-server --entry-file=index.html dist",
        "build": "npm-run-all --parallel --print-label build:**",
        "build:css": "sass --style=compressed css/app.scss dist/css/app.css",
        "build:elm": "elm make src/Main.elm --optimize --output dist/js/elm.js",
        "build:js": "babel app/app.js --out-file dist/js/app.js"
    }
}
```

Check out a complete example with sass, elm, uglifyjs and [esbuild](https://github.com/evanw/esbuild/) as used by this website at [maggisk-dev/package.json](https://github.com/maggisk/maggisk-dev/blob/master/package.json)

I'm probably overlooking some webpack feature that can't be replaced like this. Code splitting comes to mind, but if you're using something like [Elm](https://elm-lang.org/) or [Svelte](https://svelte.dev/) the output is so tiny compared to React/Vue/Angular that it doesn't really matter.

There are some issues left, like combining your babel-generated-javascript and elm-generated-javascript into a single file, but this is the build setup that I'm going to strive for from now on.
