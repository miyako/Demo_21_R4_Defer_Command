/*  Side-by-side comparison of two writing styles, on two examples.
	Both code panes are read from the real .4dm source files.
*/

property examples : Object
property exampleKeys : Collection
property scenarios : Object
property keys : Collection
property subtitle : Text
property legacyAll : Collection
property deferAll : Collection
property legacyLines : Collection
property deferLines : Collection
property metricsLegacy : Text
property metricsDefer : Text
property resultMessage : Text
property cleanupOnly : Boolean
property palette : Object

Class constructor()
	This.examples:={values: [\
		Localized string("DeferCompare_ExampleXML"); \
		Localized string("DeferCompare_ExampleBench")\
		]; index: 0}
	This.exampleKeys:=["xml"; "bench"]
	This.cleanupOnly:=False
	
	//MARK: - Form objects event handlers
	
Function formEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Load)
			This._resolvePalette()
			This._loadExample()
	End case 
	
Function dropExampleEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Data Change)
			This._loadExample()
	End case 
	
Function btnRunEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Clicked)
			This._runBoth()
	End case 
	
Function chkCleanupEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Clicked)
			This._applyFilter()
	End case 
	
	//MARK: - Examples
	
Function get isBenchmark() : Boolean
	return (This.exampleKeys[This.examples.index]="bench")
	
Function _loadExample()
	var $cleanupKey : Text
	If (This.isBenchmark)
		This.subtitle:=Localized string("DeferCompare_SubtitleBench")
		This.scenarios:={values: [\
			Localized string("DeferCompare_ScenarioBenchNominal"); \
			Localized string("DeferCompare_ScenarioBenchBlockedCustomer"); \
			Localized string("DeferCompare_ScenarioBenchUnknownProduct"); \
			Localized string("DeferCompare_ScenarioBenchBadCurrency"); \
			Localized string("DeferCompare_ScenarioBenchDiscountConflict")\
			]; index: 0}
		This.keys:=["nominal"; "blockedCustomer"; "unknownProduct"; "badCurrency"; "discountConflict"]
		This.legacyAll:=This._loadSource("PricingEngineLegacy")
		This.deferAll:=This._loadSource("PricingEngineDefer")
		$cleanupKey:="DeferCompare_MetricsCleanupBench"
	Else 
		This.subtitle:=Localized string("DeferCompare_SubtitleXML")
		This.scenarios:={values: [\
			Localized string("DeferCompare_ScenarioXMLNominal"); \
			Localized string("DeferCompare_ScenarioXMLCatalogVersion"); \
			Localized string("DeferCompare_ScenarioXMLTemplatePlaceholder"); \
			Localized string("DeferCompare_ScenarioXMLUnknownProduct")\
			]; index: 0}
		This.keys:=["nominal"; "catalogVersion"; "templatePlaceholder"; "unknownProduct"]
		This.legacyAll:=This._loadSource("XMLReportBuilderLegacy")
		This.deferAll:=This._loadSource("XMLReportBuilderDefer")
		$cleanupKey:="DeferCompare_MetricsCleanupXML"
	End if 
	This.resultMessage:=Localized string("DeferCompare_ResultPrompt")
	This.metricsLegacy:=This._metrics(This.legacyAll; $cleanupKey)
	This.metricsDefer:=This._metrics(This.deferAll; $cleanupKey)
	This._applyFilter()
	
	//MARK: - Demo driver
	
Function _runBoth()
	If (This.isBenchmark)
		This._runBenchmark()
	Else 
		This._runXML()
	End if 
	
Function _runXML()
	var $scenario : Text:=This.keys[This.scenarios.index]
	var $legacy : Object:=cs.XMLReportBuilderLegacy.me.build($scenario)
	var $defer : Object:=cs.XMLReportBuilderDefer.me.build($scenario)
	
	If (($legacy.exit=$defer.exit) && ($legacy.xml=$defer.xml) && ($legacy.message=$defer.message))
		This.resultMessage:=This._localized("DeferCompare_ResultSame"; {exit: $defer.exit; message: $defer.message})
	Else 
		This.resultMessage:=Localized string("DeferCompare_ResultDiverge")
	End if 
	This._spotExit($defer.exit)
	
Function _runBenchmark()
	var $scenario : Text:=This.keys[This.scenarios.index]
	var $bench : cs.BenchLog:=cs.BenchLog.me
	
	$bench.reset()
	var $legacy : Object:=cs.PricingEngineLegacy.me.compute($scenario)
	var $legacyStarted : Integer:=$bench.started
	var $legacyRecorded : Integer:=$bench.recorded
	
	$bench.reset()
	var $defer : Object:=cs.PricingEngineDefer.me.compute($scenario)
	var $deferStarted : Integer:=$bench.started
	var $deferRecorded : Integer:=$bench.recorded
	
	This.resultMessage:=This._localized("DeferCompare_ResultBench"; {exit: $defer.exit; \
		legacyRecorded: $legacyRecorded; legacyStarted: $legacyStarted; \
		deferRecorded: $deferRecorded; deferStarted: $deferStarted})
	This._spotExit($defer.exit)
	
Function _spotExit($exit : Integer)
	This._selectExitRow("lbLegacy"; This.legacyLines; $exit)
	This._selectExitRow("lbDefer"; This.deferLines; $exit)
	
	//MARK: - Source code panes
	
Function _loadSource($className : Text) : Collection
	var $lines : Collection:=[]
	var $file : 4D.File:=File("/SOURCES/Classes/"+$className+".4dm")
	If (Not($file.exists))
		$file:=Folder(fk database folder).file("Sources/Classes/"+$className+".4dm")
	End if 
	If (Not($file.exists))
		return $lines
	End if 
	
	var $text : Text:=$file.getText()
	$text:=Replace string($text; Char(Carriage return)+Char(Line feed); Char(Line feed))
	$text:=Replace string($text; Char(Carriage return); Char(Line feed))
	
	var $rawLines : Collection:=Split string($text; Char(Line feed))
	var $raw : Text
	var $num : Integer:=0
	For each ($raw; $rawLines)
		$num:=$num+1
		$lines.push(This._codeRow($num; $raw))
	End for each 
	return $lines
	
Function _codeRow($num : Integer; $raw : Text) : Object
	var $code : Text:=Replace string($raw; Char(Tab); "    ")
	var $kind : Text:="code"
	Case of 
		: (Position("!! FORGOTTEN"; $code)>0)
			$kind:="missing"
		: (Position("--- EXIT"; $code)>0)
			$kind:="exit"
		: (Position("defer("; $code)>0)
			$kind:="defer"
		: (Position("DOM CLOSE XML"; $code)>0)
			$kind:="cleanup"
		: (Position("$benchmark.stop()"; $code)>0)
			$kind:="cleanup"
		: (Position("//"; Replace string($code; " "; ""))=1)
			$kind:="comment"
	End case 
	return {num: $num; code: $code; kind: $kind}
	
	// Meta info expression of the code listboxes, evaluated on each row display.
Function rowMeta($row : Object) : Object
	
	return This._meta($row.kind)
	
Function _meta($kind : Text) : Object
	Case of 
		: ($kind="cleanup")
			return {stroke: This.palette.cleanup; fontWeight: "bold"}
		: ($kind="defer")
			return {stroke: This.palette.defer; fontWeight: "bold"}
		: ($kind="missing")
			return {stroke: "#FFFFFF"; fill: This.palette.missing; fontWeight: "bold"}
		: ($kind="exit")
			return {stroke: This.palette.exit; fontWeight: "bold"}
		: ($kind="comment")
			return {stroke: This.palette.comment; fontStyle: "italic"}
		Else 
			return {stroke: -255}
	End case 
	
	//MARK: - Colour scheme
	
	// Row colours come from hidden reference rectangles styled in styleSheets.css,
	// so they follow the light / dark colour scheme.
Function _resolvePalette()
	var $refs : Object:={comment: "refComment"; cleanup: "refCleanup"; \
		defer: "refDefer"; exit: "refExit"; missing: "refMissing"}
	var $kind : Text
	var $fg; $bg : Integer
	This.palette:={}
	For each ($kind; $refs)
		OBJECT GET RGB COLORS(*; $refs[$kind]; $fg; $bg)
		This.palette[$kind]:=This._toHex($bg)
	End for each 
	
Function _toHex($rgb : Integer) : Text
	var $digits : Text:="0123456789ABCDEF"
	var $hex : Text:="#"
	var $shift; $val : Integer
	For each ($shift; [16; 8; 0])
		$val:=($rgb >> $shift) & 0x00FF
		$hex:=$hex+$digits[[($val\16)+1]]+$digits[[($val%16)+1]]
	End for each 
	return $hex
	
Function _metrics($lines : Collection; $cleanupKey : Text) : Text
	var $cleanup : Integer:=$lines.query("kind in :1"; ["cleanup"; "defer"]).length
	var $exits : Integer:=$lines.query("kind = :1"; "exit").length
	return This._localized("DeferCompare_Metrics"; {lines: $lines.length; exits: $exits; \
		cleanup: This._localized($cleanupKey; {count: $cleanup})})
	
	// Localized string with {name} placeholders replaced by $values
Function _localized($id : Text; $values : Object) : Text
	var $text : Text:=Localized string($id)
	var $key : Text
	For each ($key; $values)
		$text:=Replace string($text; "{"+$key+"}"; String($values[$key]))
	End for each 
	return $text
	
Function _applyFilter()
	If (This.cleanupOnly)
		This.legacyLines:=This.legacyAll.query("kind in :1"; ["cleanup"; "defer"; "exit"; "missing"])
		This.deferLines:=This.deferAll.query("kind in :1"; ["cleanup"; "defer"; "exit"; "missing"])
	Else 
		This.legacyLines:=This.legacyAll
		This.deferLines:=This.deferAll
	End if 
	
Function _selectExitRow($objectName : Text; $lines : Collection; $exit : Integer)
	var $needle : Text:="--- EXIT "+String($exit)+" "
	var $i : Integer
	For ($i; 0; $lines.length-1)
		If (Position($needle; $lines[$i].code)>0)
			LISTBOX SELECT ROW(*; $objectName; $i+1; lk replace selection)
			return 
		End if 
	End for 
	