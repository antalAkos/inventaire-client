import showAllAuthorsPreviewLists from '#entities/lib/show_all_authors_preview_lists'
import clampedExtract from '../lib/clamped_extract.js'
import serieInfoboxTemplate from './templates/serie_infobox.hbs'
import ClampedExtract from '#behaviors/clamped_extract'
import EntitiesCommons from '#behaviors/entities_commons'

export default Marionette.View.extend({
  template: serieInfoboxTemplate,
  className: 'serieInfobox',
  behaviors: {
    ClampedExtract,
    EntitiesCommons,
  },

  regions: {
    authors: '.authors',
    scenarists: '.scenarists',
    illustrators: '.illustrators',
    colorists: '.colorists'
  },

  initialize () {
    this.waitForAuthors = this.model.getExtendedAuthorsModels()
    this.model.getWikipediaExtract()
  },

  modelEvents: {
    // The description might be overriden by a Wikipedia extract arriving later
    change: 'lazyRender'
  },

  serializeData () {
    const attrs = this.model.toJSON()
    clampedExtract.setAttributes(attrs)
    attrs.standalone = this.options.standalone
    attrs.showCleanupButton = app.user.hasDataadminAccess
    return attrs
  },

  async onRender () {
    const authorsPerProperty = await this.waitForAuthors
    if (this.isIntact()) showAllAuthorsPreviewLists.call(this, authorsPerProperty)
  }
})
