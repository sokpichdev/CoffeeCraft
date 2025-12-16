# CoffeeCraft — Firestore & Firebase Schema Reference

This document summarizes all Firebase-related data used by the CoffeeCraft app (Firestore + Auth). It extracts collection names, document shapes, model mappings (Swift types), example documents, uncertainties, and concrete validation steps you can run against your Firebase project or emulator.

Last scan: 2025-12-16

---

## TL;DR
- Collections used: `users`, `products`, `carts`, `orders`.
- Auth: Email/password (Firebase Auth). The app uses `Auth.auth().currentUser?.uid` as the primary user identifier.
- Storage: No Firebase Storage usage found — product images are external URLs (postimg.cc).

---

## Files that touch Firebase
(Primary files inside `CoffeeCraft/CoffeeCraft`)

- `CoffeeCraftApp.swift` — calls `FirebaseApp.configure()`
- `Module/Auth/ViewModel/AuthViewModel.swift` — imports `FirebaseAuth`, `FirebaseFirestore`; uses collection `users` and Auth APIs (createUser, signIn, signOut, sendPasswordReset)
- `Module/Menu/Product/ViewModel/ProductViewModel.swift` — reads/writes collection `products` (getDocuments, addDocument, setData, delete, updateData)
- `Module/Firebase/ProductSeeder.swift` — seeds `products` collection with sample documents (gives canonical fields/values)
- `Module/Cart/ViewModel/CartManager.swift` — reads/writes `carts` collection; stores cart by document id = `userId` and encodes `CartItem` via `Firestore.Encoder/Decoder`
- `Module/Firebase/OrderService.swift` — writes to `orders` (placeOrder) and uses `Auth.auth().currentUser?.uid` and `Timestamp`
- `Module/Order/ViewModel/OrderViewModel.swift` — queries `orders` for current user
- `Module/Order/ViewModel/AdminOrdersViewModel.swift` — listens to `orders` collection and updates order status
- `Module/Main/RootView.swift` — reads `Auth.auth().currentUser?.uid` when constructing `CartManager`

> Note: A workspace-wide scan also found other projects that use Firebase (OneNews, etc.), but this document focuses on the `CoffeeCraft` app.

---

## Swift model mappings (extracted)
These structs/classes are defined in the project and map to Firestore documents (directly or indirectly):

- Product (`Module/Menu/Product/Model/Product.swift`)
- id: String
- name: String
- description: String
- price: Double
- imageURL: String
- category: String
- available: Bool
- customizations: [String: [String: Double]]?  (optional map of category → option → price)

- User (`Module/Auth/Model/UserRole.swift`)
- id: String
- name: String
- email: String
- role: UserRole (`"customer"` | `"manager"`)

- CartItem (`Module/Cart/Model/CartItem.swift`) — encoded with `Firestore.Encoder`
- id: UUID (encoded as string)
- product: Product (nested)
- selections: [String: String]
- extras: [String]
- totalPrice: computed locally (not stored as a field by the app)

- Order (`Module/Order/Model/Order.swift`)
- @DocumentID id: String? (Firestore doc id)
- userId: String
- items: [CartItemData]
- totalPrice: Double
- status: String
- timestamp: Date (stored in Firestore as `Timestamp`)

- CartItemData (lightweight order item)
- name: String
- selections: [String: String]? (optional)
- extras: [String]? (optional)
- price: Double

---

## Canonical Firestore schema (collection-by-collection)

### 1) `users` (document id: user uid)
- name: String (required — `AuthViewModel` expects it)
- email: String (required)
- role: String (`"customer"` | `"manager"`) (required)

Notes:
- `AuthViewModel.fetchUserData` reads `name`, `email`, and `role` and constructs the `User` model. Treat these fields as required for correct app behavior.

Example document (JSON)
```
/users/<UID>
{
"name": "Jane Doe",
"email": "jane@example.com",
"role": "customer"
}
```

---

### 2) `products` (document id: productId)
Fields used by the app (inferred types):
- name: String
- description: String
- price: Double
- imageURL: String (URL string)
- category: String
- available: Bool
- customizations: Map<String, Map<String, Double>> (optional)

Notes:
- `ProductSeeder` provides many sample products matching this structure. `ProductViewModel` provides defaults when fields are missing (e.g., price -> 0.0, description -> "", available -> true).

Example document (JSON)
```
/products/<PRODUCT_ID>
{
"name": "Cappuccino",
"description": "A classic Italian coffee with steamed milk foam.",
"price": 3.5,
"imageURL": "https://i.postimg.cc/VNK61H8p/capp.jpg",
"category": "Coffee",
"available": true,
"customizations": {
"Size": { "Small": 0.0, "Medium": 0.5, "Large": 1.0 },
"Milk": { "Whole": 0.0, "Oat": 0.5 }
}
}
```

---

### 3) `carts` (document id: userId)
- items: Array<CartItem> (stored via `Firestore.Encoder`)

CartItem shape (encoded) roughly corresponds to the Swift `CartItem`:
- id: String (UUID)
- product: Product (embedded sub-object with product fields)
- selections: { String: String }
- extras: [String]

Notes:
- `CartManager` writes `db.collection("carts").document(userId).setData(["items": data])` where `data` is `try items.map { try Firestore.Encoder().encode($0) }`.
- `CartManager.loadCartFromFirestore` expects `items` to be an array of dictionaries (`[[String: Any]]`) and decodes them with `Firestore.Decoder().decode(CartItem.self, from: $0)`.
- Because encoding/decoding is used, the cart documents will mirror the Swift types (including nested `product`).

Example document (JSON-ish)
```
/carts/<UID>
{
"items": [
{ "id": "...", "product": { "id": "...", "name": "Espresso", "price": 2.0, ... }, "selections": { "Size": "Small" }, "extras": [] }
]
}
```

---

### 4) `orders` (document id: generated by Firestore)
Fields written by `OrderService.placeOrder`:
- userId: String (Auth UID)
- timestamp: Timestamp
- totalPrice: Double
- status: String (ex: `"Pending"`)
- items: Array of lightweight item dictionaries
- Each item: { name: String, price: Double, selections?: {String:String}, extras?: [String] }

Notes:
- `Order` model expects `timestamp` to decode to `Date` (Firestore will store `Timestamp`).
- `AdminOrdersViewModel` decodes docs using `try? doc.data(as: Order.self)` so all Order fields should be present for a successful decode.

Example document (JSON)
```
/orders/<ORDER_ID>
{
"userId": "UID",
"timestamp": <Firestore Timestamp>,
"totalPrice": 12.00,
"status": "Pending",
"items": [ { "name": "Cappuccino", "price": 3.5, "selections": {"Size":"Large"}, "extras": ["Whip"] } ]
}
```

---

## Firebase Storage
No usage of `Storage.storage()` or `FirebaseStorage` was found in the CoffeeCraft codebase. Product images are stored as external URLs (see `ProductSeeder`). If you plan to allow image uploads from the app in the future, you'll need to add Storage usage and update rules and upload paths.

---

## Firebase Auth usage summary
- The app uses Firebase Email/Password auth via `Auth.auth()` APIs (createUser, signIn, sendPasswordReset, signOut).
- The app stores/reads Firestore `users` documents under document id = `user.uid` and reads `uid` for carts and orders to tie data to a user.

---

## Known mismatch / design notes
- `CartManager` stores a full `CartItem` (including nested `Product`) via `Firestore.Encoder`.
- `OrderService` converts cart items into lightweight dictionaries (only `name`, `price`, `selections`, `extras`) when placing orders. This is intentional (orders store snapshot info rather than full product object) but keep in mind the two structures differ.
- `Product.customizations` is a nested map (`[String: [String: Double]]`). Ensure Firestore documents store this as a Map (not serialized JSON string) so `as?` casts succeed.

---

## Uncertainties / TODOs (manual verification required)
1. Verify that live `products` documents in your Firestore project exactly match the `Product` fields (especially `customizations` being a Map).
2. Confirm whether any cart/ order documents already exist that were saved with a different shape (older app versions). If so, add migration code or tolerant decoders.
3. Confirm which `GoogleService-Info.plist` is used for the environment you intend to test (dev vs prod).
4. If you later add image uploads, plan Storage bucket names, upload path templates, and security rules.

---

## Concrete validation steps (quick checklist)
1. Identify Firebase project (which `GoogleService-Info.plist` is active in Xcode).
2. In Firebase Console > Firestore, inspect the following collections & sample documents:
- `users/<UID>` — confirm `name`, `email`, `role` fields exist
- `products/<PRODUCT_ID>` — confirm `price` is numeric, `customizations` is a Map, and `imageURL` is a URL string
- `carts/<UID>` — inspect `items` array, ensure each item contains nested product data as expected
- `orders/<ORDER_ID>` — confirm `timestamp` is a Timestamp and `items` entries follow the lightweight shape
3. Run the app flows:
- Sign up a new user as `customer`, verify `users/<UID>` created with expected fields
- Add products to cart (while logged in), confirm `carts/<UID>` is created/updated
- Place an order, confirm `orders/<ORDER_ID>` is created with `userId`, `timestamp`, `totalPrice`, `items`, and `status`

---

## Example Firestore console queries
(Use these in the Firebase console or in a script)

- List recent orders for a user (JavaScript/firestore client):
```js
db.collection('orders').where('userId', '==', '<UID>').orderBy('timestamp', 'desc')
```

- Inspect a product in the console:
```js
db.collection('products').doc('<PRODUCT_ID>').get()
```

- Inspect a user's cart:
```js
db.collection('carts').doc('<UID>').get()
```

---

## Suggested low-risk improvements
- Centralize collection names into constants (e.g., `struct FirestoreCollections { static let users = "users" }`) and refactor usages to avoid typos.
- Add a small `docs/firestore-schema.md` (this file) to the repo (done) and keep it updated when model fields change.
- Add tolerant decoding for older data shapes (use optional fields and fallback values where appropriate).
- Add unit/integration tests using the Firebase Emulator to validate flows (signup, add-to-cart, place-order) without touching production data.

---

## Want me to also:
- [ ] Add a constants file and refactor collection string literals to use it (low-risk)
- [ ] Add a Swift unit/integration test that runs against the Firebase Emulator (requires adding dev dependencies)
- [ ] Generate a small migration utility for older cart/order document shapes

Tell me which one(s) and I'll implement them next.

---

End of document.
