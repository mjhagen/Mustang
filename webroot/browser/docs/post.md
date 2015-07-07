###Introduction

POST allows you to insert one or more new records.

If you provide a parameter labeled "batch" containing a JSON formatted array of entities the API will insert those records.

###Parameters

* id `id=#GUID#`
* any field you wish to filter on `firstName=John`

###Example

```
#apiBaseURL#/#entityName#
```

###Batch example

```
batch = [{"name":"test1"},{"name":"test2"}]
```