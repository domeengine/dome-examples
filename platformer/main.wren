import "dome" for Process
import "graphics" for Canvas, Color
import "input" for Keyboard
import "math" for Vec, M

var TILE = 8

class Entity {
  construct new(pos, size) {
    _pos = pos
    _size = size
  }
  construct new() {
    _pos = Vec.new()
    _size = Vec.new()
  }

  pos { _pos }
  pos=(v) { _pos = v }
  size { _size }
  size=(v) { _size = v }

  update() {}
  draw(alpha) {}

  static isOverlapping(a, b) {
    return a.pos.x < b.pos.x + b.size.x &&
      a.pos.x + a.size.x > b.pos.x &&
      a.pos.y + a.size.y < b.pos.y &&
      a.pos.y + a.size.y > b.pos.y
  }
}

class Actor is Entity {
  construct new(pos, size) {
    super(pos, size)
    _vel = Vec.new()
    _acc = Vec.new()
    _rx = 0
    _ry = 0
  }

  moveX(distance) { moveX(distance, null) }
  moveY(distance) { moveY(distance, null) }
  moveX(distance, action) {
    _rx = _rx + distance
    var move = Vec.new(M.round(_rx), 0)
    if (move.manhattan != 0) {
      _rx = _rx - move.x
      var sign = Vec.new(M.sign(move.x), 0)

      while (move.manhattan != 0) {
        var testPos = sign + pos
        move = move - sign
      }
      // check collide at pos
      pos = pos + sign
      // check collide at pos
      // if not collide
      if (action != null) {
        action.call(this)
      }
    }
  }
  moveY(distance, action) {
    _ry = _ry + distance
    var move = Vec.new(0, M.round(_ry))
    if (move.manhattan != 0) {
      _ry = _ry - move.y
      var sign = Vec.new(0, M.sign(move.y))

      while (move.manhattan != 0) {
        var testPos = sign + pos
        move = move - sign
      }
      // check collide at pos
      pos = pos + sign
      // check collide at pos
      // if not collide
      if (action != null) {
        action.call(this)
      }
    }
  }
  squish() {}
}
class Solid is Entity {
  construct new(pos, size) {
    super(pos, size)
    _rx = 0
    _ry = 0
    _collidable = true
  }
  move(vec) { move(vec.x, vec.y) }
  move(x, y) {

  }
}

// -------- GAME CODE ---------

class Block is Solid {
  construct new() {
    super(
      Vec.new(10 * TILE, 4 * TILE),
      Vec.new(2 * TILE, 1 * TILE)
    )
  }
  draw(alpha) {
    Canvas.rect(pos.x, pos.y, size.x, size.y, Color.red)
  }
}

class Player is Actor {
  construct new() {
    super(Vec.new(), Vec.new(TILE, TILE))
  }
  update() {
    if (Keyboard.isKeyDown("left")) {
      moveX(-1)
    }
    if (Keyboard.isKeyDown("right")) {
      moveX(1)
    }
    if (Keyboard.isKeyDown("up")) {
      moveY(-1)
    }
    if (Keyboard.isKeyDown("down")) {
      moveY(1)
    }
  }
  draw(alpha) {
    Canvas.rectfill(pos.x, pos.y, size.x, size.y, Color.red)
  }
}


class Game {
    static init() {
      __solids = [Block.new()]
      __actors = [Player.new()]
      Canvas.resize(128, 128)
    }
    static update() {
      if (Keyboard.isKeyDown("escape")) {
        Process.exit()
      }
      __solids.each {|solid| solid.update() }
      __actors.each {|actor| actor.update() }
    }
    static draw(alpha) {
      // Draw background
      Canvas.rectfill(0, 0, 128, 120, Color.blue)
      Canvas.rectfill(0, 120, 128, 8, Color.green)

      // Draw entities
      __solids.each {|solid| solid.draw(alpha) }
      __actors.each {|actor| actor.draw(alpha) }
    }
}
