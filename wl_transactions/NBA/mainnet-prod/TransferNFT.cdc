import NonFungibleToken from 0x1d7e57aa55817448
import NBA_NFT from 0x54317f5ad2f47ad3

// This transaction is for transferring an NFT from 
// one account to another

transaction(recipient: Address, withdrawID: UInt64) {
    // local variable for storing the transferred token
    let nft: @NonFungibleToken.NFT

    prepare(acct: AuthAccount) {
        // borrow a reference to the signer's NFT collection
        let collectionRef = acct.borrow<&NBA_NFT.Collection>(from: NBA_NFT.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")

        // withdraw the NFT from the owner's collection
        self.nft <- collectionRef.withdraw(withdrawID: withdrawID)
    }

    execute {
        // get the recipients public account object
        let recipientAccount = getAccount(recipient)

        // borrow a public reference to the receivers collection
        let depositRef = recipientAccount.getCapability(NBA_NFT.CollectionPublicPath)!.borrow<&{NBA_NFT.NBA_NFTCollectionPublic}>()!

        // Deposit the NFT in the recipient's collection
        depositRef.deposit(token: <-self.nft)
    }
}