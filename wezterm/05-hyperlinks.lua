local hyperlink_rules = require("wezterm").default_hyperlink_rules()

table.insert(hyperlink_rules, {
	-- JIRA Issues
	regex = [[\b([A-Z]+-\d+)\b]],
	format = "https://jira.sso.episerver.net/browse/$0",
	highlight = 1,
})

return {
	hyperlink_rules = hyperlink_rules,
}
