import "math" for Vec, M
var VEC = Vec.new()

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
}
