* @title Using elm without node or npm (or yarn)
* @slug using-elm-without-node-or-npm-or-yarn
* @time 2020-02-26 23:34

Do we need nodejs and npm when using Elm? Seems difficult to avoid, but lets try to set up a project without it.

[elm-live](https://github.com/wking-io/elm-live) is probably the most common development server when using Elm. We need something similar, but not written in javascript? [Modd](https://github.com/cortesi/modd) is a go development tool that monitors files for changes and reacts by executing commands, and its sister project [devd](https://github.com/cortesi/devd) is a development webserver with live-reload capabilities. Sounds exactly what we need.

[sass](https://sass-lang.com/) is my preferred css processor. It's actually written in [dart](https://dart.dev/) with implementations in other languages, including javascript. The dart version has a binary we can download and run without any dependencies. Sounds perfect.

We also need elm of course. Elm is written in Haskell and has binaries available for download. Should be easy.

Same for [elm-format](https://github.com/avh4/elm-format) which I like to use in my elm projects.

What about a javascript bundler? 99% of those are written in javascript. Except maybe [swc](https://github.com/swc-project/swc) and [esbuild](https://github.com/evanw/esbuild). Swc is written in rust and doesn't seem to have binaries available. Esbuild is written in Go, lets give that a shot. We probably won't write much javascript in our elm project, but I still like to minify my javascript that calls Elm.Main.init and sets up ports and maybe analytics etc.

Sounds totally doable. Except that's quite a bit of work to get up and running, and automating it to work on both MacOS and linux doesn't sound much fun. Docker to the rescue maybe? Lets try.

```Dockerfile
FROM debian:buster-slim

WORKDIR "/app"

ENV ELM_VERSION=0.19.1 \
    ELM_FORMAT_VERSION=0.8.2 \
    MODD_VERSION=0.8 \
    DEVD_VERSION=0.9 \
    ESBUILD_VERSION=0.0.9 \
    SASS_VERSION=1.26.1

# only thing missing is curl
RUN apt update && apt install -y curl && apt clean

# Elm: https://elm-lang.org
RUN curl -L "https://github.com/elm/compiler/releases/download/$ELM_VERSION/binary-for-linux-64-bit.gz" \
    | gunzip > /usr/local/bin/elm \
    && chmod +x /usr/local/bin/elm

# elm-format: https://github.com/avh4/elm-format
RUN curl -L "https://github.com/avh4/elm-format/releases/download/$ELM_FORMAT_VERSION/elm-format-$ELM_FORMAT_VERSION-linux-x64.tgz" \
    | tar xzO > /usr/local/bin/elm-format \
    && chmod +x /usr/local/bin/elm-format

# modd: https://github.com/cortesi/modd
RUN curl -L "https://github.com/cortesi/modd/releases/download/v$MODD_VERSION/modd-$MODD_VERSION-linux64.tgz" \
    | tar -xzO > /usr/local/bin/modd \
    && chmod +x /usr/local/bin/modd

# devd: https://github.com/cortesi/devd
RUN curl -L "https://github.com/cortesi/devd/releases/download/v$DEVD_VERSION/devd-$DEVD_VERSION-linux64.tgz" \
    | tar xzO > /usr/local/bin/devd \
    && chmod +x /usr/local/bin/devd

# esbuild: https://github.com/evanw/esbuild
RUN curl -L "https://registry.npmjs.org/esbuild-linux-64/-/esbuild-linux-64-$ESBUILD_VERSION.tgz" \
    | tar xzO > /usr/local/bin/esbuild \
    && chmod +x /usr/local/bin/esbuild

# sass (dart version (the best version)): https://sass-lang.com/
RUN cd / \
    && curl -L "https://github.com/sass/dart-sass/releases/download/$SASS_VERSION/dart-sass-$SASS_VERSION-linux-x64.tar.gz" \
    | tar xz \
    && ln -s /dart-sass/sass /usr/local/bin/sass

CMD ["modd"]
```

We're just downloading binaries to our PATH and making them executable. Pretty simple.

Now we need to configure modd.

```
{
    prep: mkdir -p static/build
    daemon: sass --watch src/app.scss static/build/app.css
}

src/**/*.js {
    prep: esbuild --bundle src/init.js --outfile=static/build/init.js --sourcemap
}

src/**/*.elm {
    prep: elm make src/Main.elm --debug --output static/build/elm.js
}

static/**/* {
    daemon: devd -m -A 0.0.0.0 -p 1234 --notfound /index.html static
}
```

Sass works faster by using --watch than running from scratch. esbuild and elm don't have a watch option so we let modd take care of that. Lastly we start devd. modd will send it a unix process signal to trigger a live-reload any time something in our static directory changes.

Now we just need to build our Docker container with `docker build -t elm-without-npm .` and run it with `docker run --rm -it --volume="$PWD:/app" -p 1234:1234 elm-without-npm`

Last thing we need is a production build and minify our assets. We just need to execute a bunch of commands, so lets create a bash script to take care of that.

```bash
#!/usr/bin/env bash

mkdir -p static/build
rm -rf static/build/*

sass src/app.scss --style=compressed --no-source-map --quiet > static/build/app.css
esbuild --bundle src/init.js --outfile=static/build/init.js --minify
elm make src/Main.elm --optimize --output /tmp/elm.js
esbuild /tmp/elm.js --outfile=static/build/elm.js --minify
rm /tmp/elm.js
```

Biggest flaw is not having uglify, but esbuild does a decent job of minification. What comes closest to uglify is probably [google clojure compiler](https://developers.google.com/closure/compiler) but who likes dealing with Java?

<span class="note">(I actually tried. Java wont install on buster-slim and the java runtime environment is around 600mb, which means to get it working we'd have to switch to standard debian docker image plus the 600mb java runtime and our docker image would become HUGE. Yuck)</span>

Now we can make a production build by running `docker run --rm -it --volume="$PWD:/app" elm-without-npm ./build` which builds in about 1 second. Nice.

[I put this all together on github](https://github.com/maggisk/elm-without-npm) if anyone is interested.

### Conclusion

Is it possible to use Elm without npm? Definitely. Is it worth it? Probably not. I miss uglify especially. Modd and devd are absolutely fantastic though and I'm going to prefer those over any javascript solutions from now on.


