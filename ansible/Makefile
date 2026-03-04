# Infrastructure Ansible Makefile
# Usage: make <target> ENV=<environment> APP=<application> SVC=<service>
# Example: make ansible-ping ENV=uat APP=myapp SVC=postgresql

.PHONY: help venv ansible-site k8s-reset k8s-prepare k8s-deploy k8s-post deploy-all lint

# Default values
ENV ?= uat
APP ?= devops
SVC ?= k8s

# Unified inventory for full app deployment (uses hosts.yaml directly under app)
APP_INVENTORY := inventories/$(ENV)/$(APP)/hosts.yaml

# Paths
INVENTORY := inventories/$(ENV)/$(APP)/$(SVC)/hosts.yaml
KUBESPRAY_DIR := kubespray
PLAYBOOKS_DIR := playbooks

# Colors
GREEN := \033[0;32m
YELLOW := \033[0;33m
NC := \033[0m

help: ## Show this help
	@echo "$(GREEN)Ansible Infrastructure Makefile$(NC)"
	@echo ""
	@echo "$(YELLOW)Usage:$(NC) make <target> ENV=<env> APP=<app> SVC=<service>"
	@echo ""
	@echo "$(YELLOW)Examples:$(NC)"
	@echo "  make ansible-ping ENV=uat APP=myapp SVC=postgresql"
	@echo "  make k8s-deploy ENV=uat APP=devops SVC=k8s"
	@echo "  make deploy-redis ENV=uat APP=myapp SVC=redis"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

venv: ## Create Python virtual environment for Kubespray
	@echo "Creating virtual environment..."
	cd $(KUBESPRAY_DIR) && python3 -m venv venv && \
		source venv/bin/activate && \
		pip install -r requirements.txt

lint: ## Run ansible-lint on playbooks
	@echo "Running ansible-lint..."
	ansible-lint $(PLAYBOOKS_DIR)/*.yaml

# =============================================================================
# INVENTORY HELPERS
# =============================================================================

list-inventories: ## List available inventories
	@echo "$(GREEN)Available Inventories:$(NC)"
	@find inventories/$(ENV) -name "hosts.yaml" | sed 's|inventories/||g' | sed 's|/hosts.yaml||g' | sort

check-inventory: ## Verify inventory file exists
	@if [ ! -f "$(INVENTORY)" ]; then \
		echo "$(YELLOW)ERROR: Inventory not found: $(INVENTORY)$(NC)"; \
		echo "Available inventories:"; \
		find inventories/$(ENV) -name "hosts.yaml" | sed 's|inventories/||g' | sed 's|/hosts.yaml||g' | sort; \
		exit 1; \
	fi

# =============================================================================
# KUBERNETES DEPLOYMENT
# =============================================================================

k8s-reset: check-inventory ## Reset Kubernetes cluster
	@echo "Resetting K8s cluster for $(ENV)/$(APP)/$(SVC)..."
	cd $(KUBESPRAY_DIR) && source venv/bin/activate && \
		ansible-playbook -i ../$(INVENTORY) reset.yml --become -e reset_confirmation=yes

k8s-prepare: check-inventory ## Prepare disks for Kubernetes
	@echo "Preparing K8s disks for $(ENV)/$(APP)/$(SVC)..."
	cd $(KUBESPRAY_DIR) && source venv/bin/activate && \
		ansible-playbook -i ../$(INVENTORY) ../$(PLAYBOOKS_DIR)/prepare_k8s_disks.yaml --become

k8s-deploy: check-inventory ## Deploy Kubernetes cluster
	@echo "Deploying K8s cluster for $(ENV)/$(APP)/$(SVC)..."
	cd $(KUBESPRAY_DIR) && source venv/bin/activate && \
		ansible-playbook -i ../$(INVENTORY) cluster.yml --become

k8s-post: check-inventory ## Run post K8s setup (Longhorn, Vault, cert-manager)
	@echo "Running post K8s setup for $(ENV)/$(APP)/$(SVC)..."
	cd $(KUBESPRAY_DIR) && source venv/bin/activate && \
		ansible-playbook -i ../$(INVENTORY) ../$(PLAYBOOKS_DIR)/post_k8s_setup.yaml --become

deploy-all: k8s-reset k8s-prepare k8s-deploy k8s-post ## Full K8s deployment (reset + prepare + deploy + post)
	@echo "✅ Full K8s deployment complete for $(ENV)/$(APP)/$(SVC)"

prod-ready: check-inventory ## Deploy production-ready cluster (all-in-one)
	@echo "Deploying production-ready cluster for $(ENV)/$(APP)/$(SVC)..."
	cd $(KUBESPRAY_DIR) && source venv/bin/activate && \
		ansible-playbook -i ../$(INVENTORY) ../$(PLAYBOOKS_DIR)/deploy_prod_ready_cluster.yaml --become
	@echo "✅ Production-ready cluster deployment complete"

# =============================================================================
# DNS
# =============================================================================

dns-deploy: check-inventory ## Deploy Bind9 DNS server
	@echo "Deploying Bind9 DNS for $(ENV)/$(APP)/$(SVC)..."
	cd $(KUBESPRAY_DIR) && source venv/bin/activate && \
		ansible-playbook -i ../$(INVENTORY) ../$(PLAYBOOKS_DIR)/deploy_bind9.yaml --become

external-dns: check-inventory ## Deploy ExternalDNS to Kubernetes
	@echo "Deploying ExternalDNS for $(ENV)/$(APP)/$(SVC)..."
	cd $(KUBESPRAY_DIR) && source venv/bin/activate && \
		ansible-playbook -i ../$(INVENTORY) ../$(PLAYBOOKS_DIR)/deploy_external_dns.yaml --become

# =============================================================================
# SERVICE DEPLOYMENT
# =============================================================================

deploy-redis: check-inventory ## Deploy Redis cluster
	@echo "Deploying Redis for $(ENV)/$(APP)/$(SVC)..."
	ansible-playbook -i $(INVENTORY) $(PLAYBOOKS_DIR)/deploy_redis.yaml --become

deploy-postgresql: check-inventory ## Deploy PostgreSQL (Patroni HA)
	@echo "Deploying PostgreSQL for $(ENV)/$(APP)/$(SVC)..."
	ansible-playbook -i $(INVENTORY) $(PLAYBOOKS_DIR)/deploy_postgresql.yaml --become

deploy-rabbitmq: check-inventory ## Deploy RabbitMQ cluster
	@echo "Deploying RabbitMQ for $(ENV)/$(APP)/$(SVC)..."
	ansible-playbook -i $(INVENTORY) $(PLAYBOOKS_DIR)/deploy_rabbitmq.yaml --become

deploy-minio: check-inventory ## Deploy MinIO cluster
	@echo "Deploying MinIO for $(ENV)/$(APP)/$(SVC)..."
	ansible-playbook -i $(INVENTORY) $(PLAYBOOKS_DIR)/deploy_minio.yaml --become

deploy-keepalived: check-inventory ## Deploy Keepalived for HA
	@echo "Deploying Keepalived for $(ENV)/$(APP)/$(SVC)..."
	ansible-playbook -i $(INVENTORY) $(PLAYBOOKS_DIR)/deploy_keepalived.yaml --become

# =============================================================================
# GENERAL
# =============================================================================

ansible-site: check-inventory ## Run full site.yml playbook
	@echo "Running site.yml for $(ENV)/$(APP)/$(SVC)..."
	ansible-playbook -i $(INVENTORY) $(PLAYBOOKS_DIR)/site.yml --become

ansible-ping: check-inventory ## Ping all hosts in inventory
	@echo "Pinging hosts in $(INVENTORY)..."
	ansible -i $(INVENTORY) all -m ping

ansible-facts: check-inventory ## Gather facts from all hosts
	@echo "Gathering facts from $(INVENTORY)..."
	ansible -i $(INVENTORY) all -m setup

# =============================================================================
# FULL STACK DEPLOYMENT (make deploy ENV=uat APP=myapp)
# =============================================================================

check-app-inventory: ## Verify unified app inventory exists
	@if [ ! -f "$(APP_INVENTORY)" ]; then \
		echo "$(YELLOW)ERROR: App inventory not found: $(APP_INVENTORY)$(NC)"; \
		echo "Expected format: inventories/$(ENV)/$(APP)/hosts.yaml"; \
		exit 1; \
	fi

deploy: check-app-inventory ## Deploy full application stack (make deploy ENV=uat APP=myapp)
	@echo "$(GREEN)Deploying full $(APP) stack on $(ENV)...$(NC)"
	@echo "Inventory: $(APP_INVENTORY)"
	@echo "Playbook: $(PLAYBOOKS_DIR)/deploy-$(APP).yaml"
	@echo ""
	ansible-playbook -i $(APP_INVENTORY) $(PLAYBOOKS_DIR)/deploy-$(APP).yaml --become
	@echo ""
	@echo "$(GREEN)✅ $(APP) deployment complete!$(NC)"

deploy-dry: check-app-inventory ## Dry-run full application stack (check mode)
	@echo "$(YELLOW)DRY-RUN: $(APP) stack on $(ENV)...$(NC)"
	ansible-playbook -i $(APP_INVENTORY) $(PLAYBOOKS_DIR)/deploy-$(APP).yaml --become --check --diff

deploy-tags: check-app-inventory ## Deploy specific tags (make deploy-tags ENV=uat APP=myapp TAGS=redis,rabbitmq)
	@echo "$(GREEN)Deploying $(APP) with tags: $(TAGS)$(NC)"
	ansible-playbook -i $(APP_INVENTORY) $(PLAYBOOKS_DIR)/deploy-$(APP).yaml --become --tags "$(TAGS)"

deploy-ping: check-app-inventory ## Test connectivity to all app hosts
	@echo "$(GREEN)Testing connectivity to $(APP) hosts...$(NC)"
	ansible -i $(APP_INVENTORY) all -m ping

# =============================================================================
# FULL-STACK AUTOMATION (make full-stack ENV=uat APP=myapp)
# Terraform + Ansible in ONE command
# =============================================================================

TF_DIR := ../terraform

# VCD Access Token - fetched from VCD using refresh token
ACCESS_TOKEN := $(shell python3 ../scripts/get_token.py $(ENV) $(APP) 2>/dev/null)

full-stack: ## FULL AUTOMATION: Terraform Apply + Ansible Deploy (make full-stack ENV=uat APP=myapp)
	@if [ -z "$(ACCESS_TOKEN)" ]; then echo "$(YELLOW)ERROR: Failed to get VCD access token. Check VCD_REFRESH_TOKEN env var$(NC)"; exit 1; fi
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════$(NC)"
	@echo "$(GREEN)  FULL STACK DEPLOYMENT: $(APP) on $(ENV)$(NC)"
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════$(NC)"
	@echo ""
	@echo "$(YELLOW)Phase 1: Terraform Apply$(NC)"
	@echo "─────────────────────────────────────────────────────────────────"
	cd $(TF_DIR) && terraform init -backend-config=../environments/$(ENV)/backend-$(APP).hcl -reconfigure
	cd $(TF_DIR) && terraform apply -var-file=../environments/$(ENV)/$(APP).tfvars -var="vcd_access_token=$(ACCESS_TOKEN)" -auto-approve

	@echo ""
	@echo "$(YELLOW)Phase 2: Wait for VM Readiness (SSH + cloud-init + disk mount)$(NC)"
	@echo "─────────────────────────────────────────────────────────────────"
	ansible-playbook -i ../environments/$(ENV)/$(APP).ini $(PLAYBOOKS_DIR)/wait_for_ready.yaml
	@echo ""
	@echo "$(YELLOW)Phase 3: Ansible Deploy$(NC)"
	@echo "─────────────────────────────────────────────────────────────────"
	ansible-playbook -i ../environments/$(ENV)/$(APP).ini $(PLAYBOOKS_DIR)/deploy-$(APP).yaml --become
	@echo ""
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════$(NC)"
	@echo "$(GREEN)  ✅ $(APP) FULL STACK DEPLOYMENT COMPLETE$(NC)"
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════$(NC)"

full-stack-dry: ## Dry-run full-stack (terraform plan + ansible check)
	@echo "$(YELLOW)DRY-RUN: Full stack $(APP) on $(ENV)$(NC)"
	@echo ""
	@echo "$(YELLOW)Phase 1: Terraform Plan$(NC)"
	cd $(TF_DIR) && terraform init -backend-config=../environments/$(ENV)/backend-$(APP).hcl -reconfigure
	cd $(TF_DIR) && terraform plan -var-file=../environments/$(ENV)/$(APP).tfvars
	@echo ""
	@echo "$(YELLOW)Phase 2: Ansible Check (using existing inventory)$(NC)"
	@if [ -f "../environments/$(ENV)/$(APP).ini" ]; then \
		ansible-playbook -i ../environments/$(ENV)/$(APP).ini $(PLAYBOOKS_DIR)/deploy-$(APP).yaml --become --check --diff; \
	else \
		echo "$(YELLOW)No inventory yet - run terraform apply first$(NC)"; \
	fi

