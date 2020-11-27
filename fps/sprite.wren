import "./texture" for Texture
import "math" for M

var PI_RAD = Num.pi / 180

class Entity {
  construct new(position) {
    _pos = position
  }
  solid { false }
  pos { _pos }
  pos=(v) { _pos = v }

  update(context) {}
  draw() {}
}

class Player is Entity {
  construct new(position, direction) {
    super(position)
    _dir = direction
    _angle = direction.y.atan(direction.x)
  }

  angle { _angle }
  angle=(v) {
    _angle = v % 360
    if (_angle < 0) {
      _angle = _angle + 360
    }
    _dir.x = M.cos(_angle * PI_RAD)
    _dir.y = M.sin(_angle * PI_RAD)
  }

  update(context) {

  }

  dir { _dir }

}

class Sprite is Entity {
  construct new(pos, textures) {
    super(pos)
    if (!(textures is List)) {
      textures = [ textures ]
    }
    _textures = textures
    _octant = 0
  }

  textures { _textures }
  currentTex { _textures[_octant % _textures.count] }

  update(context) {
    super(context)
    var playerPos = pos - context.player.pos
    var angle = playerPos.y.atan(playerPos.x) / PI_RAD + 180
    var segmentSize = 360 / _textures.count
    _octant = (angle / segmentSize).round % _textures.count
  }

  uDiv { 1 }
  vDiv { 1 }
  vMove { 0 }
}

class Pillar is Sprite {
  construct new(pos) {
    super(pos, [Texture.importImg("./column.png"), Texture.importImg("./column2.png")])
  }
  solid { true }
  vMove { 0 }
  vDiv { 1 }
}
