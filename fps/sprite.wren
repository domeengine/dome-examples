import "./texture" for Texture

class Entity {
  construct new(position) {
    _pos = position
  }
  solid { false }
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

  uDiv { 1 }
  vDiv { 1 }
  vMove { 0 }
}

class Pillar is Sprite {
  construct new(pos) {
    super(pos, Texture.importImg("./column.png"))
  }
  solid { true }
  vMove { 0 }
  vDiv { 1 }
}
