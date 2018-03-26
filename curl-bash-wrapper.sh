#!/usr/bin/env bash
function cf_lower() {
  echo "${1:-`cat`}" | tr '[:upper:]' '[:lower:]'
}

function cf_upper() {
  echo "${1:-`cat`}" | tr '[:lower:]' '[:upper:]'
}

function cf_starts_with() {
  local str=$1
  local pre=$2
  [[ "$str" ==  ${pre}* ]]
}

function cf_compose_url() {
  local inputUrl=$1
  local baseUrl=$2
  if test $inputUrl && (cf_starts_with $inputUrl $baseUrl || [[ $inputUrl =~ http.?://.+ ]]); then
    echo $inputUrl
  else
    echo "$baseUrl$inputUrl"
  fi
}

# used after a pipe, for example: echo '{ "k": "v"}' | cf_jsonfmt
function cf_jsonfmt() {
  if type python > /dev/null 2>&1; then
    python -mjson.tool
  else
    echo "python is not found in PATH"
    return 1
  fi
}

# -u : user name, default value: $REQ_USER
# -p : password, default value: $REQ_PWD
# -l : request url, it can be full url (startsWith http://baseurl.com) or sub-path (/data/resource), default value: $REQ_BASE
# -m : request method, default value: $REQ_METHOD
# -d : request body, defaut read from stdin by cat
function cf_req() {
  local OPTIND=1
  local u;local p;local l;local m;local d;
  while getopts ":u:p:l:m:d:" o; do
      case "${o}" in
          u)  u=${OPTARG} ;;
          p)  p=${OPTARG} ;;
          l)  l=${OPTARG} ;;
          m)  m=${OPTARG} ;;
          d)  d=${OPTARG} ;;
      esac
  done
  if type curl > /dev/null 2>&1; then
    if (test $u || test $REQ_USER) && (test $p || test $REQ_PWD); then
      echo $(curl -k -s -u ${u:-$REQ_USER}:${p:-$REQ_PWD} -X `cf_upper ${m:-$REQ_METHOD}` -H "Accept: application/json" -H "Content-Type: application/json" $(cf_compose_url $l $REQ_BASE) -d @<(if test "GET" = `cf_upper ${m:-$REQ_METHOD}` || test "DELETE" = `cf_upper ${m:-$REQ_METHOD}`; then echo ""; else echo ${d:-`cat`}; fi))
    else
      echo $(curl -k -s -X `cf_upper ${m:-$REQ_METHOD}` -H "Accept: application/json" -H "Content-Type: application/json" $(cf_compose_url $l $REQ_BASE) -d @<(if test "GET" = `cf_upper ${m:-$REQ_METHOD}` || test "DELETE" = `cf_upper ${m:-$REQ_METHOD}`; then echo ""; else echo ${d:-`cat`}; fi)) 
    fi
  else
    echo "curl is not found in PATH"
    return 1
  fi
}

# cf_req -d '{ "query" : "MATCH (ee:Person) WHERE ee.name = \"Emil\" RETURN ee;", "params" : {} }'| cf_parse '["data"][0][0]["all_relationships"]'
# $1 the key
# $2 json string or read stdin from cat 
function cf_parse() {
  if type python > /dev/null 2>&1; then
    python <<EOF
import json
try:
  print(json.loads('''${2:-`cat`}''')${1:-""})
except Exception as e:
  print("error: {}".format(e))
EOF
  else
    echo "python is not found in PATH"
    return 1
  fi
}
