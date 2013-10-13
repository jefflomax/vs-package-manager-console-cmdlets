$answers =
	"As I see it, yes", 
	"Reply hazy, try again", 
	"Outlook not so good",
	"Dog's barking, can't fly without umbrella",
	"Kerbyl Blatins horse feathers",
	"Flap Quack",
	"Purple cows invading",
	"Let me out of here right now"

function Get-Answer($question) {
	$answers | Get-Random
}

Export-ModuleMember Get-Answer
