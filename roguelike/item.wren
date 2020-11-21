import "./action" for Action

class ItemType {
  construct new(name) {
    _name = name
  }
  name { _name }
}

class Item {
  construct new(type) {
    _type = type
  }

  type { _type }
  getAction(type) { Action.none() }
}

// basic inventory with slots for every item
class Inventory {
  construct init(size) {
    _items = []
    if (size < 0) {
      Fiber.abort("Inventory size cannot be negative")
    }
    _size = size
  }
  construct init() {
    _items = []
    _size = -1
  }

  add(item) {
    if (_size == -1 || _items.count < _size) {
      _items.add(item)
    }
  }

  clear() {
    _items.clear()
  }

  swap(index1, index2) {
    var temp = _items[index1]
    _items[index1] = _items[index2]
    _items[index2] = temp
  }

  remove(item) {
    for (index in 0..._items.count) {
      if (_items[index] == item) {
        return _items.removeAt(index)
      }
    }
  }
}

class ItemLocation {
  construct new(item, pos) {
    _item = item
    _pos = pos
  }
}

