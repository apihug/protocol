# 枚举与错误扩展使用手册

为枚举值添加业务编码、多语言文案、错误元数据。

- **扩展包**: `apihug/protobuf/extend/constant.proto`  + `apihug/protobuf/swagger/annotations.proto` (swagger annotation)
- **作用域**: EnumValue  
- **场景**: 业务枚举、错误码

---

## ⚠️ 禁止规则

**NEVER** 在 proto 文件中添加任何 file-level option 声明：

```proto
// ❌ 禁止使用以下 option（依赖默认代码生成配置）
option java_package = "...";
option java_multiple_files = true;
option go_package = "...";
```

所有代码生成配置由构建系统自动管理，**严格禁止**手动添加任何文件级 option。

---

## 一、导入与语法

### 1.1 导入

```proto
import "apihug/protobuf/extend/constant.proto";
```

### 1.2 基本语法

```proto
ENUM_NAME = 序号 [(hope.constant.field) = {
  code: 业务编码;  // int32
  message: "英文";  // string
  message2: "中文";  // string
}];
```

### 1.3 快速示例

```proto
syntax = "proto3";
package com.example.order;

import "apihug/protobuf/extend/constant.proto";

enum OrderStatusEnum {
  PLACED = 0 [(hope.constant.field) = {
    code: 1,
    message: "Placed",
    message2: "已经下单"
  }];
  
  APPROVED = 1 [(hope.constant.field) = {
    code: 2,
    message: "Approved",
    message2: "已经审批"
  }];
  
  DELIVERED = 2 [(hope.constant.field) = {
    code: 4,
    message: "Delivered",
    message2: "已经发货"
  }];
}
```

----

## 二、字段说明

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `code` | int32 | 是 | 业务编码，同一枚举内唯一 |
| `message` | string | 是 | 主语言文案（英文），默认为枚举名 |
| `message2` | string | 否 | 第二语言文案（中文） |
| `error` | Error消息 | 否 | 错误扩展信息（仅错误码使用） |

**注意**: `cn_message` (field=3) 已于 2024-05-08 废弃，请使用 `message2`

---

## 三、错误码扩展

### 3.1 Error 语法

```proto
error: {
  title: "错误标题";  // string
  tips: "处理提示";  // string
  http_status: HTTP状态码枚举;  // 枚举名（NOT_FOUND）
  phase: 层次枚举;  // CONTROLLER/SERVICE/DOMAIN
  severity: 严重度枚举;  // LOW/WARN/ERROR/FATAL
}
```

### 3.2 示例

```proto
import "apihug/protobuf/extend/constant.proto";

enum UserError {
  USER_NOT_FOUND = 1 [(hope.constant.field) = {
    code: 10001,
    message: "user_not_found",
    message2: "用户不存在"
    error: {
      title: "User Not Found",
      tips: "检查用户ID是否正确",
      http_status: NOT_FOUND,  // ❌ 不要写 404
      phase: SERVICE,
      severity: ERROR
    }
  }];
}

---

### 3.3 Error 字段

| 字段 | 类型 | 取值 | 说明 |
|---|---|---|---|
| `title` | string | - | 错误标题 |
| `tips` | string | - | 处理建议 |
| `http_status` | HttpStatus枚举 | NOT_FOUND/BAD_REQUEST/... | HTTP状态码（写枚举名） |
| `phase` | Phase枚举 | CONTROLLER/SERVICE/DOMAIN | 错误层次 |
| `severity` | Severity枚举 | LOW/WARN/ERROR/FATAL | 严重程度 |

**HttpStatus 常用值**: BAD_REQUEST(400) | UNAUTHORIZED(401) | FORBIDDEN(403) | NOT_FOUND(404) | CONFLICT(409) | INTERNAL_SERVER_ERROR(500)

**Phase**: CONTROLLER(表单层) | SERVICE(服务层) | DOMAIN(领域层)

**Severity**: LOW(无影响) | WARN(可重试) | ERROR(业务中断) | FATAL(数据损坏)

---

## 四、关键类型

| 写法 | 类型 | 错误示例 | 正确示例 |
|---|---|---|---|
| `code` | int32 | - | `code: 10001` |
| `message` | string | - | `message: "user_not_found"` |
| `http_status` | 枚举 | ❌ `http_status: 404` | ✅ `http_status: NOT_FOUND` |
| `phase` | 枚举 | ❌ `phase: "SERVICE"` | ✅ `phase: SERVICE` |
| `severity` | 枚举 | ❌ `severity: 2` | ✅ `severity: ERROR` |

---

## 五、完整示例

```proto
syntax = "proto3";
package com.example.user;

import "apihug/protobuf/extend/constant.proto";
import "apihug/protobuf/swagger/annotations.proto";

// 权限枚举
enum Authority {
  option (hope.swagger.enm) = {
    title: "Authority enum";
    description: "系统权限";
  };

  USER_CREATE = 0 [(hope.constant.field) = {
    code: 1001,
    message: "user:create",
    message2: "创建用户"
  }];
  
  USER_DELETE = 1 [(hope.constant.field) = {
    code: 1002,
    message: "user:delete",
    message2: "删除用户"
  }];
}

// 错误码枚举
enum UserError {
  USER_NOT_FOUND = 0 [(hope.constant.field) = {
    code: 10001,
    message: "user_not_found",
    message2: "用户不存在"
    error: {
      title: "User Not Found",
      tips: "检查用户ID是否正确",
      http_status: NOT_FOUND,
      phase: SERVICE,
      severity: ERROR
    }
  }];

  PASSWORD_INVALID = 1 [(hope.constant.field) = {
    code: 10002,
    message: "password_invalid",
    message2: "密码错误"
    error: {
      title: "Invalid Password",
      tips: "密码错误次数过多将锁定账户",
      http_status: UNAUTHORIZED,
      phase: CONTROLLER,
      severity: WARN
    }
  }];
}
```

---

## 六、常见错误

### 错误 1: 类型混淆

❌ **错误**:
```proto
error: {
  http_status: 404,      // 不要写数字
  phase: "SERVICE",      // 不要加引号
  severity: 2            // 不要写序号
}
```

✅ **正确**:
```proto
error: {
  http_status: NOT_FOUND,  // 枚举名
  phase: SERVICE,
  severity: ERROR
}
```

### 错误 2: code 重复

❌ **错误**:
```proto
enum UserError {
  ERROR_1 = 0 [(hope.constant.field) = {code: 10001}];
  ERROR_2 = 1 [(hope.constant.field) = {code: 10001}];  // code 重复
}
```

✅ **正确**:
```proto
enum UserError {
  ERROR_1 = 0 [(hope.constant.field) = {code: 10001}];
  ERROR_2 = 1 [(hope.constant.field) = {code: 10002}];  // code 唯一
}
```

---

## 七、快速参考

### 基本模板

```proto
syntax = "proto3";
package 你的包名;

import "apihug/protobuf/extend/constant.proto";

enum 枚举名 {
  值名 = 序号 [(hope.constant.field) = {
    code: 业务码,
    message: "英文",
    message2: "中文"
  }];
}
```

### 错误码模板

```proto
enum 错误枚举名 {
  错误名 = 序号 [(hope.constant.field) = {
    code: 错误码,
    message: "标识符",
    message2: "中文描述"
    error: {
      title: "标题",
      tips: "提示",
      http_status: HTTP状态,
      phase: 层次,
      severity: 严重度
    }
  }];
}
```
