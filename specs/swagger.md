# API 接口扩展使用手册

将 protobuf service rpc 映射为 HTTP RESTful API，生成 OpenAPI/Swagger 文档。

- **扩展包**: `apihug/protobuf/swagger/swagger.proto` + `annotations.proto`  
- **作用域**: Service/Method(rpc)/Message/Field  
- **场景**: HTTP API、OpenAPI文档、前后端联调

---

## ⚠️ 禁止规则

### 1. 禁止 file-level option

**NEVER** 在 proto 文件中添加任何 file-level option 声明：

```proto
// ❌ 禁止使用以下 option（依赖默认代码生成配置）
option java_package = "...";
option java_multiple_files = true;
option go_package = "...";
```

所有代码生成配置由构建系统自动管理，**严格禁止**手动添加任何文件级 option。

### 2. 禁止跨层引用 🚫

**API 层（api/）不得引用 Domain 实体**：

```proto
// ❌ 禁止引用 domain 层实体
import "com/example/domain/entities/user.proto";  // 错误！
import "com/example/domain/entities/order.proto";  // 错误！

message CreateUserRequest {
  // ❌ 禁止使用 Domain Entity 类型
  UserEntity user = 1;  // 错误！
  repeated OrderEntity orders = 2;  // 错误！
}
```

**✅ 正确做法**：
```proto
// ✅ 允许引用常量层（infra/）
import "com/example/infra/settings/user_constant.proto";

// ✅ 允许引用其他 API 消息
import "com/example/api/common/response.proto";

message CreateUserRequest {
  string user_name = 1;  // ✅ 使用基础类型
  UserStatusEnum status = 2;  // ✅ 枚举可共享
  CommonResponse response = 3;  // ✅ API 内部引用
}
```

**架构原则**：API 层负责接口契约，Domain 层负责数据持久化，两者通过 Service 层转换，**严禁直接依赖**。

---

## 一、导入与语法

### 1.1 导入

```proto
import "apihug/protobuf/swagger/annotations.proto";
```

**可选引入**（仅需 Mock 数据时）:
```proto
import "apihug/protobuf/mock/mock.proto";
```

### 1.2 四层扩展点

| 级别 | proto 元素 | 扩展点 | 作用 |
|---|---|---|---|
| 服务 | `service` | `(hope.swagger.svc)` | 定义服务基础路径、描述 |
| 方法 | `rpc` | `(hope.swagger.operation)` | 定义 HTTP 方法、路径、权限等 |
| 消息 | `message` | `(hope.swagger.schema)` | 定义请求/响应对象描述 |
| 字段 | `field` | `(hope.swagger.field)` | 定义字段约束、示例、验证规则 |

---

## 二、Service 级扩展

### 2.1 ServiceSchema 语法

```proto
service 服务名 {
  option (hope.swagger.svc) = {
    path: "/基础路径";
    description: "服务说明";
  };
  
  // rpc 方法...
}
```

### 2.2 真实案例

```proto
syntax = "proto3";
package com.example.pet.service;

import "apihug/protobuf/swagger/annotations.proto";

service PetService {
  option (hope.swagger.svc) = {
    path: "/pet";
    description: "Pet Manager service";
  };

  rpc GetPet (...) returns (...) {
    // 方法定义...
  }
}
```

### 2.3 字段说明

#### `path` (string)

- **作用**: 服务的基础路径前缀
- **建议**: 使用资源名（`/user`, `/order`, `/pet`）
- **示例**: `path: "/pet"`

#### `description` (string)

- **作用**: 服务的业务说明
- **建议**: 使用自然语言描述服务职责
- **示例**: `description: "宠物管理服务"`

---

## 三、Operation 级扩展（核心）

### 3.1 HTTP 方法与路径

#### 语法格式

```proto
rpc 方法名 (请求类型) returns (响应类型) {
  option (hope.swagger.operation) = {
    post: "/路径";  // 或 get/put/patch/delete
    description: "方法说明";
    // 其他配置...
  };
}
```

#### HTTP 方法选择

| 方法 | 使用场景 | 示例路径 |
|---|---|---|
| `get` | 查询资源 | `get: "/users"` |
| `post` | 创建资源、复杂查询 | `post: "/users"` |
| `put` | 全量更新资源 | `put: "/users/{id}"` |
| `patch` | 部分更新资源 | `patch: "/users/{id}"` |
| `delete` | 删除资源 | `delete: "/users/{id}"` |

#### 路径变量

使用 `{变量名}` 定义路径参数：

```proto
option (hope.swagger.operation) = {
  get: "/pet/{id}";
  // ...
};
```

### 3.2 真实案例集合

#### 案例 1：文件上传（multipart/form-data）

```proto
rpc UploadMeta (OpenApiMetaUploadRequest) returns (google.protobuf.Empty) {
  option (hope.swagger.operation) = {
    post: "/upload-meta";
    description: "开放平台上传API元数据";
    tags: "open";
    group: TENANT;
    authorization: {
      low_limit_risky_mode: ANONYMOUS
    };
    priority: HIGH;
    consumes: "multipart/form-data";  // 文件上传
  };
}
```

#### 案例 2：分页查询

```proto
rpc ReturnPageable (Customer) returns (Pet) {
  option (hope.swagger.operation) = {
    post: "/batch-user-pet";
    pageable: true;  // 启用分页
    description: "根据请求返回一个 pageable 数据";
    tags: "user";
    tags: "pet";
    request_name: "pet";
  };
}
```

#### 案例 3：路径参数 + 查询参数

```proto
rpc UpdateByPath (google.protobuf.Empty) returns (google.protobuf.Empty) {
  option (hope.swagger.operation) = {
    post: "/update-by-path/{user-id}/try-more/{user-name}";
    description: "测试两个路径参数";
    tags: "other";
    parameters: {
      parameter: {
        name: "user-id";
        in: PATH;
        schema: {
          format: INTEGER;
          maximum: {value: 12345}
        };
      };
      parameter: {
        name: "user-name";
        in: PATH;
        schema: {
          format: STRING;
          empty: false;
          pattern: "^[A-Za-z0-9+_.-]+@(.+)$";
          max_length: {value: 64}
        };
      }
    }
  };
}
```

#### 案例 4：带权限验证

```proto
rpc PlaceOrder (google.protobuf.Empty) returns (PlaceOrderRequest) {
  option (hope.swagger.operation) = {
    post: "/place-order";
    description: "下单操作";
    summary: "下单详细操作";
    tags: "user";
    tags: "pet";
    security: {
      security_requirement: {
        key: "jwt";
        value: {
          scope: "pet:read";
          scope: "pet:write";
        };
      }
    }
  };
}
```

---

## 四、Operation 字段详解

### 4.1 基础描述

#### `description` (string)

- **作用**: 接口功能说明
- **建议**: 清晰描述接口用途
- **示例**: `description: "上传文件元数据"`

#### `summary` (string)

- **作用**: 简短摘要（建议 <120 字符）
- **用途**: swagger-ui 标题显示
- **示例**: `summary: "创建订单"`

#### `tags` (repeated string)

- **作用**: 接口分组标签
- **建议**: 按业务模块分组
- **示例**: 
```proto
tags: "user";
tags: "order";
```

#### `operation_id` (string)

- **作用**: 接口唯一标识（生成代码时使用）
- **建议**: 使用驼峰命名
- **示例**: `operation_id: "getUserById"`

### 4.2 请求与响应配置

#### `request_name` (string)

- **作用**: 请求体参数名称（用于代码生成）
- **示例**: `request_name: "petRequest"`

#### `pageable` (optional bool)

**类型**: `optional bool` **（可选布尔值！）**  
**作用**: 启用分页查询

**效果**:
- 请求: 自动添加 `page`, `size`, `sort` 参数
- 响应: 包装为 `Page<T>` 结构

**示例**:
```proto
pageable: true
```

#### `input_repeated` / `output_repeated` (optional bool)

**类型**: `optional bool` **（可选布尔值！）**  
**作用**: 标记请求/响应为列表

**示例**:
```proto
input_repeated: true;  // 请求是 List<T>
output_repeated: true;  // 响应是 List<T>
```

**废弃字段警告**:
- ❌ `input_plural` (已废弃) → 使用 `input_repeated`
- ❌ `out_plural` (已废弃) → 使用 `output_repeated`

#### `raw` (optional bool)

**作用**: 不包装响应（直接返回原始类型）

**示例**:
```proto
raw: true  // 不包装为 Result<T>
```

#### `body_empty` (bool)

**作用**: 允许响应 body 为空

**示例**:
```proto
body_empty: true  // POST 返回空 body
```

### 4.3 媒体类型

#### `consumes` (repeated string)

- **作用**: 接口接受的 Content-Type
- **常用值**: `"application/json"`, `"multipart/form-data"`
- **示例**:
```proto
consumes: "multipart/form-data";
```

#### `produces` (repeated string)

- **作用**: 接口返回的 Content-Type
- **示例**:
```proto
produces: "application/json";
```

#### `response_media_type` (MediaType枚举)

**类型**: `Operation.MediaType` 枚举  
**作用**: 指定响应媒体类型

**常用值**:

| 枚举值 | MIME类型 | 使用场景 |
|---|---|---|
| `APPLICATION_JSON` | application/json | JSON 响应（默认） |
| `TEXT_PLAIN` | text/plain | 纯文本 |
| `TEXT_HTML` | text/html | HTML 页面 |
| `APPLICATION_PDF` | application/pdf | PDF 文件 |
| `APPLICATION_XLSX` | ... | Excel 文件 |
| `IMAGE_PNG` | image/png | PNG 图片 |
| `MULTIPART_FORM_DATA` | multipart/form-data | 文件上传 |

**示例**:
```proto
response_media_type: APPLICATION_PDF;
```

### 4.4 参数定义 ⚠️

#### `parameters` (Parameters消息)

**作用**: 定义路径/查询/头部/Cookie/Session 参数

**⚠️ 强制规则**: 
- **所有路径参数**（`/{id}`）**必须**在 `parameters` 中声明
- **所有 Request body 参数**（查询条件、筛选器）**必须**在 `parameters` 中声明
- 缺失 parameter 声明将导致 OpenAPI 文档不完整

**Parameter 字段**:

| 字段 | 类型 | 说明 |
|---|---|---|
| `name` | string | 参数名 |
| `in` | IN枚举 | 位置（QUERY/PATH/HEADER/COOKIE/SESSION） |
| `schema` | JSONSchema | 参数约束 |
| `plural` | bool | 是否数组 |

**IN 枚举值**:

| 枚举值 | 含义 |
|---|---|
| `QUERY` | 查询参数（`?key=value`） |
| `PATH` | 路径参数（`/{id}`） |
| `HEADER` | HTTP 头（`Authorization: xxx`） |
| `COOKIE` | Cookie |
| `SESSION` | Session（框架特有） |

**示例**:
```proto
parameters: {
  parameter: {
    name: "user-id";
    in: QUERY;
    plural: true;  // 数组参数
    schema: {
      format: INTEGER;
      description: "user id";
    }
  };
  parameter: {
    name: "start-date";
    in: QUERY;
    schema: {
      format: DATE;
      description: "begin date";
      empty: false;
      date_format: BASIC_ISO_DATE;
    }
  }
}
```

### 4.5 权限控制

#### `authorization` (Authorization消息)

**方式 1: 低级别风险模式**

```proto
authorization: {
  low_limit_risky_mode: ANONYMOUS  // 或 LOGIN / ACTIVE
}
```

**LowLimitRiskyMode 枚举**:

| 枚举值 | 含义 |
|---|---|
| `ANONYMOUS` | 无需登录 |
| `LOGIN` | 需要登录 |
| `ACTIVE` | 需要登录且账户激活 |

**方式 2: RBAC（角色+权限）**

```proto
authorization: {
  rbac: {
    roles: {
      roles: ["ROLE_ADMIN", "ROLE_USER"]
    };
    authorities: ["USER_CREATE", "USER_DELETE"];
    combinator: AND;  // 或 OR
  }
}
```

**RBAC 字段**:
- `roles.roles`: 角色列表
- `authorities`: 权限列表（需在 Authority 枚举中定义）
- `combinator`: 组合方式（AND=同时满足，OR=满足之一）

**方式 3: SpEL 表达式**

```proto
authorization: {
  expression: "hasRole('ADMIN') and #userId == authentication.principal.id"
}
```

#### `group` (Group枚举)

**作用**: 标记接口所属前端分组

**可选值**:

| 枚举值 | 含义 |
|---|---|
| `CUSTOMER` | 用户端（C端） |
| `TENANT` | 租户管理端（B端） |
| `PLATFORM` | 平台运营端 |

**示例**:
```proto
group: TENANT;
```

### 4.6 优先级与可见性

#### `priority` (Priority枚举)

**作用**: 标记接口重要程度

**可选值**:

| 枚举值 | 数值 | 含义 |
|---|---|---|
| `NA` | 0 | 未设置 |
| `LOW` | 1 | 低优先级 |
| `MIDDLE` | 4 | 中等（需团队主管批准） |
| `HIGH` | 8 | 高（需项目经理批准） |
| `CRITICAL` | 16 | 关键（需VP批准） |
| `FATAL` | 32 | 可能影响业务（需CTO批准） |

**示例**:
```proto
priority: HIGH;
```

#### `internal` (bool)

- **作用**: 标记为内部接口（不对外开放）
- **示例**: `internal: true`

#### `hide` (bool)

- **作用**: 在文档中隐藏该接口
- **示例**: `hide: true`

#### `deprecated` (bool)

- **作用**: 标记接口已废弃
- **示例**: `deprecated: true`

### 4.7 AI友好字段

#### `questions` (repeated string)

**作用**: 自然语言问题（供 LLM 理解接口用途）

**示例**:
```proto
questions: [
  "如何获取用户订单列表？",
  "查询最近一页订单数据",
  "How to get user orders?"
];
```

---

## 五、Message 级扩展

### 5.1 Schema 语法

```proto
message 消息名 {
  option (hope.swagger.schema) = {
    json_schema: {
      title: "对象标题";
      description: "对象说明";
    };
  };
  
  // 字段定义...
}
```

### 5.2 真实案例

```proto
syntax = "proto3";
package com.example.bean;

import "swagger/annotations.proto";

message PlaceOrderRequest {
  option (hope.swagger.schema) = {
    json_schema: {
      title: "PlaceOrder";
      description: "下单请求";
    };
    external_docs: {
      url: "https://example.com/order-design";
      description: "订单设计详细信息"
    }
  };

  uint64 id = 1 [(hope.swagger.field) = {
    description: "请求ID";
    empty: false;
    maximum: 12345;
    example: "1111";
  }];
  
  // 更多字段...
}
```

---

## 六、Field 级扩展（JSONSchema）

### 6.1 基础字段

#### `description` (string)

- **作用**: 字段说明
- **示例**: `description: "用户ID"`

#### `example` (string)

- **作用**: 示例值（供文档和前端使用）
- **示例**: `example: "13800138000"`

#### `title` (string)

- **作用**: 字段标题
- **示例**: `title: "User Name"`

#### `default` (string)

- **作用**: 默认值（JSON Schema 级别）
- **示例**: `default: "ACTIVE"`

### 6.2 空值控制（三选一）

**重要**: 以下三个字段是 `oneof EmptyConstraint`，只能选一个！

#### `empty` (bool)

- **适用**: 所有类型
- **作用**: 
  - 原始类型: 不为 null
  - 字符串: 不为空串（可以是空格）
  - 集合: size > 0
- **示例**:
```proto
empty: false  // 不能为空
```

#### `blank` (bool)

- **适用**: 仅字符串
- **作用**: 不能是空白字符串（不能包含空格）
- **示例**:
```proto
blank: false  // 不能是空白串
```

#### `nullable` (bool)

- **适用**: 非字符串类型
- **作用**: 不能为 null
- **示例**:
```proto
nullable: false  // 不能为 null
```

**选择建议**:
```
字符串，禁止空串 → empty: false
字符串，禁止空白 → blank: false
数字/日期，禁止null → nullable: false
集合，禁止空集合 → empty: false
```

### 6.3 长度约束

#### 字符串长度

**类型**: `uint64`

```proto
max_length: 100;
min_length: 1;
```

#### 集合元素数量

**类型**: `uint64`

```proto
max_items: 50;
min_items: 1;
```

#### 对象属性数量

**类型**: `uint64`

```proto
max_properties: 20;
min_properties: 1;
```

### 6.4 数值约束

#### 最大值/最小值

**类型**: `double`

```proto
maximum: 12345;
minimum: 1;
```

#### 排他性边界

**类型**: `bool` 枚举

```proto
exclusive_maximum: true;  // 开区间 (value < max)
exclusive_minimum: true;  // 开区间 (min < value)
```

#### 倍数约束

**类型**: `double`

```proto
multiple_of: 10;  // 必须是 10 的倍数
```

### 6.5 模式匹配

#### `pattern` (string)

- **作用**: 正则表达式验证
- **示例**:
```proto
pattern: "^[A-Za-z0-9+_.-]+@(.+)$";  // 邮箱格式
pattern: "^1[3-9]\\d{9}$";  // 手机号
```

#### `enum` (repeated string)

- **作用**: 枚举可选值
- **示例**:
```proto
enum: ["PENDING", "APPROVED", "REJECTED"];
```

### 6.6 格式指定

#### `format` (JSONSchemaFormat枚举)

**作用**: 明确字段类型（用于路径/查询参数）

**常用值**:

| 枚举值 | 对应类型 | 使用场景 |
|---|---|---|
| `STRING` | string | 字符串 |
| `INTEGER` | int32 | 整数 |
| `LONG` | int64 | 长整数 |
| `DOUBLE` | double | 浮点数 |
| `BOOLEAN` | bool | 布尔值 |
| `DATE` | LocalDate | 日期（yyyy-MM-dd） |
| `DATE_TIME` | LocalDateTime | 日期时间 |
| `TIME` | LocalTime | 时间 |
| `UUID` | UUID | UUID字符串 |
| `EMAIL` | string | 邮箱 |
| `PASSWORD` | string | 密码（隐藏显示） |
| `BINARY` | bytes | 二进制数据 |

**示例**:
```proto
uint64 id = 1 [(hope.swagger.field) = {
  format: LONG;  // 明确为 Long 类型
}];
```

### 6.7 日期时间约束

#### `time_constraint_type` (TimeConstraintType枚举)

**可选值**:

| 枚举值 | 含义 | 等价Jakarta注解 |
|---|---|---|
| `NA` | 无限制 | - |
| `FUTURE` | 必须是未来时间 | `@Future` |
| `FUTURE_OR_PRESENT` | 未来或当前 | `@FutureOrPresent` |
| `PAST` | 必须是过去时间 | `@Past` |
| `PAST_OR_PRESENT` | 过去或当前 | `@PastOrPresent` |

**示例**:
```proto
string expire_date = 1 [(hope.swagger.field) = {
  time_constraint_type: FUTURE;  // 必须是未来日期
}];
```

#### `date_format` (DateFormat枚举) or `customized_date_format` (string)

**预定义格式**:

| 枚举值 | 格式 | 示例 |
|---|---|---|
| `BASIC_ISO_DATE` | yyyyMMdd | 20231225 |
| `ISO_LOCAL_DATE` | yyyy-MM-dd | 2023-12-25 |
| `ISO_TIME` | HH:mm:ss.SSSSSSS | 10:15:30.123 |
| `ISO_LOCAL_TIME` | HH:mm:ss | 10:15:30 |
| `ISO_LOCAL_DATE_TIME` | yyyy-MM-dd'T'HH:mm:ss | 2023-12-25T10:15:30 |
| `YYYY_MM_DD_HH_MM_SS` | yyyy-MM-dd HH:mm:ss | 2023-12-25 10:15:30 |
| `YYYY_MM_DD_HH_MM_SS_SSS` | yyyy-MM-dd HH:mm:ss:SSS | 2023-12-25 10:15:30:123 |

**自定义格式**:
```proto
customized_date_format: "yyyy/MM/dd";
```

**示例**:
```proto
string created_at = 1 [(hope.swagger.field) = {
  date_format: YYYY_MM_DD_HH_MM_SS;
}];
```

### 6.8 高级验证

#### 邮箱验证

```proto
email: true;  // bool类型
```

#### 断言验证

```proto
assert: true;   // 必须为 true
assert: false;  // 必须为 false
```

#### 小数精度

```proto
digits_integer: 3;   // 整数部分最备3位
digits_fraction: 2;  // 小数部分最备2位
```

#### 小数范围（字符串形式）

```proto
decimal_max: "999.99";
decimal_min: "0.01";
```

---

## 七、Mock 数据配置

### 7.1 Mock 语法位置

#### 字段级 Mock

```proto
string phone = 1 [(hope.swagger.field) = {
  description: "手机号";
  mock: {
    // mock 规则...
  };
}];
```

#### 响应级 Mock（仅简单类型）

```proto
option (hope.swagger.operation) = {
  post: "/ping";
  mock: {
    // mock 规则...
  };
};
```

### 7.2 Mock 规则类型

#### Nature（语义类别）

**作用**: 根据语义自动生成数据

**常用值**:

| 枚举值 | 生成内容 | 示例 |
|---|---|---|
| `EMAIL` | 邮箱 | user@example.com |
| `URL` | 网址 | https://example.com |
| `IP4` | IPv4 地址 | 192.168.1.1 |
| `IP6` | IPv6 地址 | ... |
| `GUID` / `UUID` | UUID | 550e8400-... |
| `PHONE` | 国际电话 | +1-555-1234 |
| `CN_PHONE` | 中国手机号 | 13800138000 |
| `CN_ADDRESS` | 中国地址 | 上海市浦东新区... |
| `CN_GENDER` | 中文性别 | 男/女 |
| `NAME` | 英文姓名 | John Doe |
| `GENDER` | 英文性别 | Male/Female |
| `COUNTRY` | 国家名 | China |
| `ANIMAL` | 动物名 | Cat |
| `COLOR` | 颜色 | Red |

**示例**:
```proto
mock: {nature: EMAIL}
mock: {nature: CN_PHONE}
```

#### StringRule（字符串规则）

**字段**:
- `length` (uint32): 精确长度
- `min` / `max` (uint32): 长度范围
- `pool` (Pool枚举): 字符池
  - `ORIGINAL`: 保持原样
  - `LOWER`: 小写
  - `UPPER`: 大写
  - `NUMBER`: 纯数字
  - `SYMBOL`: 符号
  - `CAPITALIZE`: 首字母大写
- `customized_pool` (string): 自定义字符池
- `candidates` (repeated string): 候选值列表

**示例**:
```proto
mock: {
  string_rule: {
    min: {value: 3};
    max: {value: 20};
    pool: LOWER;
  }
}

mock: {
  string_rule: {
    candidates: ["PENDING", "APPROVED", "REJECTED"]
  }
}
```

#### NumberRule（数值规则）

**字段**:
- `min` / `max` (int64): 整数部分范围
- `min_integer` / `max_integer` (uint32): 整数部分位数
- `min_fraction` / `max_fraction` (uint32): 小数部分位数

**示例**:
```proto
mock: {
  number_rule: {
    min: 1;
    max: 100000;
    min_fraction: 0;
    max_fraction: 2;  // 0-2位小数
  }
}
```

#### DateRule（日期规则）

**方式 1: 生日**

```proto
mock: {
  date_rule: {
    birth_day: {
      min_age: 18;
      max_age: 60;
    }
  }
}
```

**方式 2: 相对时间**

```proto
mock: {
  date_rule: {
    time_gap: 30;
    time_unit: DAYS;  // NANOSECONDS/MICROSECONDS/MILLISECONDS/SECONDS/MINUTES/HOURS/DAYS
    dir: PAST;  // PAST/FUTURE
  }
}
```

#### ChineseRule（中文文本）

**类型**:
- `PARAGRAPH`: 段落
- `SENTENCE`: 句子
- `WORD`: 词
- `TITLE`: 标题

**示例**:
```proto
mock: {
  chinese_rule: {
    type: TITLE;
    min: 5;
    max: 20;
  }
}
```

#### ChineseNameRule（中文姓名）

**类型**:
- `FIRST`: 名
- `LAST`: 姓
- `NAME`: 全名

**示例**:
```proto
mock: {
  chinese_name_rule: {
    type: NAME
  }
}
```

#### ChinaAddressRule（中国地址）

**类型**:
- `REGION`: 区域（华北、华东...）
- `PROVINCE`: 省
- `CITY`: 市
- `COUNTY`: 区/县
- `ADDRESS`: 完整地址

**示例**:
```proto
mock: {
  china_address_rule: {
    type: ADDRESS;
    with_prefix: true;
  }
}
```

---

## 八、关键类型辨析

### 8.1 bool vs 字符串

❌ **错误**:
```proto
empty: "false"  // 字符串，错误！
nullable: "true"  // 字符串，错误！
plural: "false"  // 字符串，错误！
```

✅ **正确**:
```proto
empty: false  // bool类型
nullable: true
plural: false
```

### 8.2 uint32/uint64/int64/double vs 包装类型

❌ **错误** (过时语法):
```proto
length: {value: 32}  // 老语法，不再需要！
max_length: {value: 100}
maximum: {value: 12345}
```

✅ **正确**:
```proto
length: 32  // uint32
max_length: 100  // uint64
maximum: 12345  // double
```

### 8.3 optional bool vs bool

**proto3 新语法**: `optional bool` 用于三态布尔

```proto
optional bool pageable = 51;  // 未设置/true/false
optional bool raw = 52;
```

**区别**:
- `bool`: 默认 false（两态）
- `optional bool`: 可以不设置（三态）

---

## 九、完整示例

### 9.1 完整 Service 示例

```proto
syntax = "proto3";
package com.example.pet.service;

import "com/example/pet/bean/request.proto";
import "swagger/annotations.proto";
import "google/protobuf/empty.proto";

service PetService {
  option (hope.swagger.svc) = {
    path: "/pet";
    description: "宠物管理服务";
  };

  // 上传文件
  rpc UploadFile (UploadRequest) returns (google.protobuf.Empty) {
    option (hope.swagger.operation) = {
      post: "/upload";
      description: "上传宠物照片";
      tags: "pet";
      consumes: "multipart/form-data";
      multipart: true;
      authorization: {
        low_limit_risky_mode: LOGIN
      };
    };
  };

  // 分页查询
  rpc ListPets (PetQueryRequest) returns (Pet) {
    option (hope.swagger.operation) = {
      post: "/list";
      description: "分页查询宠物列表";
      tags: "pet";
      pageable: true;
      authorization: {
        rbac: {
          authorities: ["PET_VIEW"];
        }
      };
    };
  };

  // 路径参数
  rpc GetPetById (google.protobuf.Empty) returns (Pet) {
    option (hope.swagger.operation) = {
      get: "/pets/{id}";
      description: "根据ID获取宠物详情";
      tags: "pet";
      parameters: {
        parameter: {
          name: "id";
          in: PATH;
          schema: {
            format: LONG;
            minimum: {value: 1};
          };
        }
      };
      authorization: {
        low_limit_risky_mode: ANONYMOUS
      };
    };
  };

  // 复杂权限控制
  rpc DeletePet (google.protobuf.Empty) returns (google.protobuf.Empty) {
    option (hope.swagger.operation) = {
      delete: "/pets/{id}";
      description: "删除宠物";
      tags: "pet";
      priority: HIGH;
      parameters: {
        parameter: {
          name: "id";
          in: PATH;
          schema: {
            format: LONG;
          };
        }
      };
      authorization: {
        rbac: {
          roles: {roles: ["ROLE_ADMIN"]};
          authorities: ["PET_DELETE"];
          combinator: AND;
        }
      };
    };
  };
}
```

### 9.2 完整 Message 示例

```proto
syntax = "proto3";
package com.example.pet.bean;

import "swagger/annotations.proto";
import "com/example/pet/enumeration/constants.proto";

message PlaceOrderRequest {
  option (hope.swagger.schema) = {
    json_schema: {
      title: "PlaceOrderRequest";
      description: "下单请求对象";
    };
  };

  uint64 id = 1 [(hope.swagger.field) = {
    description: "请求ID";
    empty: false;
    maximum: 12345;
    example: "1111";
  }];

  uint64 pet_id = 2 [(hope.swagger.field) = {
    description: "宠物ID";
    empty: false;
    minimum: 1;
    maximum: 999999;
    example: "1985";
  }];

  uint32 quantity = 3 [(hope.swagger.field) = {
    description: "购买数量";
    empty: false;
    minimum: 1;
    maximum: 100;
    example: "5";
  }];

  com.example.pet.enumeration.OrderStatus order_status = 4 [(hope.swagger.field) = {
    description: "订单状态";
  }];

  string ship_date = 5 [(hope.swagger.field) = {
    description: "发货日期";
    example: "2023-12-25";
    date_format: ISO_LOCAL_DATE;
    time_constraint_type: FUTURE;
    empty: false;
  }];

  bool complete = 6 [(hope.swagger.field) = {
    description: "是否完成";
    example: "false";
  }];

  string phone = 7 [(hope.swagger.field) = {
    description: "联系电话";
    example: "13800138000";
    pattern: "^1[3-9]\\d{9}$";
    mock: {nature: CN_PHONE};
  }];

  string email = 8 [(hope.swagger.field) = {
    description: "联系邮箱";
    email: true;
    empty: false;
    mock: {nature: EMAIL};
  }];

  string remark = 9 [(hope.swagger.field) = {
    description: "备注";
    max_length: 500;
    mock: {
      chinese_rule: {
        type: SENTENCE;
        max: {value: 50};
      }
    };
  }];
}
```

---

## 十、常见错误

### 10.1 类型混淆

❌ **错误**:
```proto
empty: "false"  // 字符串
max_length: {value: 100}  // 老语法
pageable: "false"  // 字符串
```

✅ **正确**:
```proto
empty: false  // bool类型
max_length: 100  // uint64类型
pageable: true  // optional bool
```

### 10.2 oneof 冲突

❌ **错误**:
```proto
empty: false;
blank: false;  // 两个都设置了！
```

✅ **正确**:
```proto
empty: false;  // 只设置一个
```

### 10.3 废弃字段使用

❌ **错误**:
```proto
input_plural: true;  // 已废弃
out_plural: true;  // 已废弃
```

✅ **正确**:
```proto
input_repeated: true;  // 使用新字段
output_repeated: true;
```

---

## 十一、最佳实践

### 11.1 HTTP 方法选择

```
查询单个资源 → GET /resources/{id}
查询列表 → GET /resources 或 POST /resources/search
创建资源 → POST /resources
全量更新 → PUT /resources/{id}
部分更新 → PATCH /resources/{id}
删除资源 → DELETE /resources/{id}
```

### 11.2 路径设计

```
资源集合 → /pets
特定资源 → /pets/{id}
子资源 → /pets/{id}/photos
操作 → /pets/{id}/activate （动词形式）
复杂查询 → POST /pets/search
```

### 11.3 权限设计

```
公开接口 → low_limit_risky_mode: ANONYMOUS
需登录 → low_limit_risky_mode: LOGIN
需角色 → rbac.roles
需权限 → rbac.authorities
复杂规则 → rbac.combinator: AND
```

### 11.4 Mock 数据选择

```
邮箱 → nature: EMAIL
手机 → nature: CN_PHONE
UUID → nature: GUID
姓名 → chinese_name_rule
地址 → china_address_rule
日期 → date_rule
枚举 → string_rule.candidates
```

---

## 十二、快速参考

### Service 模板

```proto
service 服务名 {
  option (hope.swagger.svc) = {
    path: "/路径";
    description: "说明";
  };
  
  rpc 方法名 (...) returns (...) {
    option (hope.swagger.operation) = {
      post: "/path";
      description: "说明";
    };
  }
}
```

### Operation 模板

```proto
option (hope.swagger.operation) = {
  post: "/路径";
  description: "说明";
  tags: "标签";
  authorization: {
    low_limit_risky_mode: LOGIN
  };
};
```

### Field 模板

```proto
string 字段名 = 序号 [(hope.swagger.field) = {
  description: "说明";
  example: "示例";
  empty: false;
}];
```
