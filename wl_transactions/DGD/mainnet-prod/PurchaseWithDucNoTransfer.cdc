
import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import DapperUtilityCoin from 0xead892083b3e2c6c
import DGD_NFT from 0x329feb3ab062d289
import MetadataViews from 0x1d7e57aa55817448

transaction(sellerAddress: Address, orderUuid: String, price: UFix64, metadata: {String: String}) {
  let gigAuthAccountAddress: Address
  let paymentVault: @{FungibleToken.Vault}
  let sellerPaymentReceiver: &{FungibleToken.Receiver}
  let balanceBeforeTransfer: UFix64
  let mainDucVault: auth(FungibleToken.Withdraw) &DapperUtilityCoin.Vault
      
  prepare(
    gig: &Account,
    dapper: auth(BorrowValue) &Account,
    buyer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account
  ) {
    self.gigAuthAccountAddress = gig.address

    // Initialize the buyer's collection if they do not already have one
    if buyer.storage.borrow<&DGD_NFT.Collection>(from: DGD_NFT.CollectionStoragePath) == nil {

        // Create a new empty collection and save it to the account
        buyer.storage.save(<-DGD_NFT.createEmptyCollection(nftType: Type<@DGD_NFT.NFT>()), to: DGD_NFT.CollectionStoragePath)

        // Publish a public capability for the collection
        buyer.capabilities.unpublish(DGD_NFT.CollectionPublicPath)
        let collectionCap = buyer.capabilities.storage.issue<&DGD_NFT.Collection>(DGD_NFT.CollectionStoragePath)
        buyer.capabilities.publish(collectionCap, at: DGD_NFT.CollectionPublicPath)
    }
    
    // withdraw DUC
    self.mainDucVault = dapper.storage.borrow<auth(FungibleToken.Withdraw) &DapperUtilityCoin.Vault>(from: /storage/dapperUtilityCoinVault)
        ?? panic("Could not borrow reference to Dapper Utility Coin vault")
    self.balanceBeforeTransfer = self.mainDucVault.balance
    self.paymentVault <- self.mainDucVault.withdraw(amount: price)
    // set seller DUC receiver ref
    self.sellerPaymentReceiver = getAccount(sellerAddress).capabilities.borrow<&{FungibleToken.Receiver}>(/public/dapperUtilityCoinReceiver)
    ?? panic("Could not borrow receiver reference to the recipient's DapperUtilityCoin vault")
  }
  pre {
    // Make sure the seller is the right account
    self.gigAuthAccountAddress == 0x329feb3ab062d289 && sellerAddress == 0xeae068e55f902d0d: "seller must be GigLabs"
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