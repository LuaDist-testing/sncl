<?xml version="1.0" encoding="ISO-8859-1"?>
<ncl id="main" xmlns="http://www.ncl.org.br/NCL3.0/EDTVProfile">
	<head>
		<regionBase>
			<region id="rgFullScreen" height="100%" width="100%"  >
				<region id="rgHalfScreenLeft" height="50%" left="0" width="50%" />
				<region id="rgHalfScreenRight" height="50%" right="0" width="50%" />
			</region>
		</regionBase>
		<connectorBase>
		</connectorBase>
	</head>

	<body>
		<context id="context1">
			<port id="pContext1" component="media1Photo" />
			<media id="media1Photo" src="../media/photo1.jpg" >
				<property name="focusIndex" value="1"/>
			</media>
			<media id="media1Text" src="../media/text1.html" >
				<property name="focusIndex" value="1"/>
			</media>
		</context>


	</body>
</ncl>