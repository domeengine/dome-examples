import "graphics" for Canvas, Drawable, ImageData, Color
import "dome" for Window

// Main
class Game {
  static font {__font}
  static init() {
    Display.init()
    Window.title = "Raster Font Example"
    __font = RasterFontZEROMod2.new()
  }

  static update() {}

  static draw(dt) {
    Canvas.cls(GamePalette.background)
    font.print("Hello DOME!", 40, 20)
    font.print("With Raster Fonts", 10, 40)
  }
}

class Display {
  // Use Gameboy Resolution 160x144
  static width {160}
  static height {144}
  static scale {3}
  
  static init() {
    Canvas.resize(Display.width, Display.height)
    Window.resize(Canvas.width * Display.scale, Canvas.height * Display.scale)
  }
}

// Based on https://lospec.com/palette-list/crtgb
class ColorGBCRT {

  static none { Color.none }

  // Flyweight objects
  static black {
    if (!__black) {
      __black = Color.hex("#060601")
    }
    return __black
  }

  static green {
    if (!__green) {
      __green = Color.hex("#0b3e08")
    }
    return __green
  }

  static lightgreen {
    if (!__lightgreen) {
      __lightgreen = Color.hex("#489a0d")
    }
    return __lightgreen
  }

  static yellow {
    if (!__yellow) {
      __yellow = Color.hex("#daf222")
    }
    return __yellow
  }
}

class GamePalette {
  static background  {ColorGBCRT.black}
  static background2 {ColorGBCRT.green}
  static foreground  {ColorGBCRT.lightgreen}
  static foreground2 {ColorGBCRT.yellow}
}

// Given an hex value color. Replace it with other hex value color
class ColorMap {
  map {
    if(!_map) {
      _map = {}
    }
    return _map
  }

  set(color, replacement) {
    _map[color] = replacement
  }

  construct new(map) {
    _map = map
  }
}

// Loads an image coloring its pixels with a given color map
class ImageColorizer {

  original {_original}
  colorized {_colorized}

  construct new(path, colormap) {
      _original = ImageData.loadFromFile(path)
      var image = ImageData.loadFromFile(path)
      var keys = colormap.map.keys
      var color = ""

      // traverse every pixel inside the image
      for (x in 0...image.width) {
        for (y in 0...image.height) {
          color = image.pget(x, y)
          for (key in keys) {
            // hack to compare using the color hex value
            if (color.toString == "Color (%(key))") {
              color = colormap.map[key]
              if (color is Color) {
                image.pset(x, y, color)
              }
            }
          }
        }
      }
      _colorized = image
  }
}

// Every character inside the raster font is a tile
class Tile is Drawable {
  x {_x}
  y {_y}
  width {_width}
  height {_height}
  index {_index}
  image {_image}

  construct new(x, y, w, h, index, image) {
    _x = x
    _y = y
    _width = w
    _height = h
    _index = index
    _image = image
  }

  draw(x, y) {
    this.image.drawArea(this.x, this.y, this.width, this.height, x, y)
  }

  // Create a new tile array by separating the image on same sized square blocks
  static build(sourceImage, width, height) {
    var tiles = []
    var index = 0
    for (y in 0...(sourceImage.height / height)) {
      for (x in 0...(sourceImage.width / width)) {
        var tile = Tile.new(x * width, y * height, width, height, index, sourceImage)
        tiles.add(tile)
        index = index + 1
      }
    }
    return tiles
  }
}


class RasterFont {
  name {_name}
  filepath {_filepath}
  colormap {_colormap}
  width {_width}
  height {_height}
  kerning {_kerning}

  image {_image}
  glyphs {_glyphs}

  tiles {
    if (!_tiles) {
      _tiles = {
        "original": [],
        "colorized": []
      }
    }
  }

  static print(text, x, y, kerning, glyphs, tiles) {
    var glyph = null
    var spacing = 0
    
    text.each {|char|
     glyph = glyphs[char]
     if (glyph) {
       var tile = tiles[glyph]
       tile.draw(x + spacing, y)
       spacing = spacing + kerning
     }
    }
    // The final width of the text
    return spacing
  }
}

// ZEROmod2 font from https://github.com/psgcabal/lsdfonts
class RasterFontZEROMod2 is RasterFont {
  
  construct new() {
    _width = 8
    _height = 8
    _kerning = 8
    _name = "ZEROmod2"
    _filepath = "./%(_name).png"
    _colormap = ColorMap.new({
        "#000000FF": GamePalette.foreground,
        "#808080FF": GamePalette.background2
    })

    _image = ImageColorizer.new(_filepath, _colormap)
    
    _tiles = {
      "original": Tile.build(_image.original, _width, _height),
      "colorized": Tile.build(_image.colorized, _width, _height)
    }

    // Map a glyph to a tile index
    _glyphs = {
        "♫": 0,
        ">": 1,

        " ": 2,
        "\t": 2,

        "0": 3,
        "1": 4,
        "2": 5,
        "3": 6,
        "4": 7,
        "5": 8,
        "6": 9,
        "7": 10,
        "8": 11,
        "9": 12,

        "A": 13,
        "a": 13,

        "B": 14,
        "b": 14,

        "C": 15,
        "c": 15,

        "D": 16,
        "d": 16,

        "E": 17,
        "e": 17,

        "F": 18,
        "f": 18,

        "G": 19,
        "g": 19,

        "H": 20,
        "h": 20,

        "I": 21,
        "i": 21,

        "J": 22,
        "j": 22,

        "K": 23,
        "k": 23,

        "L": 24,
        "l": 24,

        "M": 25,
        "m": 25,

        "N": 26,
        "n": 26,

        "O": 27,
        "o": 27,

        "P": 28,
        "p": 28,

        "Q": 29,
        "q": 29,

        "R": 30,
        "r": 30,

        "S": 31,
        "s": 31,

        "T": 32,
        "t": 32,

        "U": 33,
        "u": 33,

        "V": 34,
        "v": 34,

        "W": 35,
        "w": 35,

        "X": 36,
        "x": 36,

        "Y": 37,
        "y": 37,

        "Z": 38,
        "z": 38,

        "-": 39,
        "#": 40,
        "?": 41,
        "!": 42,
        "©": 43,
        "❤": 44,
        ",": 45,
        ".": 46,
        ":": 47,
        "=": 48,
        "{": 49,
        "}": 50,
        "«": 51,
        "»": 52,
        "@": 53,
        "&": 54,
        "[": 55,
        "]": 56,
        "_": 57,
        "|": 58,
        "+": 59,
        "(": 60,
        // add mising
      }
  }

  print(text, x, y, kerning, mode) {
    var tiles = _tiles["original"]
    if (mode == 1) {
      tiles = _tiles["colorized"]
    }
    return RasterFont.print(text, x, y, kerning, _glyphs, tiles)
  }

  print(text, x, y) {
    return print(text, x, y, _kerning, 0)
  }

  printc(text, x, y) {
    return print(text, x, y, _kerning, 1)
  }
}