import "graphics" for ImageData
import "math" for M

class Texture {

  // Round-tripping to fetch image data is too slow, so we import the image data into
  // Wren memory for faster retrieval.
  construct new(data, width, height) {
    _data = data
    _width = width
    _height = height
  }

  [n] { _data[n] }
  width { _width }
  height { _height }

  static importImg(path) {
    var texture = []
    var img = ImageData.loadFromFile(path)
    for (y in 0...img.height) {
      for (x in 0...img.width) {
        texture.add(img.pget(x,y))
      }
    }
    return Texture.new(texture, img.width, img.height)
  }


  pget(x, y) {
    x = M.mid(0, x, width - 1).round
    y = M.mid(0, y, height - 1).round
    return this[y * width + x]
  }
}
