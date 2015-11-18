if Meteor.isServer
  Meteor.publish 'emojis', ->
    Emojis.find()
