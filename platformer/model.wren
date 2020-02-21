import "math" for M
import "io" for FileSystem

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
  construct fromFile(filename) {
    var err = Fiber.new {
      var mapFile = FileSystem.load(filename)
      var rows = mapFile.split("\n")
      _height = rows.count
      _width = 0
      var map = []
      rows.each {|row|
        var cols = row.split(",")
        _width = M.max(cols.count, _width)
        map = map + cols
      }
      _tiles = List.filled(_width * _height, EMPTY_TILE)

      for (y in 0..._height) {
        for (x in 0..._width) {
          var pos = y * _width + x
          var type = Num.fromString(map[pos])
          System.write(type)
          if (type < 0) {
            type = null
          }
          System.write(",")
          this.set(x, y, Tile.new(type, type != null))
        }
        System.print()
      }
    }.try()
    System.print(err)
  }

  save(filename) {
    var map = []
    for (y in 0...this.height) {
      var row = []
      for (x in 0...this.width) {
        var type = this.get(x, y).type
        if (type == null) {
          type = -1
        }
        row.add(type)
      }
      map.add(row.join(","))
    }
    Fiber.new {
      FileSystem.save(filename, map.join("\n"))
      System.print(map.join("\n"))
      System.print("Saved!")
    }.try()
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

