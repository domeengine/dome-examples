import "audio" for AudioEngine
import "math" for M, Vec
import "graphics" for Canvas, Color, ImageData
import "input" for Keyboard
import "dome" for Window, Process
import "./zero" for Actor
import "random" for Random
var Generator = Random.new()

var WIDTH = 800
var HEIGHT = 480
var TITLE = "Boing!"
var HALF_W = WIDTH / 2
var HALF_H = HEIGHT / 2
var PLAYER_SPEED = 6
var MAX_AI_SPEED = 6

class Impact is Actor {
  construct new(pos) {
    super("blank", pos)
    _time = 0
  }

  time { _time }

  update() {
    image = "impact%((_time / 2).floor)"
    _time = _time + 1
  }
}

class Bat is Actor {
  construct new(game, player, isPlayer) {
    super("blank", Vec.new())
    _game = game
    if (player == 0) {
      pos.x = 40
    } else {
      pos.x = 760
    }
    pos.y = HALF_H
    _player = player
    _score = 0
    _timer = 0
    _isPlayer = isPlayer || false
  }

  draw(alpha) {
    super.draw(alpha)
    // Canvas.rectfill(pos.x - 9, pos.y - 57, 18, 114, Color.green)
    Canvas.pset(pos.x, pos.y, Color.red)
  }

  ai_move() {
    var dX = M.abs(_game.ball.pos.x - pos.x)
    var tY1 = _game.ball.pos.y + _game.ai_offset
    var tY2 = HALF_H
    var weight = M.min(1, dX / HALF_W)
    var tY = M.lerp(tY1, weight, tY2)
    return M.mid(MAX_AI_SPEED, -MAX_AI_SPEED, (tY - pos.y))
  }

  player1_move() {
    if (Keyboard.isKeyDown("up") || Keyboard.isKeyDown("a")) {
      return -PLAYER_SPEED
    }
    if (Keyboard.isKeyDown("down") || Keyboard.isKeyDown("z")) {
      return PLAYER_SPEED
    }
    return 0
  }

  player2_move() {
    if (Keyboard.isKeyDown("m")) {
      return PLAYER_SPEED
    }
    if (Keyboard.isKeyDown("k")) {
      return -PLAYER_SPEED
    }
    return 0
  }

  update() {
    _timer = _timer - 1
    var dY
    if (!_isPlayer) {
      dY = this.ai_move()
    } else {
      if (_player == 0) {
        dY = this.player1_move()
      } else {
        dY = this.player2_move()
      }
    }

    pos.y = M.mid(400, 80, pos.y + dY)
    var frame = 0
    if (_timer > 0) {
      if (_game.ball.out()) {
        frame = 2
      } else {
        frame = 1
      }
    }
    image = "bat%(_player)%(frame)"
  }

  timer=(v) { _timer = v }
  score=(v) { _score = v }
  timer { _timer }
  score { _score }
}

class Ball is Actor {
  construct new(game, direction) {
    super("ball", Vec.new(HALF_W, HALF_H))
    _speed = 5
    _vel = Vec.new(direction, 0)
    _game = game
  }

  update() {
    for (i in 0..._speed) {
      var original = pos
      pos = pos + _vel

      if (M.abs(pos.x - HALF_W) >= 344 && M.abs(original.x - HALF_W) < 344) {
        var direction = 0
        var bat
        if (pos.x < HALF_W) {
          direction = 1
          bat = _game.bats[0]
        } else {
          direction = -1
          bat = _game.bats[1]
        }

        var dY = pos.y - bat.pos.y

        if (dY > -64 && dY < 64) {
          _vel.x = -_vel.x
          _vel.y = M.mid(-1, _vel.y + dY / 128, 1)

          _vel = _vel.unit
          _game.impact(Vec.new(pos.x - direction * 10, pos.y))

          _speed = _speed + 1
          _game.ai_offset = Generator.int(-10, 11)

          bat.timer = 10

          var num = Generator.int(5)
          AudioEngine.play("hit%(num)")
          if (_speed <= 10) {
            AudioEngine.play("hit_slow")
          } else if (_speed <= 12) {
            AudioEngine.play("hit_medium")
          } else if (_speed <= 16) {
            AudioEngine.play("hit_fast")
          } else {
            AudioEngine.play("hit_veryfast")
          }
        }
      }
      if (M.abs(pos.y - HALF_H) > 220) {
        _vel.y = -_vel.y
        pos.y = pos.y + _vel.y
        _game.impact(pos)
        var num = Generator.int(5)
        AudioEngine.play("bounce%(num)")
        AudioEngine.play("bounce_synth")
      }
    }

  }

  out() {
    return pos.x < 0 || pos.x > WIDTH
  }
}

class GameState {

    construct init(playerCount) {
      _bats = [Bat.new(this, 0, playerCount >= 1), Bat.new(this, 1, playerCount >= 2)]

      _ball = Ball.new(this, -1)
      _impacts = []
      _ai_offset = 0
      Window.resize(WIDTH, HEIGHT)
      Canvas.resize(WIDTH, HEIGHT)
      Window.title = TITLE

      _table = ImageData.loadFromFile("images/table.png")

      AudioEngine.load("score_goal", "sounds/score_goal0.ogg")
      AudioEngine.load("hit_slow", "sounds/hit_slow0.ogg")
      AudioEngine.load("hit_medium", "sounds/hit_medium0.ogg")
      AudioEngine.load("hit_fast", "sounds/hit_fast0.ogg")
      AudioEngine.load("hit_veryfast", "sounds/hit_veryfast0.ogg")
      AudioEngine.load("bounce_synth", "sounds/bounce_synth0.ogg")
      for (i in 0...5) {
        AudioEngine.load("bounce%(i)", "sounds/bounce%(i).ogg")
      }
      for (i in 0...5) {
        AudioEngine.load("hit%(i)", "sounds/hit%(i).ogg")
      }
    }
    update() {
      (_bats + [_ball] + _impacts).each {|obj| obj.update() }

      _impacts = _impacts.where {|impact| impact.time <= 10 }.toList

      if (_ball.out()) {
        var scoring_player
        if (_ball.pos.x < HALF_W) {
          scoring_player = 1
        } else {
          scoring_player = 0
        }
        var losing_player = 1 - scoring_player
        if (_bats[losing_player].timer < 0) {
          _bats[scoring_player].score = _bats[scoring_player].score + 1
          AudioEngine.play("score_goal")
          _bats[losing_player].timer = 20
        } else if (_bats[losing_player].timer == 0) {
            var direction
          if (losing_player == 0) {
            direction = -1
          } else {
            direction = 1
          }
          _ball = Ball.new(this, direction)
        }

      }
    }
    draw(alpha) {
      _table.draw(0, 0)
      for (p in 0..1) {
        if (_bats[p].timer > 0 && _ball.out()) {
          Canvas.draw(ImageData.loadFromFile("images/effect%(p).png"), 0, 0)
        }
      }
      (_bats + [_ball] + _impacts).each {|obj| obj.draw(alpha) }
      for (p in 0..1) {
        var score
        if (_bats[p].score < 10) {
          score = "0%(_bats[p].score)"
        } else {
          score = "%(_bats[p].score)"
        }
        for (i in 0..1) {
          var color = "0"
          var other_p = 1 - p
          if (_bats[other_p].timer > 0 && _ball.out()) {
            if (p == 0) {
              color = "2"
            } else {
              color = "1"
            }
          }
          var image = "digit%(color)%(score[i])"
          Canvas.draw(ImageData.loadFromFile("images/%(image).png"), 255 + (160 * p + (i * 55)), 46)
        }
      }
    }
    impact(pos) {
      _impacts.add(Impact.new(pos))
    }
    ball { _ball }
    bats { _bats }
    ai_offset=(v) { _ai_offset = v }
    ai_offset { _ai_offset }
}

var MENU = 1
var PLAY = 2
var GAME_OVER = 3

class Game {
  static init() {
    __state = MENU
    AudioEngine.load("music", "music/theme.ogg")
    AudioEngine.load("down", "sounds/down.ogg")
    AudioEngine.load("up", "sounds/up.ogg")
    var music = AudioEngine.play("music")
    music.loop = true
    music.volume = 0.3
    __game = GameState.init(0)
    __playerCount = 1
    __pressed = false
  }
  static update() {
    if (Keyboard.isKeyDown("escape")) {
      Process.exit()
    }
    __game.update()
    var down = Keyboard.isKeyDown("space")
    __pressed = !__pressed && down

    if (__state == MENU) {
      if (__pressed) {
        __state = PLAY
        __game = GameState.init(__playerCount)
      } else {
        if (__playerCount == 2 && Keyboard.isKeyDown("up")) {
          AudioEngine.play("up")
          __playerCount = 1
        } else if (__playerCount == 1 && Keyboard.isKeyDown("down")) {
          AudioEngine.play("down")
          __playerCount = 2
        }
        __game.update()
      }
    } else if (__state == PLAY) {
      if (M.max(__game.bats[0].score, __game.bats[1].score) > 9) {
        __state = GAME_OVER
      } else {
        __game.update()
      }
    } else if (__state == GAME_OVER) {
      if (__pressed) {
        __pressed = false
        __state = MENU
        __playerCount = 1
        __game = GameState.init(0)
      }
    }
    __pressed = down
  }
  static draw(alpha) {
    __game.draw(alpha)
    if (__state == MENU) {
      ImageData.loadFromFile("images/menu%(__playerCount-1).png").draw(0, 0)
    } else if (__state == GAME_OVER) {
      ImageData.loadFromFile("images/over.png").draw(0, 0)
    }
  }
}
