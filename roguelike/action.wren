import "./dir" for Dir
import "./events" for BoltEvent, EnergyDepletedEvent, MoveEvent

class Action {
  type { _type }
  actor { _actor }
  game { _game }
  energy { 0 }

  construct none() { _type = "none" }
  construct new(type) {
    _type = type
  }

  bind(actor) {
    _game = actor.game
    _actor = actor
  }

  perform(result) { true }
  addEvent(event) { _game.addEventToResult(event) }
}

class DanceAction is Action {
  construct new() {
    super("dance")
  }
  perform(result) {
    System.print("%(actor.type) dances flagrantly!")
    return true
  }
}
class RestAction is Action {
  construct new() {
    super("rest")
  }
  perform(result) {
    System.print("%(actor.type) rests.")
    return true
  }
}
class TeleportAction is Action {
  construct new() {
    super("teleport")
  }
  perform(result) {
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

  perform(result) {
    System.print("Action(%(type)): %(actor.type)")
    if (_dir == null) {
      result.alternate = Action.none()
      return true
    }

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
          result.alternate = TeleportAction.new()
        }
      }
    }
    return validMove
  }
}

class PlayerMoveAction is MoveAction {
  construct new(direction) {
    super(direction)
  }
  perform(result) {
    var validMove = super.perform(result)
    if (validMove) {
      addEvent(MoveEvent.new(actor, _dir))
    }
    return validMove
  }
}
