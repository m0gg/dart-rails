dart-rails
==========

### Idea ###

Handle [dart](https://www.dartlang.org/ 'dartlang.org') scripts so they get transcoded to js for browsers
without dart support. Currently there's only the `Dartium` browser from the development-kit that supports
dart directly.

For now this is a rather stupid attempt, although it works.

For a working sample check [m0gg/dart-rails-sample](https://github.com/m0gg/dart-rails-sample 'm0gg/dart-rails-sample').

### Setup ###

  1. `Gemfile`

    ```ruby
    gem 'ruby-dart2js'
    gem 'dart-rails'
     ```

  2. run `rails generate dart:assets` this will bring you:

    ```sh
    rails g dart:assets
    create  app/assets/dart
    create  app/assets/dart/dart_app.dart
    create  app/assets/dart/dart_app.js
    create  app/assets/dart/pubspec.yaml
    ```

  3. Currently you still need to add following to the bottom of your body in the layout:

     `layout.html.erb` (for instance)

    ```
    <%= dart_include_tag 'dart_app' %>
    <%= javascript_include_tag 'dart' %>
    ```

  4. *Optional:* run `rake pub:get` to respect the dependencies in your `pubspec.yaml`.
  Initially the pubspec contains `rails_ujs` as dependency, this is just basic for now,
  so you probably want to omit it if you're still using JQuery.

  *Note:* you'll need to point `DART_SDK_HOME` to the root of your dart-sdk unless your `pub` executable is in the `PATH`

### Compatibility ###

###### UglifyJs ######

Don't worry if you're experiencing a

```
ExecJS::ProgramError: RangeError: Maximum call stack size exceeded
```

This is exactly what it means, a stackoverflow of UglifyJs. According to
[RangeError: Maximum call stack size exceeded #414](https://github.com/mishoo/UglifyJS2/issues/414) UglifyJs is
massivly recursive and your dart2js file might have blown it. This happened to me with an AngluarDart application.
You may simply disable UglifyJs in the environment file.

```
...
# Compress JavaScripts and CSS.
# config.assets.js_compressor = :uglifier
...
```

###### assets:precompile + native .dart files ######

As of rails 4 we are facing a problem for the productive environments.
See [Inability to compile nondigest and digest assets breaks compatibility with bad gems #49](https://github.com/rails/sprockets-rails/issues/49)

You may optionally add this to your Gemfile

```
gem 'non-stupid-digest-assets', '>= 1.1', github: 'm0gg/non-stupid-digest-assets'
```

this will enable a workaround for digesting the assets while precompiling dart files as
seen in [non-stupid-digest-assets](https://github.com/alexspeller/non-stupid-digest-assets) and
additionally rewrite the manifests to use the non-digest files.

###### ruby-dart2js ######

This gem is needed for the `dart2js` compiler compatibility.

See [ruby-dart2js](https://github.com/m0gg/ruby-dart2js) on github for setup.

```
<%= javascript_include_tag 'dart' %>
```
in the layout needs to stay as it is unless you want to drop
compatibility for browsers without dart support.
It includes the bundled `javascripts/dart.js` from this gem.

This will parse all script-tags with `type="application/dart"` and replace them with tags that request
the appropriate js file.
```html
<script type="application/dart" src="/assets/dart_app.dart"></script>
```
would get
```html
<script type="application/javascript" src="/assets/dart_app.js"></script>
```
To provide the transcompiled version of you dart-file you'll need a js template
with a directive which could look like this
```javascript
//
//= dart dart_app
```

###### Sprockets ######

`Dart::SprocketsDirectiveDart2js` extends Sprockets base `DirectiveProcessor` and thus each dart-file
included (via `dart` directive) in `.js` templates get compiled and inserted.


### Changelog ###
v0.3.0 - 21. Jan. 2015:
  * with v0.2.0 of ruby-dart2js, minifying is supported and will bump the feature version of dart-rails with updated dependencies

v0.2.5 - 14. Jan. 2015:
  * fixed a misplaced initializer for non-stupid-digest-assets that caused every asset to be non-digested

v0.2.4 - 13. Dec. 2014 - update:
  * corrected `pubspec.yml` to assign valid `dart_app` as name

v0.2.3 - 13. Dec. 2014:
  * fix 2 issues documented as [Fix the generated pubspec.yml #13](https://github.com/m0gg/dart-rails/issues/13)
  and [Generators run each time rails g runs #12](https://github.com/m0gg/dart-rails/issues/12)
  * generators no longer try to run `rails g dart:assets` as javascript_engine
  * generated `pubspec.yml` now staticly assigns `dart-app` as name
  * railtie restructured and split into two engines

v0.2.2 - 12. Dec. 2014 - update:
  * dart-rails is now available via rubygems, it's first published with version 0.2.2

v0.2.2 - 04. Dec. 2014:
  * due to sprockets digest method, we are forced to use a workaround to allow
  "precompilation" of .dart files, see [non-stupid-digest-assets](https://github.com/alexspeller/non-stupid-digest-assets)
  and [Inability to compile nondigest and digest assets breaks compatibility with bad gems #49](https://github.com/rails/sprockets-rails/issues/49)
  it is optionally (and automatically) available by adding `gem 'non-stupid-digest-assets', '>= 1.1', github: 'm0gg/non-stupid-digest-assets'
` to your Gemfile
  * added dart_app.js to precompile list
  * faced an issue with UglifyJs stackoverflowing with too large dart2js files

v0.2.1 - 18. Oct. 2014:
  * dart2js compilation no longer recurses to infinity and further, this problem came uo to me while working with angularDart, which now compiles fine (takes some time though)
  * sorry for dev-gap, been quite busy in university

v0.2.0 - 08. Oct. 2014:
  * dart-rails can now detect changes in dart code and its dependencies
  * RailsUjs call is now in the initial dart_app.dart template
  * fixed pathname to touch for change recognition
  * renamed relevant constants to Dart2Js
  * bumped ruby-dart2js version to 0.1.0

v0.1.2 - 27. Sep. 2014:
  * slightly different dart2js output directory-tree, now based on md5-hashed timestamps

v0.1.1 - 29. Aug. 2014:
  * dart-rails will no longer break assets:precompile

v0.1.0 - 29. Aug. 2014:
  * Note that `.dart2js` templates are no longer needed. Sprockets
  DirectiveProcessor for Javascript ist now capable of including
  dart2js-compiled scripts via a `//= dart dart_app` directive. See
  updated sample application on github.
  * Errors during dart2js compilation will now be handled by Sprockets
  and thus the exception message will be thrown in the created js file.
  For now there will be also an output on the console.
  * As for newest SprocketsRails there is no longer the need of manually
  adding `dart.js` to the precompilation list.
  * Compiled scripts will reside in the `#{Rails.root}/tmp/cache/` directory.
