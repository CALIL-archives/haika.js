casper = require('casper').create()
casper.start 'http://127.0.0.1:8080/doc/contact.html', ->
  @fill 'form#contact_form',
    email: 'contact@calil.jp',
    category: 'ご質問',
    content: 'これはフォームのテストです。'
      , true
 
casper.run()