# 単位表示パターン
入力フォームに単位（例：円、日、kg）を表示するための標準パターンです。

## 標準HAML構造

```haml
.form-group
  .row
    .col-12
      %label.small.dynamic-label ラベル
      .input-group.max-auto
        = number_field_tag 'input_name', nil, class: 'add-input form-control [任意の追加クラス]', min: 0
      .unit-over-input 単位
```

## 必須要素と階層

1. **`.form-group`** - フォーム項目の親要素
2. **`.row`** - Bootstrap行レイアウト（必須）
3. **`.col-12`** - 行内カラム（必須）
4. **`%label`** - 入力欄のラベル
5. **`.input-group.max-auto`** - 入力欄のグループ
6. **`input要素`** - `class: 'add-input form-control ...'`（この2クラスは必須）
7. **`.unit-over-input`** - 単位表示（inputの右側に絶対配置）

## 具体例

```haml
.form-group.mb-2
  .row
    .col-12
      %label.small.dynamic-label.next-task-days-label 作業後、5日空けてから行う
      .input-group.max-auto
        = number_field_tag 'next_task_days_template', nil, class: 'add-input form-control next-task-days-input', min: 0, data: { action: 'input->schedules--task-edit#updateDynamicLabels' }
      .unit-over-input 日
```

## 注意点

- **`.row`と`.col-12`** は単位表示の絶対配置のために必須
- **`add-input form-control`** の両方をinputに付与すること
- 単位によって横幅調整が必要な場合は、`.input-group`に適切なクラスを追加
- 単位は `.unit-over-input` 内に直接テキストで記述

この標準パターンを全画面で統一することで、UIの一貫性と保守性が向上します。