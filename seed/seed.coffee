Emojis.seed = ->
  Emojis.remove({})
  emojis = JSON.parse(Assets.getText 'seed/emojis.json')
  count = 0

  if emojis and Array.isArray(emojis)
    count = emojis.reduce (memo, emoji) ->

      # I wanna have a canonical alias, not an array of them.
      # Thus fetch the first alias and put the rest, if exists,
      # in the tags array.
      emoji.alias = emoji.aliases[0]
      emoji.tags = emoji.tags.concat(_.rest(emoji.aliases))

      delete emoji.aliases
      Emojis.insert(emoji)

      return memo + 1
    , 0

  return count

Meteor.startup ->
  if Emojis.find().count() is 0
    Emojis.seed()
