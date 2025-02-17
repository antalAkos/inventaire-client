import { transactionsData } from '#inventory/lib/transactions_data'
import ItemPreview from './item_preview.js'
import itemsPreviewListTemplate from './templates/items_preview_list.hbs'

export default Marionette.CollectionView.extend({
  template: itemsPreviewListTemplate,
  className () {
    let className = 'itemsPreviewList'
    if (this.options.compact) className += ' compact'
    return className
  },

  childViewContainer: '.items-preview',
  childView: ItemPreview,
  childViewOptions () {
    return {
      displayItemsCovers: this.options.displayItemsCovers,
      compact: this.options.compact
    }
  },

  initialize () {
    this.transaction = this.options.transaction
  },

  serializeData () {
    return {
      transaction: this.transaction,
      icon: transactionsData[this.transaction].icon
    }
  }
})
