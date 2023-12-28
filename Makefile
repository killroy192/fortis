-include .env

.PHONY: all test clean install compile snapshot 

all: clean install test

# Clean the repo
clean :; forge clean

# Local installation
install :; npm i && npx husky install

# CI installation
install-ci :; touch .env; npm ci

# Update Dependencies
forge-update:; forge update

compile :; npx hardhat compile

test :; forge test -vvv; npx hardhat test

snapshot :; forge snapshot

format :; forge fmt src/; forge fmt test/

lint :; npx solhint src/**/*.sol

node :; npx hardhat node

network?=hardhat

deploy :; npx hardhat --network $(network) deploy-bundle

amount?=1
oracle?=Oracle

refund :; npx hardhat --network $(network) refund --amount $(amount) --oracle $(oracle)

onRegister :; npx hardhat --network $(network) onRegister --id $(id) --oracle $(oracle)

eth?=0.001

trade-demo :;  npx hardhat --network $(network) demo:trade --amount $(eth)

migrate-demo :; npx hardhat --network $(network) demo:migrate

-include ${FCT_PLUGIN_PATH}/makefile-external
