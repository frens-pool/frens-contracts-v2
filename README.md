# FRENS smart contracts

## Instalation

Install forge: https://book.getfoundry.sh/getting-started/installation

## running unit tests

forge test --via-ir --fork-url https://mainnet.infura.io/v3/ee9cdb4773b84b42bc893ed870a2c148

## test coverage reports

`forge coverage --report lcov --fork-url https://mainnet.infura.io/v3/ee9cdb4773b84b42bc893ed870a2c148`

`forge coverage --fork-url https://mainnet.infura.io/v3/ee9cdb4773b84b42bc893ed870a2c148`

# Other commands
./deposit new-mnemonic --chain mainnet --eth1_withdrawal_address 0xd119D184628e094322007cEa4F2535Ec3A06E6b1


# Create interfaces

`npx hardhat gen-interface <ContractName>`

