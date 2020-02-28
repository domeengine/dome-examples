import "input" for Keyboard, Mouse

class InputGroup {
  construct new(inputs, action) {
    _inputs = inputs
    _action = action
    _firing = false
  }
  update() {
    _inputs.each {|input| input.update() }
    _firing = _inputs.count > 0 && _inputs.any {|input| input.firing }
  }

  firing { _firing }
  action { _action }
}

class DigitalInput {
  construct new(name, action, repeatable) {
    _name = name
    _repeatable = repeatable
    _action = action
    _counter = 0
    _wasPressed = false
    _firing = false
  }

  name { _name }
  firing { _firing }
  action { _action }

  update() {
    var isPressed = getInputState()
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

  getInputState() {
    return false
  }
}

class Key is DigitalInput {
  construct new(name) {
    super(name, true, null)
  }
  construct new(name, repeatable) {
    super(name, repeatable, null)
  }
  construct new(name, repeatable, action) {
    super(name, repeatable, action)
  }

  getInputState() {
    return Keyboard.isKeyDown(name)
  }
}

class MouseButton is DigitalInput {
  construct new(key, result, repeat) {
    super(key, result, repeat)
  }
  construct new(key, result) {
    super(key, result, false)
  }

  getInputState() {
    return Mouse.isButtonPressed(name)
  }
}
