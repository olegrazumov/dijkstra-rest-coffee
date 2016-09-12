api = module.exports = {}

api.error = (msg, status) ->
  err = new Error msg
  err.status = status
  err 

api.errorHandler = (err, req, res, next) ->
  status = err.status || 500
  message = err.message || 'Internal server error'
  data = {
    error: {
      code: status,
      message: message
    }
  }

  res.status(status)
  api.sendResponse(res, data)
  
api.sendResponse = (res, data) ->
  res.json(data)

api.dijkstra = (adjLists, a, b) ->
  result = []
  visited = {}
  path = {}
  queue = {}
  vertexCount = Object.keys(adjLists).length

  for vertex of adjLists
    queue[vertex] = Number.POSITIVE_INFINITY
    keysSorted = Object.keys(adjLists[vertex]).sort((a,b) -> adjLists[vertex][a] - adjLists[vertex][b])
    neighborsSorted = {}
    for key in keysSorted
      neighborsSorted[key] = adjLists[vertex][key]
    adjLists[vertex] = neighborsSorted

  queue[a] = 0

  while Object.keys(visited).length < vertexCount
    minCost = Math.min.apply(Math, Object.keys(queue).map((key) -> queue[key]))
    for vertex of queue
      if queue[vertex] == minCost
        minVertex = vertex

    for neighbor of adjLists[minVertex]
      continue if visited.hasOwnProperty neighbor

      minCost = parseInt queue[minVertex]
      neighborCost = parseInt adjLists[minVertex][neighbor]
      neighborCostCurrent = queue[neighbor]

      if minCost + neighborCost < neighborCostCurrent
        queue[neighbor] = minCost + neighborCost
        path[neighbor] = minVertex

    visited[minVertex] = queue[minVertex]
    delete queue[minVertex]

  return result unless path.hasOwnProperty b

  pos = b;
  while pos != a
    result.push pos
    pos = path[pos];

  result.push a if result.length

  {
    route: result.reverse(),
    cost: visited[b]
  }   

