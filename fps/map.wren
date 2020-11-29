import "math" for Vec, M

class Elegant {
  static pair(vec) { pair(vec.x, vec.y) }
  static pair(x, y) {
    if (x >= y) {
      return x * x + x + y
    } else {
      return y * y + x
    }
  }

  static unpair(z) {
    var sqrtz = M.floor(z.sqrt)
    var sqz = sqrtz * sqrtz
    if ((z - sqz) > sqrtz) {
      return Vec.new(sqrtz, z - sqz - sqrtz)
    } else {
      return Vec.new(z- sqz, sqrtz)
    }
  }
}

class Tile {
  construct new() {
    init_(0, {})
  }
  construct new(texture) {
    init_(texture, {})
  }
  construct new(texture, data) {
    init_(texture, data)
  }

  toString { "Tile: %(texture), %(data)" }

  copy {
    var data = {}
    for (key in _data.keys) {
      data[key] = _data[key]
    }
    return Tile.new(_texture, data)
  }

  init_(texture, data) {
    _texture = texture
    _data = data
  }

  texture { _texture }

  data { _data }
  [index] { _data[index] }
  [index]=(v) { _data[index] = v }
}

var VOID_TILE = Tile.new(-1, { "solid": true })
var EMPTY_TILE = Tile.new(0)

class TileMap {
  construct new(width, height, tile) {
    _width = width
    _height = height
    _tiles = List.filled(_width * _height, tile.copy)
  }
  construct new(width, height) {
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
    x = x.floor
    y = y.floor
    if (x < 0 || x >= width || y < 0 || y >= height) {
      return VOID_TILE
    }
    return _tiles[_width * y + x]
  }

  set(vec, tile) { setTile(vec.x, vec.y, tile) }
  set(x, y, tile) {
    x = x.floor
    y = y.floor
    if (x < 0 || x >= width || y < 0 || y >= height) {
      Fiber.abort("Tile index out of bounds (%(x),%(y))")
    }
    if (!tile is Tile) {
      Fiber.abort("Only instances of Tile can be added to the tilemap")
    }
    _tiles[_width * y + x] = tile
  }

  width { _width }
  height { _height }
}

