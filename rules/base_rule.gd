## base_rule.gd
## Rule = (hook, trigger, effect). At a given hook, if trigger passes, run effect.
class_name BaseRule
extends RefCounted

var hook: StringName
var trigger: BaseTrigger
var effect: BaseEffect

func _init(h := StringName(), t := BaseTrigger.new(), e := BaseEffect.new()) -> void:
	# Many triggers are inherently tied to a certian part of the lifecycle
	# (such as OnVist trigger being hooked by 'OnVisit')
	trigger = t
	effect = e
	hook = h if h != StringName() else t.default_hook()
	assert(hook != StringName(), "Rule requires a hook (none provided and trigger has no default).")

func try_apply(h: StringName, ctx: Object) -> bool:
	# Returns true if effect ran.
	if h != hook:
		return false
	if trigger.check(ctx):
		effect.apply(ctx)
		return true
	return false

func _to_string() -> String:
	return "Rule(hook=%s, trigger=%s, effect=%s)" % [str(hook), trigger.to_string(), effect.to_string()]
