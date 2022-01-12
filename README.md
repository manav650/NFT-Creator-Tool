# NFT Creator Tool
This tool is created a help an average person to launch their own NFT collection in form of smart contracts over blockchain without getting into complex coding.
Not everybody knows how to code and this project was created bearing in mind that simple fact.



## How it works
On the frontend, user needs to connect its metamask wallet and fill out the basic yet interactive form in webpage specifying his/her/their needs and specification from the smart contract.(eg. name, metadata, totalSupply, mintPrice, marketplace).

Then, a file named "final_contract.vy" will be outputed or deployed to the selected network.



## Mechanics
Apart from basic functions, user can choose if they need their smart contract to have an incorporated marketplace.(Bid, offer, buy and sell functioning of tokens withing the contract.)

This creates two versions of smart contracts
1. NFT - just the basic functionality of a Non-Fungible-Token
2. NFT_v2 - An incorporated marketplace functioning within the smart contract.



## Deployment
Both the version of the smart contracts have been deployed on ONE chain(testnet) seperately.

Here are the hyperlinks to both -
1. NFT - https://explorer.pops.one/address/0xcd76869bcf9186db3accbb3c53ca7252697bad5a
2. NFT_v2 - https://explorer.pops.one/address/0x9bbb09629048f8eae02825729a67cd7285e15505



## Mechanics of smart contracts
Both the smart contracts are written in vyper to ensure better security and reduction in risks pertaining to solidity.
Both the contracts implement ERC721 have been tested thoroughly to overcome any breach in security of code.



## Future scope
I will be continuing this project further to improve selection of choices and include more functionalities such as
1. Uploading of NFTs(eg. images, music) to IPFS decentralized server.
2. Interactive UI for marketplace functionalities.
