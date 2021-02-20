import AuthorLayout from 'modules/entities/views/author_layout'
import currentTaskTemplate from './templates/current_task.hbs'

export default Marionette.LayoutView.extend({
  template: currentTaskTemplate,
  serializeData () {
    return _.extend(this.model.serializeData(),
      { showSourcesLinks: true })
  },

  regions: {
    suspect: '#suspect',
    suggestion: '#suggestion',
    otherSuggestions: '#otherSuggestions'
  },

  onShow () {
    this.showAuthor('suspect')
    this.showAuthor('suggestion')
  },

  showAuthor (name) {
    return this[name].show(new AuthorLayout({
      model: this.model[name],
      initialWorksListLength: 20,
      wrapWorks: true,
      noAuthorWrap: true,
      standalone: true
    }))
  }
})
