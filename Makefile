.PHONY: help validate setup deploy-dev deploy-staging deploy-prod destroy-dev destroy-staging destroy-prod clean

# Default target
help:
	@echo "Azure Microservices Platform - Available Commands"
	@echo "=================================================="
	@echo "  make validate        - Check prerequisites"
	@echo "  make setup          - Initialize Terraform backend"
	@echo "  make deploy-dev     - Deploy development environment"
	@echo "  make deploy-staging - Deploy staging environment"
	@echo "  make deploy-prod    - Deploy production environment"
	@echo "  make destroy-dev    - Destroy development environment"
	@echo "  make destroy-staging- Destroy staging environment"
	@echo "  make destroy-prod   - Destroy production environment"
	@echo "  make clean          - Clean up temporary files"
	@echo ""

# Validate prerequisites
validate:
	@./scripts/validate-prerequisites.sh

# Setup Terraform backend
setup:
	@./scripts/setup-backend.sh

# Deploy environments
deploy-dev:
	@./scripts/deploy.sh dev

deploy-staging:
	@./scripts/deploy.sh staging

deploy-prod:
	@./scripts/deploy.sh production

# Destroy environments
destroy-dev:
	@./scripts/destroy.sh dev

destroy-staging:
	@./scripts/destroy.sh staging

destroy-prod:
	@./scripts/destroy.sh production

# Clean temporary files
clean:
	@echo "Cleaning temporary files..."
	@find . -type f -name "*.tfplan" -delete
	@find . -type f -name "*.tfstate.backup" -delete
	@find . -type f -name "*.retry" -delete
	@find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	@echo "Clean complete!"
