export default class SmoothedHorionztalControl {
  msSpeed: any
  value: number
  constructor(speed) {
    this.msSpeed = speed
    this.value = 0
  }

  moveLeft(delta, playerController) {
    if (this.value > 0) {
      this.reset()
    }
    this.value -= this.msSpeed * delta
    if (this.value < -1) {
      this.value = -1
    }
    playerController.time.rightDown += delta
  }

  moveRight(delta) {
    if (this.value < 0) {
      this.reset()
    }
    this.value += this.msSpeed * delta
    if (this.value > 1) {
      this.value = 1
    }
  }

  reset() {
    this.value = 0
  }
}
