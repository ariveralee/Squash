# Squash

## Purpose 

A script that allows for the managing of multiple mongodb credentials as well as adding users to mongodb.

## Usage

There are several commands for this script:
	- add-cred
	- del-cred
	- add-user


### add-cred

This allows you to add a credential to a file. The credential itself consists of an alias and and a mongo connection url. A typical command would consist of:

```
$ ./squash.sh add-cred --alias mymongo --url http://127.0.0.1:27017
```

The `--alias` and `--url` flags can be entered in any order. If the entered alias or url is not found in the file, then it is added and saved. 

### del-cred

Allows you to remove an entered alias and connection url from the credentials file. A typical command would look like:

```
$ ./squash.sh del-cred --alias mymongo --url http://127.0.0.1:27017
```

As mentioned before, `--alias` and `url` can be entered in any order. The script will search to see if the alias and url exists and will confirm user wants to remove. 

### add-user

The cream of the crop, There are a few more flags for this command but it will allow for you to add a user to a mongo db. Here's what the command would look like:

```
$ ./squash.sh add-user --use mymongo --user coolguy --pass password --db superheros --roles dbAdmin,readWrite
```
`--use` is where you will specify the alias you would like to use for the above case, it's "mymongo"

`--user` This is the username you wish to get the user for the database

`--pass` nuff said.

`--db` This will be the database you want to add the user to. Note that by using the `--use` flag, you're specifying which connection url to use by use of the alias.

`--roles` Add as many roles as you wish for the user. They must however, be comma delimited.


A few things happen when this command is ran. First, we check for the alias and connection string in our credentials file. If it's present then we will attempt to connect. If successful, then the user will be added to the db specified. 

If all is well, you should get a confirmation that the user was added!