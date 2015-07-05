# Force whitespace (\s) between text and emoji/smiley, for safety. Otherwise
# this guy will collide with URLs like http://lolol.com (see the ':/' in there? :D).
shortnameRegexp = /\B:([\w+-]+):/g
smileyRegexp = /\B([:;=#%XB8><](-|\.)?[']?[D|$S3XE<>OP)(\]/\\]|-[_\.]-|<\/?3)/g

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

Emojis = new Mongo.Collection 'emojis',
  transform: (emoji) ->
    
    # Shortcut helpers

    emoji.path = Emojis.basePath() + '/' + imagePath(emoji)
    
    emoji.toHTML = ->
      Emojis.template(this)

    emoji.toHex = ->
      toHex(@emoji)

    return emoji

if Meteor.isServer
  Emojis._ensureIndex(alias: 1)
  Emojis._ensureIndex(ascii: 1)


Emojis._basePath = '/images/emojis'

Emojis.setBasePath = (path) ->
  check path, String

  # Remove trailing slashes.
  Emojis._basePath = path.replace(/\/+$/, '')

Emojis.basePath = ->
  Emojis._basePath

Emojis.template = (emoji) ->
  "<img src='#{Emojis.basePath()}/#{imagePath(emoji)}' title='#{emoji.alias}' alt='#{emoji.emoji or emoji.alias}' class='emoji'>"

Emojis.parse = (text) ->
  if typeof text isnt 'string'
    return ''

  text = text.toString()

  text
  .replace smileyRegexp, (match, smiley, nose) ->
    smiley = smiley.toUpperCase()
    smiley = if nose then smiley.replace(/:-/g, ':') else smiley

    if emoji = Emojis.findOne(ascii: smiley)
      return Emojis.template(emoji)
    else
      return match

  .replace shortnameRegexp, (match, alias) ->
    if emoji = Emojis.findOne(alias: alias)
      return Emojis.template(emoji)
    else
      return match
