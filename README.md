# 서버 구조
Firebase Realtime Database를 사용하였으며 구조는 아래와 같습니다
```json
{
  "users": {
    "98ece5eb-8dba-42e1-a596-f6b10214c0c8": {
      "email": "abc@example.com",
      "filters": [
        {
          "alias": "세피아필터",
          "filterId": "026652fd-0c5a-4cbe-bfcd-da43d01f9547",
          "inputColor": "0.861173 0.774748 0.21618 1",
          "inputIntensity": 0.1,
          "inputLevels": 0.3,
          "inputRadius": 0.2,
          "systemName": "CISepiaTone"
        },
        {
          "alias": "세피아필터2",
          "filterId": "a6eee90b-5215-425b-9d6b-bd1cb78fed88",
          "inputColor": "0.861173 0.774748 0.21618 1",
          "inputIntensity": 0.1,
          "inputLevels": 0.3,
          "inputRadius": 0.2,
          "systemName": "CISepiaTone"
        }
      ]
    },
    "b8454c6f-8cd1-4b9b-aef4-1a619f73e686": {
      "email": "abc@example.com"
    }
  }
}

```
