export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'tasks(/)(works)(/)': 'showWorksTask',
        'tasks(/)(humans)(/)': 'showHumansTask',
        'tasks(/)(:id)(/)': 'showTask',
      }
    })

    new Router({ controller: API })

    app.commands.setHandlers({
      'show:task': API.showHumansTask
    })
  }
}

const API = {
  showHumansTask (task) { API.showTask(task, 'human') },
  showWorksTask (task) { API.showTask(task, 'work') },
  showTask (task, type) {
    if (app.request('require:loggedIn', 'tasks')) {
      return showLayout({ task, entitiesType: type })
    }
  }
}

const showLayout = async params => {
  const { default: TasksLayout } = await import('./views/tasks_layout.js')
  app.layout.showChildView('main', new TasksLayout(params))
}
