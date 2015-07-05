describe 'Emojis', ->

  describe 'Transforms', ->

    beforeEach ->
      Emojis._basePath = '/images/emojis'

    describe '#path', ->

      it 'should be the full path to the emoji image', ->
        emoji = Emojis.findOne(alias: 'smile')

        emoji.path.should.equal '/images/emojis/1f604.png'

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

      it 'should return the template string for the emoji', ->
        emoji = Emojis.findOne(alias: 'smile')
        emoji.toHTML().should.equal "<img src='/images/emojis/1f604.png' title='smile' alt='😄' class='emoji'>"
