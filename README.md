dart-rails
==========

### Idea

Handle [dart](https://www.dartlang.org/ 'dartlang.org') scripts so they get transcoded to js for browsers
without dart support. Currently there's only the `Dartium` browser from the development-kit that supports
dart directly.

For now this is a rather stupid attempt, although it works. 

For a working sample check [m0gg/dart-rails-sample](https://github.com/m0gg/dart-rails-sample 'm0gg/dart-rails-sample').

### Setup

  1. `Gemfile`

        gem 'ruby-dart', :git => 'https://github.com/m0gg/ruby-dart_js.git'
        gem 'dart-rails', :git => 'https://github.com/m0gg/dart-rails.git'

  2. run `rails generate dart:assets` this will bring you:

        $# rails g dart:assets
        create  app/assets/darts
        create  app/assets/darts/dart_app.dart
        create  app/assets/darts/dart_app.js.dart2js
        create  app/assets/darts/pubspec.yaml

  3. Currently you still need to add following to the bottom of your body in the layout:

     `layout.html.erb`

        <%= dart_include_tag 'dart_app' %>
        <%= javascript_include_tag 'dart' %>

  4. *Optional:* run `rake pub:get` to respect the dependencies in your `pubspec.yaml`.
  Initially the pubspec contains `rails_ujs` as dependency, this is just basic for now,
  so you probably want to omit it if you're still using JQuery.

  *Note:* you'll need to point `DART_SDK_HOME` to the root of your dart-sdk unless your `pub` executable is in the `PATH`

### Compatibility

###### ruby-dart_js

This gem is needed for the `dart2js` transcoder compatibility.

See [ruby-dart_js](https://github.com/m0gg/ruby-dart_js) on github for setup.

`<%= javascript_include_tag 'dart' %>` needs to stay as it is unless you want to drop
compatibility for browsers without dart support. It includes the bundled `javascripts/dart.js`
from this gem.

This will parse all script-tags with `type="application/dart"` and replace them with tags that request
the appropriate js file.

    <script type="application/dart" src="/assets/dart_app.dart"></script>

would get

    <script type="application/javascript" src="/assets/dart_app.js"></script>

To provide the transcoded version of you dart-file you'll need a `dart_app.js.dart2js` template/directive which could look
like this

    //= include dart_app

`Dart::Tilt::Dart2jsTemplate` gets registered as `DirectiveProcessor` in `Sprockets` and thus each dart-file
included in the `.dart2js` template gets transcoded and served as js.
