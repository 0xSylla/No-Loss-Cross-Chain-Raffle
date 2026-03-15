-include .env

.PHONY: all clean build test snapshot format anvil deploy

all: clean build test

# Build & compile
build:; forge build
clean:; forge clean
test:; forge test
snapshot:; forge snapshot
format:; forge fmt

# Local node
anvil:; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

# Deploy
deploy-sepolia:
	@forge script script/DeployRaffleScript.s.sol:DeployRaffleScript --rpc-url $(SEPOLIA_RPC_URL) --account defaultKey --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv

deploy-anvil:
	@forge script script/DeployRaffleScript.s.sol:DeployRaffleScript --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

# Install dependencies
install:
	forge install smartcontractkit/chainlink-brownie-contracts --no-commit
	forge install OpenZeppelin/openzeppelin-contracts --no-commit
	forge install transmissions11/solmate --no-commit
	forge install Cyfrin/foundry-devops --no-commit
