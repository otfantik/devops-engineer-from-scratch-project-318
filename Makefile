ANSIBLE_DIR := ansible
PLAYBOOK    := playbook.yml

.PHONY: help ping deps deploy deploy-force vault-edit lint lint-fix test smoke clean

help:
	@echo "Available commands:"
	@echo "  make ping         — ping both VMs"
	@echo "  make deps         — install Ansible collections and roles"
	@echo "  make deploy       — full deployment"
	@echo "  make deploy-force — deploy + force restart app"
	@echo "  make vault-edit   — edit vault.yml"
	@echo "  make lint         — ansible-lint"
	@echo "  make lint-fix     — ansible-lint --fix"
	@echo "  make test         — ping + health checks"
	@echo "  make smoke        — curl all services"

ping:
	cd $(ANSIBLE_DIR) && ansible all -m ping

deps:
	ansible-galaxy collection install -r requirements.yml -p $(ANSIBLE_DIR)/collections
	ansible-galaxy role install -r requirements.yml -p $(ANSIBLE_DIR)/roles

deploy:
	cd $(ANSIBLE_DIR) && ansible-playbook $(PLAYBOOK)

deploy-force:
	cd $(ANSIBLE_DIR) && ansible-playbook $(PLAYBOOK) -e "deploy_force_restart=true"

vault-edit:
	cd $(ANSIBLE_DIR) && ansible-vault edit vault.yml

lint:
	cd $(ANSIBLE_DIR) && ANSIBLE_CONFIG=ansible.cfg ansible-lint $(PLAYBOOK)

lint-fix:
	cd $(ANSIBLE_DIR) && ANSIBLE_CONFIG=ansible.cfg ansible-lint --fix $(PLAYBOOK)

test: ping
	@echo "=== Health checks ==="
	@curl -sf http://93.77.179.75:9090/-/ready >/dev/null && echo "Prometheus: OK" || echo "Prometheus: FAIL"
	@curl -sf http://93.77.179.75:3000/api/health >/dev/null && echo "Grafana: OK" || echo "Grafana: FAIL"

smoke:
	@echo "=== Application ==="
	@curl -sfI https://bulletins-otfantik.ddns.net/api/bulletins >/dev/null && echo "API: OK" || (echo "API: FAIL"; exit 1)
	@curl -sfI https://bulletins-otfantik.ddns.net/ >/dev/null && echo "SPA: OK" || (echo "SPA: FAIL"; exit 1)
	@echo "=== Prometheus ==="
	@curl -sf http://93.77.179.75:9090/-/ready >/dev/null && echo "Prometheus ready: OK" || (echo "Prometheus: FAIL"; exit 1)
	@echo "=== Grafana ==="
	@curl -sf http://93.77.179.75:3000/api/health >/dev/null && echo "Grafana: OK" || echo "Grafana: FAIL"

clean:
	rm -f $(ANSIBLE_DIR)/*.retry