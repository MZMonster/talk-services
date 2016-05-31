_ = require 'lodash'
util = require '../util'

_receiveWebhook = ({query, body}) ->
  payload = _.assign {}
    , query or {}
    , body or {}

  {
    content, authorName, displayType, creator
    title, text, redirectUrl, imageUrl, mention
  } = payload

  throw new Error("Title and text can not be empty") unless title?.length or text?.length or content?.length

  message =
    body: content or payload.body or ''
    authorName: authorName
    creator: creator
    team: payload.team
    displayType: displayType

  if mention and mention._id and mention.name
    message.body = "<$at|#{mention._id}|@#{mention.name}$> #{message.body or ''}"
    message.mentions = [mention._id]

  switch
    when payload._roomId
      message.room = payload._roomId
    when payload._toId
      message.to = payload._toId
    when payload._storyId
      message.story = payload._storyId
    else throw new Err('PARAMS_MISSING', '_toId _roomId _storyId')

  if title or text or redirectUrl or imageUrl
    message.attachments = [
      category: 'quote'
      color: payload.color
      data:
        title: title
        text: text
        redirectUrl: redirectUrl
        imageUrl: imageUrl
    ]

  message

module.exports = ->

  @title = 'Incoming Webhook'

  @template = 'webhook'

  @isCustomized = true

  @summary = util.i18n
    zh: 'Incoming Webhook 是使用普通的 HTTP 请求与 JSON 数据从外部向简聊发送消息的简单方案。'
    en: 'Incoming Webhook makes use of normal HTTP requests with a JSON payload.'

  @description = util.i18n
    zh: 'Incoming Webhook 是使用普通的 HTTP 请求与 JSON 数据从外部向简聊发送消息的简单方案。你可以将 Webook 地址复制到第三方服务，通过简单配置来自定义收取相应的推送消息。'
    en: 'Incoming Webhook makes use of normal HTTP requests with a JSON payload. Copy your webhook address to third-party services to configure push notifications.'

  @iconUrl = util.static 'images/icons/incoming@2x.png'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readOnly: true
    description: util.i18n
      zh: '复制 web hook 地址到你的应用中来启用 Incoming Webhook。'
      en: 'To start using incoming webhook, copy this url to your application'

  @registerEvent 'service.webhook', _receiveWebhook
