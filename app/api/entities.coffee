module.exports =
  search: (search)->
    _.buildPath "/api/entities/public",
      action: 'search'
      search: search
      language: app.user.lang
  getImages: (entityUri, data)->
    _.buildPath "/api/entities/public",
      action: 'get-images'
      entity: entityUri
      data: data
  isbns: (isbns)->
    _.buildPath '/api/entities/public',
      action: 'get-isbn-entities'
      isbns: _.piped(isbns)
  inv:
    create: '/api/entities'
    get: (ids)->
      _.buildPath '/api/entities/public',
        action: 'get-inv-entities'
        ids: _.piped(ids)
  followed: '/api/entities/followed'