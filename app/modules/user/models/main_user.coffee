Filterable = require 'modules/general/models/filterable'
Transactions = require 'modules/transactions/collections/transactions'
Groups = require 'modules/network/collections/groups'

module.exports = Filterable.extend
  url: ->
    app.API.user

  parse: (data)->
    _.log data, 'data:main user parse data'
    { notifications, relations, transactions, groups } = data
    @addNotifications(notifications)
    @relations = relations
    @transactions = new Transactions transactions
    @groups = new Groups groups
    app.vent.trigger 'transactions:unread:changes'
    return _(data).omit ['relations', 'notifications', 'transactions', 'groups']

  initialize: ->
    @setLang()
    @on 'change:language', @setLang
    @on 'change:username', @setPathname

  setLang: -> @lang = @get('language')?[0..1]
  setPathname: ->
    username = @get('username')
    @set 'pathname', "/inventory/#{username}"

  addNotifications: (notifications)->
    if notifications?
      app.request('waitForData')
      .then app.request.bind(app, 'notifications:add', notifications)

  serializeData: ->
    attrs = @toJSON()
    attrs.mainUser = true
    return attrs
