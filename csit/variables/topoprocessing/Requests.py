UNIFICATION_NT = '''<topology xmlns="urn:opendaylight:topology:correlation" xmlns:n="urn:TBD:params:xml:ns:yang:network-topology">
                        <n:topology-id>unif:1</n:topology-id>
                        <correlations>
                            <output-model>network-topology-model</output-model>
                            <correlation>
                                <correlation-id>1</correlation-id>
                                <type>aggregation-only</type>
                                <correlation-item>node</correlation-item>
                                <aggregation>
                                    <aggregation-type>unification</aggregation-type>
                                    <mapping>
                                        <input-model>network-topology-model</input-model>
                                        <underlay-topology>und-topo:1</underlay-topology>
                                        <target-field>network-topology-pcep:path-computation-client/network-topology-pcep:ip-address</target-field>
                                        <aggregate-inside>false</aggregate-inside>
                                    </mapping>
                                    <mapping>
                                        <input-model>network-topology-model</input-model>
                                        <underlay-topology>und-topo:2</underlay-topology>
                                        <target-field>network-topology-pcep:path-computation-client/network-topology-pcep:ip-address</target-field>
                                        <aggregate-inside>false</aggregate-inside>
                                    </mapping>
                                </aggregation>
                            </correlation>
                        </correlations>
                    </topology>'''

UNDERLAY_TOPOLOGY_1 = '''<topology
                                xmlns="urn:TBD:params:xml:ns:yang:network-topology"
                                xmlns:pcep="urn:opendaylight:params:xml:ns:yang:topology:pcep">
                            <topology-id>und-topo:1</topology-id>
                            <topology-types>
                                <pcep:topology-pcep></pcep:topology-pcep>
                            </topology-types>
                            <node>
                                <node-id>pcep:1</node-id>
                                <pcep:path-computation-client>
                                    <pcep:ip-address>192.168.1.1</pcep:ip-address>
                                </pcep:path-computation-client>
                            </node>
                            <node>
                                <node-id>pcep:2</node-id>
                                <pcep:path-computation-client>
                                    <pcep:ip-address>192.168.1.2</pcep:ip-address>
                                </pcep:path-computation-client>
                            </node>
                            <node>
                                <node-id>pcep:3</node-id>
                                <pcep:path-computation-client>
                                    <pcep:ip-address>192.168.2.1</pcep:ip-address>
                                </pcep:path-computation-client>
                            </node>
                            <node>
                                <node-id>pcep:4</node-id>
                                <pcep:path-computation-client>
                                    <pcep:ip-address>192.168.2.2</pcep:ip-address>
                                </pcep:path-computation-client>
                            </node>
                            <node>
                                <node-id>pcep:5</node-id>
                                <pcep:path-computation-client>
                                    <pcep:ip-address>192.168.2.3</pcep:ip-address>
                                </pcep:path-computation-client>
                            </node>
                        </topology>'''

UNDERLAY_TOPOLOGY_2 = '''<topology
                                xmlns="urn:TBD:params:xml:ns:yang:network-topology"
                                xmlns:pcep="urn:opendaylight:params:xml:ns:yang:topology:pcep">
                            <topology-id>und-topo:2</topology-id>
                            <topology-types>
                                <pcep:topology-pcep></pcep:topology-pcep>
                            </topology-types>
                            <node>
                                <node-id>pcep:6</node-id>
                                <pcep:path-computation-client>
                                    <pcep:ip-address>192.168.1.3</pcep:ip-address>
                                </pcep:path-computation-client>
                            </node>
                            <node>
                                <node-id>pcep:7</node-id>
                                <pcep:path-computation-client>
                                    <pcep:ip-address>192.168.1.4</pcep:ip-address>
                                </pcep:path-computation-client>
                            </node>
                            <node>
                                <node-id>pcep:8</node-id>
                                <pcep:path-computation-client>
                                    <pcep:ip-address>192.168.2.4</pcep:ip-address>
                                </pcep:path-computation-client>
                            </node>
                            <node>
                                <node-id>pcep:9</node-id>
                                <pcep:path-computation-client>
                                    <pcep:ip-address>192.168.2.5</pcep:ip-address>
                                </pcep:path-computation-client>
                            </node>
                            <node>
                                <node-id>pcep:10</node-id>
                                <pcep:path-computation-client>
                                    <pcep:ip-address>192.168.2.3</pcep:ip-address>
                                </pcep:path-computation-client>
                            </node>
                        </topology>'''
