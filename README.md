haika.js
===========

配架図エディタ


## Example


## Support Browser

- InternetExplorer 10+
- Firefox 32+
- Google Chrome 36+
- Safari 7+

## Licence

MIT


## Development

python -m SimpleHTTPServer 9998
cd haika/
python manage.py runserver 9999
grunt server
grunt esteWatch

### Dependencies
- `node.js` >= 11.0
- `npm install -g grunt-cli`

### Deploy

```
$ git clone git@github.com:CALIL/haika.js.git
$ cd haika
$ npm install
$ grunt
```

### Commands

- `grunt` concats all files for test.
- `grunt watch` executes `grunt` each time at updating JavaScript files.


### Testing

Open `test/index.html`.
