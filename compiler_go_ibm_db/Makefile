build: build_image test
	@docker login
	@echo "Please enter tag for image usmanovrinat1984/compiler_go_ibm_db"
	@read root_path; \
	docker tag usmanovrinat1984/compiler_go_ibm_db:latest usmanovrinat1984/compiler_go_ibm_db:$$root_path; \
	docker push usmanovrinat1984/compiler_go_ibm_db:latest; \
	docker push usmanovrinat1984/compiler_go_ibm_db:$$root_path;

build_image:
	@docker build --platform linux/amd64 -t usmanovrinat1984/compiler_go_ibm_db:latest .

test:
	@docker rm test_compiler_go_ibm_db || true
	@docker rmi usmanovrinat1984/test_compiler_go_ibm_db || true
	@docker build --platform linux/amd64 -t usmanovrinat1984/test_compiler_go_ibm_db -f test.Dockerfile .
	@docker run --name test_compiler_go_ibm_db usmanovrinat1984/test_compiler_go_ibm_db
	@docker logs test_compiler_go_ibm_db
	@docker rm test_compiler_go_ibm_db
	@docker rmi usmanovrinat1984/test_compiler_go_ibm_db


