
class Entity {
  construct new(position) {
    _pos = position
  }
  pos { _pos }

  update() {}
  draw() {}
}

class Sprite is Entity {
  construct new(pos, textures) {
    super(pos)
    if (!(textures is List)) {
      textures = [ textures ]
    }
    _textures = textures
  }

  textures { _textures }
}
