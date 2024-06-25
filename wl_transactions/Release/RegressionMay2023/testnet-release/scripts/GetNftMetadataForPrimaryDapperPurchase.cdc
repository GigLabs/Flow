
// Get metadata for a single NFT in a owner's collection
// needed to display the NFT in dapper wallet
// during the primary purchase of an NFT
pub struct PurchaseData {
  pub let id: UInt64
  pub let name: String?
  pub let amount: UFix64
  pub let description: String?
  pub let imageURL: String?

  init(id: UInt64, name: String?, amount: UFix64, description: String?, imageURL: String?) {
      self.id = id
      self.name = name
      self.amount = amount
      self.description = description
      self.imageURL = imageURL
  }
}

pub fun main(sellerAddress: Address, nftIDs: [UInt64], price: UFix64, metadata: {String: String}): PurchaseData {
  var idList: String = ""

  for nftID in nftIDs {
    idList = idList.concat(nftID.toString()).concat(" ")
  }
  return PurchaseData(
      id: 0,
      name: metadata["name"],
      amount: price,
      description: metadata["description"],
      imageURL: metadata["imageUrl"],
  )
}
