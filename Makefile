-include .env

.PHONY: all test clean deploy-anvil

all: clean install update build

# Clean the repo
clean :; forge clean

# Remove modules

install :; rm -rf lib && forge install --no-commit --no-git foundry-rs/forge-std && yarn && npx husky install

# Update Dependencies
update:; forge update && yarn

build:; forge build

test :; forge test 

snapshot :; forge snapshot

slither :; slither ./src 

format :; npx prettier --write src/**/*.sol && npx prettier --write src/**/*.sol

lint :; npx solhint src/**/*.sol && npx solhint script/**/*.sol

anvil :; anvil -m 'test test test test test test test test test test test junk'

# use the "@" to hide the command from your shell 
deploy-sepolia :; @forge script script/${contract}.s.sol:Deploy${contract} --rpc-url ${SEPOLIA_RPC_URL}  --private-key ${PRIVATE_KEY} --broadcast --verify --etherscan-api-key ${ETHERSCAN_API_KEY}  -vvvv

# This is the private key of account from the mnemonic from the "make anvil" command
deploy-anvil :; @forge script script/${contract}.s.sol:Deploy${contract} --rpc-url http://localhost:8545  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast 

deploy-all :; make deploy-${network} contract=APIConsumer && make deploy-${network} contract=KeepersCounter && make deploy-${network} contract=PriceFeedConsumer && make deploy-${network} contract=VRFConsumerV2

-include ${FCT_PLUGIN_PATH}/makefile-external
