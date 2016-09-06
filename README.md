# fileconverter  
This is the ruby tool to convert file from one format to another.

## Json to CSV  
Convert Json file from nested format to a flat CSV strcuture.  
The convert rule likes the following:
```json
[
{
	"key1": {
		"key11": "v1"
		"key12": "v2"
	},
	"key2": "v3"
}
]
```
```
will be converted to:
key1.key11  |   key1.key12  |    key2
----------------------------------------
v1          |   v2          |    v3
```
