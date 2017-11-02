should()

describe 'Emojis', ->

  before ->
    Emojis.isSupported = true

  if Meteor.isClient
    before (done) ->
      Meteor.subscribe 'emojis', -> done()

  describe 'Transforms', ->

    beforeEach ->
      Emojis._basePath = '/images/emojis'

    describe '#path', ->

      it 'should be the full path to the emoji image', ->
        emoji = Emojis.findOne(alias: 'smile')
        custom = Emojis.findOne(alias: 'trollface')

        emoji.path.should.equal '/images/emojis/1f604.png'
        custom.path.should.equal '/images/emojis/trollface.png'

      it 'should be based on the base path', ->
        Emojis.setBasePath '/images/smileys'

        emoji = Emojis.findOne(alias: 'smile')

        emoji.path.should.equal '/images/smileys/1f604.png'

    describe '#toHex', ->

      it 'should return the hexadecimal representation of the emoji unicode', ->
        emoji = Emojis.findOne(alias: 'smile')
        emoji.toHex().should.equal '1f604'

      it 'should return empty string for custom emojis', ->
        emoji = Emojis.findOne(alias: 'trollface')
        emoji.toHex().should.equal ''

    describe '#toHTML', ->

      beforeEach ->
        Emojis.isSupported = true
        Emojis.useImages = false

      it 'should return the template string for the emoji', ->
        emoji = Emojis.findOne(alias: 'smile')
        emoji.toHTML().should.equal "<span class='emoji' title='smile'>😄</span>"

      it 'should return the template string with images for the emoji if useImages is true', ->
        Emojis.useImages = true

        emoji = Emojis.findOne(alias: 'smile')
        emoji.toHTML().should.equal "<img src='/images/emojis/1f604.png' title='smile' alt='😄' class='emoji'>"

      it 'should return the template string with images for the emoji if the emoji is custom', ->
        emoji = Emojis.findOne(alias: 'trollface')
        emoji.toHTML().should.equal "<img src='/images/emojis/trollface.png' title='trollface' alt='trollface' class='emoji'>"

      it 'should return the template string with images for the emoji if emojis are not supported', ->
        Emojis.isSupported = false

        emoji = Emojis.findOne(alias: 'smile')
        emoji.toHTML().should.equal "<img src='/images/emojis/1f604.png' title='smile' alt='😄' class='emoji'>"

      it 'should be be able to override the template function', ->
        org = Emojis.template
        Emojis.template = (emoji) -> 'foo'

        emoji = Emojis.findOne()
        emoji.toHTML().should.equal 'foo'

        Emojis.template = org

      it 'should be be able to override the image template function', ->
        org = Emojis.imageTemplate
        Emojis.useImages = true
        Emojis.imageTemplate = (emoji) -> 'foo'

        emoji = Emojis.findOne()
        emoji.toHTML().should.equal 'foo'

        Emojis.imageTemplate = org
