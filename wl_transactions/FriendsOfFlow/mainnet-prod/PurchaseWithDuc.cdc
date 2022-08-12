import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import DapperUtilityCoin from 0xead892083b3e2c6c
import FriendsOfFlow_NFT from 0xcee3d6cc34301ad1

transaction(sellerAddress: Address, nftIDs: [UInt64], price: UFix64, metadata: {String: String}) {
  let gigAuthAccountAddress: Address
  let paymentVault: @FungibleToken.Vault
  let sellerPaymentReceiver: &{FungibleToken.Receiver}
  let balanceBeforeTransfer: UFix64
  let mainDucVault: &DapperUtilityCoin.Vault
      
  prepare(gig: AuthAccount, dapper: AuthAccount, buyer: AuthAccount) {
    self.gigAuthAccountAddress = gig.address
    // If the account doesn't already have a collection
    if buyer.borrow<&FriendsOfFlow_NFT.Collection>(from: FriendsOfFlow_NFT.CollectionStoragePath) == nil {
        // Create a new empty collection and save it to the account
        buyer.save(<-FriendsOfFlow_NFT.createEmptyCollection(), to: FriendsOfFlow_NFT.CollectionStoragePath)
        // Create a public capability to the FriendsOfFlow_NFT collection
        // that exposes the Collection interface
        buyer.link<&FriendsOfFlow_NFT.Collection{NonFungibleToken.CollectionPublic,FriendsOfFlow_NFT.FriendsOfFlow_NFTCollectionPublic}>(
            FriendsOfFlow_NFT.CollectionPublicPath,
            target: FriendsOfFlow_NFT.CollectionStoragePath
        )
    }
    
    // withdraw DUC
    self.mainDucVault = dapper.borrow<&DapperUtilityCoin.Vault>(from: /storage/dapperUtilityCoinVault)
        ?? panic("Could not borrow reference to Dapper Utility Coin vault")
    self.balanceBeforeTransfer = self.mainDucVault.balance
    self.paymentVault <- self.mainDucVault.withdraw(amount: price)
    // set seller DUC receiver ref
    self.sellerPaymentReceiver = getAccount(sellerAddress).getCapability(/public/dapperUtilityCoinReceiver)
    .borrow<&{FungibleToken.Receiver}>()
    ?? panic("Could not borrow receiver reference to the recipient's Vault")
  }
  pre {
    // Make sure the seller is the right account
    self.gigAuthAccountAddress == 0xcee3d6cc34301ad1 && sellerAddress == 0xb82ba4137573164c: "seller must be GigLabs"
  }
  execute {
    self.sellerPaymentReceiver.deposit(from: <- self.paymentVault)
  }
  post {
    // Ensure there is no DUC leakage
    self.mainDucVault.balance == self.balanceBeforeTransfer:
        "transaction would leak DUC"
  }
}