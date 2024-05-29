
import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import DapperUtilityCoin from 0x82ec283f88a62e65
import ryandapper_NFT from 0xf3e8f8ae2e9e2fec
import MetadataViews from 0x631e88ae7f1d7c20

transaction(sellerAddress: Address, orderUuid: String, price: UFix64, metadata: {String: String}) {
  let gigAuthAccountAddress: Address
  let paymentVault: @FungibleToken.Vault
  let sellerPaymentReceiver: &{FungibleToken.Receiver}
  let balanceBeforeTransfer: UFix64
  let mainDucVault: &DapperUtilityCoin.Vault
      
  prepare(gig: AuthAccount, dapper: AuthAccount, buyer: AuthAccount) {
    self.gigAuthAccountAddress = gig.address
    // If the account doesn't already have a collection
    if buyer.borrow<&ryandapper_NFT.Collection>(from: ryandapper_NFT.CollectionStoragePath) == nil {

        // Create a new empty collection and save it to the account
        buyer.save(<-ryandapper_NFT.createEmptyCollection(), to: ryandapper_NFT.CollectionStoragePath)

        // Create a public capability to the ryandapper_NFT collection
        // that exposes the Collection interface, which now includes
        // the Metadata Resolver to expose Metadata Standard views
        buyer.link<&ryandapper_NFT.Collection{ryandapper_NFT.ryandapper_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
            ryandapper_NFT.CollectionPublicPath,
            target: ryandapper_NFT.CollectionStoragePath
        )
    }
    // If the account already has a ryandapper_NFT collection, but has not yet exposed the 
    // Metadata Resolver interface for the Metadata Standard views
    else if (buyer.getCapability<&ryandapper_NFT.Collection{ryandapper_NFT.ryandapper_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(ryandapper_NFT.CollectionPublicPath).borrow() == nil) {

        // Unlink the current capability exposing the ryandapper_NFT collection,
        // as it needs to be replaced with an updated capability
        buyer.unlink(ryandapper_NFT.CollectionPublicPath)

        // Create the new public capability to the ryandapper_NFT collection
        // that exposes the Collection interface, which now includes
        // the Metadata Resolver to expose Metadata Standard views
        buyer.link<&ryandapper_NFT.Collection{ryandapper_NFT.ryandapper_NFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
            ryandapper_NFT.CollectionPublicPath,
            target: ryandapper_NFT.CollectionStoragePath
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
    self.gigAuthAccountAddress == 0xf3e8f8ae2e9e2fec && sellerAddress == 0x426d9b66c3e3e7b4: "seller must be GigLabs"
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