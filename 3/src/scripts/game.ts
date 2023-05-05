import 'phaser'
import MainScene from './scenes/mainScene'
import PreloadScene from './scenes/preloadScene'

const DEFAULT_WIDTH = 1280
const DEFAULT_HEIGHT = 720

const config = {
  type: Phaser.AUTO,
  backgroundColor: '#000000',
  // scale: {
  //   parent: 'phaser-game',
  //   mode: Phaser.Scale.FIT,
  //   autoCenter: Phaser.Scale.CENTER_BOTH,
  //   width: DEFAULT_WIDTH,
  //   height: DEFAULT_HEIGHT
  // },
  pixelArt: true,
  scene: [PreloadScene, MainScene],
  physics: {
    default: 'matter',
    matter: {
      gravity: { y: 1 },
      enableSleep: false,
      debug: true
    }
  }
}

window.addEventListener('load', () => {
  const game = new Phaser.Game(config)
})
