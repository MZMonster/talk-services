qs = require 'querystring'
Promise = require 'bluebird'
request = require 'request'
_ = require 'lodash'
requestAsync = Promise.promisify request

util = require '../util'

_sendToRobot = ({message}) ->
  talkai = this

  return unless message.body?.length
  return unless talkai.config.apikey and talkai.config.url

  _sendToHubot.call this, message

_sendToHubot = (message) ->
  talkai = this

  requestAsync
    method: 'POST'
    url: talkai.config.url
    body: message
    json: true
    timeout: 20000

  .then (res) ->
    unless res.statusCode >= 200 and res.statusCode < 300
      throw new Error("Bad request #{res.statusCode}")

module.exports = ->

  @title = '小艾'

  @isHidden = true

  @iconUrl = util.static 'images/icons/talkai@2x.png'

  @config = util.config.talkai

  @registerEvent 'message.create', _sendToRobot
