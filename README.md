# Emojis for Meteor 😄

This package makes it easier to manage 💖💥🌈 in your Meteor app.

## Features

- ✅ Renders unicode emojis from shortnames (:smile:).
- ✅ Adds an `Emoji` collection to the client and server filled with over 800 emojis. Suitable for autocompletions and similar.
- ✅ Includes `emoji` template helpers for easy rendering of emojis inside your Meteor templates.
- ✅ Parses arbitrary strings and replaces any emoji shortnames with emoji unicode representations.
- ✅ Parses common ASCII smileys and maps to corresponding emoji.
- ✅ Detects unicode emojis support and fallbacks to images.
- ✅ Customizable base directory for the emoji images. Suitable for CDN usage.

## Installation

```
meteor add lookback:emoji
```

You're not done yet! Continue reading ...

## Get up and running

This package exports a single namespace: `Emojis`. It's a `Mongo.Collection`, and includes some custom methods (see *API* below).

### Emoji images

Some browsers on some systems still don't support native unicode emojis. Read more here: [caniemoji.com](http://caniemoji.com). So we need to fallback to image representations in that case.

This package **does not** include the actual images for the emojis. You can however checkout the images in these emoji projects:

- [Twemoji by Twitter](https://github.com/twitter/twemoji/)
- [Emojione](https://github.com/Ranks/emojione)
- [Gemoji by GitHub](https://github.com/github/gemoji) *(beware: emoji images in here are copyrighted by Apple)*

This package assumes the images are in PNG format and named with their hexadecimal unicode name (like `1f604.png` for the `smile` emoji).

You would typically put the emoji images in the `public/images` directory, in an `emojis` folder. If not, be sure to call `Emojis.setBasePath()` with the custom path (see the API functions below).

### Using the collection

All emojis are initially parsed from the `emojis.json` file in this repo. The `emojis` collection is seeded on application startup if the collection is empty.

Having all emojis in the collection lets you implement things like autocompletions for emojis, where you can query the `alias` and `tags` fields for the given keyboard input.

The emojis in the collection is not published by default. To do so, you need to add this somewhere on your server:

```js
Meteor.publish('emojis', function() {
  // Here you can choose to publish a subset of all emojis
  // if you'd like to.
  return Emojis.find();
});
```

And subscribe on the client:

```js
Meteor.startup(function() {
  Meteor.subscribe('emojis');
});
```

Now you can run arbitrary queries for any emoji on both the server and the client.

```js
Emojis.findOne({
  alias: 'smile'
});
```

That call returns an emoji object with this structure:

```js
{
  // This is the canonical shortname
  alias: "smile",
  description: "smiling face with open mouth and smiling eyes",
  // Unicode symbol
  emoji: "😄",
  tags: ["happy", "joy", "pleased"],
  // Path to emoji image
  path: '/images/emojis/1f604.png'
  // Creates an `img` element for this emoji
  toHTML: function() {...},
  // The Hex representation of this emoji
  toHex: function() {...}
}
```

This package always assumes this data structure when reasoning about an *emoji object*.

### Parsing text

The `Emojis.parse` function takes this:

```
A text with some emojis or smileys :D :boom: :smile:
```

and outputs this:

```html
A text with some emojis or smileys <span title="smiley" class="emoji">😃</span> <span title="boom" class="emoji">💥</span> <span title="smile" class="emoji">😄</span>
```

### Template helpers

For everyday usage, you would use the built-in Blaze templates instead of calling `Emojis.parse` manually:

```html
{{ ! A block of text. Works similar to the built-in Markdown block helper. }}
{{#emoji}}
  A text with some emojis: :boom: :smile:
{{/emoji}}
```

or

```html
{{ ! Or inline helper }}
{{ > emoji ':speech_balloon:'}}
```

## Full API

### Emoji object methods

Called on an emoji object fetched from the database.

#### `emoji.path`

The full path for this emoji:

```js
var emoji = Emojis.findOne({alias: 'smile'});
console.log(emoji.path);
// => "/images/emojis/1f604.png"
```

#### `emoji.toHTML() -> String`

Shortcut function that returns the HTML representation of the emoji.

This depends on these parameters:

- `Emojis.useImages` - force use of image emojis.
- `Emojis.isSupported` - if unicode emojis is supported in the browser or not.
- if the emoji is custom (not in standard unicode).

If emojis aren't supported, `toHTML()` will fallback to images.

```js
// Default behavior.
var emoji = Emojis.findOne({alias: 'smile'});
console.log(emoji.toHTML());
// => <span title="smile" class="emoji">😄</span>

var custom = Emojis.findOne({alias: 'trollface'});
console.log(emoji.toHTML());
// => <img src="images/trollface.png" title="trollface" alt="trollface">
```

You can use `Emojis.useImages` (defaults to the inverse of `Emojis.isSupported`) to force use of images.

#### `emoji.toHex() -> String`

Returns the hexadecimal representation of the unicode emoji:

```js
var emoji = Emojis.findOne({alias: 'smile'});
console.log(emoji.toHex());

// => "1f604"
```

### Static properties

#### `Emojis.useImages`

Defaults to the inverse of `Emojis.isSupported`. Set to `true` to force use of images.

#### `Emojis.isSupported`

Checks browser support for unicode emojis.

### Static functions

Exposed directly in the `Emojis` namespace.

#### `Emojis.parse(text:String) -> String`

*Client and server.*

Takes a string and returns the string with any **emoji shortnames** and **ASCII smileys** replaced with their image representations.

The emoji images will be on this format:

```html
<img src="/<emoji-basepath>/<unicode-name>.png" title="<shortname>" alt="<unicode-version>" class="emoji">
<!-- IRL: -->
<img src="/images/emojis/1f4a5.png" title="boom" alt="💥" class="emoji">
```

#### `Emojis.toUnicode(text:String) -> String`

Parses a text and converts any shortcodes to unicode emojis.

#### `Emojis.template(emoji:Object) -> String`

Takes an *emoji object* and returns its HTML representation.

```js
var emoji = Emojis.findOne({alias: 'smile'});
console.log(Emojis.template(emoji));
// => <span class='emoji' title='smile'>😄</span>
```

You can override this function with your own template function if you want to. The default one looks like this:

```js
/*
  The `emoji` parameter is an emoji object from the collection.
*/
Emojis.template = function(emoji) {
  return '<span class="emoji" title="' + emoji.alias + '">' + emoji.emoji + '</span>';
};
```

#### `Emojis.imageTemplate(emoji:Object) -> String`

Same as `Emojis.template`, but for images.

```js
var emoji = Emojis.findOne({alias: 'smile'});
console.log(Emojis.imageTemplate(emoji));
// => <img src="/images/emojis/1f604.png" title="smile" alt="😄" class="emoji">
```

#### `Emojis.setBasePath(path:String)`

*Client and server.*

The *base path* is where the package shall put in front of the image name. Defaults to `/images/emojis`. Set this in some init routine of yours.

If you're using a CDN network like CloudFront or similar, you should call this function with the root CDN path in order to use the CDN niceties.

Sample usage:

```js
// Assume:
Meteor.settings.public.cdnUrl = 'https://foobar.cloudfront.net';

// ...

if(Meteor.settings.public.cdnUrl) {
  Emojis.setBasePath(Meteor.settings.public.cdnUrl + '/images/emojis');
}
```

#### `Emojis.basePath() -> String`

*Client and server.*

Returns the current base path.

#### `Emojis.seed() -> Number`

*Server only.*

Wipes the `emojis` collection, and re-populates it from the `emojis.json` file. Returns the number of emojis inserted. Useful for when you've made changes to the JSON file and wants to update the collection.

Sample usage (on the server):

```js
/**
 * Expose a `emojis/reset` method for resetting the emojis collection.
 * For admins only.
 */
Meteor.methods({
  'emojis/reset': function() {
    if(!Meteor.userId() || !Meteor.user().admin) {
      throw new Meteor.Error(403, 'Access denied.');
    }

    var count = Emojis.seed();
    return 'Inserted ' + count + ' emojis.';
  }
});
```

## Suggested styling

Style the `.emoji` class like this with CSS to achieve a nice vertical aligned position for the emoji images:

```css
img.emoji {
  font-size: inherit;
  height: 2.7ex;
  /* prevent img stretch */
  width: auto;
  min-width: 15px;
  min-height: 15px;

  /* Inline alignment adjust the margins  */
  display: inline-block;
  margin: -0.4ex .15em 0;
  line-height: normal;
  vertical-align: middle;
}
```

## Tests

Run tests with

```
make test
```

Watch mode:

```
make runner
```

## Version history

- `0.4.1` - Let `Emojis.getAllTokens` return an object with `total`, `smileys`, and `emojis` props.
- `0.4.0` - Add `Emojis.getAllTokens` method for getting all raw matched tokens from a text.
- `0.3.4` - Fix spacing issues when parsing smileys.
- `0.3.3` - Fix `testBD` being parsed to `test😎`.
- `0.3.2` - Fix `testBDfoo` being parsed to `test😎`. I.e. require whitespace between ASCII smileys.
- `0.3.1` - Add polyfill for `String.fromCodePoint`.
- `0.3.0`
  This release moves to using native unicode emojis as default. If native emojis are not supported in the browser, it'll fallback to the previous image solution.

  - Add `Emojis.isSupported` variable for checking for native unicode support.
  - Add `Emojis.useImages` for forcing use of images over unicode.
- `0.2.0` - Add `Emojis.toUnicode` function.
- `0.1.0` - Initial publish.

***

Made by [Lookback](http://github.com/lookback).
