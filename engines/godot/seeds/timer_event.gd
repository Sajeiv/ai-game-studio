# SEED: timer_event
# STATUS: verified
# DESCRIPTION: Fires triggered() after a configurable delay. Supports one-shot and looping.
# EXPORTS: wait_time, loop, autostart
# SIGNALS: triggered(), started(), stopped()

extends Node

@export var wait_time: float = 1.0
@export var loop: bool = false
@export var autostart: bool = false

signal triggered()
signal started()
signal stopped()

var _timer: Timer

func _ready() -> void:
	_timer = Timer.new()
	_timer.wait_time = wait_time
	_timer.one_shot = not loop
	add_child(_timer)
	_timer.timeout.connect(_on_timeout)
	if autostart:
		start()

func start() -> void:
	_timer.wait_time = wait_time
	_timer.start()
	started.emit()

func stop() -> void:
	_timer.stop()
	stopped.emit()

func reset() -> void:
	stop()
	start()

func _on_timeout() -> void:
	triggered.emit()
	if loop:
		started.emit()
