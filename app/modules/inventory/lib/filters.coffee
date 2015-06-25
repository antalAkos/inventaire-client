module.exports =
  initialize: (app)->

    Items.filtered = new FilteredCollection Items

    Items.personal.filtered = new FilteredCollection Items.personal
    Items.friends.filtered = new FilteredCollection Items.friends
    Items.public.filtered = new FilteredCollection Items.public

    app.commands.setHandlers
      'filter:inventory:owner': filterInventoryByOwner
      'filter:inventory:friends': filterInventoryByFriends
      'filter:inventory:group': filterInventoryByGroup
      'filter:inventory:reset': resetInventoryFilter
      'filter:visibility': filterVisibilityBy
      'filter:visibility:reset': resetFilters
      'filter:items:byText': filterItemsByText

visibilityFilters =
  'private': {'listing':'private'}
  'friends': {'listing':'friends'}
  'public': {'listing':'public'}

filterVisibilityBy = (audience)->
  Items.personal.filtered.resetFilters()
  .filterBy audience, visibilityFilters[audience]

resetFilters = ->
  Items.personal.filtered.resetFilters()

resetInventoryFilter = (owner)->
  Items.filtered.resetFilters()

filterInventoryByOwner = (owner)->
  Items.filtered.resetFilters()
  Items.filtered.filterBy 'owner', (model)-> model.get('owner') is owner

filterInventoryByFriends = (owner)->
  Items.filtered.resetFilters()
  Items.filtered.filterBy 'friends', (model)->
    app.request 'user:isFriend', model.get('owner')

filterInventoryByGroup = (groupModel)->
  Items.filtered.resetFilters()
  allMembers = groupModel.allMembers()
  mainUserId = app.user.id
  Items.filtered.filterBy 'group', (model)->
    owner = model.get 'owner'
    if owner in allMembers
      if owner is mainUserId then isntPrivateItem model
      else true
    else false

isntPrivateItem = (model)->
  model.get('listing') isnt 'private'

filterItemsByText = (text, reset)->
  Items.filtered.filterByText text, reset
