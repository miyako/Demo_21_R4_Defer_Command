// Opens the "defer" code comparison window (non-modal).
#DECLARE($params : Object)

var $splashWindowTitle : Text
$splashWindowTitle:=""

var $window : Integer

If (Count parameters=0)
	
	ARRAY LONGINT($windows; 0)
	WINDOW LIST($windows)
	
	var $i : Integer
	For ($i; 1; Size of array($windows))
		$window:=$windows{$i}
		If (Window process($window)=1) && (Get window title($window)=$splashWindowTitle)
			var $x; $y; $bottom; $right : Integer
			GET WINDOW RECT($x; $y; $bottom; $right; $window)
			CALL FORM($window; Formula(SET WINDOW RECT($x; $y; $bottom; $right; $window)))
			return 
		End if 
	End for 
	
	CALL WORKER(1; Current method name; {})
	
Else 
	
	SET MENU BAR(1)
	
	$window:=Open form window("DeferCompare"; Plain form window; Horizontally centered; Vertically centered)
	SET WINDOW TITLE($splashWindowTitle; $window)
	DIALOG("DeferCompare"; *)
	
End if 
