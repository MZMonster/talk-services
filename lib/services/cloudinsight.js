// Generated by CoffeeScript 1.10.0
(function() {
  var _, _receiveWebhook, util;

  _ = require('lodash');

  util = require('../util');

  _receiveWebhook = function(arg) {
    var authorName, body, content, imageUrl, message, payload, query, redirectUrl, text, title;
    query = arg.query, body = arg.body;
    payload = _.assign({}, query || {}, body || {});
    content = payload.content, authorName = payload.authorName, title = payload.title, text = payload.text, redirectUrl = payload.redirectUrl, imageUrl = payload.imageUrl;
    if (!((title != null ? title.length : void 0) || (text != null ? text.length : void 0) || (content != null ? content.length : void 0))) {
      throw new Error("Title and text can not be empty");
    }
    message = {
      body: content,
      authorName: authorName
    };
    if (title || text || redirectUrl || imageUrl) {
      message.attachments = [
        {
          category: 'quote',
          data: {
            title: title,
            text: text,
            redirectUrl: redirectUrl,
            imageUrl: imageUrl
          }
        }
      ];
    }
    return message;
  };

  module.exports = function() {
    this.title = 'Cloud Insight';
    this.template = 'webhook';
    this.summary = util.i18n({
      zh: '系统监控工具',
      en: 'System Monitoring Tool'
    });
    this.description = util.i18n({
      zh: 'Cloud Insight 是一个次世代系统监控工具，支持 Ubuntu 多种操作系统监控，MySQL 多种数据库监控，和 Tomcat 多种中间件监控，以及 Docker Mesos 的监控。',
      en: 'Cloud Insight is a next-generation system monitoring tool which supports operation system monitoring, like Ubuntu, CentOS and so on. In addition, it also can used in database and middleware monitoring including 28 integrations such as Tomcat, Docker, Mesos etc.'
    });
    this.iconUrl = util["static"]('images/icons/cloudinsight@2x.png');
    this._fields.push({
      key: 'webhookUrl',
      type: 'text',
      readOnly: true,
      description: util.i18n({
        zh: '复制 web hook 地址到你的 cloud insight 当中使用。你也可以在管理界面当中找到这个 web hook 地址。',
        en: 'Copy this web hook to your Cloud Insight to use it. You may also find this url in the manager tab。'
      })
    });
    return this.registerEvent('service.webhook', _receiveWebhook);
  };

}).call(this);
