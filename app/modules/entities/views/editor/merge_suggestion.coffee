forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
mergeEntities = require './lib/merge_entities'
{ startLoading, stopLoading } = require 'modules/general/plugins/behaviors'

module.exports = Marionette.ItemView.extend
  template: require './templates/merge_suggestion'
  className: -> "merge-suggestion #{@cid}"
  behaviors:
    Loading: {}

  serializeData: ->
    attrs = @model.toJSON()
    attrs.claimsPartial = claimsPartials[@model.type]
    return attrs

  events:
    'click .merge': 'merge'

  merge: ->
    startLoading.call @, ".#{@cid} .loading"
    { toEntity } = @options
    fromUri = @model.get 'uri'
    toUri = toEntity.get 'uri'

    mergeEntities fromUri, toUri
    # Simply hidding it instead of removing it from the collection so that other
    # suggestions don't jump places, potentially leading to undesired merges
    .then => @$el.css 'visibility', 'hidden'
    .finally stopLoading.bind(@)
    .catch error_.Complete(".#{@cid} .merge", false)
    .catch forms_.catchAlert.bind(null, @)

claimsPartials =
  author: 'entities:author_claims'
  edition: 'entities:edition_claims'
  work: 'entities:work_claims'
  serie: 'entities:work_claims'
