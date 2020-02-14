import "dome" for Process
import "graphics" for Canvas, Color
import "input" for Keyboard
import "math" for Vec, M

var JUMP = 3
var GRAVITY = 0.2
var FRICTION = 0.16

var MAX_SPEED = 2
var MOVE_FORCE = 0.08
var CHANGE_FORCE = 0.5

var TILE = 8

var ActorSquish = Fn.new {|actor|
  var world = actor.world
  for(i in 0...world.actors.count) {
    if (world.actors[i] == actor) {
      world.actors.removeAt(i)
    }
  }
}

var HaltX = Fn.new {|actor|
  actor.vel.x = 0
  actor.acc.x = 0
}
var HaltY = Fn.new {|actor|
  actor.vel.y = 0
  actor.acc.y = 0
}

class Entity {
  construct new(pos, size) {
    _pos = pos
    _size = size
    _world = null
  }

  construct new() {
    _pos = Vec.new()
    _size = Vec.new()
  }

  bindWorld(world) {
    _world = world
  }

  pos { _pos }
  pos=(v) { _pos = v }
  size { _size }
  size=(v) { _size = v }
  world { _world }

  update() {}
  draw(alpha) {}

  static isOverlapping(a, b) {
    return a.pos.x < b.pos.x + b.size.x &&
      a.pos.x + a.size.x > b.pos.x &&
      a.pos.y < b.pos.y + b.size.y &&
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
  vel { _vel }
  vel=(v) { _vel = v }
  acc { _acc }
  acc=(v) { _acc = v }

  moveX(distance) { moveX(distance, null) }
  moveY(distance) { moveY(distance, null) }
  moveX(distance, action) {
    _rx = _rx + distance
    var move = Vec.new(M.round(_rx), 0)
    if (move.x != 0) {
      _rx = _rx - move.x
      var sign = Vec.new(M.sign(move.x), 0)

      while (move.manhattan != 0) {
        var testPos = sign + pos
        if (!world.isColliding(Actor.new(testPos, size))) {
          pos = pos + sign
          move = move - sign
        } else {
          // if not collide
          if (action != null) {
            action.call(this)
          }
          break
        }
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
        if (!world.isColliding(Actor.new(testPos, size))) {
          move = move - sign
          pos = pos + sign
        } else {
          // if not collide
          if (action != null) {
            action.call(this)
          }
          break
        }
      }
    }
  }

  isAbove(solid) {
    return pos.y + size.y == solid.pos.y &&
      pos.x < solid.pos.x + solid.size.x &&
      pos.x + size.x > solid.pos.x
  }

  update() {
    moveY(vel.y, HaltY)
    moveX(vel.x, HaltX)
  }
}

class Solid is Entity {
  construct new(pos, size) {
    super(pos, size)
    _rx = 0
    _ry = 0
    _collidable = true
  }
  collidable { _collidable }
  move(vec) { move(vec.x, vec.y) }
  move(x, y) {
    _rx = _rx + x
    _ry = _ry + y
    var mx = M.round(_rx)
    var my = M.round(_ry)
    if (mx != 0 || my != 0) {
      _collidable = false

      // x-axis movement first
      if (mx != 0) {
        var riding = getRiding()
        _rx = _rx - mx
        pos.x = pos.x + mx
        var right = pos.x + size.x
        var left = pos.x
        if (mx > 0) {
          world.actors.each {|actor|
            if (Entity.isOverlapping(this, actor)) {
              var actorLeft = actor.pos.x
              actor.moveX(right - actorLeft, ActorSquish)
            } else if (riding.contains(actor)) {
              actor.moveX(mx)
            }
          }
        } else {
          world.actors.each {|actor|
            if (Entity.isOverlapping(this, actor)) {
              var actorRight = actor.pos.x + actor.size.x
              actor.moveX(left - actorRight, ActorSquish)
            } else if (riding.contains(actor)) {
              actor.moveX(mx)
            }
          }
        }
      }
    }
    _collidable = true
  }

  getRiding() {
    return world.actors.where {|actor| actor.isAbove(this) }
  }
}

// -------- GAME CODE ---------

class Block is Solid {
  construct new(color, vel) {
    super(
      Vec.new(10 * TILE, 14 * TILE),
      Vec.new(2 * TILE, 1 * TILE)
    )
    _vel = vel
    _color = color
  }

  construct new(pos, size, color, vel) {
    super(pos, size)
    _color = color
    _vel = vel
  }
  draw(alpha) {
    Canvas.rectfill(pos.x, pos.y, size.x, size.y, _color)
  }
  update() {
    move(_vel)
  }
}

class Player is Actor {
  construct new() {
    super(Vec.new(), Vec.new(TILE, TILE))
  }
  update() {
    if (Keyboard.isKeyDown("left")) {
      if (M.sign(vel.x) == 1) {
        acc.x = acc.x - CHANGE_FORCE
      } else {
        acc.x = acc.x - MOVE_FORCE
      }
    } else if (Keyboard.isKeyDown("right")) {
      if (M.sign(vel.x) == -1) {
        acc.x = acc.x + CHANGE_FORCE
      } else {
        acc.x = acc.x + MOVE_FORCE
      }
    } else {
      if (M.abs(vel.x) > MOVE_FORCE) {
        acc.x = -M.sign(vel.x) * FRICTION
      } else {
        acc.x = 0
        vel.x = 0
      }
    }

    var onGround = world.isOnGround(this)

    if (onGround && Keyboard.isKeyDown("space")) {
      acc.y = -JUMP
    }

    if (!onGround) {
      // This must not be 0.5, for rounding purposes
      acc.y = GRAVITY
    } else {
      vel.y = 0
    }

    acc = acc + Vec.new()
    vel = vel + acc
    /*
    if (M.abs(vel.y) > 0.08) {
      vel.y
    }
    */
    vel.x = M.mid(-MAX_SPEED, vel.x, MAX_SPEED)
    super.update()
  }
  draw(alpha) {
    Canvas.rectfill(pos.x, pos.y, size.x, size.y, Color.red)
  }
}

class World {
  construct init() {
    _solids = [Block.new(Color.orange, Vec.new(-0.1, 0)), Block.new(Vec.new(0, 120), Vec.new(128, 8), Color.green, Vec.new())]
    _actors = [Player.new()]
    (_solids + _actors).each {|entity| entity.bindWorld(this) }
  }

  update() {
    _solids.each {|solid| solid.update() }
    _actors.each {|actor| actor.update() }
  }

  background() {
    // Draw background
    Canvas.cls(Color.blue)
    Canvas.rectfill(0, 120, 128, 8, Color.green)
  }

  isColliding(actor) {
    var colliding = false
    var solid = false
    // TODO: Check tilemap
    if (!solid) {
      solids.where {|solid| solid.collidable }.each {|solid|
        colliding = colliding || Entity.isOverlapping(actor, solid)
      }
    }

    return solid || colliding
  }

  isOnGround(actor) {
    var riding = false
    var solid = false
    // TODO: Check tilemap
    if (!solid) {
      solids.where {|solid| solid.collidable }.each {|solid|
        riding = riding || actor.isAbove(solid)
      }
    }

    return solid || riding
  }

  actors { _actors }
  solids { _solids }
}

class Game {
    static init() {
      __world = World.init()
      Canvas.resize(128, 128)
    }
    static update() {
      if (Keyboard.isKeyDown("escape")) {
        Process.exit()
      }
      __world.update()
    }
    static draw(alpha) {
      __world.background()

      // Draw entities
      __world.solids.each {|solid| solid.draw(alpha) }
      __world.actors.each {|actor| actor.draw(alpha) }
    }
}
