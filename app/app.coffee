express = require 'express'
nodeCache = require 'node-cache'
csv = require 'fast-csv'
api = require './api'

app = express()
cache = new nodeCache({
  'stdTTL': 300,
  'checkperiod': 300
})
routesMap = []

csv.fromPath(__dirname + '/routesmap.csv', {
  ignoreEmpty: true, 
  delimiter: ';',
  trim: true
}).on('data', (data) -> routesMap.push data)

app.get '/findroute', (req, res, next) ->
  for param in ['from', 'to', 'type']  
    unless req.query.hasOwnProperty param
      return next api.error("Query parameter '#{param}' must be set", 400)

  unless req.query.type == 'fastest' || req.query.type == 'cheapest'
    return next api.error("Query parameter 'type' must be one of: 'fastest', 'cheapest'", 400)
    
  cacheKey = 'findroute' + req.query.from + req.query.to + req.query.type
  unless data = cache.get cacheKey
    adjacencyLists = {}
    for route in routesMap
      weight = if req.query.type == 'cheapest' then route[2] else route[3]
      adjacencyLists[route[0]] = {} unless adjacencyLists[route[0]]
      adjacencyLists[route[1]] = {} unless adjacencyLists[route[1]]  
      adjacencyLists[route[0]][route[1]] = weight
      adjacencyLists[route[1]][route[0]] = weight   

    data = api.dijkstra(adjacencyLists, req.query.from, req.query.to)
    cache.set(cacheKey, data)

  api.sendResponse(res, data)
  
app.use (req, res, next) ->
  next api.error('API resource not found', 404)

app.use api.errorHandler

app.listen 3000

