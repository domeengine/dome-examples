class Event {}

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
