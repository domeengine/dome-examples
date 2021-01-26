import "input" for Keyboard, Mouse

class Key {
  construct new(key, result) {
    _name = key
    _repeatable = true
    _wasPressed = false
    _result = result
    _counter = 0
  }
  construct new(key, result, repeatable) {
    _name = key
    _repeatable = repeatable
    _counter = 0
    _wasPressed = false
    _result = result
  }

  getButtonState() {
    return Keyboard.isKeyDown(name)
  }

  name { _name }
  result { _result }

  update() {
    var isPressed = getButtonState()
    var fire
    if (_repeatable) {
      fire = isPressed && (_counter == 0)
      if (!isPressed) {
        _counter = 0
      } else if (fire) {
        _counter = 8
      } else {
        _counter = _counter - 1
      }
    } else {
      fire = !_wasPressed && isPressed
      _wasPressed = isPressed
    }

    return fire
  }
}

class MouseButton is Key {
  construct new(key, result, repeat) {
    super(key, result, repeat)
  }
  construct new(key, result) {
    super(key, result, false)
  }

  getButtonState() {
    return Mouse.isButtonPressed(name)
  }
}
