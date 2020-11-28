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
var Interact = InputGroup.new([ Mouse["left"], Keyboard["e"], Keyboard["space"] ], SPEED)
var Forward = InputGroup.new(Keyboard["w"], SPEED)
var Back = InputGroup.new(Keyboard["s"], -SPEED)
var LeftBtn = InputGroup.new(Keyboard["a"], -SPEED)
var RightBtn = InputGroup.new(Keyboard["d"], SPEED)
var StrafeLeftBtn = InputGroup.new(Keyboard["left"], -1)
var StrafeRightBtn = InputGroup.new(Keyboard["right"], 1)

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
    Canvas.resize(320, 200)
    Window.resize(SCALE*Canvas.width, SCALE*Canvas.height)

    Mouse.relative = true
    Mouse.hidden = true

    __player = Player.new(Vec.new(7, 11), 0)
    __sprites = [
      //Pillar.new(Vec.new(8, 13)),
      Pillar.new(Vec.new(9, 15)),
      Person.new(Vec.new(8, 13))
    ]
    __doors = DOORS
    __map = TileMap.new(MAP, MAP_WIDTH, MAP_HEIGHT)
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
    if (Keyboard.isKeyDown("escape")) {
      Process.exit()
    }

    var angle = __player.angle
    angle = angle + M.mid(-2, Mouse.x / 2, 2)
    if (StrafeLeftBtn.down) {
      angle = angle + StrafeLeftBtn.action
    }
    if (StrafeRightBtn.down) {
      angle = angle + StrafeRightBtn.action
    }
    __player.angle = angle

    __camera.x = -__player.dir.y
    __camera.y = __player.dir.x

    var vel = __player.vel
    vel.x = 0
    vel.y = 0

    if (RightBtn.down) {
      vel = vel + __camera
    }
    if (LeftBtn.down) {
      vel = vel - __camera
    }
    if (Forward.down) {
      vel = vel + __player.dir
    }
    if (Back.down) {
      vel = vel - __player.dir
    }
    __player.vel = vel

    __world.update()

    var targetPos = __player.getTarget(__world)
    var dist = targetPos - __player.pos

    if (Interact.firing) {
      if (__world.getTileAt(targetPos) == 5 && dist.length < 2.75) {
        __world.getDoorAt(targetPos).open()
      }
    }


    __dirty = true
    __renderer.update()
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
}
