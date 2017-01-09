# SwiftKnex
A Mysql Native Client and Query Builder that works on Mac and Linux.

## Features
* [x] Pure Swift Implementation(doesn't depend on libmysqlclient)
* [x] Expressive querying
* [x] Supporting Database Migration and Rollback
* [ ] Async I/O

# Query Builder Reference

## Initializing the Library

```swift
let config = KnexConfig(
    host: "localhost",
    user: "user",
    database: "my_database",
    isShowSQlLog: true
)

let con = try KnexConnection(config: config)
let knex = con.knex()
```

# Query Builder

## Select

### where equal
```swift
let results = try knex.table("users").where("id" == 1).fetch()
print(results)

// or

let results = try knex.table("users").where(.withOperator(field: "id", op: .equal, value: 1)).fetch()
print(results)
```

### where between and limit and offset

You can chain the conditional clauses like SQL and it's amazing expressive.

```swift
let results = try knex
                  .table("users")
                  .where(.between(field: "id", from: 1, to: 1000))
                  .limit(10)
                  .offset(10)
                  .fetch()

print(result)
```

### join
```swift
let results = try knex
                  .table("users")
                  .join("payments")
                  .on("users.id" == "payment.user_id")
                  .where("users.id" == 1)
                  .limit(10)
                  .offset(10)
                  .fetch()

print(results)
```

### Available clauses

Note. Recently not supported entire clauses in Mysql.

* `where(_ filter: ConditionFilter)`
  - `withOperator(field: String, op: Operator, value: Any)`
  - `in(field: String, values: [Any])`
  - `notIn(field: String, values: [Any])`
  - `between(field: String, from: Any, to: Any)`
  - `notBetween(field: String, from: Any, to: Any)`
  - `isNull(field: String)`
  - `isNotNull(field: String)`
  - `raw(String)`
* `or(_ clause: ConditionFilter)`
* `join(_ table: String)`
* `leftJoin(_ table: String)`
* `rightJoin(_ table: String)`
* `innerJoin(_ with table: String)`
* `on(_ filter: ConditionFilter)`
* `limit(_ limit: Int)`
* `offset(_ offset: Int)`
* `order(by: String, sort: OrderSort = .asc)`
* `group(by name: String)`
* `having(_ cond: ConditionFilter)`

## Insert
```swift
let result = try knex().insert(into: "users", values: ["id": 1, "name": "bar"])

print(result.affectedRows)
```

## Update
```swift
let result = try knex().table(from: "users").where("id" == 1).update(sets: ["name": "foobar"])

print(result.affectedRows)
```

## Delete
```swift
let result = try knex().table(from: "users").where("id" == 1).delete()

print(result.affectedRows)
```


# DDL

# Create
```swift
let create = Create(table: "users", fields: [
    Schema.Field(name: "id", type: .int(length: nil)).asPrimaryKey().asAutoIncrement(),
    Schema.Field(name: "name", type: .string(length: nil)),
    Schema.Field(name: "email", type: .string(length: nil)).asUnique(),
    Schema.Field(name: "last_logined_at", type: .datetime).asIndex()
])
.hasTimeStamps() // add created_at and updated_at

try knex().execRaw(sql: create.toDDL())
```

## Schema.Field Reference

### Schema Types
```swift
public enum SchemaType {
    case string(length: Int?)
    case text
    case mediumText
    case int(length: Int?)
    case bigInt(length: Int?)
    case datetime
    case float(precision: Range<Int>?)
    case double(precision: Range<Int>?)
    case boolean
}
```
### Functions for adding field attributes
* `default(as value: Any)`
* `after(for name: String)`
* `asPrimaryKey()`
* `asAutoIncrement()`
* `asNotNullable()`
* `asUngisned()`
* `charset(_ char: Charset)`
* `asUnique()`
* `asIndex()`


# Drop
```swift
let drop = Drop(table: "uesrs")
try knex().execRaw(sql: drop.toDDL())
```

# Raw
You can perform raw sql with SwiftKnex

```swift
try knex().execRaw(sql: "SELECT * from users where id = ?", params: [1])
```

# Migration
SwiftKnex supports database migration features.
**Migration feature is pretty in early development**

## Flows

### 1. Install SwiftKnex into your project.

**Package.swift**
```swift
import PackageDescription

let package = Package(
    name: "MyApp",
    dependencies: [
        .Package(url: "https://github.com/noppoMan/SwiftKnex.git", majorVersion: 0, minor: 1)
    ]
)
```
**run swift build**
```
$ swift build
```
and then, `SwiftKnexMigration` executable binary is created in the .build/debug directory.

### 2. Create Migration file into Your `{$PROJ}/Sources/SwiftKnexMigration`
```
./build/debug/SwiftKnexMigration create CreateUser

#
# Created /YourProject/Sources/Migration/20170116015823_CreateUser.swift
#
```


### 3. Create `main.swift` in the `{$PROJ}/Sources/Migration`

Create `main.swift` in the `{$PROJ}/Sources/Migration` that is created by `Migrate create` at previous section.  
And copy and paste the following code into your main.swift with replacing the `Migration_20170116015823_CreateUser` with correct class name.

You need to add the new class name(s) to the `knexMigrations` at every migration resource created.

**main.swif example**
```swift
import SwiftKnex

let knexMigrations: [Migratable] = [
    Migration_20170116015823_CreateUser()
]

let config = KnexConfig(
   host: "localhost",
   user: "root",
   database: "swift_knex_test"
)

try Migrator.run(config: config, arguments: CommandLine.arguments, knexMigrations: knexMigrations)
```

### 4. Perform Migration and Rollback
After that, you only need to run the migration

```
swift build
```

#### Migration
```
./build/Migration migrate:latest
```

#### Rollback
```
./build/Migration migrate:rollback
```

#### Seed
TODO

# Mysql Library
The base Connection and Querying library that used in SwiftKnex.

TODO

## License
Prorsum is released under the MIT license. See LICENSE for details.
