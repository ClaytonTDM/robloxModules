# TextTransform

Transform text in a way that makes it easy to manipulate individual characters.

[![Get it on Roblox](assets/roblox_dev-animated.svg)](https://create.roblox.com/store/asset/95498974358575/TextTransform)

## Methods	

### `TransformText`

`TransformText(labelToTransform: TextLabel)` → `Frame`

Transforms a `TextLabel` into a `Frame` for easy manipulation of letters.
Letter index is stored in `LayoutOrder` for each `Frame`.
Stores necessary style information as attributes on the returned `Frame`.

#### Parameters

| Name             | Type        | Required |
| ---------------- | ----------- | -------- |
| labelToTransform | `TextLabel` | Yes      |

#### Returns

| Type    |
| ------- |
| `Frame` |

---

### `CreateFrameFromLabel`

`CreateFrameFromLabel(labelTemplate: TextLabel)` → `Frame`

Creates a `Frame` from a `TextLabel` for easy manipulation of letters.
Intended to be used with [`InsertLetter`](#insertletter).

#### Parameters

| Name          | Type        | Required |
| ------------- | ----------- | -------- |
| labelTemplate | `TextLabel` | Yes      |

#### Returns

| Type    |
| ------- |
| `Frame` |

---

### `InsertLetter`

`InsertLetter(frame: Frame, letter: string, index: number)` → `Frame`

Inserts a new letter (`Frame`) into the `listFrame` at the specified index.
Adjusts `LayoutOrder` of subsequent letters.
Returns the newly created letter `Frame` or `nil` if attributes are missing.

#### Parameters

| Name      | Type     | Required |
| --------- | -------- | -------- |
| listFrame | `Frame`  | Yes      |
| letter    | `string` | Yes      |
| index     | `number` | Yes      |

#### Returns

| Type     |
| -------- |
| `Frame?` |
