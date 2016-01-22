error_ = require 'lib/error'

module.exports = (app)->
  sync =
    getUserModelFromUserId: (id)->
      if id is app.user.id then return app.user

      userModel = app.users.byId id
      if userModel? then userModel
      else return

    getUserIdFromUsername: (username)->
      if username is app.user.get('username') then return app.user.id

      userModel = app.users.findWhere({username: username})
      if userModel? then userModel.id
      else console.warn "couldnt find the user from username: #{username}"

    getProfilePicFromUserId: (id)->
      if id is app.user.id then return app.user.get 'picture'

      userModel = app.users.byId(id)
      if userModel? then userModel.get 'picture'
      else console.warn "couldnt find the user from id: #{id}"

    isMainUser: (userId)->
      if userId? then return userId is app.user.id

    isFriend: (userId)->
      unless userId? and app.users?.friends?.list?
        _.warn userId, 'isFriend isnt ready (use or recalculate after data waiters)'
        return false
      return userId in app.users.friends.list

    isPublicUser: (userId)->
      if sync.isMainUser(userId) then return false
      unless app.user.loggedIn then return true
      unless userId? and app.users?.public?.list?
        _.warn userId, 'isPublicUser isnt ready (use or recalculate after data waiters)'
        return true
      # NB: nonRelationGroupUser aren't considerer public users
      # as their user and items data are fetched as friends
      return userId in app.users.public.list

    itemsFetched: (userModel)->
      unless _.isModel(userModel)
        throw error_.new 'itemsFetched expected a model', userModel
      return userModel.itemsFetched is true

    getNonFriendsIds: (usersIds)->
      _.type usersIds, 'array'
      _(usersIds).chain()
      .without app.user.id
      .reject sync.isFriend
      .value()

  sync.getUsernameFromUserId = (id)->
    return sync.getUserModelFromUserId(id)?.get('username')

  async =
    getUsersData: (ids)->
      unless ids.length > 0 then return _.preq.resolve []

      app.request 'waitForData'
      .then -> app.users.data.local.get ids, 'collection'
      # make sure not to re-add users who have a different status than public
      .then filterOutAlreadyThere
      .then adders.public

    getUserModel: (id, category='public')->
      app.request('waitForData')
      .then ->
        userModel = app.request 'get:userModel:from:userId', id
        if userModel? then return userModel
        else
          app.users.data.local.get(id, 'collection')
          .then adders[category]
          .then _.property('0')
      .catch _.Error('getUserModel err')

    getGroupUserModel: (id)->
      # just adding to users.nonRelationGroupUser instead of users.public
      async.getUserModel id, 'nonRelationGroupUser'

    resolveToUserModel: (user)->
      # 'user' is either the user model or a username
      if _.isModel(user) then return _.preq.resolve(user)
      else
        username = user
        app.request('get:userModel:from:username', username)
        .then (userModel)->
          if userModel? then return userModel
          else throw new Error("user model not found: #{user}")

    getUserModelFromUsername: (username)->
      if username is app.user.get('username')
        return _.preq.resolve(app.user)

      userModel = app.users.findWhere {username: username}
      if userModel? then return _.preq.resolve userModel
      else
        app.users.data.remote.findOneByUsername username
        .then (user)->
          if user?
            userModel = app.users.public.add user
            return userModel

  filterOutAlreadyThere = (users)->
    current = app.users.list()
    return users.filter (user)-> not (user._id in current)

  adders =
    # usually users not found locally are non-friends users
    public: app.users.public.add.bind(app.users.public)
    nonRelationGroupUser: app.users.nonRelationGroupUser.add.bind(app.users.nonRelationGroupUser)

  { searchByText, searchByPosition } = require('./lib/search')(app)

  return reqresHandlers =
    'get:user:model': async.getUserModel
    'get:group:user:model': async.getGroupUserModel
    'get:users:data': async.getUsersData
    'resolve:to:userModel': async.resolveToUserModel
    'get:userModel:from:username': async.getUserModelFromUsername
    'get:userModel:from:userId': sync.getUserModelFromUserId
    'get:username:from:userId': sync.getUsernameFromUserId
    'get:userId:from:username': sync.getUserIdFromUsername
    'get:profilePic:from:userId': sync.getProfilePicFromUserId
    'get:non:friends:ids': sync.getNonFriendsIds
    'user:isMainUser': sync.isMainUser
    'user:isFriend': sync.isFriend
    'user:isPublicUser': sync.isPublicUser
    'user:itemsFetched': sync.itemsFetched
    'users:search': searchByText
    'users:search:byPosition': searchByPosition
