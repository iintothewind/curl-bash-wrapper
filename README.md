# curl-bash-wrapper

`curl-bash-wrapper` is a set of useful shell functions that wrap curl command to create restful requests in an easy way.

## prerequisites

- curl command
- python
- some environment variables (optional)

```bash
export REQ_BASE="https://localhost/base/url"
export REQ_USER="usr"
export REQ_PWD="pwd"
export REQ_METHOD="POST"
```

## usage

first things first, we need to load functions by using `source curl-bash-wrapper.sh`

### send GET request

`cf_req -l 'http://api.openweathermap.org/data/2.5/weather?appid=12345&lang=zh_cn&q=Shanghai' -m get`

response should be:

```json
{"weather":[{"id":701,"main":"Mist","description":"薄雾","icon":"50n"}],"base":"stations","main":{"temp":287.59,"pressure":1022,"humidity":55,"temp_min":286.15,"temp_max":289.15},"visibility":10000,"wind":{"speed":3,"deg":110},"clouds":{"all":0},"dt":1521896400,"sys":{"type":1,"id":7452,"message":0.0081,"country":"CN","sunrise":1521841965,"sunset":1521886091},"id":1236,"name":"Shanghai","cod":20}
```

After we exported some environment variables:

```bash
export REQ_BASE="http://api.openweathermap.org"
export REQ_METHOD="GET"
```

The command can be simplified to be:

```bash
cf_req -l '/data/2.5/weather?appid=12345&lang=zh_cn&q=Shanghai'
```

### send POST request

Assume we are using a neo4j database, and exported some environment variables:

```bash
export REQ_BASE="http://localhost:7474/db/data/cypher"
export REQ_USER="neo4j"
export REQ_PWD="admin"
export REQ_METHOD="POST"
```

The command can be simplified to be:

```bash
cf_req -d '{ "query" : "MATCH (ee:Person) WHERE ee.name = \"Emil\" RETURN ee;", "params" : {} }'
```

Or we can store json request body into a `query.json` file, then:

```bash
cat query.json | cf_req
```

### format json response

In order to format json response, We can connect `cf_req` and  `cf_jsonfmt` with a pipe:

```bash
cf_req -l '/data/2.5/weather?appid=a38e&lang=zh_cn&q=Shanghai' | cf_jsonfmt
```

The response will be formatted to:

```json
{
    "base": "stations",
    "id": 17236,
    "main": {
        "humidity": 55,
        "pressure": 1022,
        "temp": 287.59,
        "temp_max": 289.15,
        "temp_min": 286.15
    },
    "name": "Shanghai",
    "weather": [
        {
            "description": "\u8584\u96fe",
            "icon": "50n",
            "id": 701,
            "main": "Mist"
        }
    ],
    "wind": {
        "deg": 110,
        "speed": 3
    }
}

```

### pick value from json response

We can use `cf_parse` to **pipe** after any json response, and use key as the first parameter of this function:

```bash
cf_req -l '/data/2.5/weather?appid=a38e&lang=zh_cn&q=Shanghai' | cf_jsonfmt | cf_parse '["weather"][0]["main"]'
```

result:

```shell
Mist
```

