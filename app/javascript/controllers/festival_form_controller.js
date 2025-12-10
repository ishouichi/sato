import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "step", "nextButton", "backButton", "submitButton",
    "stepTitle", "stepDesc", "progressBar",
    "date", "startTime", "endTime", "startAt", "endAt",
    "description", "beginner", "hanten", "party",
    "imageInput", "imagePreview", "imagePicker", "imagePlaceholder",
    "existingImageBlobId", "existingImageList", "existingImageItem"
  ]

  connect() {
    this.currentStep = 1
    this.totalSteps = 4
    this.showStep(1)

    // 初期値の同期（編集時など）
    this.updateDateTime()

    // 既存画像の初期プレビュー設定
    if (this.hasImagePreviewTarget && this.imagePreviewTarget.src && this.imagePreviewTarget.src !== window.location.href) {
      this.imagePlaceholderTarget.classList.add("hidden")
      this.imagePreviewTarget.classList.remove("hidden")
    }

    // 既存画像選択の初期ハイライト
    if (this.hasExistingImageBlobIdTarget && this.hasExistingImageItemTarget) {
      const currentId = this.existingImageBlobIdTarget.value
      if (currentId) {
        this.existingImageItemTargets.forEach((el) => {
          if (el.dataset.blobId === currentId) {
            el.classList.add("ring-2", "ring-indigo-500")
          }
        })
      }
    }
  }

  next(e) {
    e.preventDefault()
    if (this.currentStep < this.totalSteps) {
      if (this.validateStep(this.currentStep)) {
        this.showStep(this.currentStep + 1)
      }
    }
  }

  back(e) {
    e.preventDefault()
    if (this.currentStep > 1) {
      this.showStep(this.currentStep - 1)
    }
  }

  showStep(step) {
    this.currentStep = step

    // Toggle visibility
    this.stepTargets.forEach((el, index) => {
      if (index + 1 === step) {
        el.classList.remove("hidden")
        el.classList.add("animate-slide-up")
      } else {
        el.classList.add("hidden")
        el.classList.remove("animate-slide-up")
      }
    })

    // Update Header Text
    if (step === 1) {
      this.stepTitleTarget.textContent = "基本情報を教えてください"
      this.stepDescTarget.textContent = "いつ、どこで祭りを行いますか？"
      this.backButtonTarget.classList.add("opacity-0", "pointer-events-none") // レイアウト崩れ防止のため隠すだけ
    } else if (step === 2) {
      this.stepTitleTarget.textContent = "募集条件について"
      this.stepDescTarget.textContent = "どんな人に来てほしいですか？"
      this.backButtonTarget.classList.remove("opacity-0", "pointer-events-none")
    } else if (step === 3) {
      this.stepTitleTarget.textContent = "アピール・写真"
      this.stepDescTarget.textContent = "祭りの雰囲気を伝えましょう"
      this.backButtonTarget.classList.remove("opacity-0", "pointer-events-none")
    } else if (step === 4) {
      this.stepTitleTarget.textContent = "公開設定"
      this.stepDescTarget.textContent = "募集を開始しますか？それとも下書きのまま保存しますか？"
      this.backButtonTarget.classList.remove("opacity-0", "pointer-events-none")
    }

    // Update Progress Bar
    this.progressBarTarget.textContent = `募集の作成 (${step}/${this.totalSteps})`

    // Toggle Buttons
    if (step === this.totalSteps) {
      this.nextButtonTarget.classList.add("hidden")
      this.submitButtonTarget.classList.remove("hidden")
    } else {
      this.nextButtonTarget.classList.remove("hidden")
      this.submitButtonTarget.classList.add("hidden")
    }
  }

  validateStep(step) {
    // 簡易バリデーション (必要に応じて実装)
    return true
  }

  updateDateTime() {
    const date = this.dateTarget.value
    const startTime = this.startTimeTarget.value
    const endTime = this.endTimeTarget.value

    if (date && startTime) {
      // 日付と時間を結合して hidden field にセット (ISO8601形式などを考慮)
      // Railsのdatetime_fieldは "YYYY-MM-DDTHH:MM" を期待
      this.startAtTarget.value = `${date}T${startTime}`
    }

    if (date && endTime) {
      this.endAtTarget.value = `${date}T${endTime}`
    }
  }

  // 募集条件のトグル変更時にdescriptionに追記するなどのロジックを入れたいが、
  // 今回はUI再現優先で、サーバー側で保存時に処理するか、あるいは単純にチェックボックス値を送る想定にする。
  // ここでは特になにもしない。

  openImagePicker(event) {
    event.preventDefault()
    if (this.hasImageInputTarget) {
      this.imageInputTarget.click()
    }
  }

  previewAndCompressImage(event) {
    const file = event.target.files[0]
    if (!file) return

    const reader = new FileReader()
    reader.onload = (e) => {
      const img = new Image()
      img.onload = () => {
        // 最大サイズを1600pxに設定
        const maxSize = 1600
        let width = img.width
        let height = img.height

        if (width > height) {
          if (width > maxSize) {
            height = (height * maxSize) / width
            width = maxSize
          }
        } else {
          if (height > maxSize) {
            width = (width * maxSize) / height
            height = maxSize
          }
        }

        // Canvasでリサイズ・圧縮
        const canvas = document.createElement("canvas")
        canvas.width = width
        canvas.height = height
        const ctx = canvas.getContext("2d")
        ctx.drawImage(img, 0, 0, width, height)

        // JPEG形式で圧縮（quality: 0.8）
        canvas.toBlob(
          (blob) => {
            if (!blob) return

            // 圧縮済みファイルをFileオブジェクトとして作成
            const compressedFile = new File([blob], file.name, {
              type: "image/jpeg",
              lastModified: Date.now()
            })

            // DataTransferを使ってfile inputのfilesを差し替え
            const dataTransfer = new DataTransfer()
            dataTransfer.items.add(compressedFile)
            this.imageInputTarget.files = dataTransfer.files

            // 既存画像選択をリセット
            if (this.hasExistingImageBlobIdTarget) {
              this.existingImageBlobIdTarget.value = ""
            }
            if (this.hasExistingImageItemTarget) {
              this.existingImageItemTargets.forEach((el) => {
                el.classList.remove("ring-2", "ring-indigo-500")
              })
            }

            // プレビュー表示
            const previewUrl = URL.createObjectURL(compressedFile)
            this.imagePreviewTarget.src = previewUrl
            this.imagePreviewTarget.classList.remove("hidden")
            if (this.hasImagePlaceholderTarget) {
              this.imagePlaceholderTarget.classList.add("hidden")
            }
          },
          "image/jpeg",
          0.8
        )
      }
      img.src = e.target.result
    }
    reader.readAsDataURL(file)
  }

  selectExistingImage(event) {
    event.preventDefault()
    const button = event.currentTarget
    const blobId = button.dataset.blobId
    if (!blobId) return

    // hiddenに選択したblob idをセット
    if (this.hasExistingImageBlobIdTarget) {
      this.existingImageBlobIdTarget.value = blobId
    }

    // ファイル入力はリセット（既存画像を優先）
    if (this.hasImageInputTarget) {
      this.imageInputTarget.value = ""
    }

    // サムネイルのハイライト更新
    if (this.hasExistingImageItemTarget) {
      this.existingImageItemTargets.forEach((el) => {
        el.classList.remove("ring-2", "ring-indigo-500")
      })
    }
    button.classList.add("ring-2", "ring-indigo-500")

    // プレビューを既存画像に切り替え
    const img = button.querySelector("img")
    if (img && this.hasImagePreviewTarget) {
      this.imagePreviewTarget.src = img.src
      this.imagePreviewTarget.classList.remove("hidden")
    }
    if (this.hasImagePlaceholderTarget) {
      this.imagePlaceholderTarget.classList.add("hidden")
    }
  }
}
