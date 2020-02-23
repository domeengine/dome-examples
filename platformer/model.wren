import "math" for M
import "graphics" for Color
import "io" for FileSystem

var ERROR = -1
var NONE = 0
var LAYER = 1

class Level {
  construct fromFile(filename) {
    _filename = filename
    var file = FileSystem.load(filename)
    var lines = file.split("\n")
    var mode = NONE

    _maps = []
    _spritesheets = []
    _solidIndex = 0
    _background = Color.black
    var solid = false
    var mapWidth = 0
    var mapHeight = 0

    var layerSpritesheet = null
    var layerTileMap = []

    lines.each {|line|
      var lineArray = line.trim().split(" ")
      if (mode == ERROR) {
      } else if (mode == NONE) {
        if (line.trim().count == 0) {
          return
        } else if (lineArray[0] == "BACKGROUND") {
          _backgroundColor = Color.new(lineArray[1])
        } else if (line.trim() == "LAYER") {
          mode = LAYER
          solid = false
          mapWidth = 0
          mapHeight = 0
          layerSpritesheet = null
          layerTileMap = []
        } else {
          Fiber.abort("Level file is invalid")
        }
      } else if (mode == LAYER) {
        if (line.trim() == "SOLID") {
          solid = true
        } else if (line.trim() == "LAYER END") {
          mode = NONE
          if (layerSpritesheet != null && layerTileMap.count > 0) {
            var tileMap = BasicTileMap.init(mapWidth, mapHeight)

            for (y in 0...mapHeight) {
              for (x in 0...mapWidth) {
                var pos = y * mapWidth + x
                var type = Num.fromString(layerTileMap[pos])
                if (type is Num && type < 0) {
                  type = null
                }
                tileMap.set(x, y, Tile.new(type, type != null))
              }
            }
            _maps.add(tileMap)
            if (solid) {
              _solidIndex = _maps.count - 1
            }
            _spritesheets.add(layerSpritesheet)
          } else {
            Fiber.abort("Level file is invalid")
          }
        } else {
          var row = line.trim()
          if (lineArray[0] == "SPRITESHEET") {
            layerSpritesheet = lineArray[1]
          } else if (row.count > 0) {
            // Assume it's fine
            var cols = row.split(",")
            mapWidth = M.max(mapWidth, cols.count)
            mapHeight = mapHeight + 1
            layerTileMap = layerTileMap + cols
          }
        }
      } else {
        Fiber.abort("Invalid")
      }
    }
  }

  save() { save(_filename) }
  save(filename) {
    var lines = []
    var toHex = Fn.new {|dec|
      if (dec < 10) {
        return String.fromByte(dec + 48)
      } else if (dec < 16) {
        return String.fromByte((dec - 10) + 65)
      }
    }
    var rA = toHex.call(backgroundColor.r >> 4)
    var rB = toHex.call(backgroundColor.r & 15)
    var gA = toHex.call(backgroundColor.g >> 4)
    var gB = toHex.call(backgroundColor.g & 15)
    var bA = toHex.call(backgroundColor.b >> 4)
    var bB = toHex.call(backgroundColor.b & 15)
    lines.add("BACKGROUND #%(rA)%(rB)%(gA)%(gB)%(bA)%(bB)")
    for (layer in 0...maps.count) {
      var map = maps[layer]
      var spritesheet = spritesheets[layer]
      lines.add("LAYER")
      lines.add("SPRITESHEET %(spritesheet)")
      if (solidIndex == layer) {
        lines.add("SOLID")
      }

      for (y in 0...map.height) {
        var row = []
        for (x in 0...map.width) {
          var type = map.get(x, y).type
          if (type == null) {
            type = -1
          }
          row.add(type)
        }
        lines.add(row.join(","))
      }

      lines.add("LAYER END")
    }
    var err = Fiber.new {
      FileSystem.save(filename, lines.join("\n"))
      System.print("Saved!")
    }.try()
    if (err) {
      Fiber.abort(err)
    }
  }

  backgroundColor { _backgroundColor }
  solidIndex { _solidIndex }
  maps { _maps }
  spritesheets { _spritesheets }
}

class Tile {
  construct new() {
    init_(null, false, false)
  }
  construct new(type) {
    init_(type, false, false)
  }
  construct new(type, solid) {
    init_(type, solid, false)
  }
  construct new(type, solid, oneway) {
    init_(type, solid, oneway)
  }

  init_(type, solid, oneway) {
    _type = type
    _solid = solid
    _oneway = oneway

  }

  type { _type }
  solid { _solid }
  oneway { _oneway }
}

var EMPTY_TILE = Tile.new()

class BasicTileMap {
  construct init(width, height) {
    _width = width
    _height = height
    _tiles = List.filled(_width * _height, EMPTY_TILE)
  }

  clear(vec) { clear(vec.x, vec.y) }
  clear(x, y) {
    set(x, y, EMPTY_TILE)
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

