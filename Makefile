# Full-Stack Infrastructure Monorepo Makefile
# Usage: make <target> ENV=<environment> APP=<application>
# Example: make full-stack ENV=example APP=myapp

.PHONY: help venv lint check-inventory
.PHONY: k8s-reset k8s-prepare k8s-deploy k8s-post deploy-all prod-ready
.PHONY: dns-deploy external-dns
.PHONY: deploy-redis deploy-postgresql deploy-rabbitmq deploy-minio deploy-keepalived
.PHONY: ansible-site ansible-ping ansible-facts
.PHONY: deploy deploy-dry deploy-tags deploy-ping
.PHONY: tf-init tf-plan tf-apply tf-destroy full-stack full-stack-dry

# Default values
ENV ?= example
APP ?= myapp
SVC ?= k8s

# Paths
INVENTORY := environments/$(ENV)/$(APP).ini
APP_INVENTORY := environments/$(ENV)/$(APP).ini
TF_VARS := environments/$(ENV)/$(APP).tfvars
TF_DIR := terraform
ANSIBLE_DIR := ansible
PLAYBOOKS_DIR := playbooks

# Optional target argument.
# Usage: make plan TARGET="minio landscape-01"
# This uses the python script to expand "minio" to all its instances.
TARGET_ARG := $(if $(TARGET),$(shell python3 scripts/expand_targets.py $(ENV) $(APP) $(TARGET)),)

# Colors
GREEN := \033[0;32m
YELLOW := \033[0;33m
NC := \033[0m

help: ## Show this help
	@echo "$(GREEN)Infrastructure Monorepo Makefile$(NC)"
	@echo ""
	@echo "$(YELLOW)Usage:$(NC) make <target> ENV=<env> APP=<app> SVC=<service>"
	@echo ""
	@echo "$(YELLOW)Examples:$(NC)"
	@echo "  make ansible-ping ENV=example APP=myapp"
	@echo "  make full-stack ENV=example APP=myapp"
	@echo "  make deploy-redis ENV=example APP=myapp SVC=redis"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

lint: ## Run ansible-lint on playbooks
	@echo "Running ansible-lint..."
	cd $(ANSIBLE_DIR) && ansible-lint $(PLAYBOOKS_DIR)/*.yaml

# =============================================================================
# INVENTORY HELPERS
# =============================================================================

check-inventory: ## Verify inventory file exists
	@if [ ! -f "$(INVENTORY)" ]; then \
		echo "$(YELLOW)ERROR: Inventory not found: $(INVENTORY)$(NC)"; \
		exit 1; \
	fi

# =============================================================================
# KUBERNETES DEPLOYMENT
# =============================================================================

k8s-reset: check-inventory ## Reset Kubernetes cluster
	@echo "Resetting K8s cluster for $(ENV)/$(APP)..."
	cd $(ANSIBLE_DIR) && ansible-playbook -i ../$(INVENTORY) $(PLAYBOOKS_DIR)/reset.yml --become -e reset_confirmation=yes

k8s-prepare: check-inventory ## Prepare disks for Kubernetes
	@echo "Preparing K8s disks for $(ENV)/$(APP)..."
	cd $(ANSIBLE_DIR) && ansible-playbook -i ../$(INVENTORY) $(PLAYBOOKS_DIR)/prepare_k8s_disks.yaml --become

k8s-deploy: check-inventory ## Deploy Kubernetes cluster
	@echo "Deploying K8s cluster for $(ENV)/$(APP)..."
	cd $(ANSIBLE_DIR) && ansible-playbook -i ../$(INVENTORY) $(PLAYBOOKS_DIR)/cluster.yml --become

k8s-post: check-inventory ## Run post K8s setup (Volumes, Vault, cert-manager)
	@echo "Running post K8s setup for $(ENV)/$(APP)..."
	cd $(ANSIBLE_DIR) && ansible-playbook -i ../$(INVENTORY) $(PLAYBOOKS_DIR)/post_k8s_setup.yaml --become

deploy-all: k8s-reset k8s-prepare k8s-deploy k8s-post ## Full K8s deployment (reset + prepare + deploy + post)
	@echo "✅ Full K8s deployment complete for $(ENV)/$(APP)"

prod-ready: check-inventory ## Deploy production-ready cluster (all-in-one)
	@echo "Deploying production-ready cluster for $(ENV)/$(APP)..."
	cd $(ANSIBLE_DIR) && ansible-playbook -i ../$(INVENTORY) $(PLAYBOOKS_DIR)/deploy_prod_ready_cluster.yaml --become
	@echo "✅ Production-ready cluster deployment complete"

# =============================================================================
# DNS
# =============================================================================

dns-deploy: check-inventory ## Deploy Bind9 DNS server
	@echo "Deploying Bind9 DNS for $(ENV)/$(APP)..."
	cd $(ANSIBLE_DIR) && ansible-playbook -i ../$(INVENTORY) $(PLAYBOOKS_DIR)/deploy_bind9.yaml --become

external-dns: check-inventory ## Deploy ExternalDNS to Kubernetes
	@echo "Deploying ExternalDNS for $(ENV)/$(APP)..."
	cd $(ANSIBLE_DIR) && ansible-playbook -i ../$(INVENTORY) $(PLAYBOOKS_DIR)/deploy_external_dns.yaml --become

# =============================================================================
# SERVICE DEPLOYMENT
# =============================================================================

deploy-redis: check-inventory ## Deploy Redis cluster
	@echo "Deploying Redis for $(ENV)/$(APP)..."
	cd $(ANSIBLE_DIR) && ansible-playbook -i ../$(INVENTORY) $(PLAYBOOKS_DIR)/deploy_redis.yaml --become

deploy-postgresql: check-inventory ## Deploy PostgreSQL (Patroni HA)
	@echo "Deploying PostgreSQL for $(ENV)/$(APP)..."
	cd $(ANSIBLE_DIR) && ansible-playbook -i ../$(INVENTORY) $(PLAYBOOKS_DIR)/deploy-postgresql-autobase.yaml --become

deploy-rabbitmq: check-inventory ## Deploy RabbitMQ cluster
	@echo "Deploying RabbitMQ for $(ENV)/$(APP)..."
	cd $(ANSIBLE_DIR) && ansible-playbook -i ../$(INVENTORY) $(PLAYBOOKS_DIR)/deploy_rabbitmq.yaml --become

deploy-minio: check-inventory ## Deploy MinIO cluster
	@echo "Deploying MinIO for $(ENV)/$(APP)..."
	cd $(ANSIBLE_DIR) && ansible-playbook -i ../$(INVENTORY) $(PLAYBOOKS_DIR)/deploy_minio.yaml --become

deploy-keepalived: check-inventory ## Deploy Keepalived for HA
	@echo "Deploying Keepalived for $(ENV)/$(APP)..."
	cd $(ANSIBLE_DIR) && ansible-playbook -i ../$(INVENTORY) $(PLAYBOOKS_DIR)/deploy_keepalived.yaml --become

# =============================================================================
# GENERAL ANSIBLE UTILITIES
# =============================================================================

ansible-site: check-inventory ## Run full site.yml playbook
	@echo "Running site.yml for $(ENV)/$(APP)..."
	cd $(ANSIBLE_DIR) && ansible-playbook -i ../$(INVENTORY) $(PLAYBOOKS_DIR)/site.yaml --become

ansible-ping: check-inventory ## Ping all hosts in inventory
	@echo "Pinging hosts in $(INVENTORY)..."
	cd $(ANSIBLE_DIR) && ansible -i ../$(INVENTORY) all -m ping

ansible-facts: check-inventory ## Gather facts from all hosts
	@echo "Gathering facts from $(INVENTORY)..."
	cd $(ANSIBLE_DIR) && ansible -i ../$(INVENTORY) all -m setup

# =============================================================================
# FULL APP CONFIGURATION DEPLOYMENT
# =============================================================================

deploy: check-inventory ## Deploy full application stack playbook (make deploy ENV=example APP=myapp)
	@echo "$(GREEN)Deploying full $(APP) stack on $(ENV)...$(NC)"
	cd $(ANSIBLE_DIR) && ansible-playbook -i ../$(APP_INVENTORY) $(PLAYBOOKS_DIR)/deploy-$(APP).yaml --become
	@echo ""
	@echo "$(GREEN)✅ $(APP) deployment complete!$(NC)"

deploy-dry: check-inventory ## Dry-run full application stack (check mode)
	@echo "$(YELLOW)DRY-RUN: $(APP) stack on $(ENV)...$(NC)"
	cd $(ANSIBLE_DIR) && ansible-playbook -i ../$(APP_INVENTORY) $(PLAYBOOKS_DIR)/deploy-$(APP).yaml --become --check --diff

deploy-tags: check-inventory ## Deploy specific tags (make deploy-tags ENV=example APP=myapp TAGS=redis)
	@echo "$(GREEN)Deploying $(APP) with tags: $(TAGS)$(NC)"
	cd $(ANSIBLE_DIR) && ansible-playbook -i ../$(APP_INVENTORY) $(PLAYBOOKS_DIR)/deploy-$(APP).yaml --become --tags "$(TAGS)"

deploy-ping: check-inventory ## Test connectivity to all app hosts
	@echo "$(GREEN)Testing connectivity to $(APP) hosts...$(NC)"
	cd $(ANSIBLE_DIR) && ansible -i ../$(APP_INVENTORY) all -m ping

# =============================================================================
# TERRAFORM ORCHESTRATION
# =============================================================================

# Dynamic Token Generation
# We fetch a fresh Access Token for every operation using the Python helper
ACCESS_TOKEN := $(shell python3 scripts/get_token.py $(ENV) $(APP))

tf-init:
	@echo "Initializing Terraform..."
	cd $(TF_DIR) && terraform init

tf-plan: tf-init
	@if [ -z "$(ACCESS_TOKEN)" ] && [ -z "$$VCD_REFRESH_TOKEN" ]; then \
		echo "$(YELLOW)WARNING: VCD_REFRESH_TOKEN is not set. Token generation may fail.$(NC)"; \
	fi
	@echo "Selecting workspace: $(ENV)-$(APP)..."
	cd $(TF_DIR) && \
	terraform workspace select $(ENV)-$(APP) 2>/dev/null || terraform workspace new $(ENV)-$(APP) && \
	terraform plan -var-file="../$(TF_VARS)" -var="vcd_access_token=$(ACCESS_TOKEN)" $(TARGET_ARG)

tf-apply: tf-init
	@if [ -z "$(ACCESS_TOKEN)" ] && [ -z "$$VCD_REFRESH_TOKEN" ]; then \
		echo "$(YELLOW)WARNING: VCD_REFRESH_TOKEN is not set. Token generation may fail.$(NC)"; \
	fi
	@echo "Selecting workspace: $(ENV)-$(APP)..."
	cd $(TF_DIR) && \
	terraform workspace select $(ENV)-$(APP) 2>/dev/null || terraform workspace new $(ENV)-$(APP) && \
	terraform apply -var-file="../$(TF_VARS)" -var="vcd_access_token=$(ACCESS_TOKEN)" $(TARGET_ARG) -auto-approve

tf-destroy: tf-init
	@if [ -z "$(ACCESS_TOKEN)" ] && [ -z "$$VCD_REFRESH_TOKEN" ]; then \
		echo "$(YELLOW)WARNING: VCD_REFRESH_TOKEN is not set. Token generation may fail.$(NC)"; \
	fi
	@echo "Selecting workspace: $(ENV)-$(APP)..."
	cd $(TF_DIR) && \
	terraform workspace select $(ENV)-$(APP) && \
	terraform destroy -var-file="../$(TF_VARS)" -var="vcd_access_token=$(ACCESS_TOKEN)" $(TARGET_ARG) -auto-approve

# =============================================================================
# FULL STACK DEPLOYMENT (Terraform + Ansible)
# =============================================================================

full-stack: ## FULL AUTOMATION: Terraform Apply + Ansible Deploy (make full-stack ENV=example APP=myapp)
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════$(NC)"
	@echo "$(GREEN)  FULL STACK DEPLOYMENT: $(APP) on $(ENV)$(NC)"
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════$(NC)"
	@echo ""
	@echo "$(YELLOW)Phase 1: Terraform Apply$(NC)"
	@echo "─────────────────────────────────────────────────────────────────"
	$(MAKE) tf-apply ENV=$(ENV) APP=$(APP)

	@echo ""
	@echo "$(YELLOW)Phase 2: Wait for VMs$(NC)"
	@echo "─────────────────────────────────────────────────────────────────"
	@sleep 30

	@echo ""
	@echo "$(YELLOW)Phase 3: Ansible Deploy$(NC)"
	@echo "─────────────────────────────────────────────────────────────────"
	$(MAKE) deploy ENV=$(ENV) APP=$(APP)

	@echo ""
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════$(NC)"
	@echo "$(GREEN)  ✅ $(APP) FULL STACK DEPLOYMENT COMPLETE$(NC)"
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════$(NC)"

full-stack-dry: ## Dry-run full-stack (terraform plan + ansible check)
	@echo "$(YELLOW)DRY-RUN: Full stack $(APP) on $(ENV)$(NC)"
	@echo ""
	@echo "$(YELLOW)Phase 1: Terraform Plan$(NC)"
	cd $(TF_DIR) && terraform init && terraform plan -var-file="../$(TF_VARS)"
	@echo ""
	@echo "$(YELLOW)Phase 2: Ansible Check (using existing inventory)$(NC)"
	@if [ -f "$(INVENTORY)" ]; then \
		$(MAKE) deploy-dry ENV=$(ENV) APP=$(APP); \
	else \
		echo "$(YELLOW)No inventory yet - run terraform apply first$(NC)"; \
	fi

###############################################################################
# K8s Day-2 Operations
###############################################################################

.PHONY: k8s-apply-argocd k8s-apply-crossplane k8s-apply-security chaos-test velero-backup

k8s-apply-argocd: ## Deploy ArgoCD root Application (App-of-Apps)
	@echo "$(GREEN)Deploying ArgoCD Root Application...$(NC)"
	kubectl apply -f k8s/argocd/root-app.yaml

k8s-apply-crossplane: ## Deploy Crossplane XRDs and Compositions
	@echo "$(GREEN)Deploying Crossplane PostgreSQL XRD + Composition...$(NC)"
	kubectl apply -f k8s/crossplane/xrd-postgresql.yaml
	kubectl apply -f k8s/crossplane/composition-postgresql.yaml
	@echo "$(YELLOW)Example claim available at: k8s/crossplane/claim-example.yaml$(NC)"

k8s-apply-security: ## Apply Kyverno policies + Istio mTLS
	@echo "$(GREEN)Applying Security Policies...$(NC)"
	kubectl apply -f k8s/security/kyverno-policies.yaml
	kubectl apply -f k8s/security/istio-zero-trust.yaml
	@echo "$(GREEN)Kyverno + Istio mTLS policies enforced.$(NC)"

k8s-apply-storage: ## Apply Portworx StorageClasses
	@echo "$(GREEN)Applying Portworx StorageClasses...$(NC)"
	kubectl apply -f k8s/storage/storageclass-portworx.yaml

velero-backup: ## Apply Velero backup schedules
	@echo "$(GREEN)Applying Velero Backup Schedules...$(NC)"
	kubectl apply -f k8s/velero/schedule-backup.yaml
	@echo "$(GREEN)Hourly + Daily backup schedules active.$(NC)"

chaos-test: ## Run ChaosMesh experiments (STAGING ONLY)
	@echo "$(RED)⚠ WARNING: This will inject chaos into the cluster!$(NC)"
	@echo "$(YELLOW)Target namespace labels must match. Press Ctrl+C to abort.$(NC)"
	@sleep 5
	kubectl apply -f k8s/chaos/chaos-experiments.yaml
	@echo "$(RED)Chaos experiments deployed. Monitor: kubectl get podchaos,networkchaos -A$(NC)"
