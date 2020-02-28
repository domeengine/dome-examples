class Event {}

class MoveEvent is Event {
  construct new(source, direction) {
    _source = source
    _direction = direction
  }
  source { _source }
  direction { _direction }

}

class GameOverEvent is Event {
  construct new() {}
}
class EnergyDepletedEvent is Event {
  construct new() {}
}

class BoltEvent is Event {
  source { _source }
  target { _target }
  construct new(source, tx, ty) {
    _source = source
    _target = [tx, ty]
  }
}
