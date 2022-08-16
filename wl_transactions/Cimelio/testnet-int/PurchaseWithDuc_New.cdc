import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import DapperUtilityCoin from 0x82ec283f88a62e65
import cimelio_NFT from 0x04625c28593d9408
import MetadataViews from 0x631e88ae7f1d7c20

transaction(sellerAddress: Address, nftIDs: [UInt64], price: UFix64, metadata: {String: String}) {
  let gigAuthAccountAddress: Address
  let paymentVault: @FungibleToken.Vault
  let sellerPaymentReceiver: &{FungibleToken.Receiver}
  let balanceBeforeTransfer: UFix64
  let mainDucVault: &DapperUtilityCoin.Vault
      
  prepare(gig: AuthAccount, dapper: AuthAccount, buyer: AuthAccount) {
    self.gigAuthAccountAddress = gig.address
    // If the account doesn't already have a collection
    if buyer.borrow<&cimelio_NFT.Collection>(from: cimelio_NFT.CollectionStoragePath) == nil {

        // Create a new empty collection and save it to the account
        buyer.save(<-cimelio_NFT.createEmptyCollection(), to: cimelio_NFT.CollectionStoragePath)

        // Create a public capability to the cimelio_NFT collection
        // that exposes the Collection interface, which now includes
        // the Metadata Resolver to expose Metadata Standard views
        buyer.link<&cimelio_NFT.Collection{NonFungibleToken.CollectionPublic,cimelio_NFT.cimelio_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
            cimelio_NFT.CollectionPublicPath,
            target: cimelio_NFT.CollectionStoragePath
        )
    }
    // If the account already has a cimelio_NFT collection, but has not yet exposed the 
    // Metadata Resolver interface for the Metadata Standard views
    else if !buyer.getCapability<&cimelio_NFT.Collection{NonFungibleToken.CollectionPublic,cimelio_NFT.cimelio_NFTCollectionPublic,MetadataViews.ResolverCollection}>
        (cimelio_NFT.CollectionPublicPath)!.check() { 

        // Unlink the current capability exposing the cimelio_NFT collection,
        // as it needs to be replaced with an updated capability
        buyer.unlink(cimelio_NFT.CollectionPublicPath)

        // Create the new public capability to the cimelio_NFT collection
        // that exposes the Collection interface, which now includes
        // the Metadata Resolver to expose Metadata Standard views
        buyer.link<&cimelio_NFT.Collection{NonFungibleToken.CollectionPublic,cimelio_NFT.cimelio_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
            cimelio_NFT.CollectionPublicPath,
            target: cimelio_NFT.CollectionStoragePath
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
    self.gigAuthAccountAddress == 0x04625c28593d9408 && sellerAddress == 0xd86a40823544201d: "seller must be GigLabs"
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