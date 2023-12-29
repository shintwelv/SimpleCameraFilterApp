# Filternator

카메라 필터를 적용하여 사진을 촬영하고 촬영된 이미지에 필터를 적용하는 앱입니다

# 적용된 언어 및 라이브러리

- Swift
- AVFoundation
- CryptoKit
- MetalKit
- Swift Package Manager
- Firebase Authentication (Email, Google, Apple Login)
- RxSwift
- Alamofire

# DB

Firebase Realtime Database를 REST api로 사용합니다

## Structure

<details>
<summary>예시 json</summary>

```json
{
  "filters": {
    "026652fd-0c5a-4cbe-bfcd-da43d01f9547": {
      "owner": "98ece5eb-8dba-42e1-a596-f6b10214c0c8",
      "alias": "세피아필터",
      "inputColor": "0.861173 0.774748 0.21618 1",
      "inputIntensity": 0.1,
      "inputLevels": 0.3,
      "inputRadius": 0.2,
      "systemName": "CISepiaTone"
    },
    "a6eee90b-5215-425b-9d6b-bd1cb78fed88": {
      "owner": "98ece5eb-8dba-42e1-a596-f6b10214c0c8",
      "alias": "세피아필터2",
      "inputColor": "0.861173 0.774748 0.21618 1",
      "inputIntensity": 0.1,
      "inputLevels": 0.3,
      "inputRadius": 0.2,
      "systemName": "CISepiaTone"
    },
    "addc9967-29f5-4b3d-a1d4-d660e2708f3e": {
      "owner": "c6bdc8ec-a4cf-44ef-b10a-2ea2c2a46eb2",
      "alias": "세피아필터3",
      "inputColor": "0.861173 0.774748 0.21618 1",
      "inputIntensity": 0.1,
      "inputLevels": 0.3,
      "inputRadius": 0.2,
      "systemName": "CISepiaTone"
    },
    "09ccf54d-73b8-4495-baf9-22a77e584233": {
      "owner": "b8454c6f-8cd1-4b9b-aef4-1a619f73e686",
      "alias": "세피아필터4",
      "inputColor": "0.861173 0.774748 0.21618 1",
      "inputIntensity": 0.1,
      "inputLevels": 0.3,
      "inputRadius": 0.2,
      "systemName": "CISepiaTone"
    }
  },
  "users": {
    "98ece5eb-8dba-42e1-a596-f6b10214c0c8": {
      "email": "abc1@example.com"
    },
    "b8454c6f-8cd1-4b9b-aef4-1a619f73e686": {
      "email": "abc2@example.com"
    },
    "c6bdc8ec-a4cf-44ef-b10a-2ea2c2a46eb2": {
      "email": "abc3@example.com"
    }
  }
}
```

</details>

![SimpleCameraApp](https://github.com/shintwelv/SimpleCameraFilterApp/assets/74942977/2765322b-c1bd-42d2-8787-ef6c1ff3d7d4)
