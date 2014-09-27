casper = require('casper').create()
casper.start 'http://calil.jp', ->
  @echo(@getTitle())
 
casper.then ->
  @capture('Calil.png')
 
casper.run()