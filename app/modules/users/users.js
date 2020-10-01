import preq from 'lib/preq'
import UserContributions from './views/user_contributions'

export default {
  define (module, app, Backbone, Marionette, $, _) {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'u(sers)/:id/contributions(/)': 'showUserContributions',
        // Aliases
        'u(sers)/:id(/)': 'showUser',
        'u(sers)(/)': 'showSearchUsers'
      }
    })

    app.addInitializer(() => new Router({ controller: API }))
  },

  initialize () {
    app.users = require('./users_collections')(app)

    require('./helpers')(app)
    require('./requests')(app, _)
    require('./invitations')(app, _)

    initRelations()

    app.commands.setHandlers({
      'show:user': app.Execute('show:inventory:user'),
      'show:user:contributions': API.showUserContributions
    })

    app.reqres.setHandlers({
      // Refreshing relations can be useful
      // to refresh notifications counters that depend on app.relations
      'refresh:relations': initRelations
    })
  }
}

const API = {
  showUserContributions (idOrUsername) {
    if (app.request('require:loggedIn', `users/${idOrUsername}/contributions`)) {
      return app.request('resolve:to:userModel', idOrUsername)
      .then(user => {
        const username = user.get('username')
        const path = `users/${username}/contributions`
        app.navigate(path, { metadata: { title: 'contributions' } })
        if (app.request('require:admin:access')) {
          return app.layout.main.show(new UserContributions({ user }))
        }
      })
    }
  },

  showUser (id) { app.execute('show:inventory:user', id) },
  showSearchUsers () { app.execute('show:users:search') }
}

const initRelations = function () {
  if (app.user.loggedIn) {
    return preq.get(app.API.relations)
    .then(relations => {
      app.relations = relations
      app.execute('waiter:resolve', 'relations')
    })
    .catch(_.Error('relations init err'))
  } else {
    app.relations = {
      friends: [],
      userRequested: [],
      otherRequested: [],
      network: []
    }
    app.execute('waiter:resolve', 'relations')
  }
}
