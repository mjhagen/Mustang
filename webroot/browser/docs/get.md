###Introduction

GET allows you to retrieve a list of records, or a single record depending on the URL.

If you add an ID at the end of the URL only the record matching that ID will be returned.

###Parameters

* id `id=#GUID#`
* any field you wish to filter on `firstName=John`

###Example

```
#apiBaseURL#/#entityName#/#GUID#
```