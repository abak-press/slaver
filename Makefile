BUNDLE = bundle
BUNDLE_OPTIONS = -j 3
RSPEC = ${APPRAISAL} rspec
APPRAISAL = ${BUNDLE} exec appraisal

all: test

test: configs bundler appraisal
	${RSPEC} 2>&1

define DATABASE_YML
test:
  adapter: sqlite3
  database: test
test_other:
  adapter: sqlite3
  database: test_other
endef
export DATABASE_YML

configs:
	echo "$${DATABASE_YML}" > spec/internal/config/database.yml

bundler:
	if ! gem list bundler -i > /dev/null; then \
	  gem install bundler; \
	fi
	${BUNDLE} install ${BUNDLE_OPTIONS}

appraisal:
	${APPRAISAL} install
