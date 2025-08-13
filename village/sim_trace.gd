## A minimal event log we can later replay/animate. For now it’s just strings.
class_name SimTrace
extends RefCounted

var lines: Array[String] = []

func log(msg: String) -> void:
	lines.append(msg)

func dump() -> String:
	return String("\n").join(lines)
