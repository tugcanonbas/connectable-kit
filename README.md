# ConnectableKit

ConnectableKit is a Swift package for the Vapor framework that simplifies the response DTOs and JSON structures for API projects.

## Features

- Generic JSON structure: The `Connectable` protocol allows you to define a wrapped Vapor `Content` structs.
- Custom HTTPStatus for every responses.
- ErrorMiddleware configurations for handling Vapor's error as ConnectableKit JSON output.
- CORSMiddleware configurations for handling Vapor's CORSMiddleware with ease.

---

## Structure

<table>
<tr><th>Type</td><th>Description</th><th>Type</th></tr>
<tr><td>status</td><td>Five possible cases: information, success, redirection, failure, and error.</td><td>ResponseStatus: String</td></tr>
<tr><td>message</td><td>Optional custom message from server.</td><td>String? = nil</td></tr>
<tr><td>data</td><td>Generic associated type that represents the data that is being sent as a response. It can be any type that conforms to Vapor's Content protocol, which includes types such as String, Int, and custom structs or classes.</td><td>Connectable? = nil</td></tr>
</table>

```json
{
  "status": "success",
  "message": "Profile fetched successfully.",
  "data": {
    "id": "EBAD7AA7-A0AF-45F7-9D40-439C62FB26DD",
    "name": "Tuğcan",
    "surname": "ÖNBAŞ",
    "profileImage": "http://localhost:8080/default_profile_image.png",
    "profileCoverImage": "http://localhost:8080/default_profile_cover_image.png"
  }
}
```

---

## Installation

ConnectableKit can be installed using Swift Package Manager. Simply add the following line to your Package.swift file:

```swift
dependencies: [
    .package(url: "https://github.com/tugcanonbas/connectable-kit.git", from: "1.0.0")
]
```

```swift
dependencies: [
    .product(name: "ConnectableKit", package: "connectable-kit"),
],
```

---

## Usage

To use the ConnectableKit Framework,

### - For Connectable

In Struct, simply conform that `Profile` is `Connectable`

```swift
import ConnectableKit

struct Profile: Model, Connectable {
    @ID(key: .id)
    var id: UUID

    @Field(key: "name")
    var name: String

    @Field(key: "surname")
    var surname: String

    @Field(key: "profileImage")
    var profileImage: String

    @Field(key: "profileCoverImage")
    var profileCoverImage: String
}
```

In Response call `.DTO` for responding wrapped generic response.

return `.toDTO(_ httpStatus: Vapor.HTTPStatus = .ok, status: ResponserStatus = .success, message: String? = nil) -> Responser<Self>`

```swift
app.get("/profiles", ":id") { req -> Profile.DTO in
    let id = try req.parameters.require("id", as: UUID.self)
    let profile = try await Profile.query(on: req.db).filter(\.$id == id).first()!

    return profile.toDTO(message: "Profile fetched successfully.")
}
```

```swift
app.post("/profiles") { req -> Profile.DTO in
    let profile = Profile(
        id: UUID(),
        name: "Tuğcan",
        surname: "ÖNBAŞ",
        profileImage: "http://localhost:8080/default_profile_image.png",
        profileCoverImage: "http://localhost:8080/default_profile_cover_image.png"
    )
    try await profile.save(on: req.db)

    return profile.toDTO(.created, message: "Profile fetched successfully.")
}
```

### - For Empty Response

```swift
app.put("/profiles", ":id") { req -> Connector.DTO in
    let id = try req.parameters.require("id", as: UUID.self)
    let update = try req.content.decode(Profile.Update.self)

    let profile = try await Profile.query(on: req.db).filter(\.$id == id).first()!
    profile.name = update.name
    try await profile.save(on: req.db)

    return Connector.toDTO(.accepted, message: "Profile updated successfully.")
}
```

```json
{
  "status": "success",
  "message": "Profile updated successfully."
}
```

## Connectable protocol

```swift
public protocol Connectable: Content {
    associatedtype DTO = Responser<Self>
    func toDTO(_ httpStatus: Vapor.HTTPStatus, status: ResponserStatus, message: String?) -> Responser<Self>
}

public extension Connectable {
    func toDTO(_ httpStatus: Vapor.HTTPStatus = .ok, status: ResponserStatus = .success, message: String? = nil) -> Responser<Self> {
        let response = Responser(httpStatus, status: status, message: message, data: self)
        return response
    }
}
```

## - For ErrorMiddleware

```swift
import ConnectableKit
```

```swift
ConnectableKit.configureErrorMiddleware(app)
```

Error Response Example

Database Error:

```json
{
  "status": "error",
  "message": "server: duplicate key value violates unique constraint \"uq:users.username\" (_bt_check_unique)"
}
```

AbortError:

```swift
guard let profile = try await Profile.query(on: req.db).filter(\.$id == id).first() else {
    throw Abort(.notFound, reason: "User not found in our Database")
}
```

Response

```json
{
  "status": "failure",
  "message": "User not found in our Database"
}
```

If you use `ConnectableKitErrorMiddleware`, don't forget to use before all middleware configureations.

See in Vapor's Documentation [Error Middleware](https://docs.vapor.codes/basics/errors/?h=error#error-middleware)

## - For CORSMiddleware

```swift
import ConnectableKit
```

```swift
ConnectableKit.configureCors(app)
```

func configureCORS

```swift
public static func configureCORS(_ app: Vapor.Application, configuration: Vapor.CORSMiddleware.Configuration? = nil)
```

---

## Inspiration

The [JSend](https://github.com/omniti-labs/jsend) specification, developed by [Omniti Labs](https://github.com/omniti-labs), outlines a consistent JSON response format for API endpoints. I found the specification to be very helpful in ensuring that API consumers can easily understand and parse the responses returned by the API.

As a result, I have heavily borrowed from the JSend specification for the response format used in this project. Specifically, I have adopted the status field to indicate the overall success or failure of the request, as well as the use of a message field to provide additional context for the response.

While I have made some modifications to the response format to suit the specific needs of this project, I am grateful for the clear and thoughtful guidance provided by the JSend specification.

---

## License

ConnectableKit is available under the MIT license. See the LICENSE file for more info.

---
