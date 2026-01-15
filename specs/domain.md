# 数据库建模扩展使用手册

将 proto message 映射为数据库表结构（实体）。

- **扩展包**: `apihug/protobuf/domain/persistence.proto` + `annotations.proto`  
- **作用域**: Message(表) + Field(列)  
- **场景**: 实体、DDL生成、Liquibase

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

**Domain 层（domain/）必须保持架构纯净**：

```proto
// ❌ 禁止引用 API 层消息
import "com/example/api/user/api.proto";  // 错误！
import "com/example/api/order/request.proto";  // 错误！

message UserEntity {
  // ❌ 禁止使用 API Request/Response 类型
  CreateUserRequest request = 1;  // 错误！
  UserLoginResponse response = 2;  // 错误！
}
```

**✅ 允许的引用**：
```proto
// ✅ 允许引用常量层（infra/）
import "com/example/infra/settings/user_constant.proto";

// ✅ 允许引用其他 domain entity
import "com/example/domain/entities/order.proto";

message UserEntity {
  UserStatusEnum status = 1;  // ✅ 枚举可共享
  OrderEntity order = 2;  // ✅ domain 内部引用
}
```

**架构原则**：Domain 层只关注数据持久化，与 API 层完全隔离。

---

## 一、导入与语法

### 1.1 导入

```proto
import "apihug/protobuf/domain/annotations.proto";
```

**注**: `annotations.proto` 自动引入 `persistence.proto` 和 `apihug/protobuf/extend/common.proto`

### 1.2 基本语法

#### 表级别 (Message)

```proto
message 实体名 {
  option (hope.persistence.table) = {
    name: "表名";
    description: "表说明";
    // 其他配置...
  };
  
  // 字段定义...
}
```

#### 列级别（Field）

```proto
string 字段名 = 序号 [(hope.persistence.column) = {
  name: "列名";
  description: "列说明";
  nullable: FALSE;
  type: VARCHAR;
  // 其他配置...
}];
```

### 1.3 快速示例

```proto
syntax = "proto3";
package com.example.pet.domain;

import "apihug/protobuf/domain/annotations.proto";

message Category {
  option (hope.persistence.table) = {
    name: "CATEGORY",
    description: "宠物分类",
    wires: [IDENTIFIABLE]  // 自动添加 id 字段
  };

  string name = 1 [(hope.persistence.column) = {
    name: "NAME",
    description: "分类名称",
    nullable: false,
    length: 32,
    unique: true,
    type: VARCHAR
  }];
}
```

---

## 二、Table 扩展详解

### 2.1 基础字段

#### `name` (string)

- **作用**: 数据库表名
- **建议**: 使用大写下划线风格（`CATEGORY`, `USER_ORDER`）
- **示例**: `name: "PET"`

#### `description` (string)

- **作用**: 表的业务说明
- **建议**: 使用中文或自然语言描述
- **示例**: `description: "宠物信息表"`

#### `catalog` (string)

- **作用**: 数据库目录（Database Catalog）
- **使用场景**: 多数据库环境
- **示例**: `catalog: "pet_db"`

#### `schema` (string)

- **作用**: 数据库模式（Database Schema）
- **使用场景**: Oracle/PostgreSQL 等多 schema 环境
- **示例**: `schema: "public"`

### 2.2 约束定义

#### `unique_constraints` (repeated)

**类型**: `UniqueConstraint` 消息  
**作用**: 定义唯一约束

**字段**:
- `name` (string): 约束名称
- `column_list` (repeated string): 列名数组

**示例**:
```proto
unique_constraints: {
  name: "UK_PET_NAME_CATEGORY",
  column_list: ["name", "category"]
}
```

#### `indexes` (repeated)

**类型**: `Index` 消息  
**作用**: 定义索引

**字段**:
- `name` (string): 索引名称
- `column_list` (repeated string): 列名数组
- `unique` (bool): 是否唯一索引

**示例**:
```proto
indexes: {
  name: "IDX_PET_NAME",
  column_list: ["name"]
}

indexes: {
  name: "IDX_CATEGORY_UNIQUE",
  column_list: ["category"],
  unique: TRUE
}
```

### 2.3 内置特性 (Wire Protocol)

#### `wires` (repeated Wire枚举)

`WIRE` 类型支持的定义， 禁止自行设计类似字段，保持一致性！！

**作用**: 启用平台内置的通用特性

**可选值**:

| 枚举值 | 含义 | 自动添加字段 |
|---|---|---|
| `ALL` | 启用所有特性 | id + 审计 + 删除标记 + 租户 + 版本号 |
| `IDENTIFIABLE` | 仅添加主键 | `id` (Long) |
| `AUDITABLE` | 审计字段 | `created_at`, `updated_at`, `created_by`, `updated_by` |
| `DELETABLE` | 逻辑删除 | `deleted` (Boolean) |
| `TENANTABLE` | 多租户 | `tenant_id` (Long) |
| `VERSIONABLE` | 乐观锁 | `version` (Integer) |
| `NONE` | 完全自定义 | 无 |

**示例**:
```proto
// 只需要主键
wires: [IDENTIFIABLE]

// 需要审计和逻辑删除
wires: [IDENTIFIABLE, AUDITABLE, DELETABLE]

// 完全自定义
wires: [NONE]
```

### 2.4 视图定义

#### `views` (repeated View消息)

**警告**: ⚠️ **非用户明确需求，勿添加 view！**

**作用**: 为实体定义不同的视图（列表、详情、统计等）

**字段**:
- `name` (string): 视图名称
- `description` (string): 视图说明
- `includes` (repeated string): 包含字段列表
- `excludes` (repeated string): 排除字段列表
- `references` (repeated ReferenceView): 关联其他实体
- `aggregated_fields` (repeated AggregatedField): 聚合字段

**示例**:
```proto
views: [{
  name: "PetView",
  description: "宠物列表视图",
  includes: ["id", "name", "category", "size"]
}]

views: [{
  name: "PetDetailView",
  description: "宠物详情视图（包含分类信息）",
  includes: ["id", "name", "category"],
  references: [{
    entity: "Category",
    includes: ["description"],
    join_type: INNER,
    left_field: "category",
    right_field: "name"
  }]
}]
```

### 2.5 Liquibase 集成

#### `liquibase` (repeated Liquibase消息)

**作用**: 为特定数据库执行自定义 SQL

**字段**:
- `version` (uint32): 版本号（仅追加，不可修改）
- `comment` (string): 变更说明
- `dbms` (repeated DBMS枚举): 目标数据库
- `negative` (bool): 是否排除 dbms（true 表示排除）
- `sql` (repeated string): SQL 语句数组

**示例**:
```proto
liquibase: {
  version: 1,
  comment: "MySQL 特殊索引",
  dbms: [MYSQL],
  sql: [
    "CREATE FULLTEXT INDEX idx_pet_name_ft ON PET(name)"
  ]
}

liquibase: {
  version: 2,
  comment: "非 H2 数据库的分区表",
  dbms: [H2],
  negative: true,
  sql: [
    "ALTER TABLE PET PARTITION BY RANGE (id)"
  ]
}
```

---

## 三、Column 扩展详解

### 3.1 基础字段

#### `name` (string)

- **作用**: 数据库列名
- **建议**: 大写下划线风格（`USER_NAME`, `CREATED_AT`）
- **示例**: `name: "NAME"`

#### `description` (string)

- **作用**: 列的业务说明
- **示例**: `description: "用户姓名"`

### 3.2 约束字段

#### `nullable` (bool)

**类型**: `bool`  
**作用**: 是否允许 NULL

**可选值**:
- `true`: 允许 NULL
- `false`: NOT NULL

**示例**:
```proto
nullable: false  // NOT NULL
nullable: true   // 允许 NULL
```

#### `unique` (bool)

**类型**: `bool`  
**作用**: 是否唯一约束

**示例**:
```proto
unique: true   // UNIQUE
unique: false  // 非唯一
```

#### `insertable` (bool)

**作用**: 是否参与 INSERT 语句

**示例**:
```proto
insertable: false  // 不参与插入（如计算字段）
```

#### `updatable` (bool)

**作用**: 是否参与 UPDATE 语句

**示例**:
```proto
updatable: false  // 不可修改（如创建时间）
```

#### `searchable` (bool)

**作用**: 是否用于 WHERE 条件查询

**示例**:
```proto
searchable: true  // 可用于过滤
```

#### `sortable` (bool)

**作用**: 是否用于 ORDER BY 排序

**示例**:
```proto
sortable: true  // 可排序
```

### 3.3 类型与长度

#### `type` (Column.Type枚举)

**类型**: `hope.persistence.Column.Type` 枚举  
**作用**: 明确指定 SQL 类型（覆盖 proto 类型推断）

**常用值**:

| 枚举值 | SQL类型 | 适用场景 |
|---|---|---|
| `VARCHAR` | VARCHAR | 字符串 |
| `CHAR` | CHAR | 固定长度字符 |
| `INTEGER` | INTEGER | 整数 |
| `BIGINT` | BIGINT | 长整数 |
| `DOUBLE` | DOUBLE | 浮点数 |
| `DECIMAL` | DECIMAL | 精确小数 |
| `DATE` | DATE | 日期 |
| `TIME` | TIME | 时间 |
| `TIMESTAMP` | TIMESTAMP | 时间戳 |
| `BOOLEAN` | BOOLEAN | 布尔值 |
| `BLOB` | BLOB | 二进制大对象 |
| `CLOB` | CLOB | 文本大对象 |

**示例**:
```proto
string name = 1 [(hope.persistence.column) = {
  type: VARCHAR  // 显式指定 VARCHAR
}];

double weight = 2 [(hope.persistence.column) = {
  type: DOUBLE  // 浮点数
}];
```

#### `length` (uint32)

**类型**: `uint32`  
**作用**: 字符串长度（仅 VARCHAR/CHAR 有效）

**示例**:
```proto
length: 32  // VARCHAR(32)

length: 255  // VARCHAR(255)
```

#### `precision` (uint32)

**类型**: `uint32`  
**作用**: DECIMAL 总位数

**示例**:
```proto
precision: 10  // DECIMAL(10, ...)
```

#### `scale` (uint32)

**类型**: `uint32`  
**作用**: DECIMAL 小数位数

**示例**:
```proto
precision: 10,
scale: 2  // DECIMAL(10, 2)
```

### 3.4 枚举映射

#### `enum_type` (EnumType枚举)

**类型**: `hope.persistence.EnumType` 枚举  
**作用**: 枚举字段的持久化方式

**可选值**:

| 枚举值 | 持久化内容 | 说明 |
|---|---|---|
| `STRING` | 枚举名称 | 默认值，存储如 "AVAILABLE" |
| `CODE` | code 字段 | 存储业务编码（需在枚举上定义 code） |

**禁止**: ❌ 不再支持 `ORDINAL`（序号），易出错已废弃

**示例**:
```proto
import "com/example/enumeration/constants.proto";

com.example.enumeration.Size size = 1 [(hope.persistence.column) = {
  name: "SIZE",
  enum_type: STRING,  // 存储 "SMALL"/"MEDIUM"/"LARGE"
  type: VARCHAR
}];

com.example.enumeration.Status status = 2 [(hope.persistence.column) = {
  name: "STATUS",
  enum_type: CODE,  // 存储 1/2/3（枚举的 code 值）
  type: INTEGER
}];
```

### 3.5 主键与自增

#### `id` (bool)

**类型**: `bool`  
**作用**: 标记为主键

**示例**:
```proto
int64 id = 1 [(hope.persistence.column) = {
  name: "ID",
  id: true,
  nullable: false
}];
```

#### `generated_value` (GeneratedValue消息)

**作用**: 主键生成策略

**字段**:
- `strategy` (GenerationType枚举): 生成策略
- `generator` (string): 生成器名称（可选）

**策略枚举**:

| 枚举值 | 说明 | 适用场景 |
|---|---|---|
| `TABLE` | 表序列 | 通用 |
| `SEQUENCE` | 数据库序列 | Oracle/PostgreSQL |
| `IDENTITY` | 自增列 | MySQL/SQL Server |
| `UUID` | UUID 生成 | 分布式系统 |
| `AUTO` | 自动选择 | 让框架决定 |

**示例**:
```proto
int64 id = 1 [(hope.persistence.column) = {
  name: "ID",
  id: TRUE,
  generated_value: {
    strategy: UUID
  }
}];

int64 order_id = 1 [(hope.persistence.column) = {
  name: "ORDER_ID",
  id: TRUE,
  generated_value: {
    strategy: SEQUENCE,
    generator: "order_seq"
  }
}];
```

### 3.6 高级字段

#### `transient` (bool)

**作用**: 标记为非持久化字段（仅视图或计算字段）

**示例**:
```proto
string full_name = 10 [(hope.persistence.column) = {
  transient: true  // 不映射到数据库
}];
```

#### `default_value` (string)

**作用**: 列默认值（SQL 级别）

**示例**:
```proto
string status = 5 [(hope.persistence.column) = {
  name: "STATUS",
  default_value: "ACTIVE"
}];

int32 retry_count = 6 [(hope.persistence.column) = {
  name: "RETRY_COUNT",
  default_value: "0"
}];
```

#### `column_definition` (string)

**作用**: 完全自定义列 DDL（覆盖所有自动生成）

**警告**: ⚠️ 仅在特殊需求时使用

**示例**:
```proto
string name = 1 [(hope.persistence.column) = {
  column_definition: "VARCHAR(32) NOT NULL COMMENT '名称'"
}];
```

#### `table` (string)

**作用**: 指定字段所属表（辅助表场景）

**示例**:
```proto
string extra_info = 10 [(hope.persistence.column) = {
  name: "EXTRA_INFO",
  table: "PET_DETAIL"  // 字段在 PET_DETAIL 表
}];
```

---

## 四、关键类型辨析

### 4.1 bool vs 字符串

**错误**: ❌ 以下写法是**错误的**

```proto
nullable: "false"  // 字符串，错误！
unique: "true"     // 字符串，错误！
```

**正确**: ✅ 必须使用 `bool` 类型

```proto
nullable: false  // bool 类型
unique: true     // bool 类型
```

### 4.2 uint32 vs 包装类型

**错误**: ❌ 以下写法是**过时的**

```proto
length: {value: 32}  // 老语法，不再需要！
precision: {value: 10}  // 老语法，不再需要！
```

**正确**: ✅ 直接使用 `uint32`

```proto
length: 32  // uint32 类型

precision: 10

scale: 2
```

### 4.3 Column.Type vs proto 类型

**proto 字段类型** vs **SQL 类型映射**:

| proto类型 | 默认SQL | 显式指定type |
|---|---|---|
| `string` | VARCHAR | `type: VARCHAR` / `CHAR` / `CLOB` |
| `int32` | INTEGER | `type: INTEGER` / `SMALLINT` |
| `int64` | BIGINT | `type: BIGINT` |
| `double` | DOUBLE | `type: DOUBLE` / `DECIMAL` |
| `float` | FLOAT | `type: FLOAT` |
| `bool` | BOOLEAN | `type: BOOLEAN` / `BIT` |
| `bytes` | BLOB | `type: BLOB` / `VARBINARY` |
| 枚举 | VARCHAR | `type: VARCHAR` (配合 `enum_type`) |

**示例**:
```proto
// proto string，默认 VARCHAR
string name = 1 [(hope.persistence.column) = {
  name: "NAME"
  // 未指定 type，自动推断为 VARCHAR
}];

// proto string，强制 CHAR
string code = 2 [(hope.persistence.column) = {
  name: "CODE",
  type: CHAR,  // 显式指定 CHAR
  length: {value: 10}
}];

// proto double，强制 DECIMAL
double price = 3 [(hope.persistence.column) = {
  name: "PRICE",
  type: DECIMAL,  // 显式指定 DECIMAL
  precision: {value: 10},
  scale: {value: 2}
}];
```

---

## 五、完整示例

### 5.1 基础实体：宠物表

```proto
syntax = "proto3";
package com.example.pet.domain;

import "domain/annotations.proto";
import "com/example/pet/enumeration/constants.proto";

message Pet {
  option (hope.persistence.table) = {
    name: "PET",
    description: "宠物信息表",
    
    unique_constraints: {
      name: "UK_PET_NAME_CATEGORY",
      column_list: ["name", "category"]
    },
    
    indexes: {
      name: "IDX_PET_NAME",
      column_list: ["name"]
    },
    
    wires: [IDENTIFIABLE, AUDITABLE, DELETABLE]
  };

  string name = 1 [(hope.persistence.column) = {
    name: "NAME",
    description: "宠物名称",
    nullable: false,
    length: 32,
    type: VARCHAR
  }];

  string category = 3 [(hope.persistence.column) = {
    name: "CATEGORY",
    description: "分类（关联 CATEGORY#NAME）",
    nullable: false,
    length: 32,
    type: VARCHAR
  }];

  com.example.pet.enumeration.Size size = 4 [(hope.persistence.column) = {
    name: "SIZE",
    description: "宠物大小",
    nullable: FALSE,
    enum_type: STRING,  // 存储 "SMALL"/"MEDIUM"/"LARGE"
    type: VARCHAR,
    length: {value: 32}
  }];

  double weight = 5 [(hope.persistence.column) = {
    name: "WEIGHT",
    description: "宠物重量(kg)",
    nullable: FALSE,
    type: DOUBLE
  }];
}
```

### 5.2 复杂实体：订单表

```proto
syntax = "proto3";
package com.example.order.domain;

import "domain/annotations.proto";
import "com/example/order/enumeration/constants.proto";

message Order {
  option (hope.persistence.table) = {
    name: "USER_ORDER",
    description: "订单表",
    
    indexes: {
      name: "IDX_ORDER_USER",
      column_list: ["user_id"]
    },
    indexes: {
      name: "IDX_ORDER_STATUS",
      column_list: ["status"]
    },
    
    wires: [ALL]  // 启用所有特性
  };

  // 主键
  int64 id = 1 [(hope.persistence.column) = {
    name: "ID",
    description: "订单ID",
    id: true,
    nullable: false,
    generated_value: {
      strategy: UUID
    }
  }];

  // 外键
  int64 user_id = 2 [(hope.persistence.column) = {
    name: "USER_ID",
    description: "用户ID",
    nullable: FALSE,
    searchable: TRUE,
    type: BIGINT
  }];

  // 枚举（存储code）
  com.example.order.enumeration.OrderStatus status = 3 [(hope.persistence.column) = {
    name: "STATUS",
    description: "订单状态",
    nullable: FALSE,
    enum_type: CODE,  // 存储 1/2/3...（code值）
    type: INTEGER
  }];

  // 金额（DECIMAL）
  double total_amount = 4 [(hope.persistence.column) = {
    name: "TOTAL_AMOUNT",
    description: "订单总金额",
    nullable: FALSE,
    type: DECIMAL,
    precision: 10,
    scale: 2
  }];

  // 备注（可空长文本）
  string remark = 5 [(hope.persistence.column) = {
    name: "REMARK",
    description: "订单备注",
    nullable: TRUE,
    length: {value: 500},
    type: VARCHAR
  }];

  // 非持久化计算字段
  string user_name = 10 [(hope.persistence.column) = {
    transient: TRUE
  }];
}
```

### 5.3 带视图的实体

```proto
message Pet {
  option (hope.persistence.table) = {
    name: "PET",
    description: "宠物",
    
    // 列表视图
    views: [{
      name: "PetListView",
      description: "宠物列表视图",
      includes: ["id", "name", "category", "size"]
    }],
    
    // 详情视图（关联分类）
    views: [{
      name: "PetDetailView",
      description: "宠物详情视图（含分类信息）",
      includes: ["id", "name", "category"],
      references: [{
        entity: "Category",
        includes: ["description"],
        join_type: INNER,
        left_field: "category",
        right_field: "name"
      }]
    }],
    
    wires: [IDENTIFIABLE]
  };

  // 字段定义...
}
```

---

## 六、常见错误

### 6.1 类型混淆

❌ **错误**:
```proto
nullable: "false"  // 字符串，错误！
length: {value: 32}  // 老语法，不再需要！
unique: "true"     // 字符串，错误！
```

✅ **正确**:
```proto
nullable: false  // bool类型
length: 32  // uint32类型
unique: true     // bool类型
```

### 6.2 枚举映射错误

❌ **错误**:
```proto
com.example.Size size = 1 [(hope.persistence.column) = {
  name: "SIZE",
  enum_type: ORDINAL,  // ORDINAL已废弃！
  type: INTEGER
}];
```

✅ **正确**:
```proto
com.example.Size size = 1 [(hope.persistence.column) = {
  name: "SIZE",
  enum_type: STRING,  // 使用 STRING 或 CODE
  type: VARCHAR,
  length: {value: 32}
}];
```

### 6.3 DECIMAL 配置错误

❌ **错误**:
```proto
double price = 1 [(hope.persistence.column) = {
  type: DECIMAL  // 缺少 precision 和 scale
}];
```

✅ **正确**:
```proto
double price = 1 [(hope.persistence.column) = {
  type: DECIMAL,
  precision: 10,
  scale: 2
}];
```

### 6.4 主键配置不完整

❌ **错误**:
```proto
int64 id = 1 [(hope.persistence.column) = {
  id: TRUE
  // 缺少 nullable 和 generated_value
}];
```

✅ **正确**:
```proto
int64 id = 1 [(hope.persistence.column) = {
  name: "ID",
  id: true,
  nullable: false,
  generated_value: {
    strategy: UUID
  }
}];
```

---

## 七、最佳实践

### 7.1 表名与列名规范

- **表名**: 大写下划线（`USER_ORDER`, `PET_CATEGORY`）
- **列名**: 大写下划线（`USER_ID`, `CREATED_AT`）
- **索引名**: `IDX_表名_列名`（`IDX_PET_NAME`）
- **唯一约束**: `UK_表名_列名`（`UK_USER_EMAIL`）

### 7.2 Wire 选择指南

```
只需主键 → wires: [IDENTIFIABLE]
需要审计 → wires: [IDENTIFIABLE, AUDITABLE]
需要逻辑删除 → wires: [IDENTIFIABLE, DELETABLE]
多租户 → wires: [IDENTIFIABLE, TENANTABLE]
全功能 → wires: [ALL]
完全自定义 → wires: [NONE]
```

### 7.3 类型选择指南

```
短字符串（<255） → VARCHAR + length
长文本 → CLOB
整数主键 → BIGINT
UUID主键 → VARCHAR(36) 或框架处理
金额 → DECIMAL(10,2)
日期 → DATE
时间戳 → TIMESTAMP
布尔 → BOOLEAN
枚举 → VARCHAR + enum_type:STRING
```

### 7.4 索引设计建议

1. 为外键添加索引
2. 为频繁查询的字段添加索引
3. 联合索引注意顺序（最左前缀）
4. 避免过多索引（影响写入性能）

---

## 八、快速参考

### 基本模板

```proto
syntax = "proto3";
package 你的包名;

import "domain/annotations.proto";

message 实体名 {
  option (hope.persistence.table) = {
    name: "表名",
    description: "说明",
    wires: [IDENTIFIABLE]
  };

  字段类型 字段名 = 序号 [(hope.persistence.column) = {
    name: "列名",
    description: "说明",
    nullable: FALSE,
    type: SQL类型
  }];
}
```

### 主键模板

```proto
int64 id = 1 [(hope.persistence.column) = {
  name: "ID",
  id: true,
  nullable: false,
  generated_value: {
    strategy: UUID
  }
}];
```

### 枚举字段模板

```proto
import "你的枚举路径/constants.proto";

你的包名.枚举名 字段名 = 序号 [(hope.persistence.column) = {
  name: "列名",
  nullable: FALSE,
  enum_type: STRING,
  type: VARCHAR,
  length: {value: 32}
}];
```

### DECIMAL模板

```proto
double 字段名 = 序号 [(hope.persistence.column) = {
  name: "列名",
  nullable: FALSE,
  type: DECIMAL,
  precision: 10,
  scale: 2
}];
```
