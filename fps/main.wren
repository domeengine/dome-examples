import "graphics" for Color, Canvas, ImageData
import "dome" for Window, Process
import "math" for Vec, M
import "input" for Keyboard, Mouse
import "./keys" for InputGroup
import "./sprite" for Sprite, Pillar, Player, Person
import "./door" for Door
import "./context" for World, TileMap
import "./texture" for Texture
import "./renderer" for Renderer

var DRAW_FLOORS = false
var DRAW_CEILING = true
var VEC = Vec.new()

var DIST_LOOKUP = []

var SPEED = 0.001
var MOVE_SPEED = 2/ 60

var Interact = InputGroup.new([ Mouse["left"], Keyboard["e"], Keyboard["space"] ], SPEED)
var Forward = InputGroup.new(Keyboard["w"], SPEED)
var Back = InputGroup.new(Keyboard["s"], -SPEED)
var LeftBtn = InputGroup.new(Keyboard["a"], -SPEED)
var RightBtn = InputGroup.new(Keyboard["d"], SPEED)
var StrafeLeftBtn = InputGroup.new(Keyboard["left"], -1)
var StrafeRightBtn = InputGroup.new(Keyboard["right"], 1)

var CANVAS

var DOORS = [
  Door.new(Vec.new(2, 11)),
  Door.new(Vec.new(3, 13))
]

var MAP_WIDTH = 30
var MAP_HEIGHT = 30
var MAP = [
    2,2,2,2,2,2,2,2,2,2,2,4,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
    2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,0,0,0,0,0,0,0,0,0,3,1,1,1,1,1,3,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,2,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,5,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,2,0,0,0,0,0,0,0,0,3,1,1,0,1,1,3,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,2,5,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
]



class Game {
  static init() {
    var SCALE = 3
    Mouse.relative = true
    Mouse.hidden = true
    Canvas.resize(320, 200)
    Window.resize(SCALE*Canvas.width, SCALE*Canvas.height)
    CANVAS = ImageData.create("buffer", Canvas.width, Canvas.height)
    __rayBuffer = List.filled(Canvas.width, null).map { [0, 0, 0, 0] }.toList
    __player = Player.new(Vec.new(7, 11), 0)
    __sprites = [
      //Pillar.new(Vec.new(8, 13)),
      //Pillar.new(Vec.new(9, 15)),
      Person.new(Vec.new(8, 13))
    ]
    __doors = DOORS
    __map = TileMap.new(MAP, MAP_WIDTH, MAP_HEIGHT)
    __direction = __player.dir
    __camera = __player.dir.perp
    __angle = 0

    __world = World.new()
    __world.entities = __sprites
    __world.doors = __doors
    __world.player = __player
    __world.map = __map
    __textures = []
    __world.textures = __textures
    __renderer = Renderer.init(__world, 320, 200)
    // Map data
    // - Map arrangement
    // - Textures for map

    // Prepare textures
    __world.floorTexture = Texture.importImg("floor.png")
    __world.ceilTexture = Texture.importImg("ceil.png")
    for (i in 1..4) {
      __textures.add(Texture.importImg("wall%(i).png"))
    }
    __textures.add(Texture.importImg("door.png"))
  }

  static update() {
    __player.update(__world)
    if (Keyboard.isKeyDown("escape")) {
      Process.exit()
    }

    __angle = __angle + M.mid(-2, Mouse.x / 2, 2)
    if (StrafeLeftBtn.down) {
      __angle = __angle + StrafeLeftBtn.action
    }
    if (StrafeRightBtn.down) {
      __angle = __angle + StrafeRightBtn.action
    }
    __player.angle = __angle
    __angle = __player.angle
    __camera.x = -__player.dir.y
    __camera.y = __player.dir.x
    __direction = __player.dir
    // __camera = __direction.perp

    var move = Vec.new()
    if (RightBtn.down) {
      move = move + __camera * MOVE_SPEED
    }
    if (LeftBtn.down) {
      move = move - __camera * MOVE_SPEED
    }
    if (Forward.down) {
      move = move + __direction * MOVE_SPEED
    }
    if (Back.down) {
      move = move - __direction * MOVE_SPEED
    }
    // __player.pos = __player.pos + move.unit * MOVE_SPEED
    move = move.unit * MOVE_SPEED

    var solid
    var originalPosition = __player.pos * 1
    var oldPosition = VEC
    oldPosition.x = __player.pos.x
    oldPosition.y = __player.pos.y

    __player.pos.x = __player.pos.x + move.x
    solid = __world.isTileHit(__player.pos)
    if (solid) {
      __player.pos.x = oldPosition.x
      __player.pos.y = oldPosition.y
    }

    oldPosition.x = __player.pos.x
    oldPosition.y = __player.pos.y

    __player.pos.y = __player.pos.y + move.y
    solid = __world.isTileHit(__player.pos)
    if (solid) {
      __player.pos.x = oldPosition.x
      __player.pos.y = oldPosition.y
      solid = false
    }
    oldPosition.x = __player.pos.x
    oldPosition.y = __player.pos.y

    if (!solid) {
      for (entity in __sprites) {
        if ((entity.pos - __player.pos).length < 0.5) {
          solid = solid || entity.solid
        }
      }
    }

    if (solid) {
      __player.pos = originalPosition
    }

    __sprites.each {|sprite| sprite.update(__world) }
    // TODO sprite update
    sortSprites(__sprites, __player.pos)


    var castResult = [0, 0, 0, 0]
    castRay(castResult, __player.pos, __player.dir, true)
    var targetPos = castResult[0]
    var dist = targetPos - __player.pos

    if (Interact.firing) {
      if (getTileAt(targetPos) == 5 && dist.length < 2.75) {
        getDoorAt(targetPos).open()
      }
    }
    __doors.each {|door|
      if ((door.pos - __player.pos).length >= 2.75) {
        door.close()
      }
      door.update()
    }

    __dirty = true
    __renderer.update()
  }

  static castRay(result, rayPosition, rayDirection, ignoreDoors) {
    var sideDistanceX = (1.0 + rayDirection.y.pow(2) / rayDirection.x.pow(2)).sqrt
    var sideDistanceY = (1.0 + rayDirection.x.pow(2) / rayDirection.y.pow(2)).sqrt

    var nextSideDistanceX
    var nextSideDistanceY
    var mapPos = Vec.new(rayPosition.x.floor, rayPosition.y.floor)
    var stepDirection = Vec.new()
    if (rayDirection.x < 0) {
      stepDirection.x = -1
      nextSideDistanceX = (rayPosition.x - mapPos.x) * sideDistanceX
    } else {
      stepDirection.x = 1
      nextSideDistanceX = (mapPos.x + 1.0 - rayPosition.x) * sideDistanceX
    }
    if (rayDirection.y < 0) {
      stepDirection.y = -1
      nextSideDistanceY = (rayPosition.y - mapPos.y) * sideDistanceY
    } else {
      stepDirection.y = 1
      nextSideDistanceY = (mapPos.y + 1.0 - rayPosition.y) * sideDistanceY
    }

    var hit = false
    var side = 0
    while (!hit) {
      if (nextSideDistanceX < nextSideDistanceY) {
        nextSideDistanceX = nextSideDistanceX + sideDistanceX
        mapPos.x = (mapPos.x + stepDirection.x)
        side = 0
      } else {
        nextSideDistanceY = nextSideDistanceY + sideDistanceY
        mapPos.y = (mapPos.y + stepDirection.y)
        side = 1
      }

      var tile = getTileAt(mapPos)
      if (tile == 5) {
        // Figure out the door position
        var doorState = ignoreDoors ? 1 : getDoorAt(mapPos).state
        var adj
        var ray_mult
        // Adjustment
        if (side == 0) {
          adj = mapPos.x - __player.pos.x + 1
          if (__player.pos.x < mapPos.x) {
            adj = adj - 1
          }
          ray_mult = adj / rayDirection.x
        } else {
          // var halfX = mapPos.x + sideDistanceX * 0.5
          adj = mapPos.y - __player.pos.y
          if (__player.pos.y > mapPos.y) {
            adj = adj + 1
          }
          ray_mult = adj / rayDirection.y
        }

        var rye2 = rayPosition.y + rayDirection.y * ray_mult
        var rxe2 = rayPosition.x + rayDirection.x * ray_mult

        var trueDeltaX = sideDistanceX
        var trueDeltaY = sideDistanceY
        if (rayDirection.y.abs < 0.01) {
          trueDeltaY = 100
        }
        if (rayDirection.x.abs < 0.01) {
          trueDeltaX = 100
        }

        if (side == 0) {
          // var halfY = mapPos.y + sideDistanceY * 0.5
          var true_y_step = (trueDeltaX * trueDeltaX - 1).sqrt
          var half_step_in_y = rye2 + (stepDirection.y * true_y_step) * 0.5
          hit = (half_step_in_y.floor == mapPos.y) && (1 - 2*(half_step_in_y - mapPos.y)).abs > 1 - doorState
        } else {
          var true_x_step = (trueDeltaY * trueDeltaY - 1).sqrt
          var half_step_in_x = rxe2 + (stepDirection.x * true_x_step) * 0.5
          hit = (half_step_in_x.floor == mapPos.x) && (1 - 2*(half_step_in_x - mapPos.x)).abs > 1 - doorState
        }
      } else {
        hit = tile > 0
      }
    }
    result[0] = mapPos
    result[1] = side
    result[2] = stepDirection
    return result
  }

  static draw(alpha) {
    __renderer.draw()

    var centerX = Canvas.width / 2
    var centerY = Canvas.height / 2

    Canvas.line(centerX - 4, centerY, centerX + 4, centerY, Color.green, 1)
    Canvas.line(centerX, centerY - 4, centerX, centerY + 4, Color.green, 1)

    //ms = (end - start)
    //ms = ms / counter
    Canvas.print(__angle, 0, 0, Color.white)
    __dirty = false
  }

  static getTileAt(position) {
    VEC.x = position.x.floor
    VEC.y = position.y.floor
    var pos = VEC
    if (pos.x >= 0 && pos.x < MAP_WIDTH && pos.y >= 0 && pos.y < MAP_HEIGHT) {
      return __map[MAP_WIDTH * pos.y + pos.x]
    }
    return 1
  }

  static getDoorAt(position) {
    VEC.x = position.x.floor
    VEC.y = position.y.floor
    var mapPos = VEC
    for (door in __doors) {
      if (door.pos == mapPos) {
        return door
      }
    }
    return null
  }

  static sortSprites(list, position) {
    var i = 1
    while (i < list.count) {
      var x = list[i]
      var j = i - 1
      while (j >= 0 && (list[j].pos - position).length < (x.pos - position).length) {
        list[j + 1] = list[j]
        j = j - 1
      }
      list[j + 1] = x
      i = i + 1
    }
  }
  static cls() {
    if (!(DRAW_FLOORS && DRAW_CEILING)) {
      for (y in 0...Canvas.height / 2) {
        for (x in 0...Canvas.width) {
          var c
          if (!DRAW_CEILING) {
            c = Color.lightgray
            CANVAS.pset(x, y, c)
          }
          if (!DRAW_FLOORS) {
            c = Color.darkgray
            CANVAS.pset(x, Canvas.height - y - 1, c)
          }
        }
      }
    }
  }
  static flip() {
    Canvas.draw(CANVAS, 0, 0)
  }
}
