<?xml version="1.0" encoding="ISO-8859-1"?>
<ncl id="main" xmlns="http://www.ncl.org.br/NCL3.0/EDTVProfile">
	<head>
		<connectorBase>
			<causalConnector id="onBeginstart">
				<simpleCondition role="onBegin"/>
				<simpleAction role="start" />
			</causalConnector>
		</connectorBase>
	</head>

	<body>

		<link xconnector="onBeginstart">
			<bind role="onBegin" component="media1" />
			<bind role="start" component="media2"/>
		</link>

	</body>
</ncl>