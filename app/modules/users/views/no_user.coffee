module.exports = Marionette.ItemView.extend
  tagName: 'li'
  className: 'text-center hidden'
  template: require './templates/no_user'
  onShow: -> @$el.fadeIn()