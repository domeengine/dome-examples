import "graphics" for ImageData, Color
import "math" for M

class Texture {

  // Round-tripping to fetch image data is too slow, so we import the image data into
  // Wren memory for faster retrieval.
  construct new(data, width, height) {
    _data = data
    _width = width
    _height = height
    _iwidth = width - 1
    _iheight = height - 1
    var alpha = 0.5
    _darker = []
    for (color in _data) {
      var newColor = Color.rgb(color.r * alpha, color.g * alpha, color.b * alpha, color.a)
      _darker.add(newColor)
    }
  }

  [n] { _data[n] }
  width { _width }
  height { _height }

  pget(x, y) {
    x = x.round % _width
    y = y.round % _height
    // x = M.mid(0, x, _iwidth).round
    // y = M.mid(0, y, _iheight).round
    return _data[y * width + x]
  }
  pgetDark(x, y) {
    x = x.round % _width
    y = y.round % _height
    //x = M.mid(0, x, _iwidth).round
    //y = M.mid(0, y, _iheight).round
    return _darker[y * width + x]
  }

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


}
