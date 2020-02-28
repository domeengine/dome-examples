import "./dir" for Dir
import "./action" for Action, MoveAction, DanceAction
import "math" for M

var SLOWEST_SPEED = 0
var SLOW_SPEED = 1
var NORMAL_SPEED = 3
var FAST_SPEED = 5

var GAINS = [
  2, // third speed
  3, // half speed
  4, // 2/3rd speed
  6, // Normal speed
  9,
  12, // double speed
]

var THRESHOLD = 12

class Actor {
  construct new(type, x, y) {
    _x = x
    _y = y
    _type = type
    _state = "ready"
    _energy = 0
    _speed = NORMAL_SPEED
    _visible = false
  }

  needsInput { false }
  // Energy Mechanics
  speed { _speed }
  speed=(v) { _speed = v }
  energy { _energy }
  gain() {
    if (type != "player") {
      System.print("%(this.type) gains %(GAINS[this.speed])")
    }
    _energy = _energy + GAINS[this.speed]
    return canTakeTurn
  }
  consume() { _energy = _energy % THRESHOLD }
  canTakeTurn { _energy >= THRESHOLD }
  // END energy mechanics

  visible { _visible }
  visible=(v) { _visible = v }

  x { _x }
  y { _y }
  x=(v) { _x = v }
  y=(v) { _y = v }
  type { _type }
  getAction() { Action.new(null) }

  state { _state }
  state=(s) { _state = s }

  bindGame(game) { _game = game }
  game { _game }
}

class Player is Actor {
  construct new(x, y) {
    super("player", x, y)
    visible = true
    _action = null
  }

  needsInput { _action == null }

  getAction() {
    var action = _action
    _action = null
    return action
  }
  action=(v) { _action = v }
}

class Blob is Actor {
  construct new(x, y) {
    super("blob", x, y)
    speed = SLOWEST_SPEED
    visible = true
  }
  getAction() {
    if (x > 0) {
      if (game.doesTileContainEntity(x - 1, y)) {
        return MoveAction.new(null)
      }
      return MoveAction.new("left")
    } else {
      return DanceAction.new()
    }
  }
}
