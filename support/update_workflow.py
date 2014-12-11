"""
Script to update records after "arms-provisioned", "arms-assessment" have been removed

Previously:
https://qcifltd.atlassian.net/wiki/display/ARMS/ARMS+2A+System+Requirements

This script updates tfpackage and workflow.metadata in relevant objects 

It used in conjunction with shell command grep: 
Usage:
    grep -rl "arms-assessment" * --include=*.metadata | python update_workflow.py review
    grep -rl "arms-provisioned" * --include=*.metadata | python update_workflow.py approved

After running this script, reindex
For more information, see:
 https://qcifltd.atlassian.net/browse/ARMSTWO-184
"""

import glob, sys, json, os.path

def changeWorkflowMeta(object_path, new_workflow):
    with open(object_path + "/workflow.metadata", 'w') as outfile:
        json.dump(new_workflow, outfile)
        outfile.close()

# Even this function is preferred but cannot be used as many tfpackage's do not comply with Python JSON module
def insert2tfpackage(object_path, x):
    fs = glob.glob(object_path + '/*.tfpackage')
    if len(fs) != 1:
        print "Why not there is only one tfpackage?"
        return

    tfpackage = fs[0]
    print "Updating %s" % tfpackage
    f = open(tfpackage)
    d = json.loads(f.read())
    f.close()

    k = x.viewkeys()
    for i in k:
        d[i] = x[i]

    with open(tfpackage, 'w') as outfile:
        json.dump(d, outfile)
        outfile.close()

def append2tfpackage(object_path, x):
    fs = glob.glob(object_path + '/*.tfpackage')
    if len(fs) != 1:
        print "Why not there is only one tfpackage?"
        return

    tfpackage = fs[0]
    print "Updating %s" % tfpackage
    f = open(tfpackage)
    d = f.read()
    f.close()
    d = d[:d.rfind('}')] + ',' + x + '}'

    with open(tfpackage, 'w') as outfile:
        outfile.write(d)
        outfile.close()

def dict2string(dic):
    items = []
    k = dic.viewkeys()
    for i in k:
        items.append("\"%s\":\"%s\"" % (i, dic[i]))
    return ",".join(items)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print "Usage: grep -rl {arms-assessment|arms-provisioned} path/* | python %s {review|approved}" % sys.argv[0]
        exit(1)

    stage = sys.argv[1]

    workflow_review = {"pageTitle": "RDSI ARMS Request", "step": "arms-review", "id": "arms", "label": "Being reviewed"}
    check_labels = {"provisioning_checklist:prefLabel.4": "Provisioned", "provisioning_checklist:prefLabel.3": "Provisioning in progress", "provisioning_checklist:prefLabel.2": "Allocation committee assessment completed", "provisioning_checklist:prefLabel.1": "Made available for assessment"}
    review_checks = {"provisioning_checklist.4": "null", "provisioning_checklist.3": "null", "provisioning_checklist.2": "null", "provisioning_checklist.1": "allocation-committee-notified"}

    workflow_approved = {"pageTitle": "RDSI ARMS Request", "step": "arms-approved", "id": "arms", "label": "Approved"}
    approved_checks = {"provisioning_checklist.4": "provisioned", "provisioning_checklist.3": "null", "provisioning_checklist.2": "null", "provisioning_checklist.1": "null"}

    tfpinsert_review = dict(check_labels.items() + review_checks.items())
    tfpinsert_approved = dict(check_labels.items() + approved_checks.items())

    workflows = {'review': workflow_review, 'approved': workflow_approved}

    tfpinserts = {'review': tfpinsert_review, 'approved': tfpinsert_approved }

    append_str = dict2string(tfpinserts[stage])

    for hit in sys.stdin:
        hit = hit.rstrip()
        print "Found: %s" % hit
        object_path = os.path.dirname(hit)
        print object_path
        print "Updating workflow.meta: %s/workflow.metadata " % object_path
        changeWorkflowMeta(object_path, workflows[stage])
        # ~ insert2tfpackage(object_path, tfpinserts[stage])
        append2tfpackage(object_path, append_str)