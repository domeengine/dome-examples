import "input" for Keyboard, Mouse

class Key {
  construct new(key) {
    init_(key, true, null)
  }
  construct new(key, repeatable) {
    init_(key, repeatable, null)
  }
  construct new(key, repeatable, action) {
    init_(key, repeatable, action)
  }

  init_(key, repeatable, action) {
    _name = key
    _repeatable = repeatable
    _counter = 0
    _wasPressed = false
    _result = action
    _firing = false
  }

  getButtonState() {
    return Keyboard.isKeyDown(name)
  }

  name { _name }
  firing { _firing }
  action { _result }

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

    _firing = fire
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
