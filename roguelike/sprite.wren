import "graphics" for Canvas, ImageData, Color
import "./main" for BulletAnimation

class Sprite {
  construct new(imagePath, x, y) {
    _x = x
    _y = y
    _image = ImageData.loadFromFile(imagePath)
  }

  draw() {
    Canvas.draw(_image, _x*16+8, _y*16+8)
  }

  x { _x }
  y { _y }

  x=(value) { _x = value }
  y=(value) { _y = value }
}
