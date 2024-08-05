
import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import DapperUtilityCoin from 0x82ec283f88a62e65
import ufcInt_NFT from 0x04625c28593d9408
import MetadataViews from 0x631e88ae7f1d7c20

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
    if buyer.storage.borrow<&ufcInt_NFT.Collection>(from: ufcInt_NFT.CollectionStoragePath) == nil {

        // Create a new empty collection and save it to the account
        buyer.storage.save(<-ufcInt_NFT.createEmptyCollection(nftType: Type<@ufcInt_NFT.NFT>()), to: ufcInt_NFT.CollectionStoragePath)

        // Publish a public capability for the collection
        buyer.capabilities.unpublish(ufcInt_NFT.CollectionPublicPath)
        let collectionCap = buyer.capabilities.storage.issue<&ufcInt_NFT.Collection>(ufcInt_NFT.CollectionStoragePath)
        buyer.capabilities.publish(collectionCap, at: ufcInt_NFT.CollectionPublicPath)
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
    self.gigAuthAccountAddress == 0x04625c28593d9408 && sellerAddress == 0x426d9b66c3e3e7b4: "seller must be GigLabs"
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