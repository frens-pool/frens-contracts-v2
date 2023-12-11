# FRENS smart contracts

## Instalation

Instal forge: https://book.getfoundry.sh/getting-started/installation

## running unit tests

forge test --via-ir --fork-url https://mainnet.infura.io/v3/ee9cdb4773b84b42bc893ed870a2c148

## test coverage reports

`forge coverage --report lcov --fork-url https://mainnet.infura.io/v3/ee9cdb4773b84b42bc893ed870a2c148`

`forge coverage --fork-url https://mainnet.infura.io/v3/ee9cdb4773b84b42bc893ed870a2c148`

# Other commands
./deposit new-mnemonic --chain mainnet --eth1_withdrawal_address 0xd119D184628e094322007cEa4F2535Ec3A06E6b1


##TODO: research/determine functionality for collateralizing the NFT
  -can each pool decide if it can be used for this?
  -what are the requirements for this (only certain operators approved?)
  -liquidation mech (it needs to be able to unstake the whole pool if the collateralization ratio is low)
  -distribution of rewards - this changed how the distribute function should work (or distribute stays the same, but staking becomes an individual vault factory which is interesting and maybe good)
  -additional collateral when staking to pay liquidator?
  -fee paid when withdrawing rewards, but not when paying off debt?
  -allowable collateralization ratio?
  -can the contract know if the validator has been slashed???


# Create interfaces

`npx hardhat gen-interface <ContractName>`

