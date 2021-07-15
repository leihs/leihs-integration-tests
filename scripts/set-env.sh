# usage: source ./scripts/set-env.sh && some-command

# read in local env file
if ! . ./.env.local; then
  echo 'could not source env file! try `cp .env.local-example .env.local`'
  return 1 # not exit, because we are being sourced and dont want to close the partent shell!
fi

# db config
DATABASE_URL="postgresql://localhost:5432/${DATABASE_NAME}?max-pool-size=5"
# db config for clj servers
LEIHS_DATABASE_URL="jdbc:${DATABASE_URL}"

# export all the vars
export DATABASE_NAME
export DATABASE_URL
export LEIHS_DATABASE_URL

export LEIHS_HTTP_PORT
export LEIHS_LEGACY_PORT
export LEIHS_HOST_PORT_POSTGRES
export LEIHS_MAIL_SMTP_PORT
export LEIHS_MAIL_POP3_PORT
export LEIHS_SECRET

export RAILS_ENV

export FIREFOX_ESR_60_PATH