// test2.js
var assert = require('assert');

describe('mochaのテスト', function(){
  this.timeout(600);
  it('1秒待つこと', function(done){
    setTimeout(done, 500);
  });
  it('1 + 1は2になること', function(){
    assert.equal(1 + 1, 2);
  });
});