import "./dir" for Dir
import "./action" for MoveAction
import "./events" for BoltEvent, EnergyDepletedEvent
import "./actor" for Player

class GameResult {
  progress=(v) { _progress = v}
  progress { _progress }
  events { _events }

  construct new() {
    _progress = false
    _events = []
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

  process() {
    var actor = _entities[_turn]
    if (!actor.canTakeTurn) {
      actor.gain()
      nextTurn()
      return GameResult.new()
    }

    var action = actor.getAction()
    if (action == null) {
      return GameResult.new()
    }
    _result = GameResult.new()
    while (true) {
      action.bind(actor)
      _result.progress = action.perform()

      if (_result.progress) {
        actor.consume()
        nextTurn()
      }

      if (action.alternate == null) {
        break
      }
      action = action.alternate
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

