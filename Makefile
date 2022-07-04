help:
	@echo "Hello! :D"
	@echo "These are the targets: web, ssh, up, down, start, stop, tf, apply, output"
	@echo
	@echo
	@echo

web:
	open "http://$(shell terraform output | grep nginx_public_dns | cut -d\" -f2)"

ssh:
	ssh -i ./keys/ubuntu.pem ubuntu@$(shell terraform output | grep nginx_public_dns | cut -d\" -f2)

up: start

down: stop

stop start:
	./scripts/$(@).sh

tf apply:
	terraform apply -auto-approve

output:
	terraform output
