should()

describe 'Emojis', ->

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


