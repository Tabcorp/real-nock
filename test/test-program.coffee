unirest = require 'unirest'

exports.multiply = (callback) ->
  unirest.get('http://localhost:6789/value')
         .set('Accept', 'application/json')
         .timeout(100)
         .end (res) ->
           if res.ok
             value = parseInt res.body.value
             callback null, value * 2
           else
             callback new Error('Failed to call backend')
