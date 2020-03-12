import "graphics" for Color, Canvas
import "dome" for Window
import "math" for Vec, M
import "input" for Keyboard
import "./keys" for Key

var MAP_WIDTH = 30
var MAP_HEIGHT = 30

var SPEED = 0.001
var MOVE_SPEED = 2/ 60

var Forward = Key.new("w", true, SPEED)
var Back = Key.new("s", true, -SPEED)
var LeftBtn = Key.new("a", true, -1)
var RightBtn = Key.new("d", true, 1)
var StrafeLeftBtn = Key.new("left", true, -SPEED)
var StrafeRightBtn = Key.new("right", true, SPEED)

var KEYS = [
  Back, Forward, LeftBtn, RightBtn, StrafeLeftBtn, StrafeRightBtn
]

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

var PI_RAD = Num.pi / 180


class Game {
  static init() {
    Canvas.resize(320, 200)
    Window.resize(2*320, 2*200)
    __position = Vec.new(7, 11)
    __angle = 180
    __direction = Vec.new(0, -1)
    __camera = Vec.new(1, 0)
    __displayDirty = true
  }
  static update() {
    KEYS.each {|key| key.update() }
    var oldPosition = __position
    if (Keyboard.isKeyDown("left")) {
      __angle = __angle + LeftBtn.action
      __displayDirty = true
    }
    if (Keyboard.isKeyDown("right")) {
      __angle = __angle + RightBtn.action
      __displayDirty = true
    }
    // if (StrafeRightBtn.firing) {
    if (Keyboard.isKeyDown("d")) {
      __position = __position + __direction.perp * MOVE_SPEED
      __displayDirty = true
    }
    if (Keyboard.isKeyDown("a")) {
    //if (StrafeLeftBtn.firing) {
      __position = __position - __direction.perp * MOVE_SPEED
      __displayDirty = true
    }
    //if (Forward.firing) {
    if (Keyboard.isKeyDown("w")) {
      __position = __position + __direction * MOVE_SPEED
      __displayDirty = true
    }
    if (Keyboard.isKeyDown("s")) {
    //if (Back.firing) {
      __position = __position - __direction * MOVE_SPEED
      __displayDirty = true
    }
    __angle = __angle % 360
    if (__angle < 0) {
      __angle = __angle + 360
    }
    if (getTileAt(__position) > 0) {
      __position = oldPosition
    }
    __direction  = Vec.new(M.cos(__angle * PI_RAD), M.sin(__angle * PI_RAD))
    __camera = __direction.perp
  }
  static draw(alpha) {
    if (__displayDirty) {
      Canvas.cls(Color.lightgray)
      Canvas.rectfill(0, Canvas.height / 2, Canvas.width, Canvas.height / 2, Color.darkgray)
      for (x in 0...Canvas.width) {
        var cameraX = 2 * (x / Canvas.width) - 1
        var rayPosition = __position
        var rayDirection = __direction + (__camera * cameraX)
        // double sideDistanceX = sqrt(1.0 + (rayDirection.GetY() * rayDirection.GetY() / (rayDirection.GetX() * rayDirection.GetX())));
        // double sideDistanceY = sqrt(1.0 + (rayDirection.GetX() * rayDirection.GetX() / (rayDirection.GetY() * rayDirection.GetY())));

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
            var doorState = 1
            if (side == 0) {
              var halfY = mapPos.y + sideDistanceY * 0.5
              var adj = mapPos.x - __position.x + 1
              if (__position.x < mapPos.x) {
                adj = adj - 1
              }
              var ray_mult = adj / rayDirection.x
              var true_y_step = (sideDistanceX * sideDistanceX - 1).sqrt
              var rye2 = rayPosition.y + rayDirection.y * ray_mult
              var half_step_in_y = rye2 + (stepDirection.y * true_y_step) * 0.5
              hit = (half_step_in_y.floor == mapPos.y) && (half_step_in_y - mapPos.y) < doorState
              if (hit) {
                // mapPos.y = mapPos.y + 0.5
              }
            } else {
              var halfX = mapPos.x + sideDistanceX * 0.5
              var adj = mapPos.y - __position.y
              if (__position.y > mapPos.y) {
                adj = adj + 1
              }
              var ray_mult = adj / rayDirection.y
              var true_x_step = (sideDistanceY * sideDistanceY - 1).sqrt
              var rxe2 = rayPosition.x + rayDirection.x * ray_mult
              var half_step_in_x = rxe2 + (stepDirection.x * true_x_step) * 0.5
              hit = (half_step_in_x.floor == mapPos.x) && (half_step_in_x - mapPos.x) < doorState
              if (hit) {
                // mapPos.x = mapPos.x +  0.5
              }
            }
          } else {
            hit = tile > 0
          }
        }


        var color = Color.black
        var tile = getTileAt(mapPos)
        if (tile == 1) {
          color = Color.red
        } else if (tile == 2) {
          color = Color.green
        } else if (tile == 3) {
          color = Color.blue
        } else if (tile == 4) {
          color = Color.white
        } else if (tile == 5) {
          color = Color.purple
          // mapPos = mapPos + stepDirection * 0.5
        }

        var perpWallDistance
        if (side == 0) {
          perpWallDistance = M.abs((mapPos.x - __position.x + (1 - stepDirection.x) / 2) / rayDirection.x)
        } else {
          perpWallDistance = M.abs((mapPos.y - __position.y + (1 - stepDirection.y) / 2) / rayDirection.y)
        }
        if (tile == 5) {
          perpWallDistance = perpWallDistance + 0.5
        }
        var lineHeight = M.abs(Canvas.height / perpWallDistance)
        var drawStart = (-lineHeight / 2) + (Canvas.height / 2)
        var drawEnd = (lineHeight / 2) + (Canvas.height / 2)

        var alpha = 0.5
        if (side == 1) {
          color = Color.rgb(color.r * alpha, color.g * alpha, color.b * alpha)
        }
        Canvas.line(x, drawStart, x, drawEnd, color)
      }

      __displayDirty = false
    }
    Canvas.print(__position, 0, 0, Color.white)
    // Canvas.print(__direction, 0, 9, Color.white)
    Canvas.print(__angle, 0, 18, Color.white)
  }

  static getTileAt(position) {
    var pos = Vec.new(position.x.floor, position.y.floor)
    if (pos.x >= 0 && pos.x < MAP_WIDTH && pos.y >= 0 && pos.y < MAP_HEIGHT) {
      return MAP[MAP_WIDTH * pos.y + pos.x]
    }
    return 0
  }


}
