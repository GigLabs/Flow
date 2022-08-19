import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import DapperUtilityCoin from 0x82ec283f88a62e65
import nba_NFT from 0x04625c28593d9408
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
    if buyer.borrow<&nba_NFT.Collection>(from: nba_NFT.CollectionStoragePath) == nil {

        // Create a new empty collection and save it to the account
        buyer.save(<-nba_NFT.createEmptyCollection(), to: nba_NFT.CollectionStoragePath)

        // Create a public capability to the nba_NFT collection
        // that exposes the Collection interface, which now includes
        // the Metadata Resolver to expose Metadata Standard views
        buyer.link<&nba_NFT.Collection{NonFungibleToken.CollectionPublic,nba_NFT.nba_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
            nba_NFT.CollectionPublicPath,
            target: nba_NFT.CollectionStoragePath
        )
    }
    // If the account already has a nba_NFT collection, but has not yet exposed the 
    // Metadata Resolver interface for the Metadata Standard views
    else if (signer.getCapability<&nba_NFT.Collection{NonFungibleToken.CollectionPublic,nba_NFT.nba_NFTCollectionPublic,MetadataViews.ResolverCollection}>(nba_NFT.CollectionPublicPath).borrow() == nil) {

        // Unlink the current capability exposing the nba_NFT collection,
        // as it needs to be replaced with an updated capability
        buyer.unlink(nba_NFT.CollectionPublicPath)

        // Create the new public capability to the nba_NFT collection
        // that exposes the Collection interface, which now includes
        // the Metadata Resolver to expose Metadata Standard views
        buyer.link<&nba_NFT.Collection{NonFungibleToken.CollectionPublic,nba_NFT.nba_NFTCollectionPublic,MetadataViews.ResolverCollection}>(
            nba_NFT.CollectionPublicPath,
            target: nba_NFT.CollectionStoragePath
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
    self.gigAuthAccountAddress == 0x04625c28593d9408 && sellerAddress == 0x05a563afe7729560: "seller must be GigLabs"
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