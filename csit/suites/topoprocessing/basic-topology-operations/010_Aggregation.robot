*** Settings ***
Documentation     Test suite to verify unification operation on different models.
...               Before test starts, configurational file have to be rewriten to change listners registration datastore type from CONFIG_API to OPERATIONAL_API.
...               Need for this change is also a reason why main feature (odl-topoprocessing-framework) is installed after file change and not during boot.
...               Suite setup also install features required for tested models, clear karaf logs for further synchronization. Tests themselves send configurational
...               xmls and verify output. Topology-id on the end of each urls must match topology-id from xml. Yang models of components in topology are defined in xmls.
Suite Setup       Setup Environment
Suite Teardown    Clean Environment
Test Teardown     Test Teardown    network-topology:network-topology/topology/topo:1
Library           RequestsLibrary
Library           SSHLibrary
Library           XML
Variables         ../../../variables/topoprocessing/TopologyRequests.py
Variables         ../../../variables/Variables.py
Resource          ../../../libraries/KarafKeywords.robot
Resource          ../../../libraries/Utils.robot
Resource          ../../../libraries/TopoprocessingKeywords.robot

*** Test Cases ***
Unification Node
    [Documentation]    Test unification operation on Network Topology model
    ${model}    Set Variable    network-topology-model
    ${request}    Prepare Unification Topology Request    ${UNIFICATION_NT}    ${model}    node    network-topo:1    network-topo:2
    ${request}    Insert Target Field    ${request}    0    l3-unicast-igp-topology:igp-node-attributes/isis-topology:isis-node-attributes/isis-topology:ted/isis-topology:te-router-id-ipv4    0
    ${request}    Insert Target Field    ${request}    1    l3-unicast-igp-topology:igp-node-attributes/isis-topology:isis-node-attributes/isis-topology:ted/isis-topology:te-router-id-ipv4    0
    ${resp}    Send Basic Request And Test If Contain X Times    ${request}    network-topology:network-topology/topology/topo:1    <node-id>node:    8
    Should Contain    ${resp.content}    <topology-id>topo:1</topology-id>
    Should Contain X Times    ${resp.content}    <supporting-node>    10
    Should Contain X Times    ${resp.content}    <termination-point    14
    Should Contain X Times    ${resp.content}    <tp-ref>    14
    Check Aggregated Node in Topology    ${model}    ${resp.content}    2    bgp:5    bgp:10
    Check Aggregated Node in Topology    ${model}    ${resp.content}    1    bgp:9
    Check Aggregated Node in Topology    ${model}    ${resp.content}    1    bgp:8
    Check Aggregated Node in Topology    ${model}    ${resp.content}    2    bgp:7
    Check Aggregated Node in Topology    ${model}    ${resp.content}    1    bgp:6
    Check Aggregated Node in Topology    ${model}    ${resp.content}    4    bgp:3    bgp:4
    Check Aggregated Node in Topology    ${model}    ${resp.content}    0    bgp:2
    Check Aggregated Node in Topology    ${model}    ${resp.content}    3    bgp:1

Unification Node Inventory
    [Documentation]    Test unification operation on inventory model
    ${model}    Set Variable    opendaylight-inventory-model
    ${request}    Prepare Unification Topology Request    ${UNIFICATION_NT}    ${model}    node    openflow-topo:1    openflow-topo:2
    ${request}    Insert Target Field    ${request}    0    flow-node-inventory:ip-address    0
    ${request}    Insert Target Field    ${request}    1    flow-node-inventory:ip-address    0
    ${resp}    Send Basic Request And Test If Contain X Times    ${request}    network-topology:network-topology/topology/topo:1    <node-id>node:    7
    Should Contain    ${resp.content}    <topology-id>topo:1</topology-id>
    Should Contain X Times    ${resp.content}    <supporting-node>    10
    Should Contain X Times    ${resp.content}    <termination-point    12
    Should Contain X Times    ${resp.content}    <tp-ref>    12
    Check Aggregated Node in Topology    ${model}    ${resp.content}    3    of-node:10    of-node:4
    Check Aggregated Node in Topology    ${model}    ${resp.content}    0    of-node:7    of-node:9
    Check Aggregated Node in Topology    ${model}    ${resp.content}    0    of-node:8
    Check Aggregated Node in Topology    ${model}    ${resp.content}    2    of-node:6    of-node:1
    Check Aggregated Node in Topology    ${model}    ${resp.content}    1    of-node:5
    Check Aggregated Node in Topology    ${model}    ${resp.content}    3    of-node:3
    Check Aggregated Node in Topology    ${model}    ${resp.content}    3    of-node:2

Unification Scripting Node
    [Documentation]    Test unification operation on Network Topology model using scripting
    ${model}    Set Variable    network-topology-model
    ${request}    Prepare Unification Topology Request    ${UNIFICATION_NT}    ${model}    node    network-topo:1    network-topo:2
    ${request}    Insert Target Field    ${request}    0    l3-unicast-igp-topology:igp-node-attributes/isis-topology:isis-node-attributes/isis-topology:ted/isis-topology:te-router-id-ipv4    0
    ${request}    Insert Target Field    ${request}    1    l3-unicast-igp-topology:igp-node-attributes/isis-topology:isis-node-attributes/isis-topology:ted/isis-topology:te-router-id-ipv4    0
    ${request}    Insert Scripting into Request    ${request}    javascript    if (originalItem.getLeafNodes().get(java.lang.Integer.valueOf('0')).getValue().indexOf("192.168.1.1") > -1 && newItem.getLeafNodes().get(java.lang.Integer.valueOf('0')).getValue().indexOf("192.168.1.3") > -1 || originalItem.getLeafNodes().get(java.lang.Integer.valueOf('0')).getValue().indexOf("192.168.1.3") > -1 && newItem.getLeafNodes().get(java.lang.Integer.valueOf('0')).getValue().indexOf("192.168.1.1") > -1) {aggregable.setResult(true);} else { aggregable.setResult(false);}
    ${resp}    Send Basic Request And Test If Contain X Times    ${request}    network-topology:network-topology/topology/topo:1    <node-id>node:    9
    Should Contain    ${resp.content}    <topology-id>topo:1</topology-id>
    Should Contain X Times    ${resp.content}    <supporting-node>    10
    Should Contain X Times    ${resp.content}    <termination-point    14
    Should Contain X Times    ${resp.content}    <tp-ref>    14
    Check Aggregated Node in Topology    ${model}    ${resp.content}    1    bgp:10
    Check Aggregated Node in Topology    ${model}    ${resp.content}    1    bgp:9
    Check Aggregated Node in Topology    ${model}    ${resp.content}    1    bgp:8
    Check Aggregated Node in Topology    ${model}    ${resp.content}    2    bgp:7
    Check Aggregated Node in Topology    ${model}    ${resp.content}    4    bgp:1    bgp:6
    Check Aggregated Node in Topology    ${model}    ${resp.content}    1    bgp:5
    Check Aggregated Node in Topology    ${model}    ${resp.content}    2    bgp:4
    Check Aggregated Node in Topology    ${model}    ${resp.content}    2    bgp:3
    Check Aggregated Node in Topology    ${model}    ${resp.content}    0    bgp:2

Unification Scripting Node Inventory
    [Documentation]    Test unification operation on inventory model using scripting
    ${model}    Set Variable    opendaylight-inventory-model
    ${request}    Prepare Unification Topology Request    ${UNIFICATION_NT}    ${model}    node    openflow-topo:1    openflow-topo:2
    ${request}    Insert Target Field    ${request}    0    flow-node-inventory:ip-address    0
    ${request}    Insert Target Field    ${request}    1    flow-node-inventory:ip-address    0
    ${request}    Insert Scripting into Request    ${request}    javascript    if (originalItem.getLeafNodes().get(java.lang.Integer.valueOf('0')).getValue().indexOf("192.168.1.2") > -1 && newItem.getLeafNodes().get(java.lang.Integer.valueOf('0')).getValue().indexOf("192.168.1.4") > -1 || originalItem.getLeafNodes().get(java.lang.Integer.valueOf('0')).getValue().indexOf("192.168.1.4") > -1 && newItem.getLeafNodes().get(java.lang.Integer.valueOf('0')).getValue().indexOf("192.168.1.2") > -1) {aggregable.setResult(true);} else { aggregable.setResult(false);}
    ${resp}    Send Basic Request And Test If Contain X Times    ${request}    network-topology:network-topology/topology/topo:1    <node-id>node:    9
    Should Contain    ${resp.content}    <topology-id>topo:1</topology-id>
    Should Contain X Times    ${resp.content}    <supporting-node>    10
    Should Contain X Times    ${resp.content}    <termination-point    12
    Should Contain X Times    ${resp.content}    <tp-ref>    12
    Check Aggregated Node in Topology    ${model}    ${resp.content}    0    of-node:10
    Check Aggregated Node in Topology    ${model}    ${resp.content}    0    of-node:9
    Check Aggregated Node in Topology    ${model}    ${resp.content}    3    of-node:2    of-node:8
    Check Aggregated Node in Topology    ${model}    ${resp.content}    0    of-node:7
    Check Aggregated Node in Topology    ${model}    ${resp.content}    0    of-node:6
    Check Aggregated Node in Topology    ${model}    ${resp.content}    1    of-node:5
    Check Aggregated Node in Topology    ${model}    ${resp.content}    3    of-node:4
    Check Aggregated Node in Topology    ${model}    ${resp.content}    3    of-node:3
    Check Aggregated Node in Topology    ${model}    ${resp.content}    2    of-node:1

Unification Node Inside
    [Documentation]    Test of unification type of aggregation inside on nodes on Network Topology model
    ${model}    Set Variable    network-topology-model
    ${request}    Prepare Unification Inside Topology Request    ${UNIFICATION_NT_AGGREGATE_INSIDE}    ${model}    node    network-topo:1
    ${request}    Insert Target Field    ${request}    0    l3-unicast-igp-topology:igp-node-attributes/isis-topology:isis-node-attributes/isis-topology:ted/isis-topology:te-router-id-ipv4    0
    ${resp}    Send Basic Request And Test If Contain X Times    ${request}    network-topology:network-topology/topology/topo:1    <node-id>node:    4
    Should Contain    ${resp.content}    <topology-id>topo:1</topology-id>
    Should Contain X Times    ${resp.content}    <supporting-node>    5
    Should Contain X Times    ${resp.content}    <termination-point    8
    Should Contain X Times    ${resp.content}    <tp-ref>    8
    Check Aggregated Node in Topology    ${model}    ${resp.content}    1    bgp:5
    Check Aggregated Node in Topology    ${model}    ${resp.content}    4    bgp:3    bgp:4
    Check Aggregated Node in Topology    ${model}    ${resp.content}    0    bgp:2
    Check Aggregated Node in Topology    ${model}    ${resp.content}    3    bgp:1

Unification Node Inside Inventory
    [Documentation]    Test of unification type of aggregation inside on nodes on Inventory model
    ${model}    Set Variable    opendaylight-inventory-model
    ${request}    Prepare Unification Inside Topology Request    ${UNIFICATION_NT_AGGREGATE_INSIDE}    ${model}    node    openflow-topo:2
    ${request}    Insert Target Field    ${request}    0    flow-node-inventory:ip-address    0
    ${resp}    Send Basic Request And Test If Contain X Times    ${request}    network-topology:network-topology/topology/topo:1    <node-id>node:    4
    Should Contain    ${resp.content}    <topology-id>topo:1</topology-id>
    Should Contain X Times    ${resp.content}    <supporting-node>    5
    Should Contain X Times    ${resp.content}    <termination-point    0
    Should Contain X Times    ${resp.content}    <supporting-termination-point>    0
    Check Aggregated Node in Topology    ${model}    ${resp.content}    0    of-node:10
    Check Aggregated Node in Topology    ${model}    ${resp.content}    0    of-node:7    of-node:9
    Check Aggregated Node in Topology    ${model}    ${resp.content}    0    of-node:8
    Check Aggregated Node in Topology    ${model}    ${resp.content}    0    of-node:6

Unification Termination Point Inside
    [Documentation]    Test aggregate inside operation on termination points
    ${model}    Set Variable    network-topology-model
    ${request}    Prepare Unification Inside Topology Request    ${UNIFICATION_NT_AGGREGATE_INSIDE}    ${model}    termination-point    network-topo:1
    ${request}    Insert Target Field    ${request}    0    ovsdb:ofport    0
    ${resp}    Send Basic Request And Test If Contain X Times    ${request}    network-topology:network-topology/topology/topo:1    <node-id>node:    5
    Should Contain    ${resp.content}    <topology-id>topo:1</topology-id>
    Should Contain X Times    ${resp.content}    <supporting-node>    5
    Should Contain X Times    ${resp.content}    <tp-ref>    8
    Should Contain X Times    ${resp.content}    <termination-point    6
    ${topology_id}    Set Variable    network-topo:1
    Check Aggregated Termination Point in Node    ${model}    ${resp.content}    ${topology_id}    bgp:1    tp:1:1    tp:1:1
    ...    tp:1:2
    Check Aggregated Termination Point in Node    ${model}    ${resp.content}    ${topology_id}    bgp:1    tp:1:3    tp:1:3
    Check Aggregated Termination Point in Node    ${model}    ${resp.content}    ${topology_id}    bgp:3    tp:3:1    tp:3:1
    Check Aggregated Termination Point in Node    ${model}    ${resp.content}    ${topology_id}    bgp:3    tp:3:2    tp:3:2
    Check Aggregated Termination Point in Node    ${model}    ${resp.content}    ${topology_id}    bgp:4    tp:4:1    tp:4:1
    ...    tp:4:2
    Check Aggregated Termination Point in Node    ${model}    ${resp.content}    ${topology_id}    bgp:5    tp:5:1    tp:5:1

Unification Termination Point Inside Inventory
    [Documentation]    Test aggregate inside operation on termination points
    ${model}    Set Variable    opendaylight-inventory-model
    ${request}    Prepare Unification Inside Topology Request    ${UNIFICATION_NT_AGGREGATE_INSIDE}    ${model}    termination-point    openflow-topo:1
    ${request}    Insert Target Field    ${request}    0    flow-node-inventory:port-number    0
    ${resp}    Send Basic Request And Test If Contain X Times    ${request}    network-topology:network-topology/topology/topo:1    <node-id>node:    5
    Should Contain    ${resp.content}    <topology-id>topo:1</topology-id>
    Should Contain X Times    ${resp.content}    <supporting-node>    5
    Should Contain X Times    ${resp.content}    <tp-ref>    12
    Should Contain X Times    ${resp.content}    <termination-point>    8
    ${topology_id}    Set Variable    openflow-topo:1
    Check Aggregated Termination Point in Node    ${model}    ${resp.content}    ${topology_id}    of-node:5    tp:5:1    tp:5:1
    Check Aggregated Termination Point in Node    ${model}    ${resp.content}    ${topology_id}    of-node:4    tp:4:1    tp:4:1
    ...    tp:4:2    tp:4:3
    Check Aggregated Termination Point in Node    ${model}    ${resp.content}    ${topology_id}    of-node:3    tp:3:1    tp:3:1
    ...    tp:3:2
    Check Aggregated Termination Point in Node    ${model}    ${resp.content}    ${topology_id}    of-node:3    tp:3:3    tp:3:3
    Check Aggregated Termination Point in Node    ${model}    ${resp.content}    ${topology_id}    of-node:2    tp:2:1    tp:2:1
    Check Aggregated Termination Point in Node    ${model}    ${resp.content}    ${topology_id}    of-node:2    tp:2:2    tp:2:2
    Check Aggregated Termination Point in Node    ${model}    ${resp.content}    ${topology_id}    of-node:2    tp:2:3    tp:2:3
    Check Aggregated Termination Point in Node    ${model}    ${resp.content}    ${topology_id}    of-node:1    tp:1:1    tp:1:1
    ...    tp:1:2
