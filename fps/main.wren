import "graphics" for Color, Canvas, ImageData
import "dome" for Window, Process
import "math" for Vec, M
import "input" for Keyboard, Mouse
import "./keys" for InputGroup
import "./sprite" for Sprite, Pillar, Player
import "./door" for Door
import "./context" for World
import "./texture" for Texture

var DRAW_FLOORS = true
var DRAW_CEILING = true
var VEC = Vec.new()

var DIST_LOOKUP = []

var PI_RAD = Num.pi / 180

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
    // CANVAS = List.filled(Canvas.width * Canvas.height, Color.none)
    CANVAS = ImageData.create("buffer", Canvas.width, Canvas.height)
    Window.resize(SCALE*Canvas.width, SCALE*Canvas.height)
    __player = Player.new(Vec.new(7, 11), Vec.new(0, -1))
    __sprites = [
      //Pillar.new(Vec.new(8, 13)),
      Pillar.new(Vec.new(9, 15))
    ]
    __doors = DOORS
    __map = MAP
    __position = __player.pos
    __direction = __player.dir
    __angle = 0

    __world = World.new()
    __world.entities = __sprites
    __world.doors = __doors
    __world.player = __player
    __world.map = __map
    // Map data
    // - Map arrangement
    // - Textures for map

    // Prepare textures
    __floorTexture = Texture.importImg("floor.png")
    __ceilTexture = Texture.importImg("ceil.png")
    __textures = []
    for (i in 1..4) {
      __textures.add(Texture.importImg("wall%(i).png"))
    }
    __textures.add(Texture.importImg("door.png"))

    __camera = Vec.new(-1, 0)
    __rayBuffer = List.filled(Canvas.width, null).map { [0, 0, 0, 0] }.toList
    for (y in 0...Canvas.height) {
      DIST_LOOKUP.add(Canvas.height / (2.0  * y - Canvas.height))
    }
    __dirty = true
  }


  static update() {
    var oldPosition = __position
    if (Keyboard.isKeyDown("escape")) {
      Process.exit()
    }

    if (Mouse.x != 0) {
      __angle = __angle + M.mid(-2, Mouse.x / 2, 2)
    }
    if (StrafeLeftBtn.down) {
      __angle = __angle + StrafeLeftBtn.action
    }
    if (StrafeRightBtn.down) {
      __angle = __angle + StrafeRightBtn.action
    }
    __player.angle = __angle
    __camera = __direction.perp

    var move = Vec.new()
    if (RightBtn.down) {
      move = move + __camera * MOVE_SPEED
      // __position = __position + __direction.perp * MOVE_SPEED
    }
    if (LeftBtn.down) {
      move = move - __camera * MOVE_SPEED
      // __position = __position - __direction.perp * MOVE_SPEED
    }
    if (Forward.down) {
      move = move + __direction * MOVE_SPEED
      // __position = __position + __direction * MOVE_SPEED
    }
    if (Back.down) {
      move = move - __direction * MOVE_SPEED
      // __position = __position - __direction * MOVE_SPEED
    }
    __player.pos = __player.pos + move.unit * MOVE_SPEED

    __position = __player.pos
    __direction = __player.dir


    var solid = isTileHit(__position)
    if (!solid) {
      for (entity in __sprites) {
        if ((entity.pos - __position).length < 0.5) {
          solid = solid || entity.solid
        }
      }
    }

    if (solid) {
      __position = oldPosition
    }

    if (__dirty || __position != oldPosition) {
      var rayPosition = __position
      var castResult = [0, 0, 0]
      for (x in 0...Canvas.width) {
        var cameraX = 2 * (x / Canvas.width) - 1
        var rayDirection = __direction + (__camera * cameraX)
        castRay(castResult, rayPosition, rayDirection, false)
        var mapPos = castResult[0]
        var side = castResult[1]
        var stepDirection = castResult[2]
        var tile = getTileAt(mapPos)

        var perpWallDistance
        if (tile == 5) {
          // If it's a door, we need to shift the map position to draw it in the correct location
          if (side == 0) {
            mapPos.x = mapPos.x + stepDirection.x / 2
          } else {
            mapPos.y = mapPos.y + stepDirection.y / 2
          }
        }
        if (side == 0) {
          perpWallDistance = M.abs((mapPos.x - __position.x + (1 - stepDirection.x) / 2) / rayDirection.x)
        } else {
          perpWallDistance = M.abs((mapPos.y - __position.y + (1 - stepDirection.y) / 2) / rayDirection.y)
        }
        //SET THE ZBUFFER FOR THE SPRITE CASTING
        var ray = __rayBuffer[x]
        ray[0] = perpWallDistance
        ray[1] = mapPos
        ray[2] = side
        ray[3] = rayDirection
      }
    }


    var castResult = [0, 0, 0, 0]
    castRay(castResult, __position, __direction, true)
    var targetPos = castResult[0]
    var dist = targetPos - __position

    if (Interact.firing) {
      if (getTileAt(targetPos) == 5 && dist.length < 2.75) {
        getDoorAt(targetPos).open()
      }
    }
    __doors.each {|door|
      if ((door.pos - __position).length >= 2.75) {
        door.close()
      }
      door.update()
    }

    __sprites.each {|sprite| sprite.update(__world) }
    // TODO sprite update
    sortSprites(__sprites, __position)
    __dirty = true
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
          adj = mapPos.x - __position.x + 1
          if (__position.x < mapPos.x) {
            adj = adj - 1
          }
          ray_mult = adj / rayDirection.x
        } else {
          // var halfX = mapPos.x + sideDistanceX * 0.5
          adj = mapPos.y - __position.y
          if (__position.y > mapPos.y) {
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

  static isTileHit(pos) {
    var mapPos = Vec.new(pos.x.floor, pos.y.floor)
    var tile = getTileAt(mapPos)
    var hit = false
    if (tile == 5) {
      hit = getDoorAt(mapPos).state > 0.5
    } else {
      hit = tile > 0
    }
    return hit
  }

  static draw(alpha) {
    var h = Canvas.height
    var w = Canvas.width
    var centerX = w / 2
    var centerY = h / 2

    var start
    var end
    if (!__dirty) {
      return
    }
    cls()

    var ms = 0
    // Floor casting
    // rayDir for leftmost ray (x = 0) and rightmost ray (x = w)
    var localStart
    var localEnd
    var counter = 0
    // ms = ms / counter * 1000


    // Wall casting
    start = System.clock
    var rayPosition = __position
    for (x in 0...Canvas.width) {
      counter = counter + 1
      var ray = __rayBuffer[x]
      var perpWallDistance = ray[0]
      var mapPos = ray[1]
      var side = ray[2]
      var rayDirection = ray[3]

      var color = Color.black
      var tile = getTileAt(mapPos)
      var texture = __textures[tile - 1]

      var lineHeight = M.abs(Canvas.height / perpWallDistance)
      var drawStart = (-lineHeight / 2) + (centerY)
      var drawEnd = (lineHeight / 2) + (centerY)
      var alpha = 0.5
      //SET THE ZBUFFER FOR THE SPRITE CASTING

      var wallX
      if (side == 0) {
        wallX = __position.y + perpWallDistance * rayDirection.y
      } else {
        wallX = __position.x + perpWallDistance * rayDirection.x
      }
      wallX = wallX - wallX.floor

      /*
      UNTEXTURED COLOR CHOOSER
      */
      if (texture == null) {
        // WORST CASE
        color = Color.pink
        if (side == 1) {
          color = Color.rgb(color.r * alpha, color.g * alpha, color.b * alpha)
        }
        Canvas.line(x, drawStart, x, drawEnd, color)
      } else {
        var texWidth = texture.width
        var texX = wallX * texWidth
        if (side == 0 && rayDirection.x <= 0) {
          texX = texWidth - texX
        }
        if (side == 1 && rayDirection.y > 0) {
          texX = texWidth - texX
        }
        texX = texX.floor
        var texStep = 1.0 * texture.height / lineHeight
        // If we are too close to a block, the lineHeight is gigantic, resulting in slowness
        // So we clip the drawStart-End and _then_ calculate the texture position.
        drawStart = M.max(0, drawStart)
        drawEnd = M.min(Canvas.height, drawEnd)
        var texPos = (drawStart - centerY + lineHeight / 2) * texStep
        for (y in drawStart...drawEnd) {
          var texY = (texPos).floor
          // color = texture[(texY * texWidth + texX)]
          if (side == 1) {
            color = texture.pgetDark(texX, texY)
            //color = Color.rgb(color.r * alpha, color.g * alpha, color.b * alpha)
          } else {
            color = texture.pget(texX, texY)
          }
          // Canvas.pset(x, y, color)
          CANVAS.pset(x, y, color)
          texPos = texPos + texStep
        }
      }
      if (DRAW_FLOORS || DRAW_CEILING) {
        var floorXWall
        var floorYWall
        if (side == 0 && rayDirection.x > 0) {
          floorXWall = mapPos.x
          floorYWall = mapPos.y + wallX
        } else if (side == 0 && rayDirection.x < 0) {
          floorXWall = mapPos.x + 1.0
          floorYWall = mapPos.y + wallX
        } else if (side == 1 && rayDirection.y > 0) {
          floorXWall = mapPos.x + wallX
          floorYWall = mapPos.y
        } else {
          floorXWall = mapPos.x + wallX
          floorYWall = mapPos.y + 1.0
        }
        var distWall = perpWallDistance
        var floorTex = __floorTexture
        var ceilTex = __ceilTexture
        drawEnd = drawEnd.floor
        for (y in (drawEnd)...h) {
          var currentDist = DIST_LOOKUP[y.floor]
          var weight = currentDist / distWall
          var currentFloorX = weight * floorXWall + (1.0 - weight) * __position.x
          var currentFloorY = weight * floorYWall + (1.0 - weight) * __position.y
          var c
          if (DRAW_FLOORS) {
            var floorTexX = ((currentFloorX * (floorTex.width)).floor % (floorTex.width))
            var floorTexY = ((currentFloorY * (floorTex.height)).floor % (floorTex.height))
            localStart = System.clock
            c = floorTex.pget(floorTexX, floorTexY)
            localEnd = System.clock
            CANVAS.pset(x.floor, y.floor, c)
            ms = ms + (localEnd - localStart)
          }
          if (DRAW_CEILING) {
            var ceilTexX = ((currentFloorX * (ceilTex.width)).floor % ceilTex.width)
            var ceilTexY = ((currentFloorY * (ceilTex.height)).floor % ceilTex.height)

            c = ceilTex.pget(ceilTexX, ceilTexY)
            CANVAS.pset(x.floor, (h - y.floor - 1), c)
          }
        }
      }
    }

    // Sort sprites in place relative to the player position

    var dir = __direction
    var cam = -__camera
    var invDet = 1.0 / (-cam.x * dir.y + dir.x * cam.y)

    for (sprite in __sprites) {
      var uDiv = sprite.uDiv
      var vDiv = sprite.vDiv
      var vMove = sprite.vMove

      var spriteX = sprite.pos.x - __position.x
      var spriteY = sprite.pos.y - __position.y

      var transformX = invDet * (dir.y * spriteX - dir.x * spriteY)
      //this is actually the depth inside the screen, that what Z is in 3D
      var transformY = invDet * (cam.y * spriteX - cam.x * spriteY)

      var vMoveScreen = (vMove / transformY).floor

      var spriteScreenX = ((centerX) * (1 + transformX / transformY)).floor
      // Prevent fisheye
      var spriteHeight = ((h / transformY).abs / vDiv).floor
      var drawStartY = (((h - spriteHeight) / 2) + vMoveScreen).floor
      if (drawStartY < 0) {
        drawStartY = 0
      }
      var drawEndY = (((h + spriteHeight) / 2) + vMoveScreen).floor
      if (drawEndY >= h) {
        drawEndY = h
      }

      // Optimisation note: this is actually half of spriteWidth, because we typically divide it by 2
      var spriteWidth = (((h / transformY).abs / uDiv) / 2).floor / 2
      var drawStartX = (spriteScreenX - spriteWidth).floor
      if (drawStartX < 0) {
        drawStartX = 0
      }
      var drawEndX = (spriteScreenX + spriteWidth).floor
      if (drawEndX >= w) {
        drawEndX = w - 1
      }

      var texture = sprite.currentTex
      var texWidth = texture.width - 1
      var texHeight = texture.height - 1
      for (stripe in drawStartX...drawEndX) {
        //  int texX = int(256 * (stripe - (-spriteWidth / 2 + spriteScreenX)) * texWidth / spriteWidth) / 256;
        var texX = ((stripe - (-spriteWidth + spriteScreenX)) * texWidth / (spriteWidth * 2)).abs

        // Conditions for this if:
        //1) it's in front of camera plane so you don't see things behind you
        //2) it's on the screen (left)
        //3) it's on the screen (right)
        //4) ZBuffer, with perpendicular distance
        // TODO: stripe SHOULD be allowed to be 0
        if (transformY > 0 && stripe > 0 && stripe < w && transformY < __rayBuffer[stripe][0]) {
          for (y in drawStartY...drawEndY) {
            var texY = (((y - vMoveScreen) - (-spriteHeight / 2 + h / 2)) * texHeight / spriteHeight).abs
            // System.print("%(texX) %(texY)")
            // var texY = ((y - drawStartY) / spriteHeight) * texHeight
            var color = texture.pget(texX, texY)
            //var color = texture[(texY * texture.width + texX)]
            // Canvas.pset(stripe, y, color)
            if (color.a != 0) {
              CANVAS.pset(stripe, y.floor, color)
            }
          }
        }
      }
    }
    flip()


    Canvas.line(centerX - 4, centerY, centerX + 4, centerY, Color.green, 1)
    Canvas.line(centerX, centerY - 4, centerX, centerY + 4, Color.green, 1)

    //ms = (end - start)
    //ms = ms / counter
    Canvas.print(__angle, 0, 0, Color.white)
    Canvas.print(ms * 1000, 0, Canvas.height - 8, Color.white)
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
