import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["startAt", "endAt"]

  connect() {
    // 初期化時に開催日時が入力されていて終了日時が空の場合にコピー
    this.syncEndAtIfEmpty()
  }

  syncEndAt() {
    // 開催日時が変更された時に終了日時が空ならコピー
    this.syncEndAtIfEmpty()
  }

  syncEndAtIfEmpty() {
    const startAtValue = this.startAtTarget.value
    const endAtValue = this.endAtTarget.value

    // 開催日時が入力されていて、終了日時が空の場合のみコピー
    if (startAtValue && !endAtValue) {
      this.endAtTarget.value = startAtValue
    }
  }
}

