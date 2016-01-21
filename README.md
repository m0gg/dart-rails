# dart-rails [![dart-rails API Documentation](https://www.omniref.com/ruby/gems/dart-rails.png)](https://www.omniref.com/ruby/gems/dart-rails) [![Gem Version](https://badge.fury.io/rb/dart-rails.svg)](http://badge.fury.io/rb/dart-rails) #

### Idea ###

Handle [dart](https://www.dartlang.org/ 'dartlang.org') scripts so they get compiled to js for browsers
without dart support. Currently there's only the `Dartium` browser from the development-kit that supports
dart natively.

For a working sample check [m0gg/dart-rails-sample](https://github.com/m0gg/dart-rails-sample 'm0gg/dart-rails-sample').

## Attention ##
If you're upgrading from versions prior `0.4.2` and use `sprockets >= 3.0.0` you need to replace your
`dart_app.js.dart2js` or `dart_app.js` (depends form which version you're upgrading) with a symlink pointing to
your `dart_app.dart` as `sprockets >= 3.0.0` no longer supports the `//= include` directive.

example `ls app/assets/dart/`
```bash
$ ls app/assets/dart/dart_app.*
app/assets/dart/dart_app.dart  app/assets/dart/dart_app.js.dart2js
```



### Setup ###

1. `Gemfile`

  ```ruby
  gem 'ruby-dart2js', git: 'https://github.com/m0gg/ruby-dart2js'
  gem 'dart-rails', git: 'https://github.com/m0gg/dart-rails.git', branch: 'behavior_change_dart2js'
   ```

2. `rails generate dart:assets`

  ```sh
  rails g dart:assets
  create  app/assets/dart
  create  app/assets/dart/dart_app.dart
  create  app/assets/dart/dart_app.js.dart2js
  create  app/assets/dart/pubspec.yaml
  ```

3.  Delivering dart/javascript code.

    You have four options. You can use one and only one of the following four:

    - deliver javascript code compiled from dart

        ```
            //= require dart_app
        ```
        Append the above to your "AppRoot/app/assets/javascripts/application.js"
        While this enables you to add several dart programs, there is no guarantee
        it will work out. (untested)
    
    - deliver the code in dart first, then on the browser side fetch the javascript code generated from dart, if the browser was not dartium.

        add the following tags to your layout (`layout.html.erb` or `application.html.erb`) after the yield statement.
        ```
        <%= dart_include_tag 'dart_app' %>
        <%= javascript_include_tag 'dart' %>
        ```

    - deliver dart only

        add the `dart_include_tag` to your layout after the yield statement.
        ```
        <%= dart_include_tag 'dart_app' %>
        ```
        Note: You must set "config.assets.digest" to false in "AppRoot/config/environments/development.rb" 

    - deliver the code in dart for access from dartium and for acesss from other browsers, in javascript
        ```
        <%= auto_dart_include_tag 'dart_app', {debug:true,defer:true} %>
        ```
        This option is digesting and turbolinks safe, but has not been tested thoroughly.<br>
        Note: Without {debug:true} explicitly passed to the helper, you may encounter: 
        ```Asset was not declared to be precompiled in production.```
        This occures with sprockets (3.5.2) as it relies solely on on the tag's option argument :debug on deciding the value of allow_non_precompiled in Sprockets::Rails::Helper#resolve_asset_path.<br>
        Note2: Currently there is a bug or design flaw that causes the dart script compiled to javascript to ignore all dom elements that come below the dart script tag(auto_dart_include_tag in our case): https://github.com/dart-lang/sdk/issues/25103
        Provide the "defer:true" option to the helper to circumvent the issue.
         
4. `rake pub:get`

    run `rake pub:get` to respect the dependencies in your `pubspec.yaml`.
    Initially the pubspec contains `rails_ujs` as dependency, this is just basic for now,
    so you probably want to omit it if you're still using JQuery.

5. ruby-dart2js

    See [ruby-dart2js](https://github.com/m0gg/ruby-dart2js) on github for setup.


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

*Attention* currently not working with `rails >= 4.2`

As of rails 4 we are facing a problem for the productive environments.
See [Inability to compile nondigest and digest assets breaks compatibility with bad gems #49](https://github.com/rails/sprockets-rails/issues/49)

You may optionally add this to your Gemfile

```
gem 'non-stupid-digest-assets', '>= 1.1', github: 'm0gg/non-stupid-digest-assets'
```

this will enable a workaround for digesting the assets while precompiling dart files as
seen in [non-stupid-digest-assets](https://github.com/alexspeller/non-stupid-digest-assets) and
additionally rewrite the manifests to use the non-digest files.


### Changelog ###
v0.4.2 - 16. Dec 2015:
  * full compat with sprockets 2 & 3 by switching to symlinked dart_app.js.dart2js
  * fixed dart2js compilation by data
  * requires `dart2js ~> 0.3.0`

v0.4.0 - 4. Dec. 2015:
  * you now need a dart_app.js.dart2js template with following content:

  `app/assets/dart/dart_app.js.dart2js`
  ```javascript
  //= include dart_app.dart
  ```

v0.3.3 - 9. Nov. 2015:
  * support for sprockets-rails > 2.3.0

v0.3.2-p1 - 9. Nov. 2015:
  * remain support for sprockets-rails prior 2.3.0

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
