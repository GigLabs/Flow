
import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import DapperUtilityCoin from 0x82ec283f88a62e65
import dapperrelease2point0_NFT from 0xd0c7d5711cb0dc51
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
    if buyer.storage.borrow<&dapperrelease2point0_NFT.Collection>(from: dapperrelease2point0_NFT.CollectionStoragePath) == nil {

        // Create a new empty collection and save it to the account
        buyer.storage.save(<-dapperrelease2point0_NFT.createEmptyCollection(nftType: Type<@dapperrelease2point0_NFT.NFT>()), to: dapperrelease2point0_NFT.CollectionStoragePath)

        // Publish a public capability for the collection
        buyer.capabilities.unpublish(dapperrelease2point0_NFT.CollectionPublicPath)
        let collectionCap = buyer.capabilities.storage.issue<&dapperrelease2point0_NFT.Collection>(dapperrelease2point0_NFT.CollectionStoragePath)
        buyer.capabilities.publish(collectionCap, at: dapperrelease2point0_NFT.CollectionPublicPath)
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
    self.gigAuthAccountAddress == 0xd0c7d5711cb0dc51 && sellerAddress == 0x6f8aa41eedff1158: "seller must be GigLabs"
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