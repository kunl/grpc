# Makefile for Python Wechaty
#
# 	GitHb: https://github.com/wechaty/python-wechaty
# 	Author: Huan LI <zixia@zixia.net> git.io/zixia
#

SOURCE_GLOB=$(wildcard chatie_grpc/**/*.py bin/*.py src/**/*.py tests/**/*.py examples/*.py)

#
# Huan(202003)
# 	F811: https://github.com/PyCQA/pyflakes/issues/320#issuecomment-469337000
#
IGNORE_PEP=E203,E221,E241,E272,E501,F811

# help scripts to find the right place of wechaty module
export PYTHONPATH=src/

.PHONY: all
all : clean lint

.PHONY: clean
clean:
	rm -fr dist/*

.PHONY: lint
lint: # pylint pycodestyle flake8 mypy pytype

.PHONY: pylint
pylint:
	pylint \
		--load-plugins pylint_quotes \
		$(SOURCE_GLOB)

.PHONY: pycodestyle
pycodestyle:
	pycodestyle \
		--statistics \
		--count \
		--ignore="${IGNORE_PEP}" \
		$(SOURCE_GLOB)

.PHONY: flake8
flake8:
	flake8 \
		--ignore="${IGNORE_PEP}" \
		$(SOURCE_GLOB)

.PHONY: mypy
mypy:
	MYPYPATH=stubs/ mypy \
		$(SOURCE_GLOB)

.PHONE: pytype
pytype:
	pytype src/
	pytype examples/

.PHONY: install
install: install-py install-go

.PHONY: install-py
install-py:
	pip install -r requirements.txt
	pip install -r requirements-dev.txt

.PHONY: install-go
install-go:
	go get -u github.com/golang/protobuf/protoc-gen-go

.PHONY: pytest
pytest:
	pytest src/ tests/

.PHONY: test-unit
test-unit: pytest

.PHONY: test
test: lint test-py test-go

.PHONY: test-py
test-py: pytest

.PHONY: test-go
test-go:
	cd ./go && go test ./...

.PHONY: check-version
check-version:
	./scripts/check_version.py

code:
	code .

.PHONY: run
run:
	python3 bin/run.py

.PHONY: dist
dist:
	python3 setup.py sdist bdist_wheel

.PHONY: publish
publish:
	PATH=~/.local/bin:${PATH} twine upload dist/*

.PHONY: generate
generate: generate-py generate-go

.PHONY: generate-py
generate-py:
	./scripts/generate-stub-py.sh

.PHONY: generate-go
generate-go:
	./scripts/generate-stub-go.sh

.PHONY: demo
demo:
	python3 examples/demo.py

