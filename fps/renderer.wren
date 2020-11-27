import "graphics" for ImageData, Canvas, Color

var DRAW_FLOORS = false
var DRAW_CEILING = true
var VEC = Vec.new()

class Renderer {
  construct init(world, width, height) {
    _w = width
    _h = height
    _halfW = _w / 2
    _halfH = _h / 2
    _canvas = ImageData.create("buffer", _w, _h)
    _world = world

    _camera = Vec.new(-1, 0)
    _rayBuffer = List.filled(_w, null).map { [0, 0, 0, 0] }.toList
    _DIST_LOOKUP = []
    for (y in 0..._h) {
      DIST_LOOKUP.add(_h / (2.0  * y - _h))
    }
    __dirty = true
  }

  update() {
    _camera.x = -_world.player.dir.y
    _camera.y = _world.player.dir.x
    var position = _world.player.pos
    var direction = _world.player.dir

    if (__dirty) {
      var rayPosition = position
      var castResult = [0, 0, 0]
      for (x in 0..._w) {
        var cameraX = 2 * (x / _w) - 1
        var rayDirection = direction + (__camera * cameraX)
        castRay(castResult, rayPosition, rayDirection, false)
        var mapPos = castResult[0]
        var side = castResult[1]
        var stepDirection = castResult[2]
        var tile = _world.getTileAt(mapPos)

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
          perpWallDistance = M.abs((mapPos.x - position.x + (1 - stepDirection.x) / 2) / rayDirection.x)
        } else {
          perpWallDistance = M.abs((mapPos.y - position.y + (1 - stepDirection.y) / 2) / rayDirection.y)
        }
        //SET THE ZBUFFER FOR THE SPRITE CASTING
        var ray = _rayBuffer[x]
        ray[0] = perpWallDistance
        ray[1] = mapPos
        ray[2] = side
        ray[3] = rayDirection
      }
    }

  }


  draw() {

  }

  castRay(result, rayPosition, rayDirection, ignoreDoors) {
    var position = _world.player.pos
    var direction = _world.player.dir

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

      var tile = _world.getTileAt(mapPos)
      if (tile == 5) {
        // Figure out the door position
        var doorState = ignoreDoors ? 1 : _world.getDoorAt(mapPos).state
        var adj
        var ray_mult
        // Adjustment
        if (side == 0) {
          adj = mapPos.x - position.x + 1
          if (position.x < mapPos.x) {
            adj = adj - 1
          }
          ray_mult = adj / rayDirection.x
        } else {
          // var halfX = mapPos.x + sideDistanceX * 0.5
          adj = mapPos.y - position.y
          if (position.y > mapPos.y) {
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

  cls() {
    if (!(DRAW_FLOORS && DRAW_CEILING)) {
      for (y in 0..._halfH) {
        for (x in 0..._halfW) {
          var c
          if (!DRAW_CEILING) {
            c = Color.lightgray
            CANVAS.pset(x, y, c)
          }
          if (!DRAW_FLOORS) {
            c = Color.darkgray
            CANVAS.pset(x, - y - 1, c)
          }
        }
      }
    }
  }

  flip() {
    Canvas.draw(CANVAS, 0, 0)
  }

}
