module.exports = Marionette.CompositeView.extend
  template: require './templates/authors_preview_list'
  childViewContainer: 'ul'
  childView: require './author_preview'
