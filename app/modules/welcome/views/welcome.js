import log_ from '#lib/loggers'
import preq from '#lib/preq'
import showPaginatedItems from '../lib/show_paginated_items.js'
import * as urls from '#lib/urls'
import Mentions from './mentions.js'
import welcomeTemplate from './templates/welcome.hbs'
import '../scss/welcome.scss'
import AlertBox from '#behaviors/alert_box'
import DeepLinks from '#behaviors/deep_links'
import Loading from '#behaviors/loading'
import SuccessCheck from '#behaviors/success_check'

export default Marionette.View.extend({
  id: 'welcome',
  template: welcomeTemplate,
  regions: {
    previewColumns: '#previewColumns',
    mentions: '#mentions'
  },

  initialize () {
    this.waitForMention = getMentionsData()
  },

  events: {
    'click .toggleMission': 'toggleMission'
  },

  behaviors: {
    AlertBox,
    DeepLinks,
    Loading,
    SuccessCheck,
  },

  serializeData () {
    return {
      loggedIn: app.user.loggedIn,
      urls,
      needNameExplanation: app.user.lang !== 'fr'
    }
  },

  ui: {
    thanks: '#thanks',
    missionsList: 'ul.mission',
    missions: 'ul.mission li',
    missionsTogglers: '.toggleMission .fa',
    landingScreen: '#landingScreen'
  },

  async onRender () {
    this.showPublicItems()

    const data = await this.waitForMention
    if (this.isIntact()) this.showMentions(data)
  },

  async showPublicItems () {
    const limit = window.screen.width < 470 ? 7 : 15
    showPaginatedItems({
      layout: this,
      regionName: 'previewColumns',
      requestName: 'items:getRecentPublic',
      requestParams: {
        lang: app.user.lang,
        assertImage: true,
      },
      allowMore: false,
      limit,
    })
    .catch(this.hidePublicItems.bind(this))
    .catch(log_.Error('hidePublicItems err'))

    this.triggerMethod('child:view:ready')
  },

  hidePublicItems (err) {
    $('#lastPublicBooks').hide()
    if (err != null) throw err
  },

  toggleMission (e) {
    this.ui.missions.slideToggle()
    this.ui.missionsTogglers.toggle()
    const currentAriaExpandedValue = this.ui.missionsList.attr('aria-expanded') === 'true'
    this.ui.missionsList.attr('aria-expanded', !currentAriaExpandedValue)
  },

  showMentions (data) {
    this.triggerMethod('child:view:ready')
    this.showChildView('mentions', new Mentions({ data }))
  }
})

// no need to fetch mentions data more than once per session
let mentionsData = null
const getMentionsData = async () => {
  mentionsData = mentionsData || await preq.get(app.API.json('mentions'))
  return mentionsData
}
