extends Spatial

var webxr_interface
var vr_supported = false

const Line = preload("res://Line.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$Button.connect("pressed", self, "_on_Button_pressed")
	webxr_interface = ARVRServer.find_interface("WebXR")
	if webxr_interface:
		# With Godot 3.5-beta4 and later, the following setting is recommended!
		# Map to the standard button/axis ids when possible.
		webxr_interface.xr_standard_mapping = true
 
		# WebXR uses a lot of asynchronous callbacks, so we connect to various
		# signals in order to receive them.
		webxr_interface.connect("session_supported", self, "_webxr_session_supported")
		webxr_interface.connect("session_started", self, "_webxr_session_started")
		webxr_interface.connect("session_ended", self, "_webxr_session_ended")
		webxr_interface.connect("session_failed", self, "_webxr_session_failed")
 
 
		# This returns immediately - our _webxr_session_supported() method 
		# (which we connected to the "session_supported" signal above) will
		# be called sometime later to let us know if it's supported or not.
		webxr_interface.is_session_supported("immersive-vr")
		

func _webxr_session_supported(session_mode: String, supported: bool) -> void:
	if session_mode == 'immersive-vr':
		vr_supported = supported

func _on_Button_pressed() -> void:
	if not vr_supported:
		OS.alert("Your browser doesn't support VR")
		return
 
	# We want an immersive VR session, as opposed to AR ('immersive-ar') or a
	# simple 3DoF viewer ('viewer').
	webxr_interface.session_mode = 'immersive-vr'
	# 'bounded-floor' is room scale, 'local-floor' is a standing or sitting
	# experience (it puts you 1.6m above the ground if you have 3DoF headset),
	# whereas as 'local' puts you down at the ARVROrigin.
	# This list means it'll first try to request 'bounded-floor', then 
	# fallback on 'local-floor' and ultimately 'local', if nothing else is
	# supported.
	webxr_interface.requested_reference_space_types = 'bounded-floor, local-floor, local'
	# In order to use 'local-floor' or 'bounded-floor' we must also
	# mark the features as required or optional.
	webxr_interface.required_features = 'local-floor'
	webxr_interface.optional_features = 'bounded-floor'
 
	# This will return false if we're unable to even request the session,
	# however, it can still fail asynchronously later in the process, so we
	# only know if it's really succeeded or failed when our 
	# _webxr_session_started() or _webxr_session_failed() methods are called.
	if not webxr_interface.initialize():
		OS.alert("Failed to initialize")
		return
 
func _webxr_session_started() -> void:
	$Button.visible = false
	self._setup()
	# This tells Godot to start rendering to the headset.
	get_viewport().arvr = true
	# This will be the reference space type you ultimately got, out of the
	# types that you requested above. This is useful if you want the game to
	# work a little differently in 'bounded-floor' versus 'local-floor'.
	print ("Reference space type: " + webxr_interface.reference_space_type)
 
func _webxr_session_ended() -> void:
	$Button.visible = true
	# If the user exits immersive mode, then we tell Godot to render to the web
	# page again.
	get_viewport().arvr = false
 
func _webxr_session_failed(message: String) -> void:
	OS.alert("Failed to initialize: " + message)

func _setup():
	for i in range(-100,100):
		var line = Line.instance()
		line.translate(Vector3(0,i,0))
		line.black=true
		self.add_child(line)
		
		var coin = randi()%int(floor(abs(i)/5)+1)
		if coin==1:
			var line_w = Line.instance()
			line_w.translate(Vector3(0,i+0.5,0))
			line_w.black=false
			self.add_child(line_w)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass