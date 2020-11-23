import "math" for M
import "./sprite" for Entity

class Door is Entity {
  construct new(position) {
    super(position)
    _locked = false
    _state = 1
    _mode = 0
  }

  locked { _locked }
  state { _state }
  mode { _mode }

  update() {
    _state = M.mid(0, _state + _mode * 0.1, 1)
    if (_state == 0 || _state == 1) {
      _mode = 0
    }
  }

  open() {
    if (!_locked) {
      _mode = -1
    }
  }

  close() {
    if (!_locked) {
      _mode = 1
    }
  }

}
