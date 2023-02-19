import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils

MbPage {
	id: root
	model: VisualItemModel {

			MbSubMenu {
                id: sensor0
			    property VBusItem name: VBusItem {bind: "com.victronenergy.sensors/Sensor/0/Name"}
                
                description: qsTr("%1").arg(name.value)
                subpage: Component {
                    PageRPISensor {
                        title: relayOverviewItem.description
                    }
                }
            }
            	MbSubMenu {
                id: sensor1
			    property VBusItem name: VBusItem {bind: "com.victronenergy.sensors/Sensor/1/Name"}
                
                description: qsTr("%1").arg(name.value)
                subpage: Component {
                    PageRPISensor {
                        title: relayOverviewItem.description
                    }
                }
            }
            	MbSubMenu {
                id: sensor2
			    property VBusItem name: VBusItem {bind: "com.victronenergy.sensors/Sensor/2/Name"}
                
                description: qsTr("%1").arg(name.value)
                subpage: Component {
                    PageRPISensor {
                        title: relayOverviewItem.description
                    }
                }
            }
            	MbSubMenu {
                id: sensor3
			    property VBusItem name: VBusItem {bind: "com.victronenergy.sensors/Sensor/3/Name"}
                
                description: qsTr("%1").arg(name.value)
                subpage: Component {
                    PageRPISensor {
                        title: relayOverviewItem.description
                    }
                }
            }
            	MbSubMenu {
                id: sensor4
			    property VBusItem name: VBusItem {bind: "com.victronenergy.sensors/Sensor/4/Name"}
                
                description: qsTr("%1").arg(name.value)
                subpage: Component {
                    PageRPISensor {
                        title: relayOverviewItem.description
                    }
                }
            }

            	MbSubMenu {
                id: sensor5
			    property VBusItem name: VBusItem {bind: "com.victronenergy.sensors/Sensor/5/Name"}
                
                description: qsTr("%1").arg(name.value)
                subpage: Component {
                    PageRPISensor {
                        title: relayOverviewItem.description
                    }
                }
            }
            	MbSubMenu {
                id: sensor6
			    property VBusItem name: VBusItem {bind: "com.victronenergy.sensors/Sensor/6/Name"}
                
                description: qsTr("%1").arg(name.value)
                subpage: Component {
                    PageRPISensor {
                        title: relayOverviewItem.description
                    }
                }
            }
            	MbSubMenu {
                id: sensor7
			    property VBusItem name: VBusItem {bind: "com.victronenergy.sensors/Sensor/7/Name"}
                
                description: qsTr("%1").arg(name.value)
                subpage: Component {
                    PageRPISensor {
                        title: relayOverviewItem.description
                    }
                }
            }
            	MbSubMenu {
                id: sensor8
			    property VBusItem name: VBusItem {bind: "com.victronenergy.sensors/Sensor/8/Name"}
                
                description: qsTr("%1").arg(name.value)
                subpage: Component {
                    PageRPISensor {
                        title: relayOverviewItem.description
                    }
                }
            }
            	MbSubMenu {
                id: sensor9
			    property VBusItem name: VBusItem {bind: "com.victronenergy.sensors/Sensor/9/Name"}
                
                description: qsTr("%1").arg(name.value)
                subpage: Component {
                    PageRPISensor {
                        title: relayOverviewItem.description
                    }
                }
            }
            
		
	

	}

}
