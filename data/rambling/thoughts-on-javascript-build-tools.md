* @title thoughts on javascript build tools
* @slug thoughts-on-javascript-build-tools
* @time 2020-02-12 14:45

I don't think anyone likes javascript build tools. They are complex and frustrating to deal with.

I love the idea of [parcel](https://parceljs.org/) and in theory you should be able to create an amazing build tool like that. But in practice, I think parcel just plain sucks. It is so full of bugs it is barely usable for a serious project. [Version 2](https://medium.com/@devongovett/parcel-2-0-0-alpha-1-is-here-8b160c6e3f7e) is on the way, but I've never been able to get it to work, and I believe I'm not the only one.

Why are javascript build tools so complex? Isn't most of the complexity coming from importing non-javascript files from javascript. Is that complexity worth it? What if we stop the abomination that is importing images, css files etc. from javascript. Couldn't we hugely simplify our build process?

As long as we stick to importing javascript from javascript we can simply call `sass --watch` for our css, `babel app.js` for our javascript, `elm make` if using elm, `dev-server ./static` for live-reloading, `uglifyjs app.js --compress --mangle` for javascript minification. No complex abstractions. No extra packages for each of your dependencies like sass + sass-loader, elm + elm-webpack-loader, babel + babel-loader etc. when using webpack. No build tool messing up the errors/stacktraces from your tools/libraries.

What I want from my build tool is:

* call multiple arbitrary shell commands in parallel and combine the output in a single terminal window
* offer the ability to watch files for changes and re-run commands when they change
* development webserver with support for live reloading of at least css changes

You can kind of set this up yourself using multiple different npm packages, but it takes a bit of work.
 
* [chokidar](https://github.com/paulmillr/chokidar) for watching files.
* [npm-run-all](https://www.npmjs.com/package/npm-run-all) for running multiple commands in parallel in the same terminal window.
* [live-server](https://www.npmjs.com/package/live-server) for live-reloading
* All the other tools you're using (sass, babel etc)

Your package.json scripts field might look something like this (untested, probably has bugs)

```json
{
    "scripts": {
        "watch": "npm-run-all --parallel watch:**",
        "watch:css": "sass --watch app/css:dev/css",
        "watch:elm": "chokidar '**/*.elm' -c 'elm make src/Main.elm --output dev/elm.js' --initial",
        "watch:javascript": "babel app/app.js --watch --out-file dev/app.js",
        "watch:server": "cd dev && live-server",
        "build": "npm-run-all --parallel build:**",
        "build:css": "sass --style=compressed app/css:build/css",
        "build:elm": "elm make src/Main.elm --optimize --output build/elm.js",
        "build:javascript": "babel app/app.js --out-file build/app.js"
    }
}
```

It's not perfect. You loose all coloring from your build commands for example. I'm also probably overlooking some webpack feature that can't be replaced like this. Code splitting might be one, but if you're using something like [Elm](https://elm-lang.org/) or [Svelte](https://svelte.dev/) the output is so tiny compared to React/Vue/Angular that it doesn't really matter.

There are some issues left, like combining your plain-javascript and elm-generated-javascript into a single file, but this is the build setup that I'm going to strive for from now on.
