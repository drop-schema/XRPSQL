# XRPSQL
Data Warehouse for XRP Ledger

This is a project to improve rippled's [Reporting Mode](https://xrpl.org/build-run-rippled-in-reporting-mode.html). The docs are a bit out of date

## Open Questions
Where is the documentation to the gRPC API? Will need to look into the source to understand it better.

# DEVLOG

## 23-03-21

Had some issues configuring the secure gateway for gRPC API across 2 docker containers.
I think the API did not like the fact that docker container DNS is mapped to their service names. 
This could probably be solved by figuring out the IPs the docker containers get bound,
but I'm cautious that the value wil change across container launches.

Solution was to just exec into the container twice - that way I could confidently use 127.0.0.1 as the secure gateway value

Up and running though! rippled and rippled-reporting logs below.

Couldn't find any examples online of reporting mode running or how to configure it. This commit might help the next person out ;)

![rippled Logs Screenshot](https://user-images.githubusercontent.com/128277679/226770683-d4ae874a-72f1-4537-96a0-7127ba05d2fc.png)
