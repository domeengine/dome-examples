import "graphics" for Color, Canvas
import "dome" for Window
import "math" for Vec, M
import "input" for Keyboard
import "./keys" for Key

var MAP_WIDTH = 30
var MAP_HEIGHT = 30

var SPEED = 0.01

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
    2,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,2,
    5,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,2,
    2,0,0,0,0,0,0,0,0,0,0,3,1,1,0,1,1,3,0,0,0,0,0,0,0,0,0,0,0,2,
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
    2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
]

var PI_RAD = Num.pi / 180


class Game {
  static init() {
    Canvas.resize(320, 200)
    Window.resize(2*320, 2*200)
    __position = Vec.new(15, 15)
    __angle = 0
    __direction = Vec.new(0, -1)
    __camera = Vec.new(1, 0)
    __displayDirty = true
  }
  static update() {
    KEYS.each {|key| key.update() }
    var oldPosition = __position
    if (Keyboard.isKeyDown("a")) {
      __angle = __angle + LeftBtn.action
      __displayDirty = true
    }
    if (Keyboard.isKeyDown("d")) {
      __angle = __angle + RightBtn.action
      __displayDirty = true
    }
    if (StrafeRightBtn.firing) {
      __position = __position + __direction.perp
      __displayDirty = true
    }
    if (StrafeLeftBtn.firing) {
      __position = __position - __direction.perp
      __displayDirty = true
    }
    if (Forward.firing) {
      __position = __position + __direction
      __displayDirty = true
    }
    if (Back.firing) {
      __position = __position - __direction
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
            mapPos.x = mapPos.x + stepDirection.x
            side = 0
          } else {
            nextSideDistanceY = nextSideDistanceY + sideDistanceY
            mapPos.y = mapPos.y + stepDirection.y
            side = 1
          }


          var tile = getTileAt(mapPos)
          hit = tile > 0
        }

        var perpWallDistance
        if (side == 0) {
          perpWallDistance = M.abs((mapPos.x - __position.x + (1 - stepDirection.x) / 2) / rayDirection.x)
        } else {
          perpWallDistance = M.abs((mapPos.y - __position.y + (1 - stepDirection.y) / 2) / rayDirection.y)
        }
        var lineHeight = M.abs(Canvas.height / perpWallDistance)
        var drawStart = (-lineHeight / 2) + (Canvas.height / 2)
        var drawEnd = (lineHeight / 2) + (Canvas.height / 2)

        var color
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
        }
        if (side == 1) {
          color = Color.rgb(color.r / 2, color.g / 2, color.b / 2)
        }
        Canvas.line(x, drawStart, x, drawEnd, color)
      }

      __displayDirty = false
    }
    Canvas.print(__position, 0, 0, Color.white)
    Canvas.print(__direction, 0, 9, Color.white)
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
