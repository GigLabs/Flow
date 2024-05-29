import NonFungibleToken from 0x631e88ae7f1d7c20
import DapPen_NFT from 0x1df9c41532276279

// This transaction is for transferring an NFT from 
// one account to another

transaction(recipient: Address, withdrawID: UInt64) {
    // local variable for storing the transferred token
    let nft: @NonFungibleToken.NFT

    prepare(acct: AuthAccount) {
        // borrow a reference to the signer's NFT collection
        let collectionRef = acct.borrow<&DapPen_NFT.Collection>(from: DapPen_NFT.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")

        // withdraw the NFT from the owner's collection
        self.nft <- collectionRef.withdraw(withdrawID: withdrawID)
    }

    execute {
        // get the recipients public account object
        let recipientAccount = getAccount(recipient)

        // borrow a public reference to the receivers collection
        let depositRef = recipientAccount.getCapability(DapPen_NFT.CollectionPublicPath)!.borrow<&{DapPen_NFT.DapPen_NFTCollectionPublic}>()!

        // Deposit the NFT in the recipient's collection
        depositRef.deposit(token: <-self.nft)
    }
}