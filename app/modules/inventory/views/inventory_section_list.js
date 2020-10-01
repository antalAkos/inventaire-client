const ListEl = Marionette.ItemView.extend({
  tagName: 'li',
  template: require('./templates/inventory_section_list_li'),

  initialize () {
    ({ context: this.context, group: this.group } = this.options)
    if (this.model.get('hasItemsCount')) {
      return this.model.waitForItemsCount.then(this.lazyRender.bind(this))
    }
  },

  serializeData () {
    const attrs = this.model.serializeData()
    attrs.isGroup = attrs.type === 'group'
    attrs.isGroupAdmin = this.isGroupAdmin()
    return attrs
  },

  events: {
    'click a': 'selectInventory'
  },

  isGroupAdmin () {
    return (this.context === 'group') && (this.group.allAdminsIds().includes(this.model.id))
  },

  selectInventory (e) {
    if (_.isOpenedOutside(e)) return
    let type = this.model.get('type') || 'user'
    if ((type === 'user') && (this.context === 'group')) { type = 'member' }
    app.vent.trigger('inventory:select', type, this.model)
    return e.preventDefault()
  }
})

export default Marionette.CollectionView.extend({
  tagName: 'ul',
  childView: ListEl,
  childViewOptions () {
    return {
      context: this.options.context,
      group: this.options.group
    }
  }
})
