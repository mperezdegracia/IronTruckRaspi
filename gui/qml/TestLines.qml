import QtQuick 1.1

Rectangle {
	width: 480
	height: 272
	color: "grey"

	// case 1
	Line {
		from: from1
		to: to1
		color: "black"
		lineWidth: 2
	}

	OverviewBall {
		id: from1
		x: 100
		y: 100
		color: "black"
	}

	OverviewBall {
		id: to1
		x: from1.x + 100
		y: from1.y + 50
	}

	// case 2
	Line {
		from: from2
		to: to2
		color: "black"
		lineWidth: 2
	}

	OverviewBall {
		id: from2
		x: 350
		y: 100
		color: "black"
	}

	OverviewBall {
		id: to2
		x: from2.x - 100
		y: from2.y + 50
	}

	// case 3
	Line {
		from: from3
		to: to3
		color: "black"
		lineWidth: 2
	}

	OverviewBall {
		id: from3
		x: 250
		y: 250
		color: "black"
	}

	OverviewBall {
		id: to3
		x: from3.x + 100
		y: from3.y - 50
	}

	// case 4
	Line {
		from: from4
		to: to4
		color: "black"
		lineWidth: 2
	}

	OverviewBall {
		id: from4
		x: 200
		y: 250
		color: "black"
	}

	OverviewBall {
		id: to4
		x: from4.x - 100
		y: from4.y - 50
	}
}

