// Generated by CoffeeScript 1.10.0
(function() {
  var _getEvents, util;

  util = require('../util');

  _getEvents = function() {
    return [
      {
        key: 'mention',
        label: util.i18n({
          zh: '@我',
          en: '@me'
        })
      }, {
        key: 'repost',
        label: util.i18n({
          zh: '转发',
          en: 'Repost'
        })
      }, {
        key: 'comment',
        label: util.i18n({
          zh: '评论',
          en: 'Comment'
        })
      }
    ];
  };

  module.exports = function() {
    var events, ref, service;
    service = this;
    this.title = '微博';
    this.summary = util.i18n({
      zh: '通过关注机制分享简短实时信息的社交网络平台。',
      en: 'Weibo is one of the most popular social network in China.'
    });
    this.description = util.i18n({
      zh: '微博是中国最流行的社交媒体平台之一。通过添加微博聚合，你可以设置将绑定账号的提及、转发和评论消息推送到你所选择的简聊话题中。',
      en: 'Weibo is one of the most popular social network in China. This integration allows you recieve mentions, reposts and replies.'
    });
    this.iconUrl = util["static"]('images/icons/weibo@2x.png');
    this._fields.push({
      key: 'events',
      items: _getEvents.apply(this)
    });
    if ((ref = process.env.NODE_ENV) === 'ga' || ref === 'prod') {
      this.serviceUrl = 'http://apps.teambition.corp:7410';
    } else {
      this.serviceUrl = 'http://localhost:7410';
    }
    events = ['integration.create', 'integration.remove', 'integration.update'];
    return events.forEach(function(event) {
      return service.registerEvent(event, function(req) {
        return service.httpPost(service.serviceUrl, {
          event: event,
          data: req.integration
        });
      });
    });
  };

}).call(this);