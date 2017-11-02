should()

describe 'Emojis', ->

  before ->
    if Emojis.find().count() is 0
      Emojis.seed()

    Emojis.isSupported = true
    Emojis.useImages = false

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

  describe '#toUnicode', ->

    it 'should convert shortnames in a text to unicode emojis', ->
      text = 'Hello there :boom:'
      result = Emojis.toUnicode(text)
      result.should.contain('💥').and.not.contain ':boom:'

    it 'should not try to convert custom emojis', ->
      text = 'Hello there :trollface:'
      result = Emojis.toUnicode(text)
      result.should.equal 'Hello there '

  describe '#parse', ->

    text = "Hello :boom: I am a :D and :') This is no a smiley:) and this is not an emoji:+1:"

    beforeEach ->
      Emojis.useImages = false
      Emojis.isSupported = true

    it 'should parse text to emoji', ->
      result = Emojis.parse(text)

      result.should
        .contain "<span class='emoji' title='boom'>💥</span>"
        .contain "<span class='emoji' title='smiley'>😃</span>"
        .contain "<span class='emoji' title='blush'>😊</span>"
        .and.contain ':+1:'
        .and.contain ":')"
        .and.not.contain ':)'
        .and.not.contain ':boom:'
        .and.not.contain ':D'

    it 'should parse text to emoji images', ->
      Emojis.useImages = true
      result = Emojis.parse(text)

      result.should
        .contain "<img src='/images/emojis/1f4a5.png' title='boom' alt='💥' class='emoji'>"
        .and.contain "<img src='/images/emojis/1f603.png' title='smiley' alt='😃' class='emoji'>"
        .and.contain ':+1:'
        .and.not.contain ':)'
        .and.not.contain ':boom:'
        .and.not.contain ':D'
