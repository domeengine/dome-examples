import "graphics" for ImageData
class Actor {
  construct new(name, position) {
    _pos = position
    _name = name
    _image = name
  }

  name { _name }
  image { _image }
  image=(v) { _image = v}
  pos { _pos }
  pos=(p) { _pos = p }
  update() {}
  draw(alpha) {
    Fiber.new {
      var image = ImageData.loadFromFile("images/%(image).png")
      image.draw(pos.x - image.width / 2, pos.y - image.height / 2)
    }.try()
  }
}
