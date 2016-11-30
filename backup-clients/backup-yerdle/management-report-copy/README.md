# management-report
SQL and automation code for key business metric reporting and analytics . .


## sql review process
we'll use a pull review process for SQL. we can accomplish this using the Github web GUI like [this](https://help.github.com/articles/github-flow-in-the-browser/)

Steps for review:
- either create a branch or use an existing branch
- switch to the branch, and either open and edit or add the file(s) you want reviewed
- create a pull request from that branch
- let people know in an appropriate slack channel that you you have a pull request for review
- check back for comments and update that branch until the pull request is approved
- after it's approved (one or two plus one comments), merge it back to the master branch


## management-report
__management-report__ is a command line tool for automating the reporting of our key operational metrics in the Management Report google sheet

__management-report__ uses:
- [sequel](http://sequel.jeremyevans.net/index.html) for Redshift access
- [google-drive-ruby](https://github.com/gimite/google-drive-ruby) for Spreadsheet manipulation

### to configure _management-report_
copy the ```example.config.rb``` file and add the missing values
```
cp config/example.config.rb config/config.rb
```

### to set oauth up on a machine . .
Obtain "management-report-key.p12" file from developer or server. Add to config/ directory.


to see what __management-report__ can do, read the code or run:
```
./management-report help
```

# TODO
- [x] [set up persistent oauth[(https://developers.google.com/api-client-library/ruby/guide/aaa_oauth)
- [x] update example.config.rb
- [x] make -s arg take multiple sql roots
- [ ] validate method (in progress)
- [ ] row insertion including dealing with formulas
- [ ] add ability to specify a start date for queries and use erb to set
- [ ] schedule management-report to run on an ops server
- [ ] make verified_users use a symnlink

