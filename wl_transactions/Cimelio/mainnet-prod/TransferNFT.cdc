import NonFungibleToken from 0x1d7e57aa55817448
import Cimelio_NFT from 0x2c9de937c319468d

// This transaction is for transferring an NFT from 
// one account to another

transaction(recipient: Address, withdrawID: UInt64) {
    // local variable for storing the transferred token
    let nft: @NonFungibleToken.NFT

    prepare(acct: AuthAccount) {
        // borrow a reference to the signer's NFT collection
        let collectionRef = acct.borrow<&Cimelio_NFT.Collection>(from: Cimelio_NFT.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")

        // withdraw the NFT from the owner's collection
        self.nft <- collectionRef.withdraw(withdrawID: withdrawID)
    }

    execute {
        // get the recipients public account object
        let recipientAccount = getAccount(recipient)

        // borrow a public reference to the receivers collection
        let depositRef = recipientAccount.getCapability(Cimelio_NFT.CollectionPublicPath)!.borrow<&{Cimelio_NFT.Cimelio_NFTCollectionPublic}>()!

        // Deposit the NFT in the recipient's collection
        depositRef.deposit(token: <-self.nft)
    }
}