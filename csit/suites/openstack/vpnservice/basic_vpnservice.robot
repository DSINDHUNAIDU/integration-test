*** Settings ***
Documentation     Test suite to validate vpnservice functionality in an openstack integrated environment.
...               The assumption of this suite is that the environment is already configured with the proper
...               integration bridges and vxlan tunnels.
Suite Setup       Basic Vpnservice Suite Setup
Suite Teardown    Basic Vpnservice Suite Teardown
Library           SSHLibrary
Library           OperatingSystem
Library           RequestsLibrary
Resource          ../../../libraries/Utils.robot
Resource          ../../../libraries/OpenStackOperations.robot
Resource          ../../../libraries/DevstackUtils.robot
Variables         ../../../variables/Variables.py

*** Variables ***
${net_1}    NET10
${net_2}    NET20
${subnet_1}    SUBNET1
${subnet_2}    SUBNET2
${subnet_1_cidr}    10.1.1.0/24
${subnet_2_cidr}    20.1.1.0/24
${port_1}    PORT1
${port_2}    PORT2
${port_3}    PORT3
${port_4}    PORT4

*** Test Cases ***
Verify Tunnel Creation
    [Documentation]    Checks that vxlan tunnels have been created properly.
    [Tags]    exclude
    Log    This test case is currently a noop, but work can be added here to validate if needed.  However, as the
    ...    suite Documentation notes, it's already assumed that the environment has been configured properly.  If
    ...    we do add work in this test case, we need to remove the "exclude" tag for it to run.  In fact, if this
    ...    test case is critical to run, and if it fails we would be dead in the water for the rest of the suite,
    ...    we should move it to Suite Setup so that nothing else will run and waste time in a broken environment.

#TC1
Create Neutron Networks
    [Documentation]    Create two networks
    Create Network    ${net_1}    --provider:network_type local
    Create Network    ${net_2}    --provider:network_type local
    List Networks

Create Neutron Subnets
    [Documentation]    Create two subnets for previously created networks
    Create SubNet    ${net_1}    ${subnet_1}    ${subnet_1_cidr}
    Create SubNet    ${net_2}    ${subnet_2}    ${subnet_2_cidr}
    List Subnets

Create Neutron Ports
    [Documentation]    Create four ports under previously created subnets
    Create Port    ${net_1}    ${port_1}
    Create Port    ${net_1}    ${port_2}
    Create Port    ${net_2}    ${port_3}
    Create Port    ${net_2}    ${port_4}

Check OpenDaylight Neutron Ports
    [Documentation]    Checking OpenDaylight Neutron API for known ports
    ${resp}    RequestsLibrary.Get Request    session    ${NEUTRON_PORTS_API}
    Log    ${resp.content}
    Should be Equal As Strings    ${resp.status_code}    200

*** Keywords ***
Basic Vpnservice Suite Setup
    Create Session    session    http://${ODL_SYSTEM_IP}:${RESTCONFPORT}    auth=${AUTH}    headers=${HEADERS}

Basic Vpnservice Suite Teardown
    Delete All Sessions
