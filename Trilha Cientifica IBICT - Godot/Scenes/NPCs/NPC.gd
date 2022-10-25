extends KinematicBody

# Identifica os dialogos feitos no Dialogic
export(String, "TimelineDropdown") var timeline: String
# Adiciona um canvas direto do Dialogic
export(bool) var add_canvas = true
# Controla se o NPC deve ter zoom no dialogo
export(bool) var zoom_camera = false
# Checa quando ele pode falar ou nao
var canTalk: bool = false
var player
var mainCam
var pointer

func _ready():
	mainCam = get_tree().get_nodes_in_group("Camera")[0]
	pointer = get_tree().get_nodes_in_group("Pointer")[0]

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_select") and canTalk:
		start_dialogue()
		canTalk = false

func start_dialogue():
	# Se o zoom estiver ativo, ativa a camera NPC e esconde o jogador 
	if zoom_camera:
		$Base/Camera.current = true
		player.hide()
	
	# Adiciona o dialogo na cena
	var d = Dialogic.start(timeline, '', "res://addons/dialogic/Nodes/DialogNode.tscn", add_canvas)
	get_parent().call_deferred('add_child', d)
	d.connect("dialogic_signal",self,'dialogic_signal')
	
	# Ativa o state Talking do personagem pra ele ficar parado
	player.get_node("States/Talking").visible = true
	# Gira o NPC pra posiçao do player
	$Base.look_at(transform.origin + player.global_transform.origin.direction_to(transform.origin),Vector3.UP)
	yield(get_tree().create_timer(0.1),"timeout")
	# Gira o player pra posicao do NPC
	player.get_node("Base").look_at(player.global_transform.origin + global_transform.origin.direction_to(player.transform.origin),Vector3.UP)
	# Esconde o ponteiro da cena e o balao da cabeca do NPC
	pointer.hide()
	$Baloon.hide()
	
func dialogic_signal(arg):
	# Quando o signal for emitido ao final do dialogo
	if arg == "cabou":
		# Se o zoom estiver ativo, mostra o jogador novamente
		if zoom_camera:
			player.show()
		
		# Desativa a camera do NPC novamente
		$Base/Camera.current = false
		# Mostra o balao de fala eo pointer 
		$Baloon.show()
		pointer.show()
		# Habilita a camera do player novamente
		mainCam.current = true
		# Habilita o state Move do player novamente
		player.get_node("States/Talking").visible = false
		player.get_node("States/Move").visible = true
		yield(get_tree().create_timer(0.1),"timeout")
		canTalk = true

func _on_Area_body_entered(body):
	if body.is_in_group("Player"):
		$Baloon.show()
		canTalk = true
		player = body

func _on_Area_body_exited(body):
	if body.is_in_group("Player"):
		$Baloon.hide()
		canTalk = false
