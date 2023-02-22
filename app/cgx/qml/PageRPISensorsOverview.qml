import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils

MbPage {
	id: root
	model: VisualItemModel {

			MbSubMenu {
                id: sensor0
		//	    property VBusItem name: VBusItem {bind: "com.victronenergy.sensors/Sensor/0/Name"}
                
                description: "Habitacion de Mateo"//qsTr("%1").arg(name.value)
                subpage: Component {
                    PageRPISensor {
                        sensor_num: '0'
                        title: qsTr("Sensor")
                    }
                }
            }
            MbSubMenu {
                id: sensor1
		//	    property VBusItem name: VBusItem {bind: "com.victronenergy.sensors/Sensor/0/Name"}
                
                description: "Gas Cocina"//qsTr("%1").arg(name.value)
                subpage: Component {
                    PageRPISensor {
                        sensor_num: '1'
                        title: qsTr("Sensor")
                    }
                }
            }	
            MbSubMenu {
                id: sensor2
		//	    property VBusItem name: VBusItem {bind: "com.victronenergy.sensors/Sensor/0/Name"}
                
                description: "Sensor 3"//qsTr("%1").arg(name.value)
                subpage: Component {
                    PageRPISensor {
                        sensor_num: '3'
                        title: qsTr("Sensor")
                    }
                }
            }
            MbSubMenu {
                id: sensor3
		//	    property VBusItem name: VBusItem {bind: "com.victronenergy.sensors/Sensor/0/Name"}
                
                description: "Sensor 4"//qsTr("%1").arg(name.value)
                subpage: Component {
                    PageRPISensor {
                        sensor_num: '3'
                        title: qsTr("Sensor")
                    }
                }
            }
            MbSubMenu {
                id: sensor4
		//	    property VBusItem name: VBusItem {bind: "com.victronenergy.sensors/Sensor/0/Name"}
                
                description: "Sensor 5"//qsTr("%1").arg(name.value)
                subpage: Component {
                    PageRPISensor {
                        sensor_num: '4'
                        title: qsTr("Sensor")
                    }
                }
            }
            MbSubMenu {
                id: sensor5
		//	    property VBusItem name: VBusItem {bind: "com.victronenergy.sensors/Sensor/0/Name"}
                
                description: "Sensor 6"//qsTr("%1").arg(name.value)
                subpage: Component {
                    PageRPISensor {
                        sensor_num: '5'
                        title: qsTr("Sensor")
                    }
                }
            }
            MbSubMenu {
                id: sensor6
		//	    property VBusItem name: VBusItem {bind: "com.victronenergy.sensors/Sensor/0/Name"}
                
                description: "Sensor 7"//qsTr("%1").arg(name.value)
                subpage: Component {
                    PageRPISensor {
                        sensor_num: '6'
                        title: qsTr("Sensor")
                    }
                }
            }
            MbSubMenu {
                id: sensor7
		//	    property VBusItem name: VBusItem {bind: "com.victronenergy.sensors/Sensor/0/Name"}
                
                description: "Sensor 8"//qsTr("%1").arg(name.value)
                subpage: Component {
                    PageRPISensor {
                        sensor_num: '7'
                        title: qsTr("Sensor")
                    }
                }
            }
            MbSubMenu {
                id: sensor8
		//	    property VBusItem name: VBusItem {bind: "com.victronenergy.sensors/Sensor/0/Name"}
                
                description: "Sensor 9"//qsTr("%1").arg(name.value)
                subpage: Component {
                    PageRPISensor {
                        sensor_num: '8'
                        title: qsTr("Sensor")
                    }
                }
            }
            MbSubMenu {
                id: sensor9
		//	    property VBusItem name: VBusItem {bind: "com.victronenergy.sensors/Sensor/0/Name"}
                
                description: "Sensor 10"//qsTr("%1").arg(name.value)
                subpage: Component {
                    PageRPISensor {
                        sensor_num: '9'
                        title: qsTr("Sensor")
                    }
                }
            }
	}

}
