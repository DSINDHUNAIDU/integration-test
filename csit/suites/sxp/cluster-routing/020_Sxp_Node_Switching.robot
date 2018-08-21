*** Settings ***
Documentation     Test suite to test cluster connection and propagation switchover using virtual ip, this suite requires additional TOOLS_SYSTEM VM.
...               VM is used for its assigned ip-address that will be overlayed by virtual-ip used in test suites.
...               Resources of this VM are not required and after start of Test suite this node shutted down and to reduce routing conflicts.
Suite Setup       Setup Custom SXP Cluster Session
Suite Teardown    Clean Custom SXP Cluster Session
Test Teardown     Clean SXP Cluster
Library           ../../../libraries/Sxp.py
Resource          ../../../libraries/ClusterManagement.robot
Resource          ../../../libraries/SxpClusterLib.robot

*** Test Cases ***
Isolation of SXP service follower Test
    [Documentation]    Test SXP connection switchover only if Controller with SCS is isolated
    SxpClusterLib.Check Shards Status
    Setup Custom SXP Cluster    ${VIRTUAL_IP}    listener
    ${controller_index} =    SxpClusterLib.Get Active Controller
    Isolate SXP Controller    ${controller_index}    listener

Isolation of SXP service follower Test Listener Part
    [Documentation]    Test SXP binding propagation only if Controller with SCS is isolated
    SxpClusterLib.Check Shards Status
    ${controller_index} =    SxpClusterLib.Get Active Controller
    Setup Custom SXP Cluster    ${VIRTUAL_IP}    listener
    Setup SXP Cluster Bindings    ${CLUSTER_NODE_ID}    controller${controller_index}
    ${controller_index} =    SxpClusterLib.Get Active Controller
    Isolate SXP Controller With Bindings    ${controller_index}    ${DEVICE_NODE_ID}    listener    ${DEVICE_SESSION}

Isolation of SXP service follower Test Speaker Part
    [Documentation]    Test SXP binding propagation only if Controller with SCS is isolated,
    ...    the same case as above but with initiator of connection between nodes in oposite mode
    SxpClusterLib.Check Shards Status
    Setup Custom SXP Cluster    ${VIRTUAL_IP}    speaker
    Setup SXP Cluster Bindings    ${DEVICE_NODE_ID}    ${DEVICE_SESSION}
    ${controller_index} =    SxpClusterLib.Get Active Controller
    Isolate SXP Controller With Bindings    ${controller_index}    ${CLUSTER_NODE_ID}    speaker

*** Keywords ***
Setup Custom SXP Cluster Session
    [Documentation]    Prepare topology for testing, creates sessions and generate Route definitions based on Cluster nodes ip
    SxpClusterLib.Shutdown Tools Node
    SxpClusterLib.Setup SXP Cluster Session
    ${controller_index} =    SxpClusterLib.Get Active Controller
    ${mac_addresses} =    SxpClusterLib.Map Followers To Mac Addresses
    BuiltIn.Set Suite Variable    ${MAC_ADDRESS_TABLE}    ${mac_addresses}
    ${route} =    Sxp.Route Definition Xml    ${VIRTUAL_IP}    ${VIRTUAL_IP_MASK}    ${VIRTUAL_INTERFACE}
    ${routes} =    Sxp.Route Definitions Xml    ${route}
    SxpLib.Put Routing Configuration To Controller    ${routes}    controller${controller_index}

Clean Custom SXP Cluster Session
    [Documentation]    Cleans up resources generated by test
    ${controller_index} =    SxpClusterLib.Get Active Controller
    SxpLib.Clean Routing Configuration To Controller    controller${controller_index}
    SxpClusterLib.Clean SXP Cluster Session

Setup Custom SXP Cluster
    [Arguments]    ${peer_address}    ${peer_mode}
    [Documentation]    Setup and connect SXP cluster topology
    SxpLib.Add Node    ${DEVICE_NODE_ID}    ip=0.0.0.0    session=${DEVICE_SESSION}
    BuiltIn.Wait Until Keyword Succeeds    20    1    SxpLib.Check Node Started    ${DEVICE_NODE_ID}    session=${DEVICE_SESSION}    system=${TOOLS_SYSTEM_IP}
    ...    ip=${EMPTY}
    ${cluster_mode} =    Sxp.Get Opposing Mode    ${peer_mode}
    SxpLib.Add Connection    version4    ${peer_mode}    ${peer_address}    64999    ${DEVICE_NODE_ID}    session=${DEVICE_SESSION}
    ${controller_id} =    SxpClusterLib.Get Active Controller
    SxpLib.Add Node    ${CLUSTER_NODE_ID}    ip=${peer_address}    session=controller${controller_id}
    BuiltIn.Wait Until Keyword Succeeds    20    1    SxpClusterLib.Check Cluster Node started    ${CLUSTER_NODE_ID}
    SxpLib.Add Connection    version4    ${cluster_mode}    ${TOOLS_SYSTEM_IP}    64999    ${CLUSTER_NODE_ID}    session=controller${controller_id}
    BuiltIn.Wait Until Keyword Succeeds    120    1    SxpClusterLib.Check Cluster is Connected    ${CLUSTER_NODE_ID}    mode=${cluster_mode}    session=controller${controller_id}

Setup SXP Cluster Bindings
    [Arguments]    ${node}    ${session}
    [Documentation]    Setup initial bindings to SXP device
    : FOR    ${i}    IN RANGE    1    ${BINDINGS}
    \    SxpLib.Add Bindings    ${i}0    ${i}.${i}.${i}.${i}/32    node=${node}    session=${session}

Isolate SXP Controller
    [Arguments]    ${controller_index}    ${peer_mode}
    [Documentation]    Isolate one of cluster nodes and perform check that Device is still connected then revert isolation (and check connection again).
    ${cluster_mode} =    Sxp.Get Opposing Mode    ${peer_mode}
    ClusterManagement.Isolate_Member_From_List_Or_All    ${controller_index}
    BuiltIn.Wait Until Keyword Succeeds    240    1    ClusterManagement.Sync_Status_Should_Be_False    ${controller_index}
    BuiltIn.Wait Until Keyword Succeeds    240    1    SxpClusterLib.Ip Addres Should Not Be Routed To Follower    ${MAC_ADDRESS_TABLE}    ${VIRTUAL_IP}    ${controller_index}
    ${active_follower} =    SxpClusterLib.Get Active Controller
    BuiltIn.Wait Until Keyword Succeeds    240    1    SXpClusterLib.Ip Addres Should Be Routed To Follower    ${MAC_ADDRESS_TABLE}    ${VIRTUAL_IP}    ${active_follower}
    BuiltIn.Wait Until Keyword Succeeds    60    1    SxpClusterLib.Check Cluster is Connected    ${CLUSTER_NODE_ID}    mode=${cluster_mode}    session=controller${active_follower}
    BuiltIn.Wait Until Keyword Succeeds    60    1    Check Device is Connected    ${DEVICE_NODE_ID}    ${VIRTUAL_IP}    ${peer_mode}
    ...    session=${DEVICE_SESSION}
    ClusterManagement.Flush_Iptables_From_List_Or_All
    BuiltIn.Wait Until Keyword Succeeds    240    1    ClusterManagement.Sync_Status_Should_Be_True    ${controller_index}
    BuiltIn.Wait Until Keyword Succeeds    60    1    SxpClusterLib.Check Cluster is Connected    ${CLUSTER_NODE_ID}    mode=${cluster_mode}    session=controller${active_follower}
    BuiltIn.Wait Until Keyword Succeeds    60    1    Check Device is Connected    ${DEVICE_NODE_ID}    ${VIRTUAL_IP}    ${peer_mode}
    ...    session=${DEVICE_SESSION}

Isolate SXP Controller With Bindings
    [Arguments]    ${controller_index}    ${node}    ${peer_mode}    ${session}=${EMPTY}
    [Documentation]    Isolate one of cluster nodes and perform check that bindings were propagated then revert isolation (and check connection again).
    ${find_session} =    BuiltIn.Set Variable If    '${session}' == '${EMPTY}'    ${True}    ${False}
    ${cluster_mode} =    Sxp.Get Opposing Mode    ${peer_mode}
    ${session} =    BuiltIn.Set Variable If    ${find_session}    controller${controller_index}    ${session}
    ClusterManagement.Isolate_Member_From_List_Or_All    ${controller_index}
    BuiltIn.Wait Until Keyword Succeeds    240    1    ClusterManagement.Sync_Status_Should_Be_False    ${controller_index}
    BuiltIn.Wait Until Keyword Succeeds    240    1    SxpClusterLib.Ip Addres Should Not Be Routed To Follower    ${MAC_ADDRESS_TABLE}    ${VIRTUAL_IP}    ${controller_index}
    ${active_follower} =    SxpClusterLib.Get Active Controller
    BuiltIn.Wait Until Keyword Succeeds    240    1    SXpClusterLib.Ip Addres Should Be Routed To Follower    ${MAC_ADDRESS_TABLE}    ${VIRTUAL_IP}    ${active_follower}
    BuiltIn.Wait Until Keyword Succeeds    60    1    SxpClusterLib.Check Cluster is Connected    ${CLUSTER_NODE_ID}    mode=${cluster_mode}    session=controller${active_follower}
    BuiltIn.Wait Until Keyword Succeeds    60    1    Check Device is Connected    ${DEVICE_NODE_ID}    ${VIRTUAL_IP}    ${peer_mode}
    ...    session=${DEVICE_SESSION}
    ${session} =    BuiltIn.Set Variable If    ${find_session}    controller${active_follower}    ${session}
    BuiltIn.Wait Until Keyword Succeeds    30    1    Check Bindings    ${node}    ${session}
    ClusterManagement.Flush_Iptables_From_List_Or_All
    BuiltIn.Wait Until Keyword Succeeds    240    1    ClusterManagement.Sync_Status_Should_Be_True    ${controller_index}
    BuiltIn.Wait Until Keyword Succeeds    60    1    SxpClusterLib.Check Cluster is Connected    ${CLUSTER_NODE_ID}    mode=${cluster_mode}    session=controller${active_follower}
    BuiltIn.Wait Until Keyword Succeeds    60    1    Check Device is Connected    ${DEVICE_NODE_ID}    ${VIRTUAL_IP}    ${peer_mode}
    ...    session=${DEVICE_SESSION}
    BuiltIn.Wait Until Keyword Succeeds    30    1    Check Bindings    ${node}    ${session}

Check Device is Connected
    [Arguments]    ${node}    ${remote_ip}    ${mode}=any    ${version}=version4    ${port}=64999    ${session}=session
    [Documentation]    Checks if SXP device is connected to at least one cluster node
    ${resp} =    SxpLib.Get Connections    node=${node}    session=${session}
    SxpLib.Should Contain Connection    ${resp}    ${remote_ip}    ${port}    ${mode}    ${version}

Check Bindings
    [Arguments]    ${node}    ${session}
    [Documentation]    Checks that bindings were propagated to Peer
    ${resp}    SxpLib.Get Bindings    node=${node}    session=${session}
    : FOR    ${i}    IN RANGE    1    ${BINDINGS}
    \    SxpLib.Should Contain Binding    ${resp}    ${i}0    ${i}.${i}.${i}.${i}/32
