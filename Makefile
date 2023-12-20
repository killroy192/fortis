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

snapshot :; forge snapshot

slither :; slither ./src 

format :; npx prettier --write src/**/*.sol

lint :; npx solhint src/**/*.sol

hh-node :; npx hardhat node

abi :; npx hardhat export-abi

network?=hardhat

deploy :; npx hardhat --network $(network) deploy-bundle

deploy-demo :; npx hardhat --network $(network) demo:deploy

amount?=1
oracle?=Oracle

refund :; npx hardhat --network $(network) refund --amount $(amount) --oracle $(oracle)

refund-demo :; npx hardhat --network $(network) refund --amount $(amount) --oracle FakedOracle

onRegister :; npx hardhat --network $(network) onRegister --id $(id) --oracle $(oracle)

onRegister-demo :; npx hardhat --network $(network) onRegister --id $(id) --oracle FakedOracle

eth?=0.001

trade-demo :;  npx hardhat --network $(network) demo:trade --amount $(eth)

-include ${FCT_PLUGIN_PATH}/makefile-external
