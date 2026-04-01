extends CanvasLayer

var time_elapsed:float=0.0
var apples_collected:int=0
var timer_active:bool=true

func _ready():
	$ScoreLabel.text="Apples:0"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if timer_active:
		time_elapsed+=delta
		
		@warning_ignore("integer_division")
		var minutes=int(time_elapsed)/60
		var seconds=int(time_elapsed)%60
		var milliseconds =int((time_elapsed-int(time_elapsed))*100)
		$TimerLabel.text="%02d:%02d.%02d"%[minutes,seconds,milliseconds]
		
func add_apple():
	apples_collected+=1
	$ScoreLabel.text="Apples: "+str(apples_collected)
	
func stop_timer():
	timer_active=false
