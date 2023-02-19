import QtQuick 1.1

Rectangle {
	width: 480
	height: 272
	color: "grey"

	Line {
		x1: 0
		y1: 0
		x2: 10
		y2: 0
		color: "blue"
	}

	Line {
		x1: 20
		y1: 0
		x2: 10
		y2: 0
		color: "red"
	}

	Rectangle {
		x: 1
		y: 1
		width: 19
		height: 1
		color: "black"
	}

	Line {
		x1: 0
		y1: 0
		x2: 0
		y2: 10
		color: "green"
	}

	Line {
		x1: 0
		y1: 20
		x2: 0
		y2: 10
		color: "white"
	}

	Rectangle {
		x: 1
		y: 1
		width: 1
		height: 19
		color: "black"
	}

	Rectangle {
		x: 479
		y: 261
		width: 1
		height: 10
		color: "black"
	}


	Line {
		x1: 479
		y1: 261
		x2: 479
		y2: 271
		color: "blue"
	}

	Line {
		x1: 469
		y1: 271
		x2: 479
		y2: 271
		color: "red"
	}


	Rectangle {
		x: 478
		y: 261
		width: 1
		height: 10
		color: "black"
	}

	/*
	Line {
		x1: 0
		y1: 0
		x2: 479
		y2: 271
		color: "red"

		Component.onCompleted: {
			console.log("x: " + x)
			console.log("y: " + y)
			console.log("width: " + width)
			console.log("height: " + height)
		}
	}
	*/
}
