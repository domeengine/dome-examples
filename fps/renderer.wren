import "graphics" for ImageData, Canvas, Color
import "math" for Vec, M

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
      _DIST_LOOKUP.add(_h / (2.0  * y - _h))
    }
    _dirty = true
  }

  update() {
    _camera.x = -_world.player.dir.y
    _camera.y = _world.player.dir.x
    var position = _world.player.pos
    var direction = _world.player.dir

    if (_dirty) {
      var rayPosition = position
      var castResult = [0, 0, 0]
      for (x in 0..._w) {
        var cameraX = 2 * (x / _w) - 1
        var rayDirection = direction + (_camera * cameraX)
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
    if (!_dirty) {
      return
    }
    var start
    start = System.clock
    var end
    cls()

    var ms = 0
    // Floor casting
    // rayDir for leftmost ray (x = 0) and rightmost ray (x = w)
    var localStart
    var localEnd
    var counter = 0
    // ms = ms / counter * 1000


    // Wall casting
    var rayPosition = _world.player.pos
    for (x in 0..._w) {
      counter = counter + 1
      var ray = _rayBuffer[x]
      var perpWallDistance = ray[0]
      var mapPos = ray[1]
      var side = ray[2]
      var rayDirection = ray[3]

      var color = Color.black
      var tile = _world.getTileAt(mapPos)
      var texture = _world.textures[tile - 1]

      var lineHeight = M.abs(_h / perpWallDistance)
      var drawStart = (-lineHeight / 2) + (_halfH)
      var drawEnd = (lineHeight / 2) + (_halfH)
      var alpha = 0.5
      //SET THE ZBUFFER FOR THE SPRITE CASTING

      var wallX
      if (side == 0) {
        wallX = rayPosition.y + perpWallDistance * rayDirection.y
      } else {
        wallX = rayPosition.x + perpWallDistance * rayDirection.x
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
        drawEnd = M.min(_h, drawEnd)
        var texPos = (drawStart - _halfH + lineHeight / 2) * texStep
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
          _canvas.pset(x, y, color)
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
        var floorTex = _world.floorTexture
        var ceilTex = _world.ceilTexture
        drawEnd = drawEnd.floor
        for (y in (drawEnd)..._h) {
          var currentDist = _DIST_LOOKUP[y.floor]
          var weight = currentDist / distWall
          var currentFloorX = weight * floorXWall + (1.0 - weight) * rayPosition.x
          var currentFloorY = weight * floorYWall + (1.0 - weight) * rayPosition.y
          var c
          if (DRAW_FLOORS) {
            var floorTexX = ((currentFloorX * (floorTex.width)).floor % (floorTex.width))
            var floorTexY = ((currentFloorY * (floorTex.height)).floor % (floorTex.height))
            localStart = System.clock
            c = floorTex.pget(floorTexX, floorTexY)
            localEnd = System.clock
            _canvas.pset(x.floor, y.floor, c)
            ms = ms + (localEnd - localStart)
          }
          if (DRAW_CEILING) {
            var ceilTexX = ((currentFloorX * (ceilTex.width)).floor % ceilTex.width)
            var ceilTexY = ((currentFloorY * (ceilTex.height)).floor % ceilTex.height)

            c = ceilTex.pget(ceilTexX, ceilTexY)
            _canvas.pset(x.floor, (_h - y.floor - 1), c)
          }
        }
      }
    }

    // Sort sprites in place relative to the player position

    var dir = _world.player.dir
    var cam = -_camera
    var invDet = 1.0 / (-cam.x * dir.y + dir.x * cam.y)

    for (sprite in _world.entities) {
      var uDiv = sprite.uDiv
      var vDiv = sprite.vDiv
      var vMove = sprite.vMove

      var spriteX = sprite.pos.x - rayPosition.x
      var spriteY = sprite.pos.y - rayPosition.y

      var transformX = invDet * (dir.y * spriteX - dir.x * spriteY)
      //this is actually the depth inside the screen, that what Z is in 3D
      var transformY = invDet * (cam.y * spriteX - cam.x * spriteY)

      var vMoveScreen = (vMove / transformY).floor

      var spriteScreenX = ((_halfW) * (1 + transformX / transformY)).floor
      // Prevent fisheye
      var spriteHeight = ((_h / transformY).abs / vDiv).floor
      var drawStartY = (((_h - spriteHeight) / 2) + vMoveScreen).floor
      if (drawStartY < 0) {
        drawStartY = 0
      }
      var drawEndY = (((_h + spriteHeight) / 2) + vMoveScreen).floor
      if (drawEndY >= _h) {
        drawEndY = _h
      }

      // Optimisation note: this is actually half of spriteWidth, because we typically divide it by 2
      var spriteWidth = (((_h / transformY).abs / uDiv) / 2).floor / 2
      var drawStartX = (spriteScreenX - spriteWidth).floor
      if (drawStartX < 0) {
        drawStartX = 0
      }
      var drawEndX = (spriteScreenX + spriteWidth).floor
      if (drawEndX >= _w) {
        drawEndX = _w - 1
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
        if (transformY > 0 && stripe > 0 && stripe < _w && transformY < _rayBuffer[stripe][0]) {
          for (y in drawStartY...drawEndY) {
            var texY = (((y - vMoveScreen) - (-spriteHeight / 2 + _h / 2)) * texHeight / spriteHeight).abs
            // System.print("%(texX) %(texY)")
            // var texY = ((y - drawStartY) / spriteHeight) * texHeight
            var color = texture.pget(texX, texY)
            //var color = texture[(texY * texture.width + texX)]
            // Canvas.pset(stripe, y, color)
            if (color.a != 0) {
              _canvas.pset(stripe, y.floor, color)
            }
          }
        }
      }
    }
    flip()
    Canvas.print(ms * 1000, 0, _h - 8, Color.white)

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
        for (x in 0..._w) {
          var c
          if (!DRAW_CEILING) {
            c = Color.lightgray
            _canvas.pset(x, y, c)
          }
          if (!DRAW_FLOORS) {
            c = Color.darkgray
            _canvas.pset(x, _h - y - 1, c)
          }
        }
      }
    }
  }

  flip() {
    Canvas.draw(_canvas, 0, 0)
  }

}
