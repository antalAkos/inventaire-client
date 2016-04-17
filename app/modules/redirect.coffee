Welcome = require 'modules/welcome/views/welcome'
ErrorView = require 'modules/general/views/error'
CallToConnection = require 'modules/general/views/call_to_connection'
initQuerystringActions = require 'modules/general/lib/querystring_actions'
DonateMenu = require 'modules/general/views/donate_menu'
FeedbackMenu = require 'modules/general/views/feedback_menu'

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    Router = Marionette.AppRouter.extend
      appRoutes:
        '(home)': 'showHome'
        'welcome': 'showWelcome'
        'donate': 'showDonate'
        'feedback': 'showFeedback'
        'me': 'showMainUser'
        '*route': 'notFound'

    app.addInitializer ->
      new Router
        controller: API

  initialize: ->
    app.reqres.setHandlers
      'require:loggedIn': requireLoggedIn
      'show:login:redirect': requireLoggedIn

    app.commands.setHandlers
      'show:home': API.showHome
      'show:welcome': API.showWelcome
      'show:error:missing': showErrorMissing
      'show:offline:error': showOfflineError
      'show:call:to:connection': showCallToConnection
      'show:error:cookieRequired': showErrorCookieRequired

    # should be run before app start to access the unmodifed url
    initQuerystringActions()

API =
  showHome: ->
    if app.user.loggedIn then app.execute 'show:inventory:general'
    else app.execute 'show:welcome'

  notFound: (route)->
    if app.user.loggedIn
      _.log route, 'route:notFound', true
      app.execute 'show:error:missing'
    else @showWelcome()

  showWelcome: ->
    title = 'Inventaire - ' + _.i18n('your friends and communities are your best library')
    app.layout.main.Show new Welcome,
      docTitle: title
      noCompletion: true
    app.navigate 'welcome'

  showDonate: -> showMenuStandalone DonateMenu, 'donate'
  showFeedback: -> showMenuStandalone FeedbackMenu, 'feedback'
  showMainUser: -> app.execute 'show:inventory:main:user'

requireLoggedIn = (route)->
  if app.user.loggedIn then return true
  else
    app.execute 'show:login'
    # the route shouldn't have the first '/'. ex: inventory/georges
    route = route.replace /^\//, ''
    app.execute 'prepare:login:redirect', route
    return false

showErrorMissing = ->
  showError
    icon: 'warning'
    header: _.I18n 'oops'
    message: _.i18n "this resource doesn't exist or you don't have the right to access it"

showOfflineError = ->
  showError
    icon: 'plug'
    header: _.i18n "can't reach the server"

showErrorCookieRequired = (command)->
  showError
    icon: 'cog'
    header: _.I18n 'cookies are disabled'
    message: _.i18n 'cookies_are_required'
    redirection:
      text: _.I18n 'retry'
      classes: 'dark-grey'
      buttonAction: ->
        if command? then app.execute command
        else location.href = location.href

showError = (options)->
  _.log options, 'showError', true
  app.layout.main.show new ErrorView options

showCallToConnection = (message)->
  app.layout.modal.show new CallToConnection
    connectionMessage: message

showMenuStandalone = (Menu, titleKey)->
  view = new Menu { standalone: true }
  app.layout.main.Show view, { docTitle: _.i18n(titleKey) }
