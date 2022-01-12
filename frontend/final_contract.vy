
"""
@title Smart Contract for NFT
@dev Implementation of ERC-721 based Non-Fungible Token.
@author manav
Modified from: https://github.com/vyperlang/vyper/blob/master/examples/tokens/ERC721.vy
"""

from vyper.interfaces import ERC721

implements: ERC721

# Interface for the contract called by safeTransferFrom()
interface ERC721Receiver:
    def onERC721Received(
            _operator: address,
            _from: address,
            _tokenId: uint256,
            _data: Bytes[1024]
        ) -> bytes32: view


# @dev Emits when ownership of any NFT changes by any mechanism. This event emits when NFTs are created (`_sender` == 0) and destroyed (`_receiver` == 0). 
#      Exception: during contract creation, any number of NFTs may be created and assigned without emitting Transfer. 
#      At the time of any transfer, the approved address for that NFT (if any) is reset.
# @param _sender Sender of NFT (if address is zero address it indicates token creation).
# @param _receiver Receiver of NFT (if address is zero address it indicates token destruction).
# @param _tokenId The NFT that got transfered.


event Transfer:
    _sender: indexed(address)
    _receiver: indexed(address)
    _tokenId: indexed(uint256)


# @dev This emits when the approved address for an NFT is changed or reaffirmed. 
#      The zero address indicates there is no approved address. 
#      When a Transfer event emits, this also indicates that the approved address for that NFT (if any) is reset.
# @param _owner Owner of NFT.
# @param _approved Address that is approved.
# @param _tokenId NFT which is approved.


event Approval:
    _owner: indexed(address)
    _approved: indexed(address)
    _tokenId: indexed(uint256)


# @dev This emits when an operator is enabled or disabled for an owner. 
#      The operator can manage all NFTs of the owner.
# @param _owner Owner of NFT.
# @param _operator Address which is given operator rights.
# @param _approved Status of operator rights(True if operator rights are given and false if revoked).


event ApprovalForAll:
    _owner: indexed(address)
    _operator: indexed(address)
    _approved: bool


# @dev This emits when the state of contract is changed.
#      Contract state can ony be changed by owner of the contract.
# @param _contractState State of the contract.


event ContractStateChanged:
    _contractState: bool



# @dev This emits when the mint price for an NFT is changed.
#      Mint price can ony be changed by owner of the contract.
# @param _mintPrice New mint price for the NFT.

event MintPriceChanged:
    _mintPrice: uint256



# @dev Mapping from NFT ID to the address that owns it.
id_to_owner: HashMap[uint256, address]


# @dev Mapping from NFT ID to approved address.
id_to_approved: HashMap[uint256, address]


# @dev Mapping from owner address to count of his tokens.
owner_nft_count: HashMap[address, uint256]

# @dev Mapping from owner address to mapping of operator addresses.
is_approved_for_all: HashMap[address, HashMap[address, bool]]


# @dev Public parameters for identification and authencity of contract.
#      These will be assigned for first and only time in constructor.
# @param Metadata Hash of the object(s) NFT is reffered to.
# @param Owner Owner of the contract
# @param Name Name of the Contract or Token
# @param Symbol Symbol of Token
# @param totalSupply Total Supply of Tokens

metadata: public(String[100])
owner: public(address)
name: public(String[10])
symbol: public(String[10])
totalSupply: public(uint256)
mintPrice: public(uint256)

# @dev Public parameters for functioning of contract.
#      These can be changed by Owner of contract or smart contract itself for security and functioning of contract.
# @param contract_state State of contract. (It can be used to pause the functioning of the contract temporarily or permanently.)
# @param sale_state State of sale functions of contract. (It can be used to pause the functioning of sale functions of the contract temporarily or permanently.)
# @param all_nft_minted Boolean Variable that indicate the wheather or not all the NFTs are minted.
# @param token_counter ID of NFT to be minted next.

contract_state: public(bool)
token_counter: public(uint256)


# @dev Mapping of interface id to bool about whether or not it"s supported
supported_interfaces: HashMap[bytes32, bool]

# @dev ERC165 interface ID of ERC165
ERC165_INTERFACE_ID: constant(bytes32) = 0x0000000000000000000000000000000000000000000000000000000001ffc9a7

# @dev ERC165 interface ID of ERC721
ERC721_INTERFACE_ID: constant(bytes32) = 0x0000000000000000000000000000000000000000000000000000000080ac58cd


@external
def __init__():
    """
    @dev Contract constructor.
         It will assign the public parameter for functioning of the contract for the first time.
    """
    # Adding the supported interfaces of the contract to Mapping
    self.supported_interfaces[ERC165_INTERFACE_ID] = True
    self.supported_interfaces[ERC721_INTERFACE_ID] = True
    # Assigning Owner address
    self.owner = 0xee805f9cAbEc9F161d0a1b79a07F2631b9053487
    # Assigning Metadata of NFT(s)
    self.metadata = "my_metadata.com"
    # Assigning Name of the Token
    self.name = "loki_kitties"
    # Assigning Symbol of the Token
    self.symbol = "LKC"
    # Assigning Total supply of the Token
    self.totalSupply = 999
    # Assigning contract_state to True
    self.contract_state = True
    # Assigning token_counter to 0 to begin the mint of first NFT.
    self.token_counter = 0
    # Assiging price of one NFT
    self.mintPrice = 30000000000000000

### VIEW FUNCTIONS ###


@view
@external
def supportsInterface(_interfaceID: bytes32) -> bool:
    """
    @dev Interface identification is specified in ERC-165.
         Throws if "contract_state" is set to False.
    @param _interfaceID Id of the interface.
    @return bool whether interface is supported or not.
    @notice Check Supported Interfaces
    """
    # Checking contract State
    assert self.contract_state == True
    return self.supported_interfaces[_interfaceID]


@view
@external
def balanceOf(_owner: address) -> uint256:
    """
    @dev Returns the number of NFTs owned by `_owner`.
         Throws if "contract_state" is set to False.
         Throws if `_owner` is the zero address. NFTs assigned to the zero address are considered invalid.
    @param _owner Address for whom to query the balance.
    @notice Returns the number of NFTs owned by address.
    """
    # Checking contract State
    assert self.contract_state == True
    assert _owner != ZERO_ADDRESS
    return self.owner_nft_count[_owner]


@view
@external
def ownerOf(_tokenId: uint256) -> address:
    """
    @dev Returns the address of the owner of the NFT.
         Throws if "contract_state" is set to False.
         Throws if `_tokenId` is not a valid NFT.
    @param _tokenId The identifier for an NFT.
    @notice Returns the address of the owner of the NFT.
    """
    # Checking contract State
    assert self.contract_state == True
    owner: address = self.id_to_owner[_tokenId]
    # Throws if `_tokenId` is not a valid NFT
    assert owner != ZERO_ADDRESS
    return owner


@view
@external
def getApproved(_tokenId: uint256) -> address:
    """
    @dev Get the approved address for a single NFT.
         Throws if "contract_state" is set to False.
         Throws if `_tokenId` is not a valid NFT.
    @param _tokenId ID of the NFT to query the approval of.
    @notice Get the approved address for the NFT.
    """
    # Checking contract State
    assert self.contract_state == True
    # Throws if `_tokenId` is not a valid NFT
    assert self.id_to_owner[_tokenId] != ZERO_ADDRESS
    return self.id_to_approved[_tokenId]


@view
@external
def isApprovedForAll(_owner: address, _operator: address) -> bool:
    """
    @dev Checks if `_operator` is an approved operator for `_owner`.
         Throws if "contract_state" is set to False.
    @param _owner The address that owns the NFTs.
    @param _operator The address that acts on behalf of the owner.
    @notice Checks if `_operator` is an approved operator for `_owner`.
    @return bool whether or not `operator` is an approved operator for `owner`.
    """
    # Checking contract State
    assert self.contract_state == True
    return (self.is_approved_for_all[_owner])[_operator]



### TRANSFER FUNCTION HELPERS (INTERNAL FUNCTIONS) ###
# @dev These functions will not check the contract"s states as they are called after confirming states by external functions.

@view
@internal
def _isApprovedOrOwner(_spender: address, _tokenId: uint256) -> bool:
    """
    @dev Returns whether the given spender can transfer a given token ID.
    @param _spender address of the spender to query.
    @param _tokenId uint256 ID of the token to be transferred.
    @return bool whether the msg.sender is approved for the given token ID, is an operator of the owner, or is the owner of the token.
    """
    _owner: address = self.id_to_owner[_tokenId]
    _spenderIsOwner: bool = _owner == _spender
    _spenderIsApproved: bool = _spender == self.id_to_approved[_tokenId]
    _spenderIsApprovedForAll: bool = (self.is_approved_for_all[_owner])[_spender]
    return (_spenderIsOwner or _spenderIsApproved) or _spenderIsApprovedForAll


@internal
def _addTokenTo(_to: address, _tokenId: uint256):
    """
    @dev Add a NFT to a given address.
         Throws if `_tokenId` is owned by someone.
    """
    assert self.id_to_owner[_tokenId] == ZERO_ADDRESS
    # Change the owner
    self.id_to_owner[_tokenId] = _to
    # Change count tracking
    self.owner_nft_count[_to] += 1


@internal
def _removeTokenFrom(_from: address, _tokenId: uint256):
    """
    @dev Remove a NFT from a given address.
         Throws if `_from` is not the current owner.
    """
    assert self.id_to_owner[_tokenId] == _from
    # Change the owner
    self.id_to_owner[_tokenId] = ZERO_ADDRESS
    # Change count tracking
    self.owner_nft_count[_from] -= 1


@internal
def _clearApproval(_owner: address, _tokenId: uint256):
    """
    @dev Clear an approval of a given address.
         Throws if `_owner` is not the current owner.
    """
    assert self.id_to_owner[_tokenId] == _owner
    if self.id_to_approved[_tokenId] != ZERO_ADDRESS:
        # Reset approvals
        self.id_to_approved[_tokenId] = ZERO_ADDRESS


@internal
def _transferFrom(_from: address, _to: address, _tokenId: uint256, _sender: address):
    """
    @dev Exeute transfer of a NFT.
         Throws unless `msg.sender` is the current owner, an authorized operator, or the approved address for this NFT.
         Throws if `_to` is the zero address.
         Throws if `_from` is not the current owner.
         Throws if `_tokenId` is not a valid NFT.
    """
    # Check requirements
    assert self._isApprovedOrOwner(_sender, _tokenId)
    # Throws if `_to` is the zero address
    assert _to != ZERO_ADDRESS
    # Clear approval. Throws if `_from` is not the current owner
    self._clearApproval(_from, _tokenId)
    # Remove NFT.
    self._removeTokenFrom(_from, _tokenId)
    # Add NFT
    self._addTokenTo(_to, _tokenId)
    # Log the transfer
    log Transfer(_from, _to, _tokenId)


### TRANSFER FUNCTIONS ###
@nonpayable
@external
def transferFrom(_from: address, _to: address, _tokenId: uint256):
    """
    @dev Throws if "contract_state" is set to False.
         Throws unless `msg.sender` is the current owner, an authorized operator, or the approved address for this NFT.
         Throws if `_from` is not the current owner.
         Throws if `_to` is the zero address.
         Throws if `_tokenId` is not a valid NFT.
    @notice This is non-payable function to transfer NFT for free.
            The caller is responsible to confirm that `_to` is capable of receiving NFTs or else they maybe be permanently lost.
    @param _from The current owner of the NFT.
    @param _to The new owner.
    @param _tokenId The NFT to transfer.
    """
    # Checking contract State
    assert self.contract_state == True
    assert _tokenId < self.totalSupply
    self._transferFrom(_from, _to, _tokenId, msg.sender)


@nonpayable
@external
def safeTransferFrom(
        _from: address,
        _to: address,
        _tokenId: uint256,
        _data: Bytes[1024]=b""
    ):
    """
    @dev Transfers the ownership of an NFT from one address to another address.
         Throws if "contract_state" is set to False.
         Throws unless `msg.sender` is the current owner, an authorized operator, or the approved address for this NFT.
         Throws if `_from` is not the current owner.
         Throws if `_to` is the zero address.
         Throws if `_tokenId` is not a valid NFT.
         If `_to` is a smart contract, it calls `onERC721Received` on `_to` and throws if
         the return value is not `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    @notice This is non-payable function to transfer NFT for free.
            Transaction will fail if `_to` is incapable of receiving NFTs.
    @param _from The current owner of the NFT.
    @param _to The new owner.
    @param _tokenId The NFT to transfer.
    @param _data Additional data with no specified format, sent in call to `_to`.
    """
    # Checking contract State
    assert self.contract_state == True
    assert _tokenId < self.totalSupply
    self._transferFrom(_from, _to, _tokenId, msg.sender)
    # Check if `_to` is a contract address
    if _to.is_contract:
        returnValue: bytes32 = ERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data)
        # Throws if transfer destination is a contract which does not implement "onERC721Received"
        assert returnValue == method_id("onERC721Received(address,address,uint256,bytes)", output_type=bytes32)


@nonpayable
@external
def approve(_approved: address, _tokenId: uint256):
    """
    @dev Set or reaffirm the approved address for an NFT. The zero address indicates there is no approved address.
         Throws if "contract_state" is set to False.
         Throws unless `msg.sender` is the current NFT owner, or an authorized operator of the current owner.
         Throws if `_tokenId` is not a valid NFT.
         Throws if `_approved` is the current owner.
    @notice This function will approve the `_approved` for full control over one NFT (`_tokenId`). 
    @param _approved Address to be approved for the given NFT ID.
    @param _tokenId ID of the token to be approved.
    """
    # Checking contract State
    assert self.contract_state == True
    assert _tokenId < self.totalSupply
    _owner: address = self.id_to_owner[_tokenId]
    # Throws if `_tokenId` is not a valid NFT
    assert _owner != ZERO_ADDRESS
    # Throws if `_approved` is the current owner
    assert _approved != _owner
    # Check requirements
    _senderIsOwner: bool = self.id_to_owner[_tokenId] == msg.sender
    _senderIsApprovedForAll: bool = (self.is_approved_for_all[_owner])[msg.sender]
    assert (_senderIsOwner or _senderIsApprovedForAll)
    # Set the approval
    self.id_to_approved[_tokenId] = _approved
    log Approval(_owner, _approved, _tokenId)


@nonpayable
@external
def setApprovalForAll(_operator: address, _approved: bool):
    """
    @dev Enables or disables approval for a third party ("operator") to manage all of `msg.sender`"s assets. It also emits the ApprovalForAll event.
         Throws if `_operator` is the `msg.sender`.
         Throws if "contract_state" is set to False.
    @notice This function will approve the `_operator` for full control over all your NFTs.
            This works even if sender doesn"t own any tokens at the time.
    @param _operator Address to add to the set of authorized operators.
    @param _approved True if the operators is approved, false to revoke approval.
    """
    # Checking contract State
    assert self.contract_state == True
    # Throws if `_operator` is the `msg.sender`
    assert _operator != msg.sender
    self.is_approved_for_all[msg.sender][_operator] = _approved
    log ApprovalForAll(msg.sender, _operator, _approved)



### MINT & BURN FUNCTIONS ###

@payable
@external
def mint() -> bool:
    """
    @dev Function to mint tokens.
         Throws if "contract_state" is set to False.
         Throws if all the NFTs are already minted.
         Throws if `msg.value` is less than mintPrice
    @notice This function can be called to mint a NFT.
    @return bool indicates if the operation was successful.
    """
    # Checking contract states
    assert self.contract_state == True
    # Checks if token_counter has reached maximum number of NFTs
    if (self.token_counter == self.totalSupply):
        assert True==False

    # Check if msg.value is greater than price
    assert msg.value >= self.mintPrice
    # Add NFT. Throws if `_tokenId` is owned by someone
    self._addTokenTo(msg.sender, self.token_counter)
    # Log Transfer
    log Transfer(ZERO_ADDRESS, msg.sender, self.token_counter)
    # Increment Token Counter
    self.token_counter += 1
    return True


@nonpayable
@external
def burn(_tokenId: uint256):
    """
    @dev Burns a specific ERC721 token.
         Throws if "contract_state" is set to False.
         Throws unless `msg.sender` is the current owner, an authorized operator, or the approved address for this NFT.
         Throws if `_tokenId` is not a valid NFT.
    @notice This function will destroy the NFT(`_tokenId`) by sending it to the ZERO_ADDRESS.
    @param _tokenId Id of the ERC721 token to be burned.
    """
    # Checking contract State
    assert self.contract_state == True
    assert _tokenId < self.totalSupply
    # Check requirements
    assert self._isApprovedOrOwner(msg.sender, _tokenId)
    _owner: address = self.id_to_owner[_tokenId]
    assert _owner != ZERO_ADDRESS
    #  Clear Existing Approvals
    self._clearApproval(_owner, _tokenId)
    # Change Owner of NFT to ZERO_ADDRESS
    self._removeTokenFrom(_owner, _tokenId)
    # Log Transfer
    log Transfer(_owner, ZERO_ADDRESS, _tokenId)


@nonpayable
@external
def withdraw(_amount: uint256):
    """
    @dev Withdraw from contract.
         Throws if "contract_state" is set to False.
         Throws if pending amount is 0.
    @notice This function will withdraw your pending amount from the smart contract.
    """
    # Checking contract states
    assert self.contract_state == True
    # Checking if the address is owner
    assert msg.sender == self.owner
    # Checking if amount is valid
    assert _amount != 0
    assert _amount <= self.balance
    # Transfer the value of `msg.sender` back
    send(msg.sender, _amount)


@nonpayable
@external
def changeContractState(_contractState: bool):
    """
    @dev Change the Contract State.
         Throws if `msg.sender` is not the Owner of contract.
    @notice This function can pause the contract.
    """
    assert msg.sender == self.owner
    self.contract_state = _contractState
    # Log
    log ContractStateChanged(_contractState)


@nonpayable
@external
def changeMintPrice(_mintPrice: uint256):
    """
    @dev Change the Mint Price of NFT
         Throws if `msg.sender` is not the Owner of contract.
    @notice This function can pause the sales from the contract.
    """
    assert msg.sender == self.owner
    assert self.contract_state == True
    self.mintPrice = _mintPrice
    # Log
    log MintPriceChanged(_mintPrice)
