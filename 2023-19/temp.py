def recursive(ranges, node):
	end_ranges = []
	if node == "R":
		return []
	elif node == "A":
		return [ranges]
	for rule_part in rules[node]:
		if ":" in rule_part:
			cond, dest = rule_part.split(":")
			sign = "<" if "<" in cond else ">"
			var, target = cond.split(sign)
			target = int(target)
			r = ranges[conv[var]]
			if sign == "<":
				if r[0] >= target:
					# this rule is unfollowable
					continue
				# the follow case
				nr = list(ranges)
				nr[conv[var]] = (r[0], min(r[1], target - 1))
				end_ranges.extend(recursive(tuple(nr), dest))

				# modify curr ranges too
				nr2 = list(ranges)
				nr2[conv[var]] = (max(r[0], target), r[1])
				ranges = tuple(nr2)
			elif sign == ">":
				if r[1] <= target:
					# this rule is unfollowable
					continue
				nr = list(ranges)
				nr[conv[var]] = (max(r[0], target + 1), r[1])
				end_ranges.extend(recursive(tuple(nr), dest))

				nr2 = list(ranges)
				nr2[conv[var]] = (r[0], min(r[1], target))
				ranges = tuple(nr2)
		else:
			assert ":" not in rule_part
			end_ranges.extend(recursive(tuple(ranges), rule_part))
	return end_ranges 
