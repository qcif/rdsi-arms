# RDSI ARMS

## Introduction

The **Allocation Request Management System** (ARMS) is a software
system for managing requests for the allocation of RDSI storage.
It captures the information in a request for storage,
tracks that request through the process of assessing and (if approved)
the provisioning storage for it.

The **Research Data Storage Infrastructure** (RDSI) is a project to
increase the sharing and re-use of research related data in
Australia. The project will be resliased through the creation and
development of data stroage infrastructure accessed through a common
infrastructure layer. For more information about RDSI, please see
<http://www.rdsi.edu.au>.

ARMS manages requests for **allocations** and not requests for
collections. It is possible to consider a set of collections as a
collection in its own right. So ARMS could be considered as a system
that deals with such aggregation-collections, but it does not identify
collections that are not aggregation-collections. The identification
of non-aggregation collection currently is out of scope.

ARMS manages **requests** for allocations and not actual
allocations. A request for a resource is not the same as the resource
itself. For requests being processed or have been rejected, there is
no corresponding storage allocation. For approved requests, there will
be a corresponding storage allocation (subject to provisioning
activities being performed outside of ARMS). ARMS can be used in
conjunction with an allocation management solution, but ARMS itself is
not an allocation management solution. A request is related to, but
not the same thing as a allocation.

ARMS is intended to help nodes **manage** the recording, assessment,
provisioning and reporting processes.

ARMS is a software **system** that has to be used in conjunction with
processes and systems (both manual and automated) external to ARMS.


## Repository structure

* [doc](doc) - documentation
* [design](design) - contains the mockups developed for the forms
* src - contains the source code
* [support](support) - provides support scripts for deployment
* [test](test) - test plan

## Licence

All code is licensed under GPLv2 - see the [LICENSE](./LICENSE) file
for more details.

## Contact

General enquiries about ARMS should be directed to [RDSI](http://www.rdsi.edu.au).

Technical enquiries about ARMS should be directed to [QCIF](http://www.qcif.edu.au).

