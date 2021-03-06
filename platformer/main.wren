import "dome" for Process
import "graphics" for Canvas, Color
import "input" for Keyboard
import "math" for Vec, M
import "./keys" for Key

// Physics Constants
var JUMP = 3
var GRAVITY = 0.2
var FRICTION = 0.16

var MAX_SPEED = 1
var MOVE_FORCE = 0.08
var CHANGE_FORCE = 0.5

// World space
var TILE_SIZE = 8

class Tile {
  construct new(type, solid) {
    _type = type
    _solid = solid
    _oneway = false
  }
  construct new(type, solid, oneway) {
    _type = type
    _solid = solid
    _oneway = oneway
  }
  type { _type }
  solid { _solid }
  oneway { _oneway }
}

class BasicTilemap {
  construct init(width, height) {
    _width = width
    _height = height
    _tiles = List.filled(_width * _height, Tile.new(0, false))
  }

  get(vec) { get(vec.x, vec.y) }
  get(x, y) {
    if (x < 0 || x >= width || y < 0 || y >= height) {
      return Tile.new(null, true)
    }
    return _tiles[_height * y + x]
  }

  set(vec, tile) { setTile(vec.x, vec.y, tile) }
  set(x, y, tile) {
    if (x < 0 || x >= width || y < 0 || y >= height) {
      Fiber.abort("Tile index out of bounds (%(x),%(y))")
    }
    if (!tile is Tile) {
      Fiber.abort("Only instances of Tile can be added to the tilemap")
    }
    _tiles[_height * y + x] = tile
  }

  width { _width }
  height { _height }
}


// Actions
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

// Engine classes
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
    if (move.manhattan != 0) {
      _rx = _rx - move.x
      var sign = Vec.new(M.sign(move.x), 0)

      while (move.manhattan != 0) {
        var testActor = Actor.new(sign + pos, size)
        testActor.vel.x = sign.x
        if (!world.isColliding(this, testActor)) {
          pos = pos + sign
          move = move - sign
        } else {
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
        var testActor = Actor.new(sign + pos, size)
        if (!world.isColliding(this, testActor)) {
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
    _oneway = true
  }
  oneway { _oneway }
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
            if (!oneway && Entity.isOverlapping(this, actor)) {
              var actorLeft = actor.pos.x
              actor.moveX(right - actorLeft, ActorSquish)
            } else if (riding.contains(actor)) {
              actor.moveX(mx)
            }
          }
        } else {
          world.actors.each {|actor|
            if (!oneway && Entity.isOverlapping(this, actor)) {
              var actorRight = actor.pos.x + actor.size.x
              actor.moveX(left - actorRight, ActorSquish)
            } else if (riding.contains(actor)) {
              actor.moveX(mx)
            }
          }
        }
      }
      if (my != 0) {
        var riding = getRiding()
        _ry = _ry - my
        pos.y = pos.y + my
        var bottom = pos.y + size.y
        var top = pos.y
        if (my > 0) {
          world.actors.each {|actor|
            if (Entity.isOverlapping(this, actor)) {
              var actorTop = actor.pos.y
              actor.moveY(bottom - actorTop, ActorSquish)
            } else if (riding.contains(actor)) {
              actor.moveY(my)
            }
          }
        } else {
          world.actors.each {|actor|
            if (Entity.isOverlapping(this, actor)) {
              var actorBottom = actor.pos.y + actor.size.y
              actor.moveY(top - actorBottom, ActorSquish)
            } else if (riding.contains(actor)) {
              actor.moveY(my)
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
      Vec.new(8 * TILE_SIZE, 13 * TILE_SIZE),
      Vec.new(2 * TILE_SIZE, 1 * TILE_SIZE)
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
    if (pos.x < 8 * TILE_SIZE || pos.x >= 14 * TILE_SIZE) {
      _vel.x = -_vel.x
    }
    move(_vel)
  }
}

class Player is Actor {
  construct new() {
    super(Vec.new(), Vec.new(TILE_SIZE, TILE_SIZE))
    _jumpButton = Key.new("space", true, false)
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

    if (onGround) {
      if (_jumpButton.update()) {
        acc.y = -JUMP
      }
      var groundTiles = [
        world.getTileAt(pos.x + size.x, pos.y + size.y),
        world.getTileAt(pos.x, pos.y + size.y)
      ]
      if (Keyboard.isKeyDown("down")) {
        var groundSolids = world.solids.where {|solid| isAbove(solid) }
        var fallthrough = false
        if (groundSolids.count > 0) {
          fallthrough = groundSolids.all {|solid| solid.collidable && solid.oneway }
        } else {
          fallthrough = groundTiles.all {|tile| (tile.type == 0 || tile.oneway) }
        }
        if (fallthrough) {
          pos.y = pos.y + 1
          onGround = world.isOnGround(this)
        }
      }
    }

    if (!onGround) {
      // This must not be 0.5, for rounding purposes
      acc.y = GRAVITY
    } else {
      // If this is enabled, you can't pass through tiles
      // Because it assumes you're on the ground now so you should stop
      // vel.y = 0
    }

    acc = acc + Vec.new()
    vel = vel + acc
    vel.x = M.mid(-MAX_SPEED, vel.x, MAX_SPEED)
    super.update()
  }
  draw(alpha) {
    Canvas.rectfill(pos.x, pos.y, size.x, size.y, Color.red)
  }
}

class World {
  construct init() {
    _solids = [Block.new(Color.orange, Vec.new(-0.1, 0))]
    _actors = [Player.new()]
    (_solids + _actors).each {|entity| entity.bindWorld(this) }
    _tilemap = BasicTilemap.init(16, 16)
    for (x in 0..._tilemap.width) {
      _tilemap.set(x, _tilemap.height - 1, Tile.new(1, true))
    }
    _tilemap.set(4, 13, Tile.new(2, true, true))
  }

  update() {
    _actors.each {|actor| actor.update() }
    _solids.each {|solid| solid.update() }
  }

  draw(alpha) {
    Canvas.cls(Color.blue)
    for (y in 0..._tilemap.height) {
      for (x in 0..._tilemap.width) {
        var tile = _tilemap.get(x, y)
        if (tile.type == 2) {
          Canvas.rectfill(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE, Color.pink)
        } else if (tile.type == 1) {
          Canvas.rectfill(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE, Color.darkgreen)
        } else {
          Canvas.rectfill(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE, Color.new(0, 0, 0, 0))
        }
      }
    }

    // Draw entities
    _solids.each {|solid| solid.draw(alpha) }
    _actors.each {|actor| actor.draw(alpha) }
  }

  getTileAt(vec) { getTileAt(vec.x, vec.y) }
  getTileAt(x, y) {
    var tx = M.floor(x / 8)
    var ty = M.floor(y / 8)
    return map.get(tx, ty)
  }
  isSolidAt(x, y) {
    var tx = M.floor(x / 8)
    var ty = M.floor(y / 8)
    return map.get(tx, ty).solid
  }

  isColliding(original, actor) {
    var colliding = false
    var pos = actor.pos
    var size = actor.size - Vec.new(1, 1)

    var tiles = [
      pos,
      pos + size,
      Vec.new(pos.x, pos.y + size.y),
      Vec.new(pos.x + size.x, pos.y)
    ]

    var isSolid = false
    tiles.each { |tilePos|
      var tileTop = M.floor(tilePos.y / TILE_SIZE) * TILE_SIZE
      var tile = getTileAt(tilePos)
      if (tile.oneway && (original.pos + original.size).y > tileTop) {
        return
      }
      isSolid = isSolid || tile.solid
    }


    if (!isSolid) {
      solids.where {|solid| solid.collidable }.each {|solid|
        if (solid.oneway && (original.pos + original.size).y > solid.pos.y) {
          return
        }
        colliding = colliding || Entity.isOverlapping(actor, solid)
      }
    }

    return isSolid || colliding
  }

  isOnGround(actor) {
    var riding = false
    var pos = actor.pos
    var size = actor.size - Vec.new(1, 0)
    var tiles = [
      pos + size,
      Vec.new(pos.x, pos.y + size.y)
    ]

    var solid = false
    tiles.each { |tilePos|
      var tileTop = M.floor(tilePos.y / TILE_SIZE) * TILE_SIZE
      var tile = getTileAt(tilePos)
      if (tile.oneway && (pos + size).y > tileTop) {
        return
      }
      solid = solid || tile.solid
    }
    if (!solid) {
      solids.where {|solid| solid.collidable }.each {|solid|
        if (solid.oneway && (pos + size).y > solid.pos.y) {
          return
        }
        riding = riding || actor.isAbove(solid)
      }
    }

    return solid || riding
  }

  map { _tilemap }
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
      __world.draw(alpha)
    }
}
