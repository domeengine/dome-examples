import "math" for Vec, M
var VEC = Vec.new()

class TileMap {
  construct new(tiles, width, height) {
    _tiles = tiles
    _width = width
    _height = height
  }

  [n] { _tiles[n] }
  width { _width }
  height { _height }

}

class World {
  construct new() {}
  player { _player }
  player=(v) { _player = v }

  doors { _doors }
  doors=(v) { _doors = v }

  entities { _entities }
  entities=(v) { _entities = v }

  map { _map }
  map=(v) { _map = v }

  textures { _textures }
  textures=(v) { _textures = v }

  floorTexture { _floorTexture }
  floorTexture=(v) { _floorTexture = v }
  ceilTexture { _ceilTexture }
  ceilTexture=(v) { _ceilTexture = v }

  getTileAt(position) {
    VEC.x = position.x.floor
    VEC.y = position.y.floor
    var pos = VEC
    if (pos.x >= 0 && pos.x < map.width && pos.y >= 0 && pos.y < map.height) {
      return map[map.height * pos.y + pos.x]
    }
    return 1
  }

  getDoorAt(position) {
    VEC.x = position.x.floor
    VEC.y = position.y.floor
    var mapPos = VEC
    for (door in doors) {
      if (door.pos == mapPos) {
        return door
      }
    }
    return null
  }

  isTileHit(pos) {
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
}
