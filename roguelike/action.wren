import "./dir" for Dir
import "./events" for BoltEvent, EnergyDepletedEvent

class Action {
  type { _type }
  actor { _actor }
  game { _game }
  energy { 0 }
  alternate { null }

  construct new(type) {
    _type = type
  }

  bind(actor) {
    _game = actor.game
    _actor = actor
  }

  perform() { true }
  addEvent(event) { _game.addEventToResult(event) }
}

class DanceAction is Action {
  construct new() {
    super("dance")
  }
  perform() {
    System.print("%(actor.type) dances flagrantly!")
    return true
  }
}
class RestAction is Action {
  construct new() {
    super("rest")
  }
  perform() {
    System.print("%(actor.type) rests.")
    return true
  }
}
class TeleportAction is Action {
  construct new() {
    super("teleport")
  }
  perform() {
    System.print("You win!")
    return true
  }
}


class MoveAction is Action {
  construct new(direction) {
    super("move")
    _dir = direction
  }

  energy { _energy || 0 }
  alternate { _alternate || null }

  perform() {
    System.print("MoveAction: %(actor.type)")
    var destX = actor.x + Dir[_dir]["x"]
    var destY = actor.y + Dir[_dir]["y"]
    var validMove = false

    if (game.isTileValid(destX, destY)) {
      var tile = game.map.get(destX, destY)
      var isSolid = tile["solid"]
      var isOccupied = game.doesTileContainEntity(destX, destY)
      if (!isSolid && !isOccupied) {
        actor.x = destX
        actor.y = destY
        validMove = true
        if (tile["teleport"]) {
          _alternate = TeleportAction.new()
        }
      }
    }
    _energy = 2
    return validMove
  }
}

