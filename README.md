# SwiftKnex
A Mysql Native Client and Query Builder that works on Mac and Linux.  
This library is powerded by [Prorsum](https://github.com/noppoman/Prorsum)

**SwiftKnex is aimed to use at production services at my company**

<img src="https://camo.githubusercontent.com/93de6573350b91e48ab570a4fe710e4e8baa38b8/687474703a2f2f696d672e736869656c64732e696f2f62616467652f73776966742d332e302d627269676874677265656e2e737667"> [<img src="https://travis-ci.org/noppoMan/Prorsum.svg?branch=master">](https://travis-ci.org/noppoMan/SwiftKnex)

## Features
* [x] Pure Swift Implementation(doesn't depend on libmysqlclient)
* [x] Expressive querying
* [x] Supporting Database Migration and Rollback
* [x] Supported Mysql 5.7 JSON Data Type
* [ ] Async I/O

## TODO
* BlobType
* GeoType
* Investigate Performance
* Async I/O Mode
* Documentation

## Contributing
All developers should feel welcome and encouraged to contribute to SwiftKnex.

To contribute a feature or idea to SwiftKnex please submit an issue! If you find bugs, of course you can create the PR(s) directory.

# Query Builder Reference

## Initializing the Library

```swift
let config = KnexConfig(
    host: "localhost",
    user: "user",
    database: "my_database",
    isShowSQLLog: true
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

let results = try knex.table("users").where(.withOperator("id", .equal, 1)).fetch()
print(results)
```

### where between and limit and offset

You can chain the conditional clauses like SQL and it's amazing expressive.

```swift
let results = try knex
                  .table("users")
                  .where(.between("id", 1, 1000))
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

### count
```swift
let results = try knex
                  .select(count("id").as("count"))
                  .table("users")
                  .fetch()

print(results)
```

### where based on priority
```swift
let results = try knex
                    .table("users")
                    .where(("country" == "Japan" && "age" > 20) || "country" == "USA")

print(results)
```

### Sub Query

#### fetch all rows from the results that taken by subquery.
```swift
let results = try knex
                    .table(
                        Table(
                            QueryBuilder()
                              .table("users")
                              .where("country" == "USA")
                            )
                        ).as("t1")
                    )
                    .where("t1.id" == 1)

print(results)
```

#### Use ids taken by subquery as argument of in clause
```swift
let results = try knex
                    .table("users")
                    .where(.in("id",
                        QueryBuilder()
                          .select(col("id"))
                          .table("t1")
                          .where("country" == "USA")
                    )).fetch()

print(results)
```

### TypeSafe Querying with Entity protocol

Define Your Entity with confirming `Entity` protocol and fetch rows as your specified type.

```swift
struct User: Entity, Serializable {
    let id: Int
    let name: String
    let email: String
    let age: Int
    let country: String?

    init(row: Row) throws {
        self.id = row["id"] as! Int
        self.name = row["name"] as! String
        self.email = row["email"] as! String
        self.age = row["age"] as! Int
        self.country = row["country"] as? String
    }

    func serialize() throws -> [String: Any] {
        return [
            "name": name,
            "email": email,
            "age": age,
            "country": country
        ]
    }
}

// fetch rows as User(s)
let users: [User] = try! con.knex()
                            .table("users")
                            .where("country" == "Japan")
                            .fetch()

print(users.first)

// Insert User(should confirm Serializable)
let result = try! con.knex().insert(into: "users", values: user)

print(result?.insertId)
```

### Available clauses

Note. Recently not supported entire clauses in Mysql.

* `where(_ filter: ConditionFilter)`
  - `withOperator(field: String, op: Operator, value: Any)`
  - `like(field: String, value: String)`
  - `in(field: String, value: Any)`
  - `notIn(field: String, value: Any)`
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
let result = try knex().table("users").where("id" == 1).update(sets: ["name": "foobar"])

print(result.affectedRows)
```

## Delete
```swift
let result = try knex().table("users").where("id" == 1).delete()

print(result.affectedRows)
```

## Transaction

```swift

do {
    try con.knex().transaction { trx in // BEGIN TRANSCTION
        try con.knex().table("users").where("id" == 1).update(sets: ["name": "foo"], trx: trx)
        try con.knex().table("users").where("id" == 2).update(sets: ["name": "bar"], trx: trx)
        try con.knex().table("users").where("id" == 3).update(sets: ["name": "foobar"], trx: trx)
    }
    // COMMIT
} catch {
    // ROLLBACK
}
```

# DDL

# Create
```swift
let create = Create(table: "users", fields: [
    Schema.Field(name: "id", type: Schema.Types.Integer()).asPrimaryKey().asAutoIncrement(),
    Schema.Field(name: "name", type: Schema.Types.String()),
    Schema.Field(name: "email", type: Schema.Types.String()).asUnique(),
    Schema.Field(name: "last_logined_at", type: Schema.Types.DateTime()).asIndex()
])
.hasTimeStamps() // add created_at and updated_at

try knex().execRaw(sql: create.toDDL())
```

## Schema.Field Reference

### Schema Types Comparison

| Schema.Types  | Mysql Type    |
| ------------- |:-------------:|
| String       | VARCHAR        |
| Integer      | INT            |
| BigInteger   | BIGIMT         |
| DateTime     | DATETIME       |
| Text         | TEXT           |
| MediumText   | MEDIUMTEXT     |
| Float        | FLOAT          |
| Double       | DOUBLE         |
| Boolean      | TINYINT(1)     |
| JSON         | JSON           |

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
let drop = Drop(table: "users")
try knex().execRaw(sql: drop.toDDL())
```

# Raw
You can perform raw sql with SwiftKnex

```swift
try knex().execRaw(sql: "SELECT * from users where id = ?", params: [1])
```

# Migration
SwiftKnex supports database migration and rollback features.

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
and then, `SwiftKnexMigration` executable binary was created in the .build/debug directory.

### 2. Create Migration file

the next step is creating migration class file into your `Sources/Migration` directory with `./build/debug/Migration create {ResourceName}`

here is an example for creating `CreateUser` migration file
```
.build/debug/SwiftKnexMigration create CreateUser

#
# Created /YourProject/Sources/Migration/20170116015823_CreateUser.swift
#
```

### 3. Edit Your Migration File

After create migration class file, edit it like following.

The created migration class has following methods.
#### up
Performed on migrate:latest

#### down
Performed on migrate:rollback

```swift
import SwiftKnex
import Foundation

class Migration_20170116015823_CreateUser: Migratable {

    var name: String {
        return "\(Mirror(reflecting: self).subjectType)"
    }

    func up(_ migrator: Migrator) throws {
       let create = Create(
           table: "users",
           fields: [
               Schema.Field(name: "id", type: Schema.Types.Integer()).asPrimaryKey().asAutoIncrement(),
               Schema.Field(name: "name", type: Schema.Types.String()).asIndex().asNotNullable(),
               Schema.Field(name: "email", type: Schema.Types.String()).asUnique().asNotNullable()
           ])
           .hasTimestamps()
           .index(columns: ["name", "email"], unique: true)

       try migrator.run(create)
    }

    func down(_ migrator: Migrator) throws {
        try migrator.run(Drop(table: "users"))
    }
}
```


### 4. Create `main.swift` in the `{$PROJ}/Sources/Migration`

Create `main.swift` in the `{$PROJ}/Sources/Migration` directory that is created by `Migrate create` at previous section.  
And copy/paste the following code into your `{$PROJ}/Sources/Migration/main.swift` and then, replace the class names in the `knexMigrations` array to correct names, and change the database configuration depending on your environment.

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

after editing main.swift, run `swift build`
```
swift build
```

### 5. Perform Migration and Rollback
After that, you only need to run the migration

**Current supporting commands are**
* `migrate:latest`:  Perform to migrate recent unmigrated files.
* `migrate:rollback`: Rollback the migrations recent performed.(The rollback unit is grouped by `batch` number)

#### Try to perform Migration
```
.build/debug/Migration migrate:latest
```

#### Try to perform Rollback
```
.build/debug/Migration migrate:rollback
```

#### Seed
TODO

# Working with Prorsum
Go Style async query performing and syncronization with Prorsum

```swift
import Prorsum

let chan = Channel<ResultSet>.make()

go {
    let rows = try! knex().table("users").where("id" == 1).fetch()
    try chan.send(rows!)
}

go {
    let rows = try! knex().table("users").where("id" == 2).fetch()
    try chan.send(rows!)
}

print(try! chan.receive())
print(try! chan.receive())
```

# Mysql Library
The base Connection and Querying library that used in SwiftKnex.

TODO

## License
Prorsum is released under the MIT license. See LICENSE for details.
