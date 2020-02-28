import "./dir" for Dir
import "./action" for MoveAction
import "./events" for BoltEvent, EnergyDepletedEvent
import "./actor" for Player

class GameResult {
  progress=(v) { _progress = v}
  progress { _progress }
  events { _events }
  alternate { _alternate }
  alternate=(v) { _alternate = v}

  construct new() {
    _progress = false
    _events = []
    _alternate = null
  }
}


class GameModel {
  map { _map }
  player { _player }
  entities { _entities }
  energy { _entities[_turn].energy }
  turn { _turn }
  isPlayerTurn() { _entities[_turn] == _player }

  construct level(map, entities) {
    _map = map
    _entities = entities
    _entities.each{|entity| entity.bindGame(this) }
    _player = _entities.where {|entity| entity.type == "player" }.toList[0]
    _turn = 0
  }

  nextTurn() {
    _turn = (_turn + 1) % _entities.count
  }

  currentActor { _entities[_turn] }

  process() {
    var actor = currentActor
    if (actor.canTakeTurn && actor.needsInput) {
      return GameResult.new()
    }
    var action = null
    while (action == null) {
      actor = currentActor
      if (actor.canTakeTurn || actor.gain()) {
        if (actor.needsInput) {
          return GameResult.new()
        }
        action = actor.getAction()
      } else {
        nextTurn()
      }
    }
    action.bind(actor)
    _result = GameResult.new()
    _result.progress = action.perform(_result)
    while (_result.alternate != null) {
      action = _result.alternate
      _result.alternate = null
      action.bind(actor)
      _result.progress = action.perform(_result)
    }

    // Some actions should consume energy on failure
    if (_result.progress) {
      actor.consume()
      nextTurn()
    }

    return _result
  }

  isTileSolid(x, y) {
    return _map.get(x, y)["solid"]
  }

  isTileValid(x, y) {
    return (x >= 0 && x < map.width && y >= 0 && y < map.height)
  }

  doesTileContainEntity(x, y) {
    return _entities.any {|entity| entity.x == x && entity.y == y }
  }

  getEntitiesOnTile(x, y) {
    return _entities.where {|entity| entity.x == x && entity.y == y }.toList
  }

  addEventToResult(event) {
    if (_result != null) {
      _result.events.add(event)
    } else {
      Fiber.abort("Tried to add an event without a result")
    }
  }

  destroyEntity(entity) {
    _entities = _entities.where {|e| e != entity }.toList
  }
}

