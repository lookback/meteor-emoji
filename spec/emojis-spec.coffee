should()

if Meteor.isServer
  Meteor.publish 'emojis', ->
    Emojis.find()

describe 'Emojis', ->

  if Meteor.isClient
    before (done) ->
      Meteor.subscribe 'emojis', -> done()

  beforeEach ->
    Emojis._basePath = '/images/emojis'

    @emoji =
      emoji: '😄'
      description: 'smiling face with open mouth and smiling eyes'
      alias: 'smile'
      tags: ['happy', 'joy', 'pleased']

    @customEmoji =
      alias: ['trollface']
      tags: []

  it 'should be exported as "Emojis"', ->
    Emojis.should.be.an 'Object'

  describe '#setBasePath', ->

    it 'should be able to set a new image base path', ->
      Emojis.setBasePath '/some/other/path'
      Emojis._basePath.should.equal '/some/other/path'

    it 'should strip trailing slashes', ->
      Emojis.setBasePath '/some/path/'
      Emojis._basePath.should.equal '/some/path'

  describe '#template', ->

    it 'should return a string template for an emoji', ->
      template = Emojis.template(@emoji)
      template.should.equal "<img src='/images/emojis/1f604.png' title='smile' alt='😄' class='emoji'>"

    it 'should return a string template for a custom emoji', ->
      template = Emojis.template(@customEmoji)
      template.should.equal "<img src='/images/emojis/trollface.png' title='trollface' alt='trollface' class='emoji'>"

  describe '#toUnicode', ->

    it 'should convert shortnames in a text to unicode emojis', ->

      text = 'Hello there :boom:'
      result = Emojis.toUnicode(text)
      result.should.contain('💥').and.not.contain ':boom:'

  describe '#parse', ->

    beforeEach ->
      @text = 'Hello :boom: I am a :D. This is no a smiley:) and this is not an emoji:+1:'

    it 'should parse text to emoji images', ->

      result = Emojis.parse(@text)

      result.should
        .contain "<img src='/images/emojis/1f4a5.png' title='boom' alt='💥' class='emoji'>"
        .and.contain "<img src='/images/emojis/1f603.png' title='smiley' alt='😃' class='emoji'>"
        .and.contain ':)'
        .and.contain ':+1:'
        .and.not.contain ':boom:'
        .and.not.contain ':D'
