# Force whitespace between text and emoji/smiley, for safety. Otherwise
# this guy will collide with URLs like http://lolol.com (see the ':/' in there? :D).
shortnameRegexp = /\B:([\w+-]+):/g
smileyRegexp = /(\<[\/\\]?3|[\(\)\\\D|\*\$][\-\^]?[\;\=]|[\:\;\=B8][\-\^]?[3DOPp\@\$\*\\\)\(\/\|])(?=\s|[\!\.\?]|$)/g

# Emulation of Ruby's String#codepoints. Takes Javascript's flawed
# unicode implementation into consideration regarding surrogate pairs.
toCodePoints = (str) ->
    chars = []
    i = 0

    while i < str.length
        c1 = str.charCodeAt(i)

        if c1 >= 0xD800 and c1 < 0xDC00 and i+1 < str.length
            c2 = str.charCodeAt(i+1)
            if c2 >= 0xDC00 && c2 < 0xE000
                chars.push(0x10000 + ((c1-0xD800)<<10) + (c2-0xDC00))
                i += 2
                continue

        chars.push(c1)
        i++

    return chars

isCustom = (emoji) ->
  emoji and typeof emoji.emoji is 'undefined'

toHex = (str) ->
  return '' if not str

  toCodePoints(str).map (char) ->
    char.toString(16)
  .join('-')

imagePath = (emoji) ->
  if isCustom(emoji)
    "#{emoji.alias}.png"
  else
    "#{toHex(emoji.emoji).replace(/-fe0f\b/, '')}.png"

toImage = (emoji) ->
  "<img src='#{emoji.path}' title='#{emoji.alias}' alt='#{emoji.emoji or emoji.alias}' class='emoji'>"

wrap = (emoji) ->
  "<span class='emoji' title='#{emoji.alias}'>#{emoji.emoji}</span>"

Emojis = new Mongo.Collection 'emojis',
  transform: (emoji) ->

    # Shortcut helpers

    emoji.path = Emojis.basePath() + '/' + imagePath(emoji)

    emoji.toHTML = ->
      if !Emojis.isSupported or isCustom(this) or Emojis.useImages then Emojis.imageTemplate(this) else Emojis.template(this)

    emoji.toHex = ->
      toHex(@emoji)

    return emoji

if Meteor.isServer
  Emojis._ensureIndex(alias: 1)
  Emojis._ensureIndex(ascii: 1)


# General parse function.
#
# Parses `text` and returns emoji objects from :shortnames: and ASCII
# smileys (:D).
#
# Optionally takes a function which can transform the return value.
parse = (text, fn) ->
  check text, String
  check fn, Match.Optional(Function)

  text
  .replace smileyRegexp, (match, smiley, nose) ->
    smiley = smiley.toUpperCase()
    smiley = if nose then smiley.replace(/:-/g, ':') else smiley

    emoji = Emojis.findOne(ascii: smiley)

    if emoji
      return if fn then fn(emoji) else emoji
    else
      return match

  .replace shortnameRegexp, (match, alias) ->
    emoji = Emojis.findOne(alias: alias)

    if emoji
      return if fn then fn(emoji) else emoji
    else
      return match

Emojis._basePath = '/images/emojis'

Emojis.setBasePath = (path) ->
  check path, String

  # Remove trailing slashes.
  Emojis._basePath = path.replace(/\/+$/, '')

Emojis.basePath = ->
  Emojis._basePath

# Overridable

Emojis.template = wrap
Emojis.imageTemplate = toImage

# Replace emoji shortnames with their unicode version.
Emojis.toUnicode = (text) ->
  parse text, (emoji) -> emoji.emoji || ''

Emojis.parse = (text) ->
  parse text, (emoji) -> emoji.toHTML()

# From https://gist.github.com/mwunsch/4710561
Emojis.isSupported = do ->
  if Meteor.isServer
    return true

  canvas = document.createElement('canvas')
  if !canvas.getContext
    return

  context = canvas.getContext('2d')

  if typeof context.fillText isnt 'function'
    return

  # :smile: String.fromCharCode(55357) + String.fromCharCode(56835)
  smile = String.fromCodePoint(0x1F604)

  context.textBaseline = "top"
  context.font = "32px Arial"
  context.fillText(smile, 0, 0)

  context.getImageData(16, 16, 1, 1).data[0] isnt 0

if Meteor.isClient
  Emojis.useImages ||= !Emojis.isSupported
else
  Emojis.useImages ||= false
