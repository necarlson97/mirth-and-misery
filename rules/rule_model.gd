## base_rule.gd
## Rule = (hook, trigger, effect). At a given hook, if trigger passes, run effect.
class_name RuleModel
extends RefCounted

var hook: StringName
var trigger: TriggerModel
var effect: EffectModel

# TODO eventually will have to care about commandments and other non-villager
# sources of rules
var source: VillagerModel
var scope: int = RuleScope.SELF

class RuleScope:
	## A scope for what a rule's triggers will be evaluation on - just the calling
	## villager, all villagers, etc
	enum { SELF, ANY, OTHER }

func _init(
	_source: VillagerModel,
	h := StringName(), t := TriggerModel.new(), e := EffectModel.new(),
	_scope := RuleScope.SELF) -> void:
	# Many triggers are inherently tied to a certian part of the lifecycle
	# (such as OnVist trigger being hooked by 'OnVisit')
	source = _source
	trigger = t
	effect = e
	hook = h if h != StringName() else t.default_hook()
	assert(hook != StringName(), "Rule requires a hook (none provided and trigger has no default).")
	scope = _scope

func try_apply(ctx: SimContext) -> bool:
	if ctx.hook != hook:
		return false
	if not _scope_allows(ctx):
		return false
	if trigger.check(source, ctx):
		effect.apply(ctx, self)
		return true
	return false

func _scope_allows(ctx: SimContext) -> bool:
	match scope:
		RuleScope.SELF:  return ctx.villager == source
		RuleScope.ANY:   return true
		RuleScope.OTHER: return ctx.villager != source
		_:               return false

func _to_string() -> String:
	return "Rule(hook=%s, trigger=%s, effect=%s)" % [str(hook), trigger.to_string(), effect.to_string()]
