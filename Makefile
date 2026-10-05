ANSIBLE_DIR := ansible
PLAYBOOK    := $(ANSIBLE_DIR)/playbook.yml

.PHONY: help ping deploy deploy-force vault-edit lint clean

help:
	@echo "Доступные команды:"
	@echo "  make ping         — проверить связь с сервером"
	@echo "  make deploy       — полный деплой (idempotent)"
	@echo "  make deploy-force — деплой с принудительным перезапуском app"
	@echo "  make vault-edit   — редактировать vault.yml"
	@echo "  make lint         — ansible-lint"
	@echo "  make clean        — удалить retry-файлы"

ping:
	cd $(ANSIBLE_DIR) && ansible all -m ping

deploy:
	cd $(ANSIBLE_DIR) && ansible-playbook playbook.yml

deploy-force:
	cd $(ANSIBLE_DIR) && ansible-playbook playbook.yml -e "deploy_force_restart=true"

vault-edit:
	cd $(ANSIBLE_DIR) && ansible-vault edit vault.yml

lint:
	ansible-lint $(PLAYBOOK)

clean:
	rm -f $(ANSIBLE_DIR)/*.retry
