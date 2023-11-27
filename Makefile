-include .env

.PHONY: all test clean deploy-anvil

all: clean install forge-build hh-build test

# Clean the repo
clean :; forge clean

# Local installation
install :; rm -rf lib && forge install --no-commit --no-git foundry-rs/forge-std && npm i && npx husky install

# CI installation
install-ci :; touch .env; forge install --no-commit --no-git foundry-rs/forge-std; npm ci

# Update Dependencies
forge-update:; forge update

forge-build:; forge build

hh-build :; npx hardhat compile

test :; forge test -vvv

test-e2e :; npx hardhat test

snapshot :; forge snapshot

slither :; slither ./contracts 

format :; npx prettier --write src/**/*.sol && npx prettier --write test/**/*.sol

lint :; npx solhint src/**/*.sol && npx solhint test/**/*.sol

anvil :; anvil -m 'test test test test test test test test test test test junk'

hh-node :; npx hardhat node

abi :; npx hardhat export-abi

deploy :; npx hardhat run deployment

deploy-arbitrum-sepolia :; npx hardhat run --network arbitrum-sepolia deployment

deploy-sepolia :; npx hardhat run --network sepolia deployment

deploy-anvil :; npx hardhat run --network anvil deployment

deploy-localhost :; npx hardhat run --network localhost deployment

-include ${FCT_PLUGIN_PATH}/makefile-external
