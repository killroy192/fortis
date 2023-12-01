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

slither :; slither ./src 

format :; npx prettier --write src/**/*.sol

lint :; npx solhint src/**/*.sol

anvil :; anvil -m 'test test test test test test test test test test test junk'

hh-node :; npx hardhat node

abi :; npx hardhat export-abi

network?=hardhat

deploy :; npx hardhat run --network $(network) scripts/deployment/$(network)

run-e2e :; npx hardhat run --network $(network) scripts/e2e/trigger.js

-include ${FCT_PLUGIN_PATH}/makefile-external
