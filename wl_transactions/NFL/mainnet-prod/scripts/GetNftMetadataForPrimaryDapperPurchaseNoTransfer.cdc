
// Get metadata for a single NFT in a owner's collection
// needed to display the NFT in dapper wallet
// during the primary purchase of an NFT
// token ids are not included in txn arguments
access(all) struct PurchaseData {
  access(all) let id: UInt64
  access(all) let name: String?
  access(all) let amount: UFix64
  access(all) let description: String?
  access(all) let imageURL: String?

  init(id: UInt64, name: String?, amount: UFix64, description: String?, imageURL: String?) {
      self.id = id
      self.name = name
      self.amount = amount
      self.description = description
      self.imageURL = imageURL
  }
}

access(all) fun main(sellerAddress: Address, orderUuid: String, price: UFix64, metadata: {String: String}): PurchaseData {
  return PurchaseData(
      id: 0,
      name: metadata["name"],
      amount: price,
      description: metadata["description"],
      imageURL: metadata["imageUrl"],
  )
}
