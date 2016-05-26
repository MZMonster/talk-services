qs = require 'querystring'
Promise = require 'bluebird'
request = require 'request'
_ = require 'lodash'
requestAsync = Promise.promisify request

util = require '../util'

_sendToRobot = ({message}) ->

  talkai = this

  return unless message.body?.length

  return unless talkai.config.apikey and talkai.config.devid

  _getTuringCallback.call this, message

  .then (body) ->

    return unless body?.content or body?.text or body?.title

    ['content', 'title', 'text'].forEach (key) ->
      return unless body[key]
      body[key] = body[key].replace? /图灵机器人/g, '小艾'

    replyMessage = {}
    replyMessage.body = body.content if body.content

    if body.text or body.title
      attachment = category: 'quote', data: body
      attachment.data.category = 'talkai'
      replyMessage.attachments = [attachment]

    replyMessage

_getTuringCallback = (message) ->

  talkai = this

  query =
    key: talkai.config.apikey
    info: message.body
    userid: message._creatorId.toString()

  requestAsync
    method: 'POST'
    url: talkai.config.url
    body: query
    json: true
    timeout: 20000

  .then (res) ->
    unless res.statusCode >= 200 and res.statusCode < 300
      throw new Error("Bad request #{res.statusCode}")
    data = res.body
    if data.code.toString() in Object.keys talkai.config.errorCodes
      code = parseInt(req.code)
      errMsg = talkai.config.errorCodes[req.code]
      throw new Error("Bad response from Tuling123.com: #{errMsg}")
    body = {}
    switch data.code
      when talkai.config.textCode
        reBr = new RegExp(/<br>/g)
        reSemi = new RegExp(/;/g)
        if data.text.split(':').length is 2
          reComma = new RegExp(/:/g)
          body.content = data.text.replace(reBr, "\n").replace(reSemi, ";\n").replace(reComma, ":\n")
        else
          body.content = data.text.replace(reBr, "\n").replace(reSemi, ";\n")
      when talkai.config.urlCode
        body.content = "[#{data.text}](#{data.url})"
      when talkai.config.newsCode
        body.content = ''
        data.list.forEach (el) ->
          body.content += "\n[#{el.article}](#{el.detailurl})"
      when talkai.config.trainCode
        body.content = ''
        data.list.forEach (el) ->
          body.content += "\n[#{el.trainnum} #{el.start} - #{el.terminal} / 时间: #{el.starttime} - #{el.endtime}](#{el.detailurl})"
      when talkai.config.flightCode
        body.text = "<ul>"
        data.list.forEach (el) ->
          # body.text += "<li><a href=" + el.detailurl + ">#{el.flight} / 时间: #{el.starttime} - #{el.endtime}</a></li>"
          body.text += "<li>#{el.flight} / 时间: #{el.starttime} - #{el.endtime}</li>"
        body.text += "</ul>"
      when talkai.config.othersCode
        body.content = ''
        i = 0
        data.list.forEach (el) ->
          return if i > 4
          i += 1
          body.content += "\n[#{el.name}](#{el.detailurl})\n\t- #{el.info}"

    return body

module.exports = ->

  @title = '小艾'

  @isHidden = true

  @iconUrl = util.static 'images/icons/talkai@2x.png'

  @config = _.assign
    url: "http://www.tuling123.com/openapi/api"
    errorCodes:
      40001: "key的长度错误"
      40002: "请求内容为空"
      40003: "key错误或帐号未激活"
      40004: "当天请求次数已用完"
      40005: "暂不支持该功能"
      40006: "服务器升级中"
      40007: "服务器数据格式异常"
    textCode: 100000
    urlCode: 200000
    newsCode: 302000
    trainCode: 305000
    flightCode: 306000
    othersCode: 308000
  , util.config.talkai

  @registerEvent 'message.create', _sendToRobot
