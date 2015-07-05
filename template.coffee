tmpl = new Template 'Template.emoji', ->
  content = ''

  if @templateContentBlock
    # this is for the block usage eg: {{#emoji}}:smile:{{/emoji}}
    content = Blaze._toText(@templateContentBlock, HTML.TEXTMODE.STRING)
  else
    # this is for the direct usage eg: {{> emoji ':blush:'}}
    content = @parentView.dataVar.get()
  
  return HTML.Raw(Emojis.parse(content))

Template.registerHelper 'emoji', tmpl
